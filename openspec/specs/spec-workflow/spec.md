# spec-workflow Specification

## Purpose

为 OpenSpec 项目提供一条固定、可重复、可审计的开发工作流：从两条相互独立的完整规划与差异收敛、规划落档，到由子代理执行的实现、验证与归档提交，全过程由统一入口驱动，支持并行协作、执行粒度选择与阶段级模型路由。

## Requirements

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

### Requirement: 入口与资源按单次加载完整交付

工作流 skill 的入口 SHALL 在单次按名加载内完整交付，每个外置资源文件 SHALL 在单次读取内完整交付——SHALL NOT 因宿主裁剪阈值丢失指令；入口与各资源文件 SHALL 各自控制在阈值内；骨架化、外移与节结构重组 SHALL NOT 改变既有 Requirement 的行为语义与触发条件。

#### Scenario: 单次加载得到完整入口

- **WHEN** 会话按名加载 skill（宿主 `skill` 工具返回入口正文）
- **THEN** 返回内容完整含红线最小集与按需读取路由指引，无指令被裁剪

#### Scenario: 资源文件独立完整交付

- **WHEN** 某阶段按入口路由读取任一资源文件
- **THEN** 该文件完整交付、不触发宿主裁剪，与外移前等价

#### Scenario: 骨架化不改变行为语义

- **WHEN** 入口改写为骨架、展开内容移入资源文件或节结构重组
- **THEN** 既有 Requirement 的行为语义与触发条件不变，重组后的节标题与 skill 名称描述一致

### Requirement: 子代理与用户的交互中转（执行期）

被父代理拥有的子代理 SHALL NOT 直接向用户提问（提问会被以 `DELEGATED_CALLER` 拒绝），工作流 SHALL 提供中转式交互：执行任务的子代理 SHALL 把需拍板的决策（问题、选项、推荐、影响面）写入产物并在回执中上浮，SHALL NOT 自行假设；主会话 SHALL 当批次即时代问（≤5 问/轮、附推荐），SHALL NOT 为等答复阻塞或轮询；回送 SHALL 按引擎：team 回送同一成员（可多轮），subagent 以上轮回执摘要 + 答复接续重派；用户授权「按假设清单推进」时 SHALL 跳过代问并标注。

#### Scenario: 执行子代理上浮待决问题

- **WHEN** 执行子代理遇到需用户拍板的决策
- **THEN** 它不自行假设，写入产物与回执上浮；主会话当批次即时代问

#### Scenario: subagent 引擎接续重派

- **WHEN** 用户在 subagent 引擎下答复上浮问题
- **THEN** 把上轮回执摘要与答复并入新提示接续推进，不等待原实例

#### Scenario: team 引擎同实例多轮澄清

- **WHEN** team 引擎下某成员上浮待决策问题
- **THEN** Lead 代问后以消息回送该成员，成员在原上下文中继续，可多轮往返

#### Scenario: 授权假设清单推进

- **WHEN** 用户明确授权「按假设清单推进」
- **THEN** 跳过代问，产物与回执标注「已授权的假设清单」

### Requirement: 栈识别与 writer skill 接线（执行侧）

工作流 SHALL 在阶段 3 执行派发时按落档 `design.md` 决策记录读取栈识别结论（writer skill 名与证据，由 spec-plan 落档写入），执行子代理提示与 team 任务卡 SHALL 点名先加载同一 writer skill 并以其规范为硬约束（豁免时注明依据）；结论无从取得（接续恢复后丢失）时 SHALL 重识别一次并更新落档记录；加载失败 SHALL 按失败处置顺序修复，仍失败 SHALL 报告问用户且 SHALL NOT 静默降级。

#### Scenario: 执行提示携带设计要点与加载指令

- **WHEN** 阶段 3 派发执行任务子代理
- **THEN** 其提示逐字引用 design 该组实现要点，并按 design.md 决策记录点名先加载同一 writer skill

#### Scenario: 任务卡含 writer skill 加载指令

- **WHEN** 以 team 引擎发布批次任务卡
- **THEN** 每张卡点名先加载同一 writer skill，与 subagent 引擎同款接线

#### Scenario: 结论无从取得时重识别

- **WHEN** 接续恢复后 design.md 决策记录缺失栈识别结论
- **THEN** 主会话重识别一次，更新落档记录并如实标注

#### Scenario: writer skill 加载失败上浮

- **WHEN** 派发前核对或子代理回执发现 writer skill 不可加载
- **THEN** 按失败处置顺序（登记核对 → `/commands-reload` → 重启兜底）修复，仍失败则报告问用户，不静默降级

### Requirement: 执行环境隔离决策

衔接点工作流 SHALL 决策执行环境（隔离或直用主工作区）：判据（主工作区有与本变更无关的未提交改动、主工作区检出其他进行中分支、存在并行变更 worktree、用户明示）命中任一 SHALL 推荐隔离；决策 SHALL 整批统一——一次询问覆盖全部触达代码仓，SHALL NOT 按仓拆问；`--worktree` 参数预置 SHALL 跳过询问。决策与布局 SHALL 写入落档 design.md 决策记录「执行环境」块（仓→worktree 路径→分支+装配记录，schema 权威源为 skill 的 worktree 手册），随衔接后首个批次提交入库。

#### Scenario: 判据命中推荐隔离

- **WHEN** 衔接点执行环境决策时主工作区存在与本变更无关的未提交改动
- **THEN** 推荐隔离并询问；选定后执行环境块写入 design.md 决策记录，随衔接后首个批次提交入库

#### Scenario: 整批统一决策

- **WHEN** 多仓触达且选定隔离
- **THEN** 一次询问覆盖全部触达代码仓后整批隔离，不按仓拆问；`--worktree` 预置时跳过询问

### Requirement: worktree 布局与创建装配

隔离 SHALL 采用统一布局：多仓 `<根仓>/.worktrees/<change>/<子仓目录名>`、单仓 `.worktrees/<change>`，分支 SHALL 为 `feature/<change>`（用户指定布局时从之）。创建 SHALL 一次性覆盖全部触达代码仓，根仓（工件仓）SHALL NOT 建 worktree；`.worktrees/` SHALL 确认被该仓 ignore（缺失补一行随首批次提交）；创建后、首个派发前 SHALL 按栈装配依赖（node：worktree 内 `pnpm install`；java：`./gradlew` 即用）。分支已被其他 worktree 检出时 SHALL 换路径或问用户，SHALL NOT 强拆。

#### Scenario: worktree 布局默认与装配

- **WHEN** 用户未指定布局且选定隔离
- **THEN** 多仓用 `<根仓>/.worktrees/<change>/<子仓目录名>`、单仓用 `.worktrees/<change>`、分支 `feature/<change>`，`.worktrees/` 已 ignore；创建后按栈装配依赖再进首个派发

#### Scenario: 分支被其他 worktree 检出

- **WHEN** 创建或重建 worktree 时 `feature/<change>` 已被其他 worktree 检出
- **THEN** 换 worktree 路径或问用户，不强拆他人检出

### Requirement: 本地配置复制与环境错开

装配期工作流 SHALL 从各代码仓主检出复制本地配置文件（`.env`、`application-local.yml` 等项目本地配置）进对应 worktree 并改写端口与数据库连接：端口每项按固定公式 `默认值 + 100 × n` 自动写入（n = 创建时根仓 `.worktrees/` 下其他并行变更目录数），SHALL NOT 逐项询问；带 migration 的数据库 SHALL 同实例建独立 database（`<原库名>_wt<n>`，装配期 CREATE DATABASE IF NOT EXISTS，基线=项目声明优先、缺省空库由 migration 全量重放）；redis 等无 schema 冲突中间件 SHALL NOT 自动隔离；端口、库名实际值与入库配置改动清单 SHALL 记入执行环境块，恢复/重建 SHALL 按块中值重写副本。

#### Scenario: 本地配置复制与端口错开

- **WHEN** worktree 创建后进入装配
- **THEN** 不入库本地配置从主检出复制进 worktree，端口项按 `默认值 + 100 × n` 自动改写不询问，实际值记入执行环境块

#### Scenario: 数据库独立库隔离

- **WHEN** 项目使用带 migration 的数据库（如 mysql）
- **THEN** 同实例建 `<原库名>_wt<n>` 独立 database 并改写连接串，基线按项目声明、无声明空库由该分支 migration 全量重放

#### Scenario: 入库配置改副本不提交

- **WHEN** 本地配置文件在某仓入库（改动会出现在 git status）
- **THEN** 改工作副本但不提交，改动文件清单记入执行环境块，收尾删 worktree 前还原

#### Scenario: 恢复按执行环境块重写

- **WHEN** 恢复或重建 worktree 时的装配核对
- **THEN** 按执行环境块记录的端口与库名重写本地配置副本，不重新分配
