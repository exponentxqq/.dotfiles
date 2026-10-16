# 执行记录：split-spec-plan-skill

**变更名**：split-spec-plan-skill（拆分 spec-workflow：独立出 spec-plan 规划半程 + 执行侧实证纪律吸收）
**执行方式**：主会话串行（轻量文档变更，无子代理派发）；执行模式 = auto（用户落档确认时补定变体口径：**全批次连续执行、完成后不提交、停留呈证等用户审核确认**，并确认为通用规则：任何模式完成后都不自动提交，除非用户明确豁免审核）；主规格经 delta 同步不手改。
**权威进度**：工件 + `tasks.md` 勾选态 + `git log` 三方对齐；过程证据即本文与对话内断言输出（无独立证据目录需求，全流程零构建工具）。

## 一、码点门禁（G1，实测）

| 文件 | 码点 | 门槛 | 结果 |
| --- | --- | --- | --- |
| `agent/skills/spec-plan/SKILL.md`（新建） | **5709**（渲染上界 6052） | ≤7849 / +343 ≤8192 | PASS |
| `agent/skills/spec-plan/refs/planning.md` | 6709 | ≤8192 | PASS |
| `agent/skills/spec-plan/refs/convergence.md` | 2070 | ≤8192 | PASS |
| `agent/skills/spec-plan/refs/routing.md` | 3924 | ≤8192 | PASS |
| `agent/skills/spec-plan/refs/failure-modes.md` | 2270 | ≤8192 | PASS |
| `agent/skills/spec-workflow/SKILL.md`（改写，12 节→10 节） | **6372**（渲染上界 6715） | ≤7849 / +343 ≤8192 | PASS |
| `agent/skills/spec-workflow/refs/execution.md` | 4619 | ≤8192 | PASS |
| `agent/skills/spec-workflow/refs/routing.md` | 3913 | ≤8192 | PASS |
| `agent/skills/spec-workflow/refs/failure-modes.md` | 2115 | ≤8192 | PASS |

frontmatter 门禁：`git diff agent/skills/spec-workflow/SKILL.md | grep '^[-+]name:\|^[-+]description:'` 零输出（逐字节不变）PASS。

## 二、结构门禁（G1/G2）

- href 闭合：两 skill 全部 `.md` 互引 `test -f` 零坏链 PASS；spec-workflow 目录内 `refs/planning.md|refs/convergence.md` 零残留引用 PASS（两文件 `git rm`，git 识别为向 `spec-plan/refs/` 的 rename）。
- 关键词归属：`独立性铁律`/`设计树`/`六字段` 在 spec-workflow 入口零残留 PASS；`问执行模式` 在两份新 planning 文件与 spec-plan 入口零残留 PASS；执行纪律关键词（`SKIPPED`/`executed`/`子仓`/`凭据`/`留痕`/`不等同于审核通过`/`豁免`）在 execution.md PASS；`limit 8 reached` 行、`grill-me`/`三选一` 从执行侧 failure-modes 移除 PASS。
- 委托指针：spec-workflow §四 含「加载 spec-plan / 原样转发 / 确认执行模式与引擎 / 栈识别结论已写入 design.md 决策记录」PASS。

## 三、配置门禁（G5）

- `dsh/spec-workflow.yaml`：git diff = 仅 2 行注释新增（键归属说明）+ 用户侧 provider 改动（范围外，不提交）；**提交采用 hash-object 精确暂存**——index = HEAD 内容 + 注释行，provider 改动保留工作区。
- 路由自检：工作区版本（含用户 `zai`→`zai-coding-cn` 改动）「OK 全部路由 ⊆ 白名单」exit 0；HEAD 基线同过 exit 0。

## 四、运行时门禁（G4）

- skctl：经 node 容器 `run.sh node … cli.ts install …/agent/skills/spec-plan` → `installed: spec-plan`；聚合层 `/home/docker/.agents/skills/spec-plan` symlink 指向仓库目录、SKILL.md md5 一致。
- 加载冒烟：会话内按名加载 `spec-plan`（返回规划半程版全文）与 `spec-workflow`（返回委托化版全文）均完整、无裁剪标记；base directory 解析为聚合层路径。
- 命令：`~/.dsh/commands/spec-plan.md` symlink 在位、`readlink -f` 命中源本；命令面板可见性属 GUI 观察，留用户核验（兜底 `/commands-reload`）。

## 五、规格门禁（G3）

- `openspec validate split-spec-plan-skill --strict` → **valid，exit 0，无 error/warning**（落档时 + 口径修正后复验两次）。
- Requirement 正文长度：spec-plan 11 条 max 443、spec-workflow 18 条 max 303，全部 ≤500 无告警。

## 六、偏差记录

- **D-1**：`openspec validate --strict` 不允许 MODIFIED Requirement 丢弃既有 Scenario → 「子代理与用户的交互中转」「栈识别与 writer skill 加载（阶段 1.7 与阶段 3）」由 MODIFIED 改为 **REMOVED + ADDED 重构更名**（执行期口径），先例 `split-project-mcp-plugin`；delta 计数由 MODIFIED×8/REMOVED×4/ADDED×4 修正为 **6/6/6**（proposal/design 同步）。
- **D-2**：用户落档确认时补定「审核-提交分离扩为**全模式**口径（完成后不自动提交，停留呈证等确认；豁免须用户明示）」→ delta「执行模式与提交节奏」增 auto 完成后停留呈证 Scenario、proposal/design/tasks 同步，单独提交 `696988b`。
- **D-3**：spec-plan SKILL.md 首版断言「问执行模式零残留」未过（总览委托衔接句含该串），改写为「确认执行模式与引擎」后过；重跑 exit 0。
- **D-4**：execution.md 首版断言「不等同于审核通过」未过（写成 ≠ 符号），改文字表述后过。
- **D-5（误报更正）**：勘察期「白名单缺 zai-coding-cn」为 `grep -A8` 截断误报——repo 与活 profile 白名单均含 `zai-coding-cn/glm-5.3(-flash)`，用户 provider 切换三处自洽，无需操作；已在呈证时向用户更正。
- **D-6**：tasks 1.2 验证句的「7 个字段/独立性」子句在首轮实跑中被省略，组5 补跑通过（其余断言首轮全过）。

## 七、提交纪律（G6）

| 提交 | 内容 |
| --- | --- |
| `6258465` | `docs(openspec): 落档 split-spec-plan-skill`（四件套 + delta，5 文件 695 行） |
| `696988b` | 口径修正（D-2） |
| `6b0c80f` | `feat(skills): 拆分 spec-workflow 规划半程为独立 spec-plan skill`（实现批次，13 文件 +383/−203；yaml 仅注释 hunk 入库） |
| 归档提交 | 见归档节（待用户确认后执行） |

一律显式 `git add`；**排除** `dsh/profiles/web/cordis.patch.yml`（活 profile，用户白名单/provider 改动）与 `nvim/lua/plugins/jdtls.lua`（无关脏改动）。

## 八、宿主操作清单（本流程不代劳）

- ~~skctl 登记 spec-plan~~ 已由本流程经 node 容器完成，无遗留。
- 用户侧：`git push origin master`；GUI 命令面板肉眼确认 `/spec-plan` 出现（未出现则会话内 `/commands-reload`，仍不可见再 `docker compose restart dsh` 兜底）。
