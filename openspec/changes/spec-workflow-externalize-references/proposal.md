# Proposal

## Why

`spec-workflow` 的 SKILL.md 是单文件 21464 Unicode 码点（仓库 9 个 skill 中最大，第二名 18471），而本部署 web profile 的模型会话组合实际挂载 `dsh-compaction-tool-result-pruner`（阈值 8192 码点，压缩后裁为头 4096 + 尾 1024）：`/compact` 后 skill 正文仅存活约 23.9%，丢失区间恰为恢复协议、执行引擎与失败处置——这些正是压缩后恢复最需要的指令内容，与主规格「压缩后无损恢复」的既有语义正面冲突。官方出货 skill 全部以 ≤8144 码点入口 + references 多文件形态刻意规避该阈值（cordis-plugin-development 先例）。

## What Changes

- 将 SKILL.md 中**按消费时机可外移**的自包含内容外移为 bundle 内 references 文件（**纯剪切搬运，不改语义**）：
  - 模型路由全文（现 §十一，含路由自检脚本与白名单对照表）→ 派发子代理时读取；
  - 边界与失败处置表（现 §十二，红线级条目除外）→ 异常处置时读取；
  - 双线规划与差异收敛的完整展开（现 §四/§五主体）→ 阶段 1 / 1.5 派发时读取。
- 入口骨架保留：总览、前置检查、模式收集、全局红线（固定承诺、独立性铁律、中转协议要点、绝不做清单）、**恢复协议**（压缩丢失区内容，必须内联）、Read-next 路由表。
- **红线级失败条目内联**：违反后立即导致不可逆/失控/静默假设的处置条目留入口；可被核对环节拦住的外移。
- 横切内容（中转协议、模型路由）**单一权威源** + 引用侧仅留摘要与指针，防双源漂移。
- 同步外部引用：`dsh/README.md` 127 行路径表与 193 行硬编码「SKILL.md 第十一节」提法。
- 主规格新增「压缩后指令完整存活」行为 Requirement（行为语言，不写字节数字）。
- 本变更为两步节奏的**第一步（外移 + 行为验证）**：用本变更自身的执行自举实测「模型是否真按路由表读 references」；第二步（去重改写、入口压至 ≤8192 码点硬线）**另立变更**，不属于本变更范围。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `spec-workflow`: 新增「压缩后指令完整存活」Requirement——把「压缩后无损恢复」从隐含语义变为可验收的行为合同；既有 13 个 Requirement 约束的行为语义零变化（纯结构搬运），不产生其他 delta。

## Impact

- `agent/skills/spec-workflow/SKILL.md`：重写为入口骨架（frontmatter `name`/`description` 逐字节不变）；`agent/skills/spec-workflow/` 下新增 references 文件。
- `dsh/README.md`：spec-workflow 节（121–210 行附近）的外部引用与文件清单同步。
- `openspec/specs/spec-workflow/spec.md`：归档时经本变更 delta 同步新增 Requirement。
- **不改**：`dsh/commands/spec-flow.md` 薄壳、`dsh/spec-workflow.yaml` 键与取值、`dsh/profiles/web/cordis.patch.yml`、其他 skill、dsh 平台实现。
- 部署：bundle 内新增文件**无需** skctl 重登记（local 源为目录级 symlink 实时视图）；无宿主操作要求（git push 归档后由用户自行执行）。
