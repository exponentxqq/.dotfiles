# Spec Delta

## MODIFIED Requirements

### Requirement: 阶段 1.7 代码设计线

spec-plan SHALL 在阶段 1.5 收敛后、落档前执行代码设计线：SHALL 派全新子代理（`design` 路由，不随阶段 1 编排模式变化），读需求原文、两线草案与收敛记录，产出深度契约约束的设计草案——内容 SHALL 覆盖触达面清单（路径、所属仓与意图——每条逐文件路径 SHALL 注明所属仓：根仓或子仓名）、证据锚（每模块 ≥1 条 file:line，新建文件标注）、接口与数据形状、决策记录（附被否方案与理由）、逐任务组实现要点、设计假设与未决项；验证思路 SHALL 落到具体命令或断言；SHALL NOT 推翻收敛结论，矛盾 SHALL 上浮待决；主会话 SHALL 核对通过后才落档。设计子代理 SHALL 先加载栈对应 writer skill 并以其规范为设计硬约束（判据与处置见「栈识别与 writer skill 加载（设计侧）」）。

#### Scenario: 设计线产出契约草案

- **WHEN** 1.5 收敛结束且未命中降档判据
- **THEN** 全新子代理产出覆盖全部字段与行为约束的草案，逐项核对通过后作为落档输入

#### Scenario: 触达面条目标注仓归属

- **WHEN** 设计草案写触达面清单
- **THEN** 每条逐文件路径注明所属仓（根仓/子仓名），供执行侧执行环境决策与多仓分立提交按仓展开

#### Scenario: 小需求降档

- **WHEN** 触达面 ≤2 个文件且无新接口
- **THEN** 部分深度字段允许单行简述，但触达面清单、假设与未决项与两条行为约束恒成立；trivial（单文件、无接口变更、无逻辑分支变化）命中时豁免派遣，由主会话一行断言落档，设计产物恒在

#### Scenario: 设计与收敛结论矛盾

- **WHEN** 设计草案与收敛记录的已定结论冲突
- **THEN** 设计线不重开收敛，把矛盾作为待决问题上浮并入落档分歧点提问

#### Scenario: 设计线失败

- **WHEN** 设计子代理产物缺失、字段残缺或答非所问
- **THEN** 重派一次，仍失败则如实报告由用户裁决

### Requirement: 落档工件与执行批次契约

spec-plan SHALL 通过 OpenSpec 变更工件落档（proposal、specs、design、tasks 四件套）；落档输入 SHALL 含代码设计草案（第 5 材料）；design SHALL 继承其深度并逐项断言核对通过；tasks SHALL 按编号分组表达执行批次——组即执行审核批次，组内单任务是合法常态，分组 SHALL 兼顾用户审核节奏；每任务 SHALL 携带可核验验证说明并引用代码设计触达面条目编号；落档 SHALL 校验通过后才交付执行。落档时 SHALL 把 `code-design.md` 与 `diff-matrix.md`（串行：`decisions.md`）复制入变更目录随工件提交；落档校验 SHALL 含两份材料副本存在性的机械断言（`test -f` 逐文件），任一缺失 SHALL 回到复制步补齐后再跑 `openspec validate <change> --strict`；落档副本 SHALL 为执行期维护与接续恢复的权威，`/tmp` 侧原件自此不再维护。落档展示摘要 SHALL 含触达仓清单（根仓工件与各代码子仓），作为执行侧执行环境决策与多仓分立提交的输入。

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

#### Scenario: 落档校验断言材料存在

- **WHEN** 落档校验步执行
- **THEN** 先断言 code-design.md 与 diff-matrix.md（串行 decisions.md）在变更目录（test -f），缺失回复制步补齐，再跑 openspec validate --strict

#### Scenario: 执行期维护落档副本

- **WHEN** 执行期对 code-design.md 做组段终形态化或追加留痕
- **THEN** 写变更目录内的落档副本，更新随批次提交，不再维护 /tmp 侧原件

#### Scenario: 落档摘要含触达仓清单

- **WHEN** 落档展示摘要输出
- **THEN** 摘要含触达仓清单（根仓工件/各代码子仓），供执行侧衔接点执行环境决策与多仓分立提交按仓展开
