-- LSP：Mason + nvim-lspconfig + nvim-jdtls（见 docs/superpowers/specs/2026-04-15-nvim-mason-ts-java-python-design.md）

local M = {}

---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map('n', 'gd', vim.lsp.buf.definition, 'LSP 定义')
    map('n', 'gr', function()
        local ok, tb = pcall(require, 'telescope.builtin')
        if ok then
            tb.lsp_references({ show_line = false })
        else
            vim.lsp.buf.references()
        end
    end, 'LSP 引用')
    map('n', 'K', vim.lsp.buf.hover, 'LSP 文档')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'LSP 重命名')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'LSP Code action')
    map('n', '[d', vim.diagnostic.goto_prev, '上一诊断')
    map('n', ']d', vim.diagnostic.goto_next, '下一诊断')
end

function M.setup_mason_lsp()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    require('mason-lspconfig').setup({
        -- 须为 nvim-lspconfig 的 server 名，勿写 Mason 包名（如 typescript-language-server → ts_ls）
        ensure_installed = {
            'jdtls',
            'ts_ls',
            'basedpyright',
        },
        handlers = {
            ---@param server_name string
            function(server_name)
                if server_name == 'jdtls' then
                    return
                end
                require('lspconfig')[server_name].setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                })
            end,
        },
    })
end

---@param bufnr integer
---@return string?
local function java_root_dir(bufnr)
    return vim.fs.root(bufnr, {
        'settings.gradle',
        'settings.gradle.kts',
        'pom.xml',
    }) or vim.fs.root(bufnr, { '.git' })
end

---@param jdtls_path string
---@return string?
local function jdtls_config_dir(jdtls_path)
    local configs = vim.fn.glob(jdtls_path .. '/config_*', false, true)
    if configs[1] then
        return configs[1]
    end
    return jdtls_path .. '/config_linux'
end

function M.setup_jdtls()
    vim.api.nvim_create_autocmd('FileType', {
        pattern = 'java',
        callback = function(ev)
            local ok, mr = pcall(require, 'mason-registry')
            if not ok or not mr.is_installed('jdtls') then
                return
            end
            local pkg = mr.get_package('jdtls')
            local jdtls_path = pkg:get_install_path()
            local launcher_jar = vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar')
            if launcher_jar == '' then
                return
            end
            local root_dir = java_root_dir(ev.buf)
            if not root_dir then
                root_dir = vim.fn.getcwd()
            end
            local project_name = vim.fn.fnamemodify(root_dir, ':t')
            local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls/' .. project_name
            local config_path = jdtls_config_dir(jdtls_path)

            local cmd = {
                'java',
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xmx1g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens',
                'java.base/java.util=ALL-UNNAMED',
                '--add-opens',
                'java.base/java.lang=ALL-UNNAMED',
                '-jar',
                launcher_jar,
                '-configuration',
                config_path,
                '-data',
                workspace_dir,
            }

            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('jdtls').start_or_attach({
                cmd = cmd,
                root_dir = root_dir,
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    java = {
                        format = { enabled = false },
                    },
                },
            })
        end,
    })
end

return M
