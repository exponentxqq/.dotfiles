# 代码级设计（阶段 1.7）——unify-spec-plan-questioning：spec-plan「追问契约」+ grill-me 双轨承载

- 变更名：`unify-spec-plan-questioning`；**触达仓 = dotfiles 根仓（唯一）**（不触达 docker、dsh-plugins、容器本地文件）。
- 上游：`explore.md`（阶段 1 串行草案）+ `decisions.md`（阶段 1.5 Q1–Q8 全部结论，**硬边界**——本文不推翻、不重开；发现事实性偏差只上浮「待决问题」）。
- 角色：代码设计线。上游已覆盖「哪些落点要问」，本文只回答「哪些文件、哪一行、写成什么形状、为什么这么定、怎么验」。
- 日期：2026-11-12。所有 file:line、码点、行数为本轮实测；openspec CLI 实测 `1.16.0`。

**硬约束源：`writing-skills` 已加载成功**（base dir `/home/docker/.agents/skills/writing-skills`，含 `SKILL.md` 与 `anthropic-best-practices.md` / `testing-skills-with-subagents.md`）。其规范在本设计中的落点：

| writing-skills 要求 | 本文落点 |
| --- | --- |
| frontmatter 仅 `name`+`description`，description 只写触发条件、不概述流程（SDO） | **不动两个 skill 的 frontmatter 与 description**；契约节只进正文（⑤ 组 2/4 的「deletions=0」断言） |
| Match the Form to the Failure：纪律型失败用禁止+范围；形状型失败用 recipe；条件型行为用可观察谓词做条件 | ①「一律经工具、不得裸文本」（纪律）；②「背景/解释/选项区别/举例」是每问必须含的部件（recipe）；③ grill-me「宿主有工具→工具轨；无工具→markdown 轨」是可观察条件（条件型） |
| Iron Law：改 skill 也要先有失败基线 | ⑤ 组 1 的 RED 基线与组 6 的 GREEN 复测（子代理代理测试；见 ④ D10） |
| Token efficiency：细节按消费时机外移，入口克制 | 契约 4 条 **258 cp**；承载字段细节进 grill-me 权威源，不新建 refs 文件（④ D5） |
| 防措辞漏洞：不加「尽量/除非」这类可协商措辞 | 「一律 / 全部 / 不得」；唯一例外写成可观察事实「子代理/成员不直接提问」（平台限制），不是主观豁免 |
| 引用其他 skill 用名称 + 明确要求，不用 `@` 强制加载 | 契约第 4 条与接线句只写 `SKILL.md 第十节『追问契约』`、grill-me `Carrier by host` 段，不写 `@` |

**实测基线（码点 = `python3 len(open(...).read())`；渲染 = 文件 − frontmatter + 343 包裹）**

| 文件 | 行 | 现码点 | 本设计后 | 说明 |
| --- | ---: | ---: | ---: | --- |
| `agent/skills/spec-plan/SKILL.md` | 122 | **7687**（frontmatter 239 / 正文 7448；9 个 `## `） | **7945** | 现渲染 **7791**；加 §十 后渲染 **8049**，硬阈值 8192，余量 **143**（path 取宿主 56 字符时余量 129） |
| `refs/planning.md` | 82 | 7372 | 7453 | +header 句 +1.75 注记 |
| `refs/failure-modes.md` | 21 | 2990 | 3040 | +header 句 |
| `refs/routing.md` | 67 | 4349 | 4378 | `:65` 改写 |
| `mode/serial.md` | 26 | 1810 | 1839 | `:11` 改写 |
| `mode/parallel.md` | 55 | 2726 | 2749 | `:53` 插句 |
| `refs/convergence.md` | 32 | 2513 | 2560 | 末行改写 |
| `agent/skills/grill-me/SKILL.md` | 32 | 2301 | 3218 | +917 cp 英文承载段 |

**三条全局结论**

1. **spec-plan 侧 0 MODIFIED**：主规格 12 条逐条核对（⑤ 5.0 表）均无「问法/承载」硬编码；1.75 的 Requirement **不在主规格**（在未归档变更 `add-ui-demo-gate` 的 delta），本变更无法也不应 MODIFIED 它。
2. **契约节落在入口第 122 行后，编号 `## 十、追问契约`**：只追加、不重编号，既有 9 个 `## ` 标题与全部「第 X 节」引用零改动；4 条 bullet = 用户三条要求 + 范围/子代理/grill-me 接线。
3. **grill-me 是承载细节的唯一权威源**：英文新增 `## Carrier by host` 双轨段（917 cp），既有 markdown 轮格式块与全部方法论段落**逐字不动**（插入位置在格式块与 “Word each question…” 之间）。

---

## ① 触达面清单

> 编号即 `tasks.md` 任务描述要引用的「触达#N」。全部路径相对 `/home/xuqinqin/develop/dotfiles`；**仓 = dotfiles 根仓**（本变更无子仓）。「阶段 2」= 落档工件，本设计线只给形状、不落盘。

| # | 路径 | 仓 | 动作 | 改动意图 | 关键改动点（行级锚） |
| --- | --- | --- | --- | --- | --- |
| 1 | `agent/skills/spec-plan/SKILL.md` | dotfiles | 修改 | 新增独立「追问契约」节，作为本 skill 全部追问的单点权威 | 第 **122 行**（§九「绝不做」段末）后追加 §十；**258 cp / 4 条 bullet**；不重编号、不改 §一–§九 任何文字（⑤ 2.1 以 `git diff --numstat` 删除行=0 断言） |
| 2 | `agent/skills/spec-plan/refs/convergence.md` | dotfiles | 修改 | 并行 1.5 的提问总句：点名工具 + 指向契约 + 保留单选/多选/推荐项 | **`:32`** 末行整句改写（原「用提问工具（单选/多选 + 推荐项）…」→ 新句点名 `ask_user_question` + 指向 §十；成品见 ③3.2） |
| 3 | `agent/skills/spec-plan/refs/planning.md` | dotfiles | 修改 | 文件头一句覆盖本文件全部追问；1.75 固定三选一就地注记「只换承载」 | **`:1` 后**插 header 句；**`:60`** 的 1.75 确认问法就地改写（三选项字面不动）；`:9`（root null）、`:12`（openspec-explore 缺失）、`:22`（栈识别未命中）由 header 句覆盖，不逐点插 |
| 4 | `agent/skills/spec-plan/refs/failure-modes.md` | dotfiles | 修改 | 异常/失败处置表的 4 处「问用户 / 由用户决定」统一纳入契约 | **`:1` 后**插 header 句（点名「问用户」与「由用户决定」）；`:9`、`:12`、`:13`、`:14` 四行不再逐行加括号（④ D4） |
| 5 | `agent/skills/spec-plan/refs/routing.md` | dotfiles | 修改 | 参数语法错误的「更正后重发」从裸文本报错改为工具问询 | **`:65`** 整条改写：先「按契约发起更正问询」，再报告错误与合法键 |
| 6 | `agent/skills/spec-plan/mode/serial.md` | dotfiles | 修改 | 串行 1 的零星澄清与 1.5 分轮提问共用一句接线 | **`:11`** 第 3 条末尾追加「两类提问均按…发起」 |
| 7 | `agent/skills/spec-plan/mode/parallel.md` | dotfiles | 修改 | 回执核对里「并入 1.5 统一提问」的承载接线 | **`:53`** 在既有括号内插「按 SKILL.md 第十节『追问契约』发起」 |
| 8 | `agent/skills/grill-me/SKILL.md` | dotfiles | 修改 | 英文双轨承载段：有工具宿主轮次经工具，无工具宿主保持 ❓/➡️；方法论两轨共用 | **`:24` 后、`:26` 前**插入 `## Carrier by host`（3 段 / 917 cp）；`:12-24` 格式块、`:26`（yes 措辞）、`:28`（重算前沿）、`:30`（事实自证）、`:32`（结束条件）**逐字不动** |
| 9 | `openspec/changes/unify-spec-plan-questioning/specs/spec-plan/spec.md` | dotfiles | **新建**（阶段 2） | spec-plan 侧 delta：**只 ADDED** 1 条「追问交互契约」+ 7 个 Scenario | `## ADDED Requirements` ×1；**无 `## MODIFIED Requirements`**；正文 298 cp（≤500）；骨架见 ③3.4 |
| 10 | `openspec/changes/unify-spec-plan-questioning/specs/grill-me/spec.md` | dotfiles | **新建**（阶段 2） | **新 capability** delta：`## Purpose` + 2 条 ADDED（承载自适应 / 每问质量与推荐） | Purpose 120 cp（≥50）；2 条 Requirement 正文分别 267 / 147 cp（≤500）；Scenario 共 7 个；骨架见 ③3.4 |
| 11 | `openspec/changes/unify-spec-plan-questioning/proposal.md` | dotfiles | **新建**（阶段 2） | 变更动机、范围与 capability 归属 | `## Why` 50–1000 字符（validator `constants.js:5,8`）；`## Capabilities`：New = `grill-me`，Modified = `spec-plan` |
| 12 | `openspec/changes/unify-spec-plan-questioning/design.md` | dotfiles | **新建**（阶段 2） | 逐断言承载本文六字段；决策记录含栈识别结论与 1.75 未触发判定 | 六节名与本文一致；决策记录必须含：**栈识别 = `writing-skills`**（证据 = 本轮加载回执 + `decisions.md:46-47`）、**0 MODIFIED 的 12 条核对结论**、§十 258 cp 预算、grill-me 双轨决策；阶段 1.75 未触发一行由主会话按 gate 追加 |
| 13 | `openspec/changes/unify-spec-plan-questioning/tasks.md` | dotfiles | **新建**（阶段 2） | 执行批次：6 组（RED + 入口 / 接线 / grill-me / delta / 工件验证） | 每任务一行 `- [ ] N.M …；验证：…`，描述引用触达#N；组内不写同一文件；单组 ≤ `parallelism: 8`（`dsh/spec-workflow.yaml:47`） |
| 14 | `openspec/changes/unify-spec-plan-questioning/code-design.md` | dotfiles | 复制（阶段 2） | 本文件落档副本，自此为权威 | `cp /tmp/spec-flow/unify-spec-plan-questioning/code-design.md …`；`cmp -s` 断言 |
| 15 | `openspec/changes/unify-spec-plan-questioning/decisions.md` | dotfiles | 复制（阶段 2） | 阶段 1.5 收敛留痕落档 | 同上；`cmp -s` 断言 |
| 16 | `openspec/changes/unify-spec-plan-questioning/.openspec.yaml` | dotfiles | **新建**（阶段 2） | openspec 变更元数据，`validate` 的前置 | `schema: spec-driven` + `created: 2026-11-12`（格式照 `add-ui-demo-gate/.openspec.yaml:1-2`） |

**明示非触达（防执行侧扩散）**

| 路径/对象 | 结论 | 依据 |
| --- | --- | --- |
| `openspec/specs/spec-plan/spec.md` | **不改** | 主规格只由 `openspec archive` 经 delta 同步；本轮 12 条逐条核对结论 = 0 冲突（⑤ 5.0） |
| `openspec/specs/grill-me/spec.md` | **当前不存在，本变更不建** | 新 capability 仅在归档时由 delta 的 `## Purpose` 生成（先例 `add-ui-demo-gate/specs/ui-demo/spec.md:3-5`） |
| `agent/skills/README.md` | **不改** | `:31` 已登记 `grill-me` / `spec-plan`；本变更不新增 skill，无登记行可加 |
| `dsh/spec-workflow.yaml` | **不改** | 无新规划键；`:47` 的 `parallelism: 8` 只被 tasks 分组上限消费 |
| `dsh/commands/*.md` | **不改** | 命令薄壳只转发 `$ARGUMENTS`，不复述问法 |
| `openspec/changes/add-ui-demo-gate/**` | **不改** | 只引用其 1.75 delta 作事实（`specs/spec-plan/spec.md:5`），不修不归档 |
| 宿主聚合层 symlink / `registry.json` | **不改** | `spec-plan`、`grill-me` 均已注册且 symlink 指向仓库目录（② E）；改源文件即生效，无需 `skctl install` 或重启 |

---

## ② 证据锚

### A. spec-plan 入口（插入点与长度红线）

- `agent/skills/spec-plan/SKILL.md:122`——文件末行（§九「绝不做」段最后一句「工件未过 `--strict` 校验不提交。」）；§十 追加于此行之后。文件共 122 行 / 9 个 `## ` 标题 / 7687 cp（frontmatter 239 cp）。
- 同名 `:52`——§三「模式收集」唯一规则「一次只问该阶段需要的选项，已由参数预置的不再问，绝不自行假设」→ 契约的「全部追问」覆盖它，**不改**（避免与 §一 `:26` 的重复再加一层）。
- 同名 `:75`——§四中转协议②「主会话**立即**代问，不积压、不另开通道」→ 主会话代问属契约范围，由契约第 1 条覆盖，**不自加指针**（省 cp；见 ④ D2）。
- 同名 `:86`——§五⑤「问决策项（`grill-me` 设计树**只问前沿**、每轮 **≤5 问**、附**推荐与来源**）」→ 方法论不动，承载由契约 + grill-me 新段接管。
- 同名 `:94`——§六 1.7 段「（未命中问用户三选一，**不静默跳过**）」；`:98`——1.75 gate「交用户确认」→ 两处是入口内的追问落点，由契约的适用范围句覆盖；1.75 的细粒度问法在 `planning.md:60`。
- 同名 `:104`——§七③「分歧点提问…一次问清；不自行拍板」→ 同上。
- 同名 `:116-120`——§九红线表（无 openspec 根 / `DELEGATED_CALLER` / 设计草案矛盾）→ 表内「问 init / store / 放弃」「主会话立即代问」「并入落档分歧点提问」均由契约覆盖；**表本身不改**（长度与语义稳定性）。
- `openspec/changes/archive/2026-10-14-spec-workflow-slim-entry/execution-log.md:79`——包裹 343 cp 的实测来源（`dsh-skill` `renderSkillContent` 模板 + path）；`:166-169`——渲染后总量 7957 ≤ 8192 的实测；`openspec/changes/archive/2026-10-14-spec-workflow-externalize-references/execution-log.md:72`——pruner 阈值 8192 / head 4096 / tail 1024。**本设计沿用 file − frontmatter + 343 的口径。**

### B. refs / mode（逐文件一个承载点）

- `refs/convergence.md:32`——末行「用提问工具（单选/多选 + 推荐项）**按前沿分轮**问；**只问决策，不问事实**。」是全仓唯一把「用提问工具」当**行动指令**却未点名的处（`SKILL.md:72` 与 `mode/parallel.md:45` 也出现「提问工具」，但那是「子代理不能调用」的平台事实，不是主会话的行动指令）；本设计整句改写。
- `refs/planning.md:1`——文件头「本文件为 SKILL.md §二…§六…§七…的外移正文」；`:9`——root null 三选一；`:12`——openspec-explore 不可加载「报告问用户三选一」；`:22`——栈识别未命中「问用户三选一」；`:60`——1.75「确认问法（一次问清）…①确认 ②要改 ③降档/豁免」；`:76`——落档「分歧点提问…一次问清」。共 6 个追问落点，文件头一句 + 1.75 注记即可覆盖。
- `refs/failure-modes.md:1`——文件头；`:4-19`——处置表；`:9`（由用户决定）、`:12`（问用户三选一）、`:13`（问用户三选一）、`:14`（报告问用户）→ 表头一句覆盖 4 行。
- `refs/routing.md:65`——「参数语法错误…→ 报错并列出合法键（含 `vision`），要求更正后重发，不猜。」→ L9 纠错通道的唯一具体落点。
- `mode/serial.md:11`——「问答节奏：零星澄清可即问…系统性待决汇聚到阶段 1.5 分轮提问」；`:18`——「按 `grill-me` 分轮提问」（承载由契约第 4 条指向 grill-me 新段，无需第二句）。
- `mode/parallel.md:53`——回执核对段「两线上浮的**待决问题按中转协议②并入阶段 1.5 的设计树/前沿统一提问**（不另开问答通道，不积压到阶段末）」→ 插句位置。
- 行数与码点见基线表；六个文件的现有码点均远低于 8192（最高 planning 7372），加句后仍 ≤7453。

### C. grill-me（承载段插入点与方法论不动）

- `agent/skills/grill-me/SKILL.md:12-24`——markdown 轮格式代码块（`❓ **Q1** - **<question title>**: …` + `➡️ <recommended answer>`）→ 新段必须说「shown above unchanged」，并插在 `:24` 之后、`:26` 之前。
- 同名 `:26`——「Word each question so "yes" accepts your recommended answer.」；`:28`——「Each round the user answers reshapes the tree… Recompute the frontier…」；`:30`——「Finding _facts_ is your job…」；`:32`——「The session is done when the frontier is empty…」→ 四段全部保留，新段的第三段只复述「设计树/前沿/3–5 问/推荐措辞/答完重算」为两轨共用，**不重复细节**。
- 文件共 32 行 / 2301 cp；新增段 917 cp → 3218 cp，远低于 8192。

### D. 主规格、delta 先例与 openspec 校验事实

- `openspec/specs/spec-plan/spec.md` 共 346 行 / **12 条 Requirement**：`:10`（规划入口）、`:29`（双线差异收敛）、`:73`（1.7 设计线）、`:102`（子代理中转）、`:126`（落档工件）、`:175`（模型路由）、`:199`（读图与回退）、`:223`（压缩后存活）、`:242`（单次加载交付）、`:261`（栈识别）、`:300`（并行双线）、`:329`（串行单线）。逐条核对见 ⑤ 5.0。
- `openspec/changes/add-ui-demo-gate/specs/spec-plan/spec.md:5`——未归档变更里的「阶段 1.75 界面演示 gate」Requirement（**不在主规格**）；`:31`——该变更的 MODIFIED「落档工件与执行批次契约」（先例：MODIFIED 必须整块携带主规格 scenario）。本变更不复制该模式。
- `openspec/changes/add-ui-demo-gate/specs/ui-demo/spec.md:3-5`——新 capability delta 的 `## Purpose` 先例；`openspec/changes/add-ui-demo-gate/.openspec.yaml:1-2`——`schema: spec-driven` + `created`。
- `openspec/config.yaml:1`——`schema: spec-driven`；`:3-6`——`context` 要求工件简体中文、结构标题与 SHALL/MUST 保留英文。
- `refs/planning.md:16-52`——阶段 1.7 深度契约（六字段 + 回执核对），是 `design.md` 逐断言承载的依据；`:67`——`code-design.md` 与 `decisions.md` 复制入变更目录（触达#14/#15）；`:68-75`——`tasks.md` 执行批次契约（`## N.` 分组、验证句、单组 ≤ `parallelism`），是触达#13 的生成依据。
- `/usr/local/lib/node_modules/@fission-ai/openspec/dist/core/validation/constants.js:9`——`MAX_REQUIREMENT_TEXT_LENGTH = 500`；`:5,:8`——Why 50–1000；`dist/core/validation/validator.js:272`——ADDED 正文超 500 记 WARNING；`:898-900`——`--strict` 下 warnings 也判 invalid。**因此 ADDED 正文必须 ≤500，MODIFIED 不受此限（本变更 0 MODIFIED）。**
- `openspec --version` 实测 `1.16.0`；`openspec list --json` 的 `root.path` = 仓库根（本轮实测）。

### E. 工件与部署事实

- `dsh/spec-workflow.yaml:47`——`parallelism: 8`（分组上限的唯一数值来源；tasks 不再写具体数值）。
- `agent/skills/README.md:31`——`grill-me` / `spec-plan` 已在「自写（本目录 local symlink）」行；**无新 skill 登记**。
- 聚合层实测：`/home/docker/.agents/skills/spec-plan -> /home/xuqinqin/develop/dotfiles/agent/skills/spec-plan`、`…/grill-me -> …/agent/skills/grill-me`；`md5sum` 源文件与聚合层视图一致（`0b225b9a172d559a29a0062100c18050` for grill-me）→ 改源文件即生效。
- `git status --porcelain -- agent/skills openspec/specs` 本轮为空 → 八个 skill 文件与主规格当前无未提交改动，变更面干净可断言。

---

## ③ 接口与数据形状

> 本变更是 markdown skill 文档：没有函数/类型/配置键。本字段 = **措辞形状**。以下代码块均为**成品文本，可逐字照抄**；任务编号对应 ⑤。

### 3.1 契约节成品（`SKILL.md` §十，258 cp，含标题前空行与末尾换行）

插入位置：`SKILL.md:122` 之后（空一行）。**逐字如下**：

```markdown
## 十、追问契约

- 本 skill 中向用户的**全部**追问（含纠错与异常处置）一律经**宿主结构化提问工具**（DSH 为 `ask_user_question`）发起，不得裸文本提问。
- 每问必须附**背景**（为什么问、答复影响什么）与**详细解释**，表述清晰易懂、不含糊。
- 存在多个方案/选项时，列出各选项的**详细区别**；涉代码、配置或结构时**举例**说明。
- 子代理/成员不直接提问，仍按第四节上浮；`grill-me` 轮次的承载见其 `Carrier by host` 段。
```

形状要点：
- **节名** = `追问契约`，编号 `十`；**4 条** = 工具强制（含范围 + 禁裸文本）/ 背景与解释 / 选项区别与举例 / 子代理 + grill-me 接线。
- 第 1 条用「**全部**」「**一律**」「**不得**」三处硬措辞，堵「只在正式提问时用工具、纠错/异常走裸文本」的漏洞；范围括号显式点名「纠错与异常处置」（L9）。
- 第 2 条把「背景」的判据写成两个可回答的子问题（为什么问、答复影响什么），避免「背景」被写成一句空话。
- 第 3 条把「详细区别」与「举例」分开，条件分别是「多方案/选项」与「涉代码、配置或结构」——不合并，避免执行侧只做其一。
- 第 4 条是**唯一例外**：子代理/成员受 `DELEGATED_CALLER` 限制，仍按既有中转协议上浮；这不是豁免契约，而是把契约的适用主体限定为主会话。后半句把 grill-me 的承载细节交给其权威源，避免双源。

### 3.2 接线句成品（逐文件，统一指向 §十）

统一句式（除 convergence 的特别改写外，其余文件用同一句或其就地变体）：

> `（按 SKILL.md 第十节『追问契约』发起）`

| 文件 | 锚 | 改动方式 |
| --- | --- | --- |
| `refs/convergence.md` | `:32` | 整句替换（点名工具 + 契约 + 保留单选/多选/推荐项） |
| `refs/planning.md` | `:1` 后 | 新增一行 header blockquote |
| `refs/planning.md` | `:60` | 整句替换（三选项字面保留，只加承载注记） |
| `refs/failure-modes.md` | `:1` 后 | 新增一行 header blockquote（覆盖表内 4 行） |
| `refs/routing.md` | `:65` | 整条替换（先发起更正问询，再报告错误与合法键） |
| `mode/serial.md` | `:11` | 整条替换（两类提问均接线） |
| `mode/parallel.md` | `:53` | 在既有括号内插入一句 |

成品措辞（逐字，可直接落盘；`<…>` 为既有占位符，不替换）：

```text
refs/convergence.md:32
用宿主结构化提问工具 `ask_user_question`（按 SKILL.md 第十节『追问契约』）**按前沿分轮**问（单选/多选 + 推荐项）；**只问决策，不问事实**。

refs/planning.md:1 后
> 本文件所有向用户的提问，一律按 SKILL.md 第十节『追问契约』发起。

refs/planning.md:60
3. **确认问法（一次问清；按 SKILL.md 第十节『追问契约』发起）**：`①确认，转入落档　②要改：<具体点>　③降档/豁免（写明依据）`——**三选项语义不变，只换承载**。**未取得确认不得落档**；否决则改稿重出，不进入落档。

refs/failure-modes.md:1 后
> 本文件所有向用户的提问与「由用户决定」事项，一律按 SKILL.md 第十节『追问契约』发起。

refs/routing.md:65
- 参数语法错误（阶段名非法、缺 `provider/model`）→ 按 SKILL.md 第十节『追问契约』发起更正问询：报告错误并列出合法键（含 `vision`），要求更正后重发，不猜。

mode/serial.md:11
3. **问答节奏**：零星澄清可即问（主会话可直问用户，无 `DELEGATED_CALLER` 限制）；系统性待决**汇聚到阶段 1.5** 分轮提问，防问答碎片化——两类提问均按 SKILL.md 第十节『追问契约』发起。

mode/parallel.md:53（括号内插入）
…**待决问题按中转协议②并入阶段 1.5 的设计树/前沿统一提问**（按 SKILL.md 第十节『追问契约』发起；不另开问答通道，不积压到阶段末）…
```

为什么不逐点复制契约全文：六个文件共 7 句接线（planning 2 句，其余各 1 句）；若每句复制 258 cp 的契约，既造成 7 个漂移源，也把 refs 文件从「按需读取的细节」变成第二权威。接线句只保留「哪个文件第几行的提问 → 去 §十」这一条边，契约文本只有一份。**反例**：若在执行侧只写「用提问工具」而不指向 §十（现状 convergence 的写法），后来者无法知道是哪个工具、要不要附背景/选项区别——这正是本变更要消除的含糊。

### 3.3 grill-me 英文承载段成品（917 cp，插在 `:24` 后；正文 915 cp + 前后各一空行）

````markdown
## Carrier by host

When the host provides a structured question tool (DSH: `ask_user_question`), deliver each round through it: one tool call per round, one entry per frontier question. The entry's question text carries the background (why this is being asked now and what the answer changes) and the explanation a markdown round would have carried. Each option carries a description of how it differs from the others; when the choice involves code, configuration, or structure, include a concrete example. Put the recommended option first and mark it as the recommendation (on DSH, append "(Recommended)" to its label).

When the host provides no such tool, keep the ❓ **Q1** / ➡️ markdown round format shown above unchanged.

Both carriers share the same method: the design tree, the frontier, 3–5 questions per round, recommendations worded so "yes" accepts them, and recomputing the frontier after each answer.
````

段落骨架（三段，各自职责固定）：
1. **工具轨**：触发条件（host provides a structured question tool）→ 轮次单位（one call per round）→ question 文本部件（标题/背景/解释）→ option 部件（区别说明 + 代码/配置/结构举例）→ 推荐（置首 + 标注；DSH 具体标签 `(Recommended)`）。
2. **无工具轨**：显式条件（no such tool）→ 保持上文 ❓/➡️ 格式不变。此段是「不破坏独立 grill 场景」的保险，不是可选建议。
3. **两轨共用方法论**：设计树、前沿、每轮 3–5 问、推荐措辞（yes = 接受推荐）、答完重算——一句话收口，避免与方法论正文重复。

写作约束：不复制 `:26-32` 的方法论细节；不把 `(Recommended)` 写成所有宿主的硬编码（用 “mark it as the recommendation” + DSH 注记）；不改变 `:12-24` 的 markdown 块（它是无工具轨的正文，必须原样保留）。

### 3.4 两条 spec delta 的骨架

#### 3.4.1 `specs/spec-plan/spec.md`（只 ADDED，1 条 Requirement，7 Scenario）

文件结构：

```markdown
# Spec Delta

## ADDED Requirements

### Requirement: 追问交互契约

<正文 298 cp，见下>

#### Scenario: <7 个，见下表>
```

Requirement 正文（298 cp，≤500；含 4 个 SHALL 断言组）：

```text
spec-plan SHALL 把向用户发起的全部追问（含前置检查、参数与模式收集、中转代问、收敛决策、栈识别、界面演示确认、落档分歧及纠错/异常处置）一律经宿主结构化提问工具（DSH 为 `ask_user_question`）承载，SHALL NOT 以裸文本提问；每问 SHALL 附背景说明与详细解释，表述清晰易懂、不含糊；存在多个方案或选项时 SHALL 列出各选项的详细区别，涉代码、配置或结构时 SHALL 举例。子代理/成员 SHALL NOT 直接提问，仍按中转协议上浮。`grill-me` 轮次的承载与问题质量 SHALL 遵循 `grill-me` capability。
```

SHALL 句式要点：①全量 + 工具承载 + 禁裸文本；②背景与解释；③选项区别 + 举例；④子代理不直问 + grill-me 委派。**不写「尽量」「必要时」**——条件都写成可观察的（存在多方案 / 涉代码配置结构）。

Scenario 清单（每条必须 `WHEN` + `THEN`）：

| # | Scenario 名 | WHEN | THEN |
| --- | --- | --- | --- |
| 1 | 全部追问经工具发起 | 任一阶段需向用户提问（参数、模式、收敛、栈识别、演示确认、落档分歧或纠错/异常） | 主会话以 `ask_user_question` 发起，不以裸文本提问 |
| 2 | 每问附背景与详细解释 | 发起任一追问 | 问题正文含背景（为什么问、答复影响什么）与详细解释，清晰易懂 |
| 3 | 多选项列详细区别并举例 | 追问涉及多个方案/选项，或涉及代码、配置、结构 | 各选项附详细区别；涉代码/配置/结构时附具体例子 |
| 4 | 纠错与异常通道同样适用 | 参数语法错误需更正，或异常处置需用户裁决 | 同样经工具发起，不以裸文本要求重发或裁决 |
| 5 | 子代理不直接提问 | 被拥有的子代理或团队成员需用户拍板 | 不调用提问工具（`DELEGATED_CALLER`），按中转协议上浮，由主会话代问 |
| 6 | grill-me 轮次经工具承载 | 阶段 1.5 按 grill-me 分轮提问 | 每轮经工具承载；问题含背景与解释、选项含区别、推荐项置首（细则见 grill-me capability） |
| 7 | 既有问法语义不变 | 追问改经工具承载 | 1.75 三选项语义（确认/要改/降档或豁免）、grill-me ≤5 问/轮与只问前沿、未修改 Requirement 的行为语义均不变 |

**文件里不得出现 `## MODIFIED Requirements`**。1.75 的 Requirement 不在主规格，不能 MODIFIED（⑤ 5.0 注）。

#### 3.4.2 `specs/grill-me/spec.md`（新 capability：Purpose + 2 条 ADDED，7 Scenario）

文件结构：

```markdown
# Spec Delta

## Purpose

<120 cp，见下>

## ADDED Requirements

### Requirement: 轮次承载（宿主自适应）
### Requirement: 每问的背景、区别与推荐
```

Purpose（120 cp，≥50）：

```text
追问访谈能力的轮次承载：在提供结构化提问工具的宿主上把每轮追问经工具承载（每题含背景、解释、选项区别与置首推荐），无此工具的宿主保持 ❓Q/➡️ markdown 轮格式；设计树、前沿、每轮 3–5 问、推荐措辞与答完重算等方法论两轨共用。
```

Requirement 1「轮次承载（宿主自适应）」（267 cp，≤500）：

```text
grill-me SHALL 按宿主能力选择轮次承载：宿主提供结构化提问工具（DSH 为 `ask_user_question`）时，每一轮 SHALL 为一次工具调用、前沿中每题一个条目；条目的 question 文本 SHALL 含问题标题、背景（为何现在问、答复改变什么）与解释，每个 option SHALL 附与其他选项的区别说明，推荐项 SHALL 置首并标注推荐；宿主无该工具时 SHALL 保持 ❓Q/➡️ markdown 轮格式。设计树、前沿、每轮 3–5 问、推荐措辞与答完重算 SHALL 为两轨共用的方法论。
```

Requirement 2「每问的背景、区别与推荐」（147 cp，≤500）：

```text
grill-me 的每个追问 SHALL 附背景说明与详细解释，表述清晰易懂；存在多个方案或选项时 SHALL 列出各选项的详细区别，涉代码、配置或结构时 SHALL 举例；每题 SHALL 给出推荐答案，措辞 SHALL 使「是/同意」等于接受该推荐，工具承载时推荐项 SHALL 置首标注。
```

Scenario 清单：

| Requirement | # | Scenario 名 | WHEN | THEN |
| --- | --- | --- | --- | --- |
| 轮次承载 | 1 | 有工具宿主一轮一次调用 | 宿主提供结构化提问工具 | 每轮为一次工具调用，前沿每题一个条目 |
| 轮次承载 | 2 | 无工具宿主保持 markdown 轮格式 | 宿主无结构化提问工具 | 保持 ❓Q/➡️ markdown 轮格式不变 |
| 轮次承载 | 3 | 两轨方法共用 | 任一承载轨 | 设计树、前沿、每轮 3–5 问、推荐措辞、答完重算一致 |
| 每问质量 | 4 | 每问附推荐且「是」等于接受推荐 | grill-me 提问 | 每题给出推荐答案，措辞使「是/同意」= 接受推荐 |
| 每问质量 | 5 | 多选项列区别并举例 | 问题含多个方案或涉代码/配置/结构 | 各选项附区别说明；涉代码/配置/结构时举例 |
| 每问质量 | 6 | 每问附背景与解释 | 发起任一追问 | 问题正文含背景与详细解释，清晰易懂 |
| 每问质量 | 7 | 工具轨推荐置首 | 轮次经结构化提问工具承载 | 推荐项置首并标注推荐 |

### 3.5 工件文件结构（阶段 2，供 openspec-propose 逐字生成）

- `proposal.md`：`## Why`（50–1000 字符；本变更约 200 字）→ `## What Changes`（7 个 spec-plan 文件 + grill-me + 2 delta + 0 MODIFIED）→ `## Capabilities`：`### New Capabilities` = `grill-me`（承载自适应 + 每问质量），`### Modified Capabilities` = `spec-plan`（只 ADDED「追问交互契约」）。
- `design.md`：逐断言承载本文 ①–⑥；决策记录额外承载 ④ 的 D1–D13（至少含 0 MODIFIED、258 cp、双轨、栈识别 `writing-skills`）；末尾按 1.75 gate 追加一行未触发判定（预计「C1 不成立：纯 skill 文档，无界面产出」）。
- `tasks.md`：`## N. 组名` 六组（见 ⑤）；每任务一行 `- [ ] N.M <描述，引用触达#N>；验证：<命令或断言>`；组内任务写不同文件；单组 ≤8。
- `.openspec.yaml`：`schema: spec-driven` + `created: 2026-11-12`。

---

## ④ 决策记录

> 每条 = 决定 + 被否方案与理由。被否方案里至少一条是「看起来更省事但会埋洞」的反例。

**D1 契约节编号与位置：`## 十、追问契约`，追加在 `SKILL.md:122` 之后。**
被否：① **插在 §一 后作无编号 `## 追问契约`**——更早可见，但破坏「一–九」编号体例，且 `## ` 计数与既有「第 X 节」引用风格不一致；② **插作 `## 二` 并整体顺延**——会改动 §三–§九 的标题编号，直接违反既有 Requirement「压缩后指令完整存活」的 Scenario「节标题与 skill 名称描述不变」（`specs/spec-plan/spec.md:240`），并迫使 6 个 refs/mode 文件与入口内所有「第 X 节」引用重映射，爆炸半径远超收益；③ **并入 §三 改造**——Q3 已否，§三管「一次只问该阶段需要的」的节奏，契约管「怎么承载/质量」，语义正交。反例：重编号看似只是数字，实际会让 `refs/convergence.md:1`、`refs/planning.md:1` 等十余处「SKILL.md 第 X 节」全部失真，是典型「省一步、坏一片」。

**D2 契约正文形态：4 条 bullet（258 cp），把三条要求拆成「工具 + 背景/解释 + 选项区别/举例」，再加范围/子代理/grill-me 一条。**
被否：① **写成一段散文**——4 条要求挤在一段里，执行侧难以逐条自检；② **只写三条、不写子代理与 grill-me**——会与既有「子代理 SHALL NOT 直接提问」的 Requirement 冲突（子代理照契约调用工具会被 `DELEGATED_CALLER` 拒绝），且 grill-me 的承载没有接线；③ **加「尽量/除非」缓和**——writing-skills 明确「nuance clause 会重新打开协商」，本变更是纪律型失败（裸文本提问），必须用「一律/不得」。
反例：若把子代理写成「也一律经工具」，执行侧会真的去调用并撞 `DELEGATED_CALLER`，然后误判工具损坏——这是把平台事实写成禁令的典型反例。

**D3 工具名：抽象「宿主结构化提问工具」+ 实名注记 `ask_user_question` 一次；接线句只指向契约，只有 convergence 末行按用户要求点名工具。**
被否：① **照原文写 `ask_question`**——本部署实际工具名是 `ask_user_question`（本会话工具清单实测），写错名会让执行侧调不到工具，验证 grep 也失去意义；② **只写实名、不写抽象**——宿主改名即全仓失真，且与「所有追问」的通用语义不符；③ **每个接线句都写实名**——7 个漂移点，Q1 已裁定「抽象定义 + 实名注记」；④ **每个接线句都重复「背景/解释/区别」**——复制契约全文（Q 已否，且 7 处漂移）。
反例：工具名是**可执行事实**，不是修辞；`ask_question` 在本仓 grep 为零（实测），照原文写等于给未来会话一个不存在的工具名。

**D4 接线粒度：planning / failure-modes 用文件头一句覆盖全部落点；routing / serial / parallel 在各自的提问总句就地插一句；convergence 末行整句改写；planning 的 1.75 另加一句「三选项语义不变」。**
被否：① **每个落点都插同一括号**——planning 6 处、failure-modes 4 处，共 10 次重复，表格/正文噪音大，且同一句重复 10 次仍是单源（没有增加信息）；② **六个文件全部只在文件头加一句**——routing / serial / parallel 的提问总句很短，就地插句比让读者回看文件头更直接；③ **只在入口契约节声明、六个文件完全不加**——refs/mode 是按需单独读取的，执行侧可能只读其中一个文件，必须在消费点可见。
反例：failure-modes 是 21 行表格，4 行都加括号会让「处置」列被同一句占满；表头一句点名「问用户 / 由用户决定」已精确覆盖这 4 行，且验证可 grep 文件级断言。

**D5 长度：契约 258 cp、不新建 refs 文件、不删改既有入口文字；渲染余量 143。**
被否：① **新建 `refs/questioning.md` 存契约细则 + 入口留路由**——Q3 已选「独立节、不外移新文件」；新建文件要加一行路由（~60 cp）、多一次读取跳转，而三条要求本身只有 258 cp，外移的收益为负；② **为腾预算删/改既有入口段**——会碰红线（§四中转、§九绝不做、恢复速查），且「语义不变」的验证面变大；③ **把契约压到 150 cp 以内**——必须删掉「范围（含纠错/异常）」「子代理例外」「grill-me 接线」之一，正好留下执行侧最容易钻的洞。
反例：为省 100 cp 删掉「含纠错与异常处置」，执行侧会把参数纠错当「不是提问」而继续裸文本——省下的 cp 远小于返工成本。

**D6 grill-me 承载段：英文 `## Carrier by host` 三段、插在格式块后；双轨条件 + 两轨共用方法论；既有 markdown 块逐字不动。**
被否：① **把 grill-me 全量改写成工具轨**——无工具宿主（独立 grill 场景）直接失效，违反 Q7「双轨自适应」；② **只在 spec-plan 契约里写承载、不改 grill-me**——Q2 已选「连带改」，且 grill-me 是独立 skill，独立使用者没有 spec-plan 的契约可依；③ **新建 `agent/skills/grill-me/refs/carrier.md`**——只有 917 cp，拆文件反而增加读取跳转与维护面；④ **重写 `:12-24` 的 ❓/➡️ 格式块**——它是无工具轨的正文，重写会破坏既有行为。
反例：若只改 spec-plan，用户在别的场景直接 `grill me` 时仍只有 markdown 轮格式，本次需求在「独立使用 grill-me」路径上等于没做。

**D7 spec delta 形态：只 ADDED 1 条 + 新 capability 2 条；spec-plan 侧 0 MODIFIED。**
被否：① **全量 MODIFIED 12 条**——MODIFIED 会整块替换主规格 requirement（含全部 scenario），12 条意味着把 346 行主规格几乎重写一遍，校验面、审阅面、归档冲突面全部放大；而 12 条里没有一条写死**主会话**提问的工具或问法（#4 只规定子代理不得直问，与本契约同向）；② **MODIFIED「看起来最相关」的 4–5 条**（规划入口 / 双线收敛⑤ / 中转 / 栈识别 / 1.75）——逐条读原文，它们只规定「何时问、问什么、怎么收敛」，没有 `ask_user_question`、没有固定文本格式，ADDED 契约是可叠加的上位规则，MODIFIED 属于「为了显得一致而改」；③ **把契约写进主规格**——主规格只能由 archive 经 delta 同步，手改违反流程。
反例：全量 MODIFIED 的最大代价不是写，而是 archive 时每个 requirement 都要带全 scenario；任何一个 scenario 漏拷，`openspec validate` 的 MODIFIED 平衡检查会报错（先例 add-ui-demo-gate 的 MODIFIED 整块携带主规格 9 个 scenario，并追加新增 scenario）。0 MODIFIED 让这次变更只需验证 ADDED 的 500 字符与 scenario 完备性。

**D8 grill-me 新建 capability：`specs/grill-me/spec.md`，Purpose + 2 条 Requirement（承载自适应 / 每问质量与推荐）。**
被否：① **不建 spec**——Q8 已选新建；grill-me 的行为变化（双轨承载、选项区别、推荐置首）没有正式 Requirement，归档后无验收锚；② **只建 1 条大 Requirement**——承载机制与问题质量是两类可独立验收的行为，合并后 scenario 会混在一起，审阅粒度差；③ **塞进 spec-plan spec**——capability 归属错误，archive 会把 grill-me 的行为写进 spec-plan。
反例：把「有工具宿主 / 无工具宿主 / 推荐置首 / 选项区别」四条塞进一条 Requirement，等于让一条 requirement 同时承担条件分支与质量约束，审阅粒度与未来修订都会变难（ADDED 虽不受 MODIFIED 的 scenario 平衡检查约束，但 scenario 混在一起同样难核对）。

**D9 1.75 三选项语义保留：`planning.md:60` 只加「按契约发起；三选项语义不变，只换承载」，不改 ①②③ 字面。**
被否：① **重写三选项（如加「④其他」）**——改变确认 gate 的语义，超出本变更范围；② **把三选项改成工具字段的 options 数组描述**——`planning.md` 是主会话执行手册，保留可读的固定三选项更稳；工具承载时把这三项原样放进 options 即可；③ **不注记、只靠 header 句**——执行侧可能把 `①确认 ②要改 ③降档/豁免` 当成「必须用文本输出这三行」，注记把「只换承载」说死。
反例：把「③降档/豁免（写明依据）」改成「③其他」会丢掉「豁免须留痕」的语义，后续 1.75 gate 的审计线就断了。

**D10 验证：RED 基线（组 1）+ GREEN 配对复测（组 6）+ 机械断言；RED 用子代理代理测试（子代理不能真调用户工具），记录「是否会发起工具调用 + 是否含背景/选项」。**
被否：① **只做 grep/python 结构断言**——证明不了「执行侧会不会真的用工具」，writing-skills 的 Iron Law 要求失败基线；② **做 5 轮压力矩阵**——本次是文档契约变更，成本与收益不匹配；一次 RED + 一次 GREEN + 微测措辞足够，若 GREEN 摇摆再加测；③ **在 design 阶段直接派子代理跑 RED**——本设计线的硬约束禁止读取/等待其他子代理，且 design 阶段不写项目文件；RED 放进执行组 1，用 `git show HEAD:` 的旧文本做基线，可复现。
反例：若跳过 RED，只看到「grep 命中 §十」就宣布完成，无法回答「没有契约时模型会怎么做」——也就无法证明这段措辞真的改变了行为。

**D11 语义不变：不动主规格、不动两个 skill 的 frontmatter/description、不动 grill-me 既有 32 行、不重编号；以 `git diff --numstat` 删除行=0 + 三选项字面 grep 断言。**
被否：① **顺手把 spec-plan 的 §三 与 §一 去重**——看似省 cp，但会改既有文字，扩大「语义不变」的证明面；② **改 description 加「会追问」**——writing-skills 明确 description 只写触发条件、不概述流程，且改 description 会改变 skill 的发现语义；③ **把 §十 插到 §九 前并重编号**——见 D1。
反例：为加契约而改 §三 的「唯一规则」措辞，会让「外移不改变行为语义」的既有 Scenario 需要重新举证；本变更的最小证明面是「只追加」。

**D12 工件语言：两份 delta、proposal、design、tasks 全部简体中文；结构标题与 SHALL/MUST 保留英文；grill-me 的 skill 正文仍英文。**
被否：① **grill-me delta 用英文**——`openspec/config.yaml` 的 context 明确「All artifacts must be written in 简体中文」，工件语言与 skill 正文语言是两回事；② **中英双语**——增加噪声与维护面，validate 也不要求。
反例：把 grill-me 的 delta 写成英文，会让同一变更的两个 spec 文件语言不一致，归档后的主规格也混语言。

**D13 栈识别记录：`writing-skills`（用户 2026-11-12 指认），证据 = 本轮加载回执 + `decisions.md:46-47`；写入落档 `design.md` 决策记录。**
被否：① **按 Spring/Nuxt 判据判「未命中」再问一次**——用户已指认，重问违反 Q 的收敛结论；② **只在本文写、不落 design.md**——执行侧与接续恢复从工件读取，会话记忆不可靠（既有 1.7 Requirement 的落盘要求）。
反例：若 design.md 漏写栈识别，spec-apply 侧会按 Spring/Nuxt 重新识别一次，得出「未命中」并可能再问用户——同一决策被问两遍。

---

## ⑤ 逐任务组实现要点

> 分组与 `tasks.md` 一一对齐：**组 1 = RED 基线（writing-skills Iron Law 的前置门）**；组 2–6 = 用户建议的五组（入口契约节 / refs+mode 接线 / grill-me 承载段 / spec delta×2 / 工件与验证）。组间串行、组内并行；单组 ≤ `parallelism: 8`；每任务写不同文件（同目录不同文件可并行，`write` 建父目录幂等；先例 add-ui-demo-gate 组 1/组 3 同构）。

### 5.0 写 spec delta 前的 12 条逐条核对（本变更 0 MODIFIED 的依据）

| # | Requirement（`openspec/specs/spec-plan/spec.md` 行） | 硬冲突？ | 结论与理由 |
| --- | --- | --- | --- |
| 1 | 规划入口（`:10-27`） | 否 | 只规定「未给选项在对应阶段开始前询问」的**时机**，未规定工具/问法；契约叠加不改变其触发条件 |
| 2 | 双线差异收敛与分歧复算（`:29-71`） | 否 | 第⑤步「按 grill-me 设计树/前沿法提问」只委托**方法论**；承载由 grill-me 新 capability + 本契约补齐；无固定文本格式 |
| 3 | 阶段 1.7 代码设计线（`:73-100`） | 否 | 规定设计线派发与深度契约，不含用户提问承载 |
| 4 | 子代理与用户的交互中转（`:102-124`） | 否 | 「子代理 SHALL NOT 直接提问」与契约第 4 条一致；契约把主会话代问纳入工具承载，二者叠加而非冲突 |
| 5 | 落档工件与执行批次契约（`:126-173`） | 否 | 不含提问承载；落档分歧点的问法在 `planning.md:76`，由接线覆盖 |
| 6 | 阶段级模型路由（`:175-197`） | 否 | 与提问无关 |
| 7 | 读图覆盖与路由回退（`:199-221`） | 否 | 与提问无关 |
| 8 | 压缩后指令完整存活（`:223-240`） | 否 | 契约新增为入口红线，未删除任何既有红线；只追加 §十，节标题不变 |
| 9 | 入口与资源按单次加载完整交付（`:242-259`） | 否（**受其硬约束**） | 要求入口渲染后 ≤8192；本设计 7945 / 渲染 8049，余量 143，满足；无文本语义冲突 |
| 10 | 栈识别与 writer skill 加载（`:261-298`） | 否 | 「未命中问用户三选一」未规定承载；契约叠加；`writing-skills` 指认不改变该 Requirement 的判据 |
| 11 | 阶段 1 并行双线规划（`:300-327`） | 否 | 与提问承载无关 |
| 12 | 阶段 1 串行单线探索（`:329-346`） | 否 | 「待决项以 grill-me 分轮收敛」未规定承载；grill-me 新 capability 补齐 |

**重点五条核对结论**：`规划入口` 否（只管时机）；`双线差异收敛`第 5 步 否（只管方法论）；`子代理交互中转` 否（契约第 4 条与之同向）；`栈识别` 否（未写承载）；`1.75 三选一问法` **不在主规格 12 条内**——它在未归档变更 `add-ui-demo-gate` 的 delta（`openspec/changes/add-ui-demo-gate/specs/spec-plan/spec.md:5`），且其 Scenario 只写「以三选一问法交用户确认」，未固定承载，故也不冲突。**本变更的 delta 不能写 MODIFIED 1.75：主规格没有这条，MODIFIED 会因找不到同名 requirement 而报错。**

### 组 1：RED 基线（写作前）

- **1.1** 派 fresh 子代理，喂 `git show HEAD:agent/skills/spec-plan/SKILL.md` 的 §三/§四/§六 摘录 + 场景「用户未给需求描述 / 栈识别未命中，你将如何向用户提问」，要求它**只写会发起的提问（不执行、不写文件）**；逐字记录到 `/tmp/spec-flow/unify-spec-plan-questioning/red-baseline.md`，含「是否点名 `ask_user_question`」「是否含背景/选项区别」两栏与一行 `RED 结果：复现|未复现`。验证：`test -s /tmp/spec-flow/unify-spec-plan-questioning/red-baseline.md` 退出码 0；`grep -qE '^RED 结果：(复现|未复现)$' …` 命中；记录中两栏存在（`grep -q '是否点名' …` 且 `grep -q '是否含背景' …` 命中）；`test -z "$(git status --porcelain -- agent/skills openspec/specs)"` 退出码 0。
- 若 RED 未复现（模型已自发用工具且附背景）：**不伪造失败**；在记录中标注「RED 未复现」并按用户显式需求继续（writing-skills 的「无失败则不写」与用户显式要求冲突时，用户要求优先，但必须在落档 `design.md` 留痕）。**不得静默跳过**。

### 组 2：入口契约节（触达#1）

- **2.1** 在 `agent/skills/spec-plan/SKILL.md:122` 后追加 ③3.1 的 §十 全文（258 cp；不改 §一–§九、不改 frontmatter）。验证在仓库根跑下列脚本与断言：

```bash
python3 - <<'PY'
import re
p='agent/skills/spec-plan/SKILL.md'
s=open(p,encoding='utf-8').read()
fm=re.match(r'^---\n.*?\n---\n\n', s, re.S).group(0)
assert '## 十、追问契约' in s
assert s.count('ask_user_question') == 1
assert s.count('子代理/成员不直接提问') == 1
assert s.count('Carrier by host') == 1
assert len(re.findall(r'^## ', s, re.M)) == 10
assert 7930 <= len(s) <= 7960, len(s)
assert len(s) - len(fm) + 343 <= 8192
print('file', len(s), 'rendered', len(s)-len(fm)+343)
PY
```

- `test "$(git diff --numstat -- agent/skills/spec-plan/SKILL.md | awk '{print $2}')" = 0`（纯追加，既有 9 节逐字未动）。
- `test -z "$(grep -rn 'ask_question' agent/skills/spec-plan/SKILL.md)"`（无裸 `ask_question`；`ask_question` 不是 `ask_user_question` 的子串，此断言为零命中）。
- 实测记录：`file 7945 / rendered 8049 / margin 143` 写入阶段摘要。

### 组 3：refs 与 mode 接线（触达#2–#7，6 个任务，写不同文件）

- **3.1** `refs/convergence.md:32` 按 ③3.2 整句替换；验证：`grep -c 'ask_user_question'` = 1；`grep -c '追问契约'` = 1；`python3 -c` 断言 `len(s) <= 2650`。
- **3.2** `refs/planning.md`：`:1` 后插 header 句；`:60` 按 ③3.2 整句替换；验证：`grep -c '追问契约'` = 2；`grep -c '①确认，转入落档'` = 1、`grep -c '②要改'` = 1、`grep -c '③降档/豁免'` = 1；`python3 -c` 断言 `len(s) <= 7600`。
- **3.3** `refs/failure-modes.md`：`:1` 后插 header 句；验证：`grep -c '追问契约'` = 1；`grep -c '由用户决定」事项'` = 1（表体里的「由**用户决定**」被加粗符隔开，不能直接当锚）；`grep -c '问用户三选一'` = 2；`python3 -c` 断言 `len(s) <= 3150`。
- **3.4** `refs/routing.md:65` 按 ③3.2 整条替换；验证：`grep -c '追问契约'` = 1；`grep -c '更正问询'` = 1；`python3 -c` 断言 `len(s) <= 4500`。
- **3.5** `mode/serial.md:11` 按 ③3.2 整条替换；验证：`grep -c '追问契约'` = 1；`grep -c '两类提问'` = 1；`python3 -c` 断言 `len(s) <= 1950`。
- **3.6** `mode/parallel.md:53` 按 ③3.2 插入；验证：`grep -c '追问契约'` = 1；`grep -c '不另开问答通道'` = 1；`python3 -c` 断言 `len(s) <= 2850`。
- **组级断言**：`test "$(grep -rl '追问契约' agent/skills/spec-plan/refs agent/skills/spec-plan/mode | wc -l)" = 6`；`test -z "$(grep -rn 'ask_question' agent/skills/spec-plan)"`。

### 组 4：grill-me 承载段（触达#8）

- **4.1** 在 `agent/skills/grill-me/SKILL.md:24` 后（`Word each question…` 前）插入 ③3.3 的 `## Carrier by host` 三段 917 cp；不改 frontmatter、不改 `:12-24` 格式块、不改 `:26-32`。验证：
  - `grep -c '^## Carrier by host'` = 1；`grep -c 'one tool call per round'` = 1；`grep -c '(Recommended)'` = 1；`grep -c 'ask_user_question'` = 1；`grep -c '❓ \*\*Q1\*\* - \*\*<question title>\*\*'` = 1（旧格式块仍在；新段也提 `❓ **Q1**`，不能用宽 pattern 计数）。
  - `test "$(git diff --numstat -- agent/skills/grill-me/SKILL.md | awk '{print $2}')" = 0`（纯插入）；`test -z "$(git diff agent/skills/grill-me/SKILL.md | grep '^[-+]name:\|^[-+]description:')"`。
  - `python3 -c` 断言 `len(s) <= 3300`。

### 组 5：spec delta ×2（触达#9–#10；落档阶段生成，执行阶段核对/修正）

- **5.1** 核对 `openspec/changes/unify-spec-plan-questioning/specs/spec-plan/spec.md` 与 ③3.4.1 一致：只含 `## ADDED Requirements` 与 1 条「追问交互契约」+ 7 Scenario；正文 298 cp。验证：`test -f`；`grep -c '^## ADDED Requirements'` = 1；`test -z "$(grep '^## MODIFIED' <file>)"`；`grep -c '^#### Scenario:'` = 7；`python3` 抽取 `### Requirement:` 到首个 `#### Scenario:` 之间的正文，断言 `len <= 500`；`test -z "$(grep 'ask_question' <file>)"`。
- **5.2** 核对 `…/specs/grill-me/spec.md` 与 ③3.4.2 一致：`## Purpose` + 2 条 ADDED + 7 Scenario。验证：`test -f`；`grep -c '^## Purpose'` = 1；`grep -c '^### Requirement:'` = 2；`grep -c '^#### Scenario:'` = 7；Purpose 长度 ≥50；两个 Requirement 正文分别 ≤500；`test -z "$(grep 'ask_question' <file>)"`。
- **5.0 记录**：把 ⑤5.0 的 12 条核对表（含 1.75 不在主规格的注）写入 `design.md` 决策记录；验证：`grep -c '12 条'`/`grep -q '1.75'` 命中。

### 组 6：工件与验证（触达#11–#16）

- **6.1** 复制两材料：`mkdir -p openspec/changes/unify-spec-plan-questioning && cp /tmp/spec-flow/unify-spec-plan-questioning/code-design.md /tmp/spec-flow/unify-spec-plan-questioning/decisions.md openspec/changes/unify-spec-plan-questioning/`。验证：`test -f openspec/changes/unify-spec-plan-questioning/code-design.md` 与 `test -f openspec/changes/unify-spec-plan-questioning/decisions.md` 均退出码 0；`cmp -s /tmp/spec-flow/unify-spec-plan-questioning/code-design.md openspec/changes/unify-spec-plan-questioning/code-design.md` 与 `cmp -s /tmp/spec-flow/unify-spec-plan-questioning/decisions.md openspec/changes/unify-spec-plan-questioning/decisions.md` 均退出码 0。
- **6.2** 核对 `.openspec.yaml` / `proposal.md`：`test -f`；`grep -q 'schema: spec-driven'`；`grep -q '^## Why'` 且 Why 50–1000 字符；`grep -q '^## Capabilities'`；`grep -q 'grill-me'` 与 `grep -q 'spec-plan'`。
- **6.3** 核对 `design.md`：六字段标题齐备（`① 触达面清单`/`② 证据锚`/`③ 接口与数据形状`/`④ 决策记录`/`⑤ 逐任务组实现要点`/`⑥ 设计假设与未决项`）；`grep -q 'writing-skills'`（栈识别）；`grep -q '0 MODIFIED'`；`grep -q '1.75'`（未触发行）。
- **6.4** 核对 `tasks.md`：`grep -cE '^## [0-9]+\. '` = 6；每个 `- [ ]` 行含 `验证：` 与 `触达#`；组号与 ⑤ 一致；单组任务数 ≤8。
- **6.5** 全量结构校验：`openspec validate unify-spec-plan-questioning --strict` 退出码 0 且无 WARNING；`openspec list --json` 含该变更；`test -z "$(git diff -- openspec/specs/spec-plan/spec.md)"`；**不得用 `openspec validate --all --strict`**（主规格既有 2 条超长会红，见 add-ui-demo-gate 的 R4 留痕）。
- **6.6** GREEN 配对复测：派 fresh 子代理，喂新 §十 + 同组 1 场景，记录 `/tmp/.../green-check.md`；断言：`grep -q 'ask_user_question'`、`grep -q '背景'`、`grep -q '选项'` 均命中，且记录一行 `GREEN 结果：通过|摇摆`；与 RED 对比写 1 行结论。
- **6.7** 无裁剪 + 语义：重跑组 2 的渲染公式（`7945 / 8049 / 143`）；主会话加载 `skill spec-plan`，断言返回正文含 `## 十、追问契约`、不含 `[... tool result middle pruned ...]`；`grep -c '^## '` = 10 且既有 9 个标题逐字仍在；1.75 三选项字面仍在（同 3.2 的 grep）。
- 收尾：实现批次由 spec-apply 按组提交；落档工件目录的提交仍按 SKILL.md §七第 7 步「工件单独提交一次」，不在本组重复。

---

## ⑥ 设计假设与未决项

### 假设（后续执行默认可依，不阻塞）

- **A1** 目标仓 = dotfiles 根仓，无子仓、无跨仓；本变更全部是 markdown。
- **A2** 变更名/目录 = `unify-spec-plan-questioning`；`.openspec.yaml` 用 `schema: spec-driven` + `created: 2026-11-12`（格式照 add-ui-demo-gate）。
- **A3** DSH 是 spec-plan 的运行宿主；`ask_user_question` 对**主会话**可用（本会话工具清单实测）；被拥有的子代理/成员仍被 `DELEGATED_CALLER` 拒绝（既有 Requirement，`specs/spec-plan/spec.md:104`）。
- **A4** openspec 1.16.0；ADDED 正文 >500 在 `--strict` 下 invalid（`constants.js:9` + `validator.js:272,898`）；本设计三条 ADDED 正文 298/267/147。
- **A5** 渲染包裹 343 cp（path 42 字符）是当前口径；`file − frontmatter(239) + 343`。本设计 7945 → 8049，余量 143；path 取宿主 56 字符时余量 129。若宿主 path 再变长，按组 2/6 的实测重算。
- **A6** 主规格 12 条**不含 1.75**；1.75 在未归档变更 `add-ui-demo-gate` 的 delta（`specs/spec-plan/spec.md:5`）。本变更**不能** MODIFIED 它；0 MODIFIED 是事实结论，不是遗漏。
- **A7** 聚合层 symlink 实时可见（`/home/docker/.agents/skills/{spec-plan,grill-me}` → 仓库目录；grill-me md5 一致）；改源文件即生效，无需 `skctl install` 或重启 dsh。
- **A8** 阶段 1.75 预计**未触发**（纯 skill 文档，无界面产出，C1 不成立）；由主会话按 gate 判定，并在 `code-design.md` 末尾追加一行「1.75 未触发：…」；本设计不替主会话下结论。
- **A9** 工件语言简体中文、结构标题与 SHALL/MUST 英文（`openspec/config.yaml:1` 与 `:3-6`）；grill-me 的 **skill 正文仍英文**，只有它的 spec delta 用中文。
- **A10** 组内同目录不同文件可并行（先例 add-ui-demo-gate 组 1/组 3）；`write` 建父目录幂等，故 6.1–6.4 共享新变更目录不构成写冲突。若执行器按更严格的「同目录禁并行」解释，则把 6.1–6.4 拆到连续子组，任务内容不变。
- **A11** 既有「第 X 节」引用全部指向 §四–§九；追加 §十 不改变它们的编号与语义（`refs/*.md`、`mode/*.md` 的 header 句已实证）。
- **A12** 契约第 4 条的「子代理/成员不直接提问」是对既有中转 Requirement 的**引用**，不是新豁免；若未来平台允许子代理直问，需另立变更。

### 风险与未知

- **R1 入口余量 143 cp 偏薄**：未来任何入口增补超过当前余量（path 变长时约 129 cp）即可能触发 pruner。缓解 = 契约节不再扩写；后续细节一律进 `refs/` 或 grill-me；组 2/6 的渲染公式与「加载无裁剪标记」是硬门。
- **R2 工具名漂移**：`ask_user_question` 出现在契约、convergence、grill-me、两个 delta（共 5 处）。DSH 改名时需同步；缓解 = 抽象措辞为主、实名只作锚，`grep -rn 'ask_user_question'` 是改名的唯一清单。
- **R3 RED 未复现**：模型可能已自发使用结构化工具，导致 writing-skills 的失败基线不成立。缓解 = 如实记录、按用户显式需求继续、在 `design.md` 留痕；**不伪造**失败。
- **R4 1.75 归档时序**：若 `add-ui-demo-gate` 在本变更期间归档，主规格会新增 1.75 Requirement；本变更无 MODIFIED，不会因此 validate 失败。若归档发生在组 5 之后，仍需在组 6.5 重跑 validate（结论不变）。
- **R5 接线句被读成「重复契约」**：6 文件只有 7 句指针，不复制全文；若审阅要求「逐落点显式」，按 ④D4 的备选在 planning/failure 各点补短括号（成本约 10 行，不影响长度预算）。
- **R6 failure-modes 表头句的覆盖**：4 行「问用户/由用户决定」由一句覆盖；若执行者只读表体不读表头，可能漏。缓解 = 表头句在表格前第一行；组 3 的 grep 按文件断言；必要时逐行补括号。
- **R7 `openspec validate --all --strict` 会红**：主规格既有两条超长（518/502 字符，add-ui-demo-gate 的 R4 留痕）与本次无关；只能用单变更 validate。tasks 的验证句必须写清变更名。
- **R8 中文正文的 SHALL 检查**：delta 正文含英文 `SHALL` / `SHALL NOT`，满足 `containsShallOrMust`；若未来有人把 SHALL 翻成「应」，validate 会红——保持英文关键字。
- **R9 英文承载段与 DSH 字段耦合**：`(Recommended)` 是 DSH 工具约定的标签；段内已用「mark it as the recommendation」+ 括号注记降低耦合。若换宿主，只需改括号注记。
- **R10 `## Carrier by host` 是 grill-me 的第一个 `##` 标题**：既有文件无标题层级；新增标题不改变正文顺序，但会让「纯 prose」风格变成「一节 + prose」。这是为了可被 spec-plan 精确引用而付出的形态代价；若审阅偏好无标题，可改为加粗引导句，但契约的 `Carrier by host` 指针需同步（不推荐）。

### 未决项（与「待决问题」节互指）

- 未决项 = 下文 Q1（RED 组去留）与 Q2（1.75 归属确认）。两项都不阻塞本设计落盘；执行按推荐走，用户在阶段 2 前可改。

---

## 待决问题

> 在六字段之外。两项都不阻塞：不答复则按「推荐」进入 tasks；答复后只改对应组，不重开收敛。

### Q1 RED 基线组是否纳入执行批次？

- **问题**：writing-skills 的 Iron Law 要求改 skill 前有失败基线；用户建议的五组里没有 RED 组。是否单列组 1？
- **选项**：
  - a.（推荐）纳入组 1：一次 fresh 子代理 + 记录 `/tmp/.../red-baseline.md` + 组 6 GREEN 配对；tasks 共 6 组。
  - b. 豁免：只做组 6 的 GREEN 与机械断言；须在落档 `design.md` 写明「用户豁免 RED」及依据，tasks 共 5 组。
- **推荐**：a。理由：writing-skills 是用户指认的硬约束；本变更的失败类型（裸文本提问/问题含糊）正是它要防的；一次 RED 的成本远小于「写完才发现措辞没改变行为」。
- **影响面**：tasks 组数 6 vs 5；执行时长 +1 次子代理；`design.md` 的决策记录多一条 RED 结论；不影响任何文件形状。

### Q2 「1.75 三选一问法」不在主规格 12 条内——接受 0 MODIFIED 吗？

- **问题**：用户的设计要点把「1.75 三选一问法」列为五条重点核对之一，但主规格 `openspec/specs/spec-plan/spec.md` 的 12 条里**没有 1.75**；1.75 的 Requirement 在未归档变更 `add-ui-demo-gate` 的 delta（`specs/spec-plan/spec.md:5`），其问法在 `planning.md:60`。本变更无法 MODIFIED 一条主规格里不存在的 Requirement。
- **选项**：
  - a.（推荐）接受 **0 MODIFIED**：只在 `planning.md:60` 就地注记「三选项语义不变，只换承载」，并把 12 条逐条核对表写入 `design.md`；`openspec validate` 面最小。
  - b. 等 `add-ui-demo-gate` 归档后再评估是否 MODIFIED 1.75：会阻塞本变更落档；且即便归档，1.75 的 Requirement 文本也只写「以三选一问法交用户确认」，未固定承载，核对结论仍是不冲突。
- **推荐**：a。理由：事实优先于清单；MODIFIED 一条不存在的 requirement 会让 validate 直接报错；1.75 的语义保留由 `planning.md:60` 的注记 + 组 3.2 的三选项 grep 断言保证。
- **影响面**：spec-plan delta 的结构（只有 ADDED）；是否等待另一个变更归档；1.75 的验证从「MODIFIED 文本」改为「planning.md 注记 + 三选项字面断言」。

## 附：阶段 1.75 界面演示（判定与确认）

1.75 未触发：C1 不成立——本变更触达面全部为 skill markdown 文档（spec-plan 7 文件 + grill-me SKILL.md）与 OpenSpec 工件，无页面、组件、表单、布局或视觉改版、无交互流程可视化（命中排除表「纯后端 / CLI / 配置 / 脚本」同族；与 A8 预判一致）。主会话 2026-11-12 判定。
