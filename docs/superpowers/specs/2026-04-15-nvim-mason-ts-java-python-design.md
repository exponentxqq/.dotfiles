# Neovim：TypeScript / Java / Python 开发环境（Mason 方案）— 设计规格

**日期**：2026-04-15  
**版本**：v1.1  
**状态**：已评审（用户认可）；待实施  

**v1.1**：§5.3 按仓库实际工具链区分 **ESLint `--fix`** 与 **Prettier**（对齐 Nuxt 等仅 ESLint 格式化的项目，如 `child-game/child`）。

---

## 1. 背景与目标

在个人 dotfiles 中的 Neovim 配置（`lazy.nvim`、Treesitter、Telescope、Neo-tree 等）之上，补齐 **TypeScript、Java、Python** 的日常开发能力：**LSP（诊断、跳转、重命名、代码动作）**、**补全**、**统一格式化入口**，并约定 **语言工具以 Mason 安装为主**（方案 A）。

**非目标（本阶段不做）**：`nvim-dap` 调试、与企业强制制品库对齐的定制 LSP 分发、单仓多根的特殊工程规则文档化（仅在「风险」中提示）。

---

## 2. 已确认的决策

| 决策项 | 选择 |
|--------|------|
| 工具链策略 | **A**：Mason 安装 LSP 与格式化器等可执行文件；本机仍须具备 **JDK、Node、Python** 等运行时 |
| TypeScript / JavaScript LSP | **typescript-language-server**（Mason）；若日后需切换 **vtsls**，仅调整 Mason 包与 `lspconfig` server 名 |
| Java | **jdtls**（Mason）+ **nvim-jdtls**；**格式化**使用 **google-java-format**（见 §5.2），不依赖 jdtls 自带的 format 作为唯一来源 |
| Python | **basedpyright** 或 **pyright**（实现阶段二选一默认 **basedpyright**，与团队习惯冲突时可改为 pyright）；**ruff** 用于 lint 与可选 format |
| TS / JS / Vue **格式化** | **以项目为准**：仓库以 **`eslint --fix`** 为官方 format（无 Prettier）时，conform 使用 **ESLint 修复**（含 `*.vue` flat config）；存在 Prettier 时再使用 **prettier**（见 §5.3） |
| 格式化统一层 | **conform.nvim**，与现有 `:Format`、`<leader>f`、`BufWritePre` 对齐（见 §5） |

---

## 3. 架构与组件职责

| 组件 | 职责 |
|------|------|
| **mason.nvim** | 安装、升级、查看 LSP 与 CLI（jdtls、typescript-language-server、pyright/basedpyright、ruff、**可选** prettier / eslint 类全局工具、google-java-format 等）；**ESLint 执行优先使用项目 `node_modules`**（见 §5.3） |
| **mason-lspconfig.nvim** | 将 Mason 安装路径与 **nvim-lspconfig** 的 server 名对齐，减少手写 `cmd` |
| **nvim-lspconfig** | 配置 TS/JS、Python 等通用 LSP；`on_attach` 中绑定 buffer 快捷键与能力 |
| **nvim-jdtls** | Java：启动 jdtls、工作区与项目根（Maven/Gradle）；**不在此路径上假设 format 仅来自 LSP** |
| **conform.nvim** | 按文件类型调用格式化器；**Java 固定为 google-java-format**；TS/JS/Vue 按 §5.3 在 **ESLint fix** 与 **prettier** 间选择；Python 可用 **ruff format** 或保留 LSP（实现时定默认，建议 ruff format 与 ruff lint 一致） |
| **nvim-cmp** | 插入模式补全 |
| **cmp-nvim-lsp** | LSP 补全源 |
| **LuaSnip** + **cmp_luasnip** | 与现有 LuaSnip 配置衔接片段补全 |

现有 **`commands.lua` 中 `:Format`**：实施时改为调用 **conform.format**（或封装为单一入口），避免与 `vim.lsp.buf.format` 双轨并存；**`BufWritePre`** 中 `silent! format` 与 `:Format` 使用同一逻辑。

---

## 4. Mason 建议安装项（ensure_installed）

以下为实施时 `mason.nvim` / `mason-tool-installer`（若采用）或文档中要求用户 `:Mason` 确认安装的清单，**以实现阶段 lockfile 为准**：

- **LSP**：`jdtls`、`typescript-language-server`、`basedpyright`（或 `pyright`）
- **Formatter / 工具**：`google-java-format`、**`ruff`**（Python）；**`prettier`** 与 **全局 eslint**（如 `eslint_d`）为 **可选**，仅作无 `node_modules` 时的 fallback；前端项目格式化以 **`pnpm exec` / `npm exec` 可用的本地 eslint** 为准

若某包在 Mason registry 中名称不同，以 Mason UI 为准并在实现计划中写死映射。

---

## 5. 格式化策略

### 5.1 原则

- **单一用户入口**：`:Format`、`<leader>f`、以及 `BufWritePre` 均走 **同一格式化路径**（conform）。
- **按文件类型**在 conform 中配置 formatter；失败时 **不静默吞掉** 关键错误（实现时可用 `vim.notify` 或 conform 自带行为，与当前 `silent!` 保存策略协调：可对 `format` 使用 `silent` 仅抑制无 formatter，但需能排查配置错误）。

### 5.2 Java

- **必须使用 google-java-format** 作为 Java 的 conform formatter。
- Mason 安装 **google-java-format** 可执行文件；conform 的 `java` formatter 指向该命令（或由 conform 内置适配器名指定，以实现阶段官方文档为准）。
- **不**将「仅 jdtls LSP format」作为 Java 的唯一格式化方式（与用户明确要求一致）；jdtls 仍用于非格式化类 LSP 能力。

### 5.3 TypeScript / JavaScript / Vue

**原则：与仓库的 `package.json` / 脚本一致，不强行统一为 Prettier。**

- **仅 ESLint、且 `format` 脚本为 `eslint --fix`**（示例：`child-game/child`：Nuxt 4 + `@nuxt/eslint` + ESLint 9 flat config，无 `prettier` 依赖）：  
  - conform 对 `javascript`、`typescript`、`vue`（及项目实际用到的扩展名）使用 **ESLint 的 fix 能力**（conform 内置适配器或等价调用）。  
  - **优先使用项目内** `node_modules/.bin/eslint`（与 `pnpm run format` 同源），工作目录为 **项目根**（含 `eslint.config.*` / `package.json` 的目录），避免全局 ESLint 与 **flat config** 版本不一致。  
  - **不在此类仓库默认启用 Prettier**，以免与 CI / `pnpm run format` 行为分叉。
- **存在 Prettier**（`prettier` 在 devDependencies 或团队明确要求）：conform 对相应文件使用 **prettier**；若同时使用 ESLint 格式规则，以项目既有约定为准（如 `eslint-config-prettier`），实现阶段按仓库常见模式配置顺序（通常 **prettier 与 eslint fix 顺序** 在 conform 文档中择一明确写法）。
- **fallback**（无 `node_modules`、单文件编辑）：实现计划写死一种行为——例如 Mason 的 `prettier` / 全局 `eslint_d` 或仅 `vim.notify` 提示「请在项目根打开」，避免 silent 无效果。

**诊断**：除 format 外，可通过 **nvim-lspconfig 挂载 `eslint` LSP**（若采用）或依赖 **conform / 手工 `eslint`** 与 Treesitter 高亮；实现阶段在计划中二选一或组合，避免重复弹同一诊断。

### 5.4 Python

- 默认 **ruff format**（与 ruff lint 一致）；若未安装 ruff，可 fallback **LSP** 或跳过（实现计划写明）。

---

## 6. 按键与 LSP 行为

在 `on_attach`（及 jdtls 等价 attach 钩子）中为 **buffer-local** 设置（与现有 `<leader>` 空格不冲突）：

| 按键 | 行为 |
|------|------|
| `gd` | 跳转到定义 |
| `gr` | 引用列表（可用 `telescope.builtin.lsp_references` 或内置 quickfix，实现时统一） |
| `K` | Hover 文档 |
| `<leader>rn` | 重命名 |
| `<leader>ca` | Code action |
| `[d` / `]d` | 上/下一条诊断（`vim.diagnostic`） |

**nvim-cmp**：插入模式下触发补全；与 **LuaSnip** 通过 `cmp_luasnip` 集成。

---

## 7. 与现有配置的衔接与修正

- **`init.lua`**：`BufWritePre` 的 pattern 将 **`*.python` 改为 `*.py`**，否则 Python 保存不会触发格式化。
- **`plugin/telescope.lua` 与 `lua/plugins.lua`** 中 Telescope 键位存在重复绑定，实施时 **合并为一处**，避免重复与加载顺序问题（本 spec 要求「整理」，不单加 LSP）。
- **`plugins.lua`** 中 **nvim-treesitter** 重复 spec 块应合并为一条（实施时整理）。

---

## 8. 风险与使用约束

- **Java**：多模块 Maven/Gradle 工程应从 **正确项目根** 启动 Neovim；`nvim-jdtls` 数据目录需可写，JDK 版本与工程要求一致（`JAVA_HOME`）。
- **TypeScript / Vue**：Monorepo 尽量与团队打开目录一致，保证 `tsconfig` / 路径别名解析正确；**ESLint flat config** 需在正确 **cwd** 下执行，否则 `--fix` 与编辑器内结果可能与 `pnpm run format` 不一致。
- **Python**：虚拟环境需对 Pyright 可见（常见：`venv`、工作区配置、`pyrightconfig.json`）；否则诊断与跳转质量下降，与 Mason 无关。

---

## 9. 验证标准（实施后）

- 在三种语言的 **最小示例项目** 中：打开文件后 Mason 已装服务器可附着；`gd` / `K` / 诊断可用；`:Format` 在 **Java** 上产出符合 **google-java-format** 的风格；保存触发与手动格式化行为一致。  
- 在 **仅 ESLint format** 的前端仓库（如 Nuxt + `eslint --fix`）中：`:Format` 与 **`pnpm run format`** 对同文件结果一致（允许实现细节差异，但规则集须同源）。
- `:checkhealth` 中 **lsp**、**mason**（若提供）无阻塞性错误。

---

## 10. 规格自检（v1.1）

1. **占位符**：无 TBD；Java 用 google-java-format；TS/JS/Vue 已区分 ESLint-only 与 Prettier 仓库。  
2. **一致性**：Java 仍以 conform + google-java-format 为准；TS/JS/Vue 与「child-game 类仓库无 Prettier」不冲突。  
3. **范围**：单 spec 覆盖 TS/Java/Python + Mason + 补全 + 格式化；调试与 DAP 明确排除。  
4. **歧义**：§5.3 已缩小歧义；**无 node_modules 时** 的 fallback 仍在实施计划中写死为一种行为；Python「无 ruff」fallback 同上。

---

**文档路径**：`docs/superpowers/specs/2026-04-15-nvim-mason-ts-java-python-design.md`（仓库：`dotfiles`）
