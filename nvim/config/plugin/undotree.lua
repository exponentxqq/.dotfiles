-- undotree 插件配置
-- 查看历史操作（相当于 jetbrains 的 local history）

local opts = { noremap = true, silent = true }
local map = vim.keymap.set

-- 切换 undotree
map('n', '<leader>u', ':UndotreeToggle<CR>', opts)

-- 自动聚焦到 undotree
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'undotree',
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
        vim.wo.cursorline = true
    end,
})
