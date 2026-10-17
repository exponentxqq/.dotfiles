# Proposal

## Why

websocket-infra 变更（opc 仓，2026-10-17 归档）是三仓 worktree 隔离执行的首个完整实战：主工作区有并行变更（t3-2 等），代码全程在 `.worktrees/websocket-infra/{service,portal}`（分支 `feature/websocket-infra`）执行，根仓工件在主工作区直提；归档后又经 rebase→全量复验→推送→code review 合并→删 worktree→清分支收尾。复盘暴露三项现存 skill 未承载、且有 git 与会话证据坐实的缺口：

1. **worktree 隔离执行全流程零覆盖**：两 skill 对 worktree 的决策时机、布局约定（`.worktrees/<change>/<子仓>` + `feature/<change>`）、创建后依赖装配（portal 需 `pnpm install`；worktree 检出不含 gitignored 的 `.env`/`application-local.yml` 等本地配置——启动服务既缺配置、并行 worktree 又端口冲突、共库时 migration 版本表互踩）、执行子代理「项目根」指向、批次提交落点（worktree feature 分支 vs 根仓主工作区）、恢复核对，全部是执行期即兴发挥；worktree 布局当时只记在易失的 `/tmp/spec-flow/<change>/progress.md`，`/compact` 后全靠对话摘要幸存——恢复协议无从核对。
2. **归档后闭环无手册、无再入口**：流程止于归档提交+汇报。真实收尾（rebase origin/main→**rebase 后全量复验**（两仓实测：service 四模块 cleanTest 1m11s、portal 727 用例+lint）→push→用户平台合并→删 worktree（先查干净、不波及其他）→`git branch -d` 清分支）跨三次用户往返、天然跨会话，而 `continue` 语义在归档后已失效——没有再入口令。
3. **推送口径过时**：dsh 容器 ssh 已修复（openssh-client 烘入镜像 + `~/.ssh` ro 挂载，实测 `ssh -T git@codeup.aliyun.com` 认证通过），failure-modes「推送不代劳」迫使每次收尾多一轮宿主往返；但探测-回退语义（不可行仍给宿主命令、不绕行）未成文。

## What Changes

- **worktree 前半程入 spec-workflow（F1）**：衔接点新增③执行环境决策（判据推荐**整批隔离**、`--worktree` 预置跳问）；新建 `refs/worktree.md`（判据、布局与创建装配、**本地配置复制与端口/数据库错开**、执行期使用、**执行环境块 schema**、恢复核对）；恢复协议插「执行环境核对」步；§六补隔离执行的派发根与提交落点。
- **执行环境块 = 交接契约（F1'）**：决策与布局（仓→worktree 路径→分支+装配记录+端口/库名/入库配置改动清单）写入落档 design.md 决策记录、随衔接后首个批次提交入库——执行期恢复与收尾重建都从工件读取，修复易失留痕缺口。
- **拆分 skill `spec-done`（F2）**：归档后收尾半程独立成 skill（命令 `/spec-done <变更名>`）：三方重建（归档执行环境块 + `git worktree list` + fetch 后分支事实）→ 隔离闭环八步（rebase（冲突 abort+呈证三选一）→全量复验→push（探测代推；被拒 fetch+rebase 一次重试）→用户合并→**git 事实复核后**删 worktree（删前入库配置还原+独立 database 去留询问）→`branch -d` 清分支→根仓 main 推送+闭环汇报）与非隔离轻量收尾（推送+遗留待办复核）；前提已归档。
- **汇报五要素→六要素（F3）**：新增⑥遗留待办（worktree 闭环清单→`/spec-done` 入口、临时偏离恢复点、预留编号）；spec-workflow 只指路不代跑。
- **推送探测代推口径（F4）**：failure-modes 修订——先探测（fetch/`ssh -T`）可行按用户指示代推，不可行给宿主命令不绕行；execution.md 汇报④同步。
- **spec-plan 供料契约（F5）**：阶段 1.7 触达面清单逐条**注明所属仓**；落档摘要新增**触达仓清单**（根仓工件/各代码子仓）——执行环境决策与多仓分立提交的输入。

## Capabilities

### New Capabilities

- `spec-done`：收尾入口与三方重建、收尾 rebase 与全量复验、收尾推送与合并确认、worktree 删除与分支清理、本地环境收尾处置、非隔离轻量收尾、收尾红线（7 Requirement 全量新增）。

### Modified Capabilities

- `spec-workflow`：**ADDED**×4（执行环境隔离决策、worktree 布局与创建装配、本地配置复制与环境错开、隔离执行落点）；**MODIFIED**×2（落档到执行的衔接与恢复——衔接含执行环境决策、恢复含执行环境核对；验证门与归档提交——归档汇报六要素含遗留待办与 spec-done 指路）。
- `spec-plan`：**MODIFIED**×2（阶段 1.7 代码设计线——触达面注明所属仓；落档工件与执行批次契约——摘要含触达仓清单）。

## Impact

- 代码/文档：`agent/skills/spec-workflow/{SKILL.md, refs/execution.md, refs/failure-modes.md}` 联动 + 新建 `refs/worktree.md`；新建 `agent/skills/spec-done/SKILL.md` + `dsh/commands/spec-done.md`；`agent/skills/spec-plan/{SKILL.md, refs/planning.md}` 供料微调；`dsh/commands/spec-flow.md` hint 加 `--worktree`、`dsh/spec-workflow.yaml` 注释一行（键值不动）。主规格随归档 delta 同步，不手改。
- 环境依赖：`/spec-done` 命令需容器内 `~/.dsh/commands/spec-done.md` symlink（先例命令可代做）；新 skill 目录需聚合层登记（宿主 `~/.local/share/agent-skills/skills/` symlink——**宿主操作**，命令呈证交用户）。
- 不影响：两 skill 方法论内核（双线独立性、七步收敛、深度契约、引擎与三模式、模型路由架构与键值）、openspec-* skills、既有归档变更。
- 风险：spec-workflow/SKILL.md 现余量约 1000 码点、注入约 970——逐字预排 + 码点断言兜底，超限压缩措辞不砍红线。
