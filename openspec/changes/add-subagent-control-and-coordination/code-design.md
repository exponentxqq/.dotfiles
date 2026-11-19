# code-design：add-subagent-control-and-coordination

> 阶段 1.7 代码设计线（串行单线）｜输入：需求原文 + `explore.md`（95 行）+ `decisions.md`（44 行），逐字读全
> **栈识别结论：writer skill = `writing-skills`**（用户指认；判据与证据见 ④D0）
> **平台事实基线（本设计任何协议文本不得违反）**：lead→subagent 下行 ✗｜subagent→lead 上行 ✓（subagent 面 `send_message`，父 session id 在 runtime context）｜sibling 互达 ✗｜无硬中断（`interrupt_agent` 仅 teammate、`job_list` 不含 subagent）——来源 `explore.md:42-47`（双探针实证，2026-11-19 / dsh 0.2.2-rc.1）
> 本文件是**代码级蓝图**：给到「哪个文件第几行、改成什么形状、断言怎么跑」。需求级轻重与风险见上游两份材料，不复读。

## 零、writing-skills 作为硬约束：四条落到本设计

| writing-skills 条款 | 本设计的落地形态 |
| --- | --- |
| Iron Law：新 skill 与**编辑既有 skill** 都必须「先见失败」（RED→GREEN） | **组 1 = RED 基线**（写作前派 fresh 子代理跑同场景），**组 6 = GREEN 配对复测**；RED 未复现则如实标注不伪造（⑤组1/组6） |
| Token 效率：外移重参考（100+ 行）到独立文件，入口只留路由 | 协议正文进**新建** `refs/coordination.md`；`execution.md` 只加 2 行行为句 + 1 处台账改写 + 1 处回执追加；入口 SKILL.md 只加 3 处短句（③3.9 逐文件 cp 预算） |
| Match the Form to the Failure：**omission 型失败用「正向配方 + 必填槽」，不用禁令清单** | 协调段写成 7 条编号配方（每条一个必填动作槽），不是「不要盲写/不要互相等待」式禁令（④D12） |
| 描述只写触发条件、不概述工作流 | **frontmatter 一字不动**（两 skill 的 `description` 已含 `Use when` 触发句），避免 SDO 回归 |

## ① 触达面清单

所属仓：**dotfiles 根仓**（`/home/xuqinqin/develop/dotfiles`）——以下 13 条全部在该仓，无子仓。

| # | 文件（仓内相对路径） | 改动性质 | 改动意图 | 关键改动点（行号＝当前基线） |
| --- | --- | --- | --- | --- |
| 1 | `agent/skills/spec-apply/refs/coordination.md` | **新建**（约 120–140 行 / 3800–5000 cp） | 协调协议**唯一权威源**：登记簿、检查点、上行、软废止、冲突矩阵、引擎升级判据、spec-plan 精简段 | 10 节：§1 平台事实与协议边界｜§2 登记簿 schema+状态机｜§3 派发前登记序｜§4 注入段模板（带 `coord-inject` 标记）｜§5 上行格式｜§6 检查点与软废止｜§7 spec-plan 精简段（**spec-plan 只指路到此节**）｜§8 冲突矩阵｜§9 升级判据｜§10 长度与维护 |
| 2 | `agent/skills/spec-apply/refs/execution.md` | 改（≈+445 cp） | subagent 引擎段接租约/检查点/上行；team 段声明不注入；回执契约增废止信号 | `:8` 台账段重写为 v2 登记簿（含状态机与单写者，+92 cp）＋其后插「协调注入」行（+209 cp，含平台不可达事实）＋team 段 `:15-21` 后插「team 不注入协调段」行（+104 cp）＋`:9` 回执格式追加「命中废止/停滞时首行 `VOIDED`/`STALLED`」（≈+40 cp） |
| 3 | `agent/skills/spec-apply/SKILL.md` | 改（+423 cp） | 入口接线：协调纪律、上行通道、refs 路由 | `:39` 路由行追加「仅 subagent 派发前另读 coordination.md」（87 cp）｜`:37` 后插「协调纪律（仅 subagent 引擎）」行（223 cp，含**派发前**升级判据提示）｜`:43` §四 追加「上行通道」句（113 cp） |
| 4 | `agent/skills/spec-apply/refs/failure-modes.md` | 改（+590 cp） | 修正与平台事实矛盾的两行；补两类新失败 | `:17` 拆方向重写（下行不可达/上行可用，221 cp）｜`:18` `job_list` 判据作废（164 cp）｜新增 2 行：检查点命中 void/stalled（121 cp）、上行发送失败降级（84 cp） |
| 5 | `agent/skills/spec-plan/SKILL.md` | 改（**+97 cp，硬上限**） | 规划期中转协议段补上行通道（仅两类事件，节奏不变） | `:80`（两条禁令）后插 1 行（97 cp）→ 渲染 8146/8192，余量 46（③3.9 实测） |
| 6 | `agent/skills/spec-plan/mode/parallel.md` | 改（+249 cp） | A/B 线模板注入精简段；回执核对加一句 | `:45` 硬约束块末补 2 行（215 cp，**两线等形**）｜`:53` 回执核对追加 34 cp（收到上行仍并入 1.5） |
| 7 | `agent/skills/spec-plan/refs/planning.md` | 改（+162 cp） | 阶段 1.7 设计线模板注入同名精简段 | `:41`（先加载 writer skill 行）后插 1 行（162 cp）；不改六字段与回执核对清单（`:46`） |
| 8 | `agent/skills/spec-plan/refs/convergence.md` | 改（+38 cp） | 复算线（第三条线）声明同款上行口径 | `:13` 复算子代理 bullet 追加「上行同学 §四 精简段：仅决/异，无租约、无检查点」 |
| 9 | `agent/skills/spec-plan/refs/failure-modes.md` | 改（+82 cp） | 规划侧上行失败降级一行 | 表末新增 1 行（`:20` 之后、`:22` 注之前） |
| 10 | `openspec/changes/add-subagent-control-and-coordination/specs/spec-apply/spec.md` | **新建（落档期，阶段 2）** | spec-apply delta：2 MODIFIED + 1 ADDED | 文案见 ③3.8（ADDED 429 cp ≤500）；场景 16 个；由 `openspec-propose` 在落档生成，执行期只核对（组 5） |
| 11 | `openspec/changes/add-subagent-control-and-coordination/specs/spec-plan/spec.md` | **新建（落档期，阶段 2）** | spec-plan delta：1 MODIFIED | 文案见 ③3.8（422 cp ≤500）；场景 5 个 |
| 12 | `openspec/specs/spec-apply/spec.md`（:27 与 :174 两条需求）＋`openspec/specs/spec-plan/spec.md`（:102） | **不直接编辑；归档期合并** | 归档时由 delta 合并为终态 | 断言：合并后 `openspec validate spec-apply --strict` 仍 exit 0（当前基线绿）；spec-plan 侧**不得新增** warning（当前基线已红 2 条，见 ⑥A5） |
| 13 | `agent/skills/spec-workflow/SKILL.md` | 改（联动，**越出 decisions Q1 范围 → 待决 P1**） | `:65` 恢复协议仍写「`job_list` 判在途/已丢」——与平台事实直接矛盾，且与本变更登记簿语义冲突 | 单行改写：删 `job_list` 判据、改「登记簿条目状态 + 写范围落盘事实」；**无 spec delta**（`openspec/specs/spec-workflow/spec.md` 无此文本，已核对） |

**明确不触达（附理由，防执行期即兴扩面）**

| 文件 | 不动的理由 |
| --- | --- |
| `agent/skills/spec-apply/refs/routing.md` | 无新路由键；`dsh/spec-workflow.yaml` 无新键（`:44 engine` / `:47 parallelism` 已够） |
| `dsh/spec-workflow.yaml`、`dsh/commands/*.md` | 无新参数/子命令；`--engine team` 已存在于 `spec-apply.md` 的 `argument-hint` |
| `agent/skills/spec-plan/mode/serial.md` | 串行单线无规划子代理（`:12`「不得再派规划成员/子代理」），1.5 仅「必要时派只读子代理」查证，无待决上浮面 |
| `agent/skills/spec-plan/refs/routing.md` | 同上，无新键 |
| `agent/skills/spec-done/*` | 清理面已覆盖 `/tmp/spec-flow/<change>/` 整目录（`openspec/specs/spec-done/spec.md:100`），登记簿随之消失，无需改 |

## ② 证据锚

| 模块 | 锚点（file:line） | 代码事实 |
| --- | --- | --- |
| #1 coordination.md | **新建** | —（动机锚：`agent/skills/spec-apply/refs/execution.md:8` 现有台账只有 4 字段「组号/任务号/派发时间/写范围」，无状态机、无写者约束、无废止语义；`explore.md:43` 上行通路实证） |
| #2 execution.md | `agent/skills/spec-apply/refs/execution.md:8` | 全文：「每批派发前把「组号/任务号/派发时间/预期落盘文件（=写范围）」写入 `/tmp/spec-flow/<change>/progress.md`…回执到达后销账」——**销账即删除/改写，无历史态**，且未规定写者 |
| #2 execution.md（提示自包含纪律） | `agent/skills/spec-apply/refs/execution.md:5` | 「提示自包含（缺一不可）：**项目根绝对路径**…**栈对应 writer skill 加载指令**」——清单是**封闭枚举**，不新增协调段则子代理收不到协调指令 |
| #2 execution.md（回执契约） | `agent/skills/spec-apply/refs/execution.md:9` | 回执四要素：改动文件清单/验证命令与输出摘要/偏差与未完成项/TOP 待决——无 `VOIDED` 位 |
| #2 execution.md（team 面已有控制） | `agent/skills/spec-apply/refs/execution.md:18-20` | team 有 `send_message` 回同一成员、`interrupt_agent` 中断重建——**控制能力只存在于 team 引擎**，正好反证 subagent 引擎无等价物 |
| #3 SKILL.md | `agent/skills/spec-apply/SKILL.md:39` | refs 消费时机路由行（「派发前（两引擎）读 execution.md…仅 subagent 派发前读 routing.md」）——**新 refs 文件必须在此登记**，否则读不到 |
| #3 SKILL.md（骨架） | `agent/skills/spec-apply/SKILL.md:28-35`（围栏 28/35，正文 29–34） | 批次循环骨架，`:31` 派发（subagent 一支）、`:33` 主会话核对——协调步骤须挂在 `:31` 与 `:33` 之间 |
| #3 SKILL.md（红线区） | `agent/skills/spec-apply/SKILL.md:55` | 第七节红线枚举（不静默假设/不重跑/不 force push…）——本次只在§三/§四加行为，**红线一字不改** |
| #4 failure-modes.md | `agent/skills/spec-apply/refs/failure-modes.md:17` | 原文断言「子代理不是 teammate、**不可消息寻址**」——**方向性错误**：错的是 lead→子代理，子代理→lead 可达（`explore.md:43`） |
| #4 failure-modes.md | `agent/skills/spec-apply/refs/failure-modes.md:18` | 原文「`job_list` 判「在途/已丢」」——平台事实 `job_list` 不含 subagent（`explore.md:45` 探针 2 运行中实测为空） |
| #5 spec-plan SKILL.md | `agent/skills/spec-plan/SKILL.md:74-80` | 中转协议 5 步（①上浮 ②代问 ③记录 ④回送 ⑤终止）＋两条禁令，**④只写「team 用 send_message」，subagent 侧无上行通道** |
| #5 spec-plan SKILL.md（长度） | `agent/skills/spec-plan/SKILL.md` 全文 7945 cp / frontmatter 239 | 渲染 = 7945−239+343 = **8049**，硬阈值 8192 → **余量 143 cp**（口径见 ⑥A4） |
| #6 parallel.md | `agent/skills/spec-plan/mode/parallel.md:45` | 模板硬约束块（「不与用户直接交互…写进产物「待决问题」节…不要为等答复而空转、阻塞或轮询」）——**正是注入决策槽的位置** |
| #6 parallel.md（回执） | `agent/skills/spec-plan/mode/parallel.md:53` | 回执核对段：两线上浮待决「按中转协议②并入阶段 1.5…不另开问答通道」——上行早到项必须在此被安置 |
| #7 planning.md | `agent/skills/spec-plan/refs/planning.md:41` | 1.7 模板末行「先加载 skill：<栈识别点名>…」——注入点在它之后、模板围栏之内 |
| #7 planning.md（长度） | `agent/skills/spec-plan/refs/planning.md` 7453 cp | 距内容上限 7849 仅 396 cp → 本文件 Δ 硬上限 300 cp（③3.9） |
| #8 convergence.md | `agent/skills/spec-plan/refs/convergence.md:13` | 复算子代理「**不以任何既有草案为输入**：只给分歧点陈述 + 需求原文」——第三条线的派发口径在此定义 |
| #9 spec-plan failure-modes | `agent/skills/spec-plan/refs/failure-modes.md:10` | 规划线失败行（重派一次→如实报告）——上行失败必须并入此行语义，不得新开处置分支 |
| #10/#11 delta | `openspec/specs/spec-apply/spec.md:27`、`:174`；`openspec/specs/spec-plan/spec.md:102` | 三个被 MODIFIED 的 Requirement 原文（cp 分别 248 / 273 / 331） |
| #10 校验上限 | `/usr/local/lib/node_modules/@fission-ai/openspec/dist/core/validation/constants.js:9` | `MAX_REQUIREMENT_TEXT_LENGTH = 500`；`…/validator.js:272`：**ADDED** 超 500 → WARNING（`--strict` 下判 invalid）；`:745`：主规格全部 Requirement 超 500 → WARNING（归档后回归点） |
| #12 归档终态 | `openspec/specs/spec-apply/spec.md:264`、`openspec/specs/spec-plan/spec.md:242` | 「入口与资源按单次加载完整交付」——本次所有长度预算的规范依据 |
| #13 spec-workflow | `agent/skills/spec-workflow/SKILL.md:65` | 恢复协议第 3 步「`job_list` 判「在途/已丢」」——Q3=a 登记簿化后此句成为第二权威源 |
| 长度口径先例 | `openspec/changes/archive/2026-10-14-spec-workflow-externalize-references/execution-log.md:72` | pruner `thresholdChars 8192 / headChars 4096 / tailChars 1024`，超限替换为中段标记 |
| 包裹口径先例 | `openspec/changes/archive/2026-10-14-spec-workflow-slim-entry/execution-log.md:79` | 包裹（不含内容）**343 cp**；内容上限 7849 |
| 反例先例（易失单源） | `openspec/changes/archive/2026-10-17-spec-workflow-worktree-lifecycle/proposal.md:7` | 「worktree 布局当时只记在易失的 `/tmp/spec-flow/<change>/progress.md`，`/compact` 后全靠对话摘要幸存——恢复协议无从核对」——**双源/易失的既有代价实证** |

## ③ 接口与数据形状（协议文本的形状）

> 本节定义的每段文本都是「逐字可粘贴」的成品形状；落档 delta 与 refs 正文从本节抄，**不再二次创作**。

### 3.1 登记簿条目 schema（`/tmp/spec-flow/<change>/progress.md`，v2）

```markdown
# progress.md · <change> 执行登记簿（v2）
> 单源：派发台账 + 租约 + 废止令。写者仅主会话（lead）；子代理只读。旧格式（条目无 state 字段）= v1，按 active 解释，首次触碰时补本节头。

## 批次 3 · 组 3 权限校验（2026-11-19T11:20+08:00）

- T3.1 | scope=apps/api/src/auth/ | agent=session-1f2a… | state=active | at=2026-11-19T11:21+08:00 | src=dispatch
- T3.2 | scope=apps/api/src/perm/,openspec/specs/auth/spec.md | agent=pending | state=active | at=2026-11-19T11:21+08:00 | src=dispatch
- T2.3 | scope=apps/api/src/auth/login.ts | agent=session-9c4e… | state=void | at=2026-11-19T11:25+08:00 | src=void | reason=用户叫停，写范围并入 T3.1
```

| 字段 | 取值 | 必填 | 语义与约束 |
| --- | --- | --- | --- |
| `T<n.m>` | 行首 token | 是 | = `tasks.md` 任务号（组.任务）；重派加后缀 `@r2` |
| `scope` | 仓内相对路径，逗号分隔，**目录以 `/` 结尾** | 是 | = 该任务的写范围（从 `code-design.md` 触达面条目抄，不新造） |
| `agent` | `session-<uuid>` 或 `pending` | 是 | `pending` = 已登记未拿到 id；派发调用返回后由 lead 回填 |
| `state` | `active\|done\|void\|stalled` | 是 | 状态机见下 |
| `at` | ISO8601 带时区（`+08:00`） | 是 | **最后一次状态变更**时刻（不是派发时刻） |
| `src` | `dispatch\|receipt\|void\|recover` | 是 | 状态来源，供恢复审计 |
| `reason` | 自由文本一句 | `void`/`stalled` 必填 | 废止/停滞依据（用户叫停、重复认领、无落盘…） |

**状态机（唯一合法迁移）**

```
active --回执到达并通过核对--------> done      （终态）
active --用户叫停/lead 放弃--------> void      （终态；reason 必填；即软废止令）
active --写范围零落盘+无上行+无回执--> stalled  （lead 判定；见 3.5 第 3 行）
stalled --重派---------------------> 新行 T<n.m>@r2（原行留存，state 不改写）
```

**写者规则（防丢失更新的关键）**：写者 SHALL 仅为主会话；子代理**只读**。主会话更新一律用 `Edit` 定点改本条目的 `state/at/src`，**禁止用 `Write` 整文件覆盖**（`Write` 是全量替换，会抹掉同批其他条目）。终态行不改写、不删除；登记簿整体随 `/tmp/spec-flow/<change>/` 由 spec-done 清理（`openspec/specs/spec-done/spec.md:100`）。

**写范围重叠的机械判据**：归一化（去空白、去行尾 `/`）后，`a` 与 `b` 重叠 ⟺ `a == b` 或 `b` 以 `a + "/"` 开头 或 `a` 以 `b + "/"` 开头。一读即得：`grep -n 'state=active' /tmp/spec-flow/<change>/progress.md`。

### 3.2 协调协议注入段模板（≤15 行预算，实测 8 行 / 574 cp）

以 `<!-- coord-inject:start -->` / `<!-- coord-inject:end -->` 包裹（**标记供长度断言抽取，注入时连同标记一起粘**）：

```
<!-- coord-inject:start -->
【协调协议·本任务强制】
1. 登记簿（唯一协调源）：/tmp/spec-flow/<change>/progress.md。开工第一动作读全表，记下他人 state=active 的 scope。
2. 让路：他人 scope 与你的写范围前缀相交 → 交集路径一律不写；整任务无法避让 → 按第 4 条上行为「决」。
3. 检查点（读你自己条目，共三处）：①动任何文件前 ②每次写文件前 ③跑验证句前。条目 state=void|stalled 或 agent 非你 → 停手：不再改动、不 git 操作，回执首行写 VOIDED。
4. 上行发送：send_message(agent_id="<你的父 agent id，见 runtime context>")；"lead" 名不可寻址；发送失败即降级（不重试、不阻塞），改写进回执。
5. 上行格式（单发不候复，只陈述结论与需要，不提问）：[上行][<change>][T<n.m>][决|异|成] 结论一句 / 需要：代问|裁决|无需 / 依据：<file:line> / 阻塞：是|否
6. 必报三类：决=需用户拍板；异=无法继续（验证失败/缺依赖/工具故障）；成=末次改动完成、跑验证句之前。
7. 兄弟子代理与你互不可达（平台事实）：一切冲突经主会话裁决，禁止互相等待或自行协商。
<!-- coord-inject:end -->
```

为什么是 7 条**配方**而不是禁令：失败类型是「子代理不知道该做」的 omission，不是「知道但违规」；`writing-skills` 的措辞实测表明 shaping 型失败用正向配方（必填槽）有效，禁令臂反而更差（④D12）。

### 3.3 上行消息格式

**单行**，头部三元组定坐标（`[上行][<change>][T<n.m>][类型]`）+ 四段固定字段（结论 / 需要 / 依据 / 阻塞）；方向固定为「子代理 → 主会话」，**单发不候复**（lead 无下行，无法回执；子代理不得等待答复）。

```
[上行][<change>][T<n.m>][决|异|成] <一句话结论> / 需要：<代问|裁决|无需> / 依据：<file:line 或阻塞点> / 阻塞：<是|否>
```

| 类型 | 触发（唯一） | lead 侧动作 | 是否阻塞子代理 |
| --- | --- | --- | --- |
| `决` | 需用户拍板（选项互斥、影响走向） | 当批次即时代问（≤5 问/轮附推荐）→ `subagent` 接续重派携带答复 | 否（发完继续可推进部分，或收尾回执上浮） |
| `异` | 无法继续（验证失败/缺依赖/工具故障/材料读不到） | 按 failure-modes 处置（重试一次纪律不变）＋可能改派 | 是（等接续重派，但不空转、不轮询） |
| `成` | **末次改动完成、跑验证句之前** | 预读 diff，进入核对准备 | 否（自跑验证句，照常回执） |

三条示例（进 `coordination.md` §5，也是组 6 GREEN 场景的输入）：

```
[上行][add-subagent-control-and-coordination][T3.1][决] 登记簿写者归属需拍板 / 需要：代问 / 依据：refs/coordination.md §2 / 阻塞：否
[上行][add-subagent-control-and-coordination][T3.2][异] 验证句缺 openspec CLI / 需要：裁决 / 依据：bash: openspec: command not found / 阻塞：是
[上行][add-subagent-control-and-coordination][T3.3][成] 已改 3 文件，开始验证 / 需要：无需 / 依据：agent/skills/spec-apply/refs/execution.md:8 / 阻塞：否
```

失败降级：`send_message` 报错或父 id 不可得 → **不重试、不阻塞**，事件改写进产物与回执（`failure-modes.md` 新增行）。

### 3.4 软废止令格式（不另立文件）

令 = 登记簿该条目 `state=void` + `reason`。**没有第二份令文件**（③3.1 已定单源）。

| 阶段 | 子代理行为 | 主会话行为 |
| --- | --- | --- |
| 令写入时 | — | 用 `Edit` 把条目改 `state=void`，`at` 刷新，`reason` 写明依据 |
| 下一个检查点 | 命中 → 停手：不再改动、不 `git` 操作；`git status --porcelain` 只读核对已改文件；回执首行 `VOIDED` 并列已改文件 | — |
| 若两次检查点之间已跑完 | 回执照常发出，**不含** `VOIDED`（令到达太晚） | 已落盘产出按「新产出」走核对/审核；**由用户裁决去留，lead 不擅自 revert** |
| 硬控制诉求（不等检查点） | — | 派发前判据提示切 `--engine team`（3.6）；已派发中无硬中断（平台事实） |

### 3.5 冲突处置矩阵

| # | 冲突 | 机械判据 | 处置（谁做） |
| --- | --- | --- | --- |
| 1 | 同一任务被双登记 | 同 `T<n.m>` 两行均 `active` | lead 保留 `at` 较早行，后行置 `void`（`reason=duplicate claim`）；若后行已派发，其检查点自停手 |
| 2 | 写范围重叠 | 3.1 前缀判据命中 | **后登记方让路**：交集路径不写；整任务不可避让 → 子代理上行 `决` → lead 裁决（串行化 / 收窄范围 / 取消） |
| 3 | 停滞 | 写范围零落盘 + 无上行 + 无回执 | lead 置 `stalled` → 先对现存 diff 跑验证句：过则补勾 `done`；未过则重派（新行 `@r2`）。**不做定时轮询**（④D5） |
| 4 | 跨批残留 | 恢复后仍有 `active` 行 | 按第 2/3 行处理；**不新建重复任务行**，禁止盲目重派造成双写 |
| 5 | 子代理互商诉求 | 子代理请求「等我兄弟的结果」 | 平台事实 sibling 不可达 → 一律上行 lead；提示语固定「冲突经主会话裁决」 |

### 3.6 引擎升级判据（Q2=b：只提示，不自动切）

| 判据 | 触发时点 | 动作 |
| --- | --- | --- |
| 同任务审核被拒 ≥2 次 | 派发前 / 组收尾 | 提示「本组建议 `--engine team`（可 `interrupt_agent`）」 |
| 需在检查点之间即时叫停 | 派发前 | 同上（软废止不等检查点，硬停只能 team） |
| 任务间需多轮互商（写面不可切分且互依细节） | 派发前 | 同上（team 成员可互相 `send_message`） |
| 预计 lead↔实现者 >2 轮澄清 | 派发前 | 同上 |

落点：`agent/skills/spec-apply/SKILL.md:37` 后的「协调纪律」行（**只在 §三 写一份**，§二③ 不重复——防双源，④D11）。

### 3.7 spec-plan 侧精简段模板（仅待决+异常两类；实测 5 行 / 358 cp）

```
【上行·本任务（仅两类事件，不改提问节奏）】
- 发送：send_message(agent_id="<你的父 agent id，见 runtime context>")；"lead" 名不可寻址；失败即降级为回执上浮（不重试、不阻塞）。
- 决：[上行][<change>][<A线|B线|复算|设计>][决] 问题=<一句> / 选项=<a|b> / 推荐=<a> / 影响面=<…> —— 随后仍写产物「待决问题」节并在回执列 TOP，节奏不变（规划线并入 1.5、设计线并入落档分歧点）。
- 异：[上行][<change>][<同上>][异] 阻塞点=<…> / 依据=<…> / 阻塞：是 —— 不重试、不空转，照常收尾回执。
- 无租约、无检查点、无完成前奏（规划期无共享写面：独立性铁律已防写冲突）。
```

权威源 = `spec-apply/refs/coordination.md` §7（spec-plan 只指路不复制，循 `spec-workflow/refs/worktree.md` 跨引用先例）；A/B 两线注入文本**除「A线|B线」占位外逐字等形**（保全 `parallel.md:27` 的等形要求）。

### 3.8 spec delta 逐条文案（cp 为 Python `len()` 实测）

**#10 spec-apply delta（结构：`## MODIFIED Requirements` ×1 段含 2 条 + `## ADDED Requirements` ×1 段含 1 条）**

- **MODIFIED「subagent 执行引擎」**（311 cp ≤500，基线 248）：

  > 默认引擎 SHALL 为 subagent:每任务由独立全新子代理完成,提示 SHALL 自包含(任务描述、验收标准、design 该组实现要点逐字引用、其触达文件写范围、栈对应 writer skill 加载指令——沿用阶段 1.7 栈识别结论点名 skill 名,豁免时注明依据),并 SHALL 注入协调协议段(≤15 行,见「subagent 运行协调」);派发前 SHALL 在登记簿登记写范围与租约;同组可并行、组间串行;主会话 SHALL 以验证说明与变更差异核对通过后才标记完成。执行子代理遇需拍板决策 SHALL 按「子代理与用户的交互中转」上浮并接续重派,SHALL NOT 因等待答复阻塞或自行假设。

  场景 5 个：既有 4 个原样保留 + 新增「派发注入协调段」。
- **MODIFIED「子代理与用户的交互中转(执行期)」**（328 cp ≤500，基线 273）：

  > 被父代理拥有的子代理 SHALL NOT 直接向用户提问(提问会被以 `DELEGATED_CALLER` 拒绝),执行半程 SHALL 提供中转式交互:执行任务的子代理 SHALL 把需拍板的决策(问题、选项、推荐、影响面)写入产物并在回执中上浮,SHALL NOT 自行假设;上浮通道 SHALL 含回执与上行消息两条(subagent 面 `send_message` 直报主会话);主会话 SHALL 当批次即时代问(≤5 问/轮、附推荐),SHALL NOT 为等答复阻塞或轮询;回送 SHALL 按引擎:team 回送同一成员(可多轮),subagent 以上轮回执摘要+答复接续重派;用户授权「按假设清单推进」时 SHALL 跳过代问并标注。

  场景 5 个：既有 4 个 + 新增「上行直报不改变代问节奏」。
- **ADDED「subagent 运行协调（登记簿·检查点·上行）」**（429 cp ≤500）：

  > subagent 引擎 SHALL 以单一登记簿 `/tmp/spec-flow/<change>/progress.md` 同时承担派发台账、租约与废止令:写者 SHALL 仅为主会话,子代理 SHALL 只读;条目 SHALL 含任务号、写范围、子代理会话 id、状态与时刻;状态机 SHALL 为 active→done|void|stalled。派发前 SHALL 先登记全批条目再并发派发。子代理 SHALL 在开工、写文件前、验证前三处检查点读自己条目;遇 void|stalled 或写范围与他人 active 条目相交 SHALL 停手并上行。上行 SHALL 走 subagent 面 `send_message`(父会话 id 取自 runtime context,单发不候复),事件限待决、异常、完成前奏三类。下行与硬中断平台不可用,通知与废止 SHALL 仅在检查点生效;需即时叫停 SHALL 在派发前按判据建议切 team 引擎。

  场景 6 个：写范围重叠让路｜检查点废止生效（VOIDED）｜完成前奏上报｜停滞判定与重派（不轮询）｜引擎升级判据仅在派发前提示｜登记簿单写者与子代理只读。

**#11 spec-plan delta（结构：`## MODIFIED Requirements` ×1 段含 1 条）**

- **MODIFIED「子代理与用户的交互中转（规划期）」**（422 cp ≤500，基线 331）：

  > 被父代理拥有的子代理 SHALL NOT 直接向用户提问(提问会被 `DELEGATED_CALLER` 拒绝),规划期 SHALL 中转式交互:子代理 SHALL 把需拍板的决策(问题、选项、推荐、影响面)写入产物并在回执中上浮,SHALL NOT 自行假设;规划线 SHALL 另有上行通道——subagent 面 `send_message` 直报主会话,事件限待决与异常两类,不设租约与完成前奏,且 SHALL NOT 改变既有提问节奏;规划线上浮项 SHALL 并入阶段 1.5 统一提问,阶段 1.7 设计线上浮项 SHALL 并入落档分歧点提问,不新开通道、不积压;回送 SHALL 按引擎:team 回送同一成员(可多轮),subagent 接续重派;用户授权「按假设清单推进」时 SHALL 跳过代问并标注。本 Requirement 适用于并行编排的规划线、复算线与阶段 1.7 设计线;串行单线由主会话直问用户,不经中转。

  场景 5 个：既有 4 个 + 新增「上行早到不改变提问节奏」。

### 3.9 长度预算表（cp = Python `len()`；入口渲染 = file − frontmatter + 343；内容上限 7849）

| 文件 | 现值 | Δ | 改后 | 上限 | 余量 | 说明 |
| --- | --- | --- | --- | --- | --- | --- |
| `spec-apply/SKILL.md` | 3271（fm 225，渲染 3389） | +423 | 3694（渲染 **3812**） | 8192 | 4380 | 富余，无裁剪风险 |
| `spec-apply/refs/execution.md` | 4955 | ≈+445 | ≈5400 | 7849 | ≈2449 | — |
| `spec-apply/refs/failure-modes.md` | 1594 | +590 | 2184 | 7849 | 5665 | — |
| `spec-apply/refs/coordination.md` | **新建** | ~4600 | ~4600 | 7849 | ~3249 | 设计目标 ≤5000 |
| `spec-plan/SKILL.md` | 7945（fm 239，渲染 **8049**） | **+97** | 8042（渲染 **8146**） | 8192 | **46** | **全仓最紧**；硬上限 100 cp（④D8 反例） |
| `spec-plan/mode/parallel.md` | 2749 | +249 | 2998 | 7849 | 4851 | — |
| `spec-plan/refs/planning.md` | 7453 | +162 | 7615 | 7849 | **234** | Δ 硬上限 300 cp |
| `spec-plan/refs/convergence.md` | 2560 | +38 | 2598 | 7849 | 5251 | — |
| `spec-plan/refs/failure-modes.md` | 3040 | +82 | 3122 | 7849 | 4727 | — |
| `spec-workflow/SKILL.md`（#13，待决 P1） | 6557（fm 218，渲染 6682） | ≈+60 | ≈6617 | 8192 | ≈1575 | — |

## ④ 决策记录

**D0｜栈识别结论：writer skill = `writing-skills`（硬约束源）**
证据：①用户指认；②本仓 spring 判据（`pom.xml`/`build.gradle(.kts)` 含 `spring-boot`）与 nuxt 判据（`nuxt.config.{ts,js,mjs}` / `package.json` 依赖）**双双零命中**（实测 `ls`：均 No such file；根无 `package.json`；maxdepth 2 无 `.ts/.java/.vue` 应用代码）；③触达面 13 条中 9 条是 skill markdown 文本、2 条是 OpenSpec 工件、1 条是恢复协议文本、1 条是终态合并，**零应用代码**。
**被否**：`spring-writer` / `nuxt-writer`（会要求分层方向、复用优先、测试金字塔与任务拆分粒度——对纯协议文本无对象，且会把 `code-design.md` 的 ③ 拉向「函数签名/类型」而非本需求的「协议文本形状」）；「不加载 writer skill」（违反 `planning.md:23` 的必须级要求）。

**D1｜协议权威源 = 新建 `spec-apply/refs/coordination.md`，spec-plan 只指路**
被否 A：全部写进 `execution.md`（现 60 行 / 4955 cp，加入后逼近 8000+，且 `execution.md` 是「两引擎共用」文件，把 subagent-only 协议塞进去会让 team 读者误以为适用）。被否 B：spec-plan 自建一份 `refs/coordination.md`（同一协议两份文本 = 双源漂移；且违反 Q3=a 的单源精神）。
反例：`openspec/changes/archive/2026-10-17-spec-workflow-worktree-lifecycle/proposal.md:7` 记录过「布局只记易失 progress.md → `/compact` 后无从核对」的代价——单源必须配「锚点固定 + 跨引用不复制」，`worktree.md`（`spec-apply/SKILL.md:22` 以「唯一权威源，跨引用不复制」引用）是既有成功先例。

**D2｜登记簿单写者 = 主会话，子代理只读**
被否：子代理开工即写自己的 `active` 行（看似更"真"，但 markdown 无锁）。反例 1：同批 3 任务同时 `Edit` 相邻行区间，后写者覆盖前者 → 冲突面丢失，两个子代理互相看不见。反例 2：任一子代理用 `Write` 整文件覆盖（模型常见路径），同批其他条目**全部消失**，比不写更糟。单写者 + 派发前批量登记，把「并发写」变成「单点顺序写」，且子代理一次读取就能看到全批租约。

**D3｜同批先登记全批条目，再一条消息并发派发**
被否：边派边登记（更省一次写文件的 token）。反例：`subagent` 同一条消息并发派发，两个子代理 t≈0 同时开工；若先派者读登记簿时后派条目还没写，**冲突窗口在 t=0 就已存在**——正好是本需求要消灭的场景。

**D4｜软废止令 = 登记簿 `state=void`，不另立令文件**
被否：`/tmp/spec-flow/<change>/void-<task>.md` 独立令文件（语义更"像令"）。理由：①双源（Q3=a 已定单源）；②注入段要再多传一个路径（≤15 行预算里再挤一行）；③检查点变成两次读（登记簿 + 令文件），失败面翻倍。
反例：若令文件与登记簿不同步（用户叫停后 lead 只写了令文件、忘了改状态），恢复协议会按 `active` 判定「在途」而无限等一个已被废止的任务。

**D5｜停滞由 lead 判定，不引入心跳/定时轮询**
被否：定时心跳（token 可预期）。理由：①红线「不得为等答复阻塞或轮询」（`spec-apply/SKILL.md:43`、`spec-plan/mode/parallel.md:45`）；②平台无在途信号可查——`job_list` 不含 subagent（`explore.md:45`）。反例：探针 2 运行中 `job_list` 为空；若协议按 `job_list` 判在途，会在子代理真实运行时误判「已丢」并重派 → **双写**（`failure-modes.md:18` 的旧文正是这个陷阱）。

**D6｜上行三类事件、单发不候复、禁止在协议里设计多轮澄清**
被否：全量心跳（Q4 已否 c）；多轮问答（看似自然）。反例：lead 无下行通路，**已结束回合的子代理无法被唤醒**（`explore.md:60` R2 推论）——若协议写「等 lead 答复再继续」，子代理要么空转（违反禁令）要么永久卡住。故协议只允许「发完继续 / 停手等接续重派」二态，无第三态。

**D7｜协调段内联进提示（≤15 行），不让子代理自己去读 refs**
被否：提示里写「先读 `refs/coordination.md`」。反例：子代理没有 skill 根路径上下文（它是 fresh + 独立工作目录），路径写错就读不到 → **协调协议静默失效**，且失败无信号（子代理不会报"我读不到协议"）；另违反 `execution.md:5` 的「提示自包含（缺一不可）」封闭枚举纪律。

**D8｜spec-plan 入口只加 97 cp 一句，细则走 spec-apply §7**
被否：写完整句（178 cp 版）。反例（实测）：`178 cp` → 渲染 `8227 > 8192`，**超出 35 cp 直接触发宿主中段裁剪**，会把 §四 中转协议整段剪掉——比不加更危险。故入口硬上限 100 cp；余量落至 46 cp，并设降级预案（⑥U1）。
被否：完全不改 spec-plan 入口（Q1=a 已定两侧一并改；且 lead 侧若不知道会收到上行，会把早到消息当"异常噪音"重复代问）。被否：spec-plan 自建 refs（同 D1）。

**D9｜failure-modes 两行「拆方向重写」，不是「原文加注」**
被否：保留原句 + 追加一行更正（省事）。反例：`:17` 原句「不可消息寻址」会让子代理/主会话都判定上行不可用——**可用能力被旧文误判为不可用**，协调协议第 4 条直接失效，且无人会去核对。事实类文本必须就地改正，不留矛盾句。

**D10｜delta 形态：spec-apply（2 MODIFIED + 1 ADDED）/ spec-plan（1 MODIFIED）**
被否：把登记簿全塞进既有「subagent 执行引擎」Requirement。理由：①该 Requirement 现 248 cp，塞入 429 cp 内容必然 >500，而 `validator.js:745` 对**主规格**所有 Requirement 施加 500 上限 → 归档后 `openspec validate spec-apply --strict` 会从绿转红（当前基线 exit 0，是硬回归）；②场景会膨胀到 10+，失去可测性。反例：ADDED 正文 429 cp 已贴近 500，任何"顺手补充"都会触界。

**D11｜引擎升级判据只提示、不自动切；且只在 §三 写一份**
被否：判据命中即自动切 team。反例：自动切会让同一变更内引擎语义漂移，且 team 成员上限 8（`execution.md:15`）、创建重；用户对批次成本变化不知情。被否：§二③ 与 §三 各写一份判据（读者就近）。理由：两份文本必然漂移，且 §二③ 是「已预置不重问」的问句位，语义不同。

**D12｜注入段用「正向配方 + 必填槽」而非禁令清单**
被否：「不要盲写」「不要互相等待」式禁令（更像规则）。理由：`writing-skills` 的失败分类表明，omission/形状型失败用禁令效果更差（其措辞实测中禁令臂比无指导对照组更差），且禁令可协商（"这次不算盲写"）。配方给的是「第 1 步做什么、第 5 行的字段是什么」，无可协商面。

**D13｜team 引擎不注入协调段，登记簿仅记 team 批次条目与终态**
被否：team 也全量接入（统一体验）。理由：team 已有控制与互通（`send_message`/`interrupt_agent`/`wait_agent`，`execution.md:18-20`），登记簿对它是冗余；接入会把「组内 ≤15 行注入」变成两套模板，成本 > 收益。留痕：登记簿可记 team 条目以便恢复核对（1 行说明，不注入）。

## ⑤ 逐任务组实现要点（与 `tasks.md` 的 6 个组一一对齐）

> 组间严格串行、组内可并行且**写不同文件**；单组 ≤ `parallelism`（`dsh/spec-workflow.yaml:47` = 8）。每任务的验证句第三方可跑。触达编号对应 ①。**落档期 `tasks.md` 必须按本节 6 组 14 任务生成**（`## N. 组名` 编号即执行审核批次，每任务一行 `- [ ] N.M …；验证：<验证句>`，并引用触达编号）——本节的验证句可直接搬进 `tasks.md`。

**组 1｜RED 基线（写作前，1 任务）**

- 1.1（触达 #1 前置）派 1 个 fresh 子代理，喂三样：`git show HEAD:agent/skills/spec-apply/refs/execution.md` 的 `:8` 台账段原文（旧文本）＋ 场景「你与另一个子代理同批执行、写范围都含 `agent/skills/spec-apply/SKILL.md`，你的提示里没有任何协调指令」＋ 只回答「开工第一件事做什么 / 发现写范围重叠怎么办 / 会不会通知主会话」三问（不执行、不写文件）。逐字记入 `/tmp/spec-flow/add-subagent-control-and-coordination/red-baseline.md`，含「是否提及读 progress.md」「是否让路」「是否提及上行」三栏与一行 `RED 结果：复现|未复现`；未复现如实标注不伪造。
  - 验证：`test -s /tmp/spec-flow/add-subagent-control-and-coordination/red-baseline.md` 退出码 0，且 `grep -qE '^RED 结果：(复现|未复现)$' …` 命中，且上面三栏关键字（`progress.md` / `让路` / `上行`）各至少出现一次作为栏目标题，且 `test -z "$(git status --porcelain -- agent/skills openspec/specs)"` 退出码 0（本组零落盘）。
  - **终形态（执行期实测 2026-11-19）**：**RED 复现**——探针三问（fresh 子代理 `opencode-go/deepseek-v4.1-flash`）证实旧协议下子代理三栏全否：不读 progress.md（视为「派发方登记动作，不是给我的执行指令」）、不让路（「没有任何协调指令，所以我按自己的任务继续写自己那份」）、不主动上行（仅真冲突时最终回执被动说明）。记录在 `/tmp/spec-flow/<change>/red-baseline.md`（易失），结论留痕于此。执行裁定：提示中 writer skill 加载指令与探针纯净纪律冲突 → 探针纪律优先跳过加载（tasks.md 附录 R1）。

**组 2｜协议权威源（1 任务，新建 #1）**

- 2.1 按 ③3.1–3.7 逐字创建 `agent/skills/spec-apply/refs/coordination.md`（10 节；注入段连 `coord-inject` 标记一起；§7 = spec-plan 精简段；§9 = 升级判据）。不写项目文件、不改任何既有文件。
  - 验证：`test -f agent/skills/spec-apply/refs/coordination.md` 且 `python3 -c "s=open('agent/skills/spec-apply/refs/coordination.md',encoding='utf-8').read();assert 3800<=len(s)<=5000,len(s)"` 退出码 0；注入段行数 `awk '/<!-- coord-inject:start -->/,/<!-- coord-inject:end -->/' agent/skills/spec-apply/refs/coordination.md | sed '1d;$d' | wc -l` 落在 **7–15**；`grep -c 'active→done|void|stalled' …` = 1；`grep -c '写者 SHALL 仅为主会话' …` ≥1；节标题 `grep -c '^## §' …` = **10**；`grep -c 'spec-plan' …` ≥1（§7 存在）。
  - **终形态（执行期实测 2026-11-19）**：134 行 / len=4996 cp，全部验证句过（注入段 8 行、`^## §`=10、常量计数全中）。③3.1–3.7 原文约 5733 cp 超长度门 → 按 **R2 裁定**（验证句优先）压缩表格冗长解释，关键逐字串与协议语义全保留（注入段连标记、三示例、§7 代码块与 3.2/3.3/3.7 脚本比对逐字一致）。§2 省略示例登记簿代码块、schema 表去「必填」列；§7 删 `parallel.md:27` file:line。详见 tasks.md 附录 R2。

**组 3｜spec-apply 接线（3 任务，写 #2/#3/#4 三个不同文件）**

- 3.1（#2）`execution.md`：`:8` 台账段重写为 v2 登记簿（③3.1 字段与状态机，+92 cp）＋其后插「协调注入（仅 subagent 引擎）」行（+209 cp）＋ team 段后插「team 不注入协调段」行（+104 cp）。`:5` 提示自包含清单**不改**（协调段由 `:8` 周边新增行引入，避免改封闭枚举的语义）；`:9` 回执格式加一句「检查点命中废止/停滞时回执首行 `VOIDED`/`STALLED`」。
  - 验证：`python3 -c "s=open('agent/skills/spec-apply/refs/execution.md',encoding='utf-8').read();assert 5250<=len(s)<=5500,len(s)"` 退出码 0；`grep -c 'coordination.md' …` = 1；`grep -c 'state=active' …` ≥1；`grep -c 'active→done|void|stalled' …` = 1；`grep -c 'VOIDED' …` = 1；`grep -c 'team 引擎不注入协调段' …` = 1。
- 3.2（#3）`SKILL.md` 三处：`:39` 路由行追加 87 cp；`:37` 后插协调纪律行 223 cp；`:43` §四 追加 113 cp。**`:55` 红线区零改动**、frontmatter 零改动。
  - 验证：`python3 -c "import re;s=open('agent/skills/spec-apply/SKILL.md',encoding='utf-8').read();fm=re.match(r'^---\n.*?\n---\n\n',s,re.S).group(0);r=len(s)-len(fm)+343;print(len(s),r);assert r<=8192 and 3600<=len(s)<=3800"` 退出码 0；`grep -c 'refs/coordination.md' …` = 1；`grep -c '协调纪律' …` = 1；`grep -c '上行通道' …` = 1；`test -z "$(git diff -- agent/skills/spec-apply/SKILL.md | grep '^[-+]description:\|^[-+]name:')"`；`grep -c '^## ' …` = 7（一…七，未新增节）。
- 3.3（#4）`failure-modes.md`：`:17` 拆方向重写、`:18` 作废 `job_list` 判据、新增 2 行（③3.4/3.3 的失败面）。
  - 验证：`test -z "$(grep '子代理不是 teammate、不可消息寻址' agent/skills/spec-apply/refs/failure-modes.md)"`（矛盾句消失）；`test -z "$(grep 'job_list' agent/skills/spec-apply/refs/failure-modes.md | grep -v '不得作为在途判据')"`；`grep -c '上行' …` ≥2；`grep -c 'VOIDED' …` = 1；`python3 -c "s=open(...).read();assert 2100<=len(s)<=2350,len(s)"` 退出码 0；表格行数 `grep -c '^|' …` 由 17 → 19。
  - **终形态（执行期实测 2026-11-19，三任务并行、写不同文件零冲突）**：3.1 len=5458（基线 4955，Δ+503；硬区间 5250–5500，余量 42）——v2 登记簿四处接线全过，`:5` 封闭枚举零改动；3.2 len=3707 / 渲染 3825≤8192（Δ+436 vs 预算 423，两道硬门均过；`:37`/`:43` 用裸 `coordination.md §N`、完整路径 `refs/coordination.md` 仅 :39 路由行一处——grep 常量 =1 所致，裁定接受）；3.3 len=2200（Δ+606 vs 预算 +590，区间内；拆方向两行 + 新增 2 行，表格恰 17→19）。三文件 grep 常量全中，与 coordination.md 语义一致。

**组 4｜spec-plan 接线（5 任务，写 #5–#9 五个不同文件）**

- 4.1（#5）`spec-plan/SKILL.md`：仅 `:80` 后插 97 cp 一行（③3.7 的指路）。
  - 验证：`python3 -c "import re;s=open('agent/skills/spec-plan/SKILL.md',encoding='utf-8').read();fm=re.match(r'^---\n.*?\n---\n\n',s,re.S).group(0);r=len(s)-len(fm)+343;print(len(s),r);assert r<=8192 and 8192-r>=40"` 退出码 0（**余量 ≥40 cp 是硬门**）；`grep -c '上行通道' …` = 1；`grep -c 'send_message' …` = **3**（基线 2 → +1）；`git diff --numstat -- agent/skills/spec-plan/SKILL.md` 新增行 = 2（1 空行 + 1 内容行），删除行 = 0。
- 4.2（#6）`mode/parallel.md`：`:45` 硬约束块末补 2 行（A/B 等形，仅占位不同）；`:53` 回执核对加 34 cp。
  - 验证：`python3 -c "s=open('agent/skills/spec-plan/mode/parallel.md',encoding='utf-8').read();assert 2900<=len(s)<=3100,len(s)"` 退出码 0；`grep -c '上行（可选，仅两类事件）' …` = 1；`grep -c '提问节奏不变' …` = 1；`grep -c 'A线|B线' …` = 1；`grep -c '不在此等待答复' …` = 1。
- 4.3（#7）`refs/planning.md`：`:41` 后插 1 行（设计线精简段）。
  - 验证：`python3 -c "s=open('agent/skills/spec-plan/refs/planning.md',encoding='utf-8').read();assert 7550<=len(s)<=7849,len(s)"` 退出码 0（**余量 ≤300 cp 硬门**）；`grep -c '设计\]\[决|异\]' …` = 1；`grep -c '六字段' …` = **4（基线不变）**，`grep -c '深度契约' …` = **2（基线不变）**（注入只加行、不动深度契约段）。
- 4.4（#8）`refs/convergence.md`：`:13` 复算 bullet 追加 38 cp。
  - 验证：`grep -c '无租约、无检查点' agent/skills/spec-plan/refs/convergence.md` = 1；`python3 -c "s=...;assert 2560<=len(s)<=2650,len(s)"` 退出码 0。
- 4.5（#9）`refs/failure-modes.md`：表末新增 1 行。
  - 验证：`grep -c '降级为回执上浮' agent/skills/spec-plan/refs/failure-modes.md` = 1；`python3 -c "s=open('agent/skills/spec-plan/refs/failure-modes.md',encoding='utf-8').read();assert 3080<=len(s)<=3160,len(s)"` 退出码 0；表格行数 `grep -c '^|' …` 由 **16 → 17**。
  - **终形态（执行期实测 2026-11-19，六任务并行、写不同文件零冲突；tasks.md 组 4 实为 6 任务，本节 ⑤ 未单列 4.6）**：4.1 render=8151/余量 41（硬门 ≥40 过；新句 100 cp 在入口硬上限 100 cp 内——**基线漂移实测事实：spec-plan 入口渲染基线 8049/余量 143，非落档期 8146/46 口径，系 dd8f00b 之后已归档的 skill 瘦身变更使入口变短，97→100 cp 方案照常适用**）；4.2 len=3085、四钉串各恰 1 行（B 线用指回式等形，避免完整串重复致 grep 行数>1）；4.3 len=7645（Δ=192≤300 硬门，钉串在格式示例中自然出现）；4.4 len=2634（单行原地改写 Δ+74；任务原文「上行同学」系笔误按「上行按 §四」落笔）；4.5 len=3145、表格恰 16→17；4.6 render=6806（「subagent 登记簿核对」术语归一，保留段逐字，`job_list` 仅存于「不得作为在途判据」语境）。引用写法两种并存（裸 `coordination.md §7` 有 spec-workflow/refs/failure-modes.md:9 先例；显式「spec-apply 的 refs/coordination.md §7」用于跨 skill refs 语境），裁定均接受。**范围外发现（不扩 scope，终检披露）**：`spec-done/SKILL.md:49` 仍写「progress 派发台账」旧术语，不在触达面 13 条内。

**组 5｜spec delta 核对（2 任务，只读 #10/#11——delta 由落档生成，本组不写工件）**

- 5.1 核对 `openspec/changes/add-subagent-control-and-coordination/specs/spec-apply/spec.md` 与 ③3.8 逐字一致：`## MODIFIED Requirements` ×1（2 条）、`## ADDED Requirements` ×1（1 条）、场景 16 个、ADDED 正文 ≤500 cp。
  - 验证：`grep -c '^## MODIFIED Requirements' …` = 1；`grep -c '^## ADDED Requirements' …` = 1；`grep -c '^### Requirement:' …` = 3；`grep -c '^#### Scenario:' …` = 16；`python3 -c "import re;s=open('…/specs/spec-apply/spec.md',encoding='utf-8').read();m=re.search(r'### Requirement: subagent 运行协调.*?\n(.*?)#### Scenario:',s,re.S);assert len(m.group(1).strip())<=500"` 退出码 0（**ADDED 500 上限，`validator.js:272`**）；`test -z "$(grep -n 'ask_question' …)"`。
- 5.2 同法核 `specs/spec-plan/spec.md`：`## MODIFIED Requirements` ×1、1 条 Requirement、5 个 Scenario、正文 422±20 cp。
  - 验证：`grep -c '^## ADDED Requirements' …` = 0；`grep -c '^### Requirement:' …` = 1；`grep -c '^#### Scenario:' …` = 5；`python3 -c "…assert 400<=len(m.group(1).strip())<=500"` 退出码 0。
- 组级门：`openspec validate add-subagent-control-and-coordination --strict` 退出码 0（**不得用 `--all --strict`**——`openspec validate spec-plan --strict` 当前基线已 exit 1，见 ⑥A5）。
  - **终形态（执行期实测 2026-11-19）**：5.3 exit=0（输出仅「is valid」，无 warning）；5.1 全断言过（ADDED 正文 429 cp ≤500、16 场景、无 ask_question）、5.2 全断言过（正文 423 cp ∈ [400,500]、5 场景）。③3.8 内容级逐字符比对：3/4 正文逐字节一致；plan MODIFIED 423 vs 3.8 声明 422 差 1 cp（delta 多一「以」——**忠实继承主规格基线用字，3.8 系引用漏字，裁定保留 delta**）；ADDED 标题与 2 个场景名括号半角 vs 3.8 全角（各条目跟随各自基线/兄弟标题风格，裁定不改）；plan 正文 15 处标点半角化系 3.8 引用即半角（外观级，语义零差，归档后主规格以 delta 为准，披露不阻断）。5.2 验证句「grep -c '^## ADDED Requirements' =0」实测数值 0 成立但 grep exit=1（无匹配语义），记录时以数值为准。

**组 6｜GREEN 配对复测与无裁剪终检（2 任务）**

- 6.1 派 1 个 fresh 子代理，喂与组 1 同场景、但提示换成 ③3.2 注入段全文（+3 条上行示例），记录 `/tmp/spec-flow/add-subagent-control-and-coordination/green-check.md`，含三栏（是否读登记簿/是否让路/是否按格式上行）与一行 `GREEN 结果：通过|摇摆`，并与 RED 写一行对比结论。
  - 验证：`grep -q 'send_message(agent_id' green-check.md` 且 `grep -q 'VOIDED' green-check.md` 且 `grep -qE '^GREEN 结果：(通过|摇摆)$' green-check.md` 均命中；`grep -q 'RED' green-check.md`（对比结论在）。
- 6.2 无裁剪终检：主会话按名加载 `skill spec-plan` 与 `skill spec-apply`，断言返回正文含新增句、且**不含** `[... tool result middle pruned ...]`。
  - 验证：加载回执含 `上行通道`（spec-plan）与 `协调纪律`（spec-apply）；`grep -c '^## ' agent/skills/spec-plan/SKILL.md` = 10（未新增节）；重跑 4.1 的渲染公式（渲染 ≤8192、余量 ≥40）。
  - **终形态（执行期实测 2026-11-19）**：**RED→GREEN 配对成立**——GREEN 探针三栏全「是」（第一动作读登记簿全表并落实三检查点、交集路径让路+不可避让上行「决」、`send_message(agent_id=父id)` 按五段式上行单发不候复+失败降级+VOIDED 复述完整），且**行为级**执行了注入段第 1 条（真实读 progress.md 确认自己条目在途）；4 条 grep 验证全过、零代码落盘。6.2：两 skill 按名加载回执均含新增句、全文完整渲染无中段裁剪标记，spec-plan `^##`=10、spec-apply `^##`=7、渲染 8151/余量 41。组 1/组 6 配对（R1 裁定省略 writer skill 加载）完成 writing-skills Iron Law 证据链。

## ⑥ 设计假设与未决项

| # | 假设 | 依据 / 若假设不成立的降级 |
| --- | --- | --- |
| A1 | 执行子代理能在自己的 runtime context 里读到**父 agent id**（形如 `session-<uuid>`） | **本设计会话自证**：本子代理的 runtime context 明写「Your parent agent id is "session-e1a198fb-…"」；`explore.md:43` 探针 1 亦实测。若某引擎不给 → 注入段第 4 条已带降级（改写进回执），协议不失效 |
| A2 | 子代理面存在 `send_message` 且可按父 id 寻址 | 自证：本子代理工具面含 `send_message`（「…or your direct parent when you are a resident continuable child」）；`explore.md:43` 实测送达 |
| A3 | 子代理可读 `/tmp/spec-flow/<change>/progress.md` | 同容器同文件系统（`explore.md:83` A4）；team/subagent 同 runtime。若隔离到不同容器则组 6 GREEN 会失败 → 届时降级为纯回执上浮（协议其余部分不变） |
| A4 | 长度口径 = `file − frontmatter + 343`，阈值 8192（超限裁为中段标记） | `archive/2026-10-14-…-externalize-references/execution-log.md:72`（三值实测）＋ `archive/2026-10-14-…-slim-entry/execution-log.md:79`（343 包裹）。path 变长会压缩余量（spec-plan 仅剩 46 → 见 U1） |
| A5 | spec-plan 主规格**当前就是红的**（`openspec validate spec-plan --strict` exit 1，`requirements[4]`/`[5]` >500） | 本次实测：`spec-apply` exit 0 / `spec-plan` exit 1。故 spec-plan 侧门禁口径 = 「**不新增** warning（仍恰好 2 条）」，而非 exit 0；spec-apply 侧必须保持 exit 0（MODIFIED 正文均 ≤500 即满足） |
| A6 | 子代理对检查点的遵循度是尽力而为 | `explore.md:72` R1；组 6 GREEN 只是抽样证据，不承诺强保证——协议第 3 条的「回执首行 VOIDED」是唯一可核对信号 |
| U1 | spec-plan 入口余量只剩 46 cp；若宿主 path 比 343 口径更长，可能不足 40 | 降级预案（D8）：把该句压到 58 cp 版「**上行通道**：subagent 可 `send_message` 直报主会话，**仅待决/异常、节奏不变**。」（实测渲染 8107，余量 85），指路句移入 `parallel.md`/`planning.md` 模板（两处均有 ≥4800 cp 余量） |
| U2 | 本次未给 team 引擎加登记簿/上行语义（D13） | 若用户要求「team 也走同一登记簿」→ 另立变更（会动 `execution.md` team 段 6 行 + 1 条 team Requirement） |
| U3 | 注入段 8 行是「最小可用」而非「最优措辞」 | writing-skills 要求 micro-test；本次以组 1/6 的 RED→GREEN 配对为最低证据，若 GREEN 摆动则按 D12 的配方结构加槽（不加禁令） |

## 待决问题

| # | 问题 | 选项 | 推荐 | 影响面 |
| --- | --- | --- | --- | --- |
| P1 | `agent/skills/spec-workflow/SKILL.md:65` 的 `job_list` 判据是否随本变更一并修正？（decisions Q1 定的范围是 spec-apply + spec-plan，此条**越出**该范围） | a 纳入本变更（单行改写，无 spec delta——已核对 `openspec/specs/spec-workflow/spec.md` 不含该文本）／b 另立变更／c 不修，保留与平台事实矛盾的判据 | **a**：Q3=a 把 progress.md 定为单一登记簿后，这行是唯一的第二权威源；不改则恢复协议继续按一个**已证实为空**的集合判在途（探针 2 实测），重派/双写风险落在这里 | 恢复协议正确性、变更触达面 +1 文件（≈+60 cp）、无归档联动 |
| P2 | team 引擎是否同步接入登记簿与上行语义？（本设计 D13 取「不接入」） | a 不接入（team 已有 `send_message`/`interrupt_agent`/`wait_agent`）／b 只登记条目不注入／c 全量接入（与 subagent 同协议） | **a**：能力已具备，注入属重复；c 会把「≤15 行单一模板」裂成两套并新增一条 team Requirement | `execution.md` team 段、team Requirement、协议维护面 |
| P3 | 登记簿结构是否需要**可执行校验**（例如组收尾跑一行 `python3` 断言每条目 7 字段齐全）？ | a 不加，靠纪律 + 本文件 ③3.1 的机械判据 + 组内验证句／b 在 `coordination.md` 附一段可复制断言脚本／c 把断言写进 `tasks.md` 每组验证句 | **a**：一旦有脚本就成为「第二实现」，与 markdown 单源漂移；本设计的验证句已覆盖「模板行数/字段存在」这类静态面，运行期结构正确性由 lead 单写者身份保证 | 机械化程度、维护成本、是否引入第二权威 |

## 附：阶段 1.75 界面演示（判定与确认）

1.75 未触发：C1 不成立——本变更触达面 13 条全部为 agent skill markdown 文本（SKILL.md / refs / mode）、OpenSpec 工件与恢复协议文本，零页面/组件/弹窗/表单/仪表盘/布局/视觉产出，无用户可见界面变化。
