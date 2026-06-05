return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        unocss = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "unocss-language-server")
    end,
  },
}
