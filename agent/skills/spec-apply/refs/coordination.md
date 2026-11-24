# coordination.md · 协调协议

> `spec-apply/SKILL.md` §三「协调纪律」外移（唯一权威源）；回入口引用「SKILL.md §三」，消费方只指路。登记簿 v4 与路由快照（`/tmp/spec-flow/<change>/routing.md`）为执行期唯一派发凭据。

## §1 平台事实（不得违反）

**基线**（rc.5 实测 2026-11-23；实证锚 = 本变更双线具名派发与设计线开工/steer；文档锚 = dsh docs；证据见 diff-matrix.md）：
- **上下行 + 名寻址**：`send_message` 发树内任意成员，`lead`=根；运行中步骤边界收 steer、闲置起轮、冷目标恢复；未命中路径报 `AGENT_NAME_NOT_FOUND`（subagent:184/196-198；catalog:2311/2317）。
- **sibling 技术可达**（跨分支）：仍禁止私商写冲突，冲突归主会话（subagent:198；catalog:2298）。
- **本配置无硬中断**：`interrupt_agent` 未挂载（preset `interrupt:false`）；按工具面自检，不写「平台不可用」（rc.1 interrupt）。
- **委派即返名**：完成通知自动递送、结束后可续话（catalog:2237/2269）。
- **省略路由 = 继承父会话**：`subagent` 未传 `provider`/`model` 时按父会话路由派生；白名单只校验显式路由、**不拦继承**（`dsh-tool-subagent` 的 `requestedAgentOptions` 与 `assertAllowedModelSelection`）——静默失效是平台语义，工作流必须显式传路由并由子代理自证。

锚点（`docs/` 下）：`subagent`=`subsystems/subagent.zh.md`；`catalog`=`tool-catalog.zh.md`；`rc.1 interrupt`=`upgrade-guide/v0.2.2-rc.1/subagent-interrupt-default`。版本快照只写本块。

## §2 登记簿 schema 与状态机

登记簿 = `/tmp/spec-flow/<change>/progress.md`（**v4**）；路由快照 = 同目录 `routing.md`（**唯一派发源**，字段与解析见 spec-apply refs/routing.md）。必填，`reason` 为 `void`/`stalled` 依据或漂移留痕。

| 字段 | 取值 | 语义与约束 |
|---|---|---|
| `T<n.m>` | 行首 token | 任务号；重派加 `@r2` |
| `scope` | 仓内相对路径，逗号分隔，目录以 `/` 结尾 | 写范围 |
| `agent` | `<name>` / `pending` | **v3：记派发返回的 name**（派发前按命名规约可推导）；`pending`=未派发；回执 `started subagent <name>` 核对后回填 |
| `state` | `active\|done\|void\|stalled` | 状态机不变 |
| `at` | ISO8601 带时区 | 最后状态变更 |
| `src` | `dispatch\|receipt\|void\|recover` | 状态来源 |
| `route` | `<provider>/<model>` / `inherit` | **v4 新增**：本次派发实际路由（审计记录，不驱动派发——驱动派发的是 `routing.md`）；`inherit` 仅映射为空或三档回退②，须在 `reason` 记原因 |
| `reason` | 自由文本 | `void`/`stalled` 依据；或 `ROUTE-DRIFT actual=<模型>` / `ACK-ADJUDICATED` 留痕 |

**状态机**（不变）：`active --回执通过--> done`｜`active --用户叫停/lead 放弃--> void`（软废止令）｜`active --零落盘+无上行+无回执--> stalled`｜`stalled --重派--> 新行 @r2`。

**v3 → v4 兼容**：v3 登记簿不强制升级；v4 新行必须带 `route`；终态行不改写。**只有 `routing.md` 存在时子代理才强制自证**——v3/无快照按 `ROUTE-LEGACY` 放行，不阻断在途变更。

**命名规约（v3）**：`name = <角色>-<序号>`——`plan-a`/`plan-b`/`panel-<n>`/`design`/`apply-<组>-<任务>`/`verify-<n>`；重派追 `-r<n>`（如 `apply-2-1-r2`）。硬约束：全名 **≤32 字符、小写 kebab、字母开头、非保留名 `lead`**（catalog:2251–2253）。重名被拒 → 追加变更短码 `-<变更名首段截6字符><变更名长度十进制>`（`adapt-spec-skills-to-dsh-rc5` → `-adapt28`）重试一次；再拒即上行 `异`，不循环。

**写者**：仅主会话；子代理只读；`Edit` 定点改，禁 `Write` 覆盖；终态行不改写、不删除。

**重叠判据**：归一化（去空白、去行尾 `/`）后，`a`/`b` 重叠 ⟺ 相等或一方以另一方 + `/` 开头。一读即得：`grep -n 'state=active' /tmp/spec-flow/<change>/progress.md`。

## §3 派发前登记序（lead 操作序）

1. **先读快照**：读 `/tmp/spec-flow/<change>/routing.md` 取本批路由键值（缺失先按 refs/routing.md 重建，重建前不派发）。
2. **先登记全批再并发**：按 §2 逐任务一行，`agent=pending`、`route=<快照值>`；`scope` 从触达面抄，目录以 `/` 结尾。
3. 派发返回 `started subagent <name>` 后按命名规约核对回填 `agent=<name>`；回执通过 → `state=done`（`at`/`src=receipt`）；未到按 §8。
4. 注入段（§4 全文连标记）粘进每个 fresh 子代理提示；team 不注入。

## §4 协调协议注入段模板

连标记粘：

```
<!-- coord-inject:start -->
【协调协议·本任务强制】
0. 路由自证（开工第一动作）：读 /tmp/spec-flow/<change>/routing.md 的本任务键（默认 apply；读图任务 vision）得 R；与系统提示「powered by <模型> model」比对：一致或 R=inherit → 开工，回执首行 ROUTE-ACK model=<实际>；不一致 → 停手（不写文件、不 git），send_message(agent="lead") 报 [上行][<change>][T<n.m>][异] 路由漂移 expected=<R> actual=<模型> / 阻塞：是，回执首行 ROUTE-MISMATCH；routing.md 缺失 → 开工并回执首行 ROUTE-LEGACY；键缺失 → 停手，回执首行 ROUTE-MISSING。
1. 登记簿（唯一协调源）：/tmp/spec-flow/<change>/progress.md。开工第一动作读全表，记下他人 state=active 的 scope。
2. 让路：他人 scope 与你的写范围前缀相交 → 交集路径一律不写；整任务无法避让 → 按第 4 条上行为「决」。
3. 检查点（读你自己条目，共三处）：①动任何文件前 ②每次写文件前 ③跑验证句前。条目 state=void|stalled 或 agent 非你的 name → 停手：不再改动、不 git 操作，回执首行写 VOIDED；收到下行废止通知也以登记簿为准。
4. 上行发送：send_message(agent="lead")（根名寻址；失败即降级，不重试、不阻塞，改写进回执）。
5. 上行格式（单发不候复，只陈述结论与需要，不提问）：[上行][<change>][T<n.m>][决|异] 结论一句 / 需要：代问|裁决|无需 / 依据：<file:line> / 阻塞：是|否
6. 必报两类：决=需用户拍板；异=无法继续（验证失败/缺依赖/工具故障）。
7. 兄弟子代理技术上互可达，但本工作流禁止私商写冲突：一切冲突经主会话裁决，禁止互相等待或自行协商。
<!-- coord-inject:end -->
```

配方非禁令：正向加槽（④D12）。

## §5 上行格式与示例

**单行**，不提问；**单发不候复**；格式与 §4 第 5 条逐字一致：

```
[上行][<change>][T<n.m>][决|异] 结论一句 / 需要：代问|裁决|无需 / 依据：<file:line> / 阻塞：是|否
```

| 类型 | 触发 | lead 动作 | 阻塞 |
|---|---|---|---|
| `决` | 需用户拍板 | 当批次代问→同实例续话回送 | 否（可继续） |
| `异` | 无法继续（验证失败/缺依赖） | failure-modes 处置＋可改派 | 是（等重派，不轮询） |

例：

```
[上行][adapt-spec-skills-to-dsh-rc5][T2.1][异] 验证句缺 openspec CLI / 需要：裁决 / 依据：bash: openspec: command not found / 阻塞：是
```

失败降级：报错或未命中根名 → 不重试、不阻塞，改写回执。

## §6 检查点与软废止

令 = 条目 `state=void` + `reason`，**无第二份令文件**（§2）。检查点见 §4 第 3 条。

| 阶段 | 子代理行为 | 主会话行为 |
|---|---|---|
| 令写入时 | — | `Edit` 改 `state=void`、刷新 `at`、`reason` 依据；另发 `send_message(agent="<name>")` 下行通知（仅加速，登记簿仍唯一令） |
| 下一个检查点 | 停手：不再改动、不 `git`；`git status --porcelain` 只读核对；回执首行 `VOIDED` 并列已改文件 | — |
| 两次检查点之间已跑完 | 回执照常，**不含** `VOIDED` | 产出照常核对；**用户裁决去留，lead 不 revert** |
| 硬控制诉求 | — | 派发前按 §9 切 `--engine team`；已派发中无硬中断 |

## §7 spec-plan 精简段（仅待决+异常）

```
【上行·本任务（仅两类事件，不改提问节奏）】
- 发送：send_message(agent="lead")（根名寻址；失败即降级为回执上浮，不重试、不阻塞）。
- 决：[上行][<change>][<A线|B线|复算|设计>][决] 问题=<一句> / 选项=<a|b> / 推荐=<a> / 影响面=<…> —— 随后仍写产物「待决问题」节并在回执列 TOP，节奏不变（规划线并入 1.5、设计线并入落档分歧点）。
- 异：[上行][<change>][<同上>][异] 阻塞点=<…> / 依据=<…> / 阻塞：是 —— 不重试、不空转，照常收尾回执。
- 无租约、无检查点（规划期无共享写面：独立性铁律已防写冲突）。
```

权威源 = 本文件 §7；`spec-plan` 只指路不复制（`worktree.md` 先例）；A/B 两线除占位外等形。

## §8 冲突处置矩阵

| # | 冲突 | 机械判据 | 处置 |
|---|---|---|---|
| 1 | 同一任务被双登记 | 同 `T<n.m>` 两行均 `active` | lead 保留 `at` 较早行，后行置 `void`（`reason=duplicate claim`）；已派发则检查点自停手 |
| 2 | 写范围重叠 | §2 前缀判据命中 | **后登记方让路**：交集不写；不可避让 → 上行 `决` → lead 裁决 |
| 3 | 停滞 | 零落盘 + 无上行 + 无回执 | lead 置 `stalled` → 对 diff 跑验证句：过则补勾 `done`，否则重派（`@r2`）。**不轮询**（④D5） |
| 4 | 跨批残留 | 恢复后仍有 `active` | 按第 2/3 行处理；**不新建重复行**，禁止盲目重派 |
| 5 | 子代理互商诉求 | 请求「等我兄弟的结果」 | 技术可达但禁止私商：一律上行 lead，禁止互相等待或自行协商；提示语「冲突经主会话裁决」 |

## §9 升级判据（只提示，不自动切）

> 本组任务存在 `blocked_by` 依赖图、需动态认领或需写范围重叠告警 → 提示建议 `--engine team`，并说明需先在根会话菜单开启 Team 模式；用户拒绝或不可用 → 维持 subagent 并留痕；并发量不构成理由（两引擎同受 8 在线上限）。

落点：`agent/skills/spec-apply/SKILL.md:37` 后「协调纪律」行（**只在 §三 写一份**；④D11）。

## §10 长度与维护

- 硬界：`len()` 3800–**6400** cp（v4 增路由字段与自证段后上调；仍低于单文件 8192 上限）；注入段 7–15 行。
- 单一权威源：变更只改本文件；消费方（`spec-apply`、`refs/*`、`spec-plan`）只指路。
- 消费方 grep 常量：`active→done|void|stalled`、`VOIDED`、`coord-inject`、`send_message(agent="lead")`、`route=`、`ROUTE-ACK`、`ROUTE-MISMATCH`、`ROUTE-LEGACY`、`routing.md`。
- 措辞遵循 writing-skills：配方加槽（U3，④D12）。
