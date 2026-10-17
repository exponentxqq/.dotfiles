# Decisions（grill-me 收敛留痕·落档副本）

编排：串行单线（plan 模式侦察 + grill-me 两轮 13 问）。原文问答于 2026-10-17 会话，本文件为逐字落档副本；`/tmp/spec-flow/spec-workflow-worktree-lifecycle/` 原件不再维护。

## 设计树与前沿分轮

- **第一轮（前沿 5 问，承重最大）**：交付载体 → worktree 决策位置 → 闭环驱动模型 → 推送代劳边界 → rebase 复验范围。
- **第二轮（前沿 5 问，第一轮解锁）**：rebase 冲突处置 → 执行环境留痕位置 → 汇报要素命名 → worktree 布局默认 → 本变更实施方式。
- **第三轮（前沿 2 问，第二轮解锁）**：隔离决策粒度 → 非隔离收尾形态；用户追加一问：收尾是否拆独立 skill。
- **第四轮+第五轮（落档呈证后用户追加需求触发：worktree 本地配置端口/数据库冲突）**：端口分配方式 → 配置基底（custom 引出数据库维度）→ 入库配置处理 → 端口记录；重问基底 → 数据库隔离层级 → 新库基线 → 收尾处置。

## 逐问裁定（Q1~Q13 答复「全部同意/都同意/可以」接受推荐项；Q14~Q19 为追加澄清轮，Q14/Q18 选非推荐项、其余接受推荐）

| # | 问题 | 裁定（A=推荐项） |
| --- | --- | --- |
| Q1 | 交付载体 | **A** 走 dotfiles 自身 openspec 流程（变更名 `spec-workflow-worktree-lifecycle`），主规格不漂移 |
| Q2 | worktree 决策位置 | **A** spec-workflow 衔接点（判据+询问，`--worktree` 预置跳问）；spec-plan 只供料（触达面标注仓+摘要列触达仓清单） |
| Q3 | 闭环驱动模型 | **A** 手册化+关键点停留：fetch+rebase+复验+push 一气呵成呈证；删 worktree/清分支硬等用户确认已推送+已合并 |
| Q4 | 推送代劳边界 | **A** 先探测（`ssh -T`/fetch）可行按用户指示代推（含根仓 main）；不可行给宿主命令不绕行 |
| Q5 | rebase 后复验范围 | **A** 全量复验（各触达仓全量测试、干净窗口） |
| Q6 | rebase 冲突处置 | **A** abort 回退+呈证三选一（授权代解/用户自解/放弃 rebase），不自行解冲突 |
| Q7 | 执行环境留痕位置 | **A** 落档 design.md 决策记录「执行环境」块，随衔接后首个批次提交入库 |
| Q8 | 归档汇报要素命名 | **A** 五要素→六要素，新增⑥遗留待办 |
| Q9 | worktree 布局默认 | **A** 多仓 `<根仓>/.worktrees/<change>/<子仓目录名>`、单仓 `.worktrees/<change>`；分支恒 `feature/<change>`；衔接点可覆盖 |
| Q10 | 本变更实施方式 | **A** 主会话直改+逐任务验证句自核对，step-group 呈证 |
| Q11 | 隔离决策粒度 | **A** 整批统一（一次询问覆盖全部触达代码仓，不按仓拆问） |
| Q12 | 非隔离收尾形态 | **A** 收尾阶段条件化：隔离→八步闭环；非隔离→轻量收尾（推送+遗留待办复核），同一 skill 覆盖 |
| Q13 | 收尾拆独立 skill（用户追加问） | **A** 拆 `spec-done`（命令 `/spec-done <变更名>`）：只管归档后收尾；worktree 前半程留 spec-workflow；交接契约=design.md 执行环境块（schema 权威源=worktree.md，spec-done 引用不复制）；复用 `verify` 键；前提已归档；delta 扩为三份 |
| Q14 | 端口分配方式 | **C** 固定公式自动写入：每端口项 `默认值 + 100 × n`，n = 创建时根仓 `.worktrees/` 下其他并行变更目录数，不询问；实际值记入执行环境块（恢复不重分配） |
| Q15 | 本地配置基底 | **A** 从主检出复制（第四轮该问 custom 引出数据库维度，第五轮重问裁定）；复制后改写端口+数据库连接，其余本地项随复制继承 |
| Q16 | 数据库隔离层级 | **A** 同 mysql 实例独立 database：`<原库名>_wt<n>`（同一 n）、`CREATE DATABASE IF NOT EXISTS`、连接串改库名；redis 等无 schema 冲突中间件不自动隔离 |
| Q17 | 新库基线 | **A** 项目声明（seed/初始化脚本）优先；无声明空库 + 该分支 migration 全量重放（flyway 启动自动跑） |
| Q18 | 入库配置处理 | **B** 改工作副本不提交；改动清单记入执行环境块，收尾删 worktree 前还原（spec-done 红线） |
| Q19 | 收尾数据库处置 | **A** 删 worktree 硬门槛确认时一并呈证库名清单问 DROP（探测口径代跑/给命令）或保留，终态入闭环汇报 |

## 事实性假设（随共识生效，用户未异议）

- 码点 ≤7849/文件纪律不变；超限一律压缩外移，不放宽预算。
- 变更名 `spec-workflow-worktree-lifecycle`（覆盖面大于纯拆分，不沿 `split-spec-done-skill` 命名）。
- spec-done 复用 `spec-workflow.yaml` 的 `verify` 键与白名单（键值不动）。

## 主会话查证记录（未转提问的事实）

- 两 skill 全文零 worktree 覆盖（grep 证实）——缺口成立的实据。
- 容器内 `/usr/bin/ssh` 存在、`ssh -T git@codeup.aliyun.com` 认证通过（Q4 口径依据）。
- dotfiles master 工作区干净、`git worktree list` 仅主检出——本变更自身执行环境=直用主工作区。
- 聚合层条目为指向 dotfiles 的 symlink、容器内只读 bind mount——spec-done 登记=宿主操作。
- 主规格四段将被 MODIFIED 的 Requirement 现行全文已逐段读取（防 MODIFIED 基线漂移）。
- worktree 检出只含入库内容（git 机制）——gitignored 本地配置（`.env`/`application-local.yml`）需从主检出复制；共享库时 migration 版本表（flyway_schema_history）被并行分支互踩为结构性风险（Q15~Q17 依据）。
