# Proposal

## Why

spec-plan 向用户的追问散布在 9 类落点（参数收集、OpenSpec 根三选一、中转代问、1.5 收敛决策、栈识别三选一、1.75 演示确认、落档分歧点、纠错与异常通道），承载与问法无统一约定——全仓仅 convergence.md 末行泛泛提「用提问工具」而未点名工具，问题也常缺背景与选项区别，执行侧问法含糊、用户体验不一。用户要求把追问机制统一为：所有追问经结构化提问工具发起、每问附背景说明与详细解释、必要时列选项详细区别并可举例。

## What Changes

- `agent/skills/spec-plan/SKILL.md` 新增独立「追问契约」节（§十，258 码点，纯追加不重编号）：工具强制（宿主结构化提问工具，DSH 为 `ask_user_question`）+ 每问附背景与解释 + 多选项列区别/涉代码配置可举例 + 适用范围含纠错与异常处置。
- spec-plan 其余 6 文件（refs/convergence.md、refs/planning.md、refs/failure-modes.md、refs/routing.md、mode/serial.md、mode/parallel.md）在各自追问落点加一句接线，统一指向 §十；convergence.md 末行点名工具。
- `agent/skills/grill-me/SKILL.md` 新增英文「Carrier by host」段（双轨自适应）：有结构化提问工具的宿主经工具承载每轮（问题含背景/解释、选项附区别、推荐置首标注）；无工具宿主保持既有 ❓Q/➡️ markdown 轮格式；方法论两轨共用。既有 32 行逐字不动。
- spec delta ×2：`specs/spec-plan`（只 ADDED 1 条「追问交互契约」，既有 12 条 Requirement 逐条核对 0 冲突、0 MODIFIED）+ `specs/grill-me`（新建 capability：承载自适应 + 每问质量与推荐）。

## Capabilities

### New Capabilities

- `grill-me`: 追问访谈的轮次承载——宿主自适应双轨（有工具宿主经结构化提问工具承载每轮，无工具宿主保持 markdown 轮格式）与每问质量（背景、解释、选项区别、举例、置首推荐）。

### Modified Capabilities

- `spec-plan`: 新增「追问交互契约」Requirement——全部追问（含纠错与异常处置）经宿主结构化提问工具承载、附背景与详细解释、多选项列区别并可举例；子代理仍按中转协议上浮；grill-me 轮次承载委派给 grill-me capability。既有 12 条 Requirement 语义不变（0 MODIFIED）。

## Impact

- 触达全部在 dotfiles 根仓：8 个 skill markdown 文件 + 2 个 spec delta + 变更工件；无代码、依赖、CI、配置键变化。
- `dsh/spec-workflow.yaml`、命令薄壳、README、`openspec/specs/` 主规格均不改动（主规格只由归档经 delta 同步）。
- SKILL.md 入口长度受既有「单次加载完整交付」Requirement 硬约束：本设计后 7945 码点 / 渲染 8049 ≤ 8192，余量 143。
- 既有「1.75 三选一问法」不在主规格 12 条内（在未归档变更 add-ui-demo-gate 的 delta），本变更 0 MODIFIED；其三选项语义由 planning.md 就地注记保证。
