# Proposal

## Why

spec-apply 的 subagent 引擎是「派发后等回执」的开环：主会话无法通知运行中的 subagent、无法停止它、subagent 之间互不可见——同一任务被多次派发（压缩丢失、接续重派、恢复重派）时会发生静默双写。双探针实证（2026-11-19 / dsh 0.2.2-rc.1）：lead→subagent 下行与硬中断在当前配置下平台不可达（team 工具与 `tool-subagent-control` 重名互斥），但 **subagent→lead 上行消息可用且 skill 从未接线**（subagent 面有 `send_message`，父 session id 在其 runtime context）。本变更在平台约束内把协议做到极限，并为硬控制需求给出引擎升级路径。

## What Changes

- **登记簿**（Q3=a）：`/tmp/spec-flow/<change>/progress.md` 由 4 字段台账升级为单一登记簿——租约、废止令、恢复核对同源；写者仅主会话，子代理只读；状态机 `active→done|void|stalled`，重派加 `@r2` 新行。
- **协调协议注入**（Q5=b ≤15 行）：每个执行 subagent 提示注入 7 条正向配方（读登记簿、让路、三处检查点、上行发送、格式、三类必报、sibling 不可达事实）——开工即知冲突，检查点感知废止。
- **上行通道**（Q4=b）：subagent 面 `send_message` 直报主会话，事件限待决/异常/完成前奏三类，单发不候复；失败降级回执上浮。
- **软废止**（Q2=b）：废止令 = 登记簿 `state=void`（不另立令文件）；派发前判据提示「需即时叫停/多轮互商 → 建议 `--engine team`」。
- **spec-plan 同步接入**（Q1=a / Q6=a）：规划线、复算线、设计线注入精简段（5 行，仅待决+异常两类，无租约/无前奏）；提问节奏两侧维持既有（Q7=a）。
- **事实修正**：spec-apply failure-modes 两行拆方向重写（上行可用、`job_list` 判据作废）；spec-workflow 恢复协议的 `job_list` 在途判据一并修正（P1=a，与登记簿单一权威源对齐）。
- 平台层零改动：不 re-enable 互斥工具、不写插件；team 引擎不接入登记簿/上行（P2=a，能力已齐备）；登记簿不加可执行校验脚本（P3=a，避免第二权威源）。

## Capabilities

### New Capabilities

（无——本次全部 Requirement 挂在既有 capability 下演进）

### Modified Capabilities

- `spec-apply`：新增 Requirement「subagent 运行协调（登记簿·检查点·上行）」；修改「subagent 执行引擎」（提示注入协调段+派发前登记）与「子代理与用户的交互中转（执行期）」（上浮通道含上行消息）。
- `spec-plan`：修改「子代理与用户的交互中转（规划期）」（规划线/复算线/设计线上行通道，仅两类事件，节奏不变）。

## Impact

- 触达面 13 条（全在 dotfiles 根仓）：新建 `agent/skills/spec-apply/refs/coordination.md`（协调协议唯一权威源）；改 spec-apply 的 SKILL.md / execution.md / failure-modes.md；改 spec-plan 的 SKILL.md / mode/parallel.md / refs/planning.md / refs/convergence.md / refs/failure-modes.md；改 spec-workflow/SKILL.md:65（单行，无 spec delta）；落档两份 spec delta（spec-apply / spec-plan）。
- 长度红线：spec-plan/SKILL.md 入口仅 +97 cp（渲染 8146/8192，余量 46，附 58 cp 降级预案）；其余文件余量充裕。
- 校验口径：spec-apply delta 归档后须保持 `openspec validate spec-apply --strict` exit 0（当前基线绿）；spec-plan 侧「不新增 warning」（当前基线已红 2 条 >500，非本次引入）；**禁用 `--all --strict`** 做门禁。
- 不影响：`dsh/spec-workflow.yaml`（无新键）、routing.md、spec-done（清理面已覆盖 `/tmp/spec-flow/<change>/` 整目录）、dsh/commands。
