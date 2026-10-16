# Spec Delta

## REMOVED Requirements

### Requirement: 阶段 1 独立双线规划
**Reason**: 双线语义收归并行编排专属；串行改单线探索后，原「编排 SHALL 支持并行与串行（串行依次完成两遍）」的合并表述不再成立。
**Migration**: 并行双线语义迁往本变更 ADDED「阶段 1 并行双线规划（team 驱动）」（编排载体改 team + 按线回退 subagent，独立性铁律不变）；串行单线语义迁往 ADDED「阶段 1 串行单线探索」（openspec-explore + grill-me，不再双线）。

## ADDED Requirements

### Requirement: 阶段 1 并行双线规划（team 驱动）

spec-plan 并行编排 SHALL 以两条**方向不同、各自完整**的规划线完成需求规划（**不是分工**）：每线独立产出同一套 7 字段的完整轻量草案（目标与非目标、范围与边界、方案与取舍、任务拆分、验证思路、风险与未知、假设清单）；A 线取需求与价值方向，B 线取实现与风险方向；两线 SHALL 相互独立——不得读取对方产物、共享结论或代担子问题。派发 SHALL 默认 **team 驱动**：`spawn_teammate` 创建两个具名 fresh 成员（不继承主会话历史），成员待决与回送按中转协议以 `send_message` 回同一成员。team 不可行时该线 SHALL 回退 subagent 派发并在阶段摘要留痕原因。

#### Scenario: 并行产出两份完整草案

- **WHEN** 用户选择并行编排
- **THEN** 两条规划线各产出一份方向不同的完整轻量草案，而非探索报告加问题清单

#### Scenario: team 驱动派发

- **WHEN** 并行编排且 Agent Teams 可用
- **THEN** 每线由一个具名 fresh 成员完成，两线互不读取对方产物，回执核对通过后成员转闲置且不复用于后续线

#### Scenario: 不可行按线回退

- **WHEN** 成员创建失败、达成员上限、成员卡死重建一次仍失败、或该线存在显式 `--model lineA|lineB` 覆盖
- **THEN** 仅该线改派 subagent 并在阶段摘要留痕原因，另一线不受影响，不反复重试成员创建

#### Scenario: 混合编排合法

- **WHEN** 两线引擎不同（一线成员、一线子代理）
- **THEN** 双份草案照常产出与核对，每线引擎与回退原因留痕

#### Scenario: 两线相互独立

- **WHEN** 任一规划线执行中需要另一条线已掌握的信息
- **THEN** 该线自行查证或记为假设与未知，不得等待、读取或引用对方产物

### Requirement: 阶段 1 串行单线探索

spec-plan 串行编排（缺省）SHALL 为单线：主会话 SHALL 加载 `openspec-explore` skill 以探索姿态完成调研与规划（先查证后提问、跟随依赖、以代码事实为据），产出单份同一套 7 字段的完整轻量草案落 `/tmp/spec-flow/<change>/explore.md`，并另立「待决问题」节（问题、选项、推荐、影响面）；SHALL NOT 产出第二条规划线。待决项 SHALL 在阶段 1.5 以 `grill-me` 设计树/前沿分轮收敛并留痕 `/tmp/spec-flow/<change>/decisions.md`。`openspec-explore` 不可加载时 SHALL 按失败处置顺序修复，仍失败 SHALL 问用户（降级裸调研 / 改并行 / 终止），SHALL NOT 静默降级。

#### Scenario: 单线产出完整草案

- **WHEN** 用户选择串行编排
- **THEN** 主会话产出一份覆盖 7 字段的完整草案与待决问题节，不派发规划成员或子代理

#### Scenario: 待决分轮收敛

- **WHEN** 草案存在待决问题
- **THEN** 以 grill-me 前沿分轮提问（≤5 问/轮、各附推荐、答完重算），问答与结论留痕 decisions.md

#### Scenario: 探索 skill 不可载问用户

- **WHEN** 串行下 openspec-explore 不可加载且按处置顺序修复无效
- **THEN** 报告并问用户三选一（降级裸调研 / 改并行 / 终止），不静默降级

## MODIFIED Requirements

### Requirement: 双线差异收敛与分歧复算

并行编排的收敛 SHALL 由主会话七步完成：①交叉比对两份草案归为共识、分歧、单边遗漏，单边项 SHALL 逐项核验不得丢弃；②可查证分歧自行查证裁定并记录，不得转为提问；③影响走向且无法查证的分歧派第三条独立子代理（不以既有草案为输入）复算并三线对照定论；④加载 `openspec-explore` 以探索姿态审视合并视图与未决清单——补双边盲区、把可查证待决项降级为事实裁定，SHALL NOT 重开双线调研、SHALL NOT 推翻已收敛共识；⑤剩余决策项按 `grill-me` 设计树/前沿法提问（只问前沿、≤5 问/轮附推荐、答完重算）；⑥裁定、复算、审视与问答全部留痕；⑦前沿为空或用户确认共识即收敛，未答项 SHALL NOT 静默假设。串行编排 SHALL 跳过①–④，直接按「阶段 1 串行单线探索」的规定收敛。

#### Scenario: 按设计树前沿分轮提问

- **WHEN** 收敛出多个互相依赖的待决策问题
- **THEN** 只把前置已定的前沿放入本轮（≤5 个、各附推荐），依赖未决的留到后续轮次，答完重算前沿

#### Scenario: 提问前先自行查证事实

- **WHEN** 某待决问题需要环境事实（代码、规范、命令输出）
- **THEN** 自行查证，只把真正的决策项交给用户

#### Scenario: 单边遗漏被核验

- **WHEN** 某关键约束只被一条规划线提出
- **THEN** 逐项核验，按其成立与否决定是否写入落档工件

#### Scenario: 分歧触发第三线复算

- **WHEN** 两线对影响走向的问题结论不同且无法查证
- **THEN** 派第三条独立子代理复算，三线对照形成结论与依据

#### Scenario: 可查证分歧不问用户

- **WHEN** 两线分歧可由读代码、规范或只读命令判定
- **THEN** 自行查证裁定并记录依据，不向用户提问

#### Scenario: 探索审视补双边盲区

- **WHEN** 比对、裁定与复算完成且未决清单仍在
- **THEN** 主会话以 openspec-explore 姿态自由审视合并视图，新发现项自查查证后归入事实裁定或决策项，不重开双线调研

#### Scenario: 审视不推翻共识

- **WHEN** 探索审视发现与已收敛共识矛盾的内容
- **THEN** 不重开收敛，把矛盾作为待决项并入 grill-me 提问

#### Scenario: 问题超过单轮上限

- **WHEN** 待决策问题超过 5 个
- **THEN** 先呈现最关键的 ≤5 个，其余留到后续轮次

### Requirement: 落档工件与执行批次契约

spec-plan SHALL 通过 OpenSpec 变更工件落档（proposal、specs、design、tasks 四件套）；落档输入 SHALL 含代码设计草案（第 5 材料）；design SHALL 继承其深度并逐项断言核对通过；tasks SHALL 按编号分组表达执行批次——组即执行审核批次，组内单任务是合法常态，分组 SHALL 兼顾用户审核节奏；每任务 SHALL 携带可核验验证说明并引用代码设计触达面条目编号；落档 SHALL 校验通过后才交付执行。落档时 SHALL 把 `code-design.md` 与 `diff-matrix.md`（串行：`decisions.md`）复制入变更目录随工件提交；落档副本 SHALL 为执行期维护与接续恢复的权威，`/tmp` 侧原件自此不再维护。

#### Scenario: 分组内任务并行执行

- **WHEN** 某编号分组含多个相互独立的任务
- **THEN** 并行执行该分组内任务

#### Scenario: 分组间串行

- **WHEN** 前一分组任务尚未全部完成
- **THEN** 后续分组任务不开始执行

#### Scenario: 组内单任务合法

- **WHEN** 某任务与其余任务存在依赖或写冲突而单独成组
- **THEN** 该组以单任务成组，不被强制拆分或合并

#### Scenario: design 继承设计草案深度

- **WHEN** 落档生成 design 工件
- **THEN** design 承载设计草案的触达面、接口、决策与逐组要点，核对通过后校验

#### Scenario: 任务引用触达面条目

- **WHEN** tasks 写入某任务描述
- **THEN** 该任务引用其触达文件所属的触达面条目编号，使「同组不写同一文件」可机械核对

#### Scenario: 落档含规划材料

- **WHEN** 落档提交完成
- **THEN** 变更目录含 code-design.md 与 diff-matrix.md（串行为 decisions.md），随工件入库

#### Scenario: 执行期维护落档副本

- **WHEN** 执行期对 code-design.md 做组段终形态化或追加留痕
- **THEN** 写变更目录内的落档副本，更新随批次提交，不再维护 /tmp 侧原件

### Requirement: 子代理与用户的交互中转（规划期）

被父代理拥有的子代理 SHALL NOT 直接向用户提问（提问会被以 `DELEGATED_CALLER` 拒绝），规划期 SHALL 中转式交互：子代理 SHALL 把需拍板的决策（问题、选项、推荐、影响面）写入产物并在回执中上浮，SHALL NOT 自行假设；规划线上浮项 SHALL 并入阶段 1.5 统一提问，阶段 1.7 设计线上浮项 SHALL 并入落档分歧点提问，不新开通道、不积压；回送 SHALL 按引擎：team 回送同一成员（可多轮），subagent 接续重派；用户授权「按假设清单推进」时 SHALL 跳过代问并标注。本 Requirement 适用于并行编排的规划线、复算线与阶段 1.7 设计线；串行单线由主会话直问用户，不经中转。

#### Scenario: 子代理上浮待决问题

- **WHEN** 规划子代理遇到需用户拍板的决策
- **THEN** 它不自行假设，把问题连同选项与推荐写入产物并在回执中上浮；主会话将其并入 1.5 统一提问

#### Scenario: 设计期上浮并入落档提问

- **WHEN** 阶段 1.7 设计子代理上浮待决问题
- **THEN** 并入落档分歧点提问一次问清，不新开通道、不积压到落档后

#### Scenario: subagent 引擎接续重派

- **WHEN** 用户在 subagent 引擎下答复上浮问题
- **THEN** 把上轮回执摘要与答复并入新提示接续推进，不等待原实例

#### Scenario: team 引擎同实例多轮澄清

- **WHEN** team 引擎下某成员上浮待决策问题
- **THEN** Lead 代问后以消息回送该成员，成员在原上下文中继续，可多轮往返

### Requirement: 阶段级模型路由（规划键）

spec-plan SHALL 从共用映射文件读取规划阶段路由（键 `lineA`、`lineB`、`panel`、`design` 依次对应 A 线、B 线、复算线、设计线）并在派发时应用；每条路由 SHALL 支持可选 `fallback`；映射为空 SHALL 沿用会话模型；命令参数 SHALL 能覆盖主路由。路由仅适用于 subagent 派发：team 成员无模型参数，team 编排下 `lineA`/`lineB` SHALL NOT 应用（留痕告知）；串行单线无派发，规划键 SHALL NOT 消费；`panel`/`design` 恒为 subagent 派发，不受编排影响；显式 `--model lineA|lineB` 覆盖存在时该线 SHALL 以 subagent 派发兑现路由。执行键（`apply`/`verify`）、引擎与并行度 SHALL 由 `spec-workflow` 消费，spec-plan SHALL NOT 应用；落档在主会话进行，模型由用户切换。

#### Scenario: 映射指定规划阶段模型

- **WHEN** 映射文件为 lineA 或 design 指定模型路由
- **THEN** 对应阶段子代理使用该模型，且该路由必须已在允许列表中

#### Scenario: 映射为空

- **WHEN** 映射文件未指定规划阶段模型
- **THEN** 派发的子代理沿用会话模型

#### Scenario: team 编排忽略规划键

- **WHEN** 并行编排以 team 成员派发规划线
- **THEN** lineA/lineB 不应用，映射值被忽略并在阶段摘要留痕告知

#### Scenario: 显式覆盖走 subagent

- **WHEN** 用户以 --model lineA|lineB 显式覆盖某线模型
- **THEN** 该线以 subagent 派发并应用该路由，不静默丢弃显式覆盖
