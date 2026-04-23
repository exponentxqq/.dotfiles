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
  for _, path in ipairs(vim.fn.glob("/usr/lib/jvm/*/bin/java", true, true) --[[@as string[] ]]) do
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
        opts.cmd = cmd
      end

      local home = project_jdk_home()
      local java_extra = {
        configuration = {
          updateBuildConfiguration = "automatic",
        },
        eclipse = {
          downloadSources = true,
        },
        maven = {
          downloadSources = true,
        },
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
      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = java_extra,
      })

      return opts
    end,
  },
}
