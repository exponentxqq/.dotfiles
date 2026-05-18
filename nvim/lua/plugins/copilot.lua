return {
  {
    "github/copilot.vim",
    lazy = false,
    init = function()
      local node_bin = vim.fn.expand("~/.local/node-v22.18.0-linux-x64/bin")
      vim.g.copilot_node_command = node_bin .. "/node"
      vim.g.copilot_npx_command = node_bin .. "/npx"
    end,
    config = function()
      vim.keymap.set("i", "<M-y>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = "Copilot Accept",
      })
    end,
  },
}
