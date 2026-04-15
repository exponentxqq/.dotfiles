-- 自定义命令配置

local cmd = vim.api.nvim_create_user_command

--============================================================
-- 配置管理
-- ReloadConfig 仅在 init.lua 中定义，避免此处覆盖为不完整重载
--============================================================

--============================================================
-- 文件操作
--============================================================

-- 保存所有文件
cmd('W', function()
    vim.cmd('wall')
end, {})

-- 退出所有
cmd('Q', function()
    vim.cmd('qa')
end, {})

--============================================================
-- 搜索和替换
--============================================================

-- 全局搜索（使用 telescope）
cmd('Grep', function(args)
    vim.cmd('Telescope live_grep')
end, {})

--============================================================
-- 查看和操作寄存器
--============================================================

-- 查看寄存器（勿用 :Registers 递归调用自身；内置为 :registers）
cmd('Registers', function()
    vim.cmd('registers')
end, {})

--============================================================
-- 格式化相关
--============================================================

-- 格式化当前文件（供 BufWritePre / <leader>f；勿再 vim.cmd('Format') 自递归）
cmd('Format', function()
    if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0 })) then
        return
    end
    pcall(vim.lsp.buf.format, { async = true, bufnr = 0 })
end, {})

--============================================================
-- Treesitter：不定义 :TSUpdate，保留 nvim-treesitter 内置命令
--============================================================

--============================================================
-- 辅助功能
--============================================================

-- 显示当前文件信息
cmd('Fileinfo', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.bo.filetype
    local lines = vim.api.nvim_buf_line_count(bufnr)
    print(string.format('File: %s\nType: %s\nLines: %d', bufname, filetype, lines))
end, {})
