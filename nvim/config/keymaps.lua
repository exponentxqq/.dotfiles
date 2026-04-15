-- 键位映射配置
-- 同步自 Vim 配置，并适配 Neovim 插件

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

--============================================================
-- 通用映射
--============================================================

-- leader 键已在 init.lua 中设置为空格

-- Escape 在插入模式下
map('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- 保存和退出
map('n', '<leader>w', '<Esc>:w<CR>', opts)
map('n', '<leader>q', '<Esc>:q<CR>', opts)
map('n', '<leader>x', '<Esc>:x<CR>', opts)
map('n', '<leader>W', '<Esc>:w!<CR>', opts)
map('n', '<leader>Q', '<Esc>:q!<CR>', opts)
map('n', '<leader>X', '<Esc>:x!<CR>', opts)

--============================================================
-- 缓冲区操作
--============================================================

-- 直接切换到指定缓冲区
map('n', '<leader>b1', ':1b<CR>', opts)
map('n', '<leader>b2', ':2b<CR>', opts)
map('n', '<leader>b3', ':3b<CR>', opts)
map('n', '<leader>b4', ':4b<CR>', opts)
map('n', '<leader>b5', ':5b<CR>', opts)
map('n', '<leader>b6', ':6b<CR>', opts)

-- 缓冲区列表
map('n', '<leader>bs', ':buffers<CR>', opts)

-- 删除当前缓冲区
map('n', '<leader>bc', ':bdelete<CR>', opts)

-- 上一个/下一个缓冲区
map('n', '<leader>bn', ':bnext<CR>', opts)
map('n', '<leader>bp', ':bprev<CR>', opts)
map('n', '<leader>bb', ':bfirst<CR>', opts)
map('n', '<leader>bl', ':blast<CR>', opts)

--============================================================
-- 视觉模式
--============================================================

-- 复制到系统剪贴板
map('v', '<C-c>', '"+y', opts)
map('v', '<leader>y', '"+y', opts)

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

-- 分屏创建
map('n', '<leader>wl', ':set splitright<CR>:vsplit<CR>', opts)
map('n', '<leader>wh', ':set nosplitright<CR>:vsplit<CR>', opts)
map('n', '<leader>wk', ':set nosplitbelow<CR>:split<CR>', opts)
map('n', '<leader>wj', ':set splitbelow<CR>:split<CR>', opts)
map('n', '<leader>wn', ':vnew<CR>', opts)

-- 调整窗口大小
map('n', '<S-up>', ':res +1<CR>', opts)
map('n', '<S-down>', ':res -1<CR>', opts)
map('n', '<S-left>', ':vertical resize-1<CR>', opts)
map('n', '<S-right>', ':vertical resize+1<CR>', opts)

--============================================================
-- 缩进操作
--============================================================

-- Tab 键缩进
map('n', '<Tab>', 'V>', opts)
map('n', '<S-Tab>', 'V<', opts)
map('v', '<Tab>', '>gv', opts)
map('v', '<S-Tab>', '<gv', opts)

--============================================================
-- Tab 操作
--============================================================

map('n', 'te', ':tabnew<CR>', opts)
map('n', 'tp', ':tabprev<CR>', opts)
map('n', 'tn', ':tabnext<CR>', opts)
map('n', 'tc', ':tabclose<CR>', opts)
map('n', 'to', ':tabonly<CR>', opts)

--============================================================
-- 移动键优化
--============================================================

-- J/K 移动更长距离
map('n', 'J', '5j', opts)
map('n', 'K', '5k', opts)
map('n', 'H', '^', opts)
map('n', 'L', '$', opts)
map('v', 'J', '5j', opts)
map('v', 'K', '5k', opts)
map('v', 'H', '^', opts)
map('v', 'L', '$', opts)

-- 移动行
map('n', '<leader>j', ':<C-u>execute \'move +\'. v:count1<CR>', opts)
map('n', '<leader>k', ':<C-u>execute \'move -1-\'. v:count1<CR>', opts)

--============================================================
-- 编辑功能
--============================================================

-- 回车键添加新行
map('n', '<CR>', 'o<Esc>', opts)
map('n', '<C-CR>', 'O<Esc>', opts)

-- 撤销 Ctrl-R
map('n', 'U', '<C-r>', opts)

-- 插入模式快捷键
map('i', '<C-d>', '<Esc>yyp', opts)
map('i', ';ge', '<Esc>A', opts)
map('i', ';o', '<Esc>o', opts)

--============================================================
-- 代码折叠
--============================================================

map('n', '+', 'za', opts)

--============================================================
-- 搜索高亮管理
--============================================================

map('n', '<leader><space>', ':set hlsearch! hlsearch?<CR>', opts)
map('n', '<leader><leader>', ':nohl<CR>', opts)

--============================================================
-- 其他快捷键
--============================================================

-- 终端
map('n', '<leader>t', ':terminal<CR>', opts)

-- 格式化
map('n', '<leader>f', ':Format<CR>', opts)

-- 强制走 LSP 的跳转（不依赖 gd 是否被抢键）
map('n', '<leader>gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'LSP 跳转定义' }))

-- gd：VeryLazy 后再盖一层全局映射；无 LSP 时只提示，绝不走 :tag（避免 E433/E426）
vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    once = true,
    callback = function()
        vim.keymap.set('n', 'gd', function()
            local bufnr = vim.api.nvim_get_current_buf()
            if next(vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/definition' })) then
                vim.lsp.buf.definition()
            else
                vim.notify(
                    '当前缓冲区无 LSP（textDocument/definition）。Java 请 :LspInfo 确认 jdtls；或先用 <leader>gd。',
                    vim.log.levels.WARN
                )
            end
        end, vim.tbl_extend('force', opts, { desc = '跳转定义（仅 LSP）' }))
        -- 再延后一次，压过在 VeryLazy 里注册 gd 的插件
        vim.defer_fn(function()
            vim.keymap.set('n', 'gd', function()
                local bufnr = vim.api.nvim_get_current_buf()
                if next(vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/definition' })) then
                    vim.lsp.buf.definition()
                else
                    vim.notify(
                        '当前缓冲区无 LSP（textDocument/definition）。Java 请 :LspInfo 确认 jdtls；或先用 <leader>gd。',
                        vim.log.levels.WARN
                    )
                end
            end, vim.tbl_extend('force', opts, { desc = '跳转定义（仅 LSP）' }))
        end, 100)
    end,
})
