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

-- 编码设置（用 scope=global，避免在 nomodifiable 缓冲区里 :ReloadConfig 时 vim.o.fileencoding 触发 E21）
vim.api.nvim_set_option_value('encoding', 'utf-8', {})
vim.api.nvim_set_option_value('fileencoding', 'utf-8', { scope = 'global' })
vim.api.nvim_set_option_value('fileencodings', 'utf-8,gb18030,gbk,gb2312', {})

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

-- 保存时格式化由 conform.nvim 的 format_on_save 处理（见 lua/plugins.lua）

-- Java：绑定 gd / <C-LeftMouse> / <C-]>，完全绕开 tagfunc/tag 路径（E433/E426 根源）。
-- 用原始 client:request，不经过 vim.lsp.buf.definition() 的 settagstack 分支。
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    group = vim.api.nvim_create_augroup('java-lsp-nav', { clear = true }),
    callback = function(ev)
        local buf = ev.buf
        -- 安全 tagfunc：返回 {} 而非 vim.NIL，防止剩余 tag 路径触发 E433
        vim.bo[buf].tagfunc = "v:lua.require('java_tagfunc').tagfunc"

        -- 共用的 LSP 定义跳转（不经过任何 tag 代码）
        local function lsp_definition()
            local bufnr = vim.api.nvim_get_current_buf()
            local win = vim.api.nvim_get_current_win()
            local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/definition' })
            if #clients == 0 then
                vim.notify('jdtls 尚未附着，:checkhealth lsp 查看状态', vim.log.levels.WARN)
                return
            end
            local client = clients[1]
            local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
            vim.lsp.buf_request(bufnr, 'textDocument/definition', params, function(err, result, ctx)
                if err then
                    vim.notify('LSP 定义查询失败: ' .. vim.inspect(err), vim.log.levels.ERROR)
                    return
                end
                if not result or (type(result) == 'table' and vim.tbl_isempty(result)) then
                    vim.notify('未找到定义（jdtls 可能仍在索引，稍候重试）', vim.log.levels.WARN)
                    return
                end
                local loc = result[1] or result
                local c = vim.lsp.get_client_by_id(ctx and ctx.client_id) or client
                local ok, jump_err = pcall(vim.lsp.util.jump_to_location, loc, c.offset_encoding)
                if not ok then
                    vim.notify('跳转失败: ' .. tostring(jump_err), vim.log.levels.ERROR)
                end
            end)
        end

        local map_opts = { buffer = buf, noremap = true, silent = false }
        vim.keymap.set('n', 'gd', lsp_definition, vim.tbl_extend('force', map_opts, { desc = 'LSP 定义（Java）' }))
        -- Ctrl+Click：先移光标到鼠标位置，再走 LSP（绕开默认的 <C-]>/tagfunc 路径）
        vim.keymap.set('n', '<C-LeftMouse>', function()
            local pos = vim.fn.getmousepos()
            if pos.winid ~= 0 then
                vim.api.nvim_set_current_win(pos.winid)
                local col = math.max(0, pos.column - 1)
                local ok = pcall(vim.api.nvim_win_set_cursor, pos.winid, { pos.line, col })
                if not ok then return end
            end
            lsp_definition()
        end, vim.tbl_extend('force', map_opts, { silent = true, desc = 'LSP 定义（鼠标）' }))
        -- <C-]>：同样劫持，避免 tag 路径
        vim.keymap.set('n', '<C-]>', lsp_definition, vim.tbl_extend('force', map_opts, { silent = true, desc = 'LSP 定义（C-]）' }))

        vim.keymap.set('n', 'gK', vim.lsp.buf.hover,
            vim.tbl_extend('force', map_opts, { silent = true, desc = 'LSP 文档（Java）' }))
    end,
})

-- 终端缓冲区：关闭行号（无标准选项 scrollside，已移除无效赋值）
vim.api.nvim_create_autocmd('TermOpen', {
    pattern = '*',
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
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
