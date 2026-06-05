-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Java: 新建 .java 文件时自动插入 package 声明和类骨架
-- 同时监听 BufNewFile 和 BufWinEnter 以兼容 Explorer 等方式创建文件
local java_types = {
  { label = "class",     body = "public class %s {",       suffix = "}" },
  { label = "interface", body = "public interface %s {",   suffix = "}" },
  { label = "enum",      body = "public enum %s {",        suffix = "}" },
  { label = "record",    body = "public record %s() {",    suffix = "}" },
  { label = "abstract",  body = "public abstract class %s {", suffix = "}" },
  { label = "annotation", body = "public @interface %s {", suffix = "}" },
}

local function java_template(buf)
  -- 跳过非空 buffer（已有内容的不处理）
  if vim.api.nvim_buf_line_count(buf) > 1 or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "" then
    return
  end
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" then
    return
  end
  local file = vim.fn.fnamemodify(filepath, ":t:r")
  local dir = vim.fn.fnamemodify(filepath, ":h")
  local pkg = dir:match("src/main/java/(.+)$")
    or dir:match("src/test/java/(.+)$")
    or dir:match("src/([%w_]+)/java/(.+)$") -- 适配其他 source set（如 integrationTest）
  if pkg then
    pkg = pkg:gsub("/", ".")
  end

  vim.ui.select(java_types, {
    prompt = "选择 Java 类型:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then
      return
    end
    local lines = {}
    if pkg then
      lines[#lines + 1] = "package " .. pkg .. ";"
      lines[#lines + 1] = ""
    end
    lines[#lines + 1] = choice.body:format(file)
    lines[#lines + 1] = "\t"
    lines[#lines + 1] = choice.suffix
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.schedule(function()
      vim.api.nvim_win_set_cursor(0, { #lines - 1, 1 })
      vim.cmd("startinsert!")
    end)
  end)
end

local java_template_group = vim.api.nvim_create_augroup("user_java_template", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
  group = java_template_group,
  pattern = "*.java",
  callback = function(args)
    java_template(args.buf)
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = java_template_group,
  pattern = "*.java",
  callback = function(args)
    vim.schedule(function()
      java_template(args.buf)
    end)
  end,
})

-- Vue: 新建 .vue 文件时自动插入 SFC 模板
local function vue_template(buf)
  if vim.api.nvim_buf_line_count(buf) > 1 or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= "" then
    return
  end
  local filepath = vim.api.nvim_buf_get_name(buf)
  if filepath == "" then
    return
  end
  local lines = {
    "<script setup lang=\"ts\">",
    "</script>",
    "",
    "<template>",
    "  <div>",
    "  </div>",
    "</template>",
    "",
    "<style scoped>",
    "</style>",
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.schedule(function()
    -- 光标放在 <script setup> 标签内部的空行
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.cmd("startinsert!")
  end)
end

local vue_template_group = vim.api.nvim_create_augroup("user_vue_template", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
  group = vue_template_group,
  pattern = "*.vue",
  callback = function(args)
    vue_template(args.buf)
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vue_template_group,
  pattern = "*.vue",
  callback = function(args)
    vim.schedule(function()
      vue_template(args.buf)
    end)
  end,
})
