# Proposal

## Why

`spec-workflow` 经四轮变更（外移、瘦身、路由、设计线、子目录化）打磨后语义闭环，但通读八个文件与量化核对发现七处可优化点，分两类：

- **无损修缮（零行为变化）**：①`refs/convergence.md` L3–10 与 L26–33 存在**逐字一致**的重复块（各 801 码点，外移叠加的历史残留，`a==b` 实测为真）；②`refs/planning.md` 前置检查展开编号断裂（入口 §二 列 ①–⑤，展开只有 1/4/5）；③三份 refs 头注过期——`planning.md` 只写「§四外移」、`convergence.md` 只写「第 4 步」、`execution.md` 只写「§八两个引擎小节」，均与实际承载范围不符；④`refs/routing.md` 自检脚本硬编码 `opencode/node_modules/yaml` 绝对路径，依赖缺失即崩，与「自检不过按三档回退」的稳健预期不符；⑤`planning.md` 标题层级混排（`###` 与 `## 附：` 交错）与 L32 冗余「入口指引」残段。
- **行为澄清（需小 delta）**：⑥`auto` 模式中途恢复语义缺口——恢复协议「提交对不上 → 回退为未完成」在 `auto` 下会误判（auto 收尾才提交，中途崩溃时已勾选任务天然无提交），正确做法是对现存 diff 跑验证句而非重派子代理；⑦主规格 L185「跳过已完成的**调研**与落档」是旧阶段名残留，实现与其余各处均为「规划」。

可行性已逐项勘明：六文件码点 7816/6279/2864/3092/3900/2238，全部远低于宿主裁剪线（`dsh-compaction-tool-result-pruner` threshold 8192 码点，`codePointLength = Array.from(text).length`）；`SKILL.md` 净增必须 ≤0（渲染上界 7816+343=8159，余量仅 33），故 ⑥ 的入口改动以等量收紧置换。

## What Changes

- **`refs/convergence.md`**：删除 L3–10 重复块（保留六步展开内那份），头注改为「§五外移正文（六步判据全文，含第 4 步 `grill-me` 方法）」；2864 → 约 2062 码点。
- **`refs/planning.md`**：头注补齐实际来源（§二/§四/§六/§十 与阶段 1.7）；为并行/串行小节补父级 H2；删 L32 冗余残段；前置检查展开改标 ①/④/⑤ 并注明 ②③ 正文留在入口（不复制，防双源漂移）。
- **`refs/execution.md`**：头注补齐 §九；在三模式节补「中途恢复（`auto`）以现存 diff 为准」要点。
- **`refs/routing.md`**：自检脚本的 yaml 依赖改为候选探测（cwd → dsh 内置 → dotfiles/opencode），全缺时打印「跳过（不等于通过）」并退出码 0；判定逻辑与正例输出不变。
- **`refs/failure-modes.md`**：「勾选态与证据矛盾」行改为与执行纪律同口径（先跑验证句，通过即保持勾选）。
- **`SKILL.md`**：§七 恢复协议第 3 步补「提交对不上时以现存 diff 为准（`auto` 未提交属预期）」；以删除 §四 冗余指针（59 码点）、收紧 §七 第 1 步注记、去「（唯一源）」等量置换，净增量 ≤0；frontmatter、12 节标题、红线区语义不动。
- **`dsh/README.md`**：文件表 planning/execution 行补齐来源，三模式段补中途恢复口径。
- **主规格**（经 delta 同步）：MODIFIED「落档到执行的衔接与恢复」（补证据优先恢复 + 新 Scenario「auto 中途恢复保留已完成任务」）、MODIFIED「接续未完成变更」（调研 → 规划）。
- 不做：不动第三类结构性议题（入口余量再压缩、`/tmp` 材料持久化、规划线产物码点上限）；不改 `dsh/spec-workflow.yaml`、命令薄壳、宿主 profile；不动归档历史。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `spec-workflow`：恢复协议新增「勾选态与提交历史不一致时以现存改动证据裁定」的 SHALL 与对应 Scenario；接续条款的阶段名由「调研」更正为「规划」。其余 Requirement 行为语义不变。

## Impact

- 代码/文档：`agent/skills/spec-workflow/`（SKILL.md + 5 份 refs）、`dsh/README.md`、`openspec/specs/spec-workflow/spec.md`（归档时由 delta 同步）。
- 不影响：skill 名与描述、加载渲染方式、`/spec-flow` 命令、阶段模型路由与白名单、skctl 聚合层、阶段 1.7 契约、阶段 1/1.5 判据语义。
- 风险：入口净增超预算 → 以等量收紧消化（候选池见 design.md）；`openspec archive` 的文本规整可能改动主规格措辞 → 归档后逐字复核主规格 diff。
