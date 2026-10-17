---
description: 执行半程：对已落档变更继续批次执行（spec-apply）
argument-hint: "<变更名> [--engine team] [--model apply=<provider>/<模型>]"
---
加载 spec-apply skill，并按其执行手册继续该变更的批次执行。

调用参数：$ARGUMENTS

规则：
- 变更未落档时提示先走规划（/spec-plan 或 /spec-flow），不进入执行。
- 执行模式与引擎未预置时先询问，不自行假设。
