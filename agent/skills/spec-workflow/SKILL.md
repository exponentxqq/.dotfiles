---
name: spec-workflow
description: 固定 spec 驱动开发工作流——两条方向不同的独立规划线与差异复算、OpenSpec 落档、子代理执行、验证归档提交一体化。Use when 用户要"走 spec 工作流/固定工作流/spec-flow"，或要求从需求一路做到归档提交且执行交由 subagent；也用于接续未完成的 OpenSpec 变更。
---

# spec-workflow 固定工作流

本 skill 是**执行手册**：每步按本文执行，未写到的情况回到用户。本文件面向**没有本次对话上下文**的未来会话——一切从工件与命令输出重建。

## 一、总览

六阶段流水线，入口为用户级命令 `/spec-flow`（命令薄壳加载本 skill）；**阶段 1→2（规划半程）委托 skill `spec-plan` 执行**，本 skill 承载衔接、执行与归档；**归档后的收尾半程（推送/合并/worktree 清理）委托 skill `spec-done`**：

```
阶段1 独立双线规划 → 阶段1.5 差异收敛 → 阶段1.7 代码设计 → 阶段2 落档（spec-plan 承载，至落档提交）
→ 阶段3 执行 → 阶段4 验证与归档（本 skill 承载）→（归档后）收尾闭环（skill spec-done 承载）
```

**状态载体 = 工件**：权威进度 = 工件 + `tasks.md` 勾选态 + `git log`（**三方对齐**）；`/tmp/spec-flow/<change>/` 材料易失、不入库、不进提交。工件跨界所有权：`code-design.md`/`diff-matrix.md`（串行 `decisions.md`）由 spec-plan 产出并**随落档提交至变更目录**，执行期由本 skill 维护**落档副本**（组段终形态化，见第六节；`/tmp` 侧原件落档后不再维护）。

承诺：**阶段边界必汇报**、**规划外 scope 变化回到用户**、**不假设未给出的选项**。

参数与模式（**一次只问该阶段需要的，已预置的不再问**）：

| 参数 / 选项 | 取值与缺省（含询问时机） |
| --- | --- |
| `<需求描述>` | 需求原文，转发 spec-plan；为空则问「要做什么」 |
| `continue <变更名>` | 接续未完成变更（第八节） |
| `--parallel` | 规划编排参数，**原样转发 spec-plan** |
| `--auto` / `--step-task` / `--step-group` | 执行模式；落档摘要后问 |
| `--engine team` | 执行引擎；映射 `engine` → `subagent`；与模式同问 |
| `--worktree` | 执行环境预置**隔离**（衔接点跳过询问）；缺省衔接点按判据问（第五节） |
| `--model <阶段>=<provider>/<模型>` | 执行键（apply/verify）覆盖；**规划键（lineA/lineB/panel/design）原样转发 spec-plan** |

展开内容按**消费时机**外移到 **`refs/`**（按下表按需读取，读到的与正文同等权威）：

| 消费时机 | 读什么 |
| --- | --- |
| 执行派发前（两引擎） | [execution.md](refs/execution.md) —— 编排、模式与提交、干净窗口验收、留痕、提示模板、回执格式 |
| 衔接点执行环境决策与恢复核对 | [worktree.md](refs/worktree.md) —— 隔离判据、布局与创建装配、本地配置与环境错开、执行环境块（交接契约 schema）、恢复核对 |
| **仅 `subagent` 引擎**派发前 | [routing.md](refs/routing.md) —— 执行键路由、三档回退、白名单、图片能力、自检 |
| 异常、边界、失败 | [failure-modes.md](refs/failure-modes.md) —— 处置表主体（红线见第十节） |

**压缩后恢复速查**（红线级）：进度只认**三方对齐**（工件+勾选态+提交历史）；**绝不重跑已完成任务**，从最小编号未完成组继续（第五节）。

## 二、前置检查

开工前四项：**①OpenSpec 根**（`openspec list --json` 读 `root`；`null` → 未接入：**绝不副作用创建** `openspec/`，问 init / store / 放弃）｜**②参数**（需求原文 / continue 名 / 模式 / 引擎 / 模型覆盖）｜**③工作目录事实**（含 `git status --porcelain`；无关脏改动**不擅自 stash / commit / revert**）｜**④能力自检**（`spec-plan`、`openspec-verify-change` 与 `openspec-archive-change` 可加载；不可加载按 [failure-modes.md](refs/failure-modes.md) 处置顺序处理）。

## 三、模式收集

**唯一规则：一次只问该阶段需要的选项，已由参数预置的不再问，绝不自行假设。**规划期参数（`--parallel`、规划键 `--model`）转发 spec-plan 后视同已预置；执行模式与引擎在落档摘要后问（第五节）。答复写进进度笔记（变更名、模式、引擎、模型覆盖）。

## 四、规划阶段（1→2）：委托 spec-plan

**加载 `spec-plan` skill，按其执行手册推进至落档提交**：`<需求描述>`、`--parallel` 与规划键 `--model` **原样转发**，已预置项不重问；未预置的规划期选项由 spec-plan 按其流程询问。落档完成后**核对两件事**再进入衔接：**四件套存在**（`openspec/changes/<change>/` 与 `tasks.md` 非空）、**栈识别结论已写入 design.md 决策记录**（缺失则要求 spec-plan 补落）。规划方法论（双线、收敛、设计契约）以 spec-plan 为唯一权威源，本 skill 不复述。

## 五、衔接与恢复协议

**衔接（落档提交后、执行前）**：①**确认执行模式与引擎**（未预置时）：`auto` / `step-task` / `step-group` / **暂不执行**；引擎（参数 `--engine` > 映射文件 `engine` > 默认 `subagent`）；②提示用户（原话模板）：**「如需切换主会话模型请现在切换，也可 /compact 压缩上下文，然后说继续。」**③**执行环境决策**（`--worktree` 预置跳过）：按 [worktree.md](refs/worktree.md) 判据推荐**整批隔离**（全部触达代码仓建 worktree）或直用主工作区，一次问清；选定后创建+装配，**执行环境块写入落档 design.md 决策记录**（随衔接后首个批次提交——执行期恢复与收尾 spec-done 的交接契约）。被打断的会话按恢复协议重建进度。

**恢复协议（任何时刻生效：新轮次、`/compact` 之后、会话重启之后、用户说「继续」）**：

1. 先重建进度：`openspec status --change <change> --json`（该版本 `status` 不接受位置参数；裸 `--json` 无效，用 `--all --json` 兜底）。
2. 读 `tasks.md` 勾选态（`- [x]` = 完成）与 `git log --oneline` 的批次提交。
3. 三方对齐：**工件 + 勾选态 + 提交历史**；勾选但无验证证据 → 回退为未完成并报告；**提交对不上时以现存 diff 为准**（`auto` 收尾才提交，未提交**属预期**）：跑该任务验证句，通过即**保持勾选**、不重派。
4. **落档副本存在性检查**：`code-design.md` 与 `diff-matrix.md`（串行 `decisions.md`）须在变更目录——缺失且 `/tmp/spec-flow/<change>/` 原件在 → 从原件**补复制入变更目录并留痕**（随下次批次提交）；两者皆无 → 报告问用户，**不以 /tmp 幸存为默认**。
5. **执行环境核对**：design.md 决策记录有执行环境块（隔离）时 → `git worktree list` 比对——worktree 在 → 续用（含装配核对，缺则补）；缺失但分支在 → 按 [worktree.md](refs/worktree.md) 重建+装配+三方对齐核对；均无 → 问用户。
6. **绝不重跑已完成任务**；从「最小编号的未完成组」继续。
7. 恢复后先输出一行进度摘要（`change / 已完成 N/M / 当前组 / 引擎 / 模式 / 下一步`）。
8. 上下文一律从工件现读（specs、design、tasks），**不依赖对话记忆**。

## 六、执行双引擎与三模式（阶段 3）

批次循环骨架：

```
while 存在未勾选任务:
    组 = 编号最小的未完成组
    if 引擎 == subagent: 组内每任务派一个 fresh 子代理（同一条消息并发，上限 parallelism）
    else:                组内任务发布到共享任务板，spawn ≤ 组内任务数的 implementer 认领
    主会话逐任务核对（验证句 + 读改动 + git diff）→ 通过才勾选 tasks.md
    组收尾：**勾选核对（本组任务全 `- [x]`）** → 工件维护（code-design.md 组段终形态化、R<n> 留痕）→ 按执行模式停留呈证 → 用户确认后才提交
```

**共同纪律**：主会话必须自己按**验证句 + diff** 核对（跑验证句命令、读回改动文件、`git diff --stat`），**核对通过才把 `- [ ]` 改成 `- [x]`**；**核对通过 ≠ 审核通过——提交在用户审核确认之后**（任何模式；用户明确豁免审核时除外）。**验收须干净窗口**：确认无并发构建进程、验证任务无 SKIPPED 且真实 executed（展开见 [execution.md](refs/execution.md)）。隔离执行时（衔接③），子代理提示的**项目根与验证句执行目录均为 worktree 路径**；代码批次提交落 worktree 的 `feature/<change>` 分支、根仓工件落主工作区（见 [worktree.md](refs/worktree.md)）。

**执行期待决中转**：执行子代理**不能直接向用户提问**（`DELEGATED_CALLER`，平台设计不是故障）——它在产物与回执**上浮**待决项 → 主会话**当批次即时代问**（≤5 问/轮附推荐）→ **subagent** 以上轮回执摘要+答复**接续重派**；**team** 用 `send_message` 回**同一成员**。**不得把待决项静默变成假设**，不得为等答复阻塞轮询。

**引擎与模式**：`subagent`（默认）每任务一个 **fresh** 子代理、组内并发**组间串行**；`team`（`--engine team`）走任务板卡片 + 具名 implementer、反馈回**同一成员**；**成员创建失败或不可用时降级 subagent**（成员上限 8 达限同此）。引擎允许**批次间切换**（含 team↔subagent），切换与原因留痕。三模式：`auto`（批次间不打断、全部完成后停留呈证）/`step-task`（每任务停留）/`step-group`（每批次停留）。**停留呈证、提交时机、writer skill 加载指令（从落档 design.md 决策记录读取，无从取得则重识别一次）、提示模板、回执格式、硬停四条件、逐条纪律见 [execution.md](refs/execution.md)**（**首次派发前读**）；`auto` **硬停**：不可逆 / 安全敏感 / 工作区外副作用 / 计划彻底失效；任务失败**重试一次**，仍失败**暂停本批次并报告**。

## 七、验证与归档（阶段 4）

**①先读项目声明的验证方式**（`AGENTS.md`/`CLAUDE.md` → README、package scripts、CI）→ **②干净窗口执行验证**（可派 **fresh** 子代理按 [routing.md](refs/routing.md) 应用 `verify` 路由；**真实密钥只经参数传入进程、绝不入库**；回传命令与**退出码**）→ **③不通过 → 不归档**（报告证据；问用户修复或**显式批准**跳过并记已知缺口）→ **④通过后、归档前加载 `openspec-verify-change` 校验**（任务全勾 + spec 覆盖映射 + design 一致性；缺漏先修复重校——如补勾、补 delta）→ **⑤归档**（`tasks.md` 全部勾选 → `openspec-archive-change` 归档并同步主规格）→ **⑥归档单独提交一次**（报错贴原文并停，**不手工搬移目录**）→ **⑦汇报六要素**（工件路径 / 验证证据 / 归档位置与主规格 / 宿主操作清单 / 沉淀回流清单——执行期改动的工作流仓文件，交用户决定提交与方式 / 遗留待办——worktree 闭环清单（入口 `/spec-done <变更名>`）、临时偏离恢复点、预留编号）→ **⑧收尾指路**：收尾半程由 skill **spec-done** 承载，本 skill 在遗留待办中指路、不代跑。

## 八、接续流程

触发：`/spec-flow continue <变更名>` 或用户要求接续。**①**跑**恢复协议**（第五节）｜**②**校验变更存在且未归档（`openspec list --json`；`tasks.md` 空 → 尚未落档，问用户是否**回规划**——回规划 = 再加载 `spec-plan` 重做阶段 1→2）｜**③跳过已完成的规划与落档**（**规划含阶段 1.7 设计线**；不需 `/tmp/spec-flow/` 材料；仅用户明确要求时才重跑）｜**④执行前重新确认执行模式与引擎**，再按第六节从最小编号未完成组续跑｜**⑤**停在审核点/失败点 → 先呈现证据再继续。

## 九、模型路由

映射文件 **`/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml`**（**绝对**路径）：执行键 `apply`/`verify` → 阶段 3 执行（**仅 `subagent` 引擎**）、阶段 4 验证；能力键 `vision` = **读图覆盖**。**规划键（lineA/lineB/panel/design）由 spec-plan 消费**，命令中的规划键覆盖原样转发；`engine`、`parallelism` 本 skill 消费。值 `{ provider, model }`，可选 `fallback`。**优先级：`--model` > 映射文件 > 继承会话模型。**

红线要点（**展开唯一权威源 = [routing.md](refs/routing.md)——仅 `subagent` 引擎派发前先读它**）：**三档回退**（顺序固定，不反复重试）——①有 `fallback` → 备用**重派一次**；②无或备用也失败 → **回退继承会话模型**一次；③仍失败 → 报告并暂停。**读图**——路由不支持图片时 `does not declare image input` 是**能力事实不是故障** → 改走 `vision`。

## 十、边界与失败

**红线级条目**（违反即致不可逆、失控或静默假设）；其余异常与失败处置见 [failure-modes.md](refs/failure-modes.md)，**遇异常先读它**：

| 情形 | 处置 |
| --- | --- |
| 无 openspec 根（`root: null`） | 问 init / store / 放弃，**绝不副作用创建** `openspec/`（第二节） |
| 执行子代理需用户决策 / 直接提问被拒（`DELEGATED_CALLER`） | 走第六节执行期中转：上浮 → 主会话**当批次即时代问** → team 回送**同一成员**、subagent 接续重派。**`DELEGATED_CALLER` 是平台设计，不是故障**——不判定工具损坏、不重试直接提问 |
| 计划彻底失效（工件与实现矛盾） | `auto` 硬停条件之一（四条件见第六节）：停下让用户决定重做落档（回规划 = 再加载 spec-plan 改工件）或终止 |

**绝不做**：不自行 `openspec init`；**不在用户审核确认前提交实现改动**（任何模式；用户明确豁免审核时除外）；不提交未过验证的内容；不动目标项目的 CI、密钥、生产配置（**真实密钥只经参数传入进程**，绝不写入入库文件/日志/提交信息）；不替用户切换主会话模型；不在 `auto` 之外的模式下跳过审核停留；不把子代理上浮的待决项**静默变成假设**；不把 `/tmp/spec-flow/` 的临时材料当成进度依据（权威进度永远是工件 + 勾选态 + 提交历史）；多仓**分立提交**（代码 / 工件 / 生成物各归其仓、N 仓各自完整提交）、不跨仓混提；不 force push、不在用户确认已推送+已合并前删 worktree（删前必查干净——收尾红线归 spec-done）。
