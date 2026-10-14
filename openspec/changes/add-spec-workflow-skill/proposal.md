# Proposal

## Why

当前每个需求都要手工编排「双线规划 → 差异收敛 → 落档 → 执行 → 归档」全过程：两条规划线靠临时决定、执行粒度与提交节奏靠临场发挥、多 agent 协作方式每次重来，既无法复用也无法审计。把该流程固化为全局 skill 加斜杠命令后，任意 OpenSpec 项目都能用同一套可重复、可审计的固定工作流，并且把「多 agent 并行」「逐 task 停留审核」等选项变成流程的一等参数。

## What Changes

- 新增全局 skill `spec-workflow`：实体落在 `agent/skills/spec-workflow/`（git 管理），经 skctl 聚合层供 dsh/opencode 全局使用；正文承载五阶段编排（含两条方向不同且各自完整的独立规划线与差异复算）、双执行引擎、三种执行模式、状态恢复协议与阶段级模型路由
- 新增用户级斜杠命令 `/spec-flow`：源本 `dsh/commands/spec-flow.md`（git 管理），宿主 `/data/dsh/commands/spec-flow.md` 以 symlink 指向源本；支持新建、接续、并行、执行模式与引擎、模型覆盖等参数
- 新增阶段级模型映射文件 `dsh/spec-workflow.yaml`（键 lineA/lineB/panel/apply/verify，默认空 = 继承会话模型）
- 打开 dsh 的 subagent 模型选择能力：profile patch 增加 `subagent-model-selection-settings` 一条覆盖（enabled + 允许模型白名单）——`tool-subagent` 的 `modelSelectionSettings` 已由 agent 预设层自带 `true`，无需也不应在 profile 层重复覆盖
- 补装 7 个 `openspec-*` skill（core 6 + verify）到宿主 skctl 聚合层——仓库文档声称已装，实际缺失
- 更新 `agent/skills/README.md`（清单表）与 `dsh/README.md`（固定工作流章节、宿主操作）
- 不改动 dsh 内核、既有插件与既有 skill 行为

## Capabilities

### New Capabilities

- `spec-workflow`: 固定 spec 驱动开发工作流——统一入口（skill + `/spec-flow` 命令）、两条方向不同且各自完整的独立规划线与差异复算（可选双 subagent 并行）、OpenSpec 落档与执行批次契约、subagent/team 双执行引擎、auto 与逐 task/逐组审核三种模式、基于工件的跨压缩/重启恢复、阶段级模型路由与验证归档提交节奏

### Modified Capabilities

（无——本次为纯新增能力，不改变既有 spec 级行为）

## Impact

- **新增**：`agent/skills/spec-workflow/SKILL.md`、`dsh/commands/spec-flow.md`、`dsh/spec-workflow.yaml`
- **修改**：`dsh/profiles/web/cordis.patch.yml`（模型选择开关与白名单）、`agent/skills/README.md`、`dsh/README.md`
- **宿主环境**：skctl 聚合层登记（spec-workflow + 7 个 openspec skills）、`/data/dsh/commands/spec-flow.md` symlink、dsh 重启后生效
- **依赖**：openspec CLI（容器已装 1.14.1）、user-commands 插件（web profile 已装）、Agent Teams（web profile 已装，仅供可选 team 引擎）、`subagent-model-selection`（本变更开启）
- **风险**：team 引擎依赖实验性 Agent Teams（默认关闭，仅显式选用）；模型白名单与映射文件需保持一致
