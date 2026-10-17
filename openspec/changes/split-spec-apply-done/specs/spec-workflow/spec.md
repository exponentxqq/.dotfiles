# Spec Delta

## REMOVED Requirements

### Requirement: subagent 执行引擎

迁移至新能力 `spec-apply`(执行半程独立;编排层不再承载执行引擎细则)。

### Requirement: team 执行引擎

迁移至新能力 `spec-apply`。

### Requirement: 执行模式与提交节奏

迁移至新能力 `spec-apply`(批次提交节奏随执行半程;落档与归档提交节奏分归 spec-plan 落档与 spec-done 归档承载)。

### Requirement: 干净窗口验收

迁移至新能力 `spec-apply`(批次验收是执行期行为)。

### Requirement: 多仓分立提交

迁移至新能力 `spec-apply`(批次提交纪律是执行期行为)。

### Requirement: 执行期沉淀回流

迁移至新能力 `spec-apply`(清单由执行期收集,随终末汇报输出)。

### Requirement: 真实凭据纪律

迁移至新能力 `spec-apply`(执行与验证期纪律)。

### Requirement: 执行期留痕与工件维护

迁移至新能力 `spec-apply`。

### Requirement: 子代理与用户的交互中转(执行期)

迁移至新能力 `spec-apply`。

### Requirement: 栈识别与 writer skill 接线(执行侧)

迁移至新能力 `spec-apply`(栈识别产出仍由 spec-plan 落档,执行侧消费归 spec-apply)。

### Requirement: 隔离执行落点

迁移至新能力 `spec-apply`(执行期提交落点)。

### Requirement: 验证门与归档提交

迁移至 `spec-done`(归档链并入终末半程,前置反转为一体化;见 spec-done delta 的 ADDED)。

## MODIFIED Requirements

### Requirement: 固定工作流入口

系统 SHALL 提供全局 skill `spec-workflow` 与命令 `/spec-flow` 作为统一编排入口;命令 SHALL 接受需求描述、接续名、并行开关、模式、引擎与模型覆盖。编排 SHALL 四段委托:规划阶段(1→2)委托 skill `spec-plan` 完成至落档提交;执行半程(衔接完成后)委托 skill `spec-apply`;终末半程(验证归档与收尾闭环)由 skill `spec-done` 承载;本 skill 保留全流程编排、衔接与恢复路由。需求描述、并行开关与规划键模型覆盖 SHALL 原样转发,已预置项不重问,未给选项 SHALL 在对应阶段开始前询问,SHALL NOT 自行假设。

#### Scenario: 以需求描述新建流程

- **WHEN** 用户调用 `/spec-flow 给登录页加验证码`
- **THEN** 以该需求启动,先由 spec-plan 完成规划至落档提交,在需要时询问未给出的选项

#### Scenario: 未预置执行模式

- **WHEN** 调用命令时未携带执行模式参数
- **THEN** 流程在落档完成后的衔接点询问执行模式,而不是自行选择

#### Scenario: 规划参数转发

- **WHEN** 调用携带 `--parallel` 与规划键 `--model`
- **THEN** 参数原样转发给 spec-plan,规划按预置编排与路由执行,不重问

### Requirement: 落档到执行的衔接与恢复

落档提交完成后,编排层 SHALL 衔接:确认执行模式与引擎(未预置时)、决策执行环境——隔离判据命中 SHALL 推荐整批隔离、一次问清,`--worktree` 预置 SHALL 跳过;选定隔离 SHALL 创建并装配,执行环境块 SHALL 写入落档 design.md 决策记录(随衔接后首个批次提交);随后提示可切换模型或压缩上下文,并委托 spec-apply。恢复协议(任何时刻生效)SHALL 以工件+勾选态+提交历史三方对齐重建进度:勾选无验证证据 SHALL 回退未完成;提交对不上 SHALL 以现存 diff 为准(跑该任务验证句,通过保持勾选不重派);落档副本缺失且 /tmp 原件在 SHALL 补复制入变更目录,皆无 SHALL 问用户;有执行环境块 SHALL 以 `git worktree list` 核对——在则续用、缺失但分支在则重建装配、均无问用户。重建后 SHALL 判定当前段并路由:未落档回规划、执行中转 spec-apply、已归档转 spec-done;SHALL NOT 重跑已完成任务。

#### Scenario: 落档完成后衔接

- **WHEN** spec-plan 落档提交完成
- **THEN** 编排层确认执行模式与引擎(未预置时),决策执行环境,提示可切换模型或压缩上下文后委托 spec-apply

#### Scenario: 衔接点执行环境决策留痕

- **WHEN** 衔接点选定隔离执行
- **THEN** 执行环境块(仓→worktree 路径→分支+装配记录)写入落档 design.md 决策记录,随衔接后首个批次提交入库

#### Scenario: 压缩上下文后继续执行

- **WHEN** 用户在流程中段压缩上下文并指示继续
- **THEN** 三方对齐重建后判定当前段(规划/执行/终末)并路由到对应半程 skill,不重复已完成任务

#### Scenario: auto 中途恢复保留已完成任务

- **WHEN** auto 模式执行中途会话中断后恢复,且已勾选任务的改动仍在工作区未提交
- **THEN** 先对现存 diff 执行该任务的验证说明,通过即保持勾选、不重派执行子代理;不通过才回退该勾选并报告

#### Scenario: 恢复时补复制落档副本

- **WHEN** 恢复时变更目录缺 `code-design.md` 或 `diff-matrix.md`(串行 `decisions.md`)而 `/tmp/spec-flow/<change>/` 原件存在
- **THEN** 从原件补复制入变更目录并留痕,随下次批次提交;不以 /tmp 原件幸存为默认继续

#### Scenario: 恢复时重建缺失的 worktree

- **WHEN** 恢复核对发现执行环境块所述 worktree 缺失但 `feature/<change>` 分支仍在
- **THEN** 按记录的布局重建 worktree、补装配,并以三方对齐核对该仓进度后继续,不重跑已完成任务

### Requirement: 接续未完成变更

命令 SHALL 支持接续未完成变更:接续时 SHALL 跑恢复协议重建进度,跳过已完成的规划与落档(要求重跑除外;规划含阶段 1.7 设计线,仅用户明确要求时才重跑),SHALL 在执行前重新确认执行模式与引擎,并按恢复协议判定当前段路由到对应半程 skill 继续。

#### Scenario: 接续时重新确认模式

- **WHEN** 用户以 continue 参数接续某未完成变更
- **THEN** 从任务完成度恢复,在执行前重新询问执行模式,并路由到当前段对应半程 skill

### Requirement: 阶段级模型路由

编排层 SHALL 以共用映射文件 `dsh/spec-workflow.yaml` 为唯一路由配置源,键的消费分工 SHALL 为:规划键(`lineA`、`lineB`、`panel`、`design`)由 `spec-plan` 消费;执行键 `apply`、能力键 `vision` 与 `engine`/`parallelism` 由 `spec-apply` 消费;`verify` 由 `spec-done` 复用。每条路由 SHALL 支持可选 `fallback`;映射为空 SHALL 沿用会话模型;命令参数 SHALL 能覆盖主路由,命令中的规划键覆盖 SHALL 被原样转发;主会话阶段(衔接与编排)的模型由用户切换,编排层仅提示。

#### Scenario: 映射指定阶段模型

- **WHEN** 映射文件为任一半程键指定模型路由
- **THEN** 对应半程消费方按分工应用该路由,且该路由必须已在允许列表中

#### Scenario: 规划键覆盖被转发

- **WHEN** 命令携带规划键的 `--model` 覆盖
- **THEN** 编排层不消费该键,原样转发给 spec-plan

#### Scenario: 映射为空

- **WHEN** 映射文件未指定某阶段模型
- **THEN** 对应派发沿用会话模型

### Requirement: 读图覆盖与路由回退

共用映射文件 SHALL 额外支持能力键 `vision`:某阶段任务需图片输入(截图、设计稿等)而该阶段路由不支持时,消费方 SHALL 忽略阶段路由改用 `vision` 派发,SHALL NOT 重试原路由。显式路由(含 `fallback`)SHALL 是允许列表子集;主路由不可用(不在列表、报错或限流)时消费方 SHALL 依次回退:`fallback` 重派一次(若有)→ 继承会话模型派发一次 → 报告错误原文并暂停,SHALL NOT 反复重试。本条为各半程派发侧共用的回退规则总述,执行侧细则由 `spec-apply` 承载。

#### Scenario: 读图任务改用 vision 路由

- **WHEN** 某阶段任务需要图片输入而该阶段路由不支持
- **THEN** 改用 `vision` 派发,不重试原路由

#### Scenario: 主路由不可用时按备用路由回退

- **WHEN** 主路由不在允许列表或 provider 失败且该键有 `fallback`
- **THEN** 以 `fallback` 重派一次并说明

#### Scenario: 备用路由也不可用

- **WHEN** 主路由与 `fallback` 均派发失败
- **THEN** 继承会话模型派发一次,仍失败则报告错误原文并暂停

#### Scenario: 配置改动对既有会话未生效

- **WHEN** 派发报该会话模型选择不可用(开关与列表在会话创建时读取)
- **THEN** 提示新建会话后重试,说明这不是工具故障

### Requirement: 压缩后指令完整存活

编排层 skill SHALL 保证指令在压缩后完整可用:恢复协议、全局纪律、不得静默假设待决项等红线 SHALL 留在入口正文;规划与执行方法论 SHALL 由对应半程 skill 承载,入口 SHALL 仅保留委托指针、参数转发说明与判段路由指引;其余展开内容 SHALL 位于可按需读取的同 bundle 资源,入口 SHALL 提供定位它的路由指引;外移与路由 SHALL NOT 改变既有 Requirement 的行为语义。

#### Scenario: 压缩后红线内容仍可用

- **WHEN** 执行中压缩上下文(如落档后压缩再继续)
- **THEN** 恢复协议与全局红线仍完整存在于入口正文,流程经判段路由从工件与勾选态无损接续,不重复已完成任务

#### Scenario: 委托指针可定位规划能力

- **WHEN** 规划半程开始
- **THEN** 入口的委托指针足以按名加载 spec-plan 并转发参数,获得等价的规划指令

#### Scenario: 委托指针可定位执行与终末能力

- **WHEN** 执行或终末半程开始
- **THEN** 入口的委托指针足以按名加载 spec-apply 或 spec-done,衔接预置项随指针交接,获得等价指令

#### Scenario: 外移内容可按需读取

- **WHEN** 某阶段需要外移文件的指令(如衔接执行环境手册、失败处置)
- **THEN** 入口路由指引足以定位并读取该文件,获得与外移前等价的指令

#### Scenario: 外移不改变行为语义

- **WHEN** 指令被搬入资源文件或入口改写为骨架
- **THEN** 既有 Requirement 的行为语义与触发条件不变,skill 名称描述逐字节一致
