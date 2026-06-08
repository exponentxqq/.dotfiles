-- SQL 列定义垂直对齐（基于 treesitter）
-- <leader>ca : 对齐光标所在的 CREATE TABLE
-- <leader>cf : conform 格式化 + 自动对齐（SQL 文件专用）
-- 保存时自动：conform 格式化 → 对齐

local M = {}

--- 将 token 列表按语义分成固定组
local function parse_groups(segments)
  local groups = {
    name = "",
    type = "",
    not_null = "",
    auto_inc = "",
    default_val = "",
    comment_val = "",
  }
  local i = 1

  groups.name = segments[i]; i = i + 1

  if segments[i] then
    groups.type = segments[i]; i = i + 1
    if segments[i] and segments[i]:lower() == "unsigned" then
      groups.type = groups.type .. " " .. segments[i]; i = i + 1
    end
  end

  while i <= #segments do
    local s = segments[i]:lower()
    if s == "not" and segments[i + 1] and segments[i + 1]:lower() == "null" then
      groups.not_null = "not null"; i = i + 2
    elseif s == "default" then
      groups.default_val = "default " .. (segments[i + 1] or ""); i = i + 2
    elseif s == "auto_increment" then
      groups.auto_inc = "auto_increment"; i = i + 1
    elseif s == "comment" then
      -- comment 值可能包含空格（如 '任务状态，参见 enum TaskStatus'）
      -- 需要收集从引号开始到引号结束的所有 segments
      local parts = {}
      local j = i + 1
      while j <= #segments do
        parts[#parts + 1] = segments[j]
        -- 遇到闭合引号则停止
        if segments[j]:match("'$") then
          break
        end
        j = j + 1
      end
      groups.comment_val = "comment " .. table.concat(parts, " ")
      i = j + 1
    elseif s == "on" and segments[i + 1] and segments[i + 1]:lower() == "update" then
      groups.default_val = groups.default_val .. " on update " .. (segments[i + 2] or ""); i = i + 3
    else
      i = i + 1
    end
  end

  return groups
end

local function pad_right(text, width)
  if width <= 0 then
    return text
  end
  return text .. string.rep(" ", width - vim.fn.strdisplaywidth(text))
end

--- 对单个 column_definitions 节点执行对齐
local function align_col_defs(buf, col_defs_node)
  local columns = {}
  for child in col_defs_node:iter_children() do
    if child:type() == "column_definition" then
      local s_row = child:start()
      local line = vim.api.nvim_buf_get_lines(buf, s_row, s_row + 1, false)[1] or ""
      line = line:gsub(",%s*$", "")
      local indent = line:match("^(%s+)") or ""
      local rest = line:sub(#indent + 1)
      local segments = {}
      for seg in rest:gmatch("(%S+)") do
        segments[#segments + 1] = seg
      end
      columns[#columns + 1] = {
        row = s_row,
        indent = indent,
        groups = parse_groups(segments),
      }
    end
  end

  if #columns == 0 then
    return
  end

  local fixed_keys = { "name", "type", "not_null", "auto_inc" }
  local widths = {}
  for _, k in ipairs(fixed_keys) do
    widths[k] = 0
    for _, col in ipairs(columns) do
      local w = vim.fn.strdisplaywidth(col.groups[k])
      if w > widths[k] then
        widths[k] = w
      end
    end
  end

  -- 检查是否有 constraints 节点（PRIMARY KEY 等）
  -- 如果有，所有列定义都需要逗号；否则最后一个不加逗号
  local has_constraints = false
  for child in col_defs_node:iter_children() do
    if child:type() == "constraints" then
      has_constraints = true
      break
    end
  end

  local new_lines = {}
  for idx, col in ipairs(columns) do
    local g = col.groups
    local line = col.indent

    line = line .. pad_right(g.name, widths.name + 1)
    line = line .. pad_right(g.type, widths.type + 1)
    if g.not_null ~= "" then
      line = line .. pad_right(g.not_null, widths.not_null + 1)
    end
    if g.auto_inc ~= "" then
      line = line .. pad_right(g.auto_inc, widths.auto_inc + 1)
    end
    if g.default_val ~= "" then
      line = line .. g.default_val .. " "
    end
    if g.comment_val ~= "" then
      line = line .. g.comment_val
    end

    line = line:gsub("%s+$", "")
    -- 如果有约束节点，所有列定义都加逗号；否则最后一个不加
    if has_constraints or idx < #columns then
      line = line .. ","
    end

    new_lines[#new_lines + 1] = line
  end

  local start_row = columns[1].row
  local end_row = columns[#columns].row
  vim.api.nvim_buf_set_lines(buf, start_row, end_row + 1, false, new_lines)
end

--- 对齐 constraints 中的索引定义（统一缩进为两个空格）
local function align_constraints(buf, constraints_node)
  local indent = "  "  -- 索引定义也用两个空格缩进
  for child in constraints_node:iter_children() do
    local s_row = child:start()
    local line = vim.api.nvim_buf_get_lines(buf, s_row, s_row + 1, false)[1] or ""
    local rest = line:match("^%s*(.+)") or ""
    local new_line = indent .. rest
    vim.api.nvim_buf_set_lines(buf, s_row, s_row + 1, false, { new_line })
  end
end

--- 对齐所有 CREATE TABLE（cursor_only=true 只处理光标所在表）
function M.align(cursor_only)
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  if ft ~= "sql" then
    return
  end

  local parser_ok, parser = pcall(vim.treesitter.get_parser, buf, "sql")
  if not parser_ok then
    return
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1

  local found = false
  for node in root:iter_children() do
    if node:type() == "statement" then
      for child in node:iter_children() do
        if child:type() == "create_table" then
          if cursor_only then
            local s_row, _, e_row, _ = child:range()
            if cursor_row >= s_row and cursor_row <= e_row then
              for cc in child:iter_children() do
                if cc:type() == "column_definitions" then
                  align_col_defs(buf, cc)
                  found = true
                elseif cc:type() == "constraints" then
                  align_constraints(buf, cc)
                end
              end
              break
            end
          else
            for cc in child:iter_children() do
              if cc:type() == "column_definitions" then
                align_col_defs(buf, cc)
                found = true
              elseif cc:type() == "constraints" then
                align_constraints(buf, cc)
              end
            end
          end
        end
      end
    end
  end

  if cursor_only and not found then
    vim.notify("光标不在 CREATE TABLE 语句内", vim.log.levels.WARN)
  end
end

-- 暴露到全局
_G.sql_align = M

-- 注册命令
vim.api.nvim_create_user_command("SqlAlign", function()
  M.align(true)
end, { desc = "对齐 SQL 列定义（光标所在表）" })

vim.api.nvim_create_user_command("SqlAlignAll", function()
  M.align(false)
end, { desc = "对齐 SQL 列定义（所有表）" })

-- SQL 文件专用快捷键和自动对齐
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sql",
  group = vim.api.nvim_create_augroup("sql_align_ft", { clear = true }),
  callback = function(args)
    local buf = args.buf

    -- <leader>ca: 手动对齐光标所在表
    vim.keymap.set("n", "<leader>ca", function()
      M.align(true)
    end, { buffer = buf, desc = "对齐 SQL 列定义" })

    -- <leader>cf: conform 格式化后自动对齐
    vim.keymap.set("n", "<leader>cf", function()
      require("conform").format({ async = true, bufnr = buf }, function()
        M.align(false)
      end)
    end, { buffer = buf, desc = "格式化 SQL（格式化 + 对齐）" })
  end,
})

-- 保存后自动对齐（conform 格式化在 BufWritePre 已执行）
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.sql",
  group = vim.api.nvim_create_augroup("sql_align_save", { clear = true }),
  callback = function(args)
    M.align(false)
    if vim.bo[args.buf].modified then
      vim.cmd("noautocmd write")
    end
  end,
})

return {}
