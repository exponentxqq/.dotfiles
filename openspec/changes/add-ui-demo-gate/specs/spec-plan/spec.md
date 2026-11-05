# Spec Delta

## ADDED Requirements

### Requirement: 阶段 1.75 界面演示 gate

阶段 1.7 回执核对通过后、阶段 2 落档前，spec-plan SHALL 加载 skill `ui-demo` 判定（C1∧C2∧C3 且不命中排除表）：命中 SHALL 由主会话 inline 产出演示（先落易失区）并取得用户明确确认后才落档，用户否决 SHALL 改稿重出不进入落档；未命中 SHALL 在代码设计草案追加一行未触发事实与判据。演示产物落档时 SHALL 整目录复制入变更目录 `demos/`（空目录视为缺失）。`ui-demo` 不可加载 SHALL 按失败处置顺序修复，仍失败 SHALL 报告问用户，不静默跳过。

#### Scenario: 命中判定进入演示 gate

- **WHEN** 阶段 1.75 判定三条件成立且不命中排除表
- **THEN** 主会话按 ui-demo 产出分级生成演示、自检后以三选一问法交用户确认

#### Scenario: 未确认不得落档

- **WHEN** 用户未答复确认或选择「要改」
- **THEN** 不进入落档步；改稿重出直至确认或取得书面豁免留痕

#### Scenario: 未命中记未触发事实

- **WHEN** 判定不成立或命中排除表
- **THEN** 代码设计草案追加一行「1.75 未触发：<判据事实>」，供执行侧与接续恢复审计

#### Scenario: ui-demo 不可加载不静默跳过

- **WHEN** 加载 skill ui-demo 失败
- **THEN** 按失败处置顺序修复，仍失败报告并问用户三选一，不静默降级跳过演示

## MODIFIED Requirements

### Requirement: 落档工件与执行批次契约

spec-plan SHALL 通过 OpenSpec 变更工件落档（proposal、specs、design、tasks 四件套）；落档输入 SHALL 含代码设计草案（第 5 材料）；design SHALL 继承其深度并逐项断言核对通过；tasks SHALL 按编号分组表达执行批次——组即执行审核批次，组内单任务是合法常态，分组 SHALL 兼顾用户审核节奏；每任务 SHALL 携带可核验验证说明并引用代码设计触达面条目编号；落档 SHALL 校验通过后才交付执行。落档时 SHALL 把 `code-design.md` 与 `diff-matrix.md`（串行：`decisions.md`）复制入变更目录随工件提交；落档校验 SHALL 含两份材料副本存在性的机械断言（`test -f` 逐文件），任一缺失 SHALL 回到复制步补齐后再跑 `openspec validate <change> --strict`；落档副本 SHALL 为执行期维护与接续恢复的权威，`/tmp` 侧原件自此不再维护。落档展示摘要 SHALL 含触达仓清单（根仓工件与各代码子仓），作为执行侧执行环境决策与多仓分立提交的输入。若阶段 1.75 界面演示已触发，落档 SHALL 同时把演示产物从易失区整目录复制入变更目录 `demos/`，其存在性断言（目录存在且非空）并入同一机械校验；未触发 SHALL 在代码设计草案留未触发判定。

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

#### Scenario: 落档复制界面演示产物

- **WHEN** 阶段 1.75 界面演示已触发且用户已确认
- **THEN** 落档把易失区 demos/ 整目录复制入变更目录（目录存在且非空随机械校验断言），随工件提交；未触发时变更目录不建 demos/
