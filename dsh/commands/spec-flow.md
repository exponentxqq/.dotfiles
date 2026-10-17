---
description: 固定工作流：双线规划→落档→衔接→执行→验证归档→收尾（spec-workflow 编排，spec-plan/spec-apply/spec-done 分段承载）
argument-hint: "[需求描述 | continue <变更名>] [--parallel] [--auto|--step-task|--step-group] [--engine team] [--worktree] [--model <阶段>=<provider>/<模型>]"
---
加载 spec-workflow skill，并按其四段编排执行（规划→衔接→执行→终末）。

调用参数：$ARGUMENTS

规则：
- 已预置的选项按参数执行；未预置的在对应阶段开始前向我询问，不要自行假设。
- 参数为空或未含需求描述时，先开放式询问我要做什么。
- 参数中 `continue <变更名>` 表示接续该未完成变更。
