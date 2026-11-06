---
name: dsh-plugin-writer
description: >-
  Use when 在 dsh-plugins 仓（/home/xuqinqin/develop/person/dsh-plugins）新增、脚手架或结构性修改 DSH 插件——搭建插件工程骨架、选 host-only/双端形态、写 package.json/cordis.patch.yml/build.mjs、执行构建验证、link: 装入 profile 验证时使用；触发词：插件、plugin、新增插件、bundle、cordis.patch、dump-config-schema。文案小改、发布流程、profile 内一次性 bundle 不适用。
---

# DSH 插件撰写（dsh-plugins 仓）

> 下文路径一律相对 `/home/xuqinqin/develop/person/dsh-plugins`（本 skill 的唯一锚点，不按 cwd 猜仓库）；命令里的 `$REPO` 即该路径。

## 1. 适用判定与分工

**适用于**：在本仓 `plugins/` 下新增插件（用 `pnpm gen:plugin` 起工程骨架）、或对已有插件做结构性修改（形态 / 入口 / 构建 / 声明 / 安装链）。

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

> 三种形态里，host-only 与双端都从 `templates/default/` 生成（`pnpm gen:plugin <name> --kind host-only|dual`），件套差异只剩 `--kind`；特例 multi-root 是既有路线，不是新插件模板、不走生成器。

`multi-root-workspace` 只为「必须替换上游 provider 或要精确版本门禁」而选；普通插件以它为模板会整包继承上一代杂质（原生依赖、精确 peer 枚举、compat gate）。

## 3. 模板插件对照表

| 形态 | 生成方式 / 模板 | 构建入口 | 版本契约 | 与 host-only 的差集 | 主要失败面 |
|---|---|---|---|---|---|
| host-only（只加命令 / 工具 / 服务） | `pnpm gen:plugin <name> --kind host-only`；成品对照 `plugins/zcode-plan`（更小：`plugins/project-mcp`） | `build-kit` 薄入口（约 3–5 行） | 软：由基线脚本派生 | — | F3 自包含、F4 产物未重建 |
| 双端（多一个浏览器半） | `pnpm gen:plugin <name> --kind dual`；成品对照 `plugins/session-tool-toggle` | `build-kit` 薄入口（host + client 两段） | 软：同左；浏览器半渲染 React 才另加 `react` peer | `dsh.client` + `exports "./client"` + `lib/client.js` 壳 | F1 丢裸包名行（浏览器半静默消失） |
| 特例（替换 provider / 精确门禁 / 原生依赖） | 既有路线，不从生成器走：`plugins/multi-root-workspace` | `tsc` 类型 + `tsdown`（**无** `build.mjs`） | 精确 allowlist，三处落点同源 | 精确 peer 枚举、`peerDependenciesMeta`、`allowBuilds` | 漏版本即启动抛错、原生依赖未表态 |

## 4. 必改清单：生成器已代劳 vs 仍需手工（7 项）

`pnpm gen:plugin` 已把骨架事实写成终态。逐项核对左栏；要动手的只有右栏，左栏有偏差时先查生成器 / 模板版本，不要手写覆盖。

| # | 生成器已代劳（核对即可） | 仍需手工 |
|---|---|---|
| 1 | 目录名与 `name` = `dsh-plugin-<目录名>`；`description` 有占位文案 | `description` 换成本插件一句话 |
| 2 | `version` 取根 `package.json`（= 当前 tag，`release` 统一同步） | 演练 / 未发布包可临时 `0.0.0`，入库前交给 `release`（`structure.md` §5） |
| 3 | `cordis.patch.yml` 的 `insert:`、行 `id`、**裸包名** `name` | 头注释按本插件重写；双端 `dsh.client.inject` 按真实依赖填 |
| 4 | `files` 含 `cordis.patch.yml` 与产物：`lib/**/*.js`（已覆盖双端 `lib/client.js`）+ `src` | 新增运行期文件（`LICENSE` / `lib/types/**` 等）时逐项进白名单（漏文件 = git 安装缺件，F2） |
| 5 | `main` / `exports["."]`；双端自动补 `exports["./client"]` 与 `dsh.client` 骨架 | 只有真要多入口才加子路径；`"./package.json"` 按需带（`dual-client.md` §2） |
| 6 | `dsh.engines.dsh` + DSH peer 由 `softDshRange()` 现取现派生 | 禁止手写数值；升级走 `pnpm dsh:upgrade`（F5） |
| 7 | 薄 `build.mjs`、extends 根基准的 tsconfig、`catalog:` / `catalog:dsh` devDeps、冒烟测试 | 旋钮按包事实调（`hostExternals` / `cjsRequireShim` / `cssClassPrefix`）；删占位文案与示例残留 |

- 目录名约定：软插件用 `test/`，multi-root 特例用 `tests/`；`lib/` 是提交物而非临时产物。
- 入口形状（`src/index.ts` 的 `name` / `inject` / `Config` / `apply`）不在上表：最小导出集合与 `Config` 可省见 `references/structure.md` §1.1。

## 5. 生命周期步骤

1. 定形态（§2），读 `tooling/build-kit/README.md` 的「旋钮语义」与 `references/structure.md` §1 的件套清单；不要手工复制现有插件。
2. `pnpm gen:plugin <name> --kind host-only|dual`（`--help` 看用法，`--dry-run` 先看文件清单）。生成器只写文件、不跑 git / pnpm；默认模板 `templates/default/`，`--template <name>` 换用其他模板（模板目录 = `templates/<name>/`，须含 `template.json`；未知模板 exit 1）；host-only 与双端的件套差异由 `--kind` 决定。
3. 按 §4 右栏改写；版本类字段现取现派生，不从模板或文档抄。
4. `pnpm install`（新包进 workspace；只有带原生依赖才需在根 `pnpm-workspace.yaml` 表态）。
5. `pnpm --filter dsh-plugin-<name> verify:all`（lint → typecheck → build → test）。
6. `pnpm dsh:check`（聚合三组门禁：DSH 基线 / 结构不变式 AR1–AR7 / 产物契约 B1–B5；动态枚举 `plugins/*`）。
7. `docker exec dsh dsh plugin --profile web add "$REPO/plugins/<name>"`（本地路径 = `link:` 调试安装，改源码重启 profile 即生效）。
8. `docker exec dsh dsh --profile web --dump-config-schema` 退出 0 **或**基线对照无新增 error = 装载性通过（它真实 import 插件；既有 profile 行会让退出码恒非 0，退出非 0 先做基线对照再怀疑插件，见 `references/verify-install.md` §4.1）；`--dump-config` 只证明注册行进了合成树。

**止于安装验证**：发布（版本统一 / tag / push）不属本 skill，一句指路 `AGENTS.md`「发布与版本」；排障见 `references/verify-install.md`。

## 6. 真源指路表

| 要查什么 | 真源 |
|---|---|
| DSH 基线版本、软插件可安装范围 | `scripts/dsh-baseline.mjs`（`DSH_BASELINE` / `softDshRange()`）——仓内唯一版本常量，任何文档都不要抄数值 |
| 仓库约定、目录结构、开发命令 | `AGENTS.md`；安装 / 构建授权 / 插件一览见 `README.md` |
| 新插件脚手架与模板素材 | `scripts/gen-plugin.mjs`（`pnpm gen:plugin --help`）；多模板约定（目录定位 / 命名 / `template.json` schema / `--template` 契约 / 新增模板步骤）在 `templates/README.md`，default 模板件套表在 `templates/default/README.md` |
| 构建策略、薄入口旋钮 | `tooling/build-kit/README.md`；实现分在 `tooling/build-kit/src/{host,client,css,guards}.mjs` |
| 运行期共享内核（归属 / 监听 / 触发器 / 根枚举 / 日志） | `tooling/host-kit/README.md`（被内联进产物，产物零 `@dsh-plugins/` 词） |
| 三组门禁与聚合入口 | `scripts/dsh-check.mjs`；基线 `scripts/check-dsh-baseline.mjs`、结构不变式 `scripts/check-architecture.mjs`（AR1–AR7）、产物契约 `scripts/check-artifacts.mjs`（B1–B5） |
| 仓级 ADR（两套编号，引用必须带路径） | `docs/decisions/`（索引见 `docs/decisions/README.md`） |
| 官方插件开发文档（三篇） | `README.md` 末「插件开发文档（官方）」；DSH 源码与 API 在 `/usr/local/lib/node_modules/@deepseek-ai/dsh/`（各子包 `README.zh.md`） |
| 可直接对照的成品 | `plugins/zcode-plan`、`plugins/session-tool-toggle`、`plugins/project-mcp`、`plugins/web-ux`、`plugins/user-commands` |

维护：`pnpm dsh:upgrade` 后复验本 skill 引用的路径与命令，真源变了同步改分册——本 skill 只留路由，事实全部指向上述真源。

## 7. 分册路由与反例速查

| 分册 | 何时读 |
|---|---|
| `references/structure.md` | 逐字段对照（`package.json` / `cordis.patch.yml` / `src/index.ts` 入口形状）、必改清单全量、特例路线三落点 |
| `references/build.md` | build-kit 薄入口与旋钮、自包含与 external 判定、CJS banner、`lib/` 入库、`allowBuilds`、engines 派生 |
| `references/dual-client.md` | 双端选型与声明形状、裸包名行因果、浏览器半 CJS 壳 |
| `references/verify-install.md` | 命令链与证明强度分层、`/inventory` 核对、排障（卸载残留 / schema 噪音 / 假故障） |

反例速查（一行一条，展开见对应分册）：

- **F1 丢裸包名行** — 双端包的 patch 必须以裸包名挂一行；去掉 = 浏览器半静默消失、宿主半一切正常（`dual-client.md`）。
- **F3 build 不自包含** — `link:` 安装不装被链包的依赖，必须内联的依赖要打进产物；内联 CJS 无 `createRequire` banner → 求值即抛 `Dynamic require of … is not supported`（`build.md`）。
- **F12 验证姿势** — `pnpm build` 绿 ≠ 可装载；`--dump-config` 只证明注册行，`--dump-config-schema` 才真实 import（`verify-install.md`）。
- **F13 双端验收错位** — `--dump-config` 不跑 client-module scan，双端包它只能证明裸包名载体行在位；scan 证据要重启后看启动图 / 设置 → 插件列表（`dual-client.md` §4、`verify-install.md` §1）。
- 旁例 **F8** — openspec 生成的 SKILL.md 常带 `allowed-tools` / `license` / `compatibility`；DSH 只认 `name` / `description` 与 4 个可选键，这些键不解析、不生效。
