# smoke-testing-local-env Specification

## Purpose

本地环境端到端冒烟验证 skill（smoke-testing-local-env）的行为规程：把「先有用例库、再按编号逐项执行」固化为可判定的强制流程——用例是所测项目的长期资产（`smoke/cases.md`），执行产生独立运行目录（`smoke/runs/`），并区分全量 smoke 与单任务 smoke 两种模式。本 skill 此前无 spec 管辖，此为其首个能力规格。

## Requirements

### Requirement: 用例先行规程

skill SHALL 在「零侵入链路」与「数据准备」之间强制设置「准备测试用例」阶段：开测前，本次执行所选用的全部用例 MUST 已落盘在所测项目根 `smoke/cases.md`（库已存在则复用/筛选，缺失或覆盖不足则现场编写建立），且所选用例编号集 MUST 在执行前写入本次运行目录的 `record.md` 作为执行清单。用例未落库或编号集未落运行记录时 SHALL NOT 进入执行阶段。frontmatter 触发词 SHALL 覆盖全量冒烟、复测、回归、上线前验收场景。

#### Scenario: 库缺失时开测前建库

- **WHEN** 所测项目根不存在 `smoke/cases.md` 而用户要求冒烟某新功能
- **THEN** 先按验收要求与项目画像 §7 用例入口编写用例并落盘建库（含 `smoke/.gitignore`），再进入数据准备与执行；不得边测边补用例

#### Scenario: 库已存在时复测直接按库执行

- **WHEN** 项目已有 `smoke/cases.md` 且用户要求「复测/全量冒烟」
- **THEN** 不重写用例，直接取库内全部在用条目组织执行，编号集写入新运行目录的 `record.md`

### Requirement: 用例库资产契约

`smoke/cases.md` SHALL 为纯定义文件：表头固定七列（编号、用例、类型、前置、步骤、期望结果、证据要求），类型仅取「正/反」；编号采用 `<组>-<两位序号>`（组沿用能力组 A–G，如 `A-01`）且永不复用；用例废弃时 SHALL 保留原行并在用例列注「已废弃：<原因>」，MUST NOT 删除或复用编号；既有用例期望变化时 SHALL 原地修订该行（编号不变）；执行结果 MUST NOT 回填本文件。前置列 SHALL 引用项目画像条目而非复制其内容。

#### Scenario: 废弃用例保留编号

- **WHEN** 某 A-05 用例对应功能已下线
- **THEN** `cases.md` 中该行保留并在用例列标注「已废弃：功能下线」，后续新增用例编号从同组最大序号续接，不复用 A-05

#### Scenario: 运行结果只进运行记录

- **WHEN** 一次执行完成
- **THEN** 通过/失败/N/A 等结果与证据只出现在 `smoke/runs/<运行>/record.md`，`cases.md` 保持纯定义、历次执行互不覆盖

### Requirement: 运行目录契约

每次执行 SHALL 产生独立运行目录 `smoke/runs/<YYYY-MM-DD>-<full|任务号>/`：日期按项目画像 §0 业务时区取值；`full` 为全量固定字面量，任务号仅保留字母/数字/`.`/`-`（空格替换为 `-`）；同日同 scope 重复运行 SHALL 追加 `-2`、`-3` 后缀，MUST NOT 覆盖已有目录。目录内 `record.md`（逐项结果回填）与 `report.md`（结论报告，含分组汇总表）SHALL 入库；截图等二进制由 `smoke/.gitignore`（单层 glob、随建库创建）忽略；MUST NOT 修改所测项目根 `.gitignore`。`record.md` 结果值域 SHALL 固定为通过/失败/N/A/观察项四值，证据列使用相对本目录链接。

#### Scenario: 同日同 scope 重跑不覆盖

- **WHEN** `2026-11-19-full` 运行目录已存在且同日再次全量冒烟
- **THEN** 新运行目录命名为 `2026-11-19-full-2`，原目录的记录与证据保持不变

#### Scenario: 截图入库隔离

- **WHEN** 运行目录内产生 `A-01-login.png` 等截图
- **THEN** 由 `smoke/.gitignore` 的 `runs/*/*.png` 规则忽略不入库，`record.md` 中以相对链接引用；项目根 `.gitignore` 零改动

### Requirement: 全量与单任务双模式

skill SHALL 区分两种冒烟模式并按用户话术判定：含「全量冒烟/复测/回归/上线前验收」判定为全量；携带任务号或里程碑判定为单任务；话术歧义时 MUST 询问用户，MUST NOT 自行猜测。全量模式的用例范围为库内全部在用条目；单任务模式为受影响旧条目（回归）加本任务新用例，且收尾时新用例回写 `cases.md` 为**硬性要求**——未回写 SHALL 视为本次冒烟未完成。受影响条目 SHALL 按能力组启发式筛选（入口/接口/数据/共享组件对应能力组），编号集在执行前落运行记录并在用户在场时确认。

#### Scenario: 话术歧义必问

- **WHEN** 用户说「把 T2.1 全量再过一遍」同时含任务号与「全量」
- **THEN** 向用户确认本次是全量 smoke 还是 T2.1 单任务 smoke，确认前不建运行目录

#### Scenario: 单任务收尾强制回写

- **WHEN** 单任务冒烟执行中为某新能力编写了用例 C-08
- **THEN** 收尾阶段 MUST 将 C-08 回写进 `smoke/cases.md`（编号续接），验收口径判定「新用例未回写 = 未完成」

### Requirement: 逐项执行纪律

执行阶段 SHALL 按运行记录中的编号集顺序逐条执行：一次只执行一条，每条执行完 SHALL 立即回填结果与证据；单条失败 SHALL 记录后继续（环境阻断除外）；N/A MUST 写明原因与等效证据；执行中临场发现的补充用例 MUST 先补录进 `cases.md` 再执行。验收口径 SHALL 绑定用例库：冒烟通过 = 所选用例在运行记录中全部有结果且无失败项 + 三层证据齐全 + 工作区洁净（预期入库改动白名单内）+（单任务）新用例已回写；未写入用例库的项 MUST NOT 构成验收范围。

#### Scenario: 临场补充用例先落库

- **WHEN** 执行中发现一个未在编号集内的边界场景需要验证
- **THEN** 先将该场景按七列格式补录进 `cases.md` 取新编号，再把新编号追加进运行记录编号集后执行，不得凭空执行未入库用例

#### Scenario: 失败不中断整轮

- **WHEN** 用例 C-03 执行失败（对象存储不可达）
- **THEN** `record.md` 中 C-03 回填「失败」并注明阻塞原因后继续执行 C-04 及后续用例，除非失败源于环境阻断（此时终止并报告）

### Requirement: 归档与洁净核验兼容

归档默认 SHALL 为运行目录收纳（report.md 与 record.md 同目录、截图由 smoke/.gitignore 忽略）；既有 openspec artifacts 等存量约定降级为画像 §9 覆盖示例；`smoke/` 路径可被项目画像 §9 覆盖，但编号稳定、七列固定、结果只进运行记录三项 MUST NOT 被覆盖。工作区洁净核验 SHALL 增加「预期入库改动」白名单：`smoke/cases.md` 新增/修订、`smoke/runs/**/*.md`、首次建库的 `smoke/.gitignore` 属预期改动，其余入库文件改动仍按污染处理。

#### Scenario: 回写用例库不判为污染

- **WHEN** 单任务冒烟收尾时 `git status` 出现 `smoke/cases.md` 修改与 `smoke/runs/2026-11-19-T2.1/record.md` 新增
- **THEN** 两项均命中预期入库改动白名单，洁净核验通过；同仓出现的其他入库文件改动仍判为污染

### Requirement: 文档结构兼容约束

skill 三文档改造 SHALL 保持既有节号与行号引用有效：SKILL.md L1–60 仅允许 L3（description）与 L11（六阶段→七阶段概述）两处同行替换（行号零位移），L1–2/L4–10/L12–60 逐字节不变；reference.md L1–18 逐字节不变且既有节号一个不少（只新增 §6.1–§6.5）；`add-ui-demo-gate` 活跃变更对 `SKILL.md:30-34` 与 `reference.md:19` 的行号引用 SHALL 保持有效。

#### Scenario: 冻结区断言

- **WHEN** 改造完成后执行冻结区校验
- **THEN** SKILL.md L1–2、L4–10、L12–60 与 HEAD 逐字节一致，L30–34 独立校验一致，L1–60 行数仍为 60；reference.md 既有节号集合在新版中无缺失

### Requirement: 多字节字符口径

测试数据含中文、emoji 或生僻字时，skill SHALL 在数据准备阶段先确认 DB 字符集与各校验层计数单位：字符集为 `utf8`（utf8mb3）时，4 字节字符的报错或截断 SHALL 判为环境限制并记观察项，不得判为功能缺陷；长度边界用例 SHALL 按被测校验层单位（前端/Java 为 UTF-16 code unit，DB `VARCHAR`/`char_length` 为码点）取上限与上限+1，MUST NOT 跨层换算；落库断言 SHALL 查回多字节原值逐字符比对。

#### Scenario: utf8mb3 表写入 emoji

- **WHEN** 目标表字符集为 `utf8`（utf8mb3）而用例需写入 emoji 或生僻字
- **THEN** 插入报错或值被静默截断时判为环境限制，记观察项并写明影响面，不记为功能缺陷；确需覆盖该能力时向用户确认改表或换库

#### Scenario: 长度边界负例全不生效

- **WHEN** 「限 50 字」的边界负例误按字节构造（51 字节 ≈ 17 个汉字）而全部提交成功
- **THEN** 先确认校验层计数单位（前端/Java `length` 为 UTF-16 code unit），按该单位重构造上限+1（51 个汉字）再断言业务错误码，不得直接判为校验缺失
