-- JSON 系列格式化：conform 使用 prettier（lang.json extra 不配置 formatter）
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.json = { "prettier" }
    opts.formatters_by_ft.jsonc = { "prettier" }
    opts.formatters_by_ft.json5 = { "prettier" }
  end,
}
