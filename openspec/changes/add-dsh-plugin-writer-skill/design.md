# Design

> 本文以阶段 1.7 产出的 `code-design.md`（随档复制于本目录）为基底修订而成，保留其全部证据锚与断言命令；两文冲突时以本文为落档权威。上游收敛留痕见 `diff-matrix.md`（第六节收敛结论为硬边界）。

## Context

- 变更产物是一份**用户级 DSH skill**（`dsh-plugin-writer`），把 dsh-plugins 仓 6 个插件沉淀的工程约定固化为 agent 可按需加载的指令文档；需求动机见 proposal.md「Why」。
- 宿放与分发链（已实证，`agent/skills/README.md:3-11`）：实体放 dotfiles 仓 `agent/skills/dsh-plugin-writer/`（git 管理）→ skctl `install` 登记聚合层 `~/.local/share/agent-skills/`（自写=symlink 回实体）→ 容器 `/home/docker/.agents/skills` bind mount 只读挂载（实时视图）→ dsh 用户级 **rank 500（user-agents）** 发现；未登记 skctl 的 skill 不可见。
- skill 发现契约（官方 DSH 包实证）：`dsh-skill-filesystem/README.zh.md:36-38` frontmatter 必填 `name`（kebab-case）+ `description`，可选 `whenToUse`/`metadata`/`disable-model-invocation`/`user-invocable`，**布尔键被拒绝的拼写=整条 skill 随警告丢弃**；`:46-56` rank 表；`:109` 发现深度 1 层（`<root>/<name>/SKILL.md`）；`dsh-tool-skill/README.zh.md:48` 目录描述 `catalogDescriptionMaxLength` 默认 500、最小 3（规范化算法未定义）。
- **栈识别结论（spec-plan 阶段 1.7 要求记入）**：本变更产物为 skill 文档（非 Spring/Nuxt 栈），用户指认聚合层 **`writing-skills`** 为 writer 约束（证据：`/home/docker/.agents/skills/writing-skills/SKILL.md`，定位「creating new skills, editing existing skills, or verifying skills」）。其 TDD 式文档开发纪律（Iron Law「无失败测试不得写 skill」、RED→GREEN→REFACTOR、SDO「description 只写触发条件不概述流程」、Match-the-Form-to-the-Failure）是本次设计与任务拆分的**硬约束**，已映射进「逐任务组实现要点」执行序。执行侧（spec-apply）沿用同一结论。

## 触达面清单（深度契约 ①）

| # | 路径 | 所属仓 | 新建/修改 | 改动意图 | 关键改动点 |
|---|---|---|---|---|---|
| 1 | `agent/skills/dsh-plugin-writer/SKILL.md` | dotfiles | 新建 | skill 主入口（精炼路由） | frontmatter 仅 `name`+`description`；正文七节骨架（适用判定/选型决策树/模板插件对照/必改清单一览/生命周期步骤/真源指路表/分册路由+反例速查），≤150 行 |
| 2 | `agent/skills/dsh-plugin-writer/references/structure.md` | dotfiles | 新建 | 分册①：同构约定与「复制后必改清单」全量 | 包名/`version`/patch `id`+裸包名注册行/`files`/`exports`/`inject`/各头注释逐项改写表；只指路+增量 |
| 3 | `agent/skills/dsh-plugin-writer/references/build.md` | dotfiles | 新建 | 分册②：构建与避坑 | 自包含 bundle、CJS `createRequire` banner、dsh 子包经 `ctx.loader.import` 不 bundle、`lib/` 入库、`allowBuilds`、engines 派生；每条锚到源码 file:line |
| 4 | `agent/skills/dsh-plugin-writer/references/dual-client.md` | dotfiles | 新建 | 分册③：双端声明 | `dsh.client.inject`+`platform`、`exports "./client"`、裸包名行 REQUIRED、浏览器半 CJS 壳 |
| 5 | `agent/skills/dsh-plugin-writer/references/verify-install.md` | dotfiles | 新建 | 分册④：验证与 profile 安装 | `verify:all`→`dsh:check`→link: 安装→`--dump-config-schema` 链、`/inventory`、`skill:` 开关假故障排障；**终点止于安装验证**，发布一句指路 AGENTS.md |
| 6 | `agent/skills/README.md` | dotfiles | 修改 | 「当前清单」表补一行 | 独立行：`` \| `dsh-plugin-writer` \| 自写（本目录 local symlink） \| `` |
| 7 | `openspec/changes/add-dsh-plugin-writer-skill/` | dotfiles | 新建（本落档） | 变更决策与任务留痕 | 不建 `specs/`（`skip_specs: true`）；提交只 `git add` 工件目录（仓内现存无关脏改动 `dsh/profiles/web/cordis.patch.yml` 不动） |
| 8 | `~/.local/share/agent-skills/skills/dsh-plugin-writer`（symlink）与 `registry.json` | 机器态（不入库） | skctl install 产生 | 分发登记 | symlink 名=frontmatter `name`；registry `source.type=local` |
| 9 | `plugins/demo-echo/`（package.json、cordis.patch.yml、build.mjs、src/index.ts、tsconfig.json、test/） | dsh-plugins | 新建（**演练临时产物**） | 从零搭最小 host-only 插件走通全链 | 包名 `dsh-plugin-demo-echo`；**验证后四步清理，不入库** |
| 10 | （明示）dsh-plugins 仓**零入库文件改动** | dsh-plugins | — | 只读提炼 + 可清理演练 | 终态 `git -C …/dsh-plugins status --short` 断言不含 demo-echo |

## 证据锚（深度契约 ②，file:line 均为规划期实测）

**dotfiles 仓 · 宿放与分发链**

- `agent/skills/README.md:3-5`（自写实体地，未经 skctl 登记不可见）；`:11`（容器挂载）；`:16-25`（`SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts`、`install <本地目录>`）；`:29-34`（清单两列表）；`:36-39`（实时视图，运行中 dsh 免重启按名加载实测）
- `tools/skctl/src/install.ts:57-61`（src 根下必须直接有 SKILL.md）；`:83-91`（name 取自 frontmatter，`validateName`/重名抛错）；`:92-93`（local 走 `symlinkSync`）；`:100-105`（registry 写入形状）
- `tools/skctl/src/validate.ts:1-5`（`NAME_RE=/^[a-z0-9]+(-[a-z0-9]+)*$/`，长度 1–64）；`:15-17`（frontmatter name/description 须为 string）
- `tools/skctl/src/paths.ts:4-5`（`DEFAULT_STORE=/home/xuqinqin/.local/share/agent-skills`）
- dotfiles `CLAUDE.md`「skctl」节：node 经 `~/develop/docker/run.sh node` 执行（仓库惯例）
- `openspec/changes/` 现仅 `archive/`（实测）→ 落档目录净新增；`agent/skills/spec-plan/`（SKILL.md+refs/+mode/）为「路由+分册」活例

**官方 DSH · 发现与 frontmatter 契约**

- `dsh-skill-filesystem/README.zh.md:36-38,46-56,109`（见 Context）；`dsh-tool-skill/README.zh.md:12,48`（目录机制与 500/3 上下限）
- `dsh-agent-preset/skills/cordis-plugin-development/SKILL.md:3-8`（官方 skill=profile 内 `install_bundle`/workspace 文件、禁止手写 profile package.json）→ 分工声明锚点

**dsh-plugins 仓 · 素材源（只读提炼）**

- `scripts/dsh-baseline.mjs:13`（`DSH_BASELINE='0.2.1-rc.5'` 唯一真源）；`:23-29`（`softDshRange()` 派生）
- `AGENTS.md:37-38`（仍写 rc.2——漂移实证；修正已定独立任务不混入）
- `package.json:14-24`（根递归脚本）；`pnpm-workspace.yaml:5-6`（`plugins/*`）；`:10-21`（`allowBuilds`）
- `scripts/check-dsh-baseline.mjs:1-22`（dsh:check 七断言）；`:149`（按标记动态区分硬插件 → 演练包会被纳入断言面）
- 根 `README.md:41-44`（TAG 安装、`--dump-config-schema`）；`:84-88`（官方三篇文档链接）
- `plugins/zcode-plan/package.json:15-31,44-53`（host-only 模板形状、`verify:all` 四段）；`cordis.patch.yml:10-12`（裸包名行）；`build.mjs:1-10,41-42`（自包含两坑）；`lib/index.js`（产物入库）
- `plugins/session-tool-toggle/package.json:11-38`（双端 exports+dsh.client）；`cordis.patch.yml:5-12`（「去掉裸包名行=浏览器半静默消失」）；`build.mjs:1-25`（双端构建注释）
- `plugins/multi-root-workspace/src/compat.ts:31,122`（`SUPPORTED_DSH_RELEASES` 精确枚举特例）
- `plugins/user-commands/src/host/inventory-command.ts`（`/inventory` 宿主侧只读）
- `dsh plugin --help`（实测）：`add <pkg>, remove <pkg>, …` → 演练清理用 remove

**writing-skills（硬约束源）**：`/home/docker/.agents/skills/writing-skills/SKILL.md`——Iron Law、RED→GREEN→REFACTOR、SDO、Match-the-Form-to-the-Failure、目录结构惯例（`skill-name/SKILL.md`+附属资源）、检查表「N/A for pure reference skills」

## Goals / Non-Goals

**Goals:**

- 一份可被 dsh 用户级发现、双面可调用的 skill：SKILL.md 精炼路由（≤150 行）+ 四分册按需加载，token 成本从「常驻」变「按需」
- 指路真源策略落地：正文与分册**零版本数字**、不复述源码注释，易变事实一律指向源头文件
- writing-skills TDD 纪律贯穿：RED 基线压测 → GREEN 撰写 → 结构/发现/加载三层校验 → 全链演练 REFACTOR 回流

**Non-Goals:**

- 不内置静态模板（以「复制后必改清单」替代）；不做脚手架生成器
- 生命周期指引不展开发布红线与 `dsh:upgrade`（止于安装验证，其余一句指路 AGENTS.md）
- 不修改任何现有插件源码；不修正 AGENTS.md 漂移（独立任务）；不覆盖 DSH 0.3.x 机制

## 接口与数据形状（深度契约 ③）

**1. 目录结构**：`agent/skills/dsh-plugin-writer/{SKILL.md, references/{structure,build,dual-client,verify-install}.md}`（发现深度 1 层约束下的 `<name>/SKILL.md` 形态；分册为附属资源按需加载）

**2. frontmatter 契约**：

```yaml
---
name: dsh-plugin-writer
description: Use when 在 dsh-plugins 仓（/home/xuqinqin/develop/person/dsh-plugins）新增、脚手架或结构性修改 DSH 插件——搭建插件工程骨架、选 host-only/双端形态、写 package.json/cordis.patch.yml/build.mjs、执行构建验证、link: 装入 profile 验证时使用；触发词：插件、plugin、新增插件、bundle、cordis.patch、dump-config-schema。文案小改、发布流程、profile 内一次性 bundle 不适用。
---
```

| 键 | 值/约束 | 断言依据 |
|---|---|---|
| `name` | `dsh-plugin-writer`；kebab-case、≤64 字符 | filesystem `:36,109`；skctl `validate.ts:1-5` |
| `description` | 只写触发+让位条件、不含流程概述；第三人称；原始字符数 ≤300（对 500 上限留 40% 余量规避规范化算法未知） | dsh-tool-skill `:48`；writing-skills SDO |
| 其余键 | **一律不写**（键集恰为 `{name, description}`；默认双开=模型+`/dsh-plugin-writer` 手势均可用） | 收敛 Q5；布尔拼错=整条丢弃（filesystem `:38`） |

**3. 分册主题边界**：`structure.md`=模板插件对照+必改清单全量（不复述注释，只给 file:line+增量）；`build.md`=自包含/external 判定、banner、`ctx.loader.import`、`lib/` 入库、`allowBuilds`、engines 派生（**零版本数字**）；`dual-client.md`=双端选型判据与声明形状、裸包名行因果、浏览器半 CJS 壳（不教 React/UI）；`verify-install.md`=命令链+`/inventory`+假故障排障（**止于安装验证**）。

**4. SKILL.md 正文章节骨架**：适用判定（绝对路径锚定本仓；「profile 内一次性功能」让位官方 skill；「行为规格设计」走 openspec-propose；未覆盖类型回退官方三篇文档）→ 选型决策树 → 模板插件对照表 → 必改清单一览（7 项精简）→ 生命周期步骤 → 真源指路表 → 分册路由+反例速查（F1/F3/F12 一行速查）。

**5. skctl 登记形状**：`node $SKCTL install ~/develop/dotfiles/agent/skills/dsh-plugin-writer`（宿主执行，node 走 docker 包装）→ symlink `~/.local/share/agent-skills/skills/dsh-plugin-writer → <实体目录>`（名=frontmatter.name，`install.ts:86-93`）；registry 追加 `{"dsh-plugin-writer": {"source": {"type": "local", "path": "<实体目录>"}, "installedAt": "<ISO 8601>"}}`；回滚 `node $SKCTL uninstall dsh-plugin-writer -y`。

**6. README 清单表行**：`| `dsh-plugin-writer` | 自写（本目录 local symlink） |`，追加表末独立成行（列结构与现有一致）。

## Decisions（深度契约 ④）

落档分歧点拍板记录（设计线上浮 4 条，2026-11-05 用户拍板）：**分2 RED 规模=1 轮至首败**；**分3 触发测试=各 1 轮（摇摆再升级 5 轮微测）**；**分4 本 design.md=以 code-design.md 为基底修订**；**分1 双端抽验强度=留执行期由用户现场决策**（见 Open Questions）。

- 执行环境：直用主工作区。衔接确认（2026-11-05）：判据零命中（两仓工作树干净、无并行 worktree、均在常规主分支 dotfiles@master / dsh-plugins@main）+ 用户选定；auto 模式 + 引擎 subagent（映射文件）。

| # | 决策 | 理由 | 被否方案与理由（反例） |
|---|---|---|---|
| D1 | 分册目录 `references/`、四册切分 | 收敛结论用词即「references/ 分主题分册」；四主题正交且发布主题已被收敛 Q4 砍除 | ① `refs/`（spec-plan 惯例）与收敛用词不一致；② 单文件——复算 2:1 已否；③ 按插件逐个分册——必复述源码注释 |
| D2 | frontmatter 键集恰 `{name, description}` | 收敛 Q5 默认双开；少写少错 | ① 显式布尔键——被拒拼写=**整条随警告丢弃**（filesystem `:38`）；② 照抄 openspec 生成键（`allowed-tools`/`license`）——DSH 不解析（F8） |
| D3 | description 只写触发+让位、≤300 字符、含本仓绝对路径 | 用户级 rank 500 跨项目可见，必须绝对路径锚定适用域（收敛 Q1 推论 1）；余量规避 U3 | ① 顶格 500——现有 openspec skill 实测 220~433 均留余量；② 流程概述式——writing-skills SDO 实测反例（agent 照 description 抄近路跳过正文） |
| D4 | skill 名沿用 `dsh-plugin-writer` | 需求定名；与 dotfiles `-writer` 命名族（spring-writer/nuxt-writer）同构 | writing-skills 动词开头命名建议（`writing-dsh-plugins`）——与需求定名冲突、破坏命名族 |
| D5 | RED 基线压测排组 1（撰写前），1 轮至首败、逐字记录借口 | writing-skills Iron Law；reference 型 skill 静态失败面已由 F1–F12 提供，压测只补动态借口样本（分2 拍板） | ① 先写后测——Iron Law「Write skill before testing? Delete it」；② 3+ 组合压力——针对 behavior-shaping 型，成本双倍 |
| D6 | 演练包逐字段对照 zcode-plan 复制（devDeps 集合原样） | 复制天然继承基线派生值，dsh:check 七断言一次过；devDeps 已全在根豁免清单 | ① 完全从零——必踩 F5/F6（反例：AGENTS.md 自己都漂了）；② 以 multi-root 为模板——带 koffi/allowBuilds 上一代杂质 |
| D7 | 演练清理四步（remove→rm→pnpm install→断言） | 只删目录不重装会留 lockfile 残留，污染 dsh:check 断言 6 比对集 | ① 演练包入库——违反「清理不入库」；② 只 rm——lockfile importer 残留致误报 |
| D8 | README 补行独立成行 | 单独变更单独评审，diff 清晰 | 并入现有合并格——掩盖「本次只加一个 skill」的评审事实 |
| D9 | 适用判定以绝对路径锚定本仓 | 用户级 skill 任意 cwd 可加载，相对路径无锚点；指令文档直给绝对路径最不易错 | ① 相对路径——其他仓库会话加载即失效；② 现场 `.git` 祖先探测——多一步多一个错法（F7 实证） |
| D10 | 触发三语句测试放组 5（目录可见后），子代理实证 | 触发是被测行为（目录渲染→模型路由），非作者判断 | 撰写期纸面自评——测不到真实路由（R7 只有请求级测试能暴露） |

## 逐任务组实现要点（深度契约 ⑤，与 tasks.md 分组一一对齐）

> 执行序契约（writing-skills TDD 映射）：组1 含 RED（落盘前基线压测）→ 组2 GREEN（最小文档针对 RED 失败写）→ 组3/4/5 格式与发现层验证 → 组6 行为层 GREEN/REFACTOR（全链演练+卡点回流）。全部验证映射为具体命令/断言，无空话。
> 分组映射（A1：tasks 为准）：本文组 1–5 = tasks 组 1–5；本文组 6（全链演练+双端抽验+REFACTOR/清理）按「组内互不依赖」契约拆为 **tasks 组 6（host-only 全链）/ 组 7（双端分支抽验）/ 组 8（REFACTOR 回填与复验，需 demo 包在位）/ 组 9（终态清理四步）**，四组间严格串行。

- **组 1 · 素材提炼与事实核对（含 RED）**：静态素材=共性字段清单+三模板路线差异表+反例 F1–F12 核对到 file:line；动态素材（RED）=skill 落盘**前**起未加载本 skill 的子代理在 dsh-plugins 仓「从零搭最小 host-only 插件并让它可安装」，观察至首个构建/装载失败点即止，**逐字记录**踩坑与合理化借口；基线零失败则按「control 不失败无需修」上浮待决。验证：素材清单每条 `test -e <路径>`；RED 记录含 ≥1 条逐字借口引用；压测目录清理后 `git status --short` 无残留。
- **组 2 · SKILL.md 与分册撰写（GREEN）**：先 SKILL.md 路由再四分册，形态/键集/骨架照③节契约；纪律：description 只写触发+让位、零版本数字（`0.2.1`/`rc.N` 一律指向 `dsh-baseline.mjs`）、分工声明放开篇、止于安装验证、分册只指路+增量。验证：`grep -nE '0\.2\.[0-9]|rc\.[0-9]' SKILL.md references/*.md` 零命中；引用路径逐一 `test -e`；`wc -l SKILL.md` ≤150。
- **组 3 · frontmatter 结构校验**：键集恰两键（sed+grep 断言）；name 合法；description 字符数 ≤300（node 断言）；YAML 可解析且必填键 string（skctl 同款 gray-matter 断言）。任何一项不过回组 2。
- **组 4 · skctl 登记与 README 补行**：先 README 行再 `skctl install`（重名即抛错=天然门禁）。验证：`node $SKCTL list --all --desc | grep dsh-plugin-writer` 命中；`readlink ~/.local/share/agent-skills/skills/dsh-plugin-writer` 输出实体目录；registry `source.type=local`；容器视图 `ls -d /home/docker/.agents/skills/dsh-plugin-writer` 存在；README `grep -n` 恰命中新行。
- **组 5 · 发现与加载验证**：新会话目录含 `dsh-plugin-writer` 条目；`/inventory` 含之；`skill dsh-plugin-writer` 实际加载返回正文（反向：拼错名应报不可用）；触发三语句各 1 子代理（新增插件→命中；profile 一次性功能→让位官方；行为规格→openspec-propose）。目录不可见先查 session-tool-toggle `skill:` 开关（F11 假故障）。
- **组 6 · dsh-plugins 侧演练（GREEN/REFACTOR，产物清理不入库）**：`plugins/demo-echo/` 按本仓约定搭最小 host-only 插件（件套与 D6 复制策略、version `0.0.0`——dsh:check 七断言不含版本统一，统一版本是 release.mjs 职责，正式入库规则写进 structure.md）；命令链 `pnpm install` → `pnpm --filter dsh-plugin-demo-echo verify:all` → `pnpm dsh:check` → `docker exec dsh dsh plugin --profile web add <本仓>/plugins/demo-echo`（本地路径=link: 调试安装）→ `docker exec dsh dsh --profile web --dump-config-schema`；双端分支抽验（强度=执行期用户决策，见 Open Questions）；REFACTOR 回填 skill 后重跑组 3 断言与受影响步骤；清理四步（D7）。验证：各命令退出码 0；`--dump-config | grep demo-echo` 出现注册行；终态 `git status --short` 不含 demo-echo。

## Risks / Trade-offs

- [双源漂移（最高）] skill 复述事实必随仓库演进过期（实证 AGENTS.md rc.2 vs 真源 rc.5）→ 内容策略=指路真源+零版本数字+分册零复述；组 2 grep 断言机械化拦截
- [静默失效] frontmatter 格式错=整条随警告丢弃，无逐条诊断 → 组 3 四项结构断言 + 组 5「目录可见+实际加载」双验证
- [触发不稳] 误触发浪费 token / 漏触发失效 → description 明确触发+让位条件；组 5 三语句请求级实证；摇摆升级 5 轮微测（分3）
- [本机遮蔽] 聚合层/项目根出现同名 skill 时 rank 高者胜 → 组 4 登记前重名检查（install 抛错门禁）+ 仓内唯一宿放约定
- [演练扰动] demo 包被 dsh:check 动态枚举纳入断言面（`check-dsh-baseline.mjs:149`）→ devDeps 照抄 zcode-plan（D6）保 lockfile 解析集不变；异常时以脚本输出回填必改清单
- [DSH 版本演进] 0.3.x 机制可能变 → skill 只依赖默认机制；维护挂靠=随 `pnpm dsh:upgrade` 复验发现层（一行建议写入 skill 维护说明，收敛 C8）

## Migration Plan

- 部署序：dotfiles 新建实体 → README 补行 → `skctl install`（即时生效，运行中 dsh 免重启实测）→ 验证组 5。
- 回滚：`node $SKCTL uninstall dsh-plugin-writer -y` + 删除实体目录与 README 行（git revert 单提交）。
- 演练残留回滚：见 D7 四步（`dsh plugin remove` → `rm -rf plugins/demo-echo` → `pnpm install` → `git status` 断言）。

## 设计假设与未决项（深度契约 ⑥）

假设：A1 六任务组口径即 tasks.md 分组口径（有变以 tasks 为准回改映射，不回改收敛）；A2 skctl 可执行（`tools/skctl/node_modules` 在位实测，node 走 docker 包装）；A3 演练环境可用（`docker exec dsh` 为日常命令；不可用则组 6 降级只读评审并显式记录）；A4 用户级根对新会话/子代理同样注入（writing-skills 即经该机制在子代理可用，同源旁证）；A5 zh-CN 正文+英文键名不影响加载（spring-writer 等长期在用旁证）；A6 description 断言用原始字符数（规范化只折叠/截断不扩增，原始 ≤300 是充分上界）；A7 双端硬断言止于 `--dump-config` 注册行（浏览器启动图无 CLI 级硬断言手段）。

## Open Questions

- **双端抽验强度**（分1，用户明示留执行期决策）：a) 硬断言止于 `--dump-config` 注册行 + Web UI 入口人工目检（推荐——F1 静默消失发生在启动图层，目检对症）；b) 追加浏览器半加载图证据。执行组 6 双端分支前询问用户。
- **U-B 触发词共存路由**（「插件」一词与 openspec-*/官方 skill 的归属）：组 5 三语句是唯一实证手段；出现双命中/误让位则调 description 触发词后重测。
- **U-A 演练包与 dsh:check 断言面**：若触发七断言以外的检查失败，以脚本输出为准回填 structure.md 必改清单。
