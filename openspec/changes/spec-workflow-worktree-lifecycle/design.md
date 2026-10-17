# Design

## Context

websocket-infra（opc 仓）是三仓 worktree 隔离执行的完整实战样本：service/portal 两代码子仓 worktree（`.worktrees/websocket-infra/{service,portal}`、分支 `feature/websocket-infra`）+ 根仓工件主工作区直提；归档后收尾实录——rebase origin/main 零冲突→**rebase 后全量复验**（service 四模块 cleanTest `--no-build-cache` 1m11s、portal 727 用例 + lint 0 errors）→容器内 ssh 缺失迫使 push 转宿主→用户平台 code review 合并→确认后删两 worktree（删前核对干净、复核未波及 t3-2 worktree）→`branch -d` 清分支。其后 ssh 修复持久化（镜像层 + compose 挂载入库），容器内 `git fetch`/push 全功能可用（实测 Codeup 认证通过）。

复盘后用户追加指出的第四缺口（实录只跑测试未踩到）：worktree 检出不含 gitignored 本地配置（`.env`/`application-local.yml`），并行 worktree 启动服务时端口冲突，且共库导致 migration 版本表互踩（静默数据损坏）；经两轮追加澄清（Q14~Q19）裁定「本地环境错开」方案。

本设计把上述经验固化为 skill 体系的三段补全 + 本地环境错开：worktree 前半程（spec-workflow）、收尾半程（新 skill spec-done）、供料契约（spec-plan）。13 项决策经 grill-me 全部落定（留痕 decisions.md 落档副本）。

**码点基线**（python len 实测）：spec-workflow/SKILL.md 6810｜execution.md 5269｜failure-modes.md 2115｜spec-plan/SKILL.md 7243｜planning.md 6041。新建文件 worktree.md / spec-done SKILL.md / spec-done.md 命令及全部修订文件均须 ≤7849。

**栈识别结论（决策记录硬项）**：writer skill **豁免**（沿 2026-10-17 变更先例裁定，仅本次有效）——dotfiles 全仓无 `pom.xml`/`build.gradle*`（Spring 未命中）、无 `nuxt.config.*` 且依赖不含 `nuxt`（Nuxt 未命中），触达面为纯 Markdown skill 文本；设计产物标注「未触 writer 约束（用户豁免）」。

**本变更自身执行环境（执行环境块，决策记录硬项）**：**直用主工作区**——dotfiles 单仓、`git worktree list` 仅主检出、`git status --porcelain` 干净、无并行变更；不建 worktree。收尾预期非隔离轻量收尾（推送 master）。

## Goals / Non-Goals

**Goals**：F1 worktree 前半程（决策/布局/创建装配/**本地配置复制与端口/数据库错开**/执行期使用/恢复核对）+ 执行环境块交接契约入 spec-workflow；F1' 决策入工件随批次提交；F2 spec-done 拆分（三方重建 + 隔离八步（含本地环境收尾处置）+ 非隔离轻量 + 红线）；F3 汇报六要素；F4 推送探测代推口径；F5 spec-plan 触达仓供料。新条目逐字定稿供执行照抄；全部文件码点 ≤7849。

**Non-Goals**：不改方法论内核与模型路由键值；不承载 worktree 收尾细节进 spec-workflow（只指路——防两 skill 双源漂移）；不处理已手工闭环的 websocket-infra 遗留（无遗留工作）；不为废弃变更的 worktree 清理建流程（failure-modes 兜底即可）；不改 `spec-workflow.yaml` 键值与 cordis.patch.yml。

## Decisions

- **D1（Q2/Q11）执行环境决策挂 spec-workflow 衔接点③，整批统一**：工作区状态在执行前一刻才真实（落档时定死会过期，continue 多日后执行尤甚）；按仓拆问会产生「service 隔离、portal 直用」混合形态，提交落点与闭环复杂度翻倍且无先例。被否：spec-plan 落档时定死、执行期遇障再即兴（现状）。
- **D2（Q7）执行环境块 = 落档 design.md 决策记录新块，schema 权威源 = spec-workflow 的 worktree.md**：沿用「栈识别结论」同款通道（执行侧与接续恢复从工件读取），修复实录中只记 /tmp progress.md 的易失缺口；spec-done 只引用不复制（防双源漂移）。被否：tasks.md 头注记（污染勾选载体）、独立工件（加文件无增益）。
- **D3（Q9）布局默认**：多仓 `<根仓>/.worktrees/<change>/<子仓目录名>`、单仓 `.worktrees/<change>`、分支恒 `feature/<change>`，衔接点可覆盖——实录布局即缺省；单仓去冗余子层，`.gitignore` 一条 `.worktrees/` 通配。被否：统一带子层（规则单一但路径冗余）。
- **D4（Q13）拆 spec-done，边界 = 只管归档后收尾**：收尾天然跨会话（实录三次用户往返）而 continue 语义归档后失效；spec-workflow/SKILL.md 码点余量恰好释放；先例 `split-spec-plan-skill` 同款半程拆分。交接：design.md 执行环境块（spec-workflow 写入、spec-done 读取）+ 归档汇报⑥遗留待办指路。前提已归档（未归档→提示先走 spec-workflow 阶段 4）。
- **D5（Q3）闭环节奏 = 手册化+关键点停留**：fetch+rebase+复验+push 一气呵成后呈证；**删 worktree 与清分支硬等用户确认已推送+已合并**。实录的逐步指令是 ssh 缺失逼出的绕行，不是理想节奏；但 worktree 删除不可逆前的合并确认是必要硬门槛。
- **D6（Q4）推送先探测、可行按用户指示代推**（含根仓 main）；不可行给宿主命令等回告、不绕行换协议硬闯。ssh 修复已是持久化基础设施，skill 应反映现实；探测-回退保留兜底。被否：维持「一律宿主」（每轮收尾多一次人工往返）。
- **D7（Q5）rebase 后全量复验**（各触达仓全量测试、干净窗口）：rebase 改写全部提交链，基线漂移的破坏常在触达面之外；实录成本可接受（两仓合计约 2 分钟）。可派 fresh 子代理按 `verify` 键（spec-done 复用 spec-workflow.yaml，键值不动）。
- **D8（Q6）rebase 冲突 abort 回退+呈证三选一**（授权代解/用户自解/放弃 rebase）：收尾冲突=基线与变更有真实语义交叠，错误合并直接进主干；呈证一次远低于合错风险。
- **D9（Q12）收尾条件化**：隔离→八步闭环；非隔离→轻量收尾（探测代推当前分支/根仓 main + 遗留待办复核）。同一 skill 覆盖两形态，避免「有 worktree 才有收尾」死角。
- **D10（Q8）汇报五要素→六要素**：⑥遗留待办（闭环清单/临时偏离恢复点/预留编号）与④宿主操作清单（用户必须做的事）不同类——实录归档报告「遗留提示」独立成节效果好，混装会在「无宿主操作」时漏呈现。
- **D11（F4 连锁）failure-modes「需要宿主操作」行拆推送例外**，execution.md 汇报④同步探测语义；spec-workflow.yaml 仅注释补一行「verify 键另由 spec-done 复用」。
- **D12（Q1/Q10）交付 = dotfiles 自身 openspec 流程，主会话直改+逐任务验证句自核对，step-group 呈证**：纯文本小变更，锚点计数口径（R1 先例）是主要风险而非代码，直改减少转述失真。
- **D13 任务分 4 组**（组1 spec-workflow 侧 5 任务、组2 spec-done 新建 3 任务、组3 spec-plan 侧 2 任务、组4 只读校验 2 任务；≤ parallelism=8）。被否：每文件一组（拖长节奏）/两 skill 并一组（审核粒度差）。聚合层登记（宿主操作）单独成任务呈证命令，不静默。
- **D14（Q14/Q15）端口固定公式 + 配置复制基底**：本地配置（`.env`/`application-local.yml` 等 gitignored 文件）从主检出复制进 worktree 后改写；每个端口项 `默认值 + 100 × n` 自动写入不询问，n = 创建时根仓 `.worktrees/` 下其他并行变更目录数（主检出占默认端口）——与主检出及其他 worktree 天然错开；实际值记入执行环境块，恢复/重建按块读回不重分配。被否：占用表呈证确认（多一轮往返，公式已保证错开）。
- **D15（Q16/Q17）数据库同实例独立 database**：并行 worktree 共库时 migration 版本表（如 flyway_schema_history）互踩=静默数据损坏——每变更建 `<原库名>_wt<n>`（同一 n），装配期 `CREATE DATABASE IF NOT EXISTS`，连接串改指新库；基线=项目声明（seed/初始化脚本）优先、缺省空库 + 该分支 migration 全量重放（flyway 启动自动跑）；redis 等无 schema 冲突中间件不自动隔离（failure-modes 提示）。被否：独立 mysql 容器（每实例一份内存、建拆慢）/不自动隔离（冲突即数据损坏）。
- **D16（Q18）入库配置改副本不提交**：该类文件入库的仓直接改工作副本、不提交（改动不进批次提交）；改动文件清单记入执行环境块，收尾删 worktree 前还原（spec-done）。被否：环境变量/启动参数覆盖（用户裁定直改副本）/随分支提交（合并后污染主检出端口与连接）。
- **D17（Q19）收尾数据库处置随删 worktree 一并问**：删 worktree 硬门槛确认时呈证独立库名清单，问用户 DROP（给命令或按推送探测口径代跑）还是保留，终态记入闭环汇报。被否：一律保留（残留累积）/自动 DROP（不可逆动作不问）。

## 触达面清单（与 code-design.md ①逐项对应，逐字新文本见其 (b) 节）

| # | 文件 | 改动意图 | 码点（现→估） |
| --- | --- | --- | --- |
| T1 | `agent/skills/spec-workflow/refs/worktree.md` | 新建：决策判据/布局创建装配/本地配置与环境错开（端口公式+数据库独立库）/执行期使用/执行环境块 schema/恢复核对 | 新建 ~3400 |
| T2 | `agent/skills/spec-workflow/SKILL.md` | 五节联动：§一流水线+参数表+消费时机表、§五衔接③+恢复协议插步重编号、§六隔离落点句、§七⑦六要素+⑧指路、§十红线追加 | 6810→~7780 |
| T3 | `agent/skills/spec-workflow/refs/execution.md` | 三处：项目根 worktree 注记、多仓分立提交 worktree 变体、汇报六要素（④探测语义） | 5269→~5480 |
| T4 | `agent/skills/spec-workflow/refs/failure-modes.md` | 3 新行+宿主操作行拆推送例外 | 2115→~2600 |
| T5 | `dsh/commands/spec-flow.md` | argument-hint 加 `--worktree` | +12 |
| T6 | `dsh/spec-workflow.yaml` | 注释补「verify 键另由 spec-done 复用」（键值不动） | +18 |
| T7 | `agent/skills/spec-done/SKILL.md` | 新建：收尾半程全手册（删 worktree 含入库配置还原+独立库去留询问） | 新建 ~5600 |
| T8 | `dsh/commands/spec-done.md` | 新建命令薄壳 | 新建 ~420 |
| T9 | `~/.dsh/commands/spec-done.md`（symlink，不入库） | 容器内命令入口（failure-modes 先例命令） | — |
| T10 | 聚合层登记（宿主 `~/.local/share/agent-skills/skills/spec-done` symlink，不入库） | skill 可加载（宿主操作，呈证命令交用户） | — |
| T11 | `agent/skills/spec-plan/refs/planning.md` | 两处：1.7 模板①触达面注明所属仓；落档摘要加触达仓清单 | 6041→~6130 |
| T12 | `agent/skills/spec-plan/SKILL.md` | §六词组微调（触达面逐条注明所属仓） | 7243→~7280 |
| T13 | `openspec/changes/spec-workflow-worktree-lifecycle/`（delta×3，随落档生成） | spec-workflow ADDED×1+MODIFIED×2、spec-plan MODIFIED×2、spec-done ADDED 全量 | 新建 |

步序重编号一处必须完整：spec-workflow/SKILL.md 恢复协议插新第 5 步「执行环境核对」，原 5/6/7→6/7/8。

## Risks / Trade-offs

- [SKILL.md 注入约 970 贴 1039 余量] → 逐字文本预排（code-design (b)），任务断言逐文件码点复核；超限先压 §七⑧并入⑥、再压 §六句，不砍红线。
- [恢复协议重编号漏改] → 设计列明重编号范围；验证句断言「执行环境核对」唯一计数与新末步「不依赖对话记忆」存在性。
- [两 skill 交界双源漂移（worktree 前半程 vs 收尾）] → 执行环境块 schema 单点定义于 worktree.md，spec-done 明写「引用不复制」；spec-workflow §七⑧只指路。
- [spec-done 聚合层登记属宿主操作] → 组2 任务呈证确切命令（`ln -sfn`，先例：既有条目即 symlink）交用户执行，登记前 `/spec-done` 命令可先经 symlink 生效（命令薄壳与聚合层相互独立）。
- [delta MODIFIED 基于主规格现行文本] → 落档前已逐段读取现行 Requirement 全文，MODIFIED 为完整替换文本。

## Migration Plan

纯 Markdown/注释修订，无迁移；组1（spec-workflow 侧）→ 组2（spec-done 新建）→ 组3（spec-plan 侧）→ 组4（只读校验）顺序实施，批次提交可回滚。主规格由归档流程按 delta 同步。websocket-infra 已手工闭环，无存量待收尾变更。

## Open Questions

（无——grill-me Q1~Q13 及两条事实性假设已全部裁定，留痕 decisions.md 落档副本。）
