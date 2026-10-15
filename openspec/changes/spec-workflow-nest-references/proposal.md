# Proposal

## Why

`agent/skills/spec-workflow/` 现在把入口 `SKILL.md` 与 5 个 references（planning / convergence / routing / execution / failure-modes）平铺在同一层：从目录无法一眼区分「入口」与「按需读取资源」，而仓内其他 skill 已有分组先例（`spring-writer/orm/easy-query.md`、`smoke-testing-local-env/scripts/`、`reviewing-deliverables/scripts/`）。

调整可行性已逐项勘明：

- **宿主加载**：按名加载只渲染 `SKILL.md`（实测包裹开销 343~360 码点），references 由按需 `read` 读取；子目录不影响加载路径。
- **聚合与部署**：skctl 按**目录级 symlink** 登记（仅校验根有 `SKILL.md`），`~/.agents/skills/spec-workflow` 直指仓库目录——移动透明、无需重登记。
- **规格**：主规格零文件名引用，其「同 bundle 资源 + 入口路由指引 + 各文件 ≤ 宿主阈值」SHALL 由子目录布局原样满足 → 本变更**规格中性、无 delta**。
- **引用面**：5 个 references 互链是同目录相对链接（一起移动即不变）、回链入口全为散文（「SKILL.md 第 X 节」）；`dsh/commands/spec-flow.md`、`agent/skills/README.md`、`dsh/spec-workflow.yaml` 零路径引用。

## What Changes

- 5 个 references `git mv` 至 `refs/`，**内容零改动**（码点保持 6279 / 2864 / 3092 / 3900 / 2238）。
- `SKILL.md`：16 处链接 href 加 `refs/` 前缀（标签保持裸文件名）；「外移到**同目录** references」改为指向 `refs/` 子目录；同步等量收紧 ≥37 码点（净 ≤7825）——frontmatter 与 12 个 `## ` 节标题不变，红线区（红线表、恢复协议、中转协议、绝不做段）语义不动。
- `dsh/README.md`：文件表 5 行 + 2 处散文路径同步为 `agent/skills/spec-workflow/refs/xxx.md`。
- 不做：不改 5 个 references 内容与主规格；不改 `dsh/spec-workflow.yaml`、命令薄壳、宿主 profile；不动 `openspec/changes/archive/` 历史。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

（无）——布局是 skill 实体文件的组织方式，主规格 `spec-workflow` 未规定平铺或子目录，其全部 SHALL 在子目录布局下原样成立；本变更不产生 spec delta。

## Impact

- 代码：`agent/skills/spec-workflow/`（5 文件移动 + `SKILL.md` 链接与收紧）、`dsh/README.md`（路径表）。
- 不影响：宿主 skill 加载与渲染、skctl 聚合层与 `~/.agents/skills` 部署、`/spec-flow` 命令、阶段模型路由配置、主规格语义、阶段 1.7 设计线契约。
- 风险：入口渲染码点预算（现 7782 + 链接前缀 80 = 7862 > 自设门 7830）→ 以等量收紧消化；改后实测渲染 ≤8192 且余量 ≥15。
