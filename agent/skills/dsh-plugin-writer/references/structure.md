# 结构与必改清单（structure）

> 本册是 `dsh-plugin-writer` 的分册①。**何时读**：用 `pnpm gen:plugin` 起新插件骨架、逐字段核对 / 改写 `package.json` / `cordis.patch.yml`，或判断该走哪条模板路线时。构建与产物问题 → `build.md`；双端声明形状 → `dual-client.md`；安装、验证与排障 → `verify-install.md`；选型决策树与生命周期见 `../SKILL.md` §2 与 §5。
>
> **路径约定**：不带前缀的路径相对 `/home/xuqinqin/develop/person/dsh-plugins`；`dsh-*` 开头的官方包位于 `/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/`。行号是该文件**当前**的行号——源码会漂，**指路以文件为准**，行号只用来快速落位。
>
> **本册不复述源码注释**：模板里的头注释是「为什么这样写」的第一手材料，去读原文。本册只给「改哪里 + 不改会怎样 + 增量」，且**不写任何版本数字**——版本只认 `scripts/dsh-baseline.mjs`，统一版本只认发布流程。

## 1. 三条模板路线与件套

| 路线 | 生成方式 / 模板（本仓相对路径） | 件套 | 构建入口 | 测试目录 | 版本契约 |
|---|---|---|---|---|---|
| host-only 软插件 | `pnpm gen:plugin <name> --kind host-only`；成品对照 `plugins/zcode-plan`（更小的服务型：`plugins/project-mcp`） | `package.json`、`cordis.patch.yml`、`build.mjs`（薄入口）、`tsconfig.json` + `tsconfig.host.json`、`vitest.config.ts`、`src/index.ts`、`test/smoke.test.ts`、`README.md` | `build-kit` 薄入口 | `test/` | `dsh.engines.dsh` + DSH peer 由基线派生 |
| 双端软插件 | `pnpm gen:plugin <name> --kind dual`；成品对照 `plugins/session-tool-toggle`（另有 `plugins/web-ux`） | host-only 全套 + `tsconfig.client.json` + `src/client/index.ts` + `dsh.client` + `exports "./client"`；本地**不放** `.oxlintrc.json` | `build-kit` 薄入口（host + client 两段） | `test/` | 同上；浏览器半渲染 React 才另加 `react` peer |
| 特例 | 既有路线，不从生成器走：`plugins/multi-root-workspace` | 同上但**无** `build.mjs`；多 `tsconfig.host.json` / `tsconfig.client.json` / `scripts/` / `docs/` | `tsc` 产类型 + `tsdown`（`tsdown.config.ts`） | `tests/`（复数） | 精确 allowlist，三处落点（§6） |

- **不可省的三件**：`package.json`（含 `dsh.bundle.patch`）、`cordis.patch.yml`、构建入口（软插件为 `build.mjs` 薄入口，特例为 `tsdown.config.ts`）。缺任一件，安装链会静默少一层（§3）。
- **编译基准只有根一份**：不再有本地 `tsconfig.base.json`；各包 tsconfig 只 `extends` 根 `tsconfig.plugin.base.json` + `include` 差异，不重声明编译选项、不带 `composite`（AR5 会拦）。
- **目录名 → 包名**：`plugins/<目录名>/package.json` 的 `name` 必须是 `dsh-plugin-<目录名>`（三模板实例：`plugins/zcode-plan/package.json:2`、`plugins/session-tool-toggle/package.json:2`、`plugins/multi-root-workspace/package.json:2`）。patch 行的 `name`、Web client-module scan、`dsh plugin remove <包名>` 全按它对齐。
- **`tsconfig.host.json` 的 `include` 按本包目录改写**：模板带 `src/host`，单文件包没有该目录（`plugins/zcode-plan/tsconfig.host.json:4-9`）；`tsc` 对不存在的 include 静默通过，留着只是指向空路径的脏配置。
- **不要手工复制现有插件**：生成器只带冒烟测试与模板 README；若确实从旧插件抄，必须删业务脚本 / 组件 / 文档 / 业务单测，别改名留着。multi-root 整包不要当模板（见 §6）。
- 判定不了形态时，回退官方三篇开发文档（入口见 `README.md`「插件开发文档（官方）」节），不要硬套模板。

### 1.1 `src/index.ts` 入口形状

件套只列文件，入口形状去模板源码读。最小组装：

- loader 从**包入口**只读 `name` / `inject` / `Config` / `apply` 四个符号（`plugins/zcode-plan/src/index.ts:5-7`）——多文件包的 `src/index.ts` 只做形状转发（`plugins/zcode-plan/src/index.ts:13`、`plugins/project-mcp/src/index.ts:14`）；单文件包直接写实现，不需要 `src/host/index.ts` 转发层。
- `name` 是短 id（= patch 行的 `id`，如 `project-mcp`），**不是 npm 包名**，只用于 loader 诊断（`plugins/zcode-plan/src/host/index.ts:62-63`、`plugins/project-mcp/src/host/index.ts:54`）。
- `inject`：无硬依赖写空数组常量（`plugins/zcode-plan/src/host/index.ts:72` 的 `readonly string[] = []`，可选能力走 `ctx.inject([...])` 软接入）；有硬依赖写服务名数组（`plugins/project-mcp/src/host/index.ts:60`）。
- `Config`：可选。没有配置项就不导出（`plugins/project-mcp/src/index.ts:14` 只有三件套）；不导出时 `--dump-config-schema` 该行 `status: "absent"` 是正常态（`build.md` §9）。
- 载体行可以是空实现：`apply()` 什么都不做，只为让裸包名行有东西可挂（`plugins/multi-root-workspace/src/index.ts:113`）。

## 2. `package.json` 逐字段改写表

锚点列是三模板**各自**文件内的行号（`z` = `plugins/zcode-plan`，`s` = `plugins/session-tool-toggle`，`m` = `plugins/multi-root-workspace`）。

| 字段 | 三模板锚（z / s / m） | 新插件怎么填 | 漏了 / 写错的后果 |
|---|---|---|---|
| `name` | `:2` / `:2` / `:2` | `dsh-plugin-<目录名>` | patch 行、client scan、`remove` 对不上 |
| `description` | `:3` / `:3` / `:3` | 本插件一句话，中英文都行 | 只影响 loader 诊断与 `plugin` 列表可读性 |
| `version` | `:4` / `:4` / `:4` | 见 §5（生成器取根版本，`release` 统一同步） | 手写单包版本 = 与 tag 漂移 |
| `type` | `:5` / `:6` / `:5` | 保持 `"module"` | 源码与 `lib/` 的 ESM 解释错 |
| `engines.node` | `:6-8` / `:7-9` / `:90-92` | 取模板值，不自己编 | 与宿主 Node 下限不一致 |
| `main` | `:9` / `:10` / `:6` | `lib/index.js` | 宿主半入口缺失 |
| `exports["."]` | `:10-14` / `:11-14` / `:8-12` | 指向 `./lib/index.js` | loader 按包名解析不到模块（启动即失败） |
| `exports["./client"]` | 无 / `:15-17` / `:41-44` | 双端才有，指向 `./lib/client.js` | 浏览器半没有入口（细节 `dual-client.md`） |
| 其它 `exports` 子路径 | 无 / `:18-19` / `:13-61` | 只有真要多入口才加；子路径行**不是** client 行。双端模板另带 `"./package.json"`（scan 回退解析用，见 `dual-client.md` §2） | 多挂行却少写 `exports` = 解析失败 |
| `dsh.engines.dsh` | `:16-18` / `:22-24` / **无** | 由 `softDshRange()` 派生，不手写（`build.md` §8） | `dsh:check` 基线组直接失败 |
| `dsh.bundle.patch` | `:19-21` / `:25-27` / `:218-220` | `"./cordis.patch.yml"` | 装上不激活 patch 层（F2） |
| `dsh.client` | 无 / `:28-38` / `:221-229` | 双端：`platform: "web"` + `inject` 列表 | 浏览器半静默消失（`dual-client.md`） |
| `files` | `:23-27` / `:39-44` / `:63-71` | 必含 `cordis.patch.yml` 与产物（软插件模板写 `lib/**/*.js`，已覆盖双端 `lib/client.js`；特例是显式清单，逐项列全）；`icon` 若声明必须在内 | git/tag 安装按 pack 落盘，缺文件即装坏（F2） |
| `license` | `:28` / `:45` / `:93` | 按本仓政策填（三模板之间不同，别照抄特例） | 只影响发布合规 |
| `peerDependencies` | `:29-31` / `:46-49` / `:94-116` | 软插件与 `dsh.engines.dsh` 同值；浏览器半渲染 React 才加 `react` peer（不渲染不加）；特例走精确枚举（§6） | 版本声明漂移即被 `dsh:check` 拦 |
| `dependencies` | 无 / `:50-52` / `:231-235` | 只放运行期真依赖；该内联还是外置见 `build.md` §1 | 误把官方子包放进来 = 实例分叉 |
| `devDependencies` | `:32-43` / `:53-84` / `:165-216` | 一律 `catalog:` / `catalog:dsh` / `workspace:*`；DSH 项至少一个且归一化后等于基线，工具链对照根 `catalog` 册 | 字面量版本 = 基线组失败 / 绕过工具链册 |
| `scripts` | `:44-54` / `:86-93` / `:72-89` | 生成器写全 `build` / `lint` / `test` / `typecheck` / `verify:all` / `prepack`（AR3 比对模板值；附加脚本允许） | `verify:all` 缺段 = 发布前自检失真 |
| 测试目录名 | `test/` / `test/` / `tests/` | host-only 与双端用 `test/`；特例用 `tests/` | 抄错目录名，`vitest run` 找不到用例 |

- `verify:all` 的四段顺序固定为 lint → typecheck → build → test（见任一软插件 `package.json` 的 `scripts.verify:all`）；特例还追加 `kernel:probe` 与 `smoke`（`plugins/multi-root-workspace/package.json` 的 `scripts.verify:all`）。
- `files` 白名单是**白名单**不是黑名单：新增运行期文件（如 `README`、`LICENSE`、`lib/types/**`）必须显式加进去，否则 tag 安装拿不到。
- `devDependencies` 的两条硬约束：每个插件**至少**声明一个 `@deepseek-ai/dsh*` 开发依赖，且全仓 `@deepseek-ai/cordis` 只能有一个版本（`scripts/check-dsh-baseline.mjs` 的基线组断言）。
- **反例（版本字面量）**：在 `devDependencies` 写 `"typescript": "^5.9.0"` 或 `"@deepseek-ai/dsh": "0.2.2-rc.1"`——前者绕过根 `catalog` 工具链册，后者会被基线组拦（要求引用 `catalog:dsh`）。统一写 `catalog:` / `catalog:dsh` / `workspace:*`。

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

- patch 是 **bundle patch**：由 `package.json` 的 `dsh.bundle.patch` 字段声明，`dsh plugin add` 把声明了 `dsh.bundle` 的包追加进 `dsh.profile.bundles` 来激活（见 `README.md`「装入 profile」节）。因此 `files` 漏掉 `cordis.patch.yml` = tag/git 安装「装了不生效」。
- 三模板的 patch 都只有一层 `insert:` 列表（特例多一个 `disabled` 头）；不要手写别的 patch 语法——patch 层语法由 DSH 决定，本仓只在 `package.json` 里声明入口。
- 双端包的「裸包名行 REQUIRED、去掉 = 浏览器半静默消失」的因果与自检方法，见 `dual-client.md`，本册只保证行形态正确。

## 4. 头注释逐项改写表

头注释是复制后的高发错误区：照抄会把「双端 / host-only」「带不带 profile config」这类**形态事实**写反，后来者按错的注释排障。薄入口的注释只解释旋钮；形态事实以 `package.json` / `cordis.patch.yml` 为准。

| 注释位置 | 这段注释在讲什么（去读原文） | 复制后必须改 |
|---|---|---|
| `tooling/template/build.mjs` | 薄入口范文：策略全部在 build-kit，本文件只声明 `hostExternals` / `cjsRequireShim` / `cssClassPrefix` | 按本包形态改旋钮；不要展开 esbuild 配置，也不要从旧插件抄 `build.mjs` |
| `tooling/build-kit/src/{host,client,css,guards}.mjs` | 构建策略与产物守卫的原理注释（banner、ModuleLoader 壳、CSS 作用域、自包含判定） | 一般不改；行为不符先读 `tooling/build-kit/README.md`，不要就地改 kit |
| `plugins/project-mcp/build.mjs` | 薄入口 + 「某个官方子包刻意不进产物」的例外理由 | 只有确实需要「与宿主同实例」时才抄这段（判据见 `build.md` §4） |
| `plugins/multi-root-workspace/tsdown.config.ts:1-16` | 两个构建面 + 生产包外置的理由 | 特例路线才用；普通插件别抄 |
| `plugins/zcode-plan/cordis.patch.yml:1-9` | 这是 bundle patch、按包名的裸插件、不声明 client、profile 级不带 config | 逐句改写成本包事实 |
| `plugins/session-tool-toggle/cordis.patch.yml:1-14` | 同上 + 裸包名行 REQUIRED 的因果 | 同上；双端包保留这条因果说明 |
| `plugins/multi-root-workspace/cordis.patch.yml:1-29` | disable-before-insert、compat 行置首、client 载体行的理由 | 特例外不要抄；要用时逐条对上本包的 provider / gate 事实 |

## 5. `version` 与其它易错项

- **生成器写什么**：`version` 取根 `package.json` 的版本（= 当前 tag），这是唯一正常起点；演练 / 未发布包可临时用 `0.0.0`，但入库前必须交给 `release` 统一。依据是仓库级门禁不查单包版本统一——`pnpm dsh:check` 的三组门禁都不涉及这一项，版本统一由发布流程保证。
- **正式入库**：`version` 恒等于**当前 tag**；约定与各包版本的统一写入都在 `scripts/release.mjs`。不要手改单包版本——`release` 会统一改写并重建产物。
- 目录名与包名之外，以下三项最容易抄错：
  - 测试目录：软插件 `test/`，特例 `tests/`（§1）。
  - `icon`：声明了就必须进 `files`（`plugins/session-tool-toggle/package.json` 的 `icon` 与 `files`）。
  - `license`：模板之间不同（特例与软插件不同），按本仓政策填，别照抄特例。
- 业务残留（脚本 / 组件 / 文档 / 业务用例）在从旧插件抄件时逐项删；`SKILL.md` §4 第 7 项是这条的一行版。

## 6. `multi-root` 特例：三处落点与构建入口

- **何时才选它**：替换上游 provider、需要精确版本 allowlist、或带原生依赖（`../SKILL.md` §2）。普通插件选它 = 整包继承原生依赖、精确 peer 枚举与 compat gate。
- **三处落点，只改一处必不一致**：
  1. 枚举常量：`plugins/multi-root-workspace/src/compat/dsh-version.ts:34`（精确版本数组，刻意不用范围）。
  2. 精确 peer 枚举：`plugins/multi-root-workspace/package.json:94-116`（同一组版本用 `||` 串起）+ 可选依赖标注 `peerDependenciesMeta` `:118-164`。
  3. 启动 gate：`plugins/multi-root-workspace/src/compat.ts:107-123`（不在 allowlist 直接抛错），由 `apply` 在 `:130-135` 调用；patch 把 compat 行放在最前（`plugins/multi-root-workspace/cordis.patch.yml:35-40`），保证其余行不会在未验证的安装上启动。
- **没有 `dsh.engines.dsh`**：`plugins/multi-root-workspace/package.json:217-229` 的 `dsh` 只有 `bundle` 与 `client`，兼容性判定在代码里（上条三处落点）。
- **构建入口不是 `build.mjs`**：`tsdown.config.ts` + `plugins/multi-root-workspace/package.json` 的 `scripts.build` / `build:types` / `bundle`（类型与打包两段，bundle 前先 clean）。external 策略、client 壳形状见 `build.md` §1 与 §5。
- **别造第二个 hard 插件**：`dsh:check` 按 `src/compat/dsh-version.ts` 是否存在分 hard/soft；`scripts/check-dsh-baseline.mjs` 要求 hard **恰有一个**，`scripts/check-architecture.mjs` 对软插件套 AR3–AR6。新插件默认走 soft 路线。

## 7. 交接：其余问题去哪

| 问题 | 分册 |
|---|---|
| `dsh.client` / `exports "./client"` / 裸包名行因果 / 浏览器半 CJS 壳 | `dual-client.md` |
| bundle 还是 external、`createRequire` banner、`ctx.loader.import`、`lib/` 入库、`allowBuilds`、engines 派生 | `build.md` |
| 装进 profile、`--dump-config-schema` 读到什么、卸载残留、schema 噪音、`skill:` 假故障 | `verify-install.md` |
| 该不该用这个 skill、选哪条路线、发布与升级 | `../SKILL.md` 与 `AGENTS.md` |
