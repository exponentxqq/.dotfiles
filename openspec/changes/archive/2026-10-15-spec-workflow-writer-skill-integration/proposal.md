# Proposal

## Why

`spec-workflow` 的代码设计环节（阶段 1.7）与执行环节（阶段 3）产出的设计蓝图与实现代码，此前只受 `code-design.md` 深度契约与项目 AGENTS.md 约束，**未接入栈级开发规范**。仓库已有两个 writer skill——`spring-writer`（Spring/Java 开发规范，14644 码点）与 `nuxt-writer`（Vue/Nuxt 前端规范，自述「规划、编写、修改、审查任一环节开始前都必须先加载」）——但 spec-workflow 的派发提示从不点名加载它们，规范约束无法稳定传导到设计与实现子代理（fresh 子代理无本次对话上下文，只能靠提示点名）。

用户裁定（本轮确认）：**阶段 1.7 与阶段 3 都必须加载栈对应 writer skill**；**栈识别未命中时问用户三选一**（指认现有 skill／明确豁免并如实标注／终止），不静默跳过。

可行性：聚合层 `~/.agents/skills/` 已实测含 `spring-writer`、`nuxt-writer`，子代理可按名加载；六 skill 文件码点 7796/6375/3235/2304/2080/4113，入口 `SKILL.md` 渲染硬顶 = 8192−343 = **7849**，余量 53，两处最短标记可容纳（超出则 §八 完全外移）。

## What Changes

- **`refs/planning.md`**：「附：代码设计环节（阶段 1.7）」新增小节「栈识别与 writer skill 接线」——只读识别判据（Spring：`pom.xml`/`build.gradle(.kts)` 含 `spring-boot`；Nuxt：`nuxt.config.*` 或 package.json 依赖含 `nuxt`；monorepo 子包一并探测；双命中全加载）、未命中三选一、可加载性核对（聚合层存在性，失败走 failure-modes 处置顺序后报告问用户）、结论记阶段摘要；设计提示模板加「先加载 skill：<点名>」行；回执核对清单加第 ⑥ 条「回执注明已加载的 writer skill 名（或豁免依据）」；三档分降补 L0 标注规则；落档细节 tasks 契约加「任务粒度同时满足所加载 writer skill 的拆分规定」（引名不复述数值，防双源）。
- **`refs/execution.md`**：subagent 引擎「提示自包含」清单与 team 引擎任务卡内容各加栈对应 writer skill 加载指令（点名、沿用 1.7 识别结论）；§九 验证环节不加（只读不写码）。
- **`SKILL.md`**：§五 阶段 1.7 指针句加「（恒先加载栈对应 writer skill）」并扩指针为「模板、writer skill 接线、深度契约与三档分降」；§八 共同纪律加最短标记；两处合计 ≤53 码点、file+343 ≤8192，frontmatter 与 12 节标题不动。
- **`refs/failure-modes.md`**：处置表加两行——「栈识别未命中」问用户三选一；「writer skill 加载失败」按既有处置顺序修复后仍失败则报告问用户（不允许静默降级）。
- **`dsh/README.md`**：文件表 planning/execution 行、阶段 1.7 段、design 路由表行、阶段 3 引擎段各补一句 writer 接线。
- **主规格**（经 delta 同步，不手改）：**ADDED**「栈识别与 writer skill 加载（阶段 1.7 与阶段 3）」——横切契约（栈识别判据、双侧加载、未命中三选一、加载失败处置、trivial 标注、落档粒度）+ 6 个 Scenario；**MODIFIED**「阶段 1.7 代码设计线」（补栈识别与加载要求）、「subagent 执行引擎」（提示含加载指令 + 1 Scenario）、「team 执行引擎」（任务卡含同款指令 + 1 Scenario）。横切契约独立成 Requirement 而非并入 1.7 需求——后者并入后文本达 649 字符，会触发 `openspec validate` 的 >500 字符告警。
- 不做：不改 `dsh/spec-workflow.yaml`（路由键不变）、不改 `/spec-flow` 薄壳、不动 profile 白名单、不动 writer skill 本体、不自动安装缺失 skill、不做栈识别的通用插件机制（判据表按当前两类写死，新增 writer skill 时人工同步，作为已知维护点记入 design.md）。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `spec-workflow`：**新增**横切 Requirement「栈识别与 writer skill 加载（阶段 1.7 与阶段 3）」——栈识别 + 双侧加载 + 未命中问用户三选一 + 加载失败处置 + trivial 标注 + 落档粒度；阶段 1.7 需求补栈识别与加载要求；两执行引擎需求增补「派发提示/任务卡含 writer skill 加载指令」。其余 Requirement 行为语义不变。

## Impact

- 代码/文档：`agent/skills/spec-workflow/`（SKILL.md + 3 份 refs：planning/execution/failure-modes）、`dsh/README.md`、`openspec/specs/spec-workflow/spec.md`（归档时由 delta 同步）。convergence.md、routing.md 不动。
- 不影响：skill 名与描述、加载渲染方式、`/spec-flow` 命令、阶段模型路由与白名单、阶段 1/1.5 判据语义、三档分降判据本身、L1/L2 深度契约字段、恢复协议。
- 风险：入口余量 53 码点被两处标记超支 → §八 完全外移只保 §五 标记；`openspec archive` 文本规整误改其他 Requirement → 归档后逐字复核主规格 diff；子代理会话缺 `skill` 工具 → 按中转协议上浮，主会话按 failure-modes 处置（本风险有兜底路径，不阻塞设计）。
