-- neo-tree 插件配置
-- 替代 NERDTree

local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- 主命令
map('n', '<leader>1', ':Neotree toggle<CR>', opts)
