# Proposal

## Why

`spec-workflow` 六阶段流水线经六轮打磨后，规划半程（阶段 1→1.5→1.7→2）与执行半程（阶段 3→4）的实际使用形态已分化，component:ai 项目（9 组 13 任务、5124+ 序消息、两次 compact 后仍在续跑）的完整执行暴露了四类结构性问题：

1. **入口预算贴顶**：`SKILL.md` 7842 码点，距渲染硬顶 7849 仅余 7——任何增改都必须以等量删改置换，规划与执行指令互相挤占。
2. **执行期死重**：超长执行会话 compact 后，入口里约 4700 码点的规划方法论（双线模板、收敛判据、设计契约）在执行期完全不被引用，却挤占执行红线（恢复协议、三方对齐）的压缩存活空间；`line-a/line-b` 等规划材料执行期零引用，易失设计成立。
3. **跨期事实无落点**：阶段 1.7 栈识别结论（writer skill 名）只记「会话内阶段摘要」，而执行期每个派发提示都点名加载同一 writer skill、接续恢复后无从取得只能重识别——拆分前无处安放，拆分后自然归位（随落档工件持久化）。
4. **执行纪律与实测行为漂移**：component:ai 实际演化出、但无 spec 承载的纪律——审核点与提交点分离（用户强制「完成后先不提交，由我审核确认后再提交」）、引擎 mid-flight 切换（team 8 成员上限、`send_message` 寻址不到 subagent，改 subagent 并留痕）、并发构建静默跳过防线（验证任务 SKIPPED 而 BUILD SUCCESSFUL，须两步法确认）、嵌套子仓双仓提交（root 工件仓 + service 代码仓分别提交）、真实密钥只经参数不落文件、执行期留痕体系（R<n> 编号规则、`code-design.md` 组段终形态化、`/tmp` 证据目录）。

同时规划半程无独立入口：只要规划不要执行的场景（规划完执行拖后、换会话执行）只能走全流程再中断。

## What Changes

- **新建 skill `spec-plan`**（`agent/skills/spec-plan/`：SKILL.md + refs planning/convergence/routing/failure-modes）：承接阶段 1 独立双线规划 → 1.5 差异收敛 → 1.7 代码设计 → 2 落档，**到落档提交为止**；收尾固定告知 `/spec-flow continue <变更名>` 接续执行。落档契约两处增强：①`tasks.md` 分组语义明确「组 = 执行审核批次，组内单任务是合法常态，分组兼顾用户审核节奏」；②栈识别结论（writer skill 名与证据）写入落档 `design.md` 决策记录，供执行侧与接续恢复读取。
- **新增用户命令 `/spec-plan`** 薄壳（`dsh/commands/spec-plan.md` + 容器 symlink）。
- **`spec-workflow` 改写为全流程编排者**：三个规划节合并为「加载 `spec-plan` skill 委托执行（转发 `--parallel` 与规划键 `--model`，已预置不重问）」一节；衔接节吸收原落档第 7 步（落档完成后确认执行模式与引擎）；frontmatter 逐字节不变；refs 删 `planning.md`/`convergence.md`，`routing.md`/`failure-modes.md` 裁至执行键，`execution.md` 吸收纪律级实证。
- **spec-workflow 执行侧吸收 component:ai 实证纪律**（不改执行节律的文本纪律）：审核-提交分离（step 模式停留 = 呈现证据等用户确认，确认后才提交）、引擎批次间可切换（team↔subagent，切换留痕）、干净窗口验收两步法（无并发构建进程 + 无 SKIPPED 且任务真实 executed）、嵌套子仓分仓提交、真实凭据只经参数、执行期留痕与工件维护（组段终形态化、R<n> 编号、证据目录易失）。
- **共用 `dsh/spec-workflow.yaml` 键值零改动**（注释补键归属分工）；`/spec-flow` 薄壳正文不动。
- **不做（本期）**：独立对抗性复核分档（L0 Lead 自核 / L1 独立只读复核 / L2 复核+假绿检验）、Lead 裁定协议（子代理报告须独立复核确认）、delta 复核——component:ai 流程级实证显著改变每组执行节律与成本，立为紧后独立变更（蓝图记本变更 design.md D7），需单独设计分档判据。

## Capabilities

### New Capabilities

- `spec-plan`：spec 驱动工作流的规划半程能力——规划入口（skill + `/spec-plan`）、独立双线规划、差异收敛与分歧复算、代码设计线（含栈识别结论落盘）、交互中转·规划期、落档工件与批次契约（组=审核批次）、规划键模型路由、读图覆盖与回退·规划侧、压缩后指令完整存活、入口与资源单次加载完整交付、栈识别与 writer skill 加载·设计侧。

### Modified Capabilities

- `spec-workflow`：**REMOVED**×6（阶段 1 双线规划、差异收敛与分歧复算、阶段 1.7 代码设计线、落档工件与执行批次契约——随规划半程迁往 `spec-plan`；交互中转、栈识别与 writer skill 加载——按口径重构更名）；**MODIFIED**×6（固定入口——规划委托 spec-plan；衔接与恢复——吸收问执行模式；阶段级模型路由——键枚举改执行键+规划键转发；执行模式与提交节奏——审核-提交分离+引擎可切换；压缩后指令完整存活与单次加载完整交付——委托指针与节结构口径）；**ADDED**×6（干净窗口验收、嵌套子仓提交、真实凭据纪律、执行期留痕与工件维护、子代理与用户的交互中转（执行期）、栈识别与 writer skill 接线（执行侧））。其余 Requirement（subagent/team 引擎、接续、验证门与归档、读图覆盖与路由回退）行为语义不变。

## Impact

- 代码/文档：`agent/skills/spec-plan/`（新建 5 文件）、`agent/skills/spec-workflow/`（SKILL.md 改写 + execution.md 扩充 + routing/failure-modes 裁剪 + 删 2 文件）、`dsh/commands/spec-plan.md`（新建）、`agent/skills/README.md`、`dsh/README.md`、`dsh/spec-workflow.yaml`（仅注释）、`openspec/specs/spec-plan/spec.md` 与 `openspec/specs/spec-workflow/spec.md`（归档时经 delta 同步，不手改）。
- 宿主操作：容器内 `ln -sfn` 建 `~/.dsh/commands/spec-plan.md` symlink；skctl 登记 `spec-plan`（聚合层在 dsh 容器内不可见，经 node 容器或宿主执行）。
- 不影响：`/spec-flow` 全流程体验与参数面、阶段模型路由键值与白名单、执行双引擎与三模式语义（除审核-提交分离口径与引擎切换授权两处实证修正）、恢复协议、openspec-* skills、web profile。
- 风险：spec-plan 入口码点超预算 → 规划细节全部下放 refs（入口只保骨架+铁律+红线+指针）；归档规整误伤主规格 → 归档后逐 Requirement 复核（先例纪律）；中转协议与路由回退纪律在两 skill 各持适配文本 → design.md 记已知双源维护点。
