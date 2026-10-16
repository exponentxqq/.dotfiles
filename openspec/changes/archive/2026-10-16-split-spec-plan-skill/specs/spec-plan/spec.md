# Spec Delta

## Purpose

spec 驱动开发工作流的规划半程：从两条相互独立的完整规划与差异收敛、代码设计线，到 OpenSpec 变更落档提交——**到落档提交为止，不进入执行**。可经命令 `/spec-plan` 独立使用（只要规划不要执行的场景），也可被 `spec-workflow` 委托作为其六阶段流水线的阶段 1→2。

本 capability 自 `spec-workflow` 迁移而来（split-spec-plan-skill 变更）：规划类需求语义迁移并适配独立入口；新增组=执行审核批次语义与栈识别结论落盘 `design.md` 两处增强。

## ADDED Requirements

### Requirement: 规划入口（spec-plan）

系统 SHALL 提供全局 skill `spec-plan` 与命令 `/spec-plan` 作为规划半程入口；SHALL 接受需求描述、并行开关与规划键模型覆盖（`--model <规划阶段>=<provider>/<模型>`）；未给选项 SHALL 在对应阶段开始前询问，不得自行假设。流程 SHALL 终于阶段 2 落档提交——落档完成后 SHALL NOT 询问执行模式、SHALL NOT 写项目代码，收尾 SHALL 告知 `/spec-flow continue <变更名>` 接续执行。被 `spec-workflow` 委托时 SHALL 接受其转发的参数且不重问已预置项。

#### Scenario: 独立规划调用

- **WHEN** 用户调用 `/spec-plan 给登录页加验证码`
- **THEN** 以该需求启动双线规划，落档提交后收尾并告知接续命令，不进入执行

#### Scenario: 落档后不执行

- **WHEN** 落档校验通过并提交完成
- **THEN** 流程就此结束，不询问执行模式与引擎、不派发任何执行子代理

#### Scenario: 被委托时不重问

- **WHEN** spec-workflow 以已含 `--parallel` 的参数委托 spec-plan
- **THEN** spec-plan 按转发参数执行，不再询问并行编排

### Requirement: 阶段 1 独立双线规划

spec-plan SHALL 以两条**方向不同、各自完整**的规划线完成需求规划（**不是分工**）：每条线 SHALL 独立产出同一套字段的完整轻量草案（目标与非目标、范围与边界、方案与取舍、任务拆分、验证思路、风险与未知、假设清单）；A 线 SHALL 取需求与价值、范围与边界方向，B 线 SHALL 取实现与约束、反例与风险方向；两线 SHALL 相互独立——不得读取对方产物、共享结论或代担子问题。编排 SHALL 支持并行与串行（串行由主会话依次完成两遍）；规划子代理 SHALL NOT 写项目文件，需拍板的问题 SHALL 上浮取得答复，SHALL NOT 自行假设。

#### Scenario: 并行模式产出两份完整规划

- **WHEN** 用户选择并行编排
- **THEN** 两个子代理各产出一份方向不同的完整轻量草案，而非探索报告加问题清单

#### Scenario: 两线相互独立

- **WHEN** 任一规划线执行中需要另一条线已掌握的信息
- **THEN** 该线自行查证或记为假设与未知，不得等待、读取或引用对方产物

#### Scenario: 串行模式依次独立完成两遍

- **WHEN** 用户选择串行编排
- **THEN** 先独立完成并落盘一条线，再在未回看其结论时完成另一条线，标注独立性弱于并行

### Requirement: 双线差异收敛与分歧复算

主会话 SHALL 交叉比对两份草案并把差异归为共识、分歧与单边遗漏；单边项 SHALL 逐项核验不得丢弃；可查证的分歧 SHALL 自行查证裁定并记录，不得转为提问；影响走向且无法查证的分歧 SHALL 派第三条独立子代理（不以既有草案为输入）复算并三线对照定论；剩余决策项 SHALL 按 `grill-me` 设计树/前沿法提问（只问前沿、≤5 问/轮附推荐、答完重算；「是 / 同意」即接受推荐），前沿为空或用户确认共识即收敛；裁定、复算与未答项 SHALL 留痕。

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

#### Scenario: 问题超过单轮上限

- **WHEN** 待决策问题超过 5 个
- **THEN** 先呈现最关键的 ≤5 个，其余留到后续轮次

### Requirement: 阶段 1.7 代码设计线

spec-plan SHALL 在阶段 1.5 收敛后、落档前执行代码设计线：SHALL 派全新子代理（`design` 路由，不随阶段 1 编排模式变化），读需求原文、两线草案与收敛记录，产出深度契约约束的设计草案——内容 SHALL 覆盖触达面清单（路径与意图）、证据锚（每模块 ≥1 条 file:line，新建文件标注）、接口与数据形状、决策记录（附被否方案与理由）、逐任务组实现要点、设计假设与未决项；验证思路 SHALL 落到具体命令或断言；SHALL NOT 推翻收敛结论，矛盾 SHALL 上浮待决；主会话 SHALL 核对通过后才落档。设计子代理 SHALL 先加载栈对应 writer skill 并以其规范为设计硬约束（判据与处置见「栈识别与 writer skill 加载（设计侧）」）。

#### Scenario: 设计线产出契约草案

- **WHEN** 1.5 收敛结束且未命中降档判据
- **THEN** 全新子代理产出覆盖全部字段与行为约束的草案，逐项核对通过后作为落档输入

#### Scenario: 小需求降档

- **WHEN** 触达面 ≤2 个文件且无新接口
- **THEN** 部分深度字段允许单行简述，但触达面清单、假设与未决项与两条行为约束恒成立；trivial（单文件、无接口变更、无逻辑分支变化）命中时豁免派遣，由主会话一行断言落档，设计产物恒在

#### Scenario: 设计与收敛结论矛盾

- **WHEN** 设计草案与收敛记录的已定结论冲突
- **THEN** 设计线不重开收敛，把矛盾作为待决问题上浮并入落档分歧点提问

#### Scenario: 设计线失败

- **WHEN** 设计子代理产物缺失、字段残缺或答非所问
- **THEN** 重派一次，仍失败则如实报告由用户裁决

### Requirement: 子代理与用户的交互中转（规划期）

被父代理拥有的子代理 SHALL NOT 直接向用户提问（提问会被以 `DELEGATED_CALLER` 拒绝），规划期 SHALL 中转式交互：子代理 SHALL 把需拍板的决策（问题、选项、推荐、影响面）写入产物并在回执中上浮，SHALL NOT 自行假设；规划线上浮项 SHALL 并入阶段 1.5 统一提问，阶段 1.7 设计线上浮项 SHALL 并入落档分歧点提问，不新开通道、不积压；回送 SHALL 按引擎：team 回送同一成员（可多轮），subagent 接续重派；用户授权「按假设清单推进」时 SHALL 跳过代问并标注。

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

### Requirement: 落档工件与执行批次契约

spec-plan SHALL 通过 OpenSpec 变更工件落档（proposal、specs、design、tasks）；落档输入 SHALL 含代码设计草案（第 5 材料）；design SHALL 继承其深度并逐项断言核对通过；tasks SHALL 按编号分组表达执行批次——**组即执行审核批次，组内单任务是合法常态，分组 SHALL 兼顾用户审核节奏**；每任务 SHALL 携带可核验验证说明并引用代码设计触达面条目编号；落档 SHALL 校验通过后才交付执行。

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

### Requirement: 阶段级模型路由（规划键）

spec-plan SHALL 从共用映射文件读取规划阶段路由（键 `lineA`、`lineB`、`panel`、`design` 依次对应 A 线、B 线、复算线、设计线）并在派发时应用；每条路由 SHALL 支持可选 `fallback`；映射为空 SHALL 沿用会话模型；命令参数 SHALL 能覆盖主路由。执行键（`apply`/`verify`）、引擎与并行度 SHALL 由 `spec-workflow` 消费，spec-plan SHALL NOT 应用；落档在主会话进行，模型由用户切换。

#### Scenario: 映射指定规划阶段模型

- **WHEN** 映射文件为 lineA 或 design 指定模型路由
- **THEN** 对应阶段子代理使用该模型，且该路由必须已在允许列表中

#### Scenario: 映射为空

- **WHEN** 映射文件未指定规划阶段模型
- **THEN** 派发的子代理沿用会话模型

### Requirement: 读图覆盖与路由回退（规划侧）

规划键路由 SHALL 支持能力键 `vision`：某阶段任务需图片输入（截图、设计稿等）而该阶段路由不支持时，SHALL 忽略阶段路由改用 `vision` 派发，SHALL NOT 重试原路由。显式路由（含 `fallback`）SHALL 是允许列表子集；主路由不可用（不在列表、报错或限流）时 SHALL 依次回退：`fallback` 重派一次（若有）→ 继承会话模型派发一次 → 报告错误原文并暂停，SHALL NOT 反复重试。

#### Scenario: 读图任务改用 vision 路由

- **WHEN** 某规划阶段任务需要图片输入而该阶段路由不支持
- **THEN** 改用 `vision` 派发，不重试原路由

#### Scenario: 主路由不可用时按备用路由回退

- **WHEN** 主路由不在允许列表或 provider 失败且该键有 `fallback`
- **THEN** 以 `fallback` 重派一次并说明

#### Scenario: 备用路由也不可用

- **WHEN** 主路由与 `fallback` 均派发失败
- **THEN** 继承会话模型派发一次，仍失败则报告错误原文并暂停

#### Scenario: 配置改动对既有会话未生效

- **WHEN** 派发报该会话模型选择不可用（开关与列表在会话创建时读取）
- **THEN** 提示新建会话后重试，说明这不是工具故障

### Requirement: 压缩后指令完整存活

spec-plan skill SHALL 保证指令在压缩后完整可用：压缩后继续所必需的红线（独立性铁律、中转协议、不得静默假设待决项）SHALL 留在入口正文；其余指令 SHALL 位于可按需读取的同 bundle 资源，入口 SHALL 提供定位它的路由指引；外移与路由 SHALL NOT 改变既有 Requirement 的行为语义。规划中断后重进 SHALL 从 `/tmp` 材料与阶段摘要重建，材料缺失即重做对应阶段并如实告知。

#### Scenario: 压缩后红线内容仍可用

- **WHEN** 规划中压缩上下文后继续
- **THEN** 独立性铁律与中转协议仍完整存在于入口正文，流程从材料与阶段摘要接续

#### Scenario: 外移内容可按需读取

- **WHEN** 某阶段需要外移文件的指令（如双线模板、设计深度契约）
- **THEN** 入口路由指引足以定位并读取该文件，获得与外移前等价的指令

#### Scenario: 外移不改变行为语义

- **WHEN** 指令被搬入资源文件或入口改写为骨架
- **THEN** 既有 Requirement 的行为语义与触发条件不变，节标题与 skill 名称描述不变

### Requirement: 入口与资源按单次加载完整交付

spec-plan skill 的入口 SHALL 在单次按名加载内完整交付，每个外置资源文件 SHALL 在单次读取内完整交付——SHALL NOT 因宿主裁剪阈值丢失指令；入口与各资源文件 SHALL 各自控制在阈值内；骨架化与外移 SHALL NOT 改变既有 Requirement 的行为语义与触发条件。

#### Scenario: 单次加载得到完整入口

- **WHEN** 会话按名加载 skill（宿主 `skill` 工具返回入口正文）
- **THEN** 返回内容完整含红线最小集与按需读取路由指引，无指令被裁剪

#### Scenario: 资源文件独立完整交付

- **WHEN** 某阶段按入口路由读取任一资源文件
- **THEN** 该文件完整交付、不触发宿主裁剪，与外移前等价

#### Scenario: 骨架化不改变行为语义

- **WHEN** 入口改写为骨架、展开内容移入资源文件
- **THEN** 既有 Requirement 的行为语义与触发条件不变，节标题与 skill 名称描述不变

### Requirement: 栈识别与 writer skill 加载（设计侧）

spec-plan SHALL 在阶段 1.7 派发前由主会话做栈识别（只读证据判据见场景），设计子代理 SHALL 先加载栈对应 writer skill（现有 `spring-writer`、`nuxt-writer`）并以其规范为硬约束；未命中任何 writer skill 时 SHALL 问用户三选一（指认现有 skill／明确豁免并如实标注／终止），SHALL NOT 静默跳过；加载失败 SHALL 按失败处置顺序修复，仍失败 SHALL 报告问用户且 SHALL NOT 静默降级；trivial 豁免派遣时一行断言 SHALL 标注未触 writer 约束；落档任务拆分粒度 SHALL 满足所加载 writer skill 的拆分规定（引名不复述数值）；**栈识别结论（writer skill 名与证据）SHALL 写入落档 `design.md` 决策记录，供执行侧与接续恢复读取**。

#### Scenario: 栈命中加载对应 writer skill

- **WHEN** 只读证据命中一侧栈——`pom.xml`/`build.gradle(.kts)` 含 `spring-boot` 判 Spring，`nuxt.config.*` 存在或 package.json 依赖含 `nuxt` 判 Nuxt
- **THEN** 设计子代理派发提示点名先加载 `spring-writer`（或 `nuxt-writer`），其规范作为设计硬约束，回执注明已加载的 skill 名

#### Scenario: 双栈全加载

- **WHEN** 同一仓库两侧证据都命中（前后端同仓 monorepo，含子包目录）
- **THEN** 两个 writer skill 都加载，两侧触达面分别受各自规范约束

#### Scenario: 栈未命中问用户三选一

- **WHEN** 栈识别既未命中 Spring 也未命中 Nuxt
- **THEN** 停下问用户：指认现有 skill／明确豁免本次加载并如实标注／终止流程；不静默跳过

#### Scenario: trivial 豁免标注 writer 约束

- **WHEN** 命中 trivial 降档（单文件、无接口变更、无逻辑分支变化），主会话 inline 一行断言落档
- **THEN** 该断言标注「未触 writer 约束」；发现涉及分层、拆分或接口时升档并照常加载

#### Scenario: writer skill 加载失败上浮

- **WHEN** 派发前核对或子代理回执发现 writer skill 不可加载
- **THEN** 按失败处置顺序（登记核对 → `/commands-reload` → 重启兜底）修复，仍失败则报告问用户，不静默降级

#### Scenario: 任务粒度满足 writer 拆分规定

- **WHEN** 阶段 1.7 已加载 writer skill 且落档写 tasks 分组
- **THEN** 任务拆分粒度同时满足该 skill 的拆分规定，与触达面条目编号共同机械可核对

#### Scenario: 栈识别结论落盘

- **WHEN** 阶段 1.7 栈识别完成且落档生成 design 工件
- **THEN** writer skill 名与识别证据写入 design.md 决策记录，spec-workflow 执行侧与接续恢复可从工件读取
