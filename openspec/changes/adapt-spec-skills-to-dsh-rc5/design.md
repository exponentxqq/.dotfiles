# Design

## Context

- 宿主已运行 **dsh 0.2.2-rc.5**（2026-11-23 实测）；`spec-*` 四技能现文按 0.2.2-rc.1 的子代理机制书写，与 rc.5 工具面存在系统性偏差。动机见 [proposal.md](proposal.md)「Why」，此处只记设计约束。
- 平台事实唯一权威源 = 本机 `/usr/local/lib/node_modules/@deepseek-ai/dsh/docs/`（随宿主升级同步）；skill 文本一律写机制、不写死版本号，版本锚只出现在 `coordination.md §1`。
- 触达面 17 项全为 markdown 规范与 delta，**零应用代码**：验收 = grep 常量 + 码点公式 + `openspec validate --strict`，无构建/测试门。
- 用户工作区有未提交改动（`dsh/profiles/web/*`、`dsh/spec-workflow.yaml`）：本变更**不触碰、不暂存**；`dsh/spec-workflow.yaml` 与 `dsh/commands/*.md` 实查后零改动。
- 规划期已完成运行期探针取证（具名派发即返名 / `send_message(agent="lead")` 上行 / 运行中 steer 下行 / 本配置无 `interrupt_agent`），证据摘要见 `code-design.md ②` 与 diff-matrix；证据本体（`/tmp`）不入库。

## Goals / Non-Goals

**Goals:**
- 消灭四技能、`dsh/README.md`、三主规格中的死工具与过时平台断言（`spawn_teammate`、`agent_id`、下行不可达、成员上限 8、team 成员无模型参数、`run_in_background`）。
- 用 rc.5 原生能力简化自建协议，同时保住持久性机制（登记簿、检查点、单写者、审核-提交分离）。
- 三主规格 delta 通过 `--strict`，归档后主规格与技能文本一致。

**Non-Goals:**
- 不改 dsh 平台层、不改 profile、不 re-enable `interrupt_agent`（宿主操作）。
- 不引入 `task_board_*` / `notes_*` / `workflow` / `subagent_fork` 作为编排骨架（见 Decisions D10 留痕表）。
- 不重设计 worktree、归档链、1.75 演示 gate 等既有机制（仅做引用面核对）。
- 不处理「栈判据的纯文档分支之外的新语言栈」——本次只加纯文档类分支（D12）。

## Decisions

**D1 栈识别结论：writer skill = `writing-skills`（用户指认）**
- 证据：聚合层 `/home/docker/.agents/skills/writing-skills/SKILL.md` 可加载（本会话已验）；Spring/Nuxt 判据实测零命中（无 `pom.xml`/`build.gradle`、无 `nuxt.config.*`、无 `nuxt` 依赖），触达面 17 项全为 markdown。
- 被否：`spring-writer`（判据零命中，会引入 Java 分层规范）；`nuxt-writer`（判据零命中，会引入 pages/components 规范）；`dsh-plugin-writer`（作用域为插件仓 TypeScript/配置，本变更零插件源码）。
- 该结论是执行侧接线依据（spec-apply 从本工件读取，不依赖会话记忆）。

**D2 引擎形态：subagent 为默认核心，team 保留为可选（用户裁定）**
- 理由：Team 模式与 subagent 的唯一功能差异是共享任务板（`team_task_*`）；并发名额同一树池（`maxActiveSubagents` 默认 8），Team 模式不增加并发；Team 是根会话级开关（用户在菜单开启，模型不能自开）。
- 被否：只留 team（规划半程无板可用、未开会话时流程阻塞、多一份进度源）；只留 subagent（放弃依赖图/认领/写范围告警能力）。详见 proposal「What Changes」。

**D3 登记簿保留并升 v3：`agent` 记 name（用户裁定 + 事实）**
- 理由：具名派发解决**寻址**，不解决**对账**——`list_agents` 的 running/inactive 不描述任务完成，树枚举不落盘；派发回执只返回 name（`started subagent <name>`），session id 对模型面不可见。命名规约使 name 在派发前可推导，满足「先登记全批条目再并发派发」。
- 被否：把登记簿换成宿主任务面板/便签（第三方插件、宿主侧不入库、无写范围状态机）；轮询 `list_agents`（非持久）；双记 name+uuid（uuid 不可得）。

**D4 上行两类、软废止下行通知（用户裁定）**
- 上行事件裁为 `决`/`异`：`成` 的预读收益由 settle 自动完成通知（含最终回答）+ 登记簿覆盖。
- 软废止追加一次 `send_message` 下行通知：生效时延从「下一检查点」缩短到「最近步骤边界 + 检查点确认」；**登记簿仍是唯一权威令**，通知只加速，不改变检查点的权威地位。

**D5 待决回送：同实例续话优先（用户裁定）**
- 理由：rc.5 本地子代理结束后 `send_message` 即续轮，保留上下文；省一次重放。任务**失败重试**仍 `fresh` 新名（`-r2`）一次——「回送是问、重试是 redo」。
- 被否：维持 fresh 接续重派（放弃 rc.5 主要收益）；续话与重试混用（上下文污染）。

**D6 命名规约：角色前缀 + 任务号（用户裁定）**
- `plan-a`/`plan-b`/`panel-<n>`/`design`/`apply-<组>-<任务>`/`verify-<n>`；重派追 `-r<n>`；重名被拒追加变更短码（`-<首段6><名长>`，如 `-adapt28`）；硬约束 ≤32 字符、小写 kebab、非 `lead`。
- 被否：变更名短码+名长（规则绕、可读性差）；变更名截断 12（碰撞概率高）。

**D7 受控嵌套：只许只读孙代理（用户裁定）**
- 规则：执行子代理不得再派**可写**子代理（登记簿不覆盖下一层）；检索/分析/复核类可派只读孙代理，提示自包含、写明「只读：不写文件、不 git」并转述本任务硬约束，产出由派发者核对。
- 理由：本 profile `maxDepth: 2` 使孙代理可达；不写纪律则写面绕开单写者与检查点。价值在上下文隔离而非并发。
- 被否：一律禁止（放弃上下文卸载与独立复核收益）；完全放开（写面无约束）。

**D8 升级判据缩为单条（用户裁定）**
- 四条旧判据（审核被拒≥2 / 检查点间叫停 / 多轮互商 / >2 轮澄清）理由全部失效；唯一剩余价值 = 任务板（依赖图 `blocked_by`、动态认领、`write_scopes` 重叠告警、面板可视）。判据只在派发前提示，不自动切换。

**D9 spec-plan 侧：具名 fresh 子代理单机制（用户裁定 + 平台事实）**
- `spawn_teammate` 已移除；两线以 `subagent(name=plan-a/plan-b)` 同消息派出、即返名，独立性铁律与 7 字段契约不变。规划键路由恒适用（成员即子代理，无编排例外）。

**D10 新工具面「暂不采用」留痕（用户裁定）**

| 工具面 | 来源 | 采纳 | 理由 |
| --- | --- | --- | --- |
| `task_board_*` | 第三方 `@linxin666/dsh-client-ui-task-board` | 否 | 宿主面板语义、宿主侧不入库、无写范围状态机；与「权威进度 = 工件 + 勾选态 + 提交历史」冲突 |
| `notes_*` | 第三方 `@zzerx/dsh-plugin-notes` | 否 | 便签非协调台账；同上 |
| `workflow` | 官方（大规模扇出编排） | 否 | 双线规划用普通 subagent 即可；显式请求才适用 |
| `subagent_fork` | 官方（继承父对话） | 否 | 继承对话破坏规划线独立性铁律；preset 保持其路由字段关闭 |

**D11 触达面补入 3 文件（用户裁定）**
- `spec-plan/refs/planning.md`（1.7 模板仍教 `agent_id`）、`convergence.md:27`（回送旧措辞）、`dsh/README.md`（spawn/成员上限/回送表）——不补则终检死名门自相矛盾，且下一次设计线派发继续复制旧断言。

**D12 栈判据并入「纯文档类默认 `writing-skills`」分支（用户裁定，与设计线原推荐相反）**
- 理由：本仓长期只有 skill/文档改动，Spring/Nuxt 判据恒零命中，每次 1.7 都要走三选一；新增分支后此类变更直接命中 `writing-skills`。属行为变更，故本变更同时改判据、SKILL.md 与 spec-plan delta（MODIFIED 保留 7 个现有 Scenario 名 + 新增 1 个）。
- 长度预算：`spec-plan/SKILL.md` §六 新增 ≈45 cp 以 §四/§八 删除等量抵扣（正文仍 ≤7507、净增 ≤0）；`planning.md` 净增 ≈80（门 ≤7900）。
- 被否：另立小变更（用户明确选择顺带改）；不改（每次仍要三选一）。

**D13 delta 形态（用户裁定）**
- 含废弃 Scenario 的 Requirement 一律 `REMOVED` 整条 + `ADDED` 新名（validator 禁止 MODIFIED 省略现有 Scenario）；其余用 `MODIFIED` 并保留全部现有 Scenario 名。归档后主规格 5 处 Requirement 名变化。

**D14 衔接裁定与执行环境（执行期，用户裁定）**
- 模式 `auto`（参数未预置，衔接点询问后选定）；引擎 `subagent`（映射文件 `engine`，未传 `--engine`）；模型覆盖无（未传 `--model`）：`apply` 键 `opencode-go/deepseek-v4.1-flash` 本会话授权已核可用；`verify` 键 `zcode-plan` 本会话未授权 → 走 fallback `opencode-go/deepseek-v4.1-flash`，按 spec-apply 自检规则留痕。
- 任务 6.1 处置：`openspec/specs` 子项**归档后复验**——主规格仅由归档同步，执行期 grep 范围收为 `agent/skills dsh/commands dsh/spec-workflow.yaml dsh/README.md`（「接续重派」的 `openspec/specs` 子项同此处置）；该子项移交 spec-done 归档后复验门，追加断言 `grep -rn 'spawn_teammate\|Team member limit\|agent_id\|互不可达\|run_in_background' openspec/specs` 无输出。
- 执行环境：直用主工作区。布局：无 worktree，全部触达面在根仓主检出 `/home/xuqinqin/develop/dotfiles` @ `master`；装配：无（零应用代码、纯 markdown，无装载单元）；环境错开：无；装载指纹：无；创建于 2026-11-23
- 脏改动隔离纪律（R10 落地）：每批次提交以**显式路径**暂存本变更文件（17 项触达面 + `openspec/changes/<change>/` 工件），`dsh/profiles/web/*` 与 `dsh/spec-workflow.yaml` 四文件零触碰、不入暂存区。

## Risks / Trade-offs

| # | 风险 | 对策 |
| --- | --- | --- |
| R1 | rc 线再漂移（rc.5→正式版） | 平台事实集中在 `coordination.md §1`；其余文件写机制；版本锚只此一处 |
| R2 | name ≤32 字符与长变更名冲突 | 角色前缀+任务号规约；重名被拒追加短码，再拒即上行「异」 |
| R3 | steer 是步骤边界尽力语义 | 检查点保留为机械底座；下行废止通知只是加速器 |
| R4 | 同实例续话上下文膨胀 | 续话限短回合（答复/审核意见）；失败重试恒 fresh |
| R5 | Team 模式是用户菜单动作 | `--engine team` = 提示开启 + 未开启回退并留痕，不假装已用 |
| R6 | `interrupt_agent` 双态 | 文档写「本配置下不可用」；派发前按工具面自检，不写死平台结论 |
| R7 | 长度门挤压（spec-plan 正文 7507 上限） | §四/§八 删除等量抵扣；验证句写死 `len(正文) ≤ 7507` |
| R8 | 执行期新旧协议交替（狗粮回环） | 组序 spec-apply 先行（协议源→消费面）；同组文件同批提交；不用已删机制 |
| R9 | delta 面识别不全 | 三主规格 + `dsh/README.md` 全量 grep 收口（任务 6.1）；MODIFIED 名集与主规格逐字核对 |
| R10 | 用户未提交改动混入提交 | `dsh/spec-workflow.yaml`/`dsh/profiles/web/*` 零改动；提交只含本变更 17 项 + 两材料 |
| R11 | 在线并发容量（8/树） | 单组 ≤ `parallelism`=8；超限为容量控制器延迟而非失败 |
