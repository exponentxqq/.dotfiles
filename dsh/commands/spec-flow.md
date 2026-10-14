---
description: 固定工作流：独立双线规划→差异收敛→落档→子代理执行→归档提交（spec-workflow）
argument-hint: "[需求描述 | continue <变更名>] [--parallel] [--auto|--step-task|--step-group] [--engine team] [--model <阶段>=<provider>/<模型>]"
---
加载 spec-workflow skill，并按其固定工作流执行。

调用参数：$ARGUMENTS

规则：
- 已预置的选项按参数执行；未预置的在对应阶段开始前向我询问，不要自行假设。
- 参数为空或未含需求描述时，先开放式询问我要做什么。
- 参数中 `continue <变更名>` 表示接续该未完成变更。
