-- 插件配置
-- 使用 lazy.nvim 插件管理器

return {
    --============================================================
    -- 核心工具
    --============================================================

    -- 文件浏览器 (替代 NERDTree)
    {
        'nvim-neo-tree/neo-tree.nvim',
        cmd = 'Neotree',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim', -- neo-tree 依赖 nui.nvim
            'nvim-tree/nvim-web-devicons', -- 图标支持
        },
        config = function()
            require('neo-tree').setup({
                close_if_last_window = false,
                popup_border_style = 'rounded',
                enable_git_status = true,
                enable_diagnostics = true,
                filesystem = {
                    follow_current_file = {
                        enabled = true,
                    },
                    filtering = {
                        ignore_patterns = {
                            "node_modules/",
                            "dist/",
                            "build/",
                            "__pycache__/",
                            ".vscode/",
                            ".idea/",
                            ".git/",
                            "*.pyc",
                            "*.class",
                        },
                    },
                },
            })
        end,
    },

    -- 文件查找 (替代 fzf)
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            require('telescope').setup({
                defaults = {
                    prompt_prefix = "  ",
                    selection_caret = "  ",
                    path_display = { "smart" },
                    mappings = {
                        i = {
                            ["<C-j>"] = "move_selection_next",
                            ["<C-k>"] = "move_selection_previous",
                        },
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
            })
            -- 快捷键
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '查找文件' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '全文搜索' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '查找缓冲区' })
            vim.keymap.set('n', '<leader>fh', builtin.oldfiles, { desc = '历史文件' })
        end,
    },

    -- 状态栏 (替代 vim-airline)
    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'auto',
                    section_separators = { left = '', right = '' },
                    component_separators = { left = '', right = '' },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename' },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {},
                },
            })
        end,
    },

    -- Treesitter (语法高亮和代码结构)
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        dependencies = {
            'nvim-treesitter/nvim-treesitter-context',
        },
        config = function()
            require('nvim-treesitter').setup({
                ensure_installed = {
                    'lua', 'vim', 'vimdoc',
                    'javascript', 'typescript',
                    'python', 'go', 'rust',
                    'html', 'css', 'scss',
                    'json', 'yaml', 'toml',
                    'gitcommit', 'markdown',
                },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = { enable = true },
            })
        end,
    },

    --============================================================
    -- 增强功能
    --============================================================

    -- 缩进线 (替代 vim-indent-guides)
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        config = function()
            require('ibl').setup({
                indent = { char = '│' },
            })
        end,
    },

    -- 括号对齐
    {
        'echasnovski/mini.pairs',
        config = function()
            require('mini.pairs').setup()
        end,
    },

    -- 成对符号自动完成 (LuaSnip)
    {
        'L3MON4D3/LuaSnip',
        dependencies = {
            -- 移除 lua_snippets 依赖，使用 builtin snippets
        },
        config = function()
            require('luasnip').config.set_config({
                history = true,
                updateevents = 'TextChanged,TextChangedI',
            })
        end,
    },

    -- 彩虹括号 (替代 rainbow_parentheses.vim)
    {
        'nvim-treesitter/nvim-treesitter',
        -- 使用内置的 rainbow 功能，不需要额外插件
    },

    -- 插件管理器本身 (.lazy DEMO)
    {
        'folke/lazy.nvim',
        opts = {
            settings = {
                update = {
                    enabled = true,
                    autoupdate = false,
                },
            },
        },
    },
}
