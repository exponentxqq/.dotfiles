# Proposal

## Why

smoke-testing-local-env 的阶段 3 只规定了用例**资产格式**（`smoke/cases.md` 七列、编号规则、入库纪律），没有规定「**从需求到用例**」的设计期方法论——建库或补用例时靠 agent 自由发挥，易遗漏场景（异常/边界/权限/幂等/兼容性），易产出「验证功能正常」式不可判定用例。本变更为其补一份独立的测试用例设计标准，把用户给定的「五步工作法 + 三段式输出格式」固化为可执行规范。

## What Changes

- **新建** `agent/skills/smoke-testing-local-env/refs/test-case-design.md`（≤160 行，六节）：适用时机与输出分级（建库/直接交付=完整三段式，单任务补新用例=增量）、五步工作法、测试点清单表（5 列）、测试用例表（11 列：TC-001 递增、P0/P1/P2 设计期口径、步骤编号与预期对应、数据具体、禁笼统描述）、接口型 8 项与页面/App 型 6 项附加覆盖、覆盖说明与风险三小节、11 列→七列入库映射（「证据要求」列按 reference §5.1 三层证据口径派生；用例ID/优先级/覆盖需求/备注四列不迁移）。
- **三处指路接线**（内容本体不混入既有文件）：SKILL.md L108 行尾同行追加（188 行不变）；`refs/reference.md` §6.2 代码块后插 1 行 blockquote（583→584）；`refs/project-profile-template.md` §7 L79 尾注扩写（纯文本文件名，防项目仓坏链）。
- **文档子目录化（落档后用户裁决并入）**：`git mv` `reference.md` 与 `project-profile-template.md` 入 `refs/`（内容零改动、R100 纯移动），新文件同落 `refs/`；`SKILL.md` 与 `scripts/` 留 skill 根；SKILL.md 冻结区授权三行（L19/L20/L57）仅更新链接目标为 `refs/` 前缀（链接文本与用途描述逐字不变）。
- **spec delta**：`smoke-testing-local-env` 新增 2 条 ADDED Requirement——「用例设计标准」（五步流程 + 接口型 8 项 / 页面型 6 项附加覆盖 + 三段式分级输出）与「设计稿入库收敛契约」（四列不迁移 + 七列续接 + 证据要求派生 + 优先级边界），共 4 Scenario；MODIFIED 1 条「文档结构兼容约束」（授权 refs/ 结构与三行链接更新）；其余 7 条 Requirement 零删除零改写。
- **顺带修（D6 决议）**：`agent/skills/spec-plan/refs/routing.md` 自检脚本白名单解析兼容 flow/block 两种 YAML 形态（现正则只认 flow-style，而 `cordis.patch.yml` 实为 block-style，自检永远误报白名单为空）；spec-plan 主规格零改动（其 13 条 Requirement 零管辖自检）。

### 非目标

- 不改 `smoke/cases.md` 七列资产契约与 `<组>-<两位序号>` 编号体系（11 列设计稿是设计期推导稿/交付物，不是第二入库资产）。
- 不动冻结区字节——除 MODIFIED「文档结构兼容约束」授权的 SKILL.md L19/L20/L57 三行链接目标更新外，SKILL.md L1–60 与 `refs/reference.md` L1–18 逐字节不变；reference 既有节号一个不少、不新增子节；迁移为 `git mv` 纯移动，两文档内容零改动。
- 不改 SKILL.md L3 触发词（D1 决议：「直接交付用例」限定被测项目/冒烟语境内或点名文件）；不动 `scripts/` 位置与其命令路径。
- 不迁移 P0/P1/P2、TC 编号、覆盖需求、备注四列入库（D4 决议：优先级仅设计期口径，执行仍按编号升序）。
- 不处理外部在途脏文件（`dsh/profiles/web/` 3 个、`add-subagent-control-and-coordination` 3 个、`agent/skills/spec-apply/refs/coordination.md` 未跟踪 1 个）；不触碰 add-ui-demo-gate 变更工件（其引用随迁移失效的提示见 Impact）；不推送远程。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `smoke-testing-local-env`: 新增 2 条 Requirement——「用例设计标准」与「设计稿入库收敛契约」；MODIFIED 1 条「文档结构兼容约束」（授权 refs/ 子目录结构与 SKILL.md L19/L20/L57 三行链接目标更新）（完整 delta 见 `specs/smoke-testing-local-env/spec.md`；ADDED 原定 1 条因 `openspec validate --strict` 的 >500 字符警告按建议拆分，语义零变化）。

## Impact

- `agent/skills/smoke-testing-local-env/`：`refs/` 子目录新增 1 文件、`git mv` 迁入 2 文件（R100 纯移动）、编辑 SKILL.md（L108 指路 + 授权三行链接）与 `refs/reference.md`（+1 行指路）、`refs/project-profile-template.md`（尾注扩写）。
- `agent/skills/spec-plan/refs/routing.md`：L49 单行扩为 4 行双形态正则（67→70 行）。
- `openspec/specs/smoke-testing-local-env/spec.md`：归档 sync 后 10 Requirement / 18 Scenario（新增 2 条 + MODIFIED 1 条）；diff 删除行仅出现在「文档结构兼容约束」节内，其余 7 条零触碰。
- add-ui-demo-gate 变更工件**不改**，但其对 `smoke-testing-local-env/reference.md:19` 的路径引用随迁移变为 `refs/reference.md:19`（行号与内容不变）；该变更剩余任务执行时按新路径解析，本变更在其 proposal/design 留痕即可。
- skill 经 `~/.agents/skills/` symlink 分发（目录整体 symlink，子目录随迁即时生效）；无构建、无运行时依赖。
