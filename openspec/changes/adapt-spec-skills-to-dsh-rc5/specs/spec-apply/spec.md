# Spec Delta

## ADDED Requirements

### Requirement: subagent 运行协调（登记簿 v3·检查点·上行）

subagent 引擎 SHALL 以单一登记簿 `/tmp/spec-flow/<change>/progress.md`（v3）承担派发台账、租约与废止令：写者 SHALL 仅为主会话，子代理只读；条目 SHALL 含任务号、写范围、`agent`（派发返回的 name）、状态与时刻；状态机 SHALL 为 active→done|void|stalled；派发前 SHALL 先登记全批再并发。子代理 SHALL 在开工、写前、验证前三处检查点读自己条目，遇 void|stalled 或写范围相交 SHALL 停手并上行；上行走 `send_message(agent="lead")`，事件限决、异两类。软废止 SHALL 以登记簿为唯一权威，下行通知只加速。本配置无 `interrupt_agent`，SHALL NOT 依赖硬中断。

#### Scenario: 写范围重叠让路

- **WHEN** 子代理在开工检查点发现他人 active 条目的写范围与自己的相交
- **THEN** 交集路径一律不写；整任务无法避让时上行为「决」交主会话裁决，不自行协商

#### Scenario: 检查点废止生效(VOIDED)

- **WHEN** 子代理在任一检查点读到自己的条目 state=void
- **THEN** 立即停手：不再改动、不 git 操作，回执首行写 VOIDED 并列出已改文件

#### Scenario: 停滞判定与重派(不轮询)

- **WHEN** 某任务写范围零落盘且无上行无回执
- **THEN** 主会话判定 stalled：先对现存 diff 跑该任务验证句，通过补勾 done，未过才重派（@r2 新行，原行留存）；不做定时轮询

#### Scenario: 引擎升级判据仅在派发前提示

- **WHEN** 派发前本组任务存在依赖图、需动态认领或需写范围重叠告警，且用户愿意在会话菜单开启 Team 模式
- **THEN** 提示建议 `--engine team`；并发量不构成理由；不自动切换，已派发中无硬中断

#### Scenario: 登记簿单写者与子代理只读

- **WHEN** 任何登记簿状态变更（登记/销账/废止/停滞）
- **THEN** 由主会话以定点编辑完成，子代理不写登记簿；终态行不改写不删除

#### Scenario: 下行废止通知仅加速

- **WHEN** 主会话写入 void 后追加一次 `send_message` 下行通知
- **THEN** 子代理以登记簿条目为准停写；通知只缩短生效时延，不构成第二份令

#### Scenario: 本配置无硬中断可用

- **WHEN** 执行期需要立即叫停某子代理
- **THEN** 以软废止 + 三处检查点实现；不依赖 `interrupt_agent`（本配置 preset 关闭）

### Requirement: 执行侧模型路由（两引擎适用）

执行半程 SHALL 从共用映射文件 `dsh/spec-workflow.yaml` 读取执行侧配置并在派发时应用：键 `apply` 对应执行子代理，`vision` 为读图覆盖，`engine`/`parallelism` 为引擎与并行度偏好；显式路由 SHALL 是允许列表子集，映射为空 SHALL 沿用会话模型，命令参数 SHALL 能覆盖主路由；主路由不可用 SHALL 按共用回退顺序处置，SHALL NOT 反复重试。`apply` 键对 subagent 与 team 两引擎 SHALL 均适用；并行度 SHALL ≤ `parallelism` 并与在线子代容量相容。

#### Scenario: 映射指定执行模型

- **WHEN** 映射文件为 apply 指定模型路由
- **THEN** 执行子代理使用该模型，且该路由已在允许列表中

#### Scenario: 映射为空

- **WHEN** 映射文件未指定执行阶段模型
- **THEN** 派发的子代理沿用会话模型

#### Scenario: team 引擎同样应用 apply 键

- **WHEN** 以 team 引擎派发且映射含 apply 路由
- **THEN** 成员（具名子代理）同样应用该路由，与 subagent 引擎一致

## MODIFIED Requirements

### Requirement: subagent 执行引擎

默认引擎 SHALL 为 subagent：每任务由独立 fresh 具名子代理完成（`name=apply-<组>-<任务>`，重派加 `-r<n>`），提示 SHALL 自包含（任务描述、验收标准、design 该组实现要点逐字引用、写范围、栈对应 writer skill 加载指令——沿用阶段 1.7 栈识别结论点名 skill 名，豁免时注明依据），并 SHALL 注入协调协议段（≤15 行，见「subagent 运行协调」）；派发前 SHALL 在登记簿登记该批全部条目（含 name）；派发 SHALL 立即返回名称，完成通知自动送达；同组可并行、组间串行；主会话 SHALL 以验证说明与变更差异核对通过后才标记完成。待决回送 SHALL 同实例续话优先（`send_message` 回同一具名子代理），冷目标才以上轮回执摘要 + 答复重派一次；任务失败 SHALL 以 fresh 新名（`-r2`）重试一次，仍失败暂停报告。执行子代理 SHALL NOT 再派可写子代理；检索/分析/复核类 MAY 派只读孙代理（提示自包含、写明只读并转述本任务硬约束），其产出由派发者核对。

#### Scenario: 执行提示携带设计要点

- **WHEN** 派发执行任务子代理
- **THEN** 其提示逐字引用 design 该组实现要点，不依赖子代理即兴做结构设计

#### Scenario: 执行提示含 writer skill 加载指令

- **WHEN** 阶段 1.7 已加载栈对应 writer skill 且以 subagent 引擎派发执行任务
- **THEN** 每个执行子代理的提示点名先加载同一 writer skill，规范约束随任务直达实现

#### Scenario: 产出未通过核对

- **WHEN** 子代理完成的任务不满足其验证说明
- **THEN** 连续模式下主会话派修复后重新核对；逐 task 审核模式下向用户呈现问题等裁决

#### Scenario: 任务失败

- **WHEN** 子代理执行任务失败
- **THEN** 以 fresh 新名（`-r2`）重试一次，仍失败则暂停并报告，不中断整个流程

#### Scenario: 派发注入协调段

- **WHEN** 以 subagent 引擎派发执行任务且提示不含协调协议段
- **THEN** 视为提示不完整，补齐协调段后才派发；派发前登记簿已登记该批全部条目

#### Scenario: 具名派发即返名

- **WHEN** 主会话派发执行子代理
- **THEN** 派发立即返回 `started subagent <name>`，不阻塞；登记簿同步回填 name，完成通知随回合自动送达

#### Scenario: 完成后同实例续话

- **WHEN** 用户或主会话需向已完成的任务子代理追加答复、审核意见或补正要求
- **THEN** 以 `send_message` 回送同一具名子代理，其在原上下文中继续；仅在不可寻址时才重派

#### Scenario: 受控嵌套只读

- **WHEN** 执行子代理需要大范围检索、分析或复核
- **THEN** MAY 派只读孙代理（提示自包含、写明「只读：不写文件、不 git」并转述本任务硬约束）；不得派可写孙代理；其产出由派发者核对后并入自己的回执

### Requirement: team 执行引擎

执行半程 SHALL 支持可选 team 引擎，前置为**根会话开启 Team 模式**（用户在会话菜单操作，模型不能自开；未开启或用户拒绝 SHALL 回退 subagent 并留痕）。开启后 lead SHALL 以 `team_task_create` 把批次发布到共享任务板（任务卡含 `write_scopes` 与 `blocked_by`），并以具名子代理派发 implementer；implementer SHALL 按当前 revision 以 CAS 认领任务卡后执行；任务卡 SHALL 含与 subagent 引擎同款的栈对应 writer skill 加载指令；审核反馈 SHALL 以消息送达对应成员以保留上下文；成员待决问题 SHALL 由 Lead 代问后回送同一成员；该引擎下 `apply` 路由 SHALL 同样应用；成员不可用 SHALL 以续话补正或重派一次，仍不可用降级 subagent 完成该任务。Team 模式无成员数上限，仅受任务板 `maxTasks` 约束；并发名额与 subagent 引擎同池，SHALL NOT 以并发为由切换引擎。

#### Scenario: 逐 task 审核下修复

- **WHEN** 用户在 team 审核点要求修改某任务产出
- **THEN** Lead 把修改要求以消息发给负责成员，由其在原上下文内修复

#### Scenario: 任务卡含 writer skill 加载指令

- **WHEN** 阶段 1.7 已加载栈对应 writer skill 且以 team 引擎发布批次任务卡
- **THEN** 每张卡点名先加载同一 writer skill，与 subagent 引擎同款接线

#### Scenario: 成员不可用

- **WHEN** 某 implementer 创建失败或长时间无进展
- **THEN** Lead 以续话补正或重派一次；仍不可恢复时降级 subagent 完成该任务

#### Scenario: Team 模式未开回退

- **WHEN** 用户指定 `--engine team` 但根会话未开启 Team 模式或拒绝开启
- **THEN** 自动回退 subagent 引擎执行并在阶段摘要与登记簿留痕，不静默假装已用 team

#### Scenario: 任务卡含依赖与写范围

- **WHEN** 批次任务间存在先后依赖或写范围需协调
- **THEN** 任务卡携带 `blocked_by` 与 `write_scopes`，成员按就绪态与写范围重叠告警认领

### Requirement: 子代理与用户的交互中转(执行期)

被父代理拥有的子代理 SHALL NOT 直接向用户提问(提问会被以 `DELEGATED_CALLER` 拒绝),执行半程 SHALL 提供中转式交互:执行任务的子代理 SHALL 把需拍板的决策(问题、选项、推荐、影响面)写入产物并在回执中上浮,SHALL NOT 自行假设;上浮通道 SHALL 含回执与上行消息两条(`send_message(agent="lead")` 直报主会话);主会话 SHALL 当批次即时代问(≤5 问/轮、附推荐),SHALL NOT 为等答复阻塞或轮询;回送 SHALL **同实例续话优先**(回同一具名子代理),仅在目标不可寻址时才以上轮回执摘要+答复重派一次;用户授权「按假设清单推进」时 SHALL 跳过代问并标注。

#### Scenario: 执行子代理上浮待决问题

- **WHEN** 执行子代理遇到需用户拍板的决策
- **THEN** 它不自行假设,写入产物与回执上浮;主会话当批次即时代问

#### Scenario: subagent 引擎接续重派

- **WHEN** 目标子代理已不可寻址（会话已亡或冷恢复被拒）
- **THEN** 把上轮回执摘要与答复并入新提示重派一次，并留痕重派原因

#### Scenario: team 引擎同实例多轮澄清

- **WHEN** team 引擎下某成员上浮待决策问题
- **THEN** Lead 代问后以消息回送该成员，成员在原上下文中继续，可多轮往返

#### Scenario: 授权假设清单推进

- **WHEN** 用户明确授权「按假设清单推进」
- **THEN** 跳过代问，产物与回执标注「已授权的假设清单」

#### Scenario: 上行直报不改变代问节奏

- **WHEN** 执行子代理经上行消息直报待决问题(早于回执到达)
- **THEN** 主会话仍按当批次即时代问处理，不因早到而新开问答通道

#### Scenario: 同实例续话优先

- **WHEN** 用户答复执行子代理上浮的问题
- **THEN** 主会话以 `send_message` 回送同一具名子代理，其在原上下文中继续

## REMOVED Requirements

### Requirement: subagent 运行协调(登记簿·检查点·上行)

### Requirement: 执行侧模型路由
