-- telescope 插件配置
-- 替代 fzf

local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- 文件查找
map('n', '<leader>ff', ':Telescope find_files<CR>', opts)

-- 全文搜索
map('n', '<leader>fg', ':Telescope live_grep<CR>', opts)

-- 缓冲区查找
map('n', '<leader>fb', ':Telescope buffers<CR>', opts)

-- 历史文件
map('n', '<leader>fh', ':Telescope oldfiles<CR>', opts)

-- 命令历史
map('n', '<leader>cm', ':Telescope commands<CR>', opts)

-- 快捷键映射
map('n', '<leader>/', ':Telescope current_buffer_fuzzy_find<CR>', opts)

-- 搜索 git 文件
map('n', '<leader>gf', ':Telescope git_files<CR>', opts)

-- 查找符号
map('n', '<leader>fs', ':Telescope current_buffer_fuzzy_find<CR>', opts)

-- 选中文本搜索
map('v', '<leader>fs', ':<C-u>Telescope current_buffer_fuzzy_find<CR>', opts)
