# Tasks

> 组间严格串行、组内可并行（单组任务数 ≤ `parallelism`=8）；`## N.` 即执行审核批次；每条验证句均可在容器内第三方复跑。`<change>` = `adapt-spec-skills-to-dsh-rc5`。

## 1. 事实基线与 RED 断言（只读，零仓库写入）

- [x] 1.1 固化 RED 清单与长度基线：对 `agent/skills dsh/commands dsh/spec-workflow.yaml dsh/README.md` 跑过时词 grep，落 `/tmp/spec-flow/<change>/red-baseline-v2.txt`（触达 #1–#14）。
  验证：`test -s /tmp/spec-flow/<change>/red-baseline-v2.txt` 且 `grep -c 'spawn_teammate' …` 输出 ≥3（RED 成立）；`python3 -c` 打印四入口 `len(正文)+343` 与 `coordination.md` cp，与设计 ①1.3 表逐项相等（±0）。
- [x] 1.2 补入面锚核对（只读）：`sed -n '41,42p' agent/skills/spec-plan/refs/planning.md`、`sed -n '27p' agent/skills/spec-plan/refs/convergence.md`、`sed -n '142p;155p;161p;173,174p' dsh/README.md`（触达 #11/#10/#14）。
  验证：上述输出分别含 `agent_id`、`回送同一成员或接续重派`、`spawn`/`Team member limit 8`/`接续重派`；`grep -c 'writing-skills' dsh/README.md` = 0。

## 2. spec-apply 协议内核（协议源）

- [x] 2.1 `agent/skills/spec-apply/refs/coordination.md` 改写（触达 #1）：§1 基线换实证/文档锚、§2 schema v3（agent=name）+ 命名规约、§3 回填 name、§4 注入段逐行定稿、§5 删「成」与两示例留一、§6 下行废止通知、§7 `agent="lead"`、§8 冲突纪律、§9 四判据→单条、§10 常量清单。
  验证：`python3` 断言 `3800 ≤ len(s) ≤ 5000`、`'agent_id' not in s`、`'互不可达' not in s`、`s.count('send_message(agent="lead")') ≥ 2`、`'成=' not in s`、注入段 `7 ≤ 行数 ≤ 15`；`grep -c '完成前奏'` = 0。
- [x] 2.2 `agent/skills/spec-apply/refs/execution.md` 两引擎段重写（触达 #2）：subagent 段具名派发/即返名/同实例续话/失败重试 fresh/受控嵌套只读；team 段 Team 模式前置检查→`team_task_create`→CAS 认领→反馈回同一 implementer→路由适用→未开启回退；并行上限口径以映射文件为准。
  验证：`grep -c 'spawn_teammate\|Team member limit\|忽略 .apply. 路由'` = 0；`grep -c 'team_task_create'` ≥1；`grep -c 'write_scopes'` ≥1；`grep -c 'send_message(agent="lead")'` ≥1；`grep -c '只读孙代理'` ≥1；`python3 -c` 文件 cp ≤8192。
- [x] 2.3 `agent/skills/spec-apply/SKILL.md`（触达 #3）：§二③ 引擎语义、§三 pseudocode 与协调纪律（判据只指路）、§四中转统一、§五 routing 两引擎适用。
  验证：`python3 -c` 「正文+343 ≤ 8192」退出 0；`grep -c 'agent_id'` = 0；`grep -n 'coordination.md §9'` 命中；`grep -c '接续重派'` = 0。
- [x] 2.4 `agent/skills/spec-apply/refs/routing.md` + `refs/failure-modes.md`（触达 #4/#5）：apply 适用面改两引擎、自检补 `list_subagent_models`、删「team 忽略 apply 键」；失败表重写下行可达/上行两类/父 id 缺失口径。
  验证：`grep -c 'team 引擎忽略' routing.md` = 0；`grep -c 'list_subagent_models' routing.md` ≥1；`grep -c '下行.*不可达' failure-modes.md` = 0；`grep -c '三类' failure-modes.md` = 0。

## 3. spec-plan 消费面

- [x] 3.1 `agent/skills/spec-plan/mode/parallel.md` 重写（触达 #7）：具名子代理单机制（同消息派 `plan-a`/`plan-b`、无 `run_in_background`、即返名）、命名与重名、回执核对、线失败补正/重派、模板收敛单版、上行 `agent="lead"`。
  验证：`grep -c 'spawn_teammate\|run_in_background\|引擎差异段'` = 0；`grep -c 'plan-a'` ≥1 且 `plan-b` ≥1；`grep -c 'send_message(agent="lead")'` ≥1；`python3 -c` cp ≤4000。
- [x] 3.2 `agent/skills/spec-plan/SKILL.md`（触达 #6）：description、§一流水线图、§三摘要字段、§四具名单机制与中转、§六栈判据分支、§八路由恒适用、§九红线表。
  验证：`python3 -c` 断言 `len(正文) ≤ 7507` 且 `len(正文)+343 ≤ 8192`；`grep -c 'team 驱动\|spawn_teammate\|agent_id\|接续重派'` = 0；`grep -c 'send_message(agent="lead")'` ≥1；`grep -c 'writing-skills'` ≥1 且 `grep -n '纯文档'` 命中（§六 分支）。
- [x] 3.3 `agent/skills/spec-plan/refs/routing.md` + `refs/failure-modes.md`（触达 #8/#9）：删 team 编排例外与 spawn 成员模型选择句、自检补 `list_subagent_models`；失败表改具名派发失败/卡死处置。
  验证：两文件 `grep -c 'Team member limit\|spawn_teammate\|team 成员无模型参数'` = 0；`grep -c 'list_subagent_models' routing.md` ≥1；failure-modes `grep -c 'agent_id'` = 0。
- [x] 3.4 `agent/skills/spec-plan/refs/convergence.md:27` + `refs/planning.md:23/:41–42/:77`（触达 #10/#11）：回送改同实例续话；planning 增「纯文档/技能类默认 writing-skills」判据分支、1.7 模板 `agent="lead"` 与 writer 点名、并行上限口径。
  验证：`grep -c '回送同一成员或接续重派' convergence.md` = 0；`grep -c 'agent_id' planning.md` = 0；`grep -c 'spring-writer / nuxt-writer' planning.md` = 0；`grep -c '纯文档' planning.md` ≥1 且 `grep -c 'writing-skills' planning.md` ≥2；`grep -c 'spring-boot' planning.md` ≥1；`python3 -c` planning.md cp ≤7900。

## 4. 编排层与仓文档

- [x] 4.1 `agent/skills/spec-workflow/SKILL.md`（触达 #12）：`--engine team` 语义（需会话菜单开启）、衔接话术、`登记簿（v3`、红线表中转回送统一。
  验证：`grep -n '登记簿（v3'` 命中；`grep -c '接续重派'` = 0；`grep -n 'Team 模式'` 命中；`python3 -c` 正文+343 ≤8192。
- [x] 4.2 `agent/skills/spec-done/SKILL.md`（触达 #13）：:24/:39 验证子代理具名 `verify-<n>`。
  验证：`grep -c 'verify-<n>'` = 2；`python3 -c` 正文+343 ≤8192。
- [x] 4.3 `dsh/README.md`（触达 #14）：:142 失败处置、:155 writer 点名（补纯文档类默认 writing-skills）、:161 执行双引擎去 spawn/成员上限、:173–174 回送表。
  验证：`grep -c 'spawn_teammate\|Team member limit\|接续重派'` = 0；`grep -c 'writing-skills'` ≥1；`grep -c '纯文档'` ≥1；`grep -n 'team_task_create'` 命中。

## 5. 三主规格 delta（新建）

- [x] 5.1 `openspec/changes/<change>/specs/spec-apply/spec.md`（触达 #16）：MODIFIED `subagent 执行引擎`/`team 执行引擎`/`子代理与用户的交互中转(执行期)`；REMOVED `subagent 运行协调(登记簿·检查点·上行)`/`执行侧模型路由`；ADDED `subagent 运行协调（登记簿 v3·检查点·上行）`/`执行侧模型路由（两引擎适用）`。
  验证：`openspec validate <change> --strict` 退出 0；`python3` 断言每个 ADDED Requirement 正文 ≤500 cp、REMOVED 名在主规格逐一存在、MODIFIED 的 Scenario 名集 ⊇ 主规格同名集合。
- [x] 5.2 `openspec/changes/<change>/specs/spec-plan/spec.md`（触达 #15）：REMOVED 3 条、ADDED 3 条、MODIFIED `栈识别与 writer skill 加载（设计侧）`（保留 7 个现有 Scenario 名 + 新增 `纯文档类默认 writing-skills`）。
  验证：同 5.1（capability=spec-plan）；另断言 3 个 REMOVED 名与主规格 `openspec/specs/spec-plan/spec.md` 逐字一致（含全角括号）；MODIFIED 的 7 个现有 Scenario 名逐字存在于 delta、正文 ≤500、新增名 `纯文档类默认 writing-skills` 不在主规格。
- [x] 5.3 `openspec/changes/<change>/specs/spec-workflow/spec.md`（触达 #17）：MODIFIED `子代理与用户的交互中转（执行期）`（保留 4 个现有 Scenario 名 + 新增 `同实例续话优先`）。
  验证：同 5.1（capability=spec-workflow）；MODIFIED 名与主规格 `openspec/specs/spec-workflow/spec.md:167` 逐字一致（全角括号）。

## 6. 终检（只读，全量门）

- [x] 6.1 死名清零（触达 #1–#17）。
  验证：`grep -rn 'spawn_teammate\|Team member limit\|agent_id\|互不可达\|run_in_background' agent/skills dsh/commands dsh/spec-workflow.yaml dsh/README.md` 无输出；`grep -rn '接续重派' agent/skills dsh/README.md` 仅允许出现在「冷兜底/失败重试」语境（人工逐条核并留痕）。`openspec/specs` 子项（死名与「接续重派」）**归档后复验**，移交 spec-done 归档后门（见 design.md D14）。
- [x] 6.2 长度门全量。
  验证：四 SKILL.md `len(正文)+343 ≤ 8192`（spec-plan 另 `len(正文) ≤ 7507`）；`coordination.md` 3800–5000；注入段 `awk` 7–15 行；`planning.md` ≤7900；其余 refs ≤8192。
- [x] 6.3 规范校验。
  验证：`openspec validate <change> --strict` 退出 0 且 `--json` 输出 `summary.warnings == 0`（单变更口径；`--all --strict` 不作门，主规格既有告警另账）。
- [x] 6.4 指针与红线锚。
  验证：`test -f` 逐个核对跨文件指针（`spec-plan/SKILL.md` → `coordination.md`、`execution.md`、`refs/*`；`spec-workflow` → `spec-apply` refs；`spec-done` → `worktree.md`/`routing.md`）；`grep -c 'DELEGATED_CALLER'` 三处入口各 ≥1；`grep -n '审核确认前提交\|绝不重跑\|干净窗口\|三方对齐'` 均命中。

## 附录·执行期留痕（R<n>）

- **R12 派发注入段来源（G1 实测）**：G1/G2 的注入段取 `code-design.md ③.3` 定稿模板（`send_message(agent="lead")`、上行仅决/异），**不**取现文 `coordination.md §4`（其 `agent_id` 与「成」类在 rc.5 已失效）；G2 落地后 G3+ 从工作区现读 `coordination.md §4`。依据：D4/C2 + ②2.2 #2/#11 + G1 实测。适用范围：本变更执行期全部 subagent 派发。连锁面：无勾选变化；`coordination.md §4` 由 2.1 改写；G6.4 指针核对覆盖。
- **G1 基线冻结**：六词计数（`spawn_teammate` 8 / `Team member limit` 5 / `agent_id` 7 / `互不可达` 2 / `run_in_background` 1 / `接续重派` 9）与四入口长度（7507/3483/6358/5860，coordination 4996，注入段 628/10 行）为 GREEN 前基线常量；证据 `/tmp/spec-flow/<change>/red-baseline-v2.txt`（206 行）· `/tmp` 不入库。
- **R13 `team_task_update` 真实 schema（G2 实测）**：认领 = `team_task_update(task_id, expected_revision=<rev>, action="claim")`；`owner` 仅 `reassign`（root-only）可显式传，认领时 owner 自动落调用者 name；`blocked_by`/`write_scopes` 为 `set_dependencies`/`edit` 字段。设计 ③.7 的简写 `(id, owner=<name>, revision)` 不准确，一律以 `tool-catalog.zh.md` 的 `team_task_update` 节为准。连锁面：`execution.md` team 段（已按真值落地）；G5 delta 引用该工具须同口径；G6.4 指针核对覆盖。
- **R14 coordination 适用面 = 仅 subagent（G2 裁定）**：协调纪律/注入段/检查点仅 subagent 引擎；team 以共享任务板 + `send_message` 为控制面，登记簿只记 team 批次条目与终态、**不注入协调段**——故 SKILL.md §三「协调纪律（仅 subagent 引擎）」与 §三 refs 行「仅 subagent 引擎另读 coordination.md」保持不放宽；`routing.md` 的「两引擎」仅指模型路由面。连锁面：G3 `parallel.md` 引用 §7（规划精简段）属 subagent 面；G4 编排层话术不复制该裁定。
- **R15 README 补修两处过时平台断言（G4 复核留痕）**：`dsh/README.md:169`「与 Agent Teams 的 teammate 都不能直接向用户提问」→「子代理（含 Team 模式成员）…」；`:230`「team 引擎执行时 teammate 继承 Lead 模型」→「team 成员即具名子代理，`apply` 键两引擎均适用——成员按映射路由选模型，不受 Lead 模型锁定」。依据：Goal #1「消灭……过时平台断言」；两处不在 ①1.1 #14 的四处清单内（同文件、同目标，面扩 2 行）。连锁面：G6.1 死名词表不含 `Agent Teams`/`teammate`，终检不受影响；三主规格 delta 无对应 Scenario；README 无长度门。

## 附录·沉淀回流清单（执行期改动，随末批次提交）

| # | 文件 | 改动性质 | 去向 |
|---|---|---|---|
| 1 | `agent/skills/spec-apply/refs/coordination.md` | 协议源 v3 重写（127 行 / 4990 cp / 注入段 598 cp·10 行） | 本批次提交 |
| 2 | `agent/skills/spec-apply/refs/execution.md` | 两引擎段重写（68 行 / 6955 cp） | 本批次提交 |
| 3 | `agent/skills/spec-apply/SKILL.md` | 六处行内改（57 行 / 正文 3604） | 本批次提交 |
| 4 | `agent/skills/spec-apply/refs/routing.md` | apply 两引擎 + 双层自检（66 行 / 4367 cp） | 本批次提交 |
| 5 | `agent/skills/spec-apply/refs/failure-modes.md` | 下行可达/上行两类（25 行 / 2231 cp） | 本批次提交 |
| 6 | `agent/skills/spec-plan/SKILL.md` | 16 处行内改（131 行 / 正文 7452） | 本批次提交 |
| 7 | `agent/skills/spec-plan/mode/parallel.md` | 具名单机制重写（57→38 行 / 2371 cp） | 本批次提交 |
| 8 | `agent/skills/spec-plan/refs/routing.md` | 规划键恒适用 + 双层自检（73 行 / 4722 cp） | 本批次提交 |
| 9 | `agent/skills/spec-plan/refs/failure-modes.md` | 具名派发失败/卡死（22 行 / 3115 cp） | 本批次提交 |
| 10 | `agent/skills/spec-plan/refs/convergence.md` | 回送=同实例续话（2679 cp） | 本批次提交 |
| 11 | `agent/skills/spec-plan/refs/planning.md` | 纯文档分支 + 模板点名（7734 cp） | 本批次提交 |
| 12 | `agent/skills/spec-workflow/SKILL.md` | 四处行内改（99 行 / 正文 6560） | 本批次提交 |
| 13 | `agent/skills/spec-done/SKILL.md` | `verify-<n>` 两处（74 行 / 正文 5886） | 本批次提交 |
| 14 | `dsh/README.md` | 四处定点 + R15 两处过时断言（349 行） | 本批次提交 |
| 15 | `openspec/changes/<change>/design.md` | D14 衔接裁定 + 执行环境块 | 本批次提交 |
| 16 | `openspec/changes/<change>/tasks.md` | 勾选 20/20 + 附录 R12–R15 + 沉淀回流清单 | 本批次提交 |
| 17 | `openspec/changes/<change>/code-design.md` | G1–G6 组段终形态化 | 本批次提交 |
| — | `openspec/changes/<change>/specs/*/spec.md`（三份 delta） | 落档交付，执行期零改动 | 已提交 `632c750` |
| — | `/tmp/spec-flow/<change>/{red-baseline-v2.txt,progress.md,line-*.md,...}` | 证据与登记簿 | 不入库（易失） |

**不提交面（用户未提交改动，全程零触碰）**：`dsh/profiles/web/cordis.patch.yml`、`package.json`、`pnpm-lock.yaml`、`dsh/spec-workflow.yaml`。
