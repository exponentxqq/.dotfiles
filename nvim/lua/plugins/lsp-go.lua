-- Go LSP: 使用 Docker 容器中的 gopls
-- 参考: lsp-rust.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          -- 使用 Docker 容器中的 gopls，替代 Mason 安装的
          cmd = { "gopls" },
          -- 不需要 Mason 安装
          mason = false,
          -- settings (gofumpt / codelens / hints / analyses) 由 LazyVim Go extra 提供
        },
      },
      -- 覆盖 Go extra 中的 setup.gopls：添加 nil 保护
      -- 修复: attempt to index local 'semantic' (a nil value)
      setup = {
        gopls = function(_, opts)
          local Snacks = require("snacks")
          Snacks.util.lsp.on({ name = "gopls" }, function(_, client)
            if client.server_capabilities.semanticTokensProvider then
              return
            end
            local caps = client.config.capabilities or {}
            local textDocument = caps.textDocument or {}
            local semantic = textDocument.semanticTokens
            if not semantic then
              return
            end
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              legend = {
                tokenTypes = semantic.tokenTypes or {},
                tokenModifiers = semantic.tokenModifiers or {},
              },
              range = true,
            }
          end)
        end,
      },
    },
  },
  -- 禁用 Go linting：golangci-lint 暂无 Docker wrapper
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        go = {},
      },
    },
  },
  -- 禁用 Go DAP：delve 暂无 Docker wrapper
  {
    "leoluz/nvim-dap-go",
    enabled = false,
  },
  -- 排除 Mason 中的 Go 工具，保持与容器内 Go 工具链版本一致
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local skip = {
        "goimports",
        "gofumpt",
        "gomodifytags",
        "impl",
        "golangci-lint",
        "delve",
      }
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return not vim.tbl_contains(skip, tool)
      end, opts.ensure_installed or {})
    end,
  },
}
