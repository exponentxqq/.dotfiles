# Decisions(grill-me 三轮裁定留痕)

| # | 问题 | 裁定 |
| --- | --- | --- |
| Q1 | 拆分范围 | **A 全拆四段**:执行拆出 + 归档并入 spec-done,一次变更(22R 主规格只重排一次,分两次则同批 Requirement 被动两次) |
| Q2 | 时序 | 先 `/spec-done spec-workflow-worktree-lifecycle` 收尾(实际推 7 笔含 execution-hardening 遗留 2 笔)再开工——已完成 |
| Q3 | 本变更执行环境 | 直用主工作区(design.md 执行环境块留痕;收尾非隔离轻量) |
| Q4 | 命名 | 新 skill `spec-apply`;残段保留名 `spec-workflow`(定位改述「全流程编排与衔接半程」) |
| Q5 | 恢复协议归属 | 留编排层:三方对齐→判定当前段→路由加载对应 skill;`/spec-flow continue` 单入口不变 |
| Q6 | 资产归属 | execution/routing 随迁;worktree.md 留守(apply/done 跨 bundle 引用);failure-modes 按段拆三份;yaml 原名原位仅改注释 |
| Q7 | spec-done 定位 | 前置反转为终末一体化:未归档先归档链(验证门→verify-change→archive→归档提交→六要素→停留);触发=编排委托+独立 `/spec-done`;两道验证时点维持;六要素改由 done 输出 |
| Q8 | `/spec-apply` 命令壳 | 配(与 /spec-plan、/spec-done 对称;直达执行段) |
| Q9 | 主规格重排原则 | 执行 11R→spec-apply 新 spec;验证门 1R→spec-done 拆两条;留守 MODIFIED 6R+原位 4R;元 R 每 skill 各持;spec-plan MODIFIED 2R 联动 |
| Q10 | 变更名 | `split-spec-apply-done`(沿 split-spec-plan-skill 先例,一名涵盖两动作) |
| Q11 | failure-modes 形态 | 混合:apply/workflow 各自 refs/failure-modes.md;done 归档条目并入正文红线表 |

## 前置收尾记录(阶段 0)

- 推送 `176e3c6..778bdb8`(7 笔:worktree-lifecycle 5 + execution-hardening 遗留 2),master 与远端同步
- worktree-lifecycle 遗留待办终态:唯一遗留(收尾本身)闭环;临时偏离 1 处((b).T11-2 基线笔误,已修正留痕);预留编号无
