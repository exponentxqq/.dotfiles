---
name: spec-workflow
description: 固定 spec 驱动开发工作流的统一编排入口——四段委托：规划（spec-plan）、衔接与执行环境决策（本 skill）、执行（spec-apply）、终末归档与收尾（spec-done），含恢复协议与判段路由。Use when 用户要"走 spec 工作流/固定工作流/spec-flow"或接续未完成的 OpenSpec 变更；全程体验一体化。
---

# spec-workflow 固定工作流

本 skill 是**执行手册**：每步按本文执行，未写到的情况回到用户。本文件面向**没有本次对话上下文**的未来会话——一切从工件与命令输出重建。

## 一、总览

四段流水线，入口为用户级命令 `/spec-flow`（命令薄壳加载本 skill）：**阶段 1→2（规划半程）委托 skill `spec-plan`** 至落档提交；**本 skill 承载衔接**（执行模式/引擎确认、执行环境决策与创建装配）与**全流程编排**（恢复协议、判段路由）；**执行半程（阶段 3）委托 skill `spec-apply`**；**终末半程（阶段 4 验证归档 + 收尾闭环）由 skill `spec-done` 承载**，执行完成后本 skill 自动委托其收口归档链：

```
阶段1 独立双线规划 → 阶段1.5 差异收敛 → 阶段1.7 代码设计 → 阶段2 落档（spec-plan 承载，至落档提交）
→ 衔接（本 skill：模式/引擎/执行环境）→ 阶段3 执行（spec-apply 承载）→ 阶段4 验证与归档 + 收尾闭环（spec-done 承载）
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
| `--model <阶段>=<provider>/<模型>` | 执行键覆盖（`apply` 随衔接交接 spec-apply、`verify` 随终末委托交接 spec-done）；**规划键（lineA/lineB/panel/design）原样转发 spec-plan** |

展开内容按**消费时机**外移到 **`refs/`**（按下表按需读取，读到的与正文同等权威）：

| 消费时机 | 读什么 |
| --- | --- |
| 衔接点执行环境决策与恢复核对 | [worktree.md](refs/worktree.md) —— 隔离判据、布局与创建装配、本地配置与环境错开、执行环境块（交接契约 schema）、恢复核对 |
| 异常、边界、失败 | [failure-modes.md](refs/failure-modes.md) —— 处置表主体（红线见第十节） |
| 执行期展开（编排/模式/提示模板/回执/路由/执行失败） | 读 skill **spec-apply** 的 SKILL.md 与其 refs/（execution/routing/failure-modes）——执行半程唯一权威源 |

**压缩后恢复速查**（红线级）：进度只认**三方对齐**（工件+勾选态+提交历史）；**绝不重跑已完成任务**，从最小编号未完成组继续（第五节）。

## 二、前置检查

开工前四项：**①OpenSpec 根**（`openspec list --json` 读 `root`；`null` → 未接入：**绝不副作用创建** `openspec/`，问 init / store / 放弃）｜**②参数**（需求原文 / continue 名 / 模式 / 引擎 / 模型覆盖）｜**③工作目录事实**（含 `git status --porcelain`；无关脏改动**不擅自 stash / commit / revert**）｜**④能力自检**（`spec-plan`、`openspec-verify-change` 与 `openspec-archive-change` 可加载；不可加载按 [failure-modes.md](refs/failure-modes.md) 处置顺序处理）。

## 三、模式收集

**唯一规则：一次只问该阶段需要的选项，已由参数预置的不再问，绝不自行假设。**规划期参数（`--parallel`、规划键 `--model`）转发 spec-plan 后视同已预置；执行模式与引擎在落档摘要后问（第五节）。答复写进进度笔记（变更名、模式、引擎、模型覆盖）。

## 四、规划阶段（1→2）：委托 spec-plan

**加载 `spec-plan` skill，按其执行手册推进至落档提交**：`<需求描述>`、`--parallel` 与规划键 `--model` **原样转发**，已预置项不重问；未预置的规划期选项由 spec-plan 按其流程询问。落档完成后**核对两件事**再进入衔接：**四件套存在**（`openspec/changes/<change>/` 与 `tasks.md` 非空）、**栈识别结论已写入 design.md 决策记录**（缺失则要求 spec-plan 补落）。规划方法论（双线、收敛、设计契约）以 spec-plan 为唯一权威源，本 skill 不复述。衔接完成后**委托 skill `spec-apply` 进入执行**（衔接预置项随指针交接，已预置不重问）。

## 五、衔接与恢复协议

**衔接（落档提交后、执行前）**：①**确认执行模式与引擎**（未预置时）：`auto` / `step-task` / `step-group` / **暂不执行**；引擎（参数 `--engine` > 映射文件 `engine` > 默认 `subagent`）；②提示用户（原话模板）：**「如需切换主会话模型请现在切换，也可 /compact 压缩上下文，然后说继续。」**③**执行环境决策**（`--worktree` 预置跳过）：按 [worktree.md](refs/worktree.md) 判据推荐**整批隔离**（全部触达代码仓建 worktree）或直用主工作区，一次问清；选定后创建+装配，**执行环境块写入落档 design.md 决策记录**（随衔接后首个批次提交——执行期恢复与收尾 spec-done 的交接契约）；衔接三步完成即**委托 spec-apply 进入执行**。被打断的会话按恢复协议重建进度。

**恢复协议（任何时刻生效：新轮次、`/compact` 之后、会话重启之后、用户说「继续」）**：

1. 先重建进度：`openspec status --change <change> --json`（该版本 `status` 不接受位置参数；裸 `--json` 无效，用 `--all --json` 兜底）。
2. 读 `tasks.md` 勾选态（`- [x]` = 完成）与 `git log --oneline` 的批次提交。
3. 三方对齐：**工件 + 勾选态 + 提交历史**；勾选但无验证证据 → 回退为未完成并报告；**提交对不上时以现存 diff 为准**（`auto` 收尾才提交，未提交**属预期**）：跑该任务验证句，通过即**保持勾选**、不重派。
4. **落档副本存在性检查**：`code-design.md` 与 `diff-matrix.md`（串行 `decisions.md`）须在变更目录——缺失且 `/tmp/spec-flow/<change>/` 原件在 → 从原件**补复制入变更目录并留痕**（随下次批次提交）；两者皆无 → 报告问用户，**不以 /tmp 幸存为默认**。
5. **执行环境核对**：design.md 决策记录有执行环境块（隔离）时 → `git worktree list` 比对——worktree 在 → 续用（含装配核对，缺则补）；缺失但分支在 → 按 [worktree.md](refs/worktree.md) 重建+装配+三方对齐核对；均无 → 问用户。
6. **判段路由**：重建进度后判定当前段——未落档 → 回规划（再加载 spec-plan 改工件）；已落档未完 → 路由 spec-apply（从最小编号未完成组继续）；已归档 → 路由 spec-done（收尾）。
7. **绝不重跑已完成任务**；从「最小编号的未完成组」继续。
8. 恢复后先输出一行进度摘要（`change / 已完成 N/M / 当前组 / 引擎 / 模式 / 当前段 / 下一步`）。
9. 上下文一律从工件现读（specs、design、tasks），**不依赖对话记忆**。

## 六、执行半程（委托 spec-apply）

批次执行（双引擎、三模式、核对与审核-提交分离、留痕与工件维护、隔离执行落点）由 skill **spec-apply** 承载，其 SKILL.md 与 refs/（execution/routing/failure-modes）为唯一权威源，本 skill 不复述；衔接预置项（模式/引擎/模型覆盖/执行环境块）随委托指针交接。恢复/接续进入执行段按第五节判段路由。

## 七、终末半程（委托 spec-done）

验证门与归档（项目验证 → verify-change → archive 同步主规格 → 归档单独提交 → 六要素汇报）与收尾闭环（隔离八步/非隔离轻量）由 skill **spec-done** 承载。执行半程全部批次完成且经用户审核提交后，本 skill **自动委托 spec-done 收口归档链**（全流程体验不变）；用户亦可 /spec-done 独立发起。本 skill 不归档、不推送、不清理。

## 八、接续流程

触发：`/spec-flow continue <变更名>` 或用户要求接续。**①**跑**恢复协议**（第五节）｜**②**校验变更存在与归档状态（`openspec list --json`）：已归档 → 按恢复协议判段路由转 `spec-done` 收尾，不进③④；未归档且 `tasks.md` 空 → 尚未落档，问用户是否**回规划**——回规划 = 再加载 `spec-plan` 重做阶段 1→2｜**③跳过已完成的规划与落档**（**规划含阶段 1.7 设计线**；不需 `/tmp/spec-flow/` 材料；仅用户明确要求时才重跑）｜**④**按第五节判段路由进入对应半程——执行段由 spec-apply 首动承接模式/引擎确认（未预置时）｜**⑤**停在审核点/失败点 → 先呈现证据再继续。

## 九、模型路由

映射文件 **`/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml`**（绝对路径）为四段共用的唯一路由配置：**规划键（lineA/lineB/panel/design）由 spec-plan 消费；执行键 `apply` 与 `engine`/`parallelism` 由 spec-apply 消费；能力键 `vision`（读图覆盖）由 spec-plan 与 spec-apply 共用；`verify` 由 spec-done 复用**。值 { provider, model }，可选 fallback；优先级 `--model` > 映射文件 > 继承会话模型；命令中的规划键覆盖原样转发，`apply`/`verify` 覆盖随对应半程委托交接。

## 十、边界与失败

**红线级条目**（违反即致不可逆、失控或静默假设）；其余异常与失败处置见 [failure-modes.md](refs/failure-modes.md)，**遇异常先读它**：

| 情形 | 处置 |
| --- | --- |
| 无 openspec 根（`root: null`） | 问 init / store / 放弃，**绝不副作用创建** `openspec/`（第二节） |
| 执行子代理需用户决策 / 直接提问被拒（`DELEGATED_CALLER`） | 走执行期待决中转（spec-apply 承载）：上浮 → 主会话**当批次即时代问** → team 回送**同一成员**、subagent 接续重派。**DELEGATED_CALLER 是平台设计，不是故障** |
| 计划彻底失效（工件与实现矛盾） | `auto` 硬停条件之一（四条件细则归 spec-apply 的 execution.md）：停下让用户决定重做落档（回规划 = 再加载 spec-plan 改工件）或终止 |

**绝不做**：不自行 `openspec init`；**不在用户审核确认前提交实现改动**（任何模式；用户明确豁免审核时除外）；不提交未过验证的内容；不动目标项目的 CI、密钥、生产配置（**真实密钥只经参数传入进程**，绝不写入入库文件/日志/提交信息）；不替用户切换主会话模型；不在 `auto` 之外的模式下跳过审核停留；不把子代理上浮的待决项**静默变成假设**；不把 `/tmp/spec-flow/` 的临时材料当成进度依据（权威进度永远是工件 + 勾选态 + 提交历史）；执行级红线（审核前不提交、auto 硬停、凭据纪律、分仓提交）归 spec-apply；收尾红线归 spec-done；本 skill 不 force push、不删 worktree。
