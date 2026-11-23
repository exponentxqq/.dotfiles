# Spec Delta

## ADDED Requirements

### Requirement: 阶段 1 并行双线规划（具名 fresh 子代理）

spec-plan 并行编排 SHALL 以两条方向不同、各自完整的规划线完成需求规划（不是分工）：每线独立产出同一套 7 字段的完整轻量草案（目标与非目标、范围与边界、方案与取舍、任务拆分、验证思路、风险与未知、假设清单）；A 线取需求与价值方向，B 线取实现与风险方向；两线 SHALL 相互独立，不得读取对方产物、共享结论或代担子问题。派发 SHALL 以 `subagent` 工具在同一消息内并行派出两个 fresh 具名子代理（`plan-a`/`plan-b`），立即返回名称，完成通知自动送达；某线失败 SHALL 同实例补正或新名（`-r2`）重派一次并留痕。

#### Scenario: 并行产出两份完整草案

- **WHEN** 用户选择并行编排
- **THEN** 两条规划线各产出一份方向不同的完整轻量草案，而非探索报告加问题清单

#### Scenario: 两线具名派发

- **WHEN** 并行编排开始派发
- **THEN** 两线以 `subagent` 工具（`name=plan-a`/`plan-b`）在同一消息内派出，派发回执立即返回名称；两线互不读取对方产物

#### Scenario: 派发失败按线重派

- **WHEN** 某线派发报错或重名被拒
- **THEN** 按失败处置顺序以同实例续话补正一次，仍失败则以新名 `-r2` 重派一次，并在阶段摘要留痕；另一线不受影响

#### Scenario: 两线相互独立

- **WHEN** 任一规划线执行中需要另一条线已掌握的信息
- **THEN** 该线自行查证或记为假设与未知，不得等待、读取或引用对方产物

### Requirement: 阶段级模型路由（规划键·恒适用）

spec-plan SHALL 从共用映射文件读取规划阶段路由（`lineA`、`lineB`、`panel`、`design` 依次对应 A 线、B 线、复算线、设计线）并在派发时应用；每条路由 SHALL 支持可选 `fallback`；映射为空 SHALL 沿用会话模型；命令参数 SHALL 能覆盖主路由。规划键对全部派发恒适用——具名子代理与 Team 成员同为子代理派发，`lineA`/`lineB` SHALL 按映射应用，无编排例外；串行单线 SHALL NOT 消费规划键；显式 `--model` 覆盖 SHALL 直接应用。执行键 `apply`、`vision`、`engine`/`parallelism` SHALL 由 spec-apply 消费，`verify` 由 spec-done 复用。

#### Scenario: 映射指定规划阶段模型

- **WHEN** 映射文件为 lineA 或 design 指定模型路由
- **THEN** 对应阶段子代理使用该模型，且该路由必须已在允许列表中

#### Scenario: 映射为空

- **WHEN** 映射文件未指定规划阶段模型
- **THEN** 派发的子代理沿用会话模型

#### Scenario: 显式覆盖不丢弃

- **WHEN** 用户以 `--model lineA|lineB` 显式覆盖某线模型
- **THEN** 该线直接应用该路由，不因编排改道、不静默丢弃

#### Scenario: 规划键无编排例外

- **WHEN** 并行编排以具名子代理或 Team 模式成员派发规划线
- **THEN** `lineA`/`lineB` 均按映射应用；Team 模式仅追加共享任务板能力，不改变路由适用性

### Requirement: 子代理与用户的交互中转（规划期·同实例回送）

被父代理拥有的子代理 SHALL NOT 直接向用户提问（会被以 `DELEGATED_CALLER` 拒绝），规划期 SHALL 中转式交互：子代理 SHALL 把需拍板的决策（问题、选项、推荐、影响面）写入产物并在回执中上浮，SHALL NOT 自行假设；规划线 SHALL 另有上行通道——`send_message(agent="lead")` 直报主会话，事件限决、异两类，SHALL NOT 改变既有提问节奏；规划线上浮项 SHALL 并入阶段 1.5 提问，设计线上浮项 SHALL 并入落档分歧点；回送 SHALL 同实例续话优先，不可寻址时以上轮回执摘要+答复重派一次。

#### Scenario: 子代理上浮待决问题

- **WHEN** 规划子代理遇到需用户拍板的决策
- **THEN** 它不自行假设，把问题连同选项与推荐写入产物并在回执中上浮；主会话将其并入 1.5 统一提问

#### Scenario: 设计期上浮并入落档提问

- **WHEN** 阶段 1.7 设计子代理上浮待决问题
- **THEN** 并入落档分歧点提问一次问清，不新开通道、不积压到落档后

#### Scenario: 同实例续话回送

- **WHEN** 用户答复规划线或设计线子代理上浮的问题
- **THEN** 主会话以 `send_message` 回送同一具名子代理，其在原上下文中继续，无需重建

#### Scenario: 冷目标兜底重派

- **WHEN** 目标子代理已不可寻址（会话已亡或冷恢复被拒）
- **THEN** 以上轮回执摘要 + 答复重派一次，并留痕重派原因

#### Scenario: 上行早到不改变提问节奏

- **WHEN** 规划线/复算线/设计线子代理经上行消息直报待决或异常（早于回执到达）
- **THEN** 主会话按既有节奏处理（规划线并入 1.5、设计线并入落档分歧点），不因早到而新开问答通道；上行失败降级为回执上浮

## MODIFIED Requirements

### Requirement: 栈识别与 writer skill 加载（设计侧）

spec-plan SHALL 在阶段 1.7 派发前由主会话做栈识别（只读证据判据见场景），设计子代理 SHALL 先加载栈对应 writer skill 并以其规范为硬约束。判据按触达面性质分两支：**触达面零应用代码（全为 markdown 规范、技能或文档）时 SHALL 默认命中 `writing-skills`，SHALL NOT 再问用户三选一**；否则按 Spring/Nuxt 判据识别，未命中任何 writer skill 时 SHALL 问用户三选一（指认现有 skill／明确豁免并如实标注／终止），SHALL NOT 静默跳过。加载失败 SHALL 按失败处置顺序修复，仍失败 SHALL 报告问用户且 SHALL NOT 静默降级；trivial 豁免派遣时一行断言 SHALL 标注未触 writer 约束；落档任务拆分粒度 SHALL 满足所加载 writer skill 的拆分规定（引名不复述数值）；**栈识别结论（writer skill 名与证据）SHALL 写入落档 `design.md` 决策记录，供执行侧与接续恢复读取**。

#### Scenario: 栈命中加载对应 writer skill

- **WHEN** 只读证据命中一侧栈——`pom.xml`/`build.gradle(.kts)` 含 `spring-boot` 判 Spring，`nuxt.config.*` 存在或 package.json 依赖含 `nuxt` 判 Nuxt
- **THEN** 设计子代理派发提示点名先加载 `spring-writer`（或 `nuxt-writer`），其规范作为设计硬约束，回执注明已加载的 skill 名

#### Scenario: 双栈全加载

- **WHEN** 同一仓库两侧证据都命中（前后端同仓 monorepo，含子包目录）
- **THEN** 两个 writer skill 都加载，两侧触达面分别受各自规范约束

#### Scenario: 纯文档类默认 writing-skills

- **WHEN** 栈判据探测零命中且触达面全为 markdown 规范/技能/文档（零应用代码）
- **THEN** 直接命中 `writing-skills` 作为 writer skill，不问三选一；识别证据（零应用代码事实）写入 design.md 决策记录

#### Scenario: 栈未命中问用户三选一

- **WHEN** 栈识别既未命中 Spring 与 Nuxt，触达面也非纯文档类
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
- **THEN** writer skill 名与识别证据写入 design.md 决策记录，spec-apply 执行侧与接续恢复可从工件读取

## REMOVED Requirements

### Requirement: 阶段 1 并行双线规划（team 驱动）

### Requirement: 阶段级模型路由（规划键）

### Requirement: 子代理与用户的交互中转（规划期）
