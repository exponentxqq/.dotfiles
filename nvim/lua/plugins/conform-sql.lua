return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- 第一步：sqlfluff 基础格式化；第二步由 sql-align（BufWritePost / <leader>cf）做列对齐
      opts.formatters_by_ft.sql = { "sqlfluff" }

      opts.formatters = opts.formatters or {}
      opts.formatters.sqlfluff = {
        command = vim.fn.stdpath("data") .. "/mason/bin/sqlfluff",
        args = { "format", "--dialect=mysql", "--ignore", "parsing,templating", "-" },
        cwd = function(ctx)
          return vim.fn.fnamemodify(ctx.filename, ":h")
        end,
        exit_codes = { 0, 1 },
      }
    end,
  },
}
