-- LSP：Mason + nvim-lspconfig + nvim-jdtls（见 docs/superpowers/specs/2026-04-15-nvim-mason-ts-java-python-design.md）

local M = {}

--- 仅提示一次：未配置项目 JDK 17 路径
local warned_missing_project_jdk = false

---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
    local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    -- gd / gK 见文件末尾 LspAttach：避免未附着时落到其它插件把 gd 绑到 :tag（E433/E426）
    map('n', 'gr', function()
        local ok, tb = pcall(require, 'telescope.builtin')
        if ok then
            tb.lsp_references({ show_line = false })
        else
            vim.lsp.buf.references()
        end
    end, 'LSP 引用')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'LSP 重命名')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'LSP Code action')
    map('n', '[d', vim.diagnostic.goto_prev, '上一诊断')
    map('n', ']d', vim.diagnostic.goto_next, '下一诊断')
end

function M.setup_mason_lsp()
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    require('mason-lspconfig').setup({
        -- Neovim 0.11+：mason-lspconfig 会对已安装包调用 vim.lsp.enable；jdtls 会走 Mason 的 Python 包装脚本
        --（默认 java 常为 17，与 jdtls 要求冲突）。改由下方 setup_jdtls + nvim-jdtls 用 java -jar 启动。
        automatic_enable = {
            exclude = { 'jdtls' },
        },
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

--- JDT LS 进程本身须用 Java 21+ 启动（与 Mason jdtls 一致）；项目语言级别由 java.configuration.runtimes 单独指定（如 JavaSE-17）。
local JDTLS_MIN_JAVA_MAJOR = 21
--- 我司/工作区项目 JDK（与「跑 LS 的 JVM」无关）。
local PROJECT_JAVA_MAJOR = 17

---@param java_bin string
---@return integer?
local function java_major_version(java_bin)
    local proc = vim.system({ java_bin, '-version' }, { text = true }):wait()
    if proc.code ~= 0 then
        return nil
    end
    local text = (proc.stderr or '') .. (proc.stdout or '')
    local quoted = text:match('version "([^"]+)"')
    if not quoted then
        return nil
    end
    if quoted:sub(1, 2) == '1.' then
        return tonumber(quoted:match('^1%.(%d+)'))
    end
    return tonumber(quoted:match('^(%d+)'))
end

---@param candidates string[]
---@return string?
local function first_java_executable_ge(candidates, min_major)
    local tried = {}
    for _, java in ipairs(candidates) do
        if not tried[java] and type(java) == 'string' and java ~= '' and vim.fn.executable(java) == 1 then
            tried[java] = true
            local major = java_major_version(java)
            if major and major >= min_major then
                return java
            end
        end
    end
    return nil
end

--- 用于启动 jdtls 的 java：优先 JDTLS_JAVA_HOME；再扫描 /usr/lib/jvm（JAVA_HOME 常为 17 时仍能旁路安装 jdk-openjdk）；最后 JAVA_HOME / PATH。
---@return string?
local function resolve_java_for_jdtls()
    local candidates = {}

    local jdtls_home = vim.fn.getenv('JDTLS_JAVA_HOME')
    if type(jdtls_home) == 'string' and jdtls_home ~= '' then
        candidates[#candidates + 1] = vim.fs.joinpath(jdtls_home, 'bin', 'java')
    end

    for _, java in ipairs(vim.fn.glob('/usr/lib/jvm/java-*-openjdk/bin/java', false, true)) do
        candidates[#candidates + 1] = java
    end

    local home = vim.fn.getenv('JAVA_HOME')
    if type(home) == 'string' and home ~= '' then
        candidates[#candidates + 1] = vim.fs.joinpath(home, 'bin', 'java')
    end

    local path_java = vim.fn.exepath('java')
    if path_java ~= '' then
        candidates[#candidates + 1] = path_java
    end
    candidates[#candidates + 1] = 'java'

    return first_java_executable_ge(candidates, JDTLS_MIN_JAVA_MAJOR)
end

--- JDK 安装根目录（含 bin/java），供 java.configuration.runtimes使用。
---@return string?
local function resolve_project_jdk_home()
    for _, key in ipairs({ 'JAVA17_HOME', 'PROJECT_JAVA_HOME' }) do
        local v = vim.fn.getenv(key)
        if type(v) == 'string' and v ~= '' and vim.fn.isdirectory(v) == 1 then
            return v
        end
    end
    local g = vim.g.java17_home
    if type(g) == 'string' and g ~= '' and vim.fn.isdirectory(g) == 1 then
        return g
    end
    local arch17 = '/usr/lib/jvm/java-17-openjdk'
    if vim.fn.isdirectory(arch17) == 1 then
        return arch17
    end
    return nil
end

---@param InstallLocation table
---@param jdtls_path string
---@return string?
local function resolve_lombok_jar(InstallLocation, jdtls_path)
    local candidates = {
        InstallLocation.global():share('jdtls/lombok.jar'),
        jdtls_path .. '/lombok.jar',
    }
    for _, p in ipairs(candidates) do
        if vim.fn.filereadable(p) == 1 then
            return p
        end
    end
    return nil
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
            -- Mason 2.x：Package 不再有 get_install_path()，路径由 InstallLocation 给出（与 Registry.is_installed 一致）
            local InstallLocation = require('mason-core.installer.InstallLocation')
            local jdtls_path = InstallLocation.global():package('jdtls')
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

            local java_exe = resolve_java_for_jdtls()
            if not java_exe then
                local fallback = vim.fn.exepath('java')
                if fallback == '' then
                    fallback = 'java'
                end
                local maj = java_major_version(fallback)
                vim.notify(
                    string.format(
                        '启动 jdtls 需要 Java %d+（当前 `%s` 为 %s）。可与项目 JDK17 并存：安装 `jdk-openjdk`，并设 JDTLS_JAVA_HOME 指向该 JDK，或保持 JAVA_HOME=JDK17 由配置扫描 /usr/lib/jvm。',
                        JDTLS_MIN_JAVA_MAJOR,
                        fallback,
                        maj and ('Java ' .. tostring(maj)) or '未知版本'
                    ),
                    vim.log.levels.ERROR
                )
                return
            end

            -- Lombok：必须在 -jar 之前加入 -javaagent，否则生成方法/字段无法解析、gd 大量失效（child-game/service 等 Gradle 多模块常见）
            local lombok_jar = resolve_lombok_jar(InstallLocation, jdtls_path)
            local cmd = {
                java_exe,
                '-Declipse.application=org.eclipse.jdt.ls.core.id1',
                '-Dosgi.bundles.defaultStartLevel=4',
                '-Declipse.product=org.eclipse.jdt.ls.core.product',
                '-Dlog.protocol=true',
                '-Dlog.level=ALL',
                '-Xmx2g',
                '--add-modules=ALL-SYSTEM',
                '--add-opens',
                'java.base/java.util=ALL-UNNAMED',
                '--add-opens',
                'java.base/java.lang=ALL-UNNAMED',
            }
            if lombok_jar then
                cmd[#cmd + 1] = '-javaagent:' .. lombok_jar
            end
            vim.list_extend(cmd, {
                '-jar',
                launcher_jar,
                '-configuration',
                config_path,
                '-data',
                workspace_dir,
            })

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            local java_settings = {
                format = { enabled = false },
                jdt = {
                    ls = {
                        lombokSupport = {
                            enabled = true,
                        },
                    },
                },
                import = {
                    gradle = {
                        enabled = true,
                        wrapper = {
                            enabled = true,
                        },
                    },
                },
            }
            local jdk17_home = resolve_project_jdk_home()
            if jdk17_home then
                java_settings.configuration = {
                    runtimes = {
                        {
                            name = 'JavaSE-' .. tostring(PROJECT_JAVA_MAJOR),
                            path = jdk17_home,
                            default = true,
                        },
                    },
                    -- 'automatic' 会在 didChangeConfiguration 时阻塞消息处理线程（Gradle reimport），
                    -- 导致所有 LSP 请求（definition/hover）永远不被处理。改 'interactive' 按需触发。
                    updateBuildConfiguration = 'interactive',
                }
            else
                java_settings.configuration = {
                    updateBuildConfiguration = 'interactive',
                }
            end
            if not jdk17_home and not warned_missing_project_jdk then
                warned_missing_project_jdk = true
                vim.notify(
                    '未找到 JDK 17 目录，jdtls 按工作区推断 Java 版本。可安装 jdk17-openjdk 或设置 JAVA17_HOME / g:java17_home。',
                    vim.log.levels.WARN
                )
            end

            require('jdtls').start_or_attach({
                cmd = cmd,
                root_dir = root_dir,
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                    java = java_settings,
                },
            })
        end,
    })
end

-- gK（LSP hover）：LspAttach 后绑定 buffer-local gK，比全局映射优先。
-- gd 不在此处绑定：Java 由 init.lua 的 FileType java autocmd 负责（原始 client:request，
-- 不经过 vim.lsp.buf.definition 的 settagstack 路径，避免 E426/E433）；
-- 其它语言走 keymaps.lua 的全局 gd（VeryLazy）。
do
    local methods = vim.lsp.protocol.Methods
    local group = vim.api.nvim_create_augroup('dotfiles-lsp-buffer-keys', { clear = true })

    ---@param buf integer
    local function bind_gK(buf)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        for _, c in pairs(vim.lsp.get_clients({ bufnr = buf })) do
            if c:supports_method(methods.textDocument_hover, buf) then
                vim.keymap.set('n', 'gK', vim.lsp.buf.hover, { buffer = buf, desc = 'LSP 悬停文档' })
                return
            end
        end
    end

    vim.api.nvim_create_autocmd('LspAttach', {
        group = group,
        callback = function(args)
            local buf = args.buf
            vim.schedule(function()
                bind_gK(buf)
                vim.defer_fn(function()
                    bind_gK(buf)
                end, 200)
            end)
        end,
    })
end

return M
