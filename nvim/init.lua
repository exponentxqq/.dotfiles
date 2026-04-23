-- GUI / Cursor 启动的 Neovim 往往不读 zshrc；dadbod 需要 PATH 里真实的 mysql（~/bin/mysql 包装脚本）。
vim.env.PATH = vim.fn.expand("~/bin") .. ":" .. vim.env.PATH

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
