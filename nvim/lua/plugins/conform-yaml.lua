-- YAML 格式化：覆盖 prettier，在输出后修复 {{ → { { 的错误规则。
-- Prettier 的 YAML parser 把 Go template {{ 当作 flow mapping 并插入空格。
-- 四条 sed 规则精确撤销此转换，不影响合法 YAML flow syntax。

local fix_cmd = [[prettier --parser yaml --stdin-filepath "$1" 2>/dev/null | sed]]
  .. [[ -e 's/{ { /{{ /g']]
  .. [[ -e 's/ } }/ }}/g']]
  .. [[ -e 's/{{ -/{{-/g']]
  .. [[ -e 's/- }}/-}}/g']]

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- 从 YAML 移除原生 prettier
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.yaml = vim.tbl_filter(function(f)
      return f ~= "prettier"
    end, opts.formatters_by_ft.yaml or {})

    -- 注册修复版 prettier
    opts.formatters = opts.formatters or {}
    opts.formatters.prettier_yaml_fix = {
      command = "sh",
      args = { "-c", fix_cmd, "sh", "$FILENAME" },
      stdin = true,
    }

    -- 替换 YAML formatter 链
    opts.formatters_by_ft.yaml = vim.list_extend({ "prettier_yaml_fix" }, opts.formatters_by_ft.yaml)
  end,
}
