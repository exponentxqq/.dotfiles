-- Go formatting: 使用 Docker 容器中的 gofmt
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        go = { "gofmt" },
      },
      formatters = {
        gofmt = {
          command = "/home/xuqinqin/develop/docker/bin/gofmt",
        },
      },
    },
  },
}
