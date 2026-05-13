local overseer = require("overseer")

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
      table.insert(ret, {
        name = "gradle " .. t,
        builder = function()
          return { cmd = { gradle_bin, t }, cwd = cwd }
        end,
      })
    end

    -- Async: fetch full task list from gradle
    overseer.builtin.system(
      { gradle_bin, "-q", "tasks", "--all", "--console=plain", "--no-daemon" },
      { cwd = cwd, text = true },
      vim.schedule_wrap(function(out)
        if out.code ~= 0 then
          -- Even if gradle tasks fails, we still have the quick tasks
          return cb(ret)
        end

        for line in vim.gsplit(out.stdout, "\n") do
          -- Match lines like "taskName - Description"
          local task_name, desc = line:match("^(%S+) %- (.+)$")
          if task_name
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
              table.insert(ret, {
                name = "gradle " .. task_name,
                builder = function()
                  return { cmd = { gradle_bin, task_name }, cwd = cwd }
                end,
              })
            end
          end
        end
        cb(ret)
      end)
    )
  end,
}
