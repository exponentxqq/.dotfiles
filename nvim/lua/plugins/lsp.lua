-- 取消默认 K = LSP hover，改为 gh；K 留给 keymaps.lua 做 5k
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- marksman 无排除配置，会把 workspace 内全部 md 建索引。opc 有 9248 个 md
      -- （.worktrees ~5600 + node_modules ~2600），每次启动单核满载 60s+ 并占 145MB，
      -- 在内存吃紧时加剧换页。md 渲染（render-markdown）与搜索均不依赖它。
      marksman = { enabled = false },
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
