-- 键位映射配置
-- 基础映射

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

--============================================================
-- 通用映射
--============================================================

-- leader 键已在 init.lua 中设置为空格

-- Escape 在插入模式下
map('i', 'jj', '<Esc>', { noremap = true, silent = true })

-- 保存和退出
map('n', '<leader>w', ':w<CR>', opts)
map('n', '<leader>q', ':q<CR>', opts)
map('n', '<leader>Q', ':qa<CR>', opts)

-- 缓冲区导航
map('n', '<leader>bn', ':bn<CR>', opts)
map('n', '<leader>bp', ':bp<CR>', opts)
map('n', '<leader>bd', ':bd<CR>', opts)

-- 上一个/下一个缓冲区
map('n', '<C-l>', ':bnext<CR>', opts)
map('n', '<C-h>', ':bprevious<CR>', opts)

--============================================================
-- 视觉模式
--============================================================

-- 复制到系统剪贴板
map('v', '<C-c>', '"+y', opts)

-- 剪切到系统剪贴板
map('v', '<C-x>', '"+d', opts)

-- 粘贴从系统剪贴板
map('v', '<C-p>', '"+p', opts)

--============================================================
-- 窗口导航
--============================================================

-- 使用 <C-h/j/k/l> 导航窗口
map('n', '<C-h>', '<C-w>h', opts)
map('n', '<C-j>', '<C-w>j', opts)
map('n', '<C-k>', '<C-w>k', opts)
map('n', '<C-l>', '<C-w>l', opts)

-- 调整窗口大小
map('n', '<C-Left>', '<C-w><', opts)
map('n', '<C-Right>', '<C-w>>', opts)
map('n', '<C-Up>', '<C-w>+', opts)
map('n', '<C-Down>', '<C-w>-', opts)

--============================================================
-- 插件快捷键
--============================================================

-- NERDTree (neo-tree)
map('n', '<leader>1', ':Neotree toggle<CR>', opts)

-- Telescope
map('n', '<leader>ff', ':Telescope find_files<CR>', opts)
map('n', '<leader>fg', ':Telescope live_grep<CR>', opts)
map('n', '<leader>fb', ':Telescope buffers<CR>', opts)
map('n', '<leader>fh', ':Telescope oldfiles<CR>', opts)

-- Undotree
map('n', '<leader>u', ':UndotreeToggle<CR>', opts)

--============================================================
-- 格式化
--============================================================

map('n', '<leader>f', ':Format<CR>', opts)
