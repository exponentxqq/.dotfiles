return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>gg",
        function()
          local path = vim.api.nvim_buf_get_name(0)
          if path == "" then
            local arg = vim.fn.argv(0)
            if arg ~= "" then
              path = vim.fn.fnamemodify(arg, ":p")
            end
          end
          if path == "" then
            path = vim.uv.cwd()
          end
          local git = vim.fs.find(".git", { path = path, upward = true })[1]
          Snacks.lazygit({ cwd = git and vim.fn.fnamemodify(git, ":h") or vim.uv.cwd() })
        end,
        desc = "Lazygit",
      },
    },
  },
}
