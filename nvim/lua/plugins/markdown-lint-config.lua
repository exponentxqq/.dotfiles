return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    init = function()
      LazyVim.on_very_lazy(function()
        local ok, lint = pcall(require, "lint")
        if not ok then
          return
        end
        local linter = lint.linters["markdownlint-cli2"]
        if linter then
          linter.args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml"), "-" }
        end
      end)
    end,
  },
}
