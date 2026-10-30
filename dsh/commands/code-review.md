---
description: 严格的代码评审（变更/指定代码块/业务流程三类目标，OCR 委托分工，报告后可派发子代理修复）
argument-hint: "[评审目标：diff/分支/commit/文件/流程描述，空=当前工作区变更]"
---
请以严格的代码评审者（code reviewer）角色执行一次评审：评审代码的质量、安全与最佳实践。

评审目标：$ARGUMENTS
（为空 = 评审当前工作区的全部未提交变更：staged、unstaged、untracked。）

## Review Scope

按评审目标匹配三类评审之一：

1. **变更评审** — 目标是一个变更（diff、commit、分支、PR，或空参数默认的工作区变更）。关注改了什么、为什么改、对系统其余部分的影响。
2. **指定代码块评审** — 目标是一段具体逻辑（函数、类、文件或描述的行为），即便早已提交。定位确切代码，就事论事评审，不看 git 历史。
3. **业务逻辑/流程评审** — 目标是一个业务流程或功能（如「审核整个面试流程」「review the payment flow」）。代码横跨多文件多层：你自己发现完整代码路径——入口、编排、持久化、错误路径——然后端到端评审整条链，不局限于用户点名的文件。

意图不明确时先问清是哪一类，不要猜。

## Review Focus

1. **Correctness** — bugs、竞态条件、off-by-one、逻辑错误
2. **Security** — 注入、密钥泄漏、不安全的反序列化、缺失校验、敏感数据打日志
3. **Performance** — 明显低效、N+1 查询、热路径上的分配
4. **Maintainability** — 命名、重复、死代码、复杂度、错误处理
5. **Consistency** — 遵循代码库既有约定、import、风格

## Workflow

1. 确定评审目标类型：变更、指定代码块或跨文件的业务流程。后两类按用户描述定位确切代码（文件路径、函数名、符号或行为）；流程类追全链：入口 → 编排 → 数据层 → 回调/错误路径，跨文件跨层。
2. 读真实代码——不要只看 diff 摘要或用户转述。
3. 理解上下文：代码该做什么、谁调用它、它调用谁、数据怎么进出。变更评审还要评估对系统其余部分的影响。
4. 评审逻辑本身——边界条件、错误路径、隐含假设、死分支——不只看风格。
5. 按严重级别排序输出 findings。
6. （可选）修复派发与复核——用户希望修复时按「修复派发」一节执行，并在完成后复核。

## 评审纪律（只读）

评审阶段是**只读**的：不修改任何文件、不提交任何东西；shell 只允许只读 git 子命令（status / diff / log / show）与下文的 `ocr delegate` 命令。修复必须走「修复派发」并经用户确认。

## OCR 委托审查（变更评审的默认流程）

变更评审（场景 1：diff / commit / 分支 / PR / 空参数工作区变更）优先使用 OCR（open-code-review）delegation 模式。分工：OCR 负责确定性的文件选择与规则匹配，你负责实际审查——OCR 不调用任何 LLM，审查质量由你保证。

`ocr` 包装命令直接可用（透明进 node 容器执行，工作目录自动对齐）。以下命令均为只读，**在项目当前目录直接运行，不要加 `cd` 前缀**。

1. **预览文件清单**

   ```bash
   ocr delegate preview --format json
   ocr delegate preview --format json --from <base> --to <branch>
   ocr delegate preview --format json --commit <hash>
   ```

   无参数 = workspace 模式（覆盖 staged、unstaged、untracked）。输出：`reviewable_files`（path / status / insertions / deletions）、`excluded_files` 及排除原因、`mode`/`from`/`to`/`commit`/`merge_base` 等 ref 元数据。
   - `reviewable_count` 为 0 —— 告知用户没有可审的变更，结束。
   - 若清单里混入明显不该审的文件（生成物、快照、临时产物），用 `--exclude 'a/**,b/**'` 重跑一次，并说明排除了什么。
   - 若评审目标或用户消息提供了需求/业务背景（如「本次改动为订单状态机加幂等」），把要点作为 `--background '<摘要>'` 传给 preview，供审查时参照。

2. **获取匹配规则**

   ```bash
   ocr delegate rule --format json <path1> <path2> ...
   ```

   传入步骤 1 的全部 reviewable 文件路径。输出按规则内容分组，同组文件共享一份审查清单（含该语言/类型的检查项，如 NPE、并发、注入、边界处理等）。

3. **建立 checklist**：以 `(path, status)` 为唯一身份列出所有 reviewable 文件（workspace 模式下同一路径可能以不同 status 出现两次）。每个条目必须最终落为 `reviewed` 或 `skipped`（附具体原因，如「纯格式化」「生成物」）。

4. **逐文件审查**（按 preview 的 mode/ref 元数据取 diff）：
   - workspace：tracked 用 `git diff HEAD -- <path>`；untracked 直接读文件全文（整体都是新代码）
   - range：`git diff <merge_base>..<to> -- <path>`
   - commit：`git show <commit> -- <path>`

   对照该文件的规则组清单逐条检查，但不要被清单限制——你仍要独立判断逻辑正确性、边界条件和系统影响（见「Review Focus」）。需要上下文时读取完整文件、追调用链（优先用 codebase-memory MCP 工具，项目名映射见各项目根 AGENTS.md；目标项目未索引时回退 grep/读文件）。

   大变更分批审：按共享规则组和 diff 大小切分为有界批次，逐批完成；**不得因发现首个 Critical/High 就停止**，必须走完全部 checklist。

5. **报告**：findings 按既有 Output Format（Critical/High/Medium/Low + `file:line`），末尾附覆盖统计：`total / reviewed / skipped` 及 `coverage_rate`（reviewed/total 百分比），skipped 逐条给出原因。疑似误报静默丢弃，宁缺毋滥——false alarm 比漏报更伤信任。

**降级规则**：`ocr` 命令报错或不可用时，退回本文档前述的纯 agent 审查流程，并向用户说明 OCR 不可用。场景 2（指定代码块评审）与场景 3（业务流程评审）不走 OCR。

## 修复派发（Post-Review Fix Dispatch）

评审报告产出后，你不直接改代码，而是派发 subagent 执行修复。

1. **确认** — 报告按严重级别排序后，询问用户要修复哪些：按级别（如「修 Critical + High」）或按具体条目（如「修 2、5」）。未经用户确认，不得派发任何修复。
2. **派发** — 用 `subagent` 工具派发。每次派发的提示必须**自包含**（subagent 不共享本会话上下文），并包含：
   - 完整的 finding 清单：每条给出 `file_path:line_number`、问题描述、期望的修复方向。
   - 项目约定：提示 subagent 遵循项目既有约定（命名、风格、库选择；若项目根有 AGENTS.md 应先读取）。
   - 验证命令：明确要求修复后运行项目的 lint / typecheck / 测试等验证命令。
   - 分组策略：同一文件或同一流程的 findings 合并为一个子代理任务；相互独立且不冲突的 findings 可并行派发多个子代理。
3. **复核** — 所有 subagent 完成后，用只读 `git diff` 重新评审修复结果：逐条确认每个 finding 已真正修复、未引入新问题，并输出复核结论（已修复 / 未修复 / 引入新问题）。若发现未修复或引入新问题，报告给用户并询问是否追加派发下一轮修复。

## Output Format

- **Critical** — must fix: bugs, security issues
- **High** — should fix: likely to cause problems
- **Medium** — consider fixing: edge cases, minor issues
- **Low** — nitpicks, style suggestions

每条 finding 引用确切的 `file_path:line_number`。简洁、具体、可执行。代码没问题就直说——不要制造问题。

## Language

始终用简体中文回复；代码标识符与技术术语可保留英文。
