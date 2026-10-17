---
description: 固定工作流收尾半程：已归档变更 rebase→复验→推送→合并→worktree 清理闭环（spec-done）
argument-hint: "<变更名>"
---
加载 spec-done skill，并按其收尾半程执行。

调用参数：$ARGUMENTS

规则：
- 变更名缺省时先向我确认要收尾哪个变更；未归档的变更提示先经 /spec-flow continue 完成归档。
- 不可逆动作（删 worktree、清分支）前先以 git 事实复核，并在硬门槛处等我确认。
- 归档 design.md 无执行环境块时按非隔离轻量收尾处理并如实告知。
