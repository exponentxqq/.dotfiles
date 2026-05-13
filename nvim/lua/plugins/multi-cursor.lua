return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  event = "VeryLazy",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- 下/上方添加光标
    set({ "n", "x" }, "<C-down>", function()
      mc.lineAddCursor(1)
    end)
    set({ "n", "x" }, "<C-up>", function()
      mc.lineAddCursor(-1)
    end)

    -- 匹配选中的单词: 选中下一个/上一个匹配
    set({ "n", "x" }, "<C-n>", function()
      if not mc.cursorsEnabled() then
        mc.enableCursors()
      end
      mc.matchAddCursor(1)
    end, { desc = "多光标: 选中下一个匹配" })

    set({ "n", "x" }, "<C-p>", function()
      mc.matchAddCursor(-1)
    end, { desc = "多光标: 选中上一个匹配" })

    set({ "n", "x" }, "<C-x>", function()
      mc.matchSkipCursor(1)
    end, { desc = "多光标: 跳过当前匹配" })

    -- 多光标模式下额外映射
    mc.addKeymapLayer(function(layerSet)
      layerSet({ "n", "x" }, "<left>", mc.prevCursor)
      layerSet({ "n", "x" }, "<right>", mc.nextCursor)
      layerSet({ "n", "x" }, "K", mc.deleteCursor)

      layerSet("n", "<Esc>", function()
        if mc.cursorsEnabled() then
          mc.clearCursors()
        else
          mc.enableCursors()
        end
      end)
    end)

    -- 自定义高亮
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
  end,
}
