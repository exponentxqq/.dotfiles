# Code Design(实施蓝图)

## ① 文件去向总表

| 动作 | 文件 | 依据 |
| --- | --- | --- |
| 新建 | `agent/skills/spec-apply/SKILL.md` | (b).B1 全文 |
| 新建 | `agent/skills/spec-apply/refs/execution.md` | (b).B2 变换(自 spec-workflow 迁) |
| 新建 | `agent/skills/spec-apply/refs/routing.md` | (b).B3 变换 |
| 新建 | `agent/skills/spec-apply/refs/failure-modes.md` | (b).B4 全文 |
| 新建 | `dsh/commands/spec-apply.md` | (b).B5 |
| 修改 | `agent/skills/spec-done/SKILL.md` | (b).B6 变换 |
| 修改 | `agent/skills/spec-workflow/SKILL.md` | (b).B7 变换 |
| 修改 | `agent/skills/spec-workflow/refs/failure-modes.md` | (b).B8 变换(瘦身) |
| 修改 | `dsh/spec-workflow.yaml` | (b).B9(头注释) |
| 修改 | `agent/skills/spec-plan/{SKILL.md, refs/routing.md, refs/planning.md, mode/parallel.md}` | (b).B10(九处改指) |
| 修改 | `dsh/README.md` | (b).B11 |
| 修改 | `dsh/commands/spec-flow.md` | (b).B12 |
| 不动 | `agent/skills/spec-workflow/refs/worktree.md`、yaml 键值、openspec-* skills | D2 |

## (b) 逐字文本与变换指令

### B1 `agent/skills/spec-apply/SKILL.md`(全文照抄)

```markdown
---
name: spec-apply
description: spec 驱动工作流的执行半程——落档后批次执行:双引擎(subagent/team)、三模式(auto/step-task/step-group)、核对与审核-提交分离、留痕与工件维护、隔离执行落点。Use when 用户要「执行/继续执行某变更任务」或调用 /spec-apply <变更名>,或被 spec-workflow 编排委托进入执行;变更未落档指回规划。
---

# spec-apply 执行半程

本 skill 是**执行手册**:每步按本文执行,未写到的情况回到用户。本文件面向**没有本次对话上下文**的未来会话——一切从工件与命令输出重建。

## 一、总览

执行半程 = 落档提交后、归档前的全部实现工作:批次循环 → 主会话核对 → 工件维护 → 按模式停留呈证 → **用户审核确认后提交**。上游:skill `spec-workflow` 衔接(模式/引擎/执行环境已定则预置,衔接后自动委托本 skill;恢复协议由其判段路由);下游:全部任务完成后归档链由 skill `spec-done` 承载(编排层自动委托)。

**状态载体 = 工件 + `tasks.md` 勾选态 + `git log` 三方对齐**;`/tmp/spec-flow/<change>/` 材料易失、不入库、不进提交。`code-design.md`/`diff-matrix.md`(串行 `decisions.md`)以变更目录落档副本为维护对象。

承诺:**核对通过 ≠ 审核通过**(提交在用户确认后)、**绝不重跑已完成任务**、**不静默假设待决项**、规划外 scope 变化回到用户。

参数:`<变更名>`(缺省问用户;恰有一个未完成变更时可确认推断);模式/引擎未预置时首动询问。

## 二、入口与前置检查

①**已落档**:变更目录四件套存在且 `tasks.md` 非空——未落档指回规划(`/spec-plan` 或 `/spec-flow`);②**进度重建**:恢复/接续进入先按 spec-workflow 恢复协议(编排层路由至此);独立进入自查三方对齐(勾选态 + 提交历史 + 现存 diff,勾选但无验证证据 → 对现存 diff 跑验证句,通过保持勾选不重派);③**模式与引擎**:`auto`/`step-task`/`step-group`;引擎 `subagent`(默认)/`team`——已预置不重问;④**执行环境**:落档 `design.md` 决策记录执行环境块——隔离 → 子代理项目根与验证目录 = worktree 路径,代码提交落 `feature/<change>`、工件落根仓主工作区;直用主工作区 → 常规落点。worktree 布局与装配手册 = **skill spec-workflow 的 `refs/worktree.md`(唯一权威源,本 skill 跨引用不复制)**;⑤**能力自检**:栈识别结论(writer skill 名)从 design.md 决策记录读取,加载失败按 [failure-modes.md](refs/failure-modes.md) 处置顺序处理。

**压缩后恢复速查(红线级)**:进度只认三方对齐;绝不重跑已完成任务,从最小编号未完成组继续。

## 三、批次循环骨架

```
while 存在未勾选任务:
    组 = 编号最小的未完成组
    if 引擎 == subagent: 组内每任务派一个 fresh 子代理(同一条消息并发,上限 parallelism)
    else:                组内任务发布到共享任务板,spawn ≤ 组内任务数的 implementer 认领
    主会话逐任务核对(验证句 + 读改动 + git diff)→ 通过才勾选 tasks.md
    组收尾:勾选核对(本组任务全 [x]) → 工件维护(code-design 组段终形态化、R<n> 留痕) → 按模式停留呈证 → 用户确认后才提交
```

**共同纪律**:主会话必须自己按**验证句 + diff** 核对,**核对通过才勾选**;**验收须干净窗口**(无并发构建、验证任务真实 executed 无 SKIPPED——展开见 [execution.md](refs/execution.md))。

展开内容按消费时机外移 **refs/**:**派发前(两引擎)读 [execution.md](refs/execution.md)**(编排、模式与提交、干净窗口、留痕、提示模板、回执格式);**仅 subagent 派发前读 [routing.md](refs/routing.md)**(执行键路由、三档回退、白名单、读图、自检);**异常先读 [failure-modes.md](refs/failure-modes.md)**。

## 四、执行期待决中转

执行子代理**不能直接向用户提问**(`DELEGATED_CALLER`,平台设计不是故障)——它在产物与回执**上浮**待决项 → 主会话**当批次即时代问**(≤5 问/轮附推荐)→ **subagent** 以上轮回执摘要+答复**接续重派**;**team** 用 `send_message` 回**同一成员**。**不得把待决项静默变成假设**,不得为等答复阻塞轮询。展开见 [execution.md](refs/execution.md)。

## 五、模型路由(执行侧)

映射文件 **`/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml`**(绝对路径,与规划半程共用):本 skill 消费 `apply`(执行任务子代理)、`vision`(读图)、`engine`、`parallelism`;`verify` 由 spec-done 复用。优先级 `--model` > 映射文件 > 继承会话模型;**三档回退**(fallback 重派一次 → 继承会话模型一次 → 报告暂停,不反复重试)与**读图改道 vision** 展开唯一权威源 = [routing.md](refs/routing.md)(仅 subagent 引擎派发前读)。

## 六、全部任务完成后

最后批次经用户审核确认提交 → **停留,归档链与收尾由 skill `spec-done` 承载**(编排层自动委托;或用户 `/spec-done <变更名>`)。本 skill 不归档、不推送、不清理分支。**沉淀回流清单**(执行期改动的工作流仓文件,逐条列明已提交去向/未提交待决)随 spec-done 六要素汇报输出。

## 七、边界与失败(红线)

**绝不做**:不在用户审核确认前提交实现改动(用户明确豁免审核时除外);不提交未过验证的内容;不把待决项静默变成假设;不把 `/tmp` 材料当进度依据;不重跑已完成任务;不动 CI、密钥、生产配置(真实密钥只经参数传入进程);多仓分立提交不跨仓混提;不 force push。**auto 硬停四条件**(不可逆/安全敏感/工作区外副作用/计划彻底失效)与任务失败重试一次纪律见 [execution.md](refs/execution.md);其余异常处置见 [failure-modes.md](refs/failure-modes.md),**遇异常先读它**。
```

### B2 `agent/skills/spec-apply/refs/execution.md`(自 spec-workflow/refs/execution.md 迁移)

1. 整体复制现文件全文至新路径。
2. 头部说明行替换为:`> 本文件为 spec-apply SKILL.md 第三节(批次循环骨架)与第四/五节的展开正文;回入口引用写「SKILL.md 第三节」。`
3. 删除「## 附:验证与归档派发要点(自 SKILL.md §七 外移)」**整节**(七条全部迁往 spec-done,见 B6;本文件不再含归档内容)。
4. `[worktree.md](worktree.md)` 链接两处(第 6、36 行)替换为文字引用:`spec-workflow 的 refs/worktree.md(唯一权威源)`。
5. `[failure-modes.md](failure-modes.md)` 引用不变(新 bundle 内同路径有效);「第六节协议」字样改「第四节协议」;「SKILL.md 第五节恢复协议」改「spec-workflow SKILL.md 恢复协议」。
6. 「第七节」类残留引用全文 grep 清零。

### B3 `agent/skills/spec-apply/refs/routing.md`(迁移)

1. 整体复制现文件。
2. 头部说明改:`> 本文件为 spec-apply SKILL.md 第五节(模型路由·执行侧)的展开正文;仅 subagent 引擎派发前读取。`
3. `verify` 键的描述处追加注记:`verify 键由 spec-done 复用(终末验证),本文件消费视角为执行侧`。
4. 「SKILL.md 第九节」类引用改「SKILL.md 第五节」。

### B4 `agent/skills/spec-apply/refs/failure-modes.md`(全文照抄)

```markdown
> 本文件为 spec-apply SKILL.md 第七节的外移正文;回入口引用写「SKILL.md 第七节」。

## 边界与失败(执行侧处置表)

| 情形 | 处置 |
| --- | --- |
| `spec-apply` skill 或 `/spec-apply` 命令不可见 | 核对容器 symlink `~/.dsh/commands/spec-apply.md` 指向 `dsh/commands/` 源本,缺失则 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md ~/.dsh/commands/spec-apply.md`;再 `/commands-reload`;仍不可见兜底重启 dsh(宿主操作) |
| writer skill 加载失败 | 按失败处置顺序(登记核对 → `/commands-reload` → 重启兜底)修复,仍失败报告问用户,不静默降级 |
| 用户中断 | 立即停在安全检查点;未提交改动保持原状并汇报位置,不擅自 stash / revert / 补提交 |
| 审核被拒 | 按意见修正后**重审**:不勾选、不提交;修正范围超出本变更 → 回用户确认 scope |
| 任务失败(重试一次仍失败) | 暂停本批次并报告(任务号、错误、进度、建议),不中断其余批次 |
| 勾选态与证据矛盾 | 以证据为准:先对现存 diff 跑该任务验证句(未提交属预期),通过保持勾选不重派;不通过才回退并报告 |
| 显式路由不在白名单(`is not allowed for this Session`) | 按三档回退:fallback 重派一次 → 继承会话模型 → 仍失败报告暂停,不反复重试(routing.md) |
| 需读图而路由不支持(`does not declare image input`) | 改用 `vision` 路由重新派发;能力事实,不重试原路由 |
| 旧会话报 `child model selection is disabled` | 配置只对新会话生效:新建会话重试;不判定工具损坏 |
| team 成员失败 / 上限达限(`Team member limit 8 reached`) | `interrupt_agent` 中断或重建;无法恢复降级 subagent,降级与原因写留痕 |
| 验证需真实密钥而凭据缺失 | 明确报错失败,不静默跳过、不伪造结果;密钥只经参数/环境变量传入 |
| 需要宿主操作(装依赖、重启兜底) | 给确切命令交用户执行,不代劳 |
| 执行环境块缺失或 worktree 异常 | 按 spec-workflow 恢复协议与其 refs/worktree.md「恢复核对」处置;脏 → 呈证问处置,不擅自清理 |

> 注:红线级条目(审核确认前不提交、不提交未过验证内容、auto 硬停四条件、真实密钥只经参数、分仓提交、不静默假设待决项)留在 SKILL.md 第七节。
```

### B5 `dsh/commands/spec-apply.md`(全文照抄)+ symlink

```markdown
---
description: 执行半程:对已落档变更继续批次执行(spec-apply)
argument-hint: "<变更名>"
---
加载 spec-apply skill,并按其执行手册继续该变更的批次执行。

调用参数:$ARGUMENTS

规则:
- 变更未落档时提示先走规划(/spec-plan 或 /spec-flow),不进入执行。
- 执行模式与引擎未预置时先询问,不自行假设。
```

symlink:`mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md ~/.dsh/commands/spec-apply.md`(容器内可代做)。

### B6 `agent/skills/spec-done/SKILL.md` 变换

1. frontmatter `description` 替换为:`spec 驱动工作流的终末半程——验证归档(项目验证门→verify-change→archive 同步主规格→归档提交→六要素汇报)与收尾闭环(rebase→全量复验→推送→合并确认→删 worktree→清分支),从工件与 git 事实三方重建进度。Use when 用户要「归档/收尾/闭环/推送合并/删 worktree」或调用 /spec-done <变更名>;任务未全完成指回 spec-apply。`
2. §一总览:第一段「收尾 = 已归档变更的最后一段」替换为「终末半程 = 变更的最后一段:**验证归档链**(任务全完成后:项目验证门 → verify-change → archive → 归档提交 → 六要素汇报 → 停留)与**收尾闭环**(隔离八步 / 非隔离轻量)」;「上游:spec-workflow(执行与归档,其归档汇报⑥遗留待办指路到本 skill)」替换为「上游:spec-apply(执行半程,全部任务完成且批次提交后,由编排层 spec-workflow 自动委托本 skill 收口归档链;亦可 /spec-done 独立发起)」;worktree 权威源句不变。
3. §二前置检查①替换为:`①**判归档状态**:变更已归档(active 列表无该名 + archive/ 下 *-<变更名>/ 存在)→ 直接进三方重建;未归档且 tasks 全勾 → 先走归档链(第二节');未归档且任务未全完成 → 拒绝入口,提示先经 spec-apply 完成执行,不代跑。` 其余②③④不变。
4. 在§二与§三之间插入新节:

```markdown
## 二'、验证门与归档(未归档且任务全完成时先走)

1. **项目验证门**:先读项目声明的验证方式(AGENTS.md/CLAUDE.md → README、scripts、CI),**干净窗口**执行(两步法:无并发构建、真实 executed 无 SKIPPED/FROM-CACHE);可派 fresh 子代理(按 `/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml` 的 `verify` 路由);**真实密钥只经参数传入进程**。不通过 → **不归档**:报告证据,问用户修复(回 spec-apply 派修复)或显式批准跳过并记已知缺口。
2. **归档前校验**:加载 `openspec-verify-change`(任务全勾、spec 覆盖映射、design 一致性);缺漏先修复重校(补勾、补 delta),不绕过校验归档。
3. **归档**:`tasks.md` 全部勾选 → `openspec-archive-change` 归档并同步主规格;报错贴原文并停,**不手工搬移目录**。
4. **归档单独提交一次**(`docs(openspec): 归档 <change>`),不与批次改动混提。
5. **六要素汇报**:①变更名与工件路径;②验证证据(命令+结果摘要);③归档位置(archive/ 与同步后的主规格);④后续宿主操作清单(skctl 登记、推送探测不可行时的宿主命令等);⑤沉淀回流清单(执行期改动的工作流仓文件逐条列明,交用户决定提交与方式,不代提交);⑥遗留待办(worktree 闭环清单与 `/spec-done` 入口、临时偏离恢复点、预留编号)。
6. **停留**:汇报后停下等用户决定收尾时机,**不自动进入推送/合并/清理**;用户指示收尾 → 进三方重建按仓推进。
```

5. §六红线表追加三行:`| 归档前验证失败 | 不归档:报告证据,问用户修复或显式批准跳过并记已知缺口 |`;`| verify-change 校验缺漏 | 先修复重校(补勾/补 delta),不绕过校验归档 |`;`| archive 命令报错 | 贴原文并停,不手工搬移目录 |`。「变更未归档」行改为「任务未全完成未归档 → 指回 spec-apply;任务全完成未归档 → 本 skill 收口归档链」。

### B7 `agent/skills/spec-workflow/SKILL.md` 变换(残段改述)

1. frontmatter `description` 替换为:`固定 spec 驱动开发工作流的统一编排入口——四段委托:规划(spec-plan)、衔接与执行环境决策(本 skill)、执行(spec-apply)、终末归档与收尾(spec-done),含恢复协议与判段路由。Use when 用户要"走 spec 工作流/固定工作流/spec-flow"或接续未完成的 OpenSpec 变更;全程体验一体化。`
2. §一总览第一段替换为:

```markdown
四段流水线,入口为用户级命令 `/spec-flow`(命令薄壳加载本 skill):**阶段 1→2(规划半程)委托 skill `spec-plan`** 至落档提交;**本 skill 承载衔接**(执行模式/引擎确认、执行环境决策与创建装配)与**全流程编排**(恢复协议、判段路由);**执行半程(阶段 3)委托 skill `spec-apply`**;**终末半程(阶段 4 验证归档 + 收尾闭环)由 skill `spec-done` 承载**,执行完成后本 skill 自动委托其收口归档链:

阶段1 独立双线规划 → 阶段1.5 差异收敛 → 阶段1.7 代码设计 → 阶段2 落档(spec-plan 承载,至落档提交)
→ 衔接(本 skill:模式/引擎/执行环境)→ 阶段3 执行(spec-apply 承载)→ 阶段4 验证与归档 + 收尾闭环(spec-done 承载)
```

3. §一消费时机表:`execution.md` 行、`routing.md` 行删除(已随 spec-apply 迁走);保留 worktree.md 行与 failure-modes.md 行,并追加一行:`| 执行期展开(编排/模式/提示模板/回执/路由/执行失败) | 读 skill **spec-apply** 的 SKILL.md 与其 refs/(execution/routing/failure-modes)——执行半程唯一权威源 |`。
4. §四末尾「再进入衔接」后追加一句:`衔接完成后**委托 skill spec-apply 进入执行**(衔接预置项随指针交接,已预置不重问)。`
5. §五:衔接③尾追加 `随后委托 spec-apply`;恢复协议第 5 步后插入新步并重编号:`5'. **判段路由**:重建进度后判定当前段——未落档 → 回规划(再载 spec-plan);已落档未完 → 路由 spec-apply(从最小组继续);已归档 → 路由 spec-done(收尾);第 7 步摘要句加「当前段」。原 6/7/8 顺延。
6. §六整节替换为:`## 六、执行半程(委托 spec-apply)\n\n批次执行(双引擎、三模式、核对与审核-提交分离、留痕与工件维护、隔离执行落点)由 skill **spec-apply** 承载,其 SKILL.md 与 refs/(execution/routing/failure-modes)为唯一权威源,本 skill 不复述;衔接预置项(模式/引擎/模型覆盖/执行环境块)随委托指针交接。` 「压缩后恢复速查」句保留于§一不变。
7. §七整节替换为:`## 七、终末半程(委托 spec-done)\n\n验证门与归档(项目验证 → verify-change → archive 同步主规格 → 归档单独提交 → 六要素汇报)与收尾闭环(隔离八步/非隔离轻量)由 skill **spec-done** 承载。执行半程全部批次完成且经用户审核提交后,本 skill **自动委托 spec-done 收口归档链**(全流程体验不变);用户亦可 /spec-done 独立发起。本 skill 不归档、不推送、不清理。`
8. §八:第④句改「按判段路由(§五 5')进入对应半程,执行段重新确认模式与引擎由 spec-apply 首动承接」。
9. §九:首段替换为:`映射文件 /home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml(绝对路径)为四段共用的唯一路由配置:**规划键(lineA/lineB/panel/design)由 spec-plan 消费;执行键 apply、能力键 vision 与 engine/parallelism 由 spec-apply 消费;verify 由 spec-done 复用**。值 { provider, model },可选 fallback;优先级 --model > 映射文件 > 继承会话模型;命令中的规划键覆盖原样转发。回退与读图细则权威源 = spec-apply 的 refs/routing.md。` 其后红线要点段删除(细则已随迁)。
10. §十:保留编排级红线(无根不副作用创建、DELEGATED_CALLER 中转、计划彻底失效硬停、规划参数转发纪律);「不在用户审核确认前提交实现改动」等执行级红线句改为 `执行级红线(审核前不提交、auto 硬停、凭据纪律)归 spec-apply;收尾红线归 spec-done`;表内「执行子代理需用户决策」行的处置保持(中转机制总述)。
11. 全文 grep 确认:`refs/execution.md`、`refs/routing.md` 引用为 0。

### B8 `agent/skills/spec-workflow/refs/failure-modes.md` 变换(瘦身)

保留条目(衔接/编排/恢复):`/spec-flow 命令或 skill 不可见`、`spec-plan 加载失败`(把「或 openspec-archive-change」从该行拆出)、`用户中断`、`宿主操作+推送例外`(总述版)、`worktree 分支被占`、`恢复时 worktree 缺失或脏`;新增两行:`| 执行期失败(任务失败/审核被拒/路由回退/team 降级/凭据缺失) | 处置权威源 = skill spec-apply 的 refs/failure-modes.md,本 skill 不复述 |`;`| 归档与收尾期失败(验证失败/verify-change 缺漏/rebase 冲突/push 被拒/删 worktree 门槛) | 处置权威源 = skill spec-done 正文红线表,本 skill 只指路 |`。删除行:`审核被拒`、`任务失败`、`勾选态与证据矛盾`(归 apply——编排层恢复协议正文已有以证据为准句)、`白名单三档回退`、`读图`、`旧会话 child model`、`team 成员`、`真实密钥`、`openspec-archive-change 加载失败`(归 done)。头部注记改 `> 本文件为 SKILL.md §十的外移正文(衔接与编排侧);执行侧见 spec-apply、终末侧见 spec-done 的对应文件。`

### B9 `dsh/spec-workflow.yaml` 头注释

现注释块替换为(键值不动):

```yaml
# spec 四段共用阶段级模型路由(文件名沿用 spec-workflow,历史锚定)
#   规划键 lineA/lineB/panel/design → spec-plan 消费
#   apply/vision、engine、parallelism → spec-apply 消费(两半共用本文件与白名单)
#   verify → spec-done 复用(归档前验证与收尾复验)
```

### B10 spec-plan 九处改指(位置 → 旧文 → 新文)

| 文件:行 | 旧 | 新 |
| --- | --- | --- |
| SKILL.md:3 | `或被 spec-workflow 委托执行其阶段 1→2` | `或被 spec-workflow 编排委托其阶段 1→2` |
| SKILL.md:12 | `或被 spec-workflow 委托作为其阶段 1→2` | `或被 spec-workflow 编排委托作为其阶段 1→2` |
| SKILL.md:20 | `委托场景由 spec-workflow 无缝衔接:确认执行模式与引擎后继续` | `委托场景由 spec-workflow 衔接后委托 spec-apply 继续(模式/引擎由其承接)` |
| refs/routing.md:12 | `engine: subagent    # 由 spec-workflow 消费,本 skill 不读` | `engine: subagent    # 由 spec-apply 消费,本 skill 不读` |
| refs/routing.md:28 | `执行键 apply/verify 与 engine 由 spec-workflow 消费` | `执行键 apply、engine/parallelism 由 spec-apply 消费,verify 由 spec-done 复用` |
| refs/routing.md:36 | `执行侧主路由(spec-workflow 消费)` | `执行侧主路由(spec-apply 消费)` |
| refs/routing.md:38 | `执行侧备用路由(spec-workflow 消费)` | `执行侧备用路由(spec-apply 消费)` |
| refs/planning.md:22 | `spec-workflow 执行侧与接续恢复从工件读取该结论…阶段 3 沿用同一结论(spec-workflow 侧无从取得时重识别一次)` | `spec-apply 执行侧与接续恢复从工件读取该结论…阶段 3 沿用同一结论(spec-apply 侧无从取得时重识别一次)` |
| mode/parallel.md:23 | `若后续 spec-workflow team 执行需成员` | `若后续 spec-apply team 执行需成员` |

(routing.md:64 的 `同 spec-workflow team 引擎忽略 apply 键先例` 改为 `同 spec-apply team 引擎忽略 apply 键先例`——共十处,以实际 grep 为准全量替换。)

### B11 `dsh/README.md`

- :121 节标题与 :125 拆分结构段:改述为四段(spec-plan 规划 / spec-workflow 编排衔接 / spec-apply 执行 / spec-done 终末),沿既有叙述框架。
- :136-139 文件清单表:spec-workflow 行改「编排与衔接半程本体(执行手册已迁 spec-apply)」;execution/routing/failure-modes 行路径改 `agent/skills/spec-apply/refs/`;新增 spec-apply SKILL.md 行与 spec-apply 命令行。
- :141 yaml 行、:174-199 路由消费表:消费者列按 B9 分工改(spec-apply / spec-done)。
- :145 入口段:加 `/spec-apply`(与 /spec-plan、/spec-done 并列的半程直达);归档收口改「执行完成后自动委托 spec-done」。
- :155-172 执行半程叙述:承载者改 spec-apply,worktree 手册权威源仍指 spec-workflow 的 refs/worktree.md。
- :219-228 安装段:加 spec-apply 的 skctl install 命令与校验行。

### B12 `dsh/commands/spec-flow.md`

description 替换为:`固定工作流:双线规划→落档→衔接→执行→验证归档→收尾(spec-workflow 编排,spec-plan/spec-apply/spec-done 分段承载)`;正文第 5 行改 `加载 spec-workflow skill,并按其四段编排执行(规划→衔接→执行→终末)。`

## 验证口径备忘

**评审修复留痕(终形态)**:变更评审后主会话直修 9 项——①yaml:3 头注释 vision 归属改「spec-plan(规划线读图)与 spec-apply 共用」并统一「四段共用」措辞,spec-workflow SKILL.md §九同步;②spec-apply §六沉淀回流清单改「最后批次组收尾工件化(tasks.md 附录、随最后批次提交)」、spec-done §二'.5⑤ 补重建来源(工件优先、git status 辅证),消跨会话信息断裂;③spec-apply/refs/execution.md:24 附节头「自 SKILL.md §六 外移」改「对应第二节③与第三节」、:1 头部说明同步;④spec-workflow/refs/failure-modes.md:6 被委托方列举与 symlink 清单补 spec-apply/spec-done;⑤README yaml 示例 provider zai→zai-coding-cn(示例块 3 处+叙述行 2 处)、parallelism 3→8,spec-apply routing.md:15 与 spec-plan routing.md:13 示例同步 8(zai-coding-cn 双模型在白名单 cordis.patch.yml:140-141 证实);⑥spec-done §二① 补「先完成②读执行环境块再进二节'」、§二'.1 补执行目录判据(隔离=worktree/非隔离=主工作区);⑦spec-workflow §八② 补已归档分支(转 spec-done 收尾,不进③④);⑧半角标点归一全角(spec-apply SKILL.md 与 failure-modes.md 全量、spec-workflow SKILL.md 新段、routing.md 头注、命令壳、yaml 头注释),§四尾句补 spec-apply 反引号(修后「委托 skill `spec-apply`」grep=2 达标,修前=1);⑨spec-apply.md argument-hint 补 --engine/--model。附带补明 --model verify 覆盖经编排层随终末委托交接 spec-done(拆分后原为盲区)。tasks 验证锚点经 grep 复核全部保持。

**主会话复核留痕(评审修复后独立复跑)**:9 项逐条对照实际文件确认落地;事实核对补证——parallelism 示例 3→8 系对齐实际值(HEAD 基线 yaml:28 即 `parallelism: 8`,键值零动、16 行变更全为注释);yaml 头注释/spec-plan routing 注记行/spec-workflow §九 vision 归属三处口径一致;spec-apply §六「工件化+从工件读出」与 spec-done §二'.5⑤「优先读附录+git status 辅证」双侧闭环。一处裁定:planning.md:72 对齐四段新口径后含「被 spec-workflow 委托时」命中 4.1 验证句模式,属编排委托类合法叙述(5.1 豁免四类之一),按 3.2 先例在 tasks 4.1 行内补豁免注记,不改文本。码点断言 16 文件(spec-plan 7+spec-workflow 4+spec-apply 4+spec-done 1)全 ≤7849、validate --strict valid、命令壳 symlink 指向源本。

**组4 实测留痕(终形态)**:spec-plan 四文件 13 处替换(表内 11+表外同口径 2:SKILL.md:104 消费分工、planning.md:72 衔接指路),旧执行语义残留 0、spec-apply 引用 10、四文件码点全过;README 34+行变更;spec-flow description 更新。主会话补修四处(子代理回执照指令正确,均系蓝图笔误/遗留):①「五个等价入口」→「八个等价入口(四对)」(4 对=8 个入口点,蓝图计数错);②安装段补 spec-apply/spec-done 两行 symlink;③补 spec-done install 行(上次 worktree-lifecycle 变更遗留缺口顺带补齐);④校验句补 /spec-done 与 spec-done。子代理报备修正采纳:yaml 示例块 apply 行内注释消费者同步改 spec-apply。

组3 实测留痕(终形态):spec-workflow/SKILL.md 116→99 行、7710→**6143 码点**(解压 1567,余量 1706);failure-modes.md 22→14 行、1653 码点;yaml 头注释 12→4 行纯注释替换(键值零 diff)。主会话补修一处蓝图漏项:§十「计划彻底失效」行「四条件见第六节」改指「细则归 spec-apply 的 execution.md」(§六已指针化,交叉引用落点失真——子代理上浮发现)。裁决记录:failure-modes 指路行分类列举含「审核被拒」grep=1 属合法(验证意图=旧行删净,已达成);T3.1 蓝图替换文本半角标点按逐字照抄接受(spec-workflow 入口本为混用风格)。用户审核发现 design「整体迁移」在任务拆解中缺删除动作:spec-workflow/refs/{execution.md,routing.md} 引用已清零但文件实体残留成孤儿(聚合层整目录 symlink 仍向运行时暴露旧口径),补任务 3.4 删除;refs/ 终态仅 failure-modes.md(1653)+worktree.md(2297),与 §一消费时机表保留行一致,全仓活跃路径引用与 bundle 内相对链接均 0。

组2 实测留痕(终形态):spec-done/SKILL.md 53→65 行、4452 码点(预算 ~4400 吻合);六项变换全落位,验证六条全过。主会话核对期精修两处:H1「收尾半程」→「终末半程」(定位升级对齐)、§一 verify 回退权威源改指 spec-apply 的 refs/routing.md;子代理自行把蓝图半角标点归一为全角(内容零偏差,采纳)。

组1 实测留痕(终形态):SKILL.md 3184 码点、execution.md 4494(标点统一全角后)、routing.md ~4000(修正后)、failure-modes.md 1330、命令壳 485 字节——全 ≤7849。主会话核对期修正四处(子代理回执照蓝图逐字正确,修正系蓝图自身措辞缺陷):①routing.md 节标题「九」→「五」(对齐新入口节号);②:26 规划键转发主体「本 skill」→「编排层 spec-workflow」(迁移后失真);③:65 主会话模型提示句改指编排层/spec-done 分载;④execution.md 替换文本标点统一全角。failure-modes.md 权限 600→644 统一。被否方案:保留「九」编号(观感不一致弃)。

- 码点断言:全部新建/修改 skill 文件 ≤7849(python3 len 断言)。
- 旧指残留清零:`grep -rn "spec-workflow" agent/skills/spec-plan/ dsh/README.md dsh/commands/spec-flow.md` 中「消费/承载执行/执行侧」语义的行逐一核对指向 spec-apply(worktree.md 权威源、yaml 文件名、编排委托三类表述除外)。
- 链接断言:spec-apply/refs 内 markdown 相对链接仅指向本 bundle(failure-modes.md/execution.md 内);worktree 引用一律文字表述。
- `openspec list --specs` 四 spec;`openspec validate split-spec-apply-done --strict` valid。
