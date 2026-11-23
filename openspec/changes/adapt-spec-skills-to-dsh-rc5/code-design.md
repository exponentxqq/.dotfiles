# code-design.md · 阶段 1.7 代码设计（adapt-spec-skills-to-dsh-rc5）

- 项目根：`/home/xuqinqin/develop/dotfiles`（本变更全部触达均在 **dotfiles 根仓**，无子仓）
- 事实基线：dsh `0.2.2-rc.5` 运行中（2026-11-23）；openspec CLI `2.1.1`；平台事实唯一权威源 = `/usr/local/lib/node_modules/@deepseek-ai/dsh/docs/`
- 输入：`line-a.md`（205 行）/ `line-b.md`（193 行）/ `diff-matrix.md`（107 行）；**C1–C14 为已定裁定，本文件不重开**
- 约定：`<change>` = `adapt-spec-skills-to-dsh-rc5`；`<cfg>` = `dsh/spec-workflow.yaml`

---

## ① 触达面清单

> 行数为估算（±3），**验收一律以码点公式 / grep 常量 / `openspec validate` 为准**；净变仅用于审核节奏预估。表格中「门」列的 `R` = 入口渲染门（`len(正文)+343 ≤ 8192`，正文 = 文件去 frontmatter），`C` = coordination 长度门（3800–5000 cp），`I` = 注入段 7–15 行，`P` = pruner 单次工具结果 8192 cp（refs 兜底门），`—` = 无长度门。

### 1.1 改动 / 新建面（17 项）

| # | 路径（仓 = dotfiles） | 改动意图与关键改动点 | 行数（现→后；增/删/净） | 门 |
|---|---|---|---|---|
| 1 | `agent/skills/spec-apply/refs/coordination.md` | **协议唯一权威源**：§1 三条 rc.1 基线换「实证锚/文档锚」4 条；§2 `agent` 字段升 v3（记 name）+ 命名规约段；§3 第 3 步改按 `started subagent <name>` 回填；§4 注入段 7 条**逐行定稿**（第 3/4/6/7 条为主改）；§5 删「成」行与两条示例（留一）；§6 「令写入时」追加 `send_message` 下行通知（登记簿仍为唯一令）；§7 上行改 `send_message(agent="lead")`；§8 第 5 行改「技术可达但禁止私商」纪律；§9 四判据→**单条**；§10 常量清单补 `send_message(agent="lead")` | 134→132（+18/−20/净**−2**） | C（4996→目标 4930–4990）+ I |
| 2 | `agent/skills/spec-apply/refs/execution.md` | subagent 引擎段：具名派发、即返名、完成通知自动递送、**待决回送同实例续话**、失败重试仍 fresh、登记簿 v3 论证重写（`list_agents` 状态≠完成）、**受控嵌套纪律并入提示自包含项**（只许只读孙代理，提示写明只读并转述本任务硬约束，产出由派发者核对）；team 引擎段整段重写：Team 模式前置检查→`team_task_create`（`write_scopes`/`blocked_by`）→具名 implementer CAS 认领→反馈回同一 implementer→**路由适用**→未开启回退；并行上限口径改「以映射文件为准（键缺失按 3）」 | 62→68（+9/−3/净**+6**） | P |
| 3 | `agent/skills/spec-apply/SKILL.md` | §二③ 引擎语义（team 需根会话开启）；§三 pseudocode else 分支改 `team_task_create` + 具名 implementer；§三协调纪律：升级判据只指路 `coordination.md §9`、回填 `name`；§四中转统一「同实例续话优先、冷兜底重派」+ `agent="lead"`；§五 routing 改两引擎适用 | 57→58（+4/−3/净**+1**） | R |
| 4 | `agent/skills/spec-apply/refs/routing.md` | :22 `apply` 适用面「仅 subagent」→「两引擎」；:34 自检补 `list_subagent_models` 首选、脚本兜底；:58 删「team 忽略 `apply` 键」，改「两引擎均应用；路由字段随 preset 启用，未启用报错不硬闯」 | 63→64（+2/−1/净**+1**） | P |
| 5 | `agent/skills/spec-apply/refs/failure-modes.md` | :16 team 行重写（Team 模式未开启回退、无成员上限、软废止+下行通知）；:17 方向表重写（**下行可达**、上行 `agent="lead"`、事件限两类）；:23 父 id 缺失→根名不可解析 | 25→26（+3/−2/净**+1**） | P |
| 6 | `agent/skills/spec-plan/SKILL.md` | description 去「（team 驱动）」；§一流水线图 :16、`--parallel` 参数 :31、refs 表 :38；§三摘要字段 :52；§四 :56（具名单机制）/:70（适用范围）/:77（④回送）；**§六 :96 栈识别句增「纯文档/技能类（触达面零应用代码）默认 `writing-skills`、不问三选一」分支**；§八 :110 删「team 成员无模型参数」与「显式 `--model` 强制 subagent」特例；§九 :121 回送句 | 131→126（+3/−8/净**−5**） | R（**正文 ≤7507，净增 ≤0**；新增句以 §四/§八 删除等量抵扣） |
| 7 | `agent/skills/spec-plan/mode/parallel.md` | 重写为具名子代理单机制：同一条消息派 `subagent(name="plan-a"/"plan-b")`、**无 `run_in_background`**、即返名；命名/重名；回执核对；线失败补正/重派；模板收敛为**单版**（删「引擎差异段」）；上行段改 `agent="lead"` | 57→38（+6/−25/净**−19**） | P |
| 8 | `agent/skills/spec-plan/refs/routing.md` | :22–28 编排适用性速查删「team 编排不应用」；:64 删 `spawn_teammate`/team 锁 Lead 模型/显式覆盖特例（保留 fresh 才支持模型选择、fork 不支持）；:39 自检补 `list_subagent_models` | 70→68（+3/−5/净**−2**） | P |
| 9 | `agent/skills/spec-plan/refs/failure-modes.md` | :10 线失败改「回送同一具名子代理补正一次，冷兜底重派」；:11–12 两行团队处置改为具名派发失败/卡死（下行催办→软废止→重派新名）；:21 父 id→根名 | 23→21（+2/−4/净**−2**） | P |
| 10 | `agent/skills/spec-plan/refs/convergence.md` | :27 答复回送改「同实例续话（冷兜底重派）」，与 §4 单一源对齐 | 32→32（+1/−1/净 **0**） | P |
| 11 | `agent/skills/spec-plan/refs/planning.md` | :23 栈判据段增「纯文档/技能类（触达面零应用代码）→ 默认命中 `writing-skills`、不问三选一」分支，Spring/Nuxt 判据与未命中三选一不变；:41 1.7 模板 writer 点名去「spring-writer / nuxt-writer」双枚举（改「按栈识别点名；本仓为 writing-skills 或用户指认」）；:42 `send_message(agent_id=父会话 id)` → `send_message(agent="lead")`；:77 并行上限口径 | 84→84（+2/−2/净 **0**） | P（7645 cp，净增 ≤100） |
| 12 | `agent/skills/spec-workflow/SKILL.md` | :31 `--engine team` 行重述（Team 模式需根会话菜单开启，未开回退）；:59 衔接话术补「team 需用户菜单开启」；:65 登记簿 v2→v3；:96 中转行回送统一 | 99→99（+3/−3/净 **0**） | R |
| 13 | `agent/skills/spec-done/SKILL.md` | :24 项目验证门、:39 全量复验：复验子代理具名 `verify-<n>`（C4 命名规约落点） | 74→74（+2/−2/净 **0**） | R |
| 14 | `dsh/README.md` | :142 失败处置表述；:155 1.7 writer 点名句补「纯文档/技能类默认 `writing-skills`」；:161 执行双引擎（去 spawn/成员上限）；:173–174 回送表（删「仅 spawn_teammate 队友可寻址」「接续重派」） | 349→349（+4/−4/净 **0**） | —（非 skill 资源） |
| 15 | `openspec/changes/<change>/specs/spec-plan/spec.md` | **新建** delta：3 REMOVED + 3 ADDED + **1 MODIFIED**（`栈识别与 writer skill 加载（设计侧）`，保留 7 个现有 Scenario + 新增「纯文档类默认 writing-skills」；名集见 ③.6A） | 0→≈150（+150/0/净**+150**） | ADDED 正文 ≤500 cp；MODIFIED 正文由 405→≤500（不增长越限） |
| 16 | `openspec/changes/<change>/specs/spec-apply/spec.md` | **新建** delta：3 MODIFIED + 2 REMOVED + 2 ADDED | 0→≈145（+145/0/净**+145**） | 同上 |
| 17 | `openspec/changes/<change>/specs/spec-workflow/spec.md` | **新建** delta：1 MODIFIED（中转·同实例续话） | 0→≈38（+38/0/净**+38**） | 同上 |

**合计**：改/建 17 文件；净增 ≈**+312 行**（其中新 delta 文件 +333，既有文件净 −21）。新增代码/配置 0 行——触达面为纯 markdown 规范与 delta。

### 1.2 零改动核对面（列出来防临场扩大）

| 路径 | 现状 | 零改动理由 |
|---|---|---|
| `dsh/commands/spec-flow.md`（12 行，:3 `[--engine team]`）、`spec-apply.md`（11 行，:3 同）、`spec-plan.md`（12 行） | 仅 argument-hint 含 `--engine team` | C14：参数保留即无需改；实查无 `spawn_teammate`/`agent_id` |
| `dsh/spec-workflow.yaml`（48 行，:44–48 engine/parallelism 注释） | 值域 `subagent \| team` 仍成立 | C14；且 R11：该文件有用户未提交路由改动，**不触碰、不暂存** |
| `agent/skills/spec-workflow/refs/failure-modes.md`（14 行，:11「team 降级」） | 表述仍真（C1 保留回退） | 无过时平台断言 |
| `agent/skills/spec-plan/mode/serial.md`（26 行） | 无 team/agent_id/接续重派 | 串行无派发，中转不经 |
| `openspec/specs/{spec-plan,spec-apply,spec-workflow}/spec.md` | 主规格 | **不直改**；只出 delta，归档由 `openspec-archive-change` 同步 |
| `dsh/profiles/web/*` | 用户未提交改动 | A2：profile 变更属宿主操作，不在本变更 |

### 1.3 长度门现状与预算（2026-11-23 实测，`python3 len()`）

| 文件 | 正文 cp | 渲染（正文+343） | 余量 | 本变更门 |
|---|---|---|---|---|
| `spec-plan/SKILL.md` | 7507 | 7850 | 342 | **正文 ≤7507（净增 ≤0）**；渲染 ≤8192 |
| `spec-apply/SKILL.md` | 3483 | 3826 | 4366 | 渲染 ≤8192 |
| `spec-workflow/SKILL.md` | 6358 | 6701 | 1491 | 渲染 ≤8192 |
| `spec-done/SKILL.md` | 5860 | 6203 | 1989 | 渲染 ≤8192 |
| `spec-apply/refs/coordination.md` | 4996 | — | **4** | **3800–5000；目标 4930–4990** |
| 注入段 | 628（10 行） | — | — | **7–15 行**（新定稿 598 cp / 10 行） |

口径裁定：入口门用 `len(正文)+343`（历史归档口径，`2026-10-15-spec-workflow-add-design-phase/design.md:7`）。上游 R8 记的「余量 46 cp」与本轮实测不符（342；若按文件总长+343 则 104）——**以本轮实测为准，门收紧为「spec-plan 正文净增 ≤0」**；这不是重开收敛，是把 R8 的「余量 ≥40」换成可机械核对的上界。

---

## ② 证据锚

### 2.1 触达模块现文事实（每模块 ≥1 条；新建标「新建」）

| # | 模块 | 现文事实（file:line + 摘句） |
|---|---|---|
| 1 | coordination.md | `:7`「lead→subagent 下行 ✗｜…｜sibling 互达 ✗｜无硬中断」；`:52` `send_message(agent_id="<你的父 agent id…>")`；`:55`「兄弟子代理与你互不可达（平台事实）」；`:118–127` §9 四判据 |
| 2 | execution.md | `:8`「v2 登记簿…表现为子代理 id 不可寻址」；`:16`「成员上限达限（Team member limit 8 reached）」；`:18`「`spawn_teammate` 创建具名 implementer」；`:22`「该引擎**忽略 `apply` 路由键**」 |
| 3 | spec-apply/SKILL.md | `:39`「升级判据（…同任务审核被拒 ≥2 次/…）」；`:45`「subagent 以上轮回执摘要+答复**接续重派**」「`send_message(agent_id=父会话 id)`」 |
| 4 | spec-apply/refs/routing.md | `:22`「`apply`｜阶段 3 执行任务子代理（仅 subagent 引擎）」；`:58`「`team` 引擎忽略 `apply` 键」 |
| 5 | spec-apply/refs/failure-modes.md | `:17`「**下行**（lead→subagent）平台不可达…事件限决/异/成三类」；`:16`「`interrupt_agent` 中断或重建」 |
| 6 | spec-plan/SKILL.md | `:56`「**派发默认 team 驱动**：每线一个具名 fresh 成员（`spawn_teammate`）」；`:110`「team 成员无模型参数」；`:77`「subagent…接续重派（非同一实例）」 |
| 7 | spec-plan/mode/parallel.md | `:7`「`spawn_teammate` 创建两个具名成员」；`:15–19` 5 条回退判据；`:42`「`run_in_background: true`」；`:47–48`「`send_message(agent_id=父会话 id)`」 |
| 8 | spec-plan/refs/routing.md | `:28`「并行 team 成员无模型参数（`lineA`/`lineB` 不应用）」；`:64`「`subagent_fork` 与 `spawn_teammate` 均不支持模型选择」 |
| 9 | spec-plan/refs/failure-modes.md | `:11`「Agent Teams 未挂载 / `spawn_teammate` 失败…成员上限达限」；`:12`「`interrupt_agent` 中断后重建一次」 |
| 10 | spec-plan/refs/convergence.md | `:27`「按引擎**回送同一成员或接续重派**」 |
| 11 | spec-plan/refs/planning.md | `:23`「`pom.xml`/`build.gradle(.kts)` 含 `spring-boot` 判 Spring；`nuxt.config.*` 或 package.json 依赖含 `nuxt` 判 Nuxt」+「皆未命中 → 问用户三选一」；`:41`「先加载 skill：<按栈识别点名：spring-writer / nuxt-writer / 两者>」；`:42`「send_message(agent_id=父会话 id)」 |
| 12 | spec-workflow/SKILL.md | `:65`「登记簿（v2，见 spec-apply refs/execution.md…）」；`:96`「team 回送**同一成员**、subagent 接续重派」 |
| 13 | spec-done/SKILL.md | `:24`「可派 fresh 子代理（按 `verify` 路由）」；`:39` 复验「可派 fresh 子代理（`verify` 路由）」 |
| 14 | dsh/README.md | `:155`「先加载栈对应 writer skill（`spring-writer`/`nuxt-writer`）」；`:161`「spawn ≤ 任务数的 implementer…成员上限 8」；`:173`「仅 `spawn_teammate` 的具名队友可寻址」 |
| 15–17 | 三 delta 文件 | **新建**（目录 `openspec/changes/<change>/specs/` 当前不存在） |

### 2.2 过时断言 → 平台事实（专家锚：实证 / 文档）

| # | 现文位置 | 现文断言 | rc.5 平台事实 | 出处 |
|---|---|---|---|---|
| 1 | spec-plan/SKILL.md:56；parallel.md:7,15–19；spec-apply/refs/execution.md:18 | `spawn_teammate` 创建具名成员 | 工具已移除；团队成员=**具名子代理**（`subagent(name=…)`，返回 `started subagent <name>`） | 文档 `upgrade-guide/v0.2.1-rc.2/agent-team-subagents/guide.zh.md:14,27`；实证：本会话 `started subagent spec-rc5-line-a` |
| 2 | coordination.md:52,100；spec-apply/SKILL.md:45；parallel.md:47–48；planning.md:42 | 上行须父 session id、参数 `agent_id`；`"lead"` 不可寻址 | 控制工具按 **name** 寻址；`lead`=根（`resolveName` 返回根 Session id）；参数更名 `agent` | 文档 `upgrade-guide/v0.2.2-alpha.3/subagent-names/guide.zh.md:12–15`；`subagent.zh.md:184,486–500`；`tool-catalog.zh.md:2317–2320`；**实证**：设计线开工 `send_message(agent="lead")` 到达主会话 |
| 3 | coordination.md:7,55；execution.md:9；failure-modes.md:17 | sibling 互不可达（写成平台事实） | 根与可继续成员**可跨分支**发消息；`list_agents`「可以向树中任意其他代理发送消息」 | 文档 `subagent.zh.md:198`；`tool-catalog.zh.md:2298` |
| 4 | coordination.md:7,94；execution.md:21；spec-apply/refs/failure-modes.md:16 | `interrupt_agent` 仅 teammate / 无硬中断 | 工具面向所有子代理，但 base 与 Web 各 preset `config.interrupt: false` → **本配置不可用**，非平台不可用 | 文档 `upgrade-guide/v0.2.2-rc.1/subagent-interrupt-default/guide.zh.md:12`；**实证**：lead 工具面清单无 `interrupt_agent`（diff-matrix 假设核验） |
| 5 | parallel.md:17；execution.md:16；spec-apply/refs/failure-modes.md:16 | `Team member limit 8 reached` 成员上限 | `agent-team` 拒绝 `maxMembers`（任务板仅 `maxTasks`）；在线并发受 `maxActiveSubagents`（默认 **8**，两引擎同池）约束 | 文档 `upgrade-guide/v0.2.1-rc.2/agent-team-subagents/guide.zh.md:17`；`config-catalog.zh.md:190,3745`；实证：diff-matrix 假设核验 |
| 6 | spec-plan/SKILL.md:110；spec-plan/refs/routing.md:22–28,64；execution.md:22；spec-apply/refs/routing.md:58 | team 成员无模型参数 → 规划键不应用、`apply` 键忽略 | 成员即具名子代理；Web/Desktop preset 启用 spawn 路由字段（`subagent_fork` 仍关闭） | 文档 `tool-catalog.zh.md:49,2269` |
| 7 | spec-plan/SKILL.md:31,56；parallel.md:1,5 | 规划默认 team 驱动 | 规划线无共享写面，平台无对应机制；具名 fresh 子代理即满足（C1 的 team 只约束执行引擎） | **实证**：本变更双线即具名子代理（`spec-rc5-line-a/b`） |
| 8 | execution.md:8；spec-workflow/SKILL.md:65 | 登记簿 v2，`agent=session-<uuid>`；子代理 id 不可寻址 | 派发即返 **name**；name 是模型面稳定身份、可按名续轮；Session id 仍是执行身份 | 文档 `upgrade-guide/v0.2.2-alpha.3/subagent-names/guide.zh.md:15`；`tool-catalog.zh.md:2298` |
| 9 | spec-plan/SKILL.md:77,121；spec-workflow/SKILL.md:96；spec-apply/SKILL.md:45；coordination.md:71,73；execution.md:11 | subagent 待决回送=**接续重派（非同一实例）** | 闲置/冷目标 `send_message` 即续轮（同实例保留上下文）；任务结束可继续对话 | 文档 `tool-catalog.zh.md:2237,2298`；`subagent.zh.md:511–523` |
| 10 | coordination.md:52,55；execution.md:9；spec-apply/refs/failure-modes.md:17 | 下行不可达，通知只能等检查点 | 运行中目标在**下一步骤边界**收 steer；闲置起轮；冷目标恢复 | 文档 `subagent.zh.md:196–198,511–523`；`tool-catalog.zh.md:2311`；**实证**：本次运行中收到 lead 的 steer 下行 |
| 11 | spec-apply/SKILL.md:45；coordination.md:54,73 | 上行三类（决/异/成） | 「成」的流水线收益由 settle 自动完成通知（含最终回答）+ 登记簿覆盖（C2 裁两类） | 文档 `tool-catalog.zh.md:2237` |
| 12 | parallel.md:42 | `run_in_background: true` | rc.5 `subagent` 工具无此参数；派发即返名、完成通知自动递送 | 文档 `tool-catalog.zh.md:2235–2269`；实证：本会话派发无该参数 |
| 13 | planning.md:41；dsh/README.md:155 | writer skill 只有 spring/nuxt 两值 | 聚合层任意已注册 skill 可按名加载；本仓栈判据零命中，用户指认 `writing-skills` | **实证**：`/home/docker/.agents/skills/writing-skills/SKILL.md:2–3` 加载成功；栈探测零命中（见 ④D1） |
| 14 | coordination.md:7 | 基线锚 = `/tmp/spec-flow/add-subagent-control-and-coordination/red-baseline.md`（2026-11-19，rc.1） | 证据已过期；新锚 = 本变更规划期（`diff-matrix.md` 假设核验表）+ docs | **实证**：双线具名派发、开工回执、运行中 steer（三件套） |

### 2.3 工具链与门禁锚（非 dsh 文档，但决定 delta 形状）

| 事实 | 出处 |
|---|---|
| MODIFIED 省略主规格现有 Scenario = **ERROR**（archive 拒绝） | `@fission-ai/openspec/dist/core/validation/validator.js:689–699` |
| `--strict` 下任何 WARNING 即失败（`valid = errors===0 && warnings===0`） | 同上 `:912–919` |
| ADDED 正文 >500 cp = WARNING（strict 红）；MODIFIED 仅在「超 500 且增长」时 WARNING | 同上 `:275–280,679–684`；`constants.js:9`（`MAX_REQUIREMENT_TEXT_LENGTH = 500`） |
| 工具结果剪裁阈值 8192 cp（head 4096 / tail 1024） | `docs/config-catalog.zh.md:840–844` |

---

## ③ 接口与数据形状

### 3.1 登记簿 v3（`/tmp/spec-flow/<change>/progress.md`）

| 字段 | 取值 | 语义与约束 |
|---|---|---|
| `T<n.m>` | 行首 token | 任务号；重派加 `@r2` |
| `scope` | 仓内相对路径，逗号分隔，目录以 `/` 结尾 | 写范围 |
| `agent` | `<name>` / `pending` | **v3：记派发返回的 name**（派发前按命名规约可推导）；`pending`=未派发；回执 `started subagent <name>` 核对后回填 |
| `state` | `active\|done\|void\|stalled` | 状态机不变 |
| `at` | ISO8601 带时区 | 最后状态变更 |
| `src` | `dispatch\|receipt\|void\|recover` | 状态来源 |
| `reason` | 自由文本 | 废止/停滞依据 |

状态机（不变）：`active --回执通过--> done`｜`active --用户叫停/lead 放弃--> void`（软废止令）｜`active --零落盘+无上行+无回执--> stalled`｜`stalled --重派--> 新行 @r2`。

**命名规约（v3，随 §2 字段表之后）**：
`name = <角色>-<序号>`——`plan-a`/`plan-b`/`panel-<n>`/`design`/`apply-<组>-<任务>`/`verify-<n>`；重派追 `-r<n>`（如 `apply-2-1-r2`）。硬约束：全名 **≤32 字符、小写 kebab、字母开头、非保留名 `lead`**（`tool-catalog.zh.md:2251–2253`）。重名被拒 → 追加变更短码 `-<变更名首段截6字符><变更名长度十进制>`（`adapt-spec-skills-to-dsh-rc5` → `-adapt28`）重试一次；再拒即上行 `异`，不循环。

示例行：
```
T2.1 scope=agent/skills/spec-apply/refs/coordination.md agent=apply-2-1 state=active at=2026-11-23T15:40:00+08:00 src=dispatch reason=
T2.1@r2 scope=agent/skills/spec-apply/refs/coordination.md agent=apply-2-1-r2 state=active at=... src=dispatch reason=
```

### 3.2 上行报（单行，单发不候复）

执行期（任务级）：
```
[上行][<change>][T<n.m>][决|异] <一句话结论> / 需要：<代问|裁决|无需> / 依据：<file:line 或阻塞点> / 阻塞：<是|否>
```
规划/设计线（问题级，`coordination.md §7` 唯一权威源；本变更设计线即用此式）：
```
[上行][<change>][<A线|B线|复算|设计>][决|异] 问题=<一句> / 选项=<a|b> / 推荐=<a> / 影响面=<…>
```
- 两类仅 `决`（需用户拍板）/ `异`（无法继续：验证失败/缺依赖/工具故障）；**无「成」**。
- 发送：`send_message(agent="lead")`；失败即降级为回执上浮，不重试、不阻塞。
- 地址：根名 `lead`；路径名未命中报 `AGENT_NAME_NOT_FOUND`（`subagent.zh.md:184`）。

### 3.3 注入段模板逐行定稿（598 cp / 10 行，门 7–15）

```markdown
<!-- coord-inject:start -->
【协调协议·本任务强制】
1. 登记簿（唯一协调源）：/tmp/spec-flow/<change>/progress.md。开工第一动作读全表，记下他人 state=active 的 scope。
2. 让路：他人 scope 与你的写范围前缀相交 → 交集路径一律不写；整任务无法避让 → 按第 4 条上行为「决」。
3. 检查点（读你自己条目，共三处）：①动任何文件前 ②每次写文件前 ③跑验证句前。条目 state=void|stalled 或 agent 非你的 name → 停手：不再改动、不 git 操作，回执首行写 VOIDED；收到下行废止通知也以登记簿为准。
4. 上行发送：send_message(agent="lead")（根名寻址；失败即降级，不重试、不阻塞，改写进回执）。
5. 上行格式（单发不候复，只陈述结论与需要，不提问）：[上行][<change>][T<n.m>][决|异] 结论一句 / 需要：代问|裁决|无需 / 依据：<file:line> / 阻塞：是|否
6. 必报两类：决=需用户拍板；异=无法继续（验证失败/缺依赖/工具故障）。
7. 兄弟子代理技术上互可达，但本工作流禁止私商写冲突：一切冲突经主会话裁决，禁止互相等待或自行协商。
<!-- coord-inject:end -->
```

逐行语义（行号 = 块内）：L1 标记；L2 标题；L3 登记簿+首读；L4 让路（配方：条件→动作）；**L5 检查点**（新增「下行通知也以登记簿为准」——令的从属关系必须写死，否则通知会被当第二道令）；**L6 发送**（`agent="lead"`，删「不可寻址」）；**L7 格式**（删「成」）；L8 两类；**L9 冲突纪律**（平台事实从「不可达」改为「可达但禁止」，保留裁决单写者）；L10 结束标记。L7 与 3.2 逐字一致；消费方 grep 常量：`coord-inject`、`VOIDED`、`state=void|stalled`、`send_message(agent="lead")`。

### 3.4 `coordination.md §1` 基线定稿（4 条，实证锚/文档锚分列）

```markdown
**基线**（rc.5 实测 2026-11-23；实证锚 = 本变更双线具名派发与设计线开工/steer；文档锚 = dsh docs；证据见 diff-matrix.md）：
- **上下行 + 名寻址**：`send_message` 发树内任意成员，`lead`=根；运行中步骤边界收 steer、闲置起轮、冷目标恢复；未命中路径报 `AGENT_NAME_NOT_FOUND`（subagent:184/196-198；catalog:2311/2317）。
- **sibling 技术可达**（跨分支）：仍禁止私商写冲突，冲突归主会话（subagent:198；catalog:2298）。
- **本配置无硬中断**：`interrupt_agent` 未挂载（preset `interrupt:false`）；按工具面自检，不写「平台不可用」（rc.1 interrupt guide）。
- **委派即返名**：完成通知自动递送、结束后可续话（catalog:2237/2269）。
```
锚点文件短名约定：`subagent` = `docs/subsystems/subagent.zh.md`；`catalog` = `docs/tool-catalog.zh.md`；`rc.1 interrupt guide` = `docs/upgrade-guide/v0.2.2-rc.1/subagent-interrupt-default/guide.zh.md`。**不写 dsh 版本号以外的平台快照结论**；版本锚只在此处（C12）。

### 3.5 引擎选择判据（单条，唯一权威源 = `coordination.md §9`）

> 本组任务存在 `blocked_by` 依赖图、需动态认领或需写范围重叠告警 → 提示建议 `--engine team`，并说明需先在根会话菜单开启 Team 模式；用户拒绝或不可用 → 维持 subagent 并留痕；并发量不构成理由（两引擎同受 8 在线上限）。

`spec-apply/SKILL.md §三` 只写「升级判据见 `coordination.md §9`（单条）」——**不复制数字**，防双源。

### 3.6 delta 的 Requirement / Scenario 名集

> 规则：**MODIFIED 必须保留主规格该 Requirement 的全部现有 Scenario 名**（validator 硬门）；要删 Scenario 只能 `REMOVED` 整条 + `ADDED` 新名（同名 ADDED+REMOVED 是 ERROR）。ADDED 正文每条 ≤500 cp；MODIFIED 正文不得「超 500 且增长」（validator 仅在增长越限时 WARNING，strict 红）。

**A. `specs/spec-plan/spec.md`**
- REMOVED：`阶段 1 并行双线规划（team 驱动）`；`阶段级模型路由（规划键）`；`子代理与用户的交互中转（规划期）`
- ADDED：`阶段 1 并行双线规划（具名 fresh 子代理）` → Scenarios：`并行产出两份完整草案`、`两线具名派发`、`派发失败按线重派`、`两线相互独立`
- ADDED：`阶段级模型路由（规划键·恒适用）` → `映射指定规划阶段模型`、`映射为空`、`显式覆盖不丢弃`、`规划键无编排例外`
- ADDED：`子代理与用户的交互中转（规划期·同实例回送）` → `子代理上浮待决问题`、`设计期上浮并入落档提问`、`同实例续话回送`、`冷目标兜底重派`、`上行早到不改变提问节奏`
- MODIFIED：`栈识别与 writer skill 加载（设计侧）` → 保留主规格 `:275–305` 全部 **7** 个现有名：`栈命中加载对应 writer skill`、`双栈全加载`、`栈未命中问用户三选一`、`trivial 豁免标注 writer 约束`、`writer skill 加载失败上浮`、`任务粒度满足 writer 拆分规定`、`栈识别结论落盘`；新增 `纯文档类默认 writing-skills`。正文 405→约 460 cp（新增分支句 ≤55 cp）。**注**：lead 续话列出的 5 个名与主规格现名有出入——漏 `双栈全加载`、`trivial 豁免标注 writer 约束`；另 2 条为改写（`栈识别未命中任何判据`→`栈未命中问用户三选一`、`任务拆分粒度受 writer skill 约束`→`任务粒度满足 writer 拆分规定`）。按「以主规格为准逐字核对」采用 7 名。

**B. `specs/spec-apply/spec.md`**
- MODIFIED：`subagent 执行引擎` → 保留全部 5 个旧名：`执行提示携带设计要点`、`执行提示含 writer skill 加载指令`、`产出未通过核对`、`任务失败`、`派发注入协调段`；新增 `具名派发即返名`、`完成后同实例续话`、`受控嵌套只读`
- MODIFIED：`team 执行引擎` → 保留 3 个旧名：`逐 task 审核下修复`、`任务卡含 writer skill 加载指令`、`成员不可用`；新增 `Team 模式未开回退`、`任务卡含依赖与写范围`
- MODIFIED：`子代理与用户的交互中转(执行期)`（**ASCII 括号，逐字匹配主规格**）→ 保留 5 个旧名：`执行子代理上浮待决问题`、`subagent 引擎接续重派`（正文改为冷兜底）、`team 引擎同实例多轮澄清`、`授权假设清单推进`、`上行直报不改变代问节奏`；新增 `同实例续话优先`
- REMOVED：`subagent 运行协调(登记簿·检查点·上行)`；`执行侧模型路由`
- ADDED：`subagent 运行协调（登记簿 v3·检查点·上行）` → `写范围重叠让路`、`检查点废止生效(VOIDED)`、`停滞判定与重派(不轮询)`、`引擎升级判据仅在派发前提示`、`登记簿单写者与子代理只读`、`下行废止通知仅加速`、`本配置无硬中断可用`
- ADDED：`执行侧模型路由（两引擎适用）` → `映射指定执行模型`、`映射为空`、`team 引擎同样应用 apply 键`

**C. `specs/spec-workflow/spec.md`**
- MODIFIED：`子代理与用户的交互中转（执行期）`（**全角括号，逐字匹配**）→ 保留 4 个旧名：`执行子代理上浮待决问题`、`subagent 引擎接续重派`、`team 引擎同实例多轮澄清`、`授权假设清单推进`；新增 `同实例续话优先`

**正文预算（ADDED ≤500 cp，超则 strict 红）**：`subagent 执行引擎` ≈420（含嵌套纪律 + 续话句）；`subagent 运行协调（登记簿 v3·检查点·上行）` ≈470–520，**若 >500 按备用拆分**——`subagent 运行协调（登记簿与检查点）`（≤350）+ `subagent 上行与冲突裁决`（≤350），两条 ADDED 替代一条，Scenario 名集合不变，5.1 内完成、不新增组；`执行侧模型路由（两引擎适用）` ≈300；spec-plan 三条 ADDED ≈300/280/380；spec-plan MODIFIED `栈识别与 writer skill 加载（设计侧）` 405→**≈460**（新增分支句 ≤55 cp，不得越 500）。

### 3.7 派发调用形状

```
subagent(name="plan-a" | "apply-<g>-<t>" | …, description="3–5 词", prompt="<自包含>") → 立即返回；回执文本 "started subagent <name>"
```
- 除 `provider`/`model` 外无引擎字段（无 `run_in_background`、无 `context`）；模型路由仅在 `apply`/`plan-a` 等键上按 `<cfg>` 应用（fresh 子代理才支持）。
- team 引擎：`team_task_create(subject, description, blocked_by[], write_scopes[])` → `team_task_update(id, owner=<name>, revision)` CAS；implementer 以同名 `subagent` 派发认领。

---

## ④ 决策记录

> 每条附被否方案与理由；可复现反例集中在 4.12。

**D1 栈识别结论：writer skill = `writing-skills`（用户指认）**
- 证据：`writing-skills` 位于聚合层 `/home/docker/.agents/skills/writing-skills/SKILL.md:2–3`，本会话加载成功；栈判据实测**零命中**——`pom.xml`/`build.gradle(.kts)` 不存在、`nuxt.config.*` 不存在、`opencode/package.json` 与 `tools/skctl/package.json` 均无 `nuxt` 依赖；触达面 17 项全为 markdown（零应用代码）。
- 被否：`spring-writer`（判据=Spring Boot 构建文件，零命中；套用会引入 Java 分层/控制器规范）；`nuxt-writer`（判据=Nuxt 配置或依赖，零命中；套用会引入 pages/components 规范）；`dsh-plugin-writer`（作用域=dsh-plugins 仓插件包与 `package.json`/`cordis.patch.yml`/`build.mjs`，本变更零插件源码，且 `dsh/` 配置按 C14 零改动）。
- 结论落入落档 `design.md` 决策记录（spec-plan §六硬要求），执行侧从工件读取。

**D2 组序：G1 事实基线 → G2 spec-apply → G3 spec-plan → G4 编排层 → G5 delta → G6 终检**
- 理由（依赖边，非拍脑袋）：`spec-plan/mode/parallel.md:47`、`spec-plan/SKILL.md:82` 指路 `coordination.md §7`；`spec-plan/SKILL.md:77/:121` 复述回送；`spec-workflow/SKILL.md:65/:96` 复述登记簿与回送。协议**源在前、消费面在后**，避免消费面先写、指到未改的旧 §7（这正是要消灭的 `agent_id` 漂移）。
- 被否：spec-plan 先（line-a 组序）——`parallel.md` 会短暂引用仍写 `agent_id` 的 `coordination.md §7`，形成"执行期实际收到旧注入"的狗粮回环；diff-matrix 的「组序交 1.7 按依赖定」据此裁定为 **spec-apply 先**。

**D3 delta 形态：删 Scenario 的 Requirement 用 REMOVED+ADDED 换名，其余 MODIFIED**
- 理由：validator 对 MODIFIED 省略现有 Scenario 直接 ERROR（`validator.js:689–699`），留旧名即留假事实；必须整条换名才能合法删场景。
- 被否：①MODIFIED 保留旧名、正文改写——`team 驱动派发`/`混合编排合法`/`team 编排忽略规划键`/`team 引擎忽略 apply 键`/`完成前奏上报` 五个名字本身断言已废机制；②直改主规格绕过 delta——破坏 spec-driven 归档链，且 `--skip-specs` 例外不适用。

**D4 coordination.md 预算：压 §5/§9、补 §1/§2，目标 4930–4990**
- 逐节预算：§1 311→473（+162），§2 936→1130（+194：字段行 + 命名段），§3 215→239（+24），§4 729→699（−30），§5 796→502（−294：删「成」行与两示例留一），§6 383→416（+33：下行通知行），§7 464→426（−38），§8 464→469（+5），§9 337→252（−85），§10 265→265；加前言 96 → **≈4967**。
- 被否：把命名规约搬到 `execution.md`（登记簿身份定义出现第二源）；放宽 §10 上限（改既有纪律，且消费方长度门随之失效）。执行期若 >4990，先删 §5 示例（−≈120）再删 §8 第 5 行扩写，**不动 §2 字段表**。

**D5 登记簿保留 + `agent=name`（C5）；不换 task_board / list_agents**
- 理由：具名派发解决**寻址**，不解决**对账**——`list_agents` 的 `running/inactive`「不表示任务完成」（`tool-catalog.zh.md:2298`），树枚举随会话存活、不落盘；压缩后恢复仍需落盘台账。name 是派发即得、模型面可寻址的唯一稳定身份。
- 被否：①`task_board_*` 当台账（第三方插件、宿主侧不入库、无写范围状态机，且不在官方 catalog）；②`list_agents` 轮询（非持久、语义不含完成）；③双记 name+uuid（派发回执只返回 name，uuid 对模型面无寻址价值）。

**D5b 两条已定裁定的落点（不新裁，只登记写哪儿）**
- **C6 受控嵌套**（用户裁定）：规则落 `execution.md` 的「提示自包含（缺一不可）」项——「只许派只读孙代理（检索/分析/复核），不得派可写子代理；孙代理提示自包含、写明只读、转述本任务硬约束；产出由派发者核对」。存在理由：本 profile `maxDepth: 2`（`config-catalog.zh.md:3747` 默认 1，profile 覆盖为 2）使孙代理可达；不写则深度成为无约束面。delta 侧在 `subagent 执行引擎` 增 Scenario `受控嵌套只读`（③.6B）。
- **C9 工具面留痕**（用户裁定，落档 `design.md` 素材）：`task_board_*` → 第三方 `@linxin666/dsh-client-ui-task-board`，不采纳（宿主面板语义、不入库、无写范围状态机）；`notes_*` → 第三方 `@zzerx/dsh-plugin-notes`，不采纳（便签非协调台账）；`workflow` → 官方，不采纳（显式大规模扇出，双线规划用普通 subagent 即可）；`subagent_fork` → 官方，不采纳（继承父对话，破坏独立性铁律；preset 保持其路由字段关闭）。落档时按「工具面 / 来源 / 采纳与否 / 理由」四行写入 design.md。

**D6 注入段保持 7 条「配方」结构，只改 3/4/6/7 条，不新增禁令**
- 理由：writing-skills「Match the Form to the Failure」——这里是"漏要素/错形状"，正向配方加槽有效；禁令在实测中更差（`coordination.md:59` 既有 D12 结论）。
- 被否：加「不要互商/不要等答复」等禁令句——增加协议重量且制造可协商空间。反例见 4.12③。

**D7 触达面补入 3 文件（上游双线均漏）**
- 补入：`spec-plan/refs/planning.md:41–42`（1.7 模板仍教 `agent_id`、writer 仅 spring/nuxt）、`spec-plan/refs/convergence.md:27`（"回送同一成员或接续重派"）、`dsh/README.md:142/155/161/173–174`（spawn/成员上限/回送表）。
- 理由：①`planning.md` 是阶段 1.7 的唯一模板源，本设计线正是其消费者，不改则下一次派发继续复制旧断言；②`dsh/` 在死名清零 grep 面内（`dsh/README.md:173` 含 `spawn_teammate`），不补则 G6 永远红；③convergence 是回送语义的第二处复述，不改即双源。
- 被否：①留给后续变更（本变更 "漂移清零" 目标不成立，且 G6 门自相矛盾）；②把 grep 面缩到 `agent/skills`（掩耳盗铃，README 仍是用户可见文档）。

**D8 spec-done 轻触 2 行（`verify-<n>`）**
- 理由：C4 命名规约含 `verify-<n>`；spec-done:24/:39 是唯一派发 `verify` 子代理的落点，不写则该名无落点。仅两行、零行为变化。
- 被否：零改动（C4 的 verify 分支悬空）；大改（越出收尾链，违反 N4）。

**D9 Team 前置检查只落 spec-apply，不在 spec-workflow 复制**
- 理由：单一权威源；workflow 只做衔接话术（"team 需用户在根会话菜单开启"），判据与工具面检查归执行半程。
- 被否：line-a 4.1 的"workflow 也加团队工具面检查"——两处判据必然漂移（一处改、一处忘），正是本次要消灭的模式。

**D10 命名短码：`-<首段6><名长>`；只在重名被拒时使用**
- 理由：C4 只定"重名追加变更短码"；短码需确定性、≤6 字符、可读，`adapt28` 同时编码变更首段与长度，碰撞概率低。
- 被否：首段截 12（`adapt-specsk`，长且碰撞概率高）；全序号 `a-1`（零可读性，恢复时无法辨变更）。

**D11 长度门口径：`body+343`；spec-plan 正文净增 ≤0**
- 理由：历史归档口径可复算；spec-plan 现余量 342，上游 R8 的 46 已过期（add-ui-demo-gate 提交后未复测）。锁定净增 ≤0 比"余量 ≥40"更抗漂移。
- 被否：按文件总长+343（会把 frontmatter 变动算进正文，口径与归档先例不一致）；沿用 46 硬门（数值失真，无法作为执行期断言）。

**D12 D5 用户裁定并入「纯文档/技能类」栈判据分支（与本文件推荐 b 相反）**
- 裁定：用户裁 **a**——判据分支并入本变更，落点 4 处：`planning.md:23`（增分支，Spring/Nuxt 与未命中三选一不变）、`spec-plan/SKILL.md:96`（§六 同步）、`spec-plan` delta MODIFIED（保留 7 现有 Scenario + 新增 `纯文档类默认 writing-skills`）、`dsh/README.md:155`（同步点名句）。
- 长度预算处理：SKILL §六 新增约 45 cp，以 §四 :56/:70/:77、§八 :110、§九 :121 的删除等量抵扣——正文净增仍 ≤0（改后预计 ≈7245，远低于 7507）；`planning.md` 净增 ≈80 cp（7645→≈7725，≤7900 门）；delta MODIFIED 正文 405→≈460（≤500，不触发 strict 警告）。
- 被否：**b 另立小变更**（用户已裁 a；分离会让本变更的 1.7 模板与判据不同批，执行期读到的模板与判据版本错位）；「只写 SKILL 不写 delta」（行为变更无规格依据，归档后主规格漏掉分支）。
- 反例：只改 `planning.md` 判据、不改 delta——归档后 `spec-plan` 主规格仍只说「未命中三选一」，下次 1.7 同时读到两套规则；只改 SKILL 不加判据——纯文档仓永远走三选一，用户裁定失效。

**4.12 反例（至少三条，均为可复现的失败路径）**
1. **delta 用 MODIFIED 删 `完成前奏上报`**：`openspec validate <change> --strict` 直接 ERROR（`validator.js:695`），且 `--strict` 下 WARNING 也红（`:919`）——落档门禁必挂。
2. **不补 `dsh/README.md`**：G6 的 `grep -rn 'spawn_teammate' dsh/` 命中 `README.md:173`，RED 门永远无法转绿；同一条 grep 也会把 `agent/skills` 的旧断言与 README 的旧断言混在一起，掩盖真实遗漏。
3. **把注入段写成禁令**（"不得互商"而非"冲突经主会话裁决"）：与 `coordination.md:59` 记录的 writing-skills 实测结论相反——禁令让子代理在压力下寻找例外；配方（条件→动作）才可机械核对。
4. **加载 spring-writer 做本设计**：会把 Java 分层/服务复用规则套到 markdown 规范上，任务拆分会围绕不存在的 controller/service 展开——正是"栈未命中问用户三选一"机制要防的错配。

---

## ⑤ 逐任务组实现要点

> **任务分组在此定稿**（落档 `tasks.md` 的 `## N. 组名` 必须与本字段一一对应，不得增删组或调序）。
>
> 组间严格串行、组内可并行（单组任务数 ≤ `parallelism`=8）；每任务描述引用触达面编号；验证句第三方可复跑；`<change>` = `adapt-spec-skills-to-dsh-rc5`。

### 组 1 · 事实基线与 RED 断言（只读，零仓库写入）
**1.1** 固化 RED 清单与长度基线：对 `agent/skills dsh/commands dsh/spec-workflow.yaml dsh/README.md` 跑过时词 grep，落 `/tmp/spec-flow/<change>/red-baseline-v2.txt`（触达 #1–#14）。
验证：`test -s /tmp/spec-flow/<change>/red-baseline-v2.txt` 且 `grep -c 'spawn_teammate' …` 输出 ≥3（RED 成立）；`python3 -c` 打印四入口 `len(正文)+343` 与 coordination cp，与 ①1.3 表逐项相等（±0）。
**1.2** 补入面锚核对（只读）：`sed -n '41,42p' agent/skills/spec-plan/refs/planning.md`、`sed -n '27p' …/convergence.md`、`sed -n '142p;155p;161p;173,174p' dsh/README.md`（触达 #11/#10/#14）。
验证：上述输出分别含 `agent_id`、`回送同一成员或接续重派`、`spawn`/`Team member limit 8`/`接续重派`；`grep -c 'writing-skills' dsh/README.md` = 0。

### 组 2 · spec-apply 协议内核（协议源）
**2.1** `coordination.md` 改写（触达 #1，全部节按 ③.1/3.3/3.4/3.5）。
验证：`python3` 断言 `3800 ≤ len(s) ≤ 5000`、`'agent_id' not in s`、`'互不可达' not in s`、`s.count('send_message(agent="lead")') ≥ 2`、`'成=' not in s`、注入段 `7 ≤ 行数 ≤ 15`；`grep -c '完成前奏'` = 0。
**2.2** `execution.md` 两引擎段重写（触达 #2）。
验证：`grep -c 'spawn_teammate\|Team member limit\|忽略 .apply. 路由'` = 0；`grep -c 'team_task_create'` ≥1；`grep -c 'write_scopes'` ≥1；`grep -c 'send_message(agent="lead")'` ≥1；`grep -c '只读孙代理'` ≥1；`python3 -c` 文件 cp ≤8192。
**2.3** `spec-apply/SKILL.md`（触达 #3）。
验证：`python3 -c` 「正文+343 ≤ 8192」退出 0；`grep -c 'agent_id'` = 0；`grep -n 'coordination.md §9'` 命中；`grep -c '接续重派'` = 0。
**2.4** `spec-apply/refs/routing.md` + `refs/failure-modes.md`（触达 #4/#5）。
验证：`grep -c 'team 引擎忽略' routing.md` = 0；`grep -c 'list_subagent_models' routing.md` ≥1；`grep -c '下行.*不可达' failure-modes.md` = 0；`grep -c '三类' failure-modes.md` = 0。

### 组 3 · spec-plan 消费面
**3.1** `mode/parallel.md` 重写（触达 #7）。
验证：`grep -c 'spawn_teammate\|run_in_background\|引擎差异段'` = 0；`grep -c 'plan-a'` ≥1 且 `plan-b` ≥1；`grep -c 'send_message(agent="lead")'` ≥1；`python3 -c` cp ≤4000。
**3.2** `spec-plan/SKILL.md`（触达 #6）。
验证：`python3 -c` 断言 `len(正文) ≤ 7507` 且 `len(正文)+343 ≤ 8192`；`grep -c 'team 驱动\|spawn_teammate\|agent_id\|接续重派'` = 0；`grep -c 'send_message(agent="lead")'` ≥1；`grep -c 'writing-skills'` ≥1 且 `grep -n '纯文档'` 命中（§六 分支）。
**3.3** `refs/routing.md` + `refs/failure-modes.md`（触达 #8/#9）。
验证：两文件 `grep -c 'Team member limit\|spawn_teammate\|team 成员无模型参数'` = 0；`grep -c 'list_subagent_models' routing.md` ≥1；failure-modes `grep -c 'agent_id'` = 0。
**3.4** `refs/convergence.md:27` + `refs/planning.md:23/:41–42/:77`（触达 #10/#11）。
验证：`grep -c '回送同一成员或接续重派' convergence.md` = 0；`grep -c 'agent_id' planning.md` = 0；`grep -c 'spring-writer / nuxt-writer' planning.md` = 0；`grep -c '纯文档' planning.md` ≥1 且 `grep -c 'writing-skills' planning.md` ≥2（分支 + 模板）；`grep -c 'spring-boot' planning.md` ≥1（既有判据未删）；`python3 -c` planning.md cp ≤7900。

### 组 4 · 编排层与仓文档
**4.1** `spec-workflow/SKILL.md`（触达 #12）。
验证：`grep -n '登记簿（v3'` 命中；`grep -c '接续重派'` = 0；`grep -n 'Team 模式'` 命中；`python3 -c` 正文+343 ≤8192。
**4.2** `spec-done/SKILL.md`（触达 #13）。
验证：`grep -c 'verify-<n>'` = 2；`python3 -c` 正文+343 ≤8192。
**4.3** `dsh/README.md` 四处（触达 #14）。
验证：`grep -c 'spawn_teammate\|Team member limit\|接续重派'` = 0；`grep -c 'writing-skills'` ≥1；`grep -c '纯文档'` ≥1；`grep -n 'team_task_create'` 命中。

### 组 5 · 三主规格 delta（新建）
**5.1** `specs/spec-apply/spec.md`（触达 #16，名集见 ③.6B）。
验证：`openspec validate <change> --strict` 退出 0；`python3` 断言每个 Requirement 正文 ≤500、`REMOVED` 名在主规格逐一存在、MODIFIED 的 Scenario 名集 ⊇ 主规格同名集合。
**5.2** `specs/spec-plan/spec.md`（触达 #15，③.6A）。
验证：同 5.1（capability=spec-plan）；另断言 3 个 REMOVED 名与主规格 `openspec/specs/spec-plan/spec.md` 逐字一致（含全角括号）；MODIFIED `栈识别与 writer skill 加载（设计侧）` 的 7 个现有 Scenario 名逐字存在于 delta、正文 ≤500、新增名 `纯文档类默认 writing-skills` 不在主规格。
**5.3** `specs/spec-workflow/spec.md`（触达 #17，③.6C）。
验证：同 5.1（capability=spec-workflow）；MODIFIED 名与主规格 `:167` 逐字一致（全角括号）。

### 组 6 · 终检（只读，全量门）
**6.1** 死名清零（触达 #1–#17）。
验证：`grep -rn 'spawn_teammate\|Team member limit\|agent_id\|互不可达\|run_in_background' agent/skills dsh/commands dsh/spec-workflow.yaml dsh/README.md openspec/specs` 无输出；`grep -rn '接续重派' agent/skills dsh/README.md openspec/specs` 仅允许出现在「冷兜底/失败重试」语境（人工逐条核并留痕）。
**6.2** 长度门全量。
验证：四 SKILL.md `len(正文)+343 ≤ 8192`（spec-plan 另 `len(正文) ≤ 7507`）；`coordination.md` 3800–5000；注入段 `awk` 7–15 行；`planning.md` ≤7900；其余 refs ≤8192。
**6.3** 规范校验。
验证：`openspec validate <change> --strict` 退出 0 且 `--json` 输出 `summary.warnings == 0`（单变更口径；`--all --strict` 不作门，主规格既有告警另账）。
**6.4** 指针与红线锚。
验证：`test -f` 逐个核对跨文件指针（`spec-plan/SKILL.md` → `coordination.md`、`execution.md`、`refs/*`；`spec-workflow` → `spec-apply` refs；`spec-done` → `worktree.md`/`routing.md`）；`grep -c 'DELEGATED_CALLER'` 三处入口各 ≥1；`grep -n '审核确认前提交\|绝不重跑\|干净窗口\|三方对齐'` 均命中。

**组间依赖理由**：G1→G2 基线冻结（cp/grep 数值成为后续断言常量）；G2→G3 协议源先于消费面（`parallel.md:47`/`SKILL.md:82` 指路 §7）；G3→G4 编排层复述最终术语（含 §六 栈判据分支）；**G3.2/3.4 的判据分支句是 G5.2 MODIFIED 正文来源**（delta 与 skill 必须同批语义，G5.2 不得先于 G3 改写判据）；G4→G5 delta 的 THEN 句逐字引用最终机制表述；G5→G6 终检对象齐备。**执行期狗粮约束**：G2 提交后，G3+ 派发注入段必须从已提交的 `coordination.md §4` 现读，不得凭旧记忆粘贴；执行本变更不得使用已删的「成」事件与 `agent_id`。

---

## ⑥ 设计假设与未决项

**假设（执行前逐条复核，失效即回报）**
- A1 rc.5 docs 与运行时同步；rc.5 相对 rc.4 无 subagent 面破坏性变更（docs 已读至 rc.4 条目，rc.5 无独立 breaking 指南）。
- A2 执行期 profile 不变：`interrupt: false`、`maxDepth: 2`、Team 模式默认关；`dsh/spec-workflow.yaml` 与 `profiles/web/*` 的用户未提交改动**不触碰、不暂存**（R11）。
- A3 openspec 2.1.1 的 validator 行为与 ②2.3 读数一致（scenario-loss ERROR、strict WARNING 失败、ADDED 500 上限）。
- A4 聚合层 `writing-skills` 可加载（本会话已验）；其路径是容器内只读 bind mount，无需装。
- A5 ② 的 file:line 为 2026-11-23 快照；执行期编辑前必须重读定位（行号漂移以现文为准，断言按内容不按行号）。
- A6 长度门 8192 = pruner 默认阈值且本 profile 未覆盖（A8 沿用；执行期以 6.2 实测为准）。
- A7 触达面零应用代码 → 无构建/测试/CI 门；验收 = grep 常量 + 码点 + `openspec validate`。
- A8 `team_task_create` 仅根会话开启 Team 模式后可见，无法在无 UI 会话端到端演练；team 段以文档核对代替（R6）。
- A9 重名判定作用域 = 同一创建者的子代理；命名短码只在被拒后启用，不预判。
- A10 冷目标 `send_message` 恢复的实际可靠性未实证（U3）；恢复协议仍以登记簿+落盘为权威。
- A11 栈判据分支的触发条件按**触达面事实**判定：全部为 markdown 规范/技能/文档且零应用代码；本变更 ① 的 17 项清单即事实依据。触达面出现任一代码/配置文件 → 分支不触发，回退 Spring/Nuxt 判据 + 三选一。

**未决项**：见下方「待决问题」D1–D5（TOP：D1 触达面补入、D2 delta 结构换名、D3 coordination 预算）。

---

## 待决问题（六字段之外）

> 以下 5 条均已由用户在 2026-11-23 续话中裁定（D1–D4 = a；**D5 = a，与设计线推荐 b 相反**）。保留裁定留痕与落地清单；执行期不得再作为开放项重开。

**D1 触达面补入 3 文件** —— **用户裁定 = a（纳入本变更）**
- 原问题：上游双线均漏的 3 个文件含同一批过时断言——`planning.md:41–42`（模板仍教 `agent_id`）、`convergence.md:27`、`dsh/README.md:142/155/161/173–174`（spawn/成员上限/回送表）。
- 落地：按 ① 17 项执行不变；G3.4（planning/convergence）与 G4.3（README）已在组内；6.1 grep 面含 `dsh/README.md`。
- 影响面：无新增文件；既有文件净行数 0。

**D2 三主规格 delta 采用「REMOVED+ADDED 换名」** —— **用户裁定 = a**
- 落地：按 ③.6 执行，共 15 个条目——spec-plan：3 REMOVED + 3 ADDED + 1 MODIFIED；spec-apply：3 MODIFIED + 2 REMOVED + 2 ADDED；spec-workflow：1 MODIFIED。
- 影响面：归档后主规格 5 处 Requirement 名变化；5.1/5.2/5.3 验证句不变。

**D3 coordination.md 压到 4930–4990** —— **用户裁定 = a**
- 落地：按 ④D4 逐节预算执行；§5 只留 1 个示例；若仍 >4990，按 D4 降级顺序先删 §5 示例、再删 §8 第 5 行扩写。
- 影响面：§10 自述、6.2 断言。

**D4 spec-done 轻触 2 行（`verify-<n>`）** —— **用户裁定 = a**
- 落地：4.2，`:24`/`:39` 两处具名。
- 影响面：spec-done 渲染门（余量 1989，无风险）。

**D5 栈识别判据分支并入** —— **用户裁定 = a（并入，与设计线推荐 b 相反）**
- 落地清单：
  1. `spec-plan/refs/planning.md:23` 判据段增「纯文档/技能类（触达面零应用代码、全为 markdown 规范/技能/文档）→ 默认命中 `writing-skills`，不问三选一」；Spring/Nuxt 判据与未命中三选一不变。
  2. `spec-plan/SKILL.md` §六 `:96` 同步该分支；正文 ≤7507 且净增 ≤0（新增 ≈45 cp，以 §四/§八 删除等量抵扣）。
  3. `spec-plan` delta **MODIFIED** `栈识别与 writer skill 加载（设计侧）`：保留主规格 `:275–305` 全部 **7** 个现有 Scenario——`栈命中加载对应 writer skill`、`双栈全加载`、`栈未命中问用户三选一`、`trivial 豁免标注 writer 约束`、`writer skill 加载失败上浮`、`任务粒度满足 writer 拆分规定`、`栈识别结论落盘`；新增 `纯文档类默认 writing-skills`；正文 405→≈460（≤500）。**注**：lead 续话的 5 个名与主规格有出入（漏 2 条、改写 2 条），已按「以主规格为准逐字核对」采用 7 名（明细见 ③.6A）。
  4. `dsh/README.md:155` writer 点名句同步（并入 G4.3）。
  5. 任务句：G3.2/G3.4/G4.3 验证句已增补；G5.2 已增 MODIFIED 名集与 ≤500 断言。
  6. 留痕：② 2.1 增 `planning.md:23` 现文锚；④ 增 D12；⑥ 增 A11。
- 影响面：spec-plan delta 行数 +35（① 总净 +312）；`planning.md` 净增 ≈80 cp（≤7900）；SKILL 正文仍净减；C1–C14 不变。

---

**1.75 界面演示 gate**：1.75 未触发：C1 不成立（触达面 17 项全为 markdown 规范文档与 OpenSpec delta，零页面/组件/布局/交互产出）。
