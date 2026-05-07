-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Java: 新建 .java 文件时自动插入 package 声明和类骨架
vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("user_java_template", { clear = true }),
  pattern = "*.java",
  callback = function(args)
    local file = vim.fn.expand("<afile>:t:r") -- 文件名（不含扩展名）
    local dir = vim.fn.expand("<afile>:h") -- 所在目录
    local pkg = dir:match("src/main/java/(.+)$")
      or dir:match("src/test/java/(.+)$")
      or dir:match("src/([%w_]+)/java/(.+)$") -- 适配其他 source set（如 integrationTest）
    if pkg then
      pkg = pkg:gsub("/", ".")
    end
    local lines = {}
    if pkg then
      lines[#lines + 1] = "package " .. pkg .. ";"
      lines[#lines + 1] = ""
    end
    lines[#lines + 1] = "public class " .. file .. " {"
    lines[#lines + 1] = "\t"
    lines[#lines + 1] = "}"
    vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, { #lines - 1, 1 })
    vim.cmd("startinsert!")
  end,
})
