# Proposal

## Why

spec-workflow 在上次 worktree-lifecycle 增补后,SKILL.md 已达 7710 码点(上限 7849,余量 139——任何增量即撞顶);其承载的三块职责消费时机互不重叠却混居一份入口:衔接与恢复(落档后一次性)、执行(§六 + execution.md 5566 + routing.md 3943,贯穿执行期)、归档(§七,全部完成后一次性)。同时归档(verify-change→archive→归档提交→六要素汇报)与收尾(rebase→push→删 worktree→闭环)本是变更终末的连续动作,却分居 spec-workflow/spec-done 两 skill、以「指路」交接。split-spec-plan-skill 变更已验证「半程独立成 skill + 委托」模式(README 有现成拆分结构叙述),本变更是该模式的第二次应用:拆执行、并归档,四段各归其位。

## What Changes

- **拆出执行 skill `spec-apply`(F1)**:阶段 3 执行半程独立成 skill——双引擎(subagent/team)、三模式(auto/step-task/step-group)、批次循环、审核-提交分离、执行期中转、留痕与工件维护、干净窗口验收全部随迁;`refs/execution.md`、`refs/routing.md` 整体随迁,`refs/failure-modes.md` 执行条目随迁;新命令 `/spec-apply <变更名>`(直达执行段,与 `/spec-plan`、`/spec-done` 对称);编排层与独立入口双形态进入。
- **spec-done 升级为终末半程(F2)**:归档链并入——前置从「已归档否则拒绝」反转为「未归档→先跑归档链(项目验证门→openspec-verify-change→archive 同步主规格→归档单独提交→六要素汇报→停留等用户决定收尾时机);已归档→直接三方重建收尾」;六要素汇报改由 spec-done 输出(归档动作执行者);归档失败条目并入正文红线表;归档前验证门与收尾 rebase 后全量复验两道时点维持。
- **spec-workflow 改述为「全流程编排与衔接半程」(F3)**:保留名(挂在 /spec-flow、yaml、spec id、九处 spec-plan 引用上);§六/§七指针化;衔接(模式/引擎确认、执行环境决策+创建装配)、恢复协议(三方对齐→**判定当前段→路由加载对应 skill**)、接续留守;`refs/worktree.md` 留守(衔接创建时点持有;spec-apply/spec-done 跨 bundle 引用,机制已验证);failure-modes 瘦身为衔接/编排条目;`dsh/spec-workflow.yaml` 保持原名原位,仅更新头注释消费者表。
- **联动面(F4)**:spec-plan 九处「执行侧由 spec-workflow 消费/承载」表述改指 spec-apply;`dsh/README.md` 拆分结构/文件清单/路由消费表/入口说明更新;`dsh/commands/spec-flow.md` description 更新。

## Capabilities

### New Capabilities

- `spec-apply`:执行入口与批次编排、subagent 引擎、team 引擎、执行模式与提交节奏、干净窗口验收、多仓分立提交(执行侧)、执行期留痕与工件维护、交互中转、writer skill 接线、真实凭据纪律、沉淀回流、隔离执行落点、执行侧模型路由、元 Requirement(压缩存活/单次加载)。

### Modified Capabilities

- `spec-workflow`:**REMOVED** 执行类与归档类 Requirement(迁出至 spec-apply / spec-done);**MODIFIED** 固定工作流入口(四段编排改述)、落档到执行的衔接与恢复(恢复协议改「判段路由」)、阶段级模型路由(共用映射文件总述)、接续未完成变更;留守执行环境三件(隔离决策/布局与创建装配/本地配置与环境错开)原位。
- `spec-done`:**MODIFIED** 收尾入口与三方重建(前置反转为终末半程一体化);**ADDED** 验证门与归档(自 spec-workflow 迁入并适配)。
- `spec-plan`:**MODIFIED** 表述类联动(委托/消费方/交接指路改指 spec-apply,行为语义不变)。

## Impact

- 代码/文档:新建 `agent/skills/spec-apply/{SKILL.md, refs/execution.md, refs/routing.md, refs/failure-modes.md}` + `dsh/commands/spec-apply.md`;改 `agent/skills/spec-done/SKILL.md`(归档链并入)、`agent/skills/spec-workflow/{SKILL.md, refs/failure-modes.md}`(瘦身;worktree.md 不动)、`dsh/spec-workflow.yaml`(注释)、`agent/skills/spec-plan/{SKILL.md, refs/routing.md, refs/planning.md, mode/parallel.md}`(九处改指)、`dsh/README.md`、`dsh/commands/spec-flow.md`。主规格四份随归档 delta 同步。
- 环境依赖:`/spec-apply` 命令需容器内 `~/.dsh/commands/spec-apply.md` symlink(先例可代做);新 skill 需聚合层登记(skctl install——**宿主操作**,命令呈证交用户)。
- 码点预算:spec-apply 入口 ~3500、spec-workflow 残段 ~5500、spec-done ~4400,均远低于 7849,断言兜底。
- 自举:本变更改 spec-workflow 自身——skill 加载为快照,执行中期改文本不影响当轮;任务组按「先新建(spec-apply)后改述(spec-workflow)」排序。
- 不影响:spec-plan 方法论内核、openspec-* skills、yaml 键值、worktree.md 内容、既有归档变更。
