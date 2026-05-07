-- 微信小程序语法支持
-- .wxml → HTML 解析器 + html-lsp
-- .wxss → CSS 解析器 + cssls
-- .wxs  → JavaScript 解析器（已由 ts/js LSP 处理）
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.filetype.add({
        extension = {
          wxml = "wxml",
          wxss = "wxss",
          wxs = "wxs",
        },
      })
      vim.treesitter.language.register("html", "wxml")
      vim.treesitter.language.register("css", "wxss")
      vim.treesitter.language.register("javascript", "wxs")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {
          filetypes = { "html", "wxml" },
        },
        cssls = {
          filetypes = { "css", "scss", "less", "wxss" },
        },
      },
    },
  },
}
