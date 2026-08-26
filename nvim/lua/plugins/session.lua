return {
  "folke/persistence.nvim",
  opts = { branch = false },
  init = function()
    local group = vim.api.nvim_create_augroup("SessionAutoRestore", { clear = true })

    -- 会话恢复的 buffer 在 VimEnter autocmd 栈内被 :source 加载，栈内事件不派发
    -- （autocmd 默认非 nested），导致 BufReadPost/FileType 未触发：无语法高亮、无 LSP。
    -- 对这类"僵尸"buffer 强制重读，让事件链在栈外正常走一遍。
    local function fix_zombies()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local name = vim.api.nvim_buf_get_name(buf)
        if
          name ~= ""
          and vim.bo[buf].buftype == ""
          and vim.fn.isdirectory(name) == 0
          and vim.bo[buf].filetype == ""
          and not vim.bo[buf].modified
        then
          pcall(vim.api.nvim_win_call, win, function()
            vim.cmd("silent! edit")
          end)
        end
      end
    end

    -- 清掉残留的目录 buffer（`nvim <dir>` 的初始目录 buffer 等）
    local function wipe_dir_buffers()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        local n = vim.api.nvim_buf_get_name(b)
        if n ~= "" and vim.bo[b].buftype == "" and vim.fn.isdirectory(n) == 1 then
          pcall(vim.api.nvim_buf_delete, b, { force = true })
        end
      end
    end

    -- VimEnter 自动恢复（早于 dashboard/UIEnter，无闪烁无残留；require 经 lazy loader 加载插件）
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      callback = function()
        local argc = vim.fn.argc()
        local dir_arg = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
        -- 无参数，或唯一参数是目录（nvim . / nvim ~/project）都处理
        if argc ~= 0 and not dir_arg then
          return
        end
        local persistence = require("persistence")
        local restored = false
        if vim.fn.filereadable(persistence.current()) == 1 then
          persistence.load()
          restored = true
        end
        wipe_dir_buffers()
        -- 修复与开树必须延迟到 VimEnter 栈外（栈内事件不派发）：
        -- schedule 在 VimEnter 事件结束后立即执行，此时事件链已恢复，且早于 dashboard
        vim.schedule(function()
          if restored then
            fix_zombies()
            -- 注意：neo-tree 的 action 只有 close/focus/show，reveal 是 flag
            local cmd = require("neo-tree.command")
            pcall(cmd.execute, {
              action = "focus",
              source = "filesystem",
              position = "left",
              reveal = true,
              dir = vim.fn.getcwd(),
            })
          elseif dir_arg then
            local cmd = require("neo-tree.command")
            pcall(cmd.execute, {
              action = "focus",
              source = "filesystem",
              position = "left",
              dir = vim.fn.fnamemodify(vim.fn.argv(0), ":p"),
            })
          end
        end)
        -- 启动期对 `nvim <dir>` 临时禁用了 hijack（neo-tree.lua 的 opts），恢复默认行为（中途 :e <dir> 仍走树）
        if dir_arg and package.loaded["neo-tree"] then
          require("neo-tree").config.filesystem.hijack_netrw_behavior = "open_default"
        end
      end,
    })
    -- 保存前关闭 neo-tree，避免会话文件包含树窗口（恢复后会重新打开）
    vim.api.nvim_create_autocmd("User", {
      group = group,
      pattern = "PersistenceSavePre",
      callback = function()
        if package.loaded["neo-tree"] then
          vim.cmd("Neotree close")
        end
      end,
    })
  end,
}
