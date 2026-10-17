# Spec Delta

## MODIFIED Requirements

### Requirement: 阶段级模型路由（规划键）

spec-plan SHALL 从共用映射文件读取规划阶段路由（键 `lineA`、`lineB`、`panel`、`design` 依次对应 A 线、B 线、复算线、设计线）并在派发时应用；每条路由 SHALL 支持可选 `fallback`；映射为空 SHALL 沿用会话模型；命令参数 SHALL 能覆盖主路由。路由仅适用于 subagent 派发：team 成员无模型参数，team 编排下 `lineA`/`lineB` SHALL NOT 应用（留痕告知）；串行单线无派发，规划键 SHALL NOT 消费；`panel`/`design` 恒为 subagent 派发，不受编排影响；显式 `--model lineA|lineB` 覆盖存在时该线 SHALL 以 subagent 派发兑现路由。执行键 `apply`、能力键 `vision` 与 `engine`/`parallelism` SHALL 由 `spec-apply` 消费，`verify` SHALL 由 `spec-done` 复用，spec-plan SHALL NOT 应用；落档在主会话进行，模型由用户切换。

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
- **THEN** writer skill 名与识别证据写入 design.md 决策记录，spec-apply 执行侧与接续恢复可从工件读取
