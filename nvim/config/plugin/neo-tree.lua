-- neo-tree 插件配置
-- 替代 NERDTree

local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- 主命令
map('n', '<leader>1', ':Neotree toggle<CR>', opts)

-- 自动动作
vim.api.nvim_create_autocmd('BufEnter', {
    group = vim.api.nvim_create_augroup('neo-tree-autocmd', { clear = true }),
    callback = function()
        -- 只有 neo-tree 窗口时退出 Neovim
        if vim.bo.filetype == 'neo-tree' and vim.fn.winnr('$') == 1 then
            vim.cmd('quit')
        end
    end,
})
