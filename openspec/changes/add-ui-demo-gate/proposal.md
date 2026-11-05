# Proposal

## Why

AI 自行设计界面时，视觉与布局方向直到实现完成才第一次被用户看到，效果不满意即整批返工；三类开发流程（spec-workflow、openspec explorer、`/plan`）均无前置确认环节。本变更加入「界面演示」gate：命中判定（涉及界面设计且无 Figma、原型、截图等设计依据）时，先产出可预览的静态演示、经用户确认再落档或呈交计划，把界面方向的返工成本从执行后前移到规划期。

## What Changes

- **新建全局 skill `ui-demo`**（`agent/skills/ui-demo/SKILL.md` + `refs/html-recipe.md`）：触发判定（C1∧C2∧C3 + 排除表）、产出分级（L1/L2/L3 语义判据，L3 以 tab 切换为主 + 并排缩略可选）、产物规范（自包含单 HTML、零外链、≤100KB、示意数据强制标注）、chrome-shared 自检序列与降级、三流程接线表——**唯一权威源，其余触点只引用不复述**。
- **spec-plan 新增阶段 1.75 界面演示 gate**（硬 gate）：阶段 1.7 回执核对后、落档前判定；命中则产出演示并取得确认才落档，未命中记未触发事实；演示产物随落档整目录复制入变更目录 `demos/`。落点为 §六 `###` 子节（不新增顶级节、不重编号），细则外移 `refs/planning.md`。
- **spec-workflow 同步**：总览流水线含 1.75（条件），状态载体段补 `demos/` 工件权属（随落档提交、执行期只读）。
- **openspec explore/propose 与 `/plan` 软接线**：仅靠 skill `description` 触发词（`whenToUse` 经实测对触发零贡献，不采用）；`/plan` 场景演示落易失区即确认即弃（不入库）。
- **不做（本期裁定）**：nginx 统一入口（skill 内留扩展位）、`/ui-demo` 命令薄壳、AGENTS.md 转接行、`spec-workflow.yaml` demo 路由键、docker 仓任何改动。

## Capabilities

### New Capabilities

- `ui-demo`: 界面演示能力——触发判定与排除表、L1/L2/L3 产出分级、静态自包含产物规范（含路径矩阵与 file:// 双路径预览）、chrome-shared 自检与降级、三流程接线与留痕、入口与资源预算。

### Modified Capabilities

- `spec-plan`: 新增「阶段 1.75 界面演示 gate」requirement（硬 gate：未确认不得落档、未命中记事实、ui-demo 不可加载不静默跳过）；「落档工件与执行批次契约」扩演示产物整目录复制与条件断言。
- `spec-workflow`: 「固定工作流入口」补阶段 1.75 条件触发与 `demos/` 工件语义。

## Impact

- 代码触达（均 dotfiles 根仓）：`agent/skills/ui-demo/`（新建）、`agent/skills/spec-plan/SKILL.md`、`agent/skills/spec-plan/refs/planning.md`、`agent/skills/spec-workflow/SKILL.md`、`agent/skills/README.md`（登记行）。
- 机器态（不入库）：`skctl install` 产生的聚合层 symlink 与 `registry.json` 登记。
- 零触达：docker 仓、`dsh/spec-workflow.yaml`、openspec 生成 skill（explore/propose 等）、`openspec/specs/` 主规格（仅由归档同步）。
- 无 CI、密钥、生产配置影响。
