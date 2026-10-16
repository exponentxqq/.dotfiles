# spec-workflow Specification

## Purpose

为 OpenSpec 项目提供一条固定、可重复、可审计的开发工作流：从两条相互独立的完整规划与差异收敛、规划落档，到由子代理执行的实现、验证与归档提交，全过程由统一入口驱动，支持并行协作、执行粒度选择与阶段级模型路由。

## Requirements

### Requirement: 固定工作流入口

系统 SHALL 提供全局 skill `spec-workflow` 与命令 `/spec-flow` 作为统一入口；命令 SHALL 接受需求描述、接续名、并行开关、模式、引擎与模型覆盖；规划阶段（1→2）SHALL 委托 skill `spec-plan` 完成至落档提交——需求描述、并行开关与规划键模型覆盖 SHALL 原样转发，已预置项不重问；未给选项 SHALL 在对应阶段开始前询问，不得自行假设。

#### Scenario: 以需求描述新建流程

- **WHEN** 用户调用 `/spec-flow 给登录页加验证码`
- **THEN** 以该需求启动，先由 spec-plan 完成规划至落档提交，在需要时询问未给出的选项

#### Scenario: 未预置执行模式

- **WHEN** 调用命令时未携带执行模式参数
- **THEN** 流程在落档完成后询问执行模式，而不是自行选择

#### Scenario: 规划参数转发

- **WHEN** 调用携带 `--parallel` 与规划键 `--model`
- **THEN** 参数原样转发给 spec-plan，规划按预置编排与路由执行，不重问

### Requirement: 落档到执行的衔接与恢复

spec-plan 落档提交完成后，工作流 SHALL 确认执行模式与引擎（未预置时），随后 SHALL 提示可在执行前切换模型或压缩上下文；工作流 SHALL 以工件与任务完成度作为唯一进度载体，使压缩或会话重启后可无损恢复；恢复时勾选态与提交历史不一致 SHALL 以现存改动证据为准——先对已完成任务的现存 diff 执行其验证说明，通过即保持勾选且不重派执行子代理（`auto` 模式收尾才提交，中途恢复时已完成任务的改动尚未提交属预期），不通过才回退为未完成并报告。

#### Scenario: 落档完成后衔接

- **WHEN** spec-plan 落档提交完成
- **THEN** 工作流确认执行模式与引擎（未预置时），并提示可切换模型或压缩上下文后再继续

#### Scenario: 压缩上下文后继续执行

- **WHEN** 用户在落档后压缩上下文并指示继续
- **THEN** 从工件与任务完成度重建进度并继续，不重复已完成任务

#### Scenario: auto 中途恢复保留已完成任务

- **WHEN** auto 模式执行中途会话中断后恢复，且已勾选任务的改动仍在工作区未提交
- **THEN** 先对现存 diff 执行该任务的验证说明，通过即保持勾选、不重派执行子代理；不通过才回退该勾选并报告

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

### Requirement: 执行模式与提交节奏

工作流 SHALL 支持三种执行模式：auto（连续执行全部批次，不在批次之间询问进度）、step-task（每任务后停留审核）、step-group（每批次后停留审核）。停留 SHALL 呈现证据（批次号、任务号、改动文件、验证输出摘要、diff stat）并等待用户确认——主会话核对通过 SHALL NOT 等同于审核通过；任何模式 SHALL NOT 在用户审核确认前提交实现改动，auto SHALL 在全部批次完成后停留呈证等待确认（用户明确豁免审核时除外）；引擎 SHALL 允许批次间切换（含 team↔subagent）并将切换与原因留痕。落档工件与归档各自单独提交一次。

#### Scenario: 逐 task 审核的提交

- **WHEN** step-task 模式下某批次通过用户审核
- **THEN** 该批次单独产生一次提交

#### Scenario: 审核点呈现证据等确认

- **WHEN** 某批次核对完成进入停留点
- **THEN** 呈现批次号、任务号、改动文件、验证输出摘要与 diff stat，等待用户确认，不代行提交

#### Scenario: 连续执行不打断

- **WHEN** auto 模式执行中不存在不可逆操作、安全敏感动作、工作区外副作用或计划彻底失效
- **THEN** 不在批次之间询问是否继续，直至全部批次完成后停留呈证

#### Scenario: auto 完成后不自动提交

- **WHEN** auto 模式全部批次完成
- **THEN** 停留呈现证据等待用户审核确认，确认后才提交；用户明确豁免审核时除外

#### Scenario: 引擎批次间切换

- **WHEN** 用户要求自某批次起改用另一引擎
- **THEN** 自该批次起按新引擎派发，并把切换与原因留痕

### Requirement: 接续未完成变更

命令 SHALL 支持接续未完成变更；接续时 SHALL 跳过已完成的规划与落档（要求重跑除外），SHALL 在执行前重新确认执行模式与引擎。

#### Scenario: 接续时重新确认模式
- **WHEN** 用户以 continue 参数接续某未完成变更
- **THEN**从任务完成度恢复，在执行前重新询问执行模式

### Requirement: 验证门与归档提交

全部任务完成后 SHALL 先执行项目声明的验证；通过后 SHALL 归档变更并同步主规格，归档 SHALL 单独提交一次；验证失败 SHALL NOT 归档。

#### Scenario: 验证失败不归档
- **WHEN** 归档前验证失败
- **THEN**不归档，报告失败并等待用户决定跳过或修复

### Requirement: 阶段级模型路由

工作流 SHALL 从共用映射文件读取执行阶段路由（键 `apply`、`verify` 依次对应阶段 3 执行、阶段 4 归档前验证）并在派发时应用；规划键（`lineA`、`lineB`、`panel`、`design`）的规划侧消费 SHALL 由 `spec-plan` 承载，命令中的规划键模型覆盖 SHALL 被原样转发；每条路由 SHALL 支持可选 `fallback`；映射为空 SHALL 沿用会话模型；命令参数 SHALL 能覆盖主路由；主会话阶段（归档）的模型由用户切换，工作流仅提示。

#### Scenario: 映射指定阶段模型

- **WHEN** 映射文件为 apply 或 verify 指定模型路由
- **THEN** 对应阶段子代理使用该模型，且该路由必须已在允许列表中

#### Scenario: 映射为空

- **WHEN** 映射文件未指定执行阶段模型
- **THEN** 派发的子代理沿用会话模型

#### Scenario: 规划键覆盖被转发

- **WHEN** 命令携带规划键的 `--model` 覆盖
- **THEN** 工作流不消费该键，原样转发给 spec-plan

### Requirement: 读图覆盖与路由回退

映射文件 SHALL 额外支持能力键 `vision`：某阶段任务需图片输入（截图、设计稿等）而该阶段路由不支持时，SHALL 忽略阶段路由改用 `vision` 派发，SHALL NOT 重试原路由。显式路由（含 `fallback`）SHALL 是允许列表子集；主路由不可用（不在列表、报错或限流）时 SHALL 依次回退：`fallback` 重派一次（若有）→ 继承会话模型派发一次 → 报告错误原文并暂停，SHALL NOT 反复重试。

#### Scenario: 读图任务改用 vision 路由
- **WHEN** 某阶段任务需要图片输入而该阶段路由不支持
- **THEN**改用 `vision` 派发，不重试原路由

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

工作流 skill SHALL 保证指令在压缩后完整可用：压缩后继续所必需的红线（恢复协议、全局纪律、不得静默假设待决项）SHALL 留在入口正文；规划方法论 SHALL 由 `spec-plan` 承载，入口 SHALL 仅保留委托指针及其参数转发说明；其余执行指令 SHALL 位于可按需读取的同 bundle 资源，入口 SHALL 提供定位它的路由指引；外移与路由 SHALL NOT 改变既有 Requirement 的行为语义。

#### Scenario: 压缩后红线内容仍可用

- **WHEN** 执行中压缩上下文（如落档后压缩再继续）
- **THEN** 恢复协议与全局红线仍完整存在于入口正文，流程从工件与勾选态无损接续，不重复已完成任务

#### Scenario: 外移内容可按需读取

- **WHEN** 某阶段需要外移文件的指令（如模型路由、失败处置、引擎提示模板）
- **THEN** 入口路由指引足以定位并读取该文件，获得与外移前等价的指令

#### Scenario: 委托指针可定位规划能力

- **WHEN** 规划阶段开始
- **THEN** 入口的委托指针足以按名加载 spec-plan 并转发参数，获得等价的规划指令

#### Scenario: 外移不改变行为语义

- **WHEN** 指令被搬入资源文件或入口改写为骨架
- **THEN** 既有 Requirement 的行为语义与触发条件不变，skill 名称描述逐字节一致

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

### Requirement: 干净窗口验收

工作流 SHALL 在宣称批次验证通过前做干净窗口确认：①确认无并发构建/测试进程；②确认验证任务真实执行——输出 SHALL NOT 含被跳过（SKIPPED）的验证任务，且任务计数为 executed 而非命中缓存或空转。并发工具会使验证任务被静默跳过而整体仍报成功，SHALL NOT 仅凭构建成功字样判定通过。

#### Scenario: 并发构建的静默跳过被拦截

- **WHEN** 验收窗口内存在其他并发构建/测试进程
- **THEN** 先等待或重跑，确认无并发后再核验，不以单次成功输出判定通过

#### Scenario: 干净窗口验收通过

- **WHEN** 无并发进程且验证任务全部 executed、无 SKIPPED
- **THEN** 该验收证据可作为批次核对与勾选依据

### Requirement: 嵌套子仓提交

目标项目含嵌套独立 git 子仓（如根仓承载 openspec 工件、子仓承载代码）时，提交 SHALL 分仓进行：代码改动提交至其所属子仓，工件改动提交至工件仓；两仓 SHALL 各自形成完整、可独立回溯的提交，SHALL NOT 跨仓混提或以单仓提交覆盖另一仓改动。

#### Scenario: 双仓分别提交

- **WHEN** 某批次同时产出子仓代码改动与根仓工件改动
- **THEN** 两仓分别显式 add 并各自提交，提交信息各自描述本仓改动

### Requirement: 真实凭据纪律

执行与验证需要的真实密钥 SHALL 只经命令行参数或环境变量传入进程，SHALL NOT 写入任何入库文件、工件、日志或提交信息；依赖真实凭据的验证在凭据缺失时 SHALL 以明确报错失败（如提示缺少参数），SHALL NOT 静默跳过或伪造结果。

#### Scenario: 凭据只经参数传入

- **WHEN** 冒烟或验证需要真实密钥
- **THEN** 密钥经 `-P` 参数或环境变量传入进程，任何提交内容与日志中零出现

#### Scenario: 缺凭据明确失败

- **WHEN** 未提供所需密钥
- **THEN** 验证以「缺少参数」类明确报错退出，不静默跳过、不伪造结果

### Requirement: 执行期留痕与工件维护

每组收尾 SHALL 把变更工件同步到终态：`code-design.md` 对应任务组段 SHALL 更新为终形态（含实测事实、被否方案与验收数据）；执行期新证实的项目级运行规则 SHALL 以编号条目留痕（tasks.md 附录或 diff-matrix 执行期章）；过程证据 SHALL 落易失目录（如 `/tmp/<项目>-evidence/`），不入库、不进提交，结论摘要进留痕。

#### Scenario: 组段终形态化

- **WHEN** 某组任务完成核对
- **THEN** code-design.md 该组段更新为终形态，记录实测事实与验收数据

#### Scenario: 运行规则编号留痕

- **WHEN** 执行中确立新的项目级运行规则
- **THEN** 以编号条目写入 tasks.md 附录或 diff-matrix 执行期章，供后续组与接续引用

#### Scenario: 证据不入库

- **WHEN** 生成过程证据文件
- **THEN** 落 /tmp 易失目录，仅结论摘要进留痕，提交内容不含证据文件

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
