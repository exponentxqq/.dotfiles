local overseer = require("overseer")

-- docker 体系 run.sh：自动拉起 java 容器 + 容器内 cd 到调用者目录执行命令。
-- 存在即容器化执行（个人开发机统一工具链/缓存）；否则回退宿主直跑 gradlew。
local RUN_SH = "/home/xuqinqin/develop/docker/run.sh"

local function container_mode()
  return vim.fn.filereadable(RUN_SH) == 1
end

---@param opts overseer.SearchParams
local function detect_gradle(opts)
  local indicators = { "settings.gradle", "settings.gradle.kts", "build.gradle", "build.gradle.kts" }
  for _, name in ipairs(indicators) do
    local found = vim.fs.find(name, { upward = true, type = "file", path = opts.dir })
    if #found > 0 then
      return vim.fs.dirname(found[1])
    end
  end
  return nil
end

-- "portal-app:boot:bootRun" → "<cwd>/portal-app/boot"；根任务 "bootRun" → nil
-- （gradle tasks --all 输出的任务名不带前导冒号；`:foo:bootRun` 形式也兼容）
local function boot_module_dir(cwd, task_name)
  local mod = task_name:match("^:?(.+):bootRun$")
  if not mod then
    return nil
  end
  return vim.fs.joinpath(cwd, (mod:gsub(":", "/")))
end

local function has_local_profile(dir)
  return dir ~= nil
    and vim.fn.filereadable(vim.fs.joinpath(dir, "src", "main", "resources", "application-local.yml")) == 1
end

-- bootRun 任务增强：模块（或单模块项目根）有 application-local.yml 时注入 local profile；
-- 所有 bootRun 任务注入唯一 tag 供 docker_kill_on_stop 组件 stop 时兜底 pkill。
-- 容器模式经 run.sh 整串执行（引号由容器内 bash 解析）；宿主回退直接 argv。
local function make_builder(gradle_bin, cwd, task_name, is_boot, with_local)
  return function()
    if not container_mode() then
      return { cmd = { gradle_bin, task_name }, cwd = cwd }
    end
    if is_boot then
      local tag = string.format("%d", vim.loop.hrtime())
      local args = {}
      if with_local then
        table.insert(args, "--spring.profiles.active=local")
      end
      table.insert(args, "--nvim.task=" .. tag)
      return {
        cmd = {
          RUN_SH,
          "java",
          "./gradlew " .. task_name .. " --args='" .. table.concat(args, " ") .. "'",
        },
        cwd = cwd,
        components = { { "docker_kill_on_stop", tag = tag, run_sh = RUN_SH } },
      }
    end
    return { cmd = { RUN_SH, "java", "./gradlew " .. task_name }, cwd = cwd }
  end
end

return {
  cache_key = function(opts)
    return detect_gradle(opts)
  end,
  generator = function(opts, cb)
    local cwd = detect_gradle(opts)
    if not cwd then
      return "No Gradle project found"
    end

    local gradle_bin = vim.fs.joinpath(cwd, "gradlew")
    if vim.fn.executable(gradle_bin) ~= 1 then
      gradle_bin = "gradle"
      if vim.fn.executable(gradle_bin) ~= 1 then
        return "Could not find gradle or gradlew"
      end
    end

    local ret = {}

    -- Always add these essential tasks (fast path)
    local quick_tasks = { "build", "test", "clean", "assemble", "bootRun", "run", "check" }
    for _, t in ipairs(quick_tasks) do
      local is_boot = t == "bootRun"
      local with_local = is_boot and has_local_profile(cwd)
      table.insert(ret, {
        name = "gradle " .. t,
        builder = make_builder(gradle_bin, cwd, t, is_boot, with_local),
      })
    end

    -- Async: fetch full task list from gradle（探测也走容器，避免宿主启 daemon）
    local probe
    if container_mode() then
      probe = { RUN_SH, "java", "./gradlew -q tasks --all --console=plain --no-daemon" }
    else
      probe = { gradle_bin, "-q", "tasks", "--all", "--console=plain", "--no-daemon" }
    end
    overseer.builtin.system(probe, { cwd = cwd, text = true }, vim.schedule_wrap(function(out)
      if out.code ~= 0 then
        -- Even if gradle tasks fails, we still have the quick tasks
        return cb(ret)
      end

      for line in vim.gsplit(out.stdout, "\n") do
        -- Match lines like "taskName - Description"
        local task_name, desc = line:match("^(%S+) %- (.+)$")
        if
          task_name
          and not task_name:match("^[%u%s]+$") -- skip category headers
          and not task_name:match("^%-+$") -- skip separator lines
          and not task_name:match("^>") -- skip gradle output prefix
        then
          local already_added = false
          for _, t in ipairs(ret) do
            if t.name == "gradle " .. task_name then
              already_added = true
              break
            end
          end
          if not already_added then
            local is_boot = task_name:match(":bootRun$") ~= nil
            local with_local = is_boot
              and has_local_profile(boot_module_dir(cwd, task_name))
            table.insert(ret, {
              name = "gradle " .. task_name .. (with_local and " [local]" or ""),
              builder = make_builder(gradle_bin, cwd, task_name, is_boot, with_local),
            })
          end
        end
      end
      cb(ret)
    end))
  end,
}
