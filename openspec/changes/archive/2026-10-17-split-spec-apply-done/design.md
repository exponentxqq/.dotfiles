# Design

## Context

spec-workflow SKILL.md 7710/7849 码点贴顶(余 139),三块消费时机互不重叠的职责(衔接恢复/执行/归档)混居一份入口;归档与收尾两个终末动作分居两 skill 以指路交接。split-spec-plan-skill 已验证「半程独立+委托」模式(见 `dsh/README.md` 拆分结构叙述)。本变更全部设计决策经 grill-me 三轮 11 问裁定(记录见 decisions.md),无开放问题。

## Goals / Non-Goals

- Goals:四段各归其位(spec-plan 规划 / spec-workflow 编排衔接 / spec-apply 执行 / spec-done 终末);归档与收尾一体化;`/spec-flow` 全程体验不变;三半程均可独立进入又被编排委托。
- Non-Goals:不改 spec-plan 方法论内核;不改 yaml 键值与文件名;不改 worktree.md 内容;不动 openspec-* skills;不重构既有归档变更。

## Decisions

### D1 命名与残段定位(grill Q4)

新 skill `spec-apply`(与 yaml `apply` 键、官方 `/openspec-apply-change` 对齐);残段保留名 `spec-workflow`——名字挂在 `/spec-flow` 命令、`dsh/spec-workflow.yaml`、spec id、spec-plan 九处引用与聚合层登记上,改名纯迁移风险零行为收益。残段定位:「全流程编排与衔接半程」。

### D2 资产归属(grill Q6)

| 资产 | 去向 | 说明 |
| --- | --- | --- |
| refs/execution.md(5566) | spec-apply | 整体迁移+称呼适配(「本 skill」语境重述) |
| refs/routing.md(3943) | spec-apply | 整体迁移;`dsh/spec-workflow.yaml` 引用路径不变 |
| refs/worktree.md(2297) | **留守 spec-workflow** | 创建发生在衔接时点(编排层职责);spec-done 既有引用零迁移;spec-apply 跨 bundle 引用(机制已由 spec-done 验证)。**内容不动**,仅引用者+1 |
| refs/failure-modes.md(2503) | 按段拆三份 | 执行条目→spec-apply/refs/failure-modes.md;归档条目→spec-done 正文红线表;衔接/编排条目→spec-workflow 原文件瘦身 |
| dsh/spec-workflow.yaml | **原名原位** | 五消费者锚定(spec-plan SKILL+refs、workflow、done、cordis.patch.yml 注释);仅更新头注释消费者表 |

### D3 恢复协议=编排层判段路由(grill Q5)

恢复协议留 spec-workflow:三方对齐重建 → 判定当前段(未落档→spec-plan 回规划;落档未完→spec-apply 从最小组继续;已归档→spec-done 收尾)→ 路由加载对应 skill。`/spec-flow continue` 单入口不变;各半程 skill 自带段内恢复细节(apply:落档副本/worktree 装配核对引用 worktree.md;done:三方重建既有)。

### D4 spec-done 终末一体化(grill Q7)

前置反转:未归档且任务全完成→先跑归档链;未归档且任务未完→拒绝入口指回 spec-apply;已归档→直接三方重建。归档链六步:①项目声明验证(干净窗口)②openspec-verify-change 校验 ③openspec-archive-change 归档+同步主规格 ④归档单独提交 ⑤六要素汇报(含沉淀回流清单、遗留待办)⑥停留等用户决定收尾时机。触发两途:编排层在执行半程完成后自动委托;`/spec-done <变更名>` 独立发起。归档前验证门与收尾 rebase 后全量复验**两道时点维持**。

### D5 入口拓扑(grill Q1/Q8)

四 skill 四命令:`/spec-flow`(编排)、`/spec-plan`(规划直达)、`/spec-apply <变更名>`(执行直达:校验落档事实,未落档指回规划;模式/引擎未知先问)、`/spec-done <变更名>`(终末直达)。命令薄壳模式沿既有 `dsh/commands/*.md` + `~/.dsh/commands/` symlink。

### D6 主规格重排逐 R 清单(grill Q9)

spec-workflow 22R:REMOVED→spec-apply 11R(subagent 引擎/team 引擎/执行模式与提交节奏/干净窗口/多仓分立/沉淀回流/真实凭据/留痕与工件维护/交互中转/writer 接线/隔离执行落点)、REMOVED→spec-done 1R(验证门与归档提交,拆为「验证门与归档执行」「归档汇报与收尾停留」两条)、MODIFIED 6R(固定入口/衔接与恢复/接续/路由总述/读图回退共用总述/压缩存活)、原位不动 4R(单次加载/隔离决策/布局装配/环境错开)→ 残 10R。
spec-apply 新 spec:15R = 入口(新)+11 迁入+执行侧模型路由(新,自路由两 R 提炼)+元 R×2。
spec-done:MODIFIED 1R(收尾入口与三方重建)+ADDED 2R。spec-plan:MODIFIED 2R(路由 R 消费分工、栈识别 R 的 Scenario 改指 spec-apply)。

## 触达面清单

- **新建**:`agent/skills/spec-apply/{SKILL.md, refs/execution.md, refs/routing.md, refs/failure-modes.md}`、`dsh/commands/spec-apply.md`、容器 symlink `~/.dsh/commands/spec-apply.md`
- **修改**:`agent/skills/spec-done/SKILL.md`(归档链并入)、`agent/skills/spec-workflow/{SKILL.md, refs/failure-modes.md}`(残段改述+瘦身)、`dsh/spec-workflow.yaml`(头注释)、`agent/skills/spec-plan/{SKILL.md, refs/routing.md, refs/planning.md, mode/parallel.md}`(九处改指)、`dsh/README.md`(拆分结构/文件清单/路由消费表/入口说明)、`dsh/commands/spec-flow.md`(description)
- **不动**:`agent/skills/spec-workflow/refs/worktree.md` 内容、yaml 键值、openspec-* skills、既有归档

## Risks / Trade-offs

- **交接契约 +1**:衔接→执行多一个交接点(模式/引擎/执行环境块/栈识别结论经 design.md 工件传递)——已有块 schema 与恢复协议核对兜底。
- **恢复路由判定复杂化**:判段逻辑本身是新复杂度——以 tasks 勾选态+active 列表+archive 目录三事实机械判定,不依赖对话记忆。
- **码点**:预算 spec-apply 入口 ~3500 / workflow 残段 ~5500 / done ~4400,全 ≤7849;断言兜底,超限压缩措辞不砍红线。
- **自举**:本变更改 spec-workflow 自身——skill 加载为快照,执行中期改文本不影响当轮;任务组按「先新建 spec-apply(组1)后改述 spec-workflow(组3)」排序,任意组间压缩按(现行)恢复协议从工件续跑。

## Migration Plan

任务组(顺序执行,组间审核):组1 新建 spec-apply 全套+命令壳+symlink → 组2 spec-done 归档链并入 → 组3 spec-workflow 残段改述+failure-modes 瘦身+yaml 注释 → 组4 spec-plan 九处改指+README+spec-flow description → 组5 全库校验(码点/锚点/链接/旧指残留/validate)。

## 执行环境

直用主工作区(根仓 dotfiles 单仓、无并行变更、纯文本变更);无 worktree、无端口/数据库错开、无入库配置改动。收尾走非隔离轻量(推送 master+遗留待办复核)。
