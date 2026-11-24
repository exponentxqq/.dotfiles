# Design

## Context

- 触发实证：benchmark T7.3 会话 `session-8330ed6c-e979-4ddb-b5b7-ce4c2ea4a1ee`（cwd `/home/xuqinqin/develop/company/workstation`）。47 次 `subagent` 派发（2026-11-24T17:10+08:00 复算）：17 次显式路由，**30 次缺失**；首个缺失 `apply-6-2`（2026-11-24T04:54:06Z）紧跟压缩 #2（04:43:49Z）；子会话 `request/header.config` 实测为 `zcode-plan/glm-5.3`。压缩 #1（02:50Z）后未漂移，因为用户随后重发 `/spec-flow continue`（skill 重载）。
- 平台事实：`@deepseek-ai/dsh-tool-subagent` 的 `requestedAgentOptions` 在无路由请求时返回 configured/继承父路由；`assertAllowedModelSelection` 只对显式 `provider`/`model` 生效。省略 = 静默继承，白名单不拦。
- 触达面全为 markdown；验收 = grep 常量 + 码点（cp）长度门 + `openspec validate --strict`，无构建/测试门。
- 工作区有 4 个既有未提交脏文件（`dsh/profiles/web/*` 3 个 + `opencode/opencode.jsonc`）：本变更零触碰、零暂存、零提交。

## Goals / Non-Goals

**Goals:**
- 压缩后可只读工件重建执行侧路由，派发不再依赖会话记忆。
- 派发省略路由时，子代理在写文件之前发现模型不符并停手上报（fail-closed）。
- 映射文件仍是唯一权威；快照与登记行只是已解析副本/审计记录。
- v3 登记簿与在途变更不被新规则阻断（`ROUTE-LEGACY` 降级）。
- 文档长度不越既有硬界；零模型值、零 profile 改动。

**Non-Goals:**
- 不改 DSH 平台层、不改 profile/白名单、不新增插件（`tools/pre-execute` 强制注入留作后续）。
- 不重跑/回溯修复 benchmark T7.3 已漂移的 30 个任务（该会话/worktree 仍在途，且不解决成因）。
- 不引入规划期持久台账（`spec-plan/refs/planning.md` 仅余 166 cp，且规划期无派发台账语义）。
- 不提交、不归档：本变更保持 active，用户复核后再归档。

## Decisions

**D1 路由快照文件而非「只靠摘要/只靠 skill 重载」**
- 位置 `/tmp/spec-flow/<change>/routing.md`，与登记簿同域同生命周期（`spec-done` 清理 `/tmp/spec-flow/<change>/` 时一并删）。
- 内容：`apply`/`apply_fallback`/`vision`/`verify`/`engine`/`parallelism` + `source` + `history`，另含**一行自证契约**（省略=静默继承、失配 `ROUTE-MISMATCH`、快照缺失 `ROUTE-LEGACY`）——压缩后只读该文件即可恢复派发契约（P0 演练实证）；值用占位符描述，**文档不写具体模型值**。
- 理由：压缩后「会话记忆」与「摘要」均不可靠（摘要含路由仍漂移），文件是唯一可被 lead 与子代理共同读取的锚点。
- 被否：只强化文档警告（反证已存在）；把快照写进登记簿 header（登记簿 20KB+，tail 读不到；独立文件更易发现与自证）。

**D2 子代理自证（fail-closed）而非「lead 事后核对」**
- 子代理读快照本键路由，比对系统提示 `You are a coding agent powered by <model> model`；不一致 → 停手不写文件 + `send_message(agent="lead")` 上行 + 回执 `ROUTE-MISMATCH`。
- 理由：错模型产出 30 分钟的返工成本远高于一次「停手重派」；且 lead 事后核对时错误产出已落地。
- 被否：只回执 `ROUTE-ACK` 事后判定（错产出已落地）；由 lead 在派发前自检（正是本次失效点）。
- 假失配（同模型不同显示名）由 lead 裁定放行（`reason=ACK-ADJUDICATED`）；无模型声明时跳过自证并注明。

**D3 登记簿 v4 + 逐行 `route=` 审计**
- 行字段新增 `route=<provider>/<model>|inherit`；`inherit` 仅映射为空/三档回退②并记 reason；`reason` 扩展支持 `ROUTE-DRIFT actual=<模型>`。
- 理由：回执是会话内易失信息，登记行是跨压缩的逐任务审计；组收尾可机械比对「回执首行 vs 行 route」。
- 被否：不记 route（丧失逐任务审计与人工复核抓手）；只记在快照（丢失「哪个任务实际用了哪条路由」）。

**D4 派发必传路由、`inherit` 显式化**
- 快照值为具体路由时派发必传 `provider`/`model`；仅快照值为 `inherit`（映射为空/回退②）时按继承派发并在行留痕。
- 理由：把平台「省略即继承」的静默语义显式化；DSH 白名单不会替我们兜底。
- 被否：改成全局子代理默认模型（影响所有会话与阶段，违背「映射为空沿用会话模型」）。

**D5 v3 legacy 兼容**
- 只有 `routing.md` 存在时子代理才强制自证；v3 登记簿/无快照 → `ROUTE-LEGACY` 继续。
- 理由：在途变更（benchmark T7.3，43/47）仍可能派发最后一两个任务；新规则不得让它们停摆。
- 被否：强制升级 v4（在途会话未重读 skill 时会双写/停摆）。

**D6 规划侧不建快照，改为「提示首行路由键 + 子代理按 yaml 兜底」**
- 规划期无派发台账，且 `spec-plan/refs/planning.md` 仅 166 cp 余量；规则写进 `refs/routing.md`、`mode/parallel.md` 与 SKILL §八 一句。
- 子代理失配停手上行；提示缺路由行时按提示键读映射文件该键值并报告（`--model` 覆盖不可辨由 lead 裁定）。
- 被否：新增 `/tmp/spec-flow/<change>/routing-plan.md`（规划早期变更名可能未定；新增文件与语义面大于收益）。

**D7 spec-done 复用同一快照**
- `spec-apply` 开工时把 `verify` 路由一并写入快照；`spec-done` 读快照 `verify` 行，缺失时按映射文件解析并写回。
- 理由：终末阶段常在压缩之后的会话里启动；`verify` 覆盖与 `apply` 同样易失。

**D8 文档长度硬界与单源**
- `coordination.md` 自设硬界 3800–5000 cp → 上调为 **3800–6400**（v4 字段/注入段/兼容说明实测 +1207 cp，仍低于单文件 8192），并在 §10 明写。
- 其余 SKILL/refs 保持 ≤8192 cp；`spec-plan/refs/planning.md` 仅 166 cp 余量，**不动**；`spec-plan/SKILL.md` 仅 511 cp 余量，只加一句。
- 路由值单源仍是 `dsh/spec-workflow.yaml`；快照/登记行只写 `provider/model` 占位形态，文档中零具体模型值（验证门 grep）。

## Risks / Trade-offs

| # | 风险 | 对策 |
| --- | --- | --- |
| R1 | 子代理自证依赖提示词合规（lead 未粘新注入段） | 快照 + 登记行 + 组收尾核对 + 呈证多层兜底；残余风险在呈证明示 |
| R2 | 模型显示名与路由 model 字面不一致 → 假失配 | lead 裁定通道 `ACK-ADJUDICATED`；无模型声明时跳过自证 |
| R3 | 在途 v3 会话重读新文档 | `ROUTE-LEGACY` 降级不阻断；新行 route 仅 v4 强制 |
| R4 | `/tmp` 被清理 → 快照丢失 | 恢复协议按映射文件 + 笔记覆盖重建；重建前不派发 |
| R5 | 长度门挤压（coordination/planning/SKILL） | coordination 上限上调并同步 §10；planning 不动；SPEC-apply 各文件余量充足 |
| R6 | 双源漂移（快照抄了模型值） | 快照/文档只写占位符；验证门 grep 具体模型字面量 = 0；映射文件零改动 |

## 长度预算（实现前基线 → 硬界）

| 文件 | 基线 cp | 目标/硬界 |
| --- | --- | --- |
| spec-apply/SKILL.md | 3828 | ≤8192 |
| spec-apply/refs/coordination.md | 4990 | **≤6400**（§10 上调） |
| spec-apply/refs/execution.md | 6955 | ≤8192 |
| spec-apply/refs/routing.md | 4436 | ≤8192 |
| spec-apply/refs/failure-modes.md | 2271 | ≤8192 |
| spec-workflow/SKILL.md | 6777 | ≤8192 |
| spec-workflow/refs/failure-modes.md | 1705 | ≤8192 |
| spec-done/SKILL.md | 6139 | ≤8192 |
| spec-plan/SKILL.md | 7681 | ≤8192 |
| spec-plan/refs/routing.md | 4791 | ≤8192 |
| spec-plan/mode/parallel.md | 2371 | ≤4000 |
| spec-plan/refs/planning.md | 7734 | 不变（≤7900） |

## 取证与复算

- 证据脚本：解压 `~/.dsh/sessions/--home-xuqinqin-develop-company-workstation--/session-8330ed6c-…/session.v4.jsonl.zstd`，统计 `tool/call` 中 `name=subagent` 的 `provider`/`model` 字段，按 `subagent/catalog` 反查子会话 `request/header.config`。
- 复算预期：总 47 / 显式 17 / 缺失 30；首个缺失 `apply-6-2`；`apply-6-2` 实际 `zcode-plan/glm-5.3`；压缩 #2 前 14 次显式、压缩 #2 后 30 次全部缺失。
- 证据落 `/tmp/spec-flow/harden-spec-routing-compaction/drift-audit.txt`（易失、不入库）。
