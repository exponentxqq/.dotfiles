local STATUS = require("overseer.constants").STATUS

-- 容器内长驻任务（bootRun 等）经 docker exec 启动：overseer 的 jobstop 只杀宿主侧
-- exec 客户端，容器内进程不受影响。本组件在任务被取消（stop / nvim 退出）时，按唯一
-- tag（经 --nvim.task=<tag> 注入应用 JVM cmdline）pkill 容器内对应进程。
---@type overseer.ComponentFileDefinition
return {
  desc = "Canceled 时 pkill 容器内 cmdline 含 --nvim.task=<tag> 的进程（docker exec 停止兜底）",
  params = {
    tag = {
      desc = "唯一标记，与 --nvim.task=<tag> 注入值一致",
      type = "string",
    },
    run_sh = {
      desc = "docker 体系 run.sh 路径",
      type = "string",
      optional = true,
      default = "/home/xuqinqin/develop/docker/run.sh",
    },
  },
  constructor = function(params)
    return {
      on_complete = function(_, _, status)
        if status ~= STATUS.CANCELED then
          return
        end
        if vim.fn.filereadable(params.run_sh) ~= 1 then
          return
        end
        vim.fn.jobstart(
          { params.run_sh, "java", "pkill -f 'nvim[.]task=" .. params.tag .. "'" },
          { detach = true }
        )
      end,
    }
  end,
}
