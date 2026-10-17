# Spec Delta

## ADDED Requirements

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

### Requirement: 隔离执行落点

隔离执行期，子代理提示的项目根与验证句执行目录 SHALL 为 worktree 路径；代码批次提交 SHALL 落 worktree 的 `feature/<change>` 分支、工件提交 SHALL 落根仓主工作区（多仓分立提交不变）。

#### Scenario: 隔离执行的提交落点

- **WHEN** 隔离执行批次核对通过且用户审核确认提交
- **THEN** 代码提交落在该代码仓 worktree 检出的 feature 分支，工件提交落在根仓主工作区，N 仓各自完整提交不跨仓混提

## MODIFIED Requirements

### Requirement: 落档到执行的衔接与恢复

spec-plan 落档提交完成后，工作流 SHALL 确认执行模式与引擎（未预置时），并 SHALL 决策执行环境——隔离（全部触达代码仓建 worktree）或直用主工作区：判据命中 SHALL 推荐隔离、一次问清不按仓拆问，`--worktree` 预置 SHALL 跳过询问；选定隔离 SHALL 创建并装配，执行环境块 SHALL 写入落档 design.md 决策记录（随衔接后首个批次提交入库）。随后 SHALL 提示可在执行前切换模型或压缩上下文；工作流 SHALL 以工件与任务完成度作为唯一进度载体，使压缩或会话重启后可无损恢复；恢复时勾选态与提交历史不一致 SHALL 以现存改动证据为准——先对已完成任务的现存 diff 执行其验证说明，通过即保持勾选且不重派执行子代理（`auto` 模式收尾才提交，中途恢复时已完成任务的改动尚未提交属预期），不通过才回退为未完成并报告。恢复时 SHALL 校验两份落档材料（`code-design.md` 与 `diff-matrix.md`，串行 `decisions.md`）在变更目录：缺失且 `/tmp/spec-flow/<change>/` 原件存在 SHALL 从原件补复制入变更目录并留痕（随下次批次提交）；两者皆无 SHALL 报告问用户，SHALL NOT 以 /tmp 幸存为默认继续。恢复时 SHALL 核对执行环境：design.md 决策记录有执行环境块（隔离）时以 `git worktree list` 比对——worktree 在 SHALL 续用（含装配核对）；缺失但分支在 SHALL 重建（`git worktree add`）并装配后按三方对齐核对该仓进度；均无 SHALL 报告问用户。

#### Scenario: 落档完成后衔接

- **WHEN** spec-plan 落档提交完成
- **THEN** 工作流确认执行模式与引擎（未预置时），决策执行环境（隔离或直用主工作区），并提示可切换模型或压缩上下文后再继续

#### Scenario: 衔接点执行环境决策留痕

- **WHEN** 衔接点选定隔离执行
- **THEN** 执行环境块（仓→worktree 路径→分支+装配记录）写入落档 design.md 决策记录，随衔接后首个批次提交入库

#### Scenario: 压缩上下文后继续执行

- **WHEN** 用户在落档后压缩上下文并指示继续
- **THEN** 从工件与任务完成度重建进度并继续，不重复已完成任务

#### Scenario: auto 中途恢复保留已完成任务

- **WHEN** auto 模式执行中途会话中断后恢复，且已勾选任务的改动仍在工作区未提交
- **THEN** 先对现存 diff 执行该任务的验证说明，通过即保持勾选、不重派执行子代理；不通过才回退该勾选并报告

#### Scenario: 恢复时补复制落档副本

- **WHEN** 恢复时变更目录缺 `code-design.md` 或 `diff-matrix.md`（串行 `decisions.md`）而 `/tmp/spec-flow/<change>/` 原件存在
- **THEN** 从原件补复制入变更目录并留痕，随下次批次提交；不以 /tmp 原件幸存为默认继续

#### Scenario: 恢复时重建缺失的 worktree

- **WHEN** 恢复核对发现执行环境块所述 worktree 缺失但 `feature/<change>` 分支仍在
- **THEN** 按记录的布局重建 worktree、补装配，并以三方对齐核对该仓进度后继续，不重跑已完成任务

### Requirement: 验证门与归档提交

全部任务完成后 SHALL 先执行项目声明的验证；验证通过后、归档前，工作流 SHALL 加载 `openspec-verify-change` 做完整性校验（任务全部勾选、spec 覆盖映射、design 一致性），发现缺漏 SHALL 先修复并重新校验，校验通过 SHALL 才归档变更并同步主规格，归档 SHALL 单独提交一次；验证失败 SHALL NOT 归档。归档汇报 SHALL 呈六要素——工件路径、验证证据、归档位置与主规格、宿主操作清单、沉淀回流清单、遗留待办（worktree 闭环清单及 `/spec-done` 入口、执行期临时偏离恢复点、预留编号）；归档后的收尾半程 SHALL 由 skill `spec-done` 承载，本工作流 SHALL 在遗留待办中指路、SHALL NOT 代跑。

#### Scenario: 验证失败不归档

- **WHEN** 归档前验证失败
- **THEN** 不归档，报告失败并等待用户决定跳过或修复

#### Scenario: verify-change 拦截勾选遗漏

- **WHEN** 归档前校验发现已入库任务存在勾选遗漏或缺漏的 spec 覆盖
- **THEN** 先补核对勾选（或补 delta）并重新校验，通过后才归档，不绕过校验归档

#### Scenario: 归档汇报列遗留待办

- **WHEN** 归档提交完成输出汇报
- **THEN** 汇报含第六要素遗留待办——worktree 闭环清单（注明 `/spec-done <变更名>` 入口）、执行期临时偏离恢复点、预留编号，交用户决定收尾时机
