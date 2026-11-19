# Spec Delta：spec-apply

## MODIFIED Requirements

### Requirement: subagent 执行引擎

默认引擎 SHALL 为 subagent:每任务由独立全新子代理完成,提示 SHALL 自包含(任务描述、验收标准、design 该组实现要点逐字引用、其触达文件写范围、栈对应 writer skill 加载指令——沿用阶段 1.7 栈识别结论点名 skill 名,豁免时注明依据),并 SHALL 注入协调协议段(≤15 行,见「subagent 运行协调」);派发前 SHALL 在登记簿登记写范围与租约;同组可并行、组间串行;主会话 SHALL 以验证说明与变更差异核对通过后才标记完成。执行子代理遇需拍板决策 SHALL 按「子代理与用户的交互中转」上浮并接续重派,SHALL NOT 因等待答复阻塞或自行假设。

#### Scenario: 执行提示携带设计要点

- **WHEN** 派发执行任务子代理
- **THEN** 其提示逐字引用 design 该组实现要点,不依赖子代理即兴做结构设计

#### Scenario: 执行提示含 writer skill 加载指令

- **WHEN** 阶段 1.7 已加载栈对应 writer skill 且以 subagent 引擎派发执行任务
- **THEN** 每个执行子代理的提示点名先加载同一 writer skill,规范约束随任务直达实现

#### Scenario: 产出未通过核对

- **WHEN** 子代理完成的任务不满足其验证说明
- **THEN** 连续模式下主会话派修复后重新核对;逐 task 审核模式下向用户呈现问题等裁决

#### Scenario: 任务失败

- **WHEN** 子代理执行任务失败
- **THEN** 重试一次,仍失败则暂停并报告,不中断整个流程

#### Scenario: 派发注入协调段

- **WHEN** 以 subagent 引擎派发执行任务且提示不含协调协议段
- **THEN** 视为提示不完整,补齐协调段后才派发;派发前登记簿已登记该批全部条目

### Requirement: 子代理与用户的交互中转(执行期)

被父代理拥有的子代理 SHALL NOT 直接向用户提问(提问会被以 `DELEGATED_CALLER` 拒绝),执行半程 SHALL 提供中转式交互:执行任务的子代理 SHALL 把需拍板的决策(问题、选项、推荐、影响面)写入产物并在回执中上浮,SHALL NOT 自行假设;上浮通道 SHALL 含回执与上行消息两条(subagent 面 `send_message` 直报主会话);主会话 SHALL 当批次即时代问(≤5 问/轮、附推荐),SHALL NOT 为等答复阻塞或轮询;回送 SHALL 按引擎:team 回送同一成员(可多轮),subagent 以上轮回执摘要+答复接续重派;用户授权「按假设清单推进」时 SHALL 跳过代问并标注。

#### Scenario: 执行子代理上浮待决问题

- **WHEN** 执行子代理遇到需用户拍板的决策
- **THEN** 它不自行假设,写入产物与回执上浮;主会话当批次即时代问

#### Scenario: subagent 引擎接续重派

- **WHEN** 用户在 subagent 引擎下答复上浮问题
- **THEN** 把上轮回执摘要与答复并入新提示接续推进,不等待原实例

#### Scenario: team 引擎同实例多轮澄清

- **WHEN** team 引擎下某成员上浮待决策问题
- **THEN** Lead 代问后以消息回送该成员,成员在原上下文中继续,可多轮往返

#### Scenario: 授权假设清单推进

- **WHEN** 用户明确授权「按假设清单推进」
- **THEN** 跳过代问,产物与回执标注「已授权的假设清单」

#### Scenario: 上行直报不改变代问节奏

- **WHEN** 执行子代理经上行消息直报待决问题(早于回执到达)
- **THEN** 主会话仍按当批次即时代问处理,不因早到而新开问答通道

## ADDED Requirements

### Requirement: subagent 运行协调(登记簿·检查点·上行)

subagent 引擎 SHALL 以单一登记簿 `/tmp/spec-flow/<change>/progress.md` 同时承担派发台账、租约与废止令:写者 SHALL 仅为主会话,子代理 SHALL 只读;条目 SHALL 含任务号、写范围、子代理会话 id、状态与时刻;状态机 SHALL 为 active→done|void|stalled。派发前 SHALL 先登记全批条目再并发派发。子代理 SHALL 在开工、写文件前、验证前三处检查点读自己条目;遇 void|stalled 或写范围与他人 active 条目相交 SHALL 停手并上行。上行 SHALL 走 subagent 面 `send_message`(父会话 id 取自 runtime context,单发不候复),事件限待决、异常、完成前奏三类。下行与硬中断平台不可用,通知与废止 SHALL 仅在检查点生效;需即时叫停 SHALL 在派发前按判据建议切 team 引擎。

#### Scenario: 写范围重叠让路

- **WHEN** 子代理在开工检查点发现他人 active 条目的写范围与自己的相交
- **THEN** 交集路径一律不写;整任务无法避让时上行为「决」交主会话裁决,不自行协商

#### Scenario: 检查点废止生效(VOIDED)

- **WHEN** 子代理在任一检查点读到自己的条目 state=void
- **THEN** 立即停手:不再改动、不 git 操作,回执首行写 VOIDED 并列出已改文件

#### Scenario: 完成前奏上报

- **WHEN** 子代理完成末次改动、即将跑验证句
- **THEN** 以「成」类上行消息直报主会话(结论/需要/依据/阻塞),随后照常自跑验证句与回执

#### Scenario: 停滞判定与重派(不轮询)

- **WHEN** 某任务写范围零落盘且无上行无回执
- **THEN** 主会话判定 stalled:先对现存 diff 跑该任务验证句,通过补勾 done,未过才重派(@r2 新行,原行留存);不做定时轮询

#### Scenario: 引擎升级判据仅在派发前提示

- **WHEN** 派发前命中判据(同任务审核被拒≥2 次/需检查点间即时叫停/任务间需多轮互商/预计澄清>2 轮)
- **THEN** 提示用户本组建议 `--engine team`(可硬中断);不自动切换,已派发中无硬中断

#### Scenario: 登记簿单写者与子代理只读

- **WHEN** 任何登记簿状态变更(登记/销账/废止/停滞)
- **THEN** 由主会话以定点编辑完成,子代理不写登记簿;终态行不改写不删除
