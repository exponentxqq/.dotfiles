# Spec Delta

## MODIFIED Requirements

### Requirement: 落档工件与执行批次契约

spec-plan SHALL 通过 OpenSpec 变更工件落档（proposal、specs、design、tasks 四件套）；落档输入 SHALL 含代码设计草案（第 5 材料）；design SHALL 继承其深度并逐项断言核对通过；tasks SHALL 按编号分组表达执行批次——组即执行审核批次，组内单任务是合法常态，分组 SHALL 兼顾用户审核节奏；每任务 SHALL 携带可核验验证说明并引用代码设计触达面条目编号；落档 SHALL 校验通过后才交付执行。落档时 SHALL 把 `code-design.md` 与 `diff-matrix.md`（串行：`decisions.md`）复制入变更目录随工件提交；落档校验 SHALL 含两份材料副本存在性的机械断言（`test -f` 逐文件），任一缺失 SHALL 回到复制步补齐后再跑 `openspec validate <change> --strict`；落档副本 SHALL 为执行期维护与接续恢复的权威，`/tmp` 侧原件自此不再维护。

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
