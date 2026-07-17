return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        formats = {
          "png",
          "jpg",
          "jpeg",
          "gif",
          "bmp",
          "webp",
          "tiff",
        },
      },
    },
    -- workaround: snacks.nvim 的 placement.update() 在 buffer 恢复显示时
    -- 缺少 show 分支，导致 self.hidden 永远不被重置，_render() 清空所有
    -- virt_text/virt_lines，切走再切回后图片不渲染。
    -- 上游 bug 位置: snacks/image/placement.lua update() 只有 #wins==0 的 hide 分支
    -- 修复方式: monkey-patch update，在 wins>0 且 hidden 时重置 hidden。
    -- 不重新 attach，避免破坏 image convert 的 progress 定时器导致僵尸 loading。
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "image",
        once = true,
        group = vim.api.nvim_create_augroup("snacks_image_fix", { clear = true }),
        callback = function()
          local ok, Placement = pcall(require, "snacks.image.placement")
          if not ok then
            return
          end
          local orig_update = Placement.update
          Placement.update = function(self, ...)
            if self.hidden and #self:wins() > 0 then
              self.hidden = false
            end
            return orig_update(self, ...)
          end
        end,
      })

      -- SVG 分屏预览：左侧代码，右侧渲染图片
      -- img_buf + placement 只创建一次，img_win 动态开关跟随 code_buf 显示状态
      local function svg_preview(code_buf)
        if not vim.api.nvim_buf_is_valid(code_buf) then
          return
        end
        if vim.b[code_buf].svg_preview then
          return
        end
        local file = vim.api.nvim_buf_get_name(code_buf)
        if file == "" or vim.fn.filereadable(file) == 0 then
          return
        end

        if not pcall(require, "snacks.image") then
          vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            once = true,
            callback = function()
              svg_preview(code_buf)
            end,
          })
          return
        end

        vim.b[code_buf].svg_preview = true
        local SnacksImage = require("snacks.image")

        -- 图片 buffer + placement（全程只创建一次）
        local img_buf = vim.api.nvim_create_buf(false, true)
        local bo = vim.bo[img_buf]
        bo.buftype = "nofile"
        bo.swapfile = false
        bo.modifiable = false
        bo.modified = false
        bo.filetype = "image"

        SnacksImage.placement.new(img_buf, file, {
          inline = false,
          auto_resize = true,
          conceal = true,
        })

        local img_win = nil ---@type number?

        local function ensure_img_win()
          if img_win and vim.api.nvim_win_is_valid(img_win) then
            return
          end
          local code_win = vim.fn.bufwinid(code_buf)
          if code_win < 0 then
            return
          end
          pcall(vim.api.nvim_win_call, code_win, function()
            local ok, win = pcall(vim.api.nvim_open_win, img_buf, false, {
              vertical = true,
              split = "right",
            })
            if ok then
              img_win = win
            end
          end)
          if img_win and vim.api.nvim_win_is_valid(img_win) then
            require("snacks.util").wo(img_win, SnacksImage.config.wo or {})
          end
        end

        local function close_img_win()
          if img_win and vim.api.nvim_win_is_valid(img_win) then
            pcall(vim.api.nvim_win_close, img_win, false)
          end
          img_win = nil
        end

        vim.schedule(function()
          if not vim.api.nvim_buf_is_valid(code_buf) then
            return
          end
          ensure_img_win()
          local code_win = vim.fn.bufwinid(code_buf)
          if code_win >= 0 and vim.api.nvim_win_is_valid(code_win) then
            vim.api.nvim_set_current_win(code_win)
          end

          vim.api.nvim_create_autocmd("BufWinEnter", {
            buffer = code_buf,
            callback = function()
              vim.schedule(ensure_img_win)
            end,
          })
          vim.api.nvim_create_autocmd("BufWinLeave", {
            buffer = code_buf,
            callback = function()
              vim.schedule(function()
                if vim.fn.bufwinid(code_buf) < 0 then
                  close_img_win()
                end
              end)
            end,
          })
          vim.api.nvim_create_autocmd("BufDelete", {
            buffer = code_buf,
            once = true,
            callback = function()
              close_img_win()
              if vim.api.nvim_buf_is_valid(img_buf) then
                vim.api.nvim_buf_delete(img_buf, { force = true })
              end
            end,
          })
        end)
      end

      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.svg",
        group = vim.api.nvim_create_augroup("snacks_image_svg", { clear = true }),
        callback = function(e)
          svg_preview(e.buf)
        end,
      })
    end,
  },
}
