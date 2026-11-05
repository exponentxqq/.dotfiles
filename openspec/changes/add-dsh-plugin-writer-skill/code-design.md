# 代码级设计（阶段 1.7）——add-dsh-plugin-writer-skill：dsh-plugin-writer skill

- 变更名：`add-dsh-plugin-writer-skill`（落档 dotfiles 仓 `openspec/changes/add-dsh-plugin-writer-skill/`，不建 specs/）
- 产物线：代码设计线。上游输入 `line-a.md` / `line-b.md` / `diff-matrix.md`（第六节收敛结论为**硬边界，本文不推翻、不重开**；发现矛盾上浮「待决问题」节）
- 约束源：**writing-skills 已成功加载**（`/home/docker/.agents/skills/writing-skills`，含 `anthropic-best-practices.md` / `testing-skills-with-subagents.md` 等附属资源）；其 TDD 式文档开发（RED→GREEN→REFACTOR、Iron Law、SDO description 纪律、Match-the-Form-to-the-Failure）为本设计的硬约束，已映射进任务组执行序（见 ⑤）
- 日期：2026-11-05。文中所有 file:line 均为本轮实测核对

---

## ① 触达面清单

| # | 路径 | 所属仓 | 新建/修改 | 改动意图 | 关键改动点 |
|---|---|---|---|---|---|
| 1 | `agent/skills/dsh-plugin-writer/SKILL.md` | dotfiles | 新建 | skill 主入口（精炼路由） | frontmatter 仅 `name`+`description` 两键；正文七节骨架（适用判定/选型决策树/模板插件对照/必改清单一览/生命周期步骤/真源指路表/分册路由+反例速查），行数预算 ≤150 行 |
| 2 | `agent/skills/dsh-plugin-writer/references/structure.md` | dotfiles | 新建 | 分册①：同构约定与「复制后必改清单」全量 | 包名/`version`/patch `id`+裸包名注册行/`files`/`exports`/`inject` 列表/各头注释逐项改写表；只指路+增量，不复述源码注释 |
| 3 | `agent/skills/dsh-plugin-writer/references/build.md` | dotfiles | 新建 | 分册②：构建与避坑 | 自包含 bundle（link: 不装被链包依赖）、CJS `createRequire` banner、dsh 子包经 `ctx.loader.import` 不 bundle、`lib/` 产物入库、`allowBuilds`、engines 派生；每条锚到源码 file:line |
| 4 | `agent/skills/dsh-plugin-writer/references/dual-client.md` | dotfiles | 新建 | 分册③：双端声明 | `dsh.client.inject`+`platform`、`exports "./client"`、裸包名行 REQUIRED（去掉=浏览器半静默消失）、浏览器半 CJS 壳 |
| 5 | `agent/skills/dsh-plugin-writer/references/verify-install.md` | dotfiles | 新建 | 分册④：验证与 profile 安装 | `verify:all`→`dsh:check`→link: 安装→`--dump-config-schema` 命令链、`/inventory` 交叉核对、`skill:` 开关假故障排障；**终点止于安装验证**，发布一句指路 AGENTS.md |
| 6 | `agent/skills/README.md` | dotfiles | 修改 | 「当前清单」表补一行 | 追加独立行：`` \| `dsh-plugin-writer` \| 自写（本目录 local symlink） \| `` |
| 7 | `openspec/changes/add-dsh-plugin-writer-skill/`（proposal.md、tasks.md、design.md 等） | dotfiles | 新建（由 `/spec-flow continue` 落档） | 变更决策与任务留痕 | 不建 `specs/`；落档提交只 `git add` 工件文件（仓内现存无关脏改动 `dsh/profiles/web/cordis.patch.yml` 不动） |
| 8 | `~/.local/share/agent-skills/skills/dsh-plugin-writer`（symlink）与 `~/.local/share/agent-skills/registry.json` | 机器态（dotfiles 仓外，宿主聚合层） | skctl install 产生 | 分发登记 | symlink 名=frontmatter `name`，目标=dotfiles 实体目录；registry 追加 `source.type=local` 条目；不入库 |
| 9 | `plugins/demo-echo/`（package.json、cordis.patch.yml、build.mjs、src/index.ts、tsconfig.json、test/） | dsh-plugins | 新建（**演练临时产物**） | 从零搭最小 host-only 插件走通全链 | 按本仓约定 `dsh-plugin-<目录名>` 命名；**验证后四步清理，不入库** |
| 10 | （明示）dsh-plugins 仓**零入库文件改动** | dsh-plugins | — | 本变更在该仓只做只读提炼+可清理演练 | `git -C …/dsh-plugins status --short` 终态断言不含 demo-echo |

---

## ② 证据锚

**dotfiles 仓 · skill 宿放与分发链**

- `agent/skills/README.md:3-5`——「本目录是自写 skill 的实体存放地（git 版本管理）……**未经 skctl 登记的 skill 两个 agent 都看不到**」；`README.md:11`——容器 `/home/docker/.agents/skills` ←聚合层只读挂载（compose SKCTL_STORE_PATH）；`README.md:16-25`——`SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts` 与 `install <本地目录>`（自写=登记 symlink）；`README.md:29-34`——「当前清单」两列表（`\| skill \| 来源 \|`）；`README.md:36-39`——宿主侧增删后「实时视图……运行中的 dsh 无需重启即可按名加载（实测）」
- `tools/skctl/src/install.ts:57-61`——本地 src **根下必须直接存在 SKILL.md**，否则 `no SKILL.md in <abs>`；`install.ts:83-91`——`name` 取自 frontmatter（`fm.name`），`validateName` 失败/重名即抛错；`install.ts:92-93`——`source.type === "local"` 走 `symlinkSync(skillDir, dest)`；`install.ts:100-105`——registry 写入 `{source, installedCommit, installedAt}`
- `tools/skctl/src/validate.ts:1-5`——`NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/`，长度 1–64；`validate.ts:15-17`——`parseFrontmatter` 要求 `name`/`description` 均为 string，否则返回 null（=「invalid SKILL.md frontmatter」）
- `tools/skctl/src/cli.ts:35`——`install <src> [--subdir DIR]` 命令面；`cli.ts:172-189`——`cmdInstall` 实现
- `tools/skctl/src/paths.ts:4-5`——`DEFAULT_STORE = /home/xuqinqin/.local/share/agent-skills`
- `CLAUDE.md`（dotfiles 根）「skctl」节——skctl 的测试/类型检查经 `~/develop/docker/run.sh node` 执行（node 命令走 docker 包装的仓库惯例）
- `openspec/changes/` 现仅 `archive/`（`ls` 实测）→ 落档目录为净新增；`git status --short` 实测仅 ` M dsh/profiles/web/cordis.patch.yml`
- `agent/skills/spec-plan/`（实存 `SKILL.md + refs/×4 + mode/×2`）——「路由+分册」的本仓活例；`agent/skills/spring-writer/SKILL.md`、`smoke-testing-local-env/SKILL.md` 头部——自写 skill frontmatter 实样（`Use when …`+中文触发词）

**官方 DSH · skill 发现与 frontmatter 契约**

- `@deepseek-ai/dsh-skill-filesystem/README.zh.md:46-56`——rank 表：100 `<projectRoot>/.dsh/skills` / 200 `<projectRoot>/.agents/skills` / 400 `<dshHome>/skills` / 500 `<agentsHome>/skills`；本 skill 经聚合层落在 **rank 500 user-agents**（用户级、跨项目可见）
- 同文件 `:36-38`——frontmatter 必填 `name`（kebab-case）+`description`，可选 `whenToUse`/`metadata`/`disable-model-invocation`/`user-invocable`；**布尔键被拒绝的拼写会让整个 skill 随警告一起被丢弃**
- 同文件 `:109`——发现深度 1 层（`<name>/SKILL.md`），刻意不支持嵌套 `**/SKILL.md`
- `@deepseek-ai/dsh-tool-skill/README.zh.md:48`——`catalogDescriptionMaxLength` 默认 `500`、最小 `3`（规范化描述）；`:12`——目录机制（首次请求前注入常驻目录）
- `@deepseek-ai/dsh-agent-preset/skills/cordis-plugin-development/SKILL.md:3-8`——官方 skill 定位「current Harness profile 内 install_bundle / ordinary workspace files」→ 分工声明（S1）的事实锚点

**dsh-plugins 仓 · skill 内容素材（只读提炼源）**

- `scripts/dsh-baseline.mjs:13`——`DSH_BASELINE = '0.2.1-rc.5'`（唯一版本真源）；`:23-29`——`softDshRange()` 派生软插件范围
- `AGENTS.md:37-38`——仍写 `0.2.1-rc.2`（双源漂移实证，收敛 F2；修正已定为独立任务不混入本变更）
- `package.json:14-24`——根递归脚本 `build/test/typecheck/lint/docs:check/release/dsh:upgrade/dsh:check/verify`
- `pnpm-workspace.yaml:5-6`——`packages: "plugins/*"`；`:10-21`——`allowBuilds`（koffi 等，F6 锚点）
- `scripts/check-dsh-baseline.mjs:1-22`——dsh:check 七断言（基线唯一/DSH devDeps 精确 pin/软插件 engines+peer=派生范围/multi-root compat:check/实际解析版本=基线/发布年龄豁免=lockfile 解析集/无 git-graph 残留）；`:149`——按 `src/compat/dsh-version.ts` 标记动态区分硬插件 → **演练包会被纳入断言面**
- `README.md:41-44`——`TAG=$(git describe …)`、`docker exec dsh dsh plugin --profile web add …`、`--dump-config-schema`（会 import 插件）；`:84-88`——官方三篇文档链接（第一个插件/开发一个工具/打包与安装）
- `plugins/zcode-plan/package.json:15-31`——`dsh.engines.dsh` + `dsh.bundle.patch` + `files` + peer 形状（host-only 模板）；`:44-53`——`verify:all = pnpm lint && pnpm typecheck && pnpm build && pnpm test`
- `plugins/zcode-plan/cordis.patch.yml:10-12`——`- insert: - id: … / name: 'dsh-plugin-…'`（裸包名行）
- `plugins/zcode-plan/build.mjs:1-10`——头注释：schemastery 必须 BUNDLE（「a `link:` install does not install the linked package's dependencies」）；`:41-42`——`banner` 注入 `createRequire`（F3 双坑锚点）
- `plugins/zcode-plan/lib/index.js`——构建产物实存入库（F4）
- `plugins/session-tool-toggle/package.json:11-19`——`exports "." + "./client"`；`:21-38`——`dsh.client.inject` 列表 + `platform: "web"`
- `plugins/session-tool-toggle/cordis.patch.yml:5-12`——「裸包名 REQUIRED：Web 侧 client-module scan 正是从这一行读 `dsh.client`……去掉裸包名行 = 浏览器半静默消失」（F1）
- `plugins/session-tool-toggle/build.mjs:1-25`——双端构建头注释（宿主半 ESM/浏览器半 CJS `window.__ModuleLoader__.load` 壳/banner require 原理）
- `plugins/multi-root-workspace/src/compat.ts:31,122`——`SUPPORTED_DSH_RELEASES` 精确枚举（特例路线锚点）
- `plugins/user-commands/src/host/inventory-command.ts`——`/inventory` 宿主侧只读命令（发现层交叉核对用）
- `dsh plugin --help`（实测）——「forwarding the remaining arguments to pnpm in the profile directory：add <pkg>, remove <pkg>, …」→ 演练清理用 `dsh plugin --profile web remove <pkg>`

**writing-skills（硬约束源）**

- `/home/docker/.agents/skills/writing-skills/SKILL.md`——Iron Law「NO SKILL WITHOUT A FAILING TEST FIRST」；RED（基线压测、逐字记录 rationalizations）→ GREEN（最小文档）→ REFACTOR（堵漏洞）；SDO「description 只写触发条件、绝不概述流程（否则 agent 照 description 抄近路跳过正文）」；Match the Form to the Failure（shaping 用 recipe 禁 prohibition）；目录结构惯例（`skill-name/SKILL.md` + 按需附属资源文件）；检查表「For behavior-shaping guidance: wording micro-tested … N/A for pure reference skills」
- 目录实存：`SKILL.md + anthropic-best-practices.md + testing-skills-with-subagents.md + persuasion-principles.md + examples/ + graphviz-conventions.dot + render-graphs.js`（附属资源活例）

---

## ③ 接口与数据形状

**1. skill 目录结构**

```
dotfiles/agent/skills/dsh-plugin-writer/
├── SKILL.md                      # 主入口：路由（≤150 行），frontmatter 两键
└── references/                   # 分主题分册（目录名随收敛结论用 references/）
    ├── structure.md              # 同构约定 + 复制后必改清单全量
    ├── build.md                  # 构建与避坑（F3/F4/F5/F6）
    ├── dual-client.md            # 双端声明（F1/F2 + 浏览器半 CJS 壳）
    └── verify-install.md         # 验证与 profile 安装（F11/F12），终点=安装验证
```

**2. SKILL.md frontmatter 键集与值（契约）**

```yaml
---
name: dsh-plugin-writer
description: Use when 在 dsh-plugins 仓（/home/xuqinqin/develop/person/dsh-plugins）新增、脚手架或结构性修改 DSH 插件——搭建插件工程骨架、选 host-only/双端形态、写 package.json/cordis.patch.yml/build.mjs、执行构建验证、link: 装入 profile 验证时使用；触发词：插件、plugin、新增插件、bundle、cordis.patch、dump-config-schema。文案小改、发布流程、profile 内一次性 bundle 不适用。
---
```

约束（逐条可断言）：

| 键 | 值/约束 | 断言依据 |
|---|---|---|
| `name` | `dsh-plugin-writer`；kebab-case、≤64 字符 | dsh-skill-filesystem `:36,109`；skctl `validate.ts:1-5` |
| `description` | 只写触发条件与让位条件，**不含流程概述**；第三人称；原始字符数 ≤300（上限 500、最小 3，留 40% 余量规避 U3 规范化算法未知） | dsh-tool-skill `:48`；writing-skills SDO |
| 其余键 | **一律不写**（不写 `whenToUse`/`metadata`/布尔键；键集恰为 `{name, description}`） | 收敛 Q5 默认双开；布尔拼错=整条丢弃（filesystem `:38`） |

**3. 分册文件清单与主题边界**

| 分册 | 主题边界（写什么） | 边界（不写什么） | 素材锚点 |
|---|---|---|---|
| `structure.md` | 复制哪个模板插件（对照表）；复制后必改清单全量：目录名/包名 `dsh-plugin-<目录名>`、`version`、patch `id` 与裸包名注册行、`files`、`exports`、`inject`、三个头注释（build.mjs/cordis.patch.yml/package.json description）逐一重写 | 不复述各插件源码注释原文，只给 file:line + 一行增量 | zcode-plan/sts 的 package.json+patch；AGENTS.md 结构节 |
| `build.md` | 自包含 bundle 原理与判定（哪些必须 bundle/哪些 external）；CJS banner；dsh 子包经 `ctx.loader.import`；`lib/` 入库与 release 前重建；`allowBuilds`；engines/peer 派生规则（指路 `dsh-baseline.mjs`，**正文零版本数字**） | 不写具体版本号、不复制 build.mjs 代码 | zcode-plan `build.mjs:1-10,41-42`；sts `build.mjs:1-25`；`dsh-baseline.mjs:13,23-29` |
| `dual-client.md` | 何时选双端（要动 Web UI）；`dsh.client.platform+inject`、`exports "./client"`、裸包名行与 client-module scan 因果；浏览器半 CJS 壳与外置依赖 | 不教 React/UI 实现细节 | sts `package.json:11-38`、`cordis.patch.yml:5-12` |
| `verify-install.md` | 命令链 `pnpm --filter <pkg> verify:all` → `pnpm dsh:check` → `docker exec dsh dsh plugin --profile web add <本仓>/plugins/<name>` → `docker exec dsh dsh --profile web --dump-config-schema`；`/inventory`；`skill:` 开关假故障排障；**发布/升级一句指路 AGENTS.md 即止** | 不展开 release 红线与 dsh:upgrade（收敛 Q4） | 根 `README.md:41-44`；AGENTS.md 命令节；sts `skill:` 开关事实 |

**4. SKILL.md 正文章节骨架（路由自足性下限）**

1. 适用判定（工作目录含 `/home/xuqinqin/develop/person/dsh-plugins` 时适用；「profile 内一次性功能」→ 让位官方 `cordis-plugin-development`；「行为规格设计」→ `openspec-propose`；原生依赖/纯 client 等未覆盖类型 → 回退官方三篇文档）
2. 选型决策树（host-only ↔ 双端 ↔ multi-root 特例；判据：是否动 Web UI / 是否需要精确版本枚举）
3. 模板插件对照表（host-only→zcode-plan 或 project-mcp；双端→session-tool-toggle 或 web-ux；特例→multi-root-workspace）
4. 复制后必改清单一览（精简 7 项；全量指路 `references/structure.md`）
5. 生命周期步骤清单（骨架→verify:all→dsh:check→link: 安装→dump-config-schema；**止于安装验证**）
6. 真源指路表（版本常量→`scripts/dsh-baseline.mjs`；命令表→根 README；工作流→AGENTS.md；官方教程→README L84-88 三链接；各坑→对应插件头注释 file:line）
7. 分册路由表 + 反例速查（F1/F3/F12 三条最高频一行速查，其余在分册）

**5. skctl 登记命令与聚合层 symlink 形状**

```sh
# 宿主 dotfiles 工作区执行（node 走 docker 包装，dotfiles CLAUDE.md 惯例）
SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts
node $SKCTL install ~/develop/dotfiles/agent/skills/dsh-plugin-writer
# 前置：实体目录根下直接有 SKILL.md（install.ts:57-61）；name 合法且聚合层无重名（:83-91）
```

产生效果（形状）：

- symlink：`~/.local/share/agent-skills/skills/dsh-plugin-writer → /home/xuqinqin/develop/dotfiles/agent/skills/dsh-plugin-writer`（**symlink 名=frontmatter `name`**，install.ts:86-93）
- registry 条目（`~/.local/share/agent-skills/registry.json` 追加）：
  ```json
  "dsh-plugin-writer": {
    "source": { "type": "local", "path": "/home/xuqinqin/develop/dotfiles/agent/skills/dsh-plugin-writer" },
    "installedAt": "<ISO 8601>"
  }
  ```
- 容器视图：`/home/docker/.agents/skills/dsh-plugin-writer`（bind mount 实时视图，README:36-39）→ dsh 用户级 rank 500（user-agents）发现
- 回滚：`node $SKCTL uninstall dsh-plugin-writer -y`

**6. dotfiles README 清单表行形状**

```markdown
| `dsh-plugin-writer` | 自写（本目录 local symlink） |
```

追加到 `agent/skills/README.md`「当前清单」表末尾，独立成行（列结构 `| skill | 来源 |` 与现有行一致；`smoke-testing-local-env` 有独立行先例）。

---

## ④ 决策记录

| # | 决策 | 理由 | 被否方案与理由（反例） |
|---|---|---|---|
| D1 | 分册目录名 `references/`、四册切分（structure/build/dual-client/verify-install） | 收敛形态行用词即「references/ 分主题分册」；四册对应复算线「内容天然分册」的四个正交主题，且发布主题已被 Q4 砍除 | ① `refs/`（spec-plan 惯例）——与收敛留痕用词不一致，不重开；② 单文件（B 线方案）——复算 2:1 已否；③ 按插件逐个分册（6 册）——必然复述源码注释，违反「只指路不复述」 |
| D2 | frontmatter 键集恰为 `{name, description}`，一个多余键都不写 | 收敛 Q5 默认双开；少写少错 | ① 显式写布尔键——filesystem `:38` 实证：被拒绝的拼写=**整条 skill 随警告丢弃**（静默失效面）；② 照抄 openspec 生成键（`allowed-tools`/`license`）——DSH 不解析，无害但误导（F8） |
| D3 | description 只写触发+让位条件，原始字符数 ≤300，含本仓绝对路径 | 用户级 skill 跨项目可见，必须用绝对路径锚定适用域（diff-matrix Q1 推论 1 明确交本设计处理）；≤300 对 500 上限留 40% 余量（U3 规范化算法未定义，只能余量规避） | ① 顶格写满 500——反例：现有 openspec skill 实测 220~433 全留余量；② 流程概述式 description——反例：writing-skills SDO 实测记录，description 写「code review between tasks」导致 agent 只做一次 review（照 description 抄近路跳过正文） |
| D4 | skill 名沿用需求原文 `dsh-plugin-writer` | 需求原文与收敛全篇定名；与 dotfiles 现有 `-writer` 命名族（`spring-writer`、`nuxt-writer`）同构，语义=「写 X 的规范」 | writing-skills 的动词开头/动名词命名建议（如 `writing-dsh-plugins`）——与需求定名冲突且打破本仓命名族；kebab-case 合法性不受影响 |
| D5 | RED 基线压测排入任务组 1（撰写前），轻量化：观察至首个构建/装载失败点即止，逐字记录 agent 的踩坑与合理化借口 | writing-skills Iron Law：无失败测试不得写 skill；基线只需行为模式与借口样本，不需走完全链 | ① 先写后测——Iron Law 明令「Write skill before testing? Delete it. Start over」；② RED 也跑全链——与 GREEN 双倍成本，基线观察价值在「怎么错的」不在「走没走通」 |
| D6 | 演练包从零手写但**逐字段对照 zcode-plan 复制**（devDependencies 集合原样复制，不引入新 `@deepseek-ai/*` 版本） | 复制天然继承现行基线派生值（engines/peer/devDeps pin），dsh:check 七断言一次通过；演练包 devDeps 全部已在根豁免清单内，lockfile 解析集不变（check 断言 6 不受扰动） | ① 完全从零手写——必踩 F5（engines 手写漂移；反例：连 AGENTS.md 自己都漂了 rc.2 vs 真源 rc.5）与 F6；② 以 multi-root 为模板——带入 koffi/allowBuilds 上一代杂质（复算 D3 已指出的复制带杂质风险） |
| D7 | 演练清理四步：profile 移除 → 删目录 → `pnpm install` 回写 lockfile → `git status` 断言 | 收敛 Q6/E2 明确演练产物不入库；只删目录不重装会留 lockfile 残留（workspace importer 条目），污染 dsh:check 断言 6 的比对集 | ① demo 插件保留入库——违反 E2「演练产物清理不入库」；② 只 `rm -rf` 不跑 `pnpm install`——lockfile 残留 demo importer，下次 dsh:check/verify 可能误报 |
| D8 | README 补行独立成行，不并入现有合并格 | 现有 L31 合并格是「一组同时引入」的语义；本 skill 单独变更单独评审，独立行 diff 清晰 | 并入 L31 合并格——掩盖「本次只加了一个 skill」的评审事实 |
| D9 | 正文「适用判定」以绝对路径 `/home/xuqinqin/develop/person/dsh-plugins` 为锚，不用相对路径、不做 .git 探测 | 用户级 skill（rank 500）在任意 cwd 都可被加载，相对路径无锚点；skill 是指令文档不是脚本，直给绝对路径最不易错 | ① 相对路径指路（`plugins/…`）——在任意其他仓库会话中加载时全部失效；② 让 agent 现场探测最近 `.git` 祖先——多一步就多一个错法（F7 的目录层级混淆就是探测类错误的实证） |
| D10 | 触发有效性三语句测试（S6）放任务组 5（落盘且目录可见后），用子代理实证，不做撰写期纸面自评 | 触发是**被测行为**（目录渲染→模型路由），不是作者判断；必须新会话目录出现后才能测 | 撰写组纸面自评触发词覆盖——测不到真实路由；反例：R7 误触发/漏触发风险只有目录渲染后的请求级测试能暴露 |

---

## ⑤ 逐任务组实现要点（与 tasks 任务分组一一对齐）

> 执行序契约（writing-skills TDD 映射）：组1 含 RED（skill 落盘前的基线压测）→ 组2 GREEN（最小文档针对 RED 失败写）→ 组3/4/5 格式与发现层验证 → 组6 行为层 GREEN/REFACTOR（全链演练 + 卡点回流修订）。每组验证映射均为具体命令或断言，无「已实现/工作正常」类空话。

**组 1 · 素材提炼与事实核对（含 RED 基线）**

- 要点：
  - 静态素材：产出「共性字段清单 + 三条模板路线差异表（host-only 软插件 / 双端软插件 / multi-root 特例）+ 反例清单 F1–F12」，每条核对到 file:line（本文 ② 节已给出主干锚点，可直接采信续核）；
  - 动态素材（RED）：skill 落盘**之前**，起一个未加载本 skill 的子代理，在 dsh-plugins 仓执行「从零搭一个最小 host-only 插件并让它可安装」，观察至首个构建/装载失败点即止，**逐字记录**其踩坑与合理化借口（预期命中 F3 不自包含/F5 engines 手写/F2 漏 patch 声明一类）；压测产物同样落演练目录随后清理；
  - 若基线零失败（对照不失败）：按 writing-skills「control 不失败则无需修」上浮待决，不硬写 skill。
- 验证映射：
  - 素材清单断言：每条反例/差异项附 file:line，抽查 `test -e <路径>` 全通过；
  - RED 记录断言：含 ≥1 条逐字的 agent 合理化借口引用；压测目录清理后 `git -C /home/xuqinqin/develop/person/dsh-plugins status --short` 无残留。

**组 2 · SKILL.md 与分册撰写（GREEN）**

- 要点：
  - 先写 SKILL.md 路由（最小文档，只针对 RED 失败与素材反例），再写四分册；形态/键集/章节骨架/行数预算照 ③ 节契约执行；
  - 硬纪律：description 只写触发+让位条件；正文与分册**零版本数字**（含 `0.2.1`/`rc.N` 字样一律指向 `scripts/dsh-baseline.mjs`）；与官方 `cordis-plugin-development` 的分工声明放开篇第 1 节；生命周期止于安装验证，发布一句指路 AGENTS.md；分册只指路+增量，不复述源码注释原文。
- 验证映射：
  - `grep -nE '0\.2\.[0-9]|rc\.[0-9]' agent/skills/dsh-plugin-writer/SKILL.md agent/skills/dsh-plugin-writer/references/*.md` → 零命中；
  - skill 内引用的每个仓库路径逐一 `test -e`（如 `/home/xuqinqin/develop/person/dsh-plugins/scripts/dsh-baseline.mjs`、各 `plugins/*/build.mjs`）；
  - `wc -l agent/skills/dsh-plugin-writer/SKILL.md` ≤ 150。

**组 3 · frontmatter 结构校验**

- 要点：四项校验全部只读断言，任何一项不过即回到组 2 改文档（不得带病登记）。
- 验证映射：
  - 键集恰为两键：`sed -n '/^---$/,/^---$/p' SKILL.md | grep -E '^[a-zA-Z-]+:' | cut -d: -f1 | sort` 输出恰为 `description`、`name` 两行；
  - name 合法：`grep -cE '^name: dsh-plugin-writer$' SKILL.md` = 1（kebab-case 由字面保证，规则同 skctl `NAME_RE`）；
  - description 字符数：`node -e 'const s=require("fs").readFileSync("agent/skills/dsh-plugin-writer/SKILL.md","utf8").match(/^description: (.+)$/m)[1];console.log([...s].length)'` → 值 ≤300（≥3）；
  - YAML 可解析且必填键为 string（与 skctl 同解析器）：`node -e 'const m=require("/home/xuqinqin/develop/dotfiles/tools/skctl/node_modules/gray-matter");const f=m("/home/xuqinqin/develop/dotfiles/agent/skills/dsh-plugin-writer/SKILL.md");if(typeof f.data.name!=="string"||typeof f.data.description!=="string")process.exit(1);console.log("ok")'` → 输出 ok。

**组 4 · skctl 登记与 README 补行**

- 要点：先补 README 清单行，再执行 skctl install（命令与形状见 ③-5/③-6）；登记前确认聚合层无重名（`install` 重名即抛错，天然门禁）。
- 验证映射：
  - `node $SKCTL list --all --desc | grep dsh-plugin-writer` → 命中 enabled/local 行与描述；
  - `readlink ~/.local/share/agent-skills/skills/dsh-plugin-writer` → 输出 `/home/xuqinqin/develop/dotfiles/agent/skills/dsh-plugin-writer`；
  - `node -e 'console.log(JSON.parse(require("fs").readFileSync(process.env.HOME+"/.local/share/agent-skills/registry.json","utf8")).skills["dsh-plugin-writer"].source.type)'` → `local`；
  - 容器视图：`ls -d /home/docker/.agents/skills/dsh-plugin-writer` → 存在；
  - `grep -n 'dsh-plugin-writer' ~/develop/dotfiles/agent/skills/README.md` → 恰命中清单表新行。

**组 5 · 发现与加载验证（目录可见 + /inventory + 实际加载）**

- 要点：三路验证——模型目录、宿主侧 `/inventory` 交叉核对、`skill` 工具实际加载；再做 S6 触发三语句路由测试；若目录不可见先查 session-tool-toggle 的 `skill:` 开关状态（F11 假故障）再怀疑文件。
- 验证映射：
  - 新开会话（token 新开）目录消息包含 `dsh-plugin-writer` 条目；
  - `/inventory` 输出（宿主侧只读，`plugins/user-commands/src/host/inventory-command.ts`）包含 `dsh-plugin-writer`；
  - `skill dsh-plugin-writer` 工具调用返回正文（标题匹配）；反向：`skill dsh-plugin-writter`（拼错名）应报不可用/无效名，佐证名字拼写；
  - 触发三语句各起一个子代理：「在本仓新写一个插件」→ 命中本 skill；「给当前 profile 加个一次性功能」→ 让位官方 `cordis-plugin-development`；「设计新插件的行为规格」→ 走 `openspec-propose`。

**组 6 · dsh-plugins 侧演练（从零搭最小 host-only 插件走通全链；产物清理不入库）**

- 要点：
  - 演练目录 `plugins/demo-echo/`，包名 `dsh-plugin-demo-echo`（AGENTS.md：包名一律 `dsh-plugin-<目录名>`）；最小件套：package.json（`dsh.engines.dsh`+`dsh.bundle.patch`+`files`+peer，devDependencies 集合照抄 zcode-plan 不增删版本）、cordis.patch.yml（`- insert:` 裸包名行，`id: demo-echo`）、build.mjs（esbuild 自包含+`createRequire` banner，头注释重写为演练语义）、src/index.ts（导出 `name`/`inject`/`apply`，宿主零注入不报错）、tsconfig.json、test/（vitest 至少 1 例）；version 用 `0.0.0`（dsh:check 七断言不含版本统一，统一版本是 release.mjs 的职责；正式入库插件的 version 对齐规则写进 structure.md 必改清单）；
  - 命令链（全绿才算 GREEN）：`pnpm install`（workspace 收录新包）→ `pnpm --filter dsh-plugin-demo-echo verify:all` → 仓库级 `pnpm dsh:check` → `docker exec dsh dsh plugin --profile web add /home/xuqinqin/develop/person/dsh-plugins/plugins/demo-echo`（本地路径=link: 调试安装）→ `docker exec dsh dsh --profile web --dump-config-schema`（真实 import 插件，装载性最硬验证）；
  - 双端抽验（A 线验证思路保留项）：演练第二分支给 demo 包追加 `dsh.client` 声明与 `exports "./client"` 后重跑 dump 链，核对 Web client-module scan 识别（硬断言止于配置树注册行，Web UI 入口目检为软断言，见待决 T1）；
  - REFACTOR：演练中 agent 实际踩到的坑回填 skill（必改清单/反例速查增补），回填后重跑组 3 断言与受影响的演练步骤；
  - 清理（四步，见 D7）：`docker exec dsh dsh plugin --profile web remove dsh-plugin-demo-echo` → `rm -rf plugins/demo-echo` → `pnpm install` → 断言。
- 验证映射：
  - `pnpm --filter dsh-plugin-demo-echo verify:all` 退出码 0（lint/typecheck/build/test 四段全绿）；
  - `pnpm dsh:check` 退出码 0；
  - `docker exec dsh dsh --profile web --dump-config-schema` 退出码 0，且输出/schema 中可见 demo-echo 装载；
  - `docker exec dsh dsh --profile web --dump-config | grep demo-echo` → 出现注册行（双端分支同法断言 client 半进入配置树）；
  - 清理终态：`git -C /home/xuqinqin/develop/person/dsh-plugins status --short` 输出不含 `demo-echo`（演练前该仓为干净态）。

---

## ⑥ 设计假设与未决项

**设计假设**

- A1 六个任务组口径即落档 `tasks.md` 的分组口径（本文与其一一对齐；若落档时分组有变，以 tasks 为准回改本文映射，不回改收敛结论）。
- A2 skctl `install` 在宿主 dotfiles 工作区可执行：`tools/skctl/node_modules` 已在位（实测），node 经 docker 包装执行（dotfiles CLAUDE.md 惯例）。
- A3 演练环境可用：`docker exec dsh`、web profile、`dsh plugin add/remove` 为仓库日常命令（E3 已降级为执行期注意项；不可用则组 6 降级只读评审并显式记录降级，S8）。
- A4 skill 目录对子代理可见：用户级 rank 500 根（容器 `/home/docker/.agents/skills`）对新会话/子代理同样注入（writing-skills 本身即经该机制在子代理可用，机制同源）。
- A5 正文 zh-CN + frontmatter 英文键不影响加载与目录渲染（line-b A5；现有 spring-writer 等中文正文 skill 长期在用为旁证）。
- A6 description 长度断言用原始字符数：规范化只折叠/截断不扩增，故原始字符数 ≤300 是规范化后 ≤500 的充分上界（叠加 40% 余量双保险，规避 U3 算法未知）。
- A7 组 6 双端抽验的硬断言止于 `--dump-config` 注册行：浏览器半启动图无 CLI 级硬断言手段，Web UI 目检为软断言（强度取舍见待决 T1）。

**未决项（不阻塞设计，执行期核验）**

- U-A：演练包被 `dsh:check` 动态枚举纳入断言面（`check-dsh-baseline.mjs:149` 按标记文件区分硬插件）：若演练包意外触发第七断言以外的检查失败，以脚本输出为准回填 structure.md 必改清单（本轮已核七断言清单，不含版本统一）。
- U-B：`dsh-plugin-writer` 与 `openspec-*`/官方 skill 的触发词共存路由（「插件」一词的归属）——组 5 三语句测试是唯一实证手段，若出现双命中/误让位，调 description 触发词后重测。

---

## 待决问题（六字段之外）

1. **双端抽验的验证强度**
   - 问题：组 6 双端分支验证到哪层为止？
   - 选项：a) 硬断言止于 `--dump-config` 注册行 + Web UI 入口人工目检；b) 追加浏览器半加载图证据（截图/启动图日志）。
   - 推荐：a（F1 的「静默消失」本就发生在启动图层，目检恰是对症层；b 的自动化成本超出本变更验证预算）。
   - 影响面：组 6 时长、环境依赖（Web GUI 可达性）、REFACTOR 回流样本量。

2. **RED 基线压测规模**
   - 问题：组 1 的基线压测跑几轮、用什么压力组合？
   - 选项：a) 1 轮全观察（观察至首败即止）；b) writing-skills 纪律型标准的 3+ 组合压力（时间+沉没成本+权威）。
   - 推荐：a（本 skill 属 technique/reference 型，writing-skills 对其测试标准是 Application scenario 而非组合压力；素材反例 F1–F12 已提供静态失败面，压测只补动态借口样本）。
   - 影响面：组 1 成本与 RED 样本厚度的权衡。

3. **触发三语句的测试轮次**
   - 问题：组 5 每条触发语句跑几个子代理样本？
   - 选项：a) 各 1 轮（共 3 个子代理）；b) 各 5 轮微测（writing-skills 微测纪律 5+ reps）。
   - 推荐：a（微测纪律针对 behavior-shaping 措辞，检查表明示「N/A for pure reference skills」；若 a 轮出现摇摆结果再升级到 b）。
   - 影响面：组 5 成本与路由结论置信度。

4. **落档 design.md 与本文档的关系**
   - 问题：`/spec-flow continue` 落档时，变更目录里的 design.md 是否即本文档（修订后复制）？
   - 选项：a) 即本文档（代码级设计契约随档入库）；b) 落档时另行改写压缩。
   - 推荐：a（保住 file:line 证据锚与断言命令的完整性，避免二次转写失真）。
   - 影响面：dotfiles 仓 `openspec/changes/add-dsh-plugin-writer-skill/` 的工件体量与后续 apply 阶段的引用一致性。
