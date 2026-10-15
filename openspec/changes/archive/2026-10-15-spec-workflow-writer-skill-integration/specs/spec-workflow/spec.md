## ADDED Requirements

### Requirement: 栈识别与 writer skill 加载（阶段 1.7 与阶段 3）

工作流 SHALL 在阶段 1.7 派发前由主会话做栈识别（只读证据判据见场景），结论 SHALL 记入阶段摘要并沿用至阶段 3；设计子代理与执行子代理 SHALL 先加载栈对应 writer skill（现有 `spring-writer`、`nuxt-writer`）并以其规范为硬约束；未命中任何 writer skill 时 SHALL 问用户三选一（指认现有 skill／明确豁免并如实标注／终止），SHALL NOT 静默跳过；加载失败 SHALL 按失败处置顺序修复，仍失败 SHALL 报告问用户且 SHALL NOT 静默降级；trivial 豁免派遣时一行断言 SHALL 标注未触 writer 约束；落档任务拆分粒度 SHALL 满足所加载 writer skill 的拆分规定（引名不复述数值）。

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

## MODIFIED Requirements

### Requirement: 阶段 1.7 代码设计线

工作流 SHALL 在阶段 1.5 收敛后、落档前执行代码设计线：SHALL 派全新子代理（`design` 路由，不随阶段 1 编排模式变化），读需求原文、两线草案与收敛记录，产出深度契约约束的设计草案——内容 SHALL 覆盖触达面清单（路径与意图）、证据锚（每模块 ≥1 条 file:line，新建文件标注）、接口与数据形状、决策记录（附被否方案与理由）、逐任务组实现要点、设计假设与未决项；验证思路 SHALL 落到具体命令或断言；SHALL NOT 推翻收敛结论，矛盾 SHALL 上浮待决；主会话 SHALL 核对通过后才落档。派发前主会话 SHALL 做栈识别，设计子代理 SHALL 先加载栈对应 writer skill 并以其规范为设计硬约束（契约见「栈识别与 writer skill 加载（阶段 1.7 与阶段 3）」）。

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

### Requirement: subagent 执行引擎

默认引擎 SHALL 为 subagent：每任务由独立全新子代理完成，提示 SHALL 自包含（任务描述、验收标准、design 该组实现要点逐字引用、其触达文件写范围、栈对应 writer skill 加载指令——沿用阶段 1.7 栈识别结论点名 skill 名，豁免时注明依据）；同组可并行、组间串行；主会话 SHALL 以验证说明与变更差异核对通过后才标记完成。执行子代理遇需拍板决策 SHALL 按「子代理与用户的交互中转」上浮并接续重派，SHALL NOT 因等待答复阻塞或自行假设。

#### Scenario: 执行提示携带设计要点
- **WHEN** 阶段 3 派发执行任务子代理
- **THEN** 其提示逐字引用 design 该组实现要点，不依赖子代理即兴做结构设计

#### Scenario: 执行提示含 writer skill 加载指令
- **WHEN** 阶段 1.7 已加载栈对应 writer skill 且以 subagent 引擎派发执行任务
- **THEN** 每个执行子代理的提示点名先加载同一 writer skill，规范约束随任务直达实现

#### Scenario: 产出未通过核对
- **WHEN** 子代理完成的任务不满足其验证说明
- **THEN** 连续模式下主会话派修复后重新核对；逐 task 审核模式下向用户呈现问题等裁决

#### Scenario: 任务失败
- **WHEN** 子代理执行任务失败
- **THEN**重试一次，仍失败则暂停并报告，不中断整个流程

### Requirement: team 执行引擎

工作流 SHALL 支持可选 team 引擎：Lead 把批次发布到共享任务板，每批次创建具名 implementer 认领，成员数 SHALL ≤该批次任务数；任务卡 SHALL 含与 subagent 引擎同款的栈对应 writer skill 加载指令；审核反馈 SHALL 以消息送达对应成员以保留上下文；成员待决问题 SHALL 由 Lead 代问后回送同一成员；该引擎下成员模型不参与阶段级模型路由。

#### Scenario: 逐 task 审核下修复
- **WHEN** 用户在 team 审核点要求修改某任务产出
- **THEN** Lead 把修改要求以消息发给负责成员，由其在原上下文内修复

#### Scenario: 任务卡含 writer skill 加载指令
- **WHEN** 阶段 1.7 已加载栈对应 writer skill 且以 team 引擎发布批次任务卡
- **THEN** 每张卡点名先加载同一 writer skill，与 subagent 引擎同款接线

#### Scenario: 成员不可用
- **WHEN** 某 implementer 创建失败或长时间无进展
- **THEN** Lead 中断或重建；无法恢复时降级 subagent 完成该任务
