# Proposal

## Why

`smoke-testing-local-env` skill 现行规程允许「边测边想用例」：用例矩阵只在收尾报告中事后呈现，既不是执行前的强制产物，也无法跨执行复用——复测要重写用例、负例易漏、证据链易缺口，「页面提示成功 ≠ 数据落库」的验收口径缺少可逐项核对的载体。用户要求把「先写用例、再逐项执行」固化为强制规程，并将用例沉淀为所测项目的长期资产以便后续复测。

## What Changes

- 规程从六阶段扩为七阶段：在「零侵入链路」后新增**阶段 3「准备测试用例（不可跳过）」**，「浏览器执行」升级为**阶段 5「按用例逐项执行」**（前置执行纪律）。
- 用例成为长期资产：落**所测项目根 `smoke/cases.md`**——七列固定（编号/用例/类型/前置/步骤/期望结果/证据要求）、稳定编号（`<组>-<两位序号>`）、废弃标记不删行；复测直接按库执行，库缺失才现场编写建立。
- 每次执行产生独立**运行目录** `smoke/runs/<YYYY-MM-DD>-<full|任务号>/`：`record.md` 逐项回填结果（通过/失败/N/A/观察项）与证据、`report.md` 结论报告、截图等二进制由新建的 `smoke/.gitignore` 忽略（markdown 入库）。
- skill 区分**全量 smoke**（跑库内全部在用条目）与**单任务 smoke**（受影响子集 + 新用例，收尾**硬性**回写 `cases.md`）；模式按用户话术判定、存疑必问。
- 归档默认改为运行目录收纳（画像 §9 可覆盖路径）；`reference §7.4` 洁净核验增加「预期入库改动」白名单（用例库回写与运行记录入库不再是「污染」）。
- frontmatter `description` 同行替换补触发词（全量冒烟、复测、回归、上线前验收）。
- 验收口径绑定用例库：「所选用例在运行记录中全部有结果且无失败项」「未写入用例库的项不构成验收范围」「单任务新用例未回写不算完成」。

## Capabilities

### New Capabilities

- `smoke-testing-local-env`: 本地环境端到端冒烟验证 skill 的行为规程——七阶段流程、用例库资产契约（cases.md 七列与稳定编号）、运行目录契约（record/report/截图忽略）、全量与单任务双模式判定与收尾差异、逐项执行纪律与验收口径。skill 此前无 spec 管辖，本次为其建立首个能力规格。

### Modified Capabilities

（无——既有 specs 只覆盖 spec-* 系列与 ui-demo/grill-me，与本变更无交集。）

## Impact

- **触达文件**（全部在 dotfiles 根仓）：`agent/skills/smoke-testing-local-env/SKILL.md`（中，156→约 200 行）、`reference.md`（大，424→约 550 行）、`project-profile-template.md`（小，91→约 96 行）；`scripts/`、`agent/skills/README.md`、`openspec/` 零触达。
- **冻结约束**：SKILL.md L1–60 与 reference.md L1–18 行数与字节基本不变——仅授权 L3（description）与 L11（六阶段→七阶段）两处**同行替换**（1 行→1 行，行号零位移；L11 不被任何活跃变更按行号引用），保护活跃变更 `add-ui-demo-gate` 对 `SKILL.md:30-34`、`reference.md:19` 的行号引用。
- **分发即时性**：容器 `~/.agents/skills/smoke-testing-local-env` 为 symlink，改动即对 opencode 与 dsh 生效，无构建步骤。
- **外溢产物**：所测项目仓将新增 `smoke/`（cases.md、.gitignore、runs/）——仅由本 skill 规程定义形状，不属于本变更的代码改动。
