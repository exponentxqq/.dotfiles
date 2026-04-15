-- 插件配置
-- 使用 lazy.nvim 插件管理器

return {
    --============================================================
    -- Mason / LSP / 格式化 / 补全（spec: docs/superpowers/specs/2026-04-15-nvim-mason-ts-java-python-design.md）
    --============================================================

    {
        'mason-org/mason.nvim',
        cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonLog' },
        config = function()
            require('mason').setup({
                PATH = 'prepend',
                ui = { border = 'rounded' },
            })
        end,
    },
    {
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        dependencies = { 'mason-org/mason.nvim' },
        config = function()
            require('mason-tool-installer').setup({
                ensure_installed = {
                    'google-java-format',
                    'ruff',
                    'eslint_d',
                },
                auto_update = false,
            })
        end,
    },
    {
        'neovim/nvim-lspconfig',
        lazy = false,
    },
    {
        'mason-org/mason-lspconfig.nvim',
        dependencies = {
            'mason-org/mason.nvim',
            'neovim/nvim-lspconfig',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            require('lsp').setup_mason_lsp()
        end,
    },
    {
        'mfussenegger/nvim-jdtls',
        ft = 'java',
        dependencies = {
            'mason-org/mason.nvim',
            'hrsh7th/cmp-nvim-lsp',
        },
        config = function()
            require('lsp').setup_jdtls()
        end,
    },
    {
        'stevearc/conform.nvim',
        event = { 'BufWritePre', 'BufNewFile', 'BufReadPost' },
        config = function()
            require('conform').setup({
                format_on_save = {
                    timeout_ms = 800,
                    lsp_fallback = true,
                },
                formatters_by_ft = {
                    java = { 'google-java-format' },
                    javascript = { 'eslint_d', 'eslint' },
                    javascriptreact = { 'eslint_d', 'eslint' },
                    typescript = { 'eslint_d', 'eslint' },
                    typescriptreact = { 'eslint_d', 'eslint' },
                    vue = { 'eslint_d', 'eslint' },
                    python = { 'ruff_format' },
                },
            })
        end,
    },
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-nvim-lsp',
            'saadparwaiz1/cmp_luasnip',
            'L3MON4D3/LuaSnip',
        },
        config = function()
            require('luasnip').config.set_config({
                history = true,
                updateevents = 'TextChanged,TextChangedI',
            })
            local cmp = require('cmp')
            local luasnip = require('luasnip')
            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                }),
            })
        end,
    },

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
    -- 勿 pin 0.1.x：nvim-treesitter main 已移除 parsers.ft_to_lang，旧 telescope 预览会报错
    -- （见 https://github.com/nvim-telescope/telescope.nvim/issues/3487 ）
    -- 若仍报 ft_to_lang：lazy-lock.json 可能仍钉在旧提交，请在本机执行 :Lazy update telescope.nvim
    {
        'nvim-telescope/telescope.nvim',
        branch = 'master',
        version = false,
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
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '查找缓冲区' })
            vim.keymap.set('n', '<leader>fh', builtin.oldfiles, { desc = '历史文件' })
            vim.keymap.set('n', '<leader>fl', builtin.grep_string, { desc = '搜索光标下单词' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '全文搜索' })
            vim.keymap.set('n', '<leader>cm', builtin.commands, { desc = 'Telescope 命令' })
            vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = '当前缓冲区模糊查找' })
            vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = 'Git 文件' })
            vim.keymap.set('n', '<leader>fs', builtin.current_buffer_fuzzy_find, { desc = '当前缓冲区符号/模糊' })
            vim.keymap.set('v', '<leader>fs', builtin.current_buffer_fuzzy_find, { desc = '当前缓冲区模糊查找' })
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

    -- 撤销树（原 plugin/undotree.lua 仅映射了命令但未安装插件）
    {
        'mbbill/undotree',
        keys = { { '<leader>u', '<cmd>UndotreeToggle<CR>', desc = '撤销树' } },
        config = function()
            vim.api.nvim_create_autocmd('FileType', {
                pattern = 'undotree',
                callback = function()
                    vim.opt_local.number = false
                    vim.opt_local.relativenumber = false
                    vim.wo.cursorline = true
                end,
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
                    'gitcommit', 'markdown', 'vue',
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

    -- LuaSnip 由 nvim-cmp 依赖加载并初始化

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
