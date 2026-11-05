# 结构与必改清单（structure）

> 本册是 `dsh-plugin-writer` 的分册①。**何时读**：在 `plugins/` 下起新插件骨架、复制模板件套、逐字段改写 `package.json` / `cordis.patch.yml`，或判断该抄哪条模板路线时。构建与产物问题 → `build.md`；双端声明形状 → `dual-client.md`；安装、验证与排障 → `verify-install.md`；选型决策树与生命周期见 `../SKILL.md` §2 与 §5。
>
> **路径约定**：不带前缀的路径相对 `/home/xuqinqin/develop/person/dsh-plugins`；`dsh-*` 开头的官方包位于 `/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/`。行号是该文件**当前**的行号——源码会漂，**指路以文件为准**，行号只用来快速落位。
>
> **本册不复述源码注释**：模板里的头注释是「为什么这样写」的第一手材料，去读原文。本册只给「改哪里 + 不改会怎样 + 增量」，且**不写任何版本数字**——版本只认 `scripts/dsh-baseline.mjs`，统一版本只认发布流程。

## 1. 三条模板路线与件套

| 路线 | 模板（本仓相对路径） | 件套 | 构建入口 | 测试目录 | 版本契约 |
|---|---|---|---|---|---|
| host-only 软插件 | `plugins/zcode-plan`（更小的服务型：`plugins/project-mcp`） | `package.json`、`cordis.patch.yml`、`build.mjs`、`tsconfig*.json`、`vitest.config.ts`、`src/index.ts`、`test/` | esbuild `build.mjs` | `test/` | `dsh.engines.dsh` + DSH peer 由基线派生 |
| 双端软插件 | `plugins/session-tool-toggle`（另有 `plugins/web-ux`） | 同上 + `.oxlintrc.json`（`session-tool-toggle` 有；`web-ux` 与 host-only 模板无）+ `src/client/` + `dsh.client` + `exports "./client"` | `build.mjs`（host + client 两段） | `test/` | 同上；浏览器半渲染 React 才另加 `react` peer |
| 特例 | `plugins/multi-root-workspace` | 同上但**无** `build.mjs`；多 `tsconfig.host.json` / `tsconfig.client.json` / `scripts/` / `docs/` | `tsc` 产类型 + `tsdown`（`tsdown.config.ts`） | `tests/`（复数） | 精确 allowlist，三处落点（§6） |

- **不可省的三件**：`package.json`（含 `dsh.bundle.patch`）、`cordis.patch.yml`、构建入口（`build.mjs`，特例为 `tsdown.config.ts`）。缺任一件，安装链会静默少一层（§3）。
- **目录名 → 包名**：`plugins/<目录名>/package.json` 的 `name` 必须是 `dsh-plugin-<目录名>`（三模板实例：`plugins/zcode-plan/package.json:2`、`plugins/session-tool-toggle/package.json:2`、`plugins/multi-root-workspace/package.json:2`）。patch 行的 `name`、Web client-module scan、`dsh plugin remove <包名>` 全按它对齐。
- **`tsconfig.host.json` 的 `include` 按本包目录改写**：模板带 `src/host`，单文件包没有该目录（`plugins/zcode-plan/tsconfig.host.json:4-9`）；`tsc` 对不存在的 include 静默通过，留着只是指向空路径的脏配置。
- **复制杂质清单**（复制后逐项删，别改名留着）：zcode-plan 的 `scripts/`、`docs/`、业务单测；session-tool-toggle 的面板组件与样式；multi-root 整包不要当模板（见 §6）。
- 判定不了形态时，回退官方三篇开发文档（入口见 `README.md:84-88`），不要硬套模板。

### 1.1 `src/index.ts` 入口形状

件套只列文件，入口形状去模板源码读。最小组装：

- loader 从**包入口**只读 `name` / `inject` / `Config` / `apply` 四个符号（`plugins/zcode-plan/src/index.ts:5-7`）——多文件包的 `src/index.ts` 只做形状转发（`plugins/zcode-plan/src/index.ts:13`、`plugins/project-mcp/src/index.ts:14`）；单文件包直接写实现，不需要 `src/host/index.ts` 转发层。
- `name` 是短 id（= patch 行的 `id`，如 `project-mcp`），**不是 npm 包名**，只用于 loader 诊断（`plugins/zcode-plan/src/host/index.ts:62-63`、`plugins/project-mcp/src/host/index.ts:47-48`）。
- `inject`：无硬依赖写空数组常量（`plugins/zcode-plan/src/host/index.ts:72` 的 `readonly string[] = []`，可选能力走 `ctx.inject([...])` 软接入）；有硬依赖写服务名数组（`plugins/project-mcp/src/host/index.ts:51`）。
- `Config`：可选。没有配置项就不导出（`plugins/project-mcp/src/index.ts:14` 只有三件套）；不导出时 `--dump-config-schema` 该行 `status: "absent"` 是正常态（`build.md` §9）。
- 载体行可以是空实现：`apply()` 什么都不做，只为让裸包名行有东西可挂（`plugins/multi-root-workspace/src/index.ts:110-112`）。

## 2. `package.json` 逐字段改写表

锚点列是三模板**各自**文件内的行号（`z` = `plugins/zcode-plan`，`s` = `plugins/session-tool-toggle`，`m` = `plugins/multi-root-workspace`）。

| 字段 | 三模板锚（z / s / m） | 新插件怎么填 | 漏了 / 写错的后果 |
|---|---|---|---|
| `name` | `:2` / `:2` / `:2` | `dsh-plugin-<目录名>` | patch 行、client scan、`remove` 对不上 |
| `description` | `:3` / `:3` / `:3` | 本插件一句话，中英文都行 | 只影响 loader 诊断与 `plugin` 列表可读性 |
| `version` | `:4` / `:4` / `:4` | 见 §5（演练包用占位，正式入库等发布同步） | 手写单包版本 = 与 tag 漂移 |
| `type` | `:5` / `:6` / `:5` | 保持 `"module"` | 源码与 `lib/` 的 ESM 解释错 |
| `engines.node` | `:6-8` / `:7-9` / `:90-92` | 取模板值，不自己编 | 与宿主 Node 下限不一致 |
| `main` | `:9` / `:10` / `:6` | `lib/index.js` | 宿主半入口缺失 |
| `exports["."]` | `:10-14` / `:11-14` / `:8-12` | 指向 `./lib/index.js` | loader 按包名解析不到模块（启动即失败） |
| `exports["./client"]` | 无 / `:15-17` / `:41-44` | 双端才有，指向 `./lib/client.js` | 浏览器半没有入口（细节 `dual-client.md`） |
| 其它 `exports` 子路径 | 无 / `:18-19` / `:13-61` | 只有真要多入口才加；子路径行**不是** client 行。双端模板另带 `"./package.json"`（scan 回退解析用，见 `dual-client.md` §2） | 多挂行却少写 `exports` = 解析失败 |
| `dsh.engines.dsh` | `:16-18` / `:22-24` / **无** | 由 `softDshRange()` 派生，不手写（`build.md` §8） | `dsh:check` 断言 3 直接失败 |
| `dsh.bundle.patch` | `:19-21` / `:25-27` / `:218-220` | `"./cordis.patch.yml"` | 装上不激活 patch 层（F2） |
| `dsh.client` | 无 / `:28-38` / `:221-229` | 双端：`platform: "web"` + `inject` 列表 | 浏览器半静默消失（`dual-client.md`） |
| `files` | `:23-27` / `:40-45` / `:63-71` | 必含 `cordis.patch.yml` 与产物（软插件模板写 `lib/**/*.js`，已覆盖双端 `lib/client.js`；特例是显式清单，逐项列全）；`icon` 若声明必须在内 | git/tag 安装按 pack 落盘，缺文件即装坏（F2） |
| `license` | `:28` / `:46` / `:93` | 按本仓政策填（三模板之间不同，别照抄特例） | 只影响发布合规 |
| `peerDependencies` | `:29-31` / `:47-50` / `:94-116` | 软插件与 `dsh.engines.dsh` 同值；浏览器半渲染 React 才加 `react` peer（不渲染不加）；特例走精确枚举（§6） | 版本声明漂移即被 `dsh:check` 拦 |
| `dependencies` | 无 / `:51-53` / `:231-235` | 只放运行期真依赖；该内联还是外置见 `build.md` §1 | 误把官方子包放进来 = 实例分叉 |
| `devDependencies` | `:32-43` / `:54-84` / `:165-216` | DSH 相关项必须存在且等于基线（至少一个，否则断言 2 直接失败）；工具链按需照抄 | 手写 pin = 断言 2 失败、`pnpm install` 混装 |
| `scripts` | `:44-54` / `:85-92` / `:72-89` | 至少 `build` / `lint` / `test` / `typecheck` / `verify:all` / `prepack` | `verify:all` 缺段 = 发布前自检失真 |
| 测试目录名 | `test/` / `test/` / `tests/` | host-only 与双端用 `test/`；特例用 `tests/` | 抄错目录名，`vitest run` 找不到用例 |

- `verify:all` 的四段顺序在模板里固定为 lint → typecheck → build → test（`plugins/zcode-plan/package.json:52`、`plugins/session-tool-toggle/package.json:90`）；特例还追加 `kernel:probe` 与 `smoke`（`plugins/multi-root-workspace/package.json:87`）。
- `files` 白名单是**白名单**不是黑名单：新增运行期文件（如 `README`、`LICENSE`、`lib/types/**`）必须显式加进去，否则 tag 安装拿不到。
- `devDependencies` 的两条硬约束：每个插件**至少**声明一个 `@deepseek-ai/dsh*` 开发依赖（`scripts/check-dsh-baseline.mjs:170`），且全仓 `@deepseek-ai/cordis` 只能有一个版本（`:175-178`）。

## 3. `cordis.patch.yml` 逐项改写

| 位置 | 三模板锚（z / s / m） | 改写要点 |
|---|---|---|
| 头注释块 | `:1-9` / `:1-14` / `:1-29` | 必改。写清本包是什么、是否双端、profile 级是否带 `config`、有无 `disabled` 前置行（见 §4） |
| 顶层 `insert:` | `:10` / `:15` / `:34` | 保持列表形态；特例路线在 `insert` 之前另有 `disabled` 行 |
| 每行 `id` | `:11` / `:16` / `:39`、`:87` | 惯例是去掉 `dsh-plugin-` 前缀的短名；`/tools`、`--dump-config` 输出与排障日志都靠它定位，改名=排障线索断 |
| 每行 `name` | `:12` / `:17` / `:88` | **裸包名**（不带子路径）。双端包的裸包名行是 client-module scan 的唯一载体（`plugins/session-tool-toggle/cordis.patch.yml:5-12`；`plugins/multi-root-workspace/cordis.patch.yml:25-29` 与载体行 `:87-88`） |
| 行级 `config:` | 无（`:8-9` 声明不带） / 无（`:14` 声明不带） / `:47-69`、`:75-78` | 必填项由 profile 安装行的 `config:` 提供，插件 schema 给默认值。照抄「不带 config」的注释前，先确认你的必填项真有来源 |
| `disabled: true` 前置 | 无 / 无 / `:30-33` | 只在替换上游 provider 时需要，且必须排在我们的行**之前**（否则服务键重复注册直接抛） |
| 子路径注册行 | 无 / 无 / `:39-86` | 一个包挂多行时用 `<包名>/<subpath>`；这类行永远不是 client 行 |

- patch 是 **bundle patch**：由 `package.json` 的 `dsh.bundle.patch` 字段声明，`dsh plugin add` 把声明了 `dsh.bundle` 的包追加进 `dsh.profile.bundles` 来激活（`README.md:47`）。因此 `files` 漏掉 `cordis.patch.yml` = tag/git 安装「装了不生效」。
- 三模板的 patch 都只有一层 `insert:` 列表（特例多一个 `disabled` 头）；不要手写别的 patch 语法——patch 层语法由 DSH 决定，本仓只在 `package.json` 里声明入口。
- 双端包的「裸包名行 REQUIRED、去掉 = 浏览器半静默消失」的因果与自检方法，见 `dual-client.md`，本册只保证行形态正确。

## 4. 头注释逐项改写表

头注释是复制后的高发错误区：照抄会把「双端 / host-only 」「带不带 profile config」这类**形态事实**写反，后来者按错的注释排障。

| 注释位置 | 这段注释在讲什么（去读原文） | 复制后必须改 |
|---|---|---|
| `plugins/zcode-plan/build.mjs:1-12` | host-only 单产物：入口、只外置什么、哪个依赖为何必须内联、为何不产类型与 map | 改成你包的形态；浏览器半相关段落删干净 |
| `plugins/session-tool-toggle/build.mjs:1-23` | 双端两段产物 + 内联 CJS 的 banner 原理 | 双端才保留两段；改包名与 externals 清单，单端删掉浏览器半段 |
| `plugins/project-mcp/build.mjs:1-19` | 第三种：host-only，但某个官方子包刻意不进产物 | 只有确实需要「与宿主同实例」时才抄这段（判据见 `build.md` §4） |
| `plugins/multi-root-workspace/tsdown.config.ts:1-16` | 两个构建面 + 生产包外置的理由 | 特例路线才用；普通插件别抄 |
| `plugins/zcode-plan/cordis.patch.yml:1-9` | 这是 bundle patch、按包名的裸插件、不声明 client、profile 级不带 config | 逐句改写成本包事实 |
| `plugins/session-tool-toggle/cordis.patch.yml:1-14` | 同上 + 裸包名行 REQUIRED 的因果 | 同上；双端包保留这条因果说明 |
| `plugins/multi-root-workspace/cordis.patch.yml:1-29` | disable-before-insert、compat 行置首、client 载体行的理由 | 特例外不要抄；要用时逐条对上本包的 provider / gate 事实 |

## 5. `version` 与其它易错项

- **演练包 / 未发布包**：`version` 用 `0.0.0`。依据是仓库级门禁不查版本统一——`scripts/check-dsh-baseline.mjs:8-14` 的七断言只覆盖基线常量、DSH pin、软插件派生范围、allowlist、安装树、发布年龄豁免、残留引用。
- **正式入库**：`version` 恒等于**当前 tag**；约定在 `scripts/release.mjs:10-15`，各包版本的统一写入在 `:130-140`。不要手改单包版本——`release` 会统一改写并重建产物。
- 目录名与包名之外，以下三项最容易抄错：
  - 测试目录：host-only / 双端 `test/`，特例 `tests/`（§1）。
  - `icon`：声明了就必须进 `files`（`plugins/session-tool-toggle/package.json:5` + `:40-45`）。
  - `license`：模板之间不同（特例与软插件不同），按本仓政策填，别照抄特例。
- 模板业务残留（脚本 / 组件 / 文档 / 业务用例）在复制后逐项删；`SKILL.md` §4 第 7 项是这条的一行版。

## 6. `multi-root` 特例：三处落点与构建入口

- **何时才选它**：替换上游 provider、需要精确版本 allowlist、或带原生依赖（`../SKILL.md` §2）。普通插件选它 = 整包继承原生依赖、精确 peer 枚举与 compat gate。
- **三处落点，只改一处必不一致**：
  1. 枚举常量：`plugins/multi-root-workspace/src/compat/dsh-version.ts:34`（精确版本数组，刻意不用范围）。
  2. 精确 peer 枚举：`plugins/multi-root-workspace/package.json:94-116`（同一组版本用 `||` 串起）+ 可选依赖标注 `peerDependenciesMeta` `:118-164`。
  3. 启动 gate：`plugins/multi-root-workspace/src/compat.ts:107-123`（不在 allowlist 直接抛错），由 `apply` 在 `:130-135` 调用；patch 把 compat 行放在最前（`plugins/multi-root-workspace/cordis.patch.yml:35-40`），保证其余行不会在未验证的安装上启动。
- **没有 `dsh.engines.dsh`**：`plugins/multi-root-workspace/package.json:217-229` 的 `dsh` 只有 `bundle` 与 `client`，兼容性判定在代码里（上条三处落点）。
- **构建入口不是 `build.mjs`**：`tsdown.config.ts` + `plugins/multi-root-workspace/package.json:73`（类型与打包两段）、`:75`（bundle 前先 clean）。external 策略、client 壳形状见 `build.md` §1 与 §5。
- **别造第二个 hard 插件**：`dsh:check` 按 `src/compat/dsh-version.ts` 是否存在分 hard/soft（`scripts/check-dsh-baseline.mjs:149-154`），并要求 hard **恰有一个**（`:153`）。新插件默认走 soft 路线。

## 7. 交接：其余问题去哪

| 问题 | 分册 |
|---|---|
| `dsh.client` / `exports "./client"` / 裸包名行因果 / 浏览器半 CJS 壳 | `dual-client.md` |
| bundle 还是 external、`createRequire` banner、`ctx.loader.import`、`lib/` 入库、`allowBuilds`、engines 派生 | `build.md` |
| 装进 profile、`--dump-config-schema` 读到什么、卸载残留、schema 噪音、`skill:` 假故障 | `verify-install.md` |
| 该不该用这个 skill、选哪条路线、发布与升级 | `../SKILL.md` 与 `AGENTS.md` |
