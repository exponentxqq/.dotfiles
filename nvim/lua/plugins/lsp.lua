-- 取消默认 K = LSP hover，改为 gh；K 留给 keymaps.lua 做 5k
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "K", false },
          {
            "gh",
            function()
              return vim.lsp.buf.hover()
            end,
            desc = "Hover",
          },
        },
      },
    },
  },
}
