return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.typescript = { "eslint_d" }
      opts.formatters_by_ft.typescriptreact = { "eslint_d" }
      opts.formatters_by_ft.javascript = { "eslint_d" }
      opts.formatters_by_ft.javascriptreact = { "eslint_d" }
      opts.formatters_by_ft.vue = { "eslint_d" }
    end,
  },
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "eslint_d")
    end,
  },
}
