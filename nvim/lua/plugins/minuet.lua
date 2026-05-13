-- 行内补全：直连 DeepSeek API

return {
  {
    "milanglacier/minuet-ai.nvim",
    opts = {
      provider = "openai_compatible",
      request_timeout = 5,
      throttle = 1500,
      debounce = 600,
      provider_options = {
        openai_compatible = {
          api_key = function()
            return os.getenv("DEEPSEEK_API_KEY")
          end,
          end_point = "https://api.deepseek.com/v1/chat/completions",
          model = "deepseek-chat",
          name = "DeepSeek",
        },
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)
      vim.api.nvim_create_autocmd("InsertEnter", {
        once = true,
        callback = function()
          vim.keymap.set("i", "<M-y>", function()
            require("blink.cmp").show()
          end, { desc = "Minuet Complete" })
        end,
      })
      LazyVim.cmp.actions.ai_accept = function()
        local ok, blink = pcall(require, "blink.cmp")
        if not ok or not blink.is_visible() then
          return
        end
        LazyVim.create_undo()
        blink.select_and_accept()
        return true
      end
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "milanglacier/minuet-ai.nvim" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.minuet = {
        name = "minuet",
        module = "minuet.blink",
        async = true,
        timeout_ms = 8000,
        score_offset = 50,
      }
      if type(opts.sources.default) == "table" and not vim.tbl_contains(opts.sources.default, "minuet") then
        table.insert(opts.sources.default, "minuet")
      end
      opts.completion = opts.completion or {}
      opts.completion.trigger = vim.tbl_deep_extend("force", opts.completion.trigger or {}, {
        prefetch_on_insert = false,
      })
    end,
  },
}
