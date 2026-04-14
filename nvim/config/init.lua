-- Neovim 配置文件
-- 相关文档: https://neovim.io/doc/

--============================================================
-- 基础设置
--============================================================

-- 设置 leader 键为空格
vim.g.mapleader = ' '

-- 启用 true color 支持
if vim.fn.has('termguicolors') == 1 then
    vim.opt.termguicolors = true
end

-- 编码设置
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'
vim.o.fileencodings = 'utf-8,gb18030,gbk,gb2312'

--============================================================
-- 界面设置
--============================================================

-- 行号
vim.opt.number = true
vim.opt.relativenumber = true

-- 状态栏
vim.opt.laststatus = 3

-- 光标行高亮
vim.opt.cursorline = true

-- 显示命令
vim.opt.showcmd = true

-- 鼠标支持
vim.opt.mouse = 'a'

-- 剪贴板
vim.opt.clipboard = 'unnamedplus'

-- 缩进
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true

-- 括号匹配
vim.opt.showmatch = true
vim.opt.matchtime = 2

-- 搜索
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- 折叠
vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 99

--============================================================
-- 文件和备份设置
--============================================================

-- 禁用 swapfile
vim.opt.swapfile = false

-- 禁用 backup
vim.opt.backup = false

-- 禁用 writebackup
vim.opt.writebackup = false

-- undodir 设置
vim.opt.undodir = vim.env.HOME .. '/.cache/nvim/undo'
vim.opt.undofile = true

--============================================================
-- 自动命令
--============================================================

-- 格式化后自动保存
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = { '*.lua', '*.js', '*.ts', '*.python', '*.go', '*.rs' },
    callback = function()
        vim.cmd('silent! format')
    end,
})

-- 进入终端模式自动进入插入模式
vim.api.nvim_create_autocmd('TermOpen', {
    pattern = '*',
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.wo.scrollside = 'right'
    end,
})

--============================================================
-- 命令别名
--============================================================

-- 重新加载配置
vim.api.nvim_create_user_command('ReloadConfig', function()
    dofile(vim.env.VIMINIT or vim.env.NVIM_INIT or vim.env.HOME .. '/.config/nvim/init.lua')
end, {})

--============================================================
-- 加载配置文件
--============================================================

-- 加载键位映射
dofile(vim.env.HOME .. '/.config/nvim/keymaps.lua')

-- 加载自定义命令
dofile(vim.env.HOME .. '/.config/nvim/commands.lua')

--============================================================
-- 启动 lazy.nvim
--============================================================

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

-- 加载插件配置
require('lazy').setup(require('plugins'))
