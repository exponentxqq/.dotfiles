-- JDTLS 进程本身需要 JVM ≥ 21（Mason 的 jdtls 脚本会校验）；项目仍可用 JDK 17。
-- 可选：export JDTLS_JAVA_HOME=/usr/lib/jvm/java-21-openjdk
-- 项目 JDK：继续用 JAVA_HOME（例如 java-17-openjdk）。
-- DAP 调试由 LazyVim Java extra 自动配置，不要在此手动设置。

---@return string?
local function project_jdk_home()
  local from_env = vim.env.JAVA_HOME
  if from_env and from_env ~= "" then
    return vim.fs.normalize(vim.trim(from_env))
  end
  local out = vim.fn.system({ "sh", "-c", 'dirname "$(dirname "$(readlink -f "$(command -v java)")")"' })
  if vim.v.shell_error == 0 and out and out:match("%S") then
    return vim.fs.normalize(vim.trim(out))
  end
  return nil
end

---@param java_exe string
---@return integer?
local function java_major_version(java_exe)
  local out = vim.fn.system({ java_exe, "-version" })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local major = out:match('"(%d+)') or out:match('version "%d+%.(%d+)') -- 1.8 style
  return major and tonumber(major) or nil
end

---@return string?
local function jdtls_java_executable()
  local home = vim.env.JDTLS_JAVA_HOME
  if home and home ~= "" then
    local exe = vim.fs.normalize(vim.trim(home)) .. "/bin/java"
    if vim.uv.fs_stat(exe) and (java_major_version(exe) or 0) >= 21 then
      return exe
    end
  end
  for _, candidate in ipairs({
    "/usr/lib/jvm/java-21-openjdk/bin/java",
    "/usr/lib/jvm/java-22-openjdk/bin/java",
    "/usr/lib/jvm/java-openjdk/bin/java", -- Arch "当前默认 JDK"，可能是 21+
  }) do
    if vim.uv.fs_stat(candidate) then
      local v = java_major_version(candidate)
      if v and v >= 21 then
        return candidate
      end
    end
  end
  for _, path in
    ipairs(vim.fn.glob("/usr/lib/jvm/*/bin/java", true, true) --[[@as string[] ]])
  do
    local v = java_major_version(path)
    if v and v >= 21 then
      return path
    end
  end
  return nil
end

---@param home string
local function java_se_runtime_name(home)
  local f = io.open(home .. "/release", "r")
  if not f then
    return "JavaSE-17"
  end
  for line in f:lines() do
    local v = line:match('JAVA_VERSION="([^"]+)"')
    if v then
      f:close()
      local major = v:match("^(%d+)")
      return major and ("JavaSE-" .. major) or "JavaSE-17"
    end
  end
  f:close()
  return "JavaSE-17"
end

--- 从指定目录（默认当前 buffer）向上查找 gradle-wrapper.properties 并解析 Gradle 版本（如 "8.5"）
--- 兼容 8.5-bin.zip / 8.14.3-bin.zip / 6.0.1-all.zip 及各镜像 URL
---@param start string? 查找起点目录，默认当前 buffer 或 cwd
---@return string?
local function gradle_wrapper_version(start)
  if not start then
    local buf = vim.api.nvim_buf_get_name(0)
    start = (buf ~= "" and vim.fs.dirname(buf)) or vim.uv.cwd()
  end
  local props = vim.fs.find("gradle-wrapper.properties", {
    upward = true,
    path = start,
    stop = vim.fs.normalize("~"),
  })
  if not props[1] then
    return nil
  end
  for line in io.lines(props[1]) do
    local v = line:match("gradle%-(%d+%.%d+%.?%d*)%-%w+%.zip")
    if v then
      return v
    end
  end
  return nil
end

return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      -- 确保 on_attach 回调存在
      local old_on_attach = opts.on_attach
      opts.on_attach = function(client, bufnr)
        if old_on_attach then
          old_on_attach(client, bufnr)
        end
        -- 设置 Java 特定的键映射
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gr", vim.lsp.buf.references, "Go to references")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
        map("n", "<leader>ci", require("jdtls").organize_imports, "Organize imports")
      end
      local run_java = jdtls_java_executable()
      if not run_java then
        vim.notify(
          "未找到 Java 21+：请安装 JDK 21（如 pacman -S jdk-openjdk）或设置 JDTLS_JAVA_HOME",
          vim.log.levels.ERROR
        )
      else
        local cmd = vim.deepcopy(opts.cmd)
        table.insert(cmd, 2, "--java-executable=" .. run_java)
        -- 清除已有 JVM 内存参数（含 --jvm-arg= 前缀），统一注入封顶限制
        for i, arg in ipairs(cmd) do
          if arg:match("^%-X") or arg:match("^%-%-jvm%-arg=%-X") then
            cmd[i] = nil
          end
        end
        local jvm_args = {
          "--jvm-arg=-Xmx4g",
          "--jvm-arg=-Xms512m",
          "--jvm-arg=-XX:MaxMetaspaceSize=512m",
          "--jvm-arg=-XX:+UseG1GC",
          "--jvm-arg=-XX:MaxGCPauseMillis=100",
          "--jvm-arg=-XX:SoftRefLRUPolicyMSPerMB=50",
          "--jvm-arg=-XX:ReservedCodeCacheSize=128m",
          "--jvm-arg=-XX:MaxDirectMemorySize=256m",
          "--jvm-arg=-Xss512k",
        }
        for i = #jvm_args, 1, -1 do
          table.insert(cmd, 2, jvm_args[i])
        end
        opts.cmd = cmd
      end

      local home = project_jdk_home()
      local java_extra = {
        configuration = {
          updateBuildConfiguration = "automatic",
        },
        eclipse = {
          downloadSources = false,
        },
        maven = {
          downloadSources = false,
        },
        autobuild = {
          enabled = true,
        },
        maxConcurrentBuilds = 4,
      }
      if home then
        java_extra.configuration.runtimes = {
          {
            name = java_se_runtime_name(home),
            path = home,
            default = true,
          },
        }
        java_extra.import = {
          gradle = {
            java = { home = home },
          },
        }
      end
      java_extra.import = vim.tbl_deep_extend("force", java_extra.import or {}, {
        gradle = {
          jvmArguments = "-Xmx512m -XX:MaxMetaspaceSize=384m -XX:MaxDirectMemorySize=256m -XX:+UseG1GC -Dfile.encoding=UTF-8",
        },
      })
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = java_extra,
      })

      -- 逐项目解析 wrapper 版本 + settings 镜像进 init_options。
      -- 注意：lazy.nvim 的 opts 求值每进程仅一次，版本若在 opts 阶段解析会被「烤死」为
      -- 首个打开的项目；opts.jdtls 作为函数由 LazyVim 在每次 attach_jdtls 时调用
      -- （此时 config.root_dir 已知），从而实现每个 jdtls client 跟随自己项目的 wrapper。
      -- init_options 镜像让 jdt.ls 的 BaseInitHandler 在 initialize 阶段即读取 settings，
      -- 消除「先按内嵌 8.9 探查、settings 到达后再重同步」的启动竞态。
      local prev_jdtls = opts.jdtls
      opts.jdtls = function(config)
        if type(prev_jdtls) == "function" then
          config = prev_jdtls(config) or config
        elseif type(prev_jdtls) == "table" then
          config = vim.tbl_deep_extend("force", config, prev_jdtls)
        end
        local v = config.root_dir and gradle_wrapper_version(config.root_dir)
        if v then
          -- deepcopy 避免污染跨项目共享的 opts.settings 表
          config.settings = vim.tbl_deep_extend("force", vim.deepcopy(config.settings or {}), {
            java = { import = { gradle = { version = v } } },
          })
        end
        config.init_options = vim.tbl_deep_extend("force", config.init_options or {}, {
          settings = config.settings,
        })
        return config
      end

      opts.dap_main = false

      opts.project_name = function(root_dir)
        if not root_dir then
          return nil
        end
        local parent = vim.fs.basename(vim.fs.dirname(root_dir))
        local name = vim.fs.basename(root_dir)
        return parent and (parent .. "-" .. name) or name
      end

      return opts
    end,
  },
}
