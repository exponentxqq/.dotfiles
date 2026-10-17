# Spec Delta

## Purpose

spec 驱动工作流的执行半程:落档后的批次执行——双引擎(subagent/team)、三模式(auto/step-task/step-group)、核对与审核-提交分离、执行期留痕与工件维护、隔离执行落点;从落档工件与提交历史重建执行进度,可被编排层委托或经 `/spec-apply` 独立进入。

## ADDED Requirements

### Requirement: 执行入口与编排委托

系统 SHALL 提供全局 skill `spec-apply` 与命令 `/spec-apply <变更名>` 作为执行半程入口:可被 `spec-workflow` 编排层在衔接完成后委托进入,也可独立进入。独立进入 SHALL 先校验变更已落档(变更目录四件套存在且 tasks.md 非空),未落档 SHALL 指回规划;进入后从最小编号未完成组继续;执行模式与引擎未知 SHALL 先询问,SHALL NOT 自行假设。

#### Scenario: 独立入口直达执行

- **WHEN** 用户对已落档变更调用 `/spec-apply <变更名>`
- **THEN** 校验落档事实后从最小编号未完成组继续执行,不重跑已完成任务

#### Scenario: 未落档指回规划

- **WHEN** `/spec-apply` 指向的变更 tasks.md 为空或变更目录不存在
- **THEN** 提示先完成规划落档,不进入执行

#### Scenario: 编排层委托进入

- **WHEN** spec-workflow 衔接完成(模式/引擎确认、执行环境就绪)
- **THEN** 委托 spec-apply 按衔接预置项执行,已预置项不重问

### Requirement: subagent 执行引擎

默认引擎 SHALL 为 subagent:每任务由独立全新子代理完成,提示 SHALL 自包含(任务描述、验收标准、design 该组实现要点逐字引用、其触达文件写范围、栈对应 writer skill 加载指令——沿用阶段 1.7 栈识别结论点名 skill 名,豁免时注明依据);同组可并行、组间串行;主会话 SHALL 以验证说明与变更差异核对通过后才标记完成。执行子代理遇需拍板决策 SHALL 按「子代理与用户的交互中转」上浮并接续重派,SHALL NOT 因等待答复阻塞或自行假设。

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

### Requirement: team 执行引擎

执行半程 SHALL 支持可选 team 引擎:Lead 把批次发布到共享任务板,每批次创建具名 implementer 认领,成员数 SHALL ≤该批次任务数;任务卡 SHALL 含与 subagent 引擎同款的栈对应 writer skill 加载指令;审核反馈 SHALL 以消息送达对应成员以保留上下文;成员待决问题 SHALL 由 Lead 代问后回送同一成员;该引擎下成员模型不参与阶段级模型路由。

#### Scenario: 逐 task 审核下修复

- **WHEN** 用户在 team 审核点要求修改某任务产出
- **THEN** Lead 把修改要求以消息发给负责成员,由其在原上下文内修复

#### Scenario: 任务卡含 writer skill 加载指令

- **WHEN** 阶段 1.7 已加载栈对应 writer skill 且以 team 引擎发布批次任务卡
- **THEN** 每张卡点名先加载同一 writer skill,与 subagent 引擎同款接线

#### Scenario: 成员不可用

- **WHEN** 某 implementer 创建失败或长时间无进展
- **THEN** Lead 中断或重建;无法恢复时降级 subagent 完成该任务

### Requirement: 执行模式与提交节奏

执行半程 SHALL 支持三种执行模式:auto(连续执行全部批次,不在批次之间询问进度)、step-task(每任务后停留审核)、step-group(每批次后停留审核)。停留 SHALL 呈现证据(批次号、任务号、改动文件、验证输出摘要、diff stat)并等待用户确认——主会话核对通过 SHALL NOT 等同于审核通过;任何模式 SHALL NOT 在用户审核确认前提交实现改动,auto SHALL 在全部批次完成后停留呈证等待确认(用户明确豁免审核时除外);引擎 SHALL 允许批次间切换(含 team↔subagent)并将切换与原因留痕;每批次经审核确认后 SHALL 单独提交一次。

#### Scenario: 逐 task 审核的提交

- **WHEN** step-task 模式下某批次通过用户审核
- **THEN** 该批次单独产生一次提交

#### Scenario: 审核点呈现证据等确认

- **WHEN** 某批次核对完成进入停留点
- **THEN** 呈现批次号、任务号、改动文件、验证输出摘要与 diff stat,等待用户确认,不代行提交

#### Scenario: 连续执行不打断

- **WHEN** auto 模式执行中不存在不可逆操作、安全敏感动作、工作区外副作用或计划彻底失效
- **THEN** 不在批次之间询问是否继续,直至全部批次完成后停留呈证

#### Scenario: auto 完成后不自动提交

- **WHEN** auto 模式全部批次完成
- **THEN** 停留呈现证据等待用户审核确认,确认后才提交;用户明确豁免审核时除外

#### Scenario: 引擎批次间切换

- **WHEN** 用户要求自某批次起改用另一引擎
- **THEN** 自该批次起按新引擎派发,并把切换与原因留痕

### Requirement: 干净窗口验收

执行半程 SHALL 在宣称批次验证通过前做干净窗口确认:①确认无并发构建/测试进程;②确认验证任务真实执行——输出 SHALL NOT 含被跳过(SKIPPED)的验证任务,且任务计数为 executed 而非命中缓存或空转。并发工具会使验证任务被静默跳过而整体仍报成功,SHALL NOT 仅凭构建成功字样判定通过。

#### Scenario: 并发构建的静默跳过被拦截

- **WHEN** 验收窗口内存在其他并发构建/测试进程
- **THEN** 先等待或重跑,确认无并发后再核验,不以单次成功输出判定通过

#### Scenario: 干净窗口验收通过

- **WHEN** 无并发进程且验证任务全部 executed、无 SKIPPED
- **THEN** 该验收证据可作为批次核对与勾选依据

### Requirement: 多仓分立提交

目标项目涉及多个独立 git 仓(嵌套独立子仓、工作区外独立仓)时,提交 SHALL 分仓进行:代码、工件、生成物各归其仓,N 仓 SHALL 各自形成完整、可独立回溯的提交,SHALL NOT 跨仓混提或以单仓提交覆盖另一仓改动。执行期需求波及工作区外独立仓 SHALL 先停下回用户(呈证点呈报或按硬停条件),用户明示后改动 SHALL 随该仓提交并以留痕注明外溢。

#### Scenario: 双仓分别提交

- **WHEN** 某批次同时产出子仓代码改动与根仓工件改动
- **THEN** 两仓分别显式 add 并各自提交,提交信息各自描述本仓改动

#### Scenario: 外部独立仓外溢经用户明示

- **WHEN** 执行期需求波及工作区外独立仓
- **THEN** 停下呈报等用户明示;明示后改动随该仓提交、留痕注明外溢,不并入目标项目仓

### Requirement: 执行期沉淀回流

执行半程 SHALL 在执行期收集沉淀回流清单:执行期改动的工作流仓文件(skill 文本、工作流配置)逐条列明——已提交项标注去向、未提交项交用户决定提交与方式;执行半程 SHALL NOT 代为提交工作流仓;清单 SHALL 随终末汇报(由 spec-done 归档六要素承载)输出。

#### Scenario: 沉淀回流清单随终末汇报输出

- **WHEN** 终末(归档)汇报输出
- **THEN** 含执行期收集的沉淀回流清单(已提交项标注去向一行、未提交项列明),由用户决定提交,执行半程不代提交

### Requirement: 真实凭据纪律

执行与验证需要的真实密钥 SHALL 只经命令行参数或环境变量传入进程,SHALL NOT 写入任何入库文件、工件、日志或提交信息;依赖真实凭据的验证在凭据缺失时 SHALL 以明确报错失败(如提示缺少参数),SHALL NOT 静默跳过或伪造结果。

#### Scenario: 凭据只经参数传入

- **WHEN** 冒烟或验证需要真实密钥
- **THEN** 密钥经 `-P` 参数或环境变量传入进程,任何提交内容与日志中零出现

#### Scenario: 缺凭据明确失败

- **WHEN** 未提供所需密钥
- **THEN** 验证以「缺少参数」类明确报错退出,不静默跳过、不伪造结果

### Requirement: 执行期留痕与工件维护

每组收尾 SHALL 先核对本组任务全部勾选(漏勾先补跑该任务验证说明核对再勾)才进工件维护与停留呈证,并 SHALL 把变更工件同步到终态:`code-design.md` 对应任务组段 SHALL 更新为终形态(含实测事实、被否方案与验收数据),组段终形态化以落档副本在变更目录为前提,缺失 SHALL 按恢复协议处置,SHALL NOT 以 /tmp 原件替代维护;执行期新证实的项目级运行规则 SHALL 以编号条目留痕(tasks.md 附录或 diff-matrix 执行期章),条目 SHALL 自包含(规则、依据、适用范围、连锁面清单),推翻前裁定 SHALL 在前条标注并重跑连锁同步;过程证据 SHALL 落易失目录,不入库不进提交。

#### Scenario: 组段终形态化

- **WHEN** 某组任务完成核对
- **THEN** code-design.md 该组段更新为终形态,记录实测事实与验收数据

#### Scenario: 组收尾勾选核对

- **WHEN** 某组全部任务核对完成进入收尾
- **THEN** 先确认本组任务全部勾选(漏勾先补核对验证说明再勾),再进工件维护与呈证

#### Scenario: 留痕条目含连锁面

- **WHEN** 执行期以 R<n> 编号留痕新证实的运行规则
- **THEN** 条目含规则、依据、适用范围与连锁面清单;后续条目推翻它时前条标注「被 R<n'> 推翻」并重跑连锁同步

#### Scenario: 证据不入库

- **WHEN** 生成过程证据文件
- **THEN** 落 /tmp 易失目录,仅结论摘要进留痕,提交内容不含证据文件

### Requirement: 子代理与用户的交互中转(执行期)

被父代理拥有的子代理 SHALL NOT 直接向用户提问(提问会被以 `DELEGATED_CALLER` 拒绝),执行半程 SHALL 提供中转式交互:执行任务的子代理 SHALL 把需拍板的决策(问题、选项、推荐、影响面)写入产物并在回执中上浮,SHALL NOT 自行假设;主会话 SHALL 当批次即时代问(≤5 问/轮、附推荐),SHALL NOT 为等答复阻塞或轮询;回送 SHALL 按引擎:team 回送同一成员(可多轮),subagent 以上轮回执摘要+答复接续重派;用户授权「按假设清单推进」时 SHALL 跳过代问并标注。

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

### Requirement: 栈识别与 writer skill 接线(执行侧)

执行半程 SHALL 在派发时按落档 `design.md` 决策记录读取栈识别结论(writer skill 名与证据,由 spec-plan 落档写入),执行子代理提示与 team 任务卡 SHALL 点名先加载同一 writer skill 并以其规范为硬约束(豁免时注明依据);结论无从取得(接续恢复后丢失)时 SHALL 重识别一次并更新落档记录;加载失败 SHALL 按失败处置顺序修复,仍失败 SHALL 报告问用户且 SHALL NOT 静默降级。

#### Scenario: 执行提示携带设计要点与加载指令

- **WHEN** 派发执行任务子代理
- **THEN** 其提示逐字引用 design 该组实现要点,并按 design.md 决策记录点名先加载同一 writer skill

#### Scenario: 任务卡含 writer skill 加载指令

- **WHEN** 以 team 引擎发布批次任务卡
- **THEN** 每张卡点名先加载同一 writer skill,与 subagent 引擎同款接线

#### Scenario: 结论无从取得时重识别

- **WHEN** 接续恢复后 design.md 决策记录缺失栈识别结论
- **THEN** 主会话重识别一次,更新落档记录并如实标注

#### Scenario: writer skill 加载失败上浮

- **WHEN** 派发前核对或子代理回执发现 writer skill 不可加载
- **THEN** 按失败处置顺序(登记核对→`/commands-reload`→重启兜底)修复,仍失败则报告问用户,不静默降级

### Requirement: 隔离执行落点

隔离执行期,子代理提示的项目根与验证句执行目录 SHALL 为 worktree 路径;代码批次提交 SHALL 落 worktree 的 `feature/<change>` 分支、工件提交 SHALL 落根仓主工作区(多仓分立提交不变)。

#### Scenario: 隔离执行的提交落点

- **WHEN** 隔离执行批次核对通过且用户审核确认提交
- **THEN** 代码提交落在该代码仓 worktree 检出的 feature 分支,工件提交落在根仓主工作区,N 仓各自完整提交不跨仓混提

### Requirement: 执行侧模型路由

执行半程 SHALL 从共用映射文件 `dsh/spec-workflow.yaml` 读取执行侧配置并在派发时应用:键 `apply` 对应执行任务子代理,能力键 `vision` 对应读图覆盖,`engine`/`parallelism` 为引擎与并行度偏好;显式路由 SHALL 是允许列表子集,映射为空 SHALL 沿用会话模型,命令参数 SHALL 能覆盖主路由;主路由不可用 SHALL 按共用回退顺序处置(fallback 重派一次→继承会话模型一次→报告原文并暂停),SHALL NOT 反复重试;team 引擎下 SHALL 忽略 `apply` 键。

#### Scenario: 映射指定执行模型

- **WHEN** 映射文件为 apply 指定模型路由
- **THEN** 执行子代理使用该模型,且该路由已在允许列表中

#### Scenario: 映射为空

- **WHEN** 映射文件未指定执行阶段模型
- **THEN** 派发的子代理沿用会话模型

#### Scenario: team 引擎忽略 apply 键

- **WHEN** 以 team 引擎派发且映射含 apply 路由
- **THEN** 成员模型不应用该路由(该引擎下阶段级路由整体不适用)

### Requirement: 压缩后指令完整存活

spec-apply SHALL 保证指令在压缩后完整可用:批次循环骨架、核对纪律(验证句+diff 核对通过才勾选)、审核-提交分离、不得静默假设待决项等红线 SHALL 留在入口正文;引擎细节 SHALL 位于可按需读取的同 bundle 资源,入口 SHALL 提供定位它的路由指引;外移与路由 SHALL NOT 改变行为语义。

#### Scenario: 压缩后红线内容仍可用

- **WHEN** 执行中压缩上下文
- **THEN** 批次骨架与核对红线仍完整存在于入口正文,从工件与勾选态无损接续,不重复已完成任务

#### Scenario: 外移内容可按需读取

- **WHEN** 派发前需要引擎细节(提示模板、回执格式、路由回退)
- **THEN** 入口路由指引足以定位并读取对应资源文件,获得等价指令

### Requirement: 入口与资源按单次加载完整交付

spec-apply 的入口 SHALL 在单次按名加载内完整交付,每个外置资源文件 SHALL 在单次读取内完整交付——SHALL NOT 因宿主裁剪阈值丢失指令;入口与各资源文件 SHALL 各自控制在阈值内;外移与节结构重组 SHALL NOT 改变行为语义与触发条件。

#### Scenario: 单次加载得到完整入口

- **WHEN** 会话按名加载 spec-apply
- **THEN** 返回内容完整含红线最小集与按需读取路由指引,无指令被裁剪

#### Scenario: 资源文件独立完整交付

- **WHEN** 按入口路由读取任一资源文件
- **THEN** 该文件完整交付、不触发宿主裁剪,与外移前等价
