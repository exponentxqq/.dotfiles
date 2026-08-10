return {
  {
    "mistweaverco/kulala.nvim",
    -- 仅打开 .http / .rest 文件时懒加载
    ft = { "http", "rest" },
    opts = {
      -- 默认环境（对应 http-client.env.json 里的 key）
      default_env = "dev",
      -- 响应体美化
      response_format = { indent = 2, sort_keys = false },
      ui = {
        display_mode = "split",      -- split 模式
        split_direction = "right",   -- 右侧分屏
        default_view = "body",
        winbar = true,
        show_icons = "on_request",
      },
      -- 启用 kulala 全套默认键位，前缀 <leader>R
      global_keymaps = true,
      global_keymaps_prefix = "<leader>R",
    },
    keys = {
      { "<leader>Rs", desc = "Kulala: 发送当前请求" },
      { "<leader>Ra", desc = "Kulala: 发送所有请求" },
      { "<leader>Rr", desc = "Kulala: 重放上次请求" },
      { "<leader>Rb", desc = "Kulala: 打开 scratchpad" },
      { "<leader>Rc", desc = "Kulala: 复制为 curl" },
      { "<leader>RC", desc = "Kulala: 从 curl 转为 .http" },
    },
  },
}
