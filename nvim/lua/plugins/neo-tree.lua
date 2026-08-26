local function first_file_deep(root)
  local path = root
  for _ = 1, 20 do
    local entries = vim.fn.readdir(path)
    table.sort(entries)
    for _, e in ipairs(entries) do
      if not e:match("^%.") and vim.fn.isdirectory(path .. "/" .. e) == 0 then
        return path .. "/" .. e
      end
    end
    local sub
    for _, e in ipairs(entries) do
      if not e:match("^%.") and vim.fn.isdirectory(path .. "/" .. e) == 1 then
        sub = path .. "/" .. e
        break
      end
    end
    if not sub then
      return nil
    end
    path = sub
  end
end

local function smart_reveal(dir)
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname ~= "" and vim.bo.filetype ~= "neo-tree" and vim.fn.filereadable(bufname) == 1 then
    return nil
  end
  return first_file_deep(dir)
end

local startup_dir = vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      group_empty_dirs = true, -- 压缩"仅含单一子目录"的目录链
      scan_mode = "deep", -- 修复 Z 崩溃：绕过 shallow 懒加载合并分支的上游 bug
      -- `nvim <dir>` 启动时禁用 hijack：hijack 会异步接管目录窗口并覆盖会话恢复的布局
      -- （会话恢复在 VimEnter 完成，由 session.lua 主动开树，行为更确定）
      hijack_netrw_behavior = startup_dir and "disabled" or "open_default",
    },
    window = {
      mappings = {
        Z = "expand_all_subnodes", -- 一键递归展开光标节点下全部
      },
    },
  },
  keys = {
    {
      "<leader>fe",
      function()
        local dir = LazyVim.root()
        require("neo-tree.command").execute({ toggle = true, dir = dir, reveal_file = smart_reveal(dir) })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        local dir = vim.fn.getcwd()
        require("neo-tree.command").execute({ toggle = true, dir = dir, reveal_file = smart_reveal(dir) })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
  },
}