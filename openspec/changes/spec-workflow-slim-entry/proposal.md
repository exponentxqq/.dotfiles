# Proposal

## Why

`spec-workflow` 的 SKILL.md 在第一步外移后仍为 15971 码点，而本部署 `dsh-compaction-tool-result-pruner` 的阈值是 8192 码点（超限 tool result 裁为头 4096 + 尾 1024）：会话 token 压力越阈时，`skill` 工具加载的入口正文仍会被裁剪，中段（§五～§十）在裁剪态下不可见。第一步已确立「按消费时机按需读取」的结构与验证方法，但入口总量仍超阈值约 7800 码点，裁剪未消除——比例回升只是分母效应（机制核查见第一步归档记录 `openspec/changes/archive/2026-10-14-spec-workflow-externalize-references/execution-log.md`），把入口压入阈值内是彻底消除该路径的唯一手段。

## What Changes

- **去重**（纯收益，零语义损失）：三处重复的 `DELEGATED_CALLER` 解释（§四 平台事实 / §八 引擎段 / §十二 红线表）合并为单一权威表述 + 指针；§二 处置细节复述收紧；§一 参数面表与 §三 模式收集表合并；§十一 摘要内联的三档回退展开收缩为指针（展开细节唯一权威源 = `routing.md`）。
- **消费时机外移**（第一步未动的节，在硬线约束下重估）：
  - §五 第 4 步的 `grill-me` 设计树/前沿方法展开 → 新增 `convergence.md`（阶段 1.5 读），入口留六步骨架与接线要点；
  - §八 team 引擎细节、subagent 提示模板与回执格式 → 新增 `execution.md`（首次派发前读），入口留批次循环骨架与两引擎共同纪律；
  - §六 `tasks.md` 批次契约的展开 → `planning.md`（落档时读），入口留契约要点；
  - §二 store 接入异常分支 → `failure-modes.md`（遇到时读），入口留一行指针。
- **协议骨架化**：§四 中转协议留 ①–⑤ 步名 + 两条禁令 + 平台事实一句话（展开移 `planning.md`）；§七 恢复协议六步语义不动、仅句式收紧。
- **句式收紧**：全文防御性从句压缩 10–15%，不删约束、不改触发条件。
- 入口码点目标区间 **[6800, 7830]**：渲染后 tool result ≤8192（含包裹开销，常量执行期实测），使 `skill` 按名加载不再触发宿主裁剪。
- 新增 references 单文件约束：每个 references 文件 SHALL ≤8192 码点（单次读取/加载不触发裁剪），写入生成规则。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `spec-workflow`: 新增行为 Requirement「入口与资源按单次加载完整交付」——把「入口完整可用」从结构性事实变为可验收的行为合同：入口与每个资源文件在单次加载/读取内完整交付，不因宿主工具结果裁剪而丢失内容。

## Impact

- `agent/skills/spec-workflow/SKILL.md`：改写为骨架 + 红线最小集；12 节编号与标题逐字节不变，frontmatter 逐字节不变。
- `agent/skills/spec-workflow/`：新增 `execution.md`、`convergence.md`；`routing.md` / `failure-modes.md` / `planning.md` 增补外移内容（各自 ≤8192 码点）。
- `dsh/README.md`：路径表补 2 个新 references 条目。
- `openspec/specs/spec-workflow/spec.md`：归档时经本变更 delta 同步新增 Requirement。
- **不改**：`dsh/commands/spec-flow.md` 薄壳、`dsh/spec-workflow.yaml` 键与取值、主规格既有 Requirement 语义、其他 skill、dsh 平台实现。
- 部署：bundle 内新增文件无需 skctl 重登记（local 源为目录级 symlink 实时视图）；无宿主操作要求（`git push` 归档后由用户自行执行）。
