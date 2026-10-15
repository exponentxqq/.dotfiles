# Proposal

## Why

spec-workflow 的五阶段流水线中，代码级设计深度没有结构保证：阶段 1 双线规划自述为「轻量」草案（设计意图，不应加码），阶段 2 的 design.md 由主会话落档时一次性写出且流程对它唯一的约束是存在性（深度取决于当轮发挥），代码级设计实际被隐式下放给阶段 3 的 fresh 执行子代理（`apply` 快路由、跨任务结构性决策无人统筹）。设计错误比需求错误更晚暴露、返工成本更高，双线规划的异构交叉验证价值没有延伸到设计层。

## What Changes

- 新增子阶段 **1.7 代码设计线**（阶段 1.5 收敛结束后、阶段 2 落档前）：恒派一个 fresh 子代理（新路由键 `design`，默认 `zai/glm-5.3`），整合性阅读需求原文 + 两线草案 + diff-matrix，产出受结构化深度契约约束的 `code-design.md`
- 深度契约 = 内容六字段（触达面清单 / file:line 证据锚 / 接口与数据形状 / 决策记录附被否反例 / 逐任务组实现要点 / 设计假设与未决项）+ 行为二约束（验证映射落具体命令或断言；不推翻收敛结论，矛盾一律上浮）
- 小需求**三档分降**（L2 全深度 / L1 部分字段单行简述 / L0 trivial 判据命中豁免 fresh 派遣、由收敛代理 inline 一行断言落档），产物 schema 恒定、零新增参数
- 落档输入由四材料扩为五材料（+code-design.md）；design.md 继承深度并落档逐断言核对
- 执行衔接：阶段 3 任务提示的「相关 spec/design 摘录」契约化为「design.md 所属组要点逐字引用」；tasks 每任务引用触达面条目编号（硬契约）
- 设计期上浮项接线到落档第 3 步「分歧点提问」（既有钩子，显式接线）
- 配套：`dsh/spec-workflow.yaml` 增 `design` 路由键、routing.md 键表、dsh/README.md 同步、failure-modes.md 并入设计线失败同构处置一句
- 工程约束：入口 SKILL.md 净零改写（渲染余量仅 ~20 码点）、主规格归档同步净增 ≤0 码点、frontmatter name/description 逐字节不变

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `spec-workflow`: 新增「代码设计环节」Requirement（1.7 设计线、深度契约、三档分降、落档继承）；「落档工件与执行批次契约」增第 5 输入材料与 design 深度契约核对、tasks 触达面引用硬契约；「子代理与用户的交互中转」增设计期上浮项并入落档分歧点提问的时机条款；「subagent 执行引擎」任务提示含所属组要点逐字引用；「阶段级模型路由」键枚举 +`design`

## Impact

- 代码：`agent/skills/spec-workflow/`（SKILL.md 净零改写、planning.md 新节承接展开、execution.md 提示模板契约化、routing.md 键表、failure-modes.md 一句并入）；`dsh/spec-workflow.yaml`（+design 键）
- 文档：`dsh/README.md` spec-workflow 节（流水线图、路由表、文件表）
- 规范：`openspec/specs/spec-workflow/spec.md`（归档同步，净增 ≤0 码点）
- 不影响：openspec CLI 与 openspec-propose 本体、阶段 1 双线轻量定位、convergence.md（1.5 判据）、frontmatter、部署形态（local symlink 改源即生效）
- 后续所有 `/spec-flow` 调用每次 +1 轮设计线派发与核对（L0 档豁免 fresh 派遣）
