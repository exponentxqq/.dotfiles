-- Rust LSP: 使用 Docker 容器中的 rust_analyzer
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          -- 使用 Docker 容器中的 rust_analyzer，替代 Mason 安装的
          cmd = { "/home/xuqinqin/develop/docker/bin/rust-analyzer" },
          -- 不需要 Mason 安装
          mason = false,
        },
      },
    },
  },
  -- 确保 Mason 不安装 rust_analyzer
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        -- 保留其他 LSP，移除 rust_analyzer（改用 Docker）
      },
    },
  },
}
