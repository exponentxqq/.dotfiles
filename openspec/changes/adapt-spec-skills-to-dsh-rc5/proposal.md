# Proposal

## Why

`spec-*` 系列技能（spec-workflow / spec-plan / spec-apply / spec-done）仍按 dsh 0.2.2-rc.1 的子代理机制书写——`spawn_teammate` 创建团队成员、上行须父会话 id 与 `agent_id` 参数、lead→subagent 下行不可达、team 成员无模型参数——而宿主已升级到 **0.2.2-rc.5**：这些断言对应的工具与行为已全部变化（具名子代理、树内任意互通、与会话级 Team 模式）。继续按现文加载会按已删除的工具执行，产生必然失败与静默漂移，且平台事实已分散复述在十余个文件中。

## What Changes

- **spec-plan**：并行双线从「team 驱动（`spawn_teammate`）」改为「具名 fresh 子代理单机制」；规划键路由恒按映射应用（删除 team 免裁与「显式 `--model` 强制 subagent」特例）；规划期中转回送统一为同实例续话；栈识别新增「纯文档/技能类触达面默认 `writing-skills`」分支（不再每次三选一）。
- **spec-apply**：协调协议 v2→v3——登记簿 `agent` 字段改记 `name`、上行事件收为决/异两类、软废止追加下行通知（登记簿仍为唯一权威令）、待决回送同实例续话优先（冷目标才重派）、受控嵌套（只许只读孙代理）；team 引擎重述为「根会话开启 Team 模式 + `team_task_*` 共享任务板 + 具名成员认领」，未开启自动回退 subagent；升级判据四条→单条；执行侧模型路由两引擎均适用。
- **spec-workflow**：执行期中转 Requirement 的回送句统一为同实例续话；`--engine team` 提示语补「需根会话菜单开启」；恢复协议登记簿口径 v2→v3。
- **spec-done**：验证子代理具名 `verify-<n>`（两行，零行为变化）。
- 触达 17 个文件（含上游双线漏掉的 `spec-plan/refs/planning.md`、`convergence.md` 与 `dsh/README.md` 三处补入面）；三份主规格 delta；**零应用代码**（纯 markdown 规范与 delta）。
- **BREAKING（对内）**：登记簿 v2→v3 字段变化；team 引擎语义重述；5 个 Requirement 以 REMOVED+ADDED 换名（validator 禁止 MODIFIED 删 Scenario）。

## Capabilities

### New Capabilities

（无——本次不引入新 capability。）

### Modified Capabilities

- `spec-plan`: 阶段 1 并行双线规划由 team 驱动改为具名 fresh 子代理；阶段级模型路由恒适用；规划期交互中转同实例回送；栈识别增加纯文档类默认分支。需要 delta 文件 `specs/spec-plan/spec.md`。
- `spec-apply`: subagent 执行引擎（具名派发、同实例续话、受控嵌套）；team 执行引擎（Team 模式重述与回退）；subagent 运行协调（登记簿 v3、检查点、上行两类、下行废止通知）；执行侧模型路由两引擎适用；执行期中转回送统一。需要 delta 文件 `specs/spec-apply/spec.md`。
- `spec-workflow`: 执行期交互中转的回送句统一（MODIFIED，保留既有 Scenario）。需要 delta 文件 `specs/spec-workflow/spec.md`。
