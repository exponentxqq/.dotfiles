# diff-matrix.md · 阶段 1.5 收敛留痕

- 变更：`adapt-spec-skills-to-dsh-rc5`（需求原文：「我已经将dsh升级到v0.2.2-rc.5，基于前几轮对话重新规划spec-*系列的skill」）
- 日期：2026-11-23｜宿主：dsh 0.2.2-rc.5（本会话即运行其上）
- 编排：并行双线。两线均为**具名 fresh 子代理**（`spec-rc5-line-a` / `spec-rc5-line-b`）——rc.5 已无 `spawn_teammate`，旧 parallel.md 回退判据①自动命中（本次迁移必要性的活证据）。
- 模型路由：映射 `lineA/lineB = zcode-plan/glm-5.4` → provider 未获会话授权（`list_subagent_models` 揭示；文件脚本却报通过）→ 三档回退②档继承会话模型。
- 输入：`line-a.md`（205 行，7 字段 + 待决 7 条）、`line-b.md`（193 行，7 字段 + 待决 8 条）。

## 一、三分类矩阵（逐字段）

| 字段 | 共识 | 分歧（→ 裁定） | 单边遗漏（→ 核验结论） |
|---|---|---|---|
| 1 目标与非目标 | 消灭死工具与过时平台断言；原生能力简化协议但不推倒重建（登记簿、检查点、单写者保留）；行为变更全部走 delta；不采用 `task_board_*`/`notes_*`/`subagent_fork`；skill 文本写机制不写版本号 | 无实质 | A：opencode 侧不在验证范围（采纳）；B：dsh-plugins 仓基线升级为独立变更（已由用户完成，基线已是 rc.5，事实关闭） |
| 2 范围与边界 | 触达：spec-plan {SKILL, mode/parallel, refs/routing, refs/failure-modes}、spec-apply {SKILL, refs/coordination, refs/execution, refs/routing, refs/failure-modes}、spec-workflow SKILL、spec-done 核对、三主规格 delta | `dsh/commands` 薄壳是否入面（A 入 / B 出）→ **零改动**：实查仅 argument-hint 含 `[--engine team]`，参数保留即无需改 | B：主规格 SHALL 正文含 `spawn_teammate`（spec-plan/spec.md:307）→ 成立，纳入 |
| 3 方案与取舍 | 12 项机制裁定主体一致：删 spawn 双机制与「team 成员无模型参数」限制；上行改 `send_message(agent="lead")`；sibling「不可达」降为纪律；软废止保留；待决回送改同实例续话；登记簿保留 | (a) 上行「成」事件：A 裁撤 / B 保留 → **用户裁定裁为两类**；(b) 登记簿 agent 字段：A 只记 name / B 并记 session id → **事实裁定只记 name**；(c) 具名短码：B 提三案 → **用户裁定角色前缀+任务号** | B：软废止加下行通知 → **用户裁定追加**；B：interrupt 可用性列为派发前自检 → 采纳；B：狗粮悖论（执行期不得用被删机制）→ 纳入任务排序；A：Team 模式是用户菜单动作 → 纳入衔接话术 |
| 4 任务拆分 | 静态断言 RED→GREEN 驱动；分组覆盖 spec-plan / spec-apply / 编排层 / delta / 终检；组间串行、组内并行 ≤ parallelism | 组 1：B 四探针 / A 只读事实基线 → **并用**，以本会话活体证据优先（1.7 派发时零成本取上行/下行证据），不足再补一次性探针；组序（spec-apply 先 / spec-plan 先）→ 交 1.7 设计线按依赖定（parallel.md §7 指路 coordination.md） | — |
| 5 验证思路 | 单变更 `--strict`；入口码点门 8192；coordination.md 3800–5000 cp；消费方 grep 常量；死名清零；红线锚句抽查 | 无 | 审视新增：过时词表加 `run_in_background`；主规格 specs 侧全量 grep 收口 |
| 6 风险与未知 | 两线 R1–R10 合并（见下「风险合并表」） | — | 审视新增 R11、R12 |
| 7 假设清单 | 合并并逐条标注验证状态（见下「假设核验」） | — | — |

### 风险合并表（去重后）

| # | 风险 | 对策（来源） |
|---|---|---|
| R1 | rc 线再漂移 | 平台事实只在 coordination.md §1 带版本锚与证据路径；其余文件写机制（A/B） |
| R2 | name ≤32 字符，长变更名必超限 | 角色前缀+任务号规约；重名被拒追加变更短码（用户裁定） |
| R3 | steer 是步骤边界尽力语义，非即时 | 检查点保留为机械底座；下行通知只是加速器（B） |
| R4 | 同实例续话的上下文膨胀与污染 | 续话限短回合；任务失败重试恒 fresh 一次（B） |
| R5 | 第三方插件工具面无官方文档 | 不作核心机制地基；design.md 留痕来源（用户裁定） |
| R6 | Team 模式是用户菜单动作 | `--engine team` = 提示开启 + 未开启回退 subagent 留痕（用户裁定） |
| R7 | `interrupt_agent` 双态（默认关、独立组合默认开） | 派发前能力自检项；文档写「本配置下不可用」（B） |
| R8 | spec-plan 入口码点余量仅 46 | §四只写结论、细节全压 parallel.md；验证句写余量硬门（B） |
| R9 | 执行期新旧协议交替（狗粮回环） | 同组文件同批提交；执行本变更不用被删机制（B） |
| R10 | delta 面识别不全 | `grep -n 'team\|spawn_teammate\|接续重派' openspec/specs/spec-*/spec.md` 全量收口（B） |
| R11 | 用户在 `dsh/spec-workflow.yaml` 有未提交路由改动 | yaml 核对后零改动，不进提交面（审视） |
| R12 | 8 在线名额为每树共享池 | 批次 ≤ parallelism(8)；超限由容量控制器延迟非失败（审视） |

### 假设核验

| 假设 | 状态 |
|---|---|
| 宿主 = 0.2.2-rc.5，docs 与实现同步 | 已验（`dsh --version`、`--dump-config`） |
| dsh-plugins 基线升级待做 | 已完成（AGENTS.md 基线 `0.2.2-rc.5`） |
| add-ui-demo-gate 仍活跃 | 已归档（提交 `c146916`） |
| profile 白名单 8 条路由 | 过期——现为 10 条（含 glm-5.4，用户未提交改动） |
| 「subagent 无上限」 | 推翻——`maxActiveSubagents` 默认 8（本 profile 未覆盖） |
| 「team 成员上限 8」 | 推翻——`agent-team` 拒绝 `maxMembers`；仅剩 `maxTasks`（本 profile 256） |
| 本会话工具面无 `interrupt_agent` | 已验（lead 工具清单） |
| 上行 `send_message(agent="lead")` 与下行 steer 运行时可用 | 文档成立、运行时待 1.7 活体取证 |

## 二、探索审视（双边盲区与降级裁定）

1. **spec-workflow 主规格也需要 delta**（两线均漏）：spec.md:169 中转 Requirement 同写「subagent 接续重派」，:176/:181 两个 Scenario 随回送统一而改；:193/:202「team 任务卡」在 Team 模式语义下仍成立。→ delta 面为三主规格。
2. **`run_in_background: true` 是死参数**（两线均漏）：parallel.md:42；rc.5 的 `subagent` 工具无此参数，回执改为自动送达。→ 并入过时词断言。
3. **上限口径纠偏**：Team 无成员上限、仅任务板 `maxTasks`；subagent `maxActiveSubagents` 8，按树共享池（`rootPools`），Team 成员同池。→ 并发不构成选 team 的理由。
4. **嵌套派发零约束**（两线均漏）：本 profile `maxDepth: 2`，孙代理不受登记簿/检查点/注入段约束。→ 用户裁定受控嵌套。
5. **两块任务板归属**：`task_board_*` = 第三方 `@linxin666/dsh-client-ui-task-board`；`notes_*` = 第三方 `@zzerx/dsh-plugin-notes`；`team_task_*` = 官方 `@deepseek-ai/dsh-tool-agent-team`。
6. **降级为事实裁定的待决**：先后顺序（已归档）；路由自检（本会话实证工具揭示、脚本漏报）；登记簿字段（派发回执与 `list_agents` 对具名子代理只给名称）；`list_subagent_models` 优先。

## 三、设计树与前沿分轮记录

```
根：rc.5 适配
├─ 引擎终局 (Q1/Q5) ──→ §9 判据 (Q6) · --engine team 语义
├─ 上行事件 (Q2) ──→ 注入段行数
├─ 软废止下行通知 (Q3)
├─ 变更先后 (Q4) ──→ 事实关闭
├─ 具名规约 (Q7) ──→ 登记簿 agent 字段
├─ 孙代理纪律 (Q8)
└─ 新工具面留痕 (Q9)
```

| 轮 | 问 | 答复 |
|---|---|---|
| 1 | Q1 引擎去留 | 自定义（条件式）：team 若仍有上限则 subagent 须保留 → 查证：Team 仅剩任务板上限，subagent 有 8 并发上限 |
| 1 | Q2 上行「成」事件 | 裁为两类 |
| 1 | Q3 软废止下行通知 | 追加 |
| 1 | Q4 与 add-ui-demo-gate 先后 | 「5.3 已经归档了」→ 查证确认 |
| 2 | Q5 引擎终局 | 追问 team 与 subagent 的区别、只留 team 是否更合适 → 详答（功能差异仅共享任务板、同池并发） |
| 2 | Q6 升级判据 | 「先回答 Q5」 |
| 2 | Q7 具名规约 | 角色前缀+任务号 |
| 2 | Q8 孙代理 | 追问使用场景与能否补强 → 详答（价值在上下文隔离） |
| 2 | Q9 留痕 | 追问任务面板/便签归属 → 详答（第三方插件） |
| 3 | Q5 引擎终局 | **subagent 默认 + team 可选** |
| 3 | Q8 孙代理 | **受控嵌套：只许只读孙代理** |
| 3 | Q9 留痕 | **不采用，design.md 留痕** |
| 4 | Q6 升级判据 | **缩为单条** |
| 4 | 收敛结束确认 | **确认，进入阶段 1.7**（前沿为空、无静默假设项） |

## 四、结论清单（供 1.7 与落档）

| # | 结论 | 依据 |
|---|---|---|
| C1 | subagent 为默认核心引擎；team 保留并重述为可选：`--engine team` = 提示用户在会话菜单开启 Team 模式 → `team_task_*` 发布批次（write_scopes/blocked_by）→ 未开启或拒绝则回退具名 subagent 并留痕 | 用户裁定 Q5 |
| C2 | 执行期上行事件裁为决/异两类（settle 自动通知含最终回答） | 用户裁定 Q2 |
| C3 | 软废止追加下行通知；登记簿仍是唯一权威令，通知仅为加速器，检查点保留 | 用户裁定 Q3 |
| C4 | 具名规约：`plan-a`/`plan-b`/`panel-<n>`/`design`/`apply-<组>-<任务>`/`verify-<n>`；重派 `-r<n>`；重名被拒追加变更短码；硬约束 ≤32 小写 kebab、非 `lead` | 用户裁定 Q7 |
| C5 | 登记簿 v3：`agent` 字段记 name（派发前可推导）；schema 其余字段、状态机、单写者、Edit 定点规则不变 | 事实裁定 |
| C6 | 受控嵌套：不派可写子代理；检索/分析/复核可派只读孙代理（提示自包含、写明只读、转述本任务硬约束；产出由派发者核对） | 用户裁定 Q8 |
| C7 | sibling 冲突仍由 lead 裁决；论证从「平台不可达」改为「工作流纪律」 | 两线共识 |
| C8 | 待决回送：同实例续话优先，冷不可寻址才 fresh 重派；任务失败重试仍 fresh 一次 | 两线共识 |
| C9 | `task_board_*`/`notes_*`/`workflow`/`subagent_fork` 本期不采用；design.md 留「工具面 → 来源 → 采纳与否 → 理由」表 | 用户裁定 Q9 |
| C10 | 规划键路由恒适用（删 team 免裁及其例外）；路由自检 `list_subagent_models` 优先、脚本兜底 | 两线共识 + 本会话实证 |
| C11 | 升级判据 §9 缩为单条：「本组任务存在依赖图（blocked_by）、需动态认领或需写范围重叠告警，且用户愿意在会话菜单开启 Team 模式 → 提示建议 `--engine team`；并发量不构成理由（两引擎同受 8 在线上限）」 | 用户裁定 Q6 |
| C12 | skill 文本写机制、不写 dsh 版本号；版本锚与证据路径只在 coordination.md §1 | 两线共识 |
| C13 | delta 面 = spec-plan、spec-apply、spec-workflow 三主规格 | 审视 + 事实 |
| C14 | `dsh/spec-workflow.yaml` 与 `dsh/commands/*.md` 零改动 | 实查 |
