-- 自定义命令配置

local cmd = vim.api.nvim_create_user_command

--============================================================
-- 配置管理
--============================================================

-- 重新加载配置
cmd('ReloadConfig', function()
   print('配置已重新加载')
   -- 只重新加载插件配置，不重新加载整个 init.lua
   require('lazy').setup(require('plugins'))
end, {})

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

-- 查看寄存器
cmd('Registers', function()
    vim.cmd('Registers')
end, {})

--============================================================
-- 格式化相关
--============================================================

-- 格式化当前文件
cmd('Format', function()
    if vim.fn.exists(':Format') == 2 then
        vim.cmd('Format')
    else
        print('No formatter available')
    end
end, {})

--============================================================
-- Treesitter 相关
--============================================================

-- Treesitter 重载
cmd('TSUpdate', function()
    vim.cmd('TSUpdate')
end, {})

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
