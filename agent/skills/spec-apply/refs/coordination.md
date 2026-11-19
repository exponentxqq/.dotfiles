# coordination.md · 协调协议

> `spec-apply/SKILL.md` §三「协调纪律」外移（唯一权威源）；回入口引用「SKILL.md §三」，消费方只指路。

## §1 平台事实（不得违反）

**基线**：lead→subagent 下行 ✗｜subagent→lead 上行 ✓（subagent 面 `send_message`，父 session id 在 runtime context）｜sibling 互达 ✗｜无硬中断（`interrupt_agent` 仅 teammate、`job_list` 不含 subagent）——来源 `explore.md:42-47`。RED 三栏全否，见 `/tmp/spec-flow/add-subagent-control-and-coordination/red-baseline.md`（2026-11-19）。

## §2 登记簿 schema 与状态机

登记簿 = `/tmp/spec-flow/<change>/progress.md`（v2）；全部必填，`reason` 仅 `void`/`stalled`。

| 字段 | 取值 | 语义与约束 |
|---|---|---|
| `T<n.m>` | 行首 token | 任务号；重派加 `@r2` |
| `scope` | 仓内相对路径，逗号分隔，目录以 `/` 结尾 | 写范围（触达面） |
| `agent` | `session-<uuid>`/`pending` | `pending`=未拿 id；派发后回填 |
| `state` | `active\|done\|void\|stalled` | 状态机见下 |
| `at` | ISO8601 带时区 | **最后状态变更** |
| `src` | `dispatch\|receipt\|void\|recover` | 状态来源 |
| `reason` | 自由文本 | 废止/停滞依据 |

**状态机**

```
active --回执到达并通过核对--------> done（终态）
active --用户叫停/lead 放弃--------> void（终态；reason 必填；即软废止令）
active --写范围零落盘+无上行+无回执--> stalled（lead 判定；见 §8 第 3 行）
stalled --重派---------------------> 新行 T<n.m>@r2（原行留存，state 不改写）
```

**写者规则**：写者 SHALL 仅为主会话；子代理只读。更新用 `Edit` 定点改，**禁止 `Write` 整文件覆盖**；终态行不改写、不删除。

**重叠判据**：归一化（去空白、去行尾 `/`）后，`a` 与 `b` 重叠 ⟺ `a == b` 或 `b` 以 `a + "/"` 开头 或 `a` 以 `b + "/"` 开头。一读即得：`grep -n 'state=active' /tmp/spec-flow/<change>/progress.md`。

## §3 派发前登记序（lead 操作序）

1. **先登记全批再并发**：按 §2 逐任务一行，`agent=pending`；`scope` 从触达面抄，目录以 `/` 结尾。
2. 派发返回后回填 `session-<uuid>`；回执核对通过 → `state=done`（`at`/`src=receipt`）；未到按 §8。
3. 注入段（§4 全文连标记）粘进每个 fresh 子代理提示；team 不注入。

## §4 协调协议注入段模板

连标记一起粘：

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

7 条是**配方**不是禁令：失败是 omission；`writing-skills` 实测配方有效、禁令更差（④D12）。

## §5 上行格式与三示例

**单行**；`[上行][<change>][T<n.m>][决|异|成]` + 结论/需要/依据/阻塞；**单发不候复**。

```
[上行][<change>][T<n.m>][决|异|成] <一句话结论> / 需要：<代问|裁决|无需> / 依据：<file:line 或阻塞点> / 阻塞：<是|否>
```

| 类型 | 触发 | lead 动作 | 阻塞 |
|---|---|---|---|
| `决` | 需用户拍板、影响走向 | 当批次代问→接续重派 | 否（可继续） |
| `异` | 无法继续（验证失败/缺依赖） | failure-modes 处置＋可改派 | 是（等重派，不轮询） |
| `成` | **末次改动完成、跑验证句之前** | 预读 diff | 否（自跑验证句，照常回执） |

例：

```
[上行][add-subagent-control-and-coordination][T3.1][决] 登记簿写者归属需拍板 / 需要：代问 / 依据：refs/coordination.md §2 / 阻塞：否
[上行][add-subagent-control-and-coordination][T3.2][异] 验证句缺 openspec CLI / 需要：裁决 / 依据：bash: openspec: command not found / 阻塞：是
[上行][add-subagent-control-and-coordination][T3.3][成] 已改 3 文件，开始验证 / 需要：无需 / 依据：agent/skills/spec-apply/refs/execution.md:8 / 阻塞：否
```

失败降级：发送报错或父 id 缺失 → **不重试、不阻塞**，改写回执。

## §6 检查点与软废止

令 = 条目 `state=void` + `reason`，**没有第二份令文件**（§2）。检查点见 §4 第 3 条。

| 阶段 | 子代理行为 | 主会话行为 |
|---|---|---|
| 令写入时 | — | `Edit` 改 `state=void`、刷新 `at`、`reason` 依据 |
| 下一个检查点 | 停手：不再改动、不 `git`；`git status --porcelain` 只读核对；回执首行 `VOIDED` 并列已改文件 | — |
| 两次检查点之间已跑完 | 回执照常，**不含** `VOIDED` | 产出按新产出核对；**用户裁决去留，lead 不 revert** |
| 硬控制诉求 | — | 派发前按 §9 切 `--engine team`；已派发中无硬中断 |

## §7 spec-plan 精简段（仅待决+异常）

```
【上行·本任务（仅两类事件，不改提问节奏）】
- 发送：send_message(agent_id="<你的父 agent id，见 runtime context>")；"lead" 名不可寻址；失败即降级为回执上浮（不重试、不阻塞）。
- 决：[上行][<change>][<A线|B线|复算|设计>][决] 问题=<一句> / 选项=<a|b> / 推荐=<a> / 影响面=<…> —— 随后仍写产物「待决问题」节并在回执列 TOP，节奏不变（规划线并入 1.5、设计线并入落档分歧点）。
- 异：[上行][<change>][<同上>][异] 阻塞点=<…> / 依据=<…> / 阻塞：是 —— 不重试、不空转，照常收尾回执。
- 无租约、无检查点、无完成前奏（规划期无共享写面：独立性铁律已防写冲突）。
```

权威源 = 本文件 §7；`spec-plan` 只指路不复制（`worktree.md` 先例）；A/B 两线除占位外逐字等形。

## §8 冲突处置矩阵

| # | 冲突 | 机械判据 | 处置 |
|---|---|---|---|
| 1 | 同一任务被双登记 | 同 `T<n.m>` 两行均 `active` | lead 保留 `at` 较早行，后行置 `void`（`reason=duplicate claim`）；已派发则检查点自停手 |
| 2 | 写范围重叠 | §2 前缀判据命中 | **后登记方让路**：交集不写；不可避让 → 上行 `决` → lead 裁决 |
| 3 | 停滞 | 零落盘 + 无上行 + 无回执 | lead 置 `stalled` → 对 diff 跑验证句：过则补勾 `done`，否则重派（`@r2`）。**不轮询**（④D5） |
| 4 | 跨批残留 | 恢复后仍有 `active` | 按第 2/3 行处理；**不新建重复行**，禁止盲目重派 |
| 5 | 子代理互商诉求 | 请求「等我兄弟的结果」 | sibling 不可达 → 一律上行 lead；提示语「冲突经主会话裁决」 |

## §9 升级判据（只提示，不自动切）

| 判据 | 触发时点 | 动作 |
|---|---|---|
| 同任务审核被拒 ≥2 次 | 派发前 / 组收尾 | 提示「建议 `--engine team`（可 `interrupt_agent`）」 |
| 需在检查点之间即时叫停 | 派发前 | 同上（硬停只能 team） |
| 任务间需多轮互商（写面不可切分且互依细节） | 派发前 | 同上（team 可互发 `send_message`） |
| 预计 lead↔实现者 >2 轮澄清 | 派发前 | 同上 |

落点：`agent/skills/spec-apply/SKILL.md:37` 后「协调纪律」行（**只在 §三 写一份**；④D11）。

## §10 长度与维护

- 硬界：`len()` 3800–5000 cp；注入段 7–15 行（`awk`）。
- 单一权威源：变更只改本文件；消费方（`spec-apply`、`refs/*`、`spec-plan`）只指路。
- 改注入段/格式字段时同步核对消费方 grep 常量（如 `active→done|void|stalled`、`VOIDED`、`coord-inject`）。
- 措辞遵循 writing-skills：omission 用正向配方加槽（④D12）；GREEN 摆动按配方加槽（U3）。
