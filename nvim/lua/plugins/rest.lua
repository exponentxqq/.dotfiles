-- REST 客户端（替代 kulala.nvim —— 其后端二进制下载源已失效）
-- 遵循 JetBrains .http 语法；纯 Lua + curl，无外部二进制下载
-- <leader>Rr : 发送光标处请求（结果面板开在右侧垂直分屏）
-- <leader>RR : 重放上次请求
-- <leader>Re : 选择 .env 环境文件
-- <leader>Rp : 右侧打开结果面板
return {
  {
    "rest-nvim/rest.nvim",
    ft = { "http" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "http")
      end,
    },
    -- v3 无 setup()：配置需在插件加载前写入 vim.g.rest_nvim
    init = function()
      vim.g.rest_nvim = {
        -- 结果面板 winbar（状态码、耗时等）
        ui = { winbar = true },
        -- 启用 .env 环境文件（:Rest env select）
        env = { enable = true },
      }
    end,
    keys = {
      { "<leader>Rr", "<cmd>botright vert Rest run<cr>", desc = "Rest: 发送光标处请求", ft = "http" },
      { "<leader>Re", "<cmd>Rest env select<cr>", desc = "Rest: 选择 .env 环境文件", ft = "http" },
      { "<leader>Rp", "<cmd>botright vert Rest open<cr>", desc = "Rest: 右侧打开结果面板", ft = "http" },
      { "<leader>RR", "<cmd>Rest last<cr>", desc = "Rest: 重放上次请求" },
    },
  },
}
