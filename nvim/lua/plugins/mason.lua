-- 让 mason 安装时解析到的 npm 与 npm 系 LSP 运行时的 node 都来自宿主，
-- 避免 docker 封装在 ~/.local 等未挂载目录产生副作用（方案 C 的 nvim 侧双保险）
return {
  "mason-org/mason.nvim",
  init = function()
    vim.env.PATH = "/usr/bin:" .. vim.env.PATH
  end,
}
