---
name: spec-apply
description: spec 驱动工作流的执行半程——落档后批次执行：双引擎（subagent/team）、三模式（auto/step-task/step-group）、核对与审核-提交分离、留痕与工件维护、隔离执行落点。Use when 用户要「执行/继续执行某变更任务」或调用 /spec-apply <变更名>，或被 spec-workflow 编排委托进入执行；变更未落档指回规划。
---

# spec-apply 执行半程

本 skill 是**执行手册**：每步按本文执行，未写到的情况回到用户。本文件面向**没有本次对话上下文**的未来会话——一切从工件与命令输出重建。

## 一、总览

执行半程 = 落档提交后、归档前的全部实现工作：批次循环 → 主会话核对 → 工件维护 → 按模式停留呈证 → **用户审核确认后提交**。上游：skill `spec-workflow` 衔接（模式/引擎/执行环境已定则预置，衔接后自动委托本 skill；恢复协议由其判段路由）；下游：全部任务完成后归档链由 skill `spec-done` 承载（编排层自动委托）。

**状态载体 = 工件 + `tasks.md` 勾选态 + `git log` 三方对齐**；`/tmp/spec-flow/<change>/` 材料易失、不入库、不进提交。`code-design.md`/`diff-matrix.md`（串行 `decisions.md`）以变更目录落档副本为维护对象。

承诺：**核对通过 ≠ 审核通过**（提交在用户确认后）、**绝不重跑已完成任务**、**不静默假设待决项**、规划外 scope 变化回到用户。

参数：`<变更名>`（缺省问用户；恰有一个未完成变更时可确认推断）；模式/引擎未预置时首动询问。

## 二、入口与前置检查

①**已落档**：变更目录四件套存在且 `tasks.md` 非空——未落档指回规划（`/spec-plan` 或 `/spec-flow`）；②**进度重建**：恢复/接续进入先按 spec-workflow 恢复协议（编排层路由至此）；独立进入自查三方对齐（勾选态 + 提交历史 + 现存 diff，勾选但无验证证据 → 对现存 diff 跑验证句，通过保持勾选不重派）；③**模式与引擎**：`auto`/`step-task`/`step-group`；引擎 `subagent`（默认）/`team`——已预置不重问；④**执行环境**：落档 `design.md` 决策记录执行环境块——隔离 → 子代理项目根与验证目录 = worktree 路径，代码提交落 `feature/<change>`、工件落根仓主工作区；直用主工作区 → 常规落点。worktree 布局与装配手册 = **skill spec-workflow 的 `refs/worktree.md`（唯一权威源，本 skill 跨引用不复制）**；⑤**能力自检**：栈识别结论（writer skill 名）从 design.md 决策记录读取，加载失败按 [failure-modes.md](refs/failure-modes.md) 处置顺序处理。

**压缩后恢复速查（红线级）**：进度只认三方对齐；绝不重跑已完成任务，从最小编号未完成组继续。

## 三、批次循环骨架

```
while 存在未勾选任务:
    组 = 编号最小的未完成组
    if 引擎 == subagent: 组内每任务派一个 fresh 子代理（同一条消息并发，上限 parallelism）
    else:                组内任务发布到共享任务板，spawn ≤ 组内任务数的 implementer 认领
    主会话逐任务核对（验证句 + 读改动 + git diff）→ 通过才勾选 tasks.md
    组收尾：勾选核对（本组任务全 [x]）→ 工件维护（code-design 组段终形态化、R<n> 留痕）→ 按模式停留呈证 → 用户确认后才提交
```

**共同纪律**：主会话必须自己按**验证句 + diff** 核对，**核对通过才勾选**；**验收须干净窗口**（无并发构建、验证任务真实 executed 无 SKIPPED——展开见 [execution.md](refs/execution.md)）。

展开内容按消费时机外移 **refs/**：**派发前（两引擎）读 [execution.md](refs/execution.md)**（编排、模式与提交、干净窗口、留痕、提示模板、回执格式）；**仅 subagent 派发前读 [routing.md](refs/routing.md)**（执行键路由、三档回退、白名单、读图、自检）；**异常先读 [failure-modes.md](refs/failure-modes.md)**。

## 四、执行期待决中转

执行子代理**不能直接向用户提问**（`DELEGATED_CALLER`，平台设计不是故障）——它在产物与回执**上浮**待决项 → 主会话**当批次即时代问**（≤5 问/轮附推荐）→ **subagent** 以上轮回执摘要+答复**接续重派**；**team** 用 `send_message` 回**同一成员**。**不得把待决项静默变成假设**，不得为等答复阻塞轮询。展开见 [execution.md](refs/execution.md)。

## 五、模型路由（执行侧）

映射文件 **`/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml`**（绝对路径，与规划半程共用）：本 skill 消费 `apply`（执行任务子代理）、`vision`（读图）、`engine`、`parallelism`；`verify` 由 spec-done 复用。优先级 `--model` > 映射文件 > 继承会话模型；**三档回退**（fallback 重派一次 → 继承会话模型一次 → 报告暂停，不反复重试）与**读图改道 vision** 展开唯一权威源 = [routing.md](refs/routing.md)（仅 subagent 引擎派发前读）。

## 六、全部任务完成后

最后批次经用户审核确认提交 → **停留，归档链与收尾由 skill `spec-done` 承载**（编排层自动委托；或用户 `/spec-done <变更名>`）。本 skill 不归档、不推送、不清理分支。**沉淀回流清单**（执行期改动的工作流仓文件，逐条列明已提交去向/未提交待决）在最后批次组收尾时**工件化**——以 R<n> 条目或独立小节追加到 `tasks.md` 附录、随最后批次提交入库；spec-done 六要素汇报**从工件读出**（其会话可能没有执行期上下文，不以会话记忆为源）。

## 七、边界与失败（红线）

**绝不做**：不在用户审核确认前提交实现改动（用户明确豁免审核时除外）；不提交未过验证的内容；不把待决项静默变成假设；不把 `/tmp` 材料当进度依据；不重跑已完成任务；不动 CI、密钥、生产配置（真实密钥只经参数传入进程）；多仓分立提交不跨仓混提；不 force push。**auto 硬停四条件**（不可逆/安全敏感/工作区外副作用/计划彻底失效）与任务失败重试一次纪律见 [execution.md](refs/execution.md)；其余异常处置见 [failure-modes.md](refs/failure-modes.md)，**遇异常先读它**。
