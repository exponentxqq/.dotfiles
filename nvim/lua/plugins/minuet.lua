return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        -- 默认使用 DeepSeek (FIM 补全，质量更好)
        provider = "openai_fim_compatible",
        provider_options = {
          openai_fim_compatible = {
            api_key = "DEEPSEEK_API_KEY",
            name = "DeepSeek",
            model = "deepseek-v4-flash",
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
          -- 备选: 智谱 z.ai
          openai_compatible = {
            end_point = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
            api_key = "GLM_API_KEY",
            name = "z.ai",
            model = "glm-4-flash",
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
        },
        throttle = 1000,
        debounce = 400,
        context_window = 64000,
        virtualtext = {
          auto_trigger_ft = { "*" },
          keymap = {
            accept = "<Tab>",
            accept_line = "<M-l>",
            accept_n_lines = "<M-z>",
            dismiss = "<M-e>",
            next = "<M-]>",
            prev = "<M-[>",
          },
        },
      })
    end,
  },
}
