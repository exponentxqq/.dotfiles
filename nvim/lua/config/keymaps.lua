-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local nx = { "n", "x" } -- x = 可视模式（不含 Select）

-- K = 5k；LSP hover 见 lua/plugins/lsp.lua（gh）
-- J/H/L 仍覆盖默认（5j、行首、行尾）
map(nx, "K", "5k", { desc = "上移 5 行" })
map(nx, "J", "5j", { desc = "下移 5 行" })
map(nx, "H", "^", { desc = "行首" })
map(nx, "L", "$", { desc = "行尾" })
map("i", "jk", "<Esc>l", { desc = "退出插入模式" })

local function smart_bs_fallback()
  local ok, mp = pcall(require, "mini.pairs")
  if ok then
    return mp.bs()
  end -- 已由 mini.pairs 预转义
  return vim.api.nvim_replace_termcodes("<BS>", true, true, true)
end

local function smart_bs()
  local pos = vim.api.nvim_win_get_cursor(0)
  local col = pos[2]
  if col == 0 then
    return smart_bs_fallback()
  end
  local before = vim.api.nvim_get_current_line():sub(1, col)
  local stripped = before:gsub("%s+$", "")
  if #stripped == #before then
    return smart_bs_fallback()
  end
  return vim.api.nvim_replace_termcodes(("<BS>"):rep(#before - #stripped), true, true, true)
end

map("i", "<BS>", smart_bs, { expr = true, replace_keycodes = false, silent = true, desc = "智能退格" })

-- flash.nvim: Treesitter 增量选择
-- <C-k> 扩大选择，<C-j> 缩小选择
map({ "n", "o", "x" }, "<C-k>", function()
  require("flash").treesitter({
    actions = {
      ["<C-k>"] = "next",
      ["<C-j>"] = "prev",
    },
  })
end, { desc = "Treesitter 增量选择 (扩大)" })
