-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local nx = { "n", "x" } -- x = 可视模式（不含 Select）

-- K = 5k；LSP hover 见 lua/plugins/lsp.lua（gh）
-- J/H/L 仍覆盖默认（5j、行首、行尾）
map(nx, "K", "5k", { desc = "上移 5 行" })
map(nx, "J", "5j", { desc = "下移 5 行" })
map(nx, "H", "0", { desc = "行首" })
map(nx, "L", "$", { desc = "行尾" })
map("i", "jk", "<Esc>", { desc = "退出插入模式" })
