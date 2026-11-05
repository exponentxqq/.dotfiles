---
name: dsh-plugin-writer
description: >-
  Use when 在 dsh-plugins 仓（/home/xuqinqin/develop/person/dsh-plugins）新增、脚手架或结构性修改 DSH 插件——搭建插件工程骨架、选 host-only/双端形态、写 package.json/cordis.patch.yml/build.mjs、执行构建验证、link: 装入 profile 验证时使用；触发词：插件、plugin、新增插件、bundle、cordis.patch、dump-config-schema。文案小改、发布流程、profile 内一次性 bundle 不适用。
---

# DSH 插件撰写（dsh-plugins 仓）

> 下文路径一律相对 `/home/xuqinqin/develop/person/dsh-plugins`（本 skill 的唯一锚点，不按 cwd 猜仓库）。

## 1. 适用判定与分工

**适用于**：在本仓 `plugins/` 下新增插件、复制模板起工程骨架、或对已有插件做结构性修改（形态 / 入口 / 构建 / 声明 / 安装链）。

**分工（三类任务不归本 skill，先分流再动手）**：

| 任务 | 去哪 |
|---|---|
| 给**当前 profile** 加一次性功能、启用 / 停用已装插件、改 profile 组合 | 官方 skill `cordis-plugin-development`（用 `plugin_manager` 在 profile 内装 bundle，不落本仓） |
| 设计插件**行为规格**、写 proposal / spec / tasks | `openspec-propose`（本仓 OpenSpec 工作流，规划与实施严格分离） |
| 原生依赖细节、纯 client 插件、其余未覆盖类型 | 官方三篇开发文档（入口见 §6） |

**不适用**：文案小改（只改 README / 注释）、发布流程（→ `AGENTS.md`「发布与版本」）、profile 内一次性 bundle（→ `cordis-plugin-development`）。

## 2. 选型决策树

```
要动 Web UI（面板 / 入口 / 渲染）？
├─ 是 → 双端：plugins/session-tool-toggle（或 plugins/web-ux）
└─ 否 → 要替换上游 provider / 需精确版本 allowlist / 带原生依赖？
         ├─ 是 → 特例：plugins/multi-root-workspace（三处落点同源：枚举常量 / peer 枚举 / compat gate）
         └─ 否 → host-only：plugins/zcode-plan（更小的服务型看 plugins/project-mcp）
判定不了 → 回退官方三篇文档（§6）
```

`multi-root-workspace` 只为「必须替换上游 provider 或要精确版本门禁」而选；普通插件以它为模板会整包继承上一代杂质（原生依赖、精确 peer 枚举、compat gate）。

## 3. 模板插件对照表

| 形态 | 模板 | 构建入口 | 版本契约 | 与 host-only 的差集 | 主要失败面 |
|---|---|---|---|---|---|
| host-only（只加命令 / 工具 / 服务） | `plugins/zcode-plan`（更小：`plugins/project-mcp`） | esbuild `build.mjs` | 软：由基线脚本派生 | — | F3 自包含、F4 产物未重建 |
| 双端（多一个浏览器半） | `plugins/session-tool-toggle` | `build.mjs`，host + client 两段 | 软：同左；浏览器半渲染 React 才另加 `react` peer | `dsh.client` + `exports "./client"` + `lib/client.js` 壳 | F1 丢裸包名行（浏览器半静默消失） |
| 特例（替换 provider / 精确门禁 / 原生依赖） | `plugins/multi-root-workspace` | `tsc` 类型 + `tsdown`（**无** `build.mjs`） | 精确 allowlist，三处落点同源 | 精确 peer 枚举、`peerDependenciesMeta`、`allowBuilds` | 漏版本即启动抛错、原生依赖未表态 |

## 4. 必改清单一览（7 项）

| # | 位置 | 改成什么 |
|---|---|---|
| 1 | `name` / 目录名 | `dsh-plugin-<目录名>`；`description` 换成本插件一句话 |
| 2 | `version` | 恒等于仓库当前 tag（仓库级统一版本，`release` 统一同步）；演练 / 未发布包用 `0.0.0`（`structure.md` §5） |
| 3 | `cordis.patch.yml` | 头注释按本插件重写；行 `id` 改本插件；行 `name` 必须是**裸包名**（双端必需，见 F1） |
| 4 | `files` | 必含 `cordis.patch.yml` 与产物：模板写 `lib/**/*.js`，已覆盖双端 `lib/client.js`；改显式清单才逐项列（漏 patch = git 安装缺文件，F2） |
| 5 | `main` / `exports` | `.` → `./lib/index.js`；双端加 `"./client"` → `./lib/client.js`，且与 `dsh.client` 成对 |
| 6 | `dsh.engines.dsh` + DSH peer | 只由 `scripts/dsh-baseline.mjs` 的 `softDshRange()` 派生，**禁止手写数值**（F5） |
| 7 | 模板残留 | 删模板的业务脚本 / 组件 / 文档 / 测试；`test/` 与 `tests/` 别抄错目录名；`lib/` 是提交物而非临时产物 |

入口形状（`src/index.ts` 的 `name` / `inject` / `Config` / `apply`）不在上表：最小导出集合与 `Config` 可省见 `references/structure.md` §1.1。

## 5. 生命周期步骤

1. 定形态（§2）→ 读模板三件套（`package.json` / `cordis.patch.yml` / `build.mjs`）的**头注释**，它写明哪些必须 bundle、哪些外置。
2. `mkdir plugins/<name>`，复制件套：三件套（`package.json` / `cordis.patch.yml` / `build.mjs`，特例为 `tsdown.config.ts`）+ `tsconfig*.json` + `vitest.config.ts` + `src/` + `test/`；双端另加 `.oxlintrc.json`（防 lint 扫 `lib/` 生成壳；模板差异见 `structure.md` §1）。
3. 按 §4 七项改写；版本类字段现取现派生，不从模板或文档抄。
4. `pnpm install`（新包进 workspace；只有带原生依赖才需在根 `pnpm-workspace.yaml` 表态）。
5. `pnpm --filter dsh-plugin-<name> verify:all`（lint → typecheck → build → test）。
6. `pnpm dsh:check`（仓库级基线门禁，会动态枚举 `plugins/*`）。
7. `docker exec dsh dsh plugin --profile web add /home/xuqinqin/develop/person/dsh-plugins/plugins/<name>`（本地路径 = `link:` 调试安装，改源码重启 profile 即生效）。
8. `docker exec dsh dsh --profile web --dump-config-schema` 退出 0 **或**基线对照无新增 error = 装载性通过（它真实 import 插件；既有 profile 行会让退出码恒非 0，退出非 0 先做基线对照再怀疑插件，见 `references/verify-install.md` §4.1）；`--dump-config` 只证明注册行进了合成树。

**止于安装验证**：发布（版本统一 / tag / push）不属本 skill，一句指路 `AGENTS.md`「发布与版本」；排障见 `references/verify-install.md`。

## 6. 真源指路表

| 要查什么 | 真源 |
|---|---|
| DSH 基线版本、软插件可安装范围 | `scripts/dsh-baseline.mjs`（`DSH_BASELINE` / `softDshRange()`）——仓内唯一版本常量，任何文档都不要抄数值 |
| 仓库约定、目录结构、开发命令 | `AGENTS.md`；安装 / 构建授权 / 插件一览见 `README.md` |
| 基线门禁断言、hard 与 soft 的分流 | `scripts/check-dsh-baseline.mjs` |
| 官方插件开发文档（三篇） | `README.md` 末「插件开发文档（官方）」；DSH 源码与 API 在 `/usr/local/lib/node_modules/@deepseek-ai/dsh/`（各子包 `README.zh.md`） |
| 可直接对照的成品 | `plugins/zcode-plan`、`plugins/session-tool-toggle`、`plugins/project-mcp`、`plugins/web-ux`、`plugins/user-commands` |

维护：`pnpm dsh:upgrade` 后复验本 skill 引用的路径与命令，真源变了同步改分册——本 skill 只留路由，事实全部指向上述真源。

## 7. 分册路由与反例速查

| 分册 | 何时读 |
|---|---|
| `references/structure.md` | 逐字段对照（`package.json` / `cordis.patch.yml` / `src/index.ts` 入口形状）、必改清单全量、特例路线三落点 |
| `references/build.md` | 自包含与 external 判定、CJS banner、`lib/` 入库、`allowBuilds`、engines 派生 |
| `references/dual-client.md` | 双端选型与声明形状、裸包名行因果、浏览器半 CJS 壳 |
| `references/verify-install.md` | 命令链与证明强度分层、`/inventory` 核对、排障（卸载残留 / schema 噪音 / 假故障） |

反例速查（一行一条，展开见对应分册）：

- **F1 丢裸包名行** — 双端包的 patch 必须以裸包名挂一行；去掉 = 浏览器半静默消失、宿主半一切正常（`dual-client.md`）。
- **F3 build 不自包含** — `link:` 安装不装被链包的依赖，必须内联的依赖要打进产物；内联 CJS 无 `createRequire` banner → 求值即抛 `Dynamic require of … is not supported`（`build.md`）。
- **F12 验证姿势** — `pnpm build` 绿 ≠ 可装载；`--dump-config` 只证明注册行，`--dump-config-schema` 才真实 import（`verify-install.md`）。
- **F13 双端验收错位** — `--dump-config` 不跑 client-module scan，双端包它只能证明裸包名载体行在位；scan 证据要重启后看启动图 / 设置 → 插件列表（`dual-client.md` §4、`verify-install.md` §1）。
- 旁例 **F8** — openspec 生成的 SKILL.md 常带 `allowed-tools` / `license` / `compatibility`；DSH 只认 `name` / `description` 与 4 个可选键，这些键不解析、不生效。
