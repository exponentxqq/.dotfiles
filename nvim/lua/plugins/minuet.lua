-- 行内补全：通过本机 LiteLLM（docker 映射 4000）调用虚拟模型 haiku
-- 若 LiteLLM 启用了 master key，请在 shell 中 export LITELLM_API_KEY=...
-- 参考：~/develop/docker/litellm/config.yaml

return {
  {
    "milanglacier/minuet-ai.nvim",
    opts = {
      provider = "openai_compatible",
      request_timeout = 3,
      throttle = 1500,
      debounce = 600,
      provider_options = {
        openai_compatible = {
          api_key = function()
            return os.getenv("LITELLM_API_KEY") or "litellm"
          end,
          end_point = "http://127.0.0.1:4000/v1/chat/completions",
          model = "haiku",
          name = "LiteLLM",
        },
      },
    },
    config = function(_, opts)
      require("minuet").setup(opts)
      -- LazyVim 仅在启用 Copilot/Codeium/Supermaven 等 extra 时注册 `ai_accept`；
      -- 否则 `<Tab>` 链里没有实际处理函数，幽灵文本无法被接受。
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
        timeout_ms = 3000,
        score_offset = 50,
      }
      if type(opts.sources.default) == "table" and not vim.tbl_contains(opts.sources.default, "minuet") then
        table.insert(opts.sources.default, "minuet")
      end
      opts.keymap = opts.keymap or {}
      opts.keymap["<A-y>"] = require("minuet").make_blink_map()
      opts.completion = opts.completion or {}
      opts.completion.trigger = vim.tbl_deep_extend("force", opts.completion.trigger or {}, {
        prefetch_on_insert = false,
      })
    end,
  },
}
