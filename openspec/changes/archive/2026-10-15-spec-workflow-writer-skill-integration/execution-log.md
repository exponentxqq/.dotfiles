# 执行记录：spec-workflow-writer-skill-integration

**变更名**：spec-workflow-writer-skill-integration（阶段 1.7 与阶段 3 强制加载栈对应 writer skill）
**目标**：让 `spec-workflow` 的代码设计线（阶段 1.7）与执行环节（阶段 3，subagent/team 两引擎）派发子代理时**必须加载项目栈对应的 writer skill**（现有 `spring-writer`、`nuxt-writer`），栈识别未命中时**问用户三选一**（指认／豁免并如实标注／终止），并把该契约同步到主规格。
**用户裁定**（本轮确认，两条）：①范围 = **阶段 1.7 + 阶段 3 都加载**（非仅设计线）；②未命中 = **问用户三选一**（不设硬门禁、不静默跳过）。
**执行方式**（用户批准的计划）：轻量 OpenSpec 变更（最终 **ADDED 1 + MODIFIED 3** Requirement、8 个新 Scenario；见 D-6）；主会话串行执行，无子代理派发；不自举 `spec-workflow` 六阶段（方案枚举已在计划阶段完成）。
**提交链**：
1. `657d324` 落档（`.openspec.yaml` + proposal.md + design.md + tasks.md + specs delta）
2. 实现（4 个 skill 文件 + `dsh/README.md` + tasks.md 勾选）
3. 本文件与变更目录的归档提交
**工作区纪律**：三次提交均显式 `git add` 指定路径，`dsh/profiles/web/cordis.patch.yml`（宿主侧脏改动，非本变更）始终排除。

## 1. 触达面与改动实绩

| 文件 | 改前 | 改后 | 说明 |
| --- | --- | --- | --- |
| `agent/skills/spec-workflow/SKILL.md` | 7796 | **7842** | §五 1.7 段加「**须先加载栈对应 writer skill**」；§八 指针句内嵌「提示模板（含 writer skill 加载指令）」——净 +46 ≤53 |
| `refs/planning.md` | 6375 | **7133** | 1.7 节新增「栈识别与 writer skill 接线」（判据/双命中/未命中三选一/可加载性核对/沿用结论）＋模板加「先加载 skill」行＋回执核对第 ⑥ 条＋L0 断言标注＋落档 tasks 契约加粒度句 |
| `refs/execution.md` | 3235 | **3390** | subagent「提示自包含」清单与 team 任务卡内容各加 writer skill 加载指令（点名、沿用 1.7 结论）；§九 未动 |
| `refs/failure-modes.md` | 2304 | **2590** | 新增两行：「栈识别未命中」→ 问用户三选一；「writer skill 加载失败」→ 处置顺序后仍失败报告问用户（不静默降级） |
| `dsh/README.md` | 15228 | **15746** | 文件表 planning/execution 行、1.7 段（含 `spring-writer`/`nuxt-writer`/三选一）、三档分降段、执行双引擎段、`design` 路由表行各补 writer 接线（共 8 处 `writer skill`） |
| **六 skill 文件合计** | 25903 | **27148** | 净 +1245（全部落在 refs 与入口预算内） |

改后六文件码点：7842 / 7133 / 3390 / 2590 / 2080 / 4113 —— 全部 ≤8192；`SKILL.md` 7842 ≤**7849**（渲染硬顶），入口余量由 53 用到 7。
未触及：`SKILL.md` frontmatter（逐字节一致）、12 个 `## ` 节标题、红线表、恢复协议、中转协议、「绝不做」段；`refs/convergence.md`、`refs/routing.md`；`dsh/spec-workflow.yaml`、命令薄壳、宿主 profile 白名单、writer skill 本体。

## 2. 验证证据

| 门 | 内容 | 结果 |
| --- | --- | --- |
| G1 结构 | `SKILL.md` `## ` 标题 **12**（与 HEAD 版本标题列表逐项相等）；frontmatter 逐字节一致（`git diff \| grep '^[-+]name:\|^[-+]description:'` 为空）；**26 个 href** 经仓库路径与聚合层（`/home/docker/.agents/skills/spec-workflow/`）双路 `test -f` 全部命中、零坏链 | **PASS** |
| G2 码点 | 六文件 7842/7133/3390/2590/2080/4113 全部 ≤8192；`SKILL.md` 7842 ≤7849（本变更采用渲染硬顶：file+343 ≤8192） | **PASS** |
| G3 接线 | `planning.md`：「栈识别与 writer skill 接线」唯一、模板含「先加载 skill」与两个 skill 名、「三选一」「不静默跳过」「未触 writer 约束」「拆分规定」齐备、回执第 ⑥ 条唯一；`execution.md`：两引擎各含「writer skill 加载指令」且注明「沿用阶段 1.7 栈识别结论」；`failure-modes.md`：两行新处置齐备；`SKILL.md`：两处标记齐备 | **PASS** |
| G4 运行时 | 会话内按名加载 `spec-workflow` 成功并返回**改后版本**——§五 可见「**须先加载栈对应 writer skill**」、§八 可见「提示模板（含 writer skill 加载指令）」；base directory = `/home/docker/.agents/skills/spec-workflow`；`refs/` 五文件可见；聚合层 `spring-writer/SKILL.md`、`nuxt-writer/SKILL.md` 均 `test -f` 通过 | **PASS** |
| G5 规格 | `openspec validate spec-workflow-writer-skill-integration --strict` → valid 且**无告警**，退出码 0；归档后 `openspec validate --all` → 1 passed / 0 failed（**无 >500 字符告警**）、`--archived` → 8 passed / 0 failed，均 exit 0；主规格 17 Requirement / **54** Scenario（+1 / +8），最长需求文本 374 字符，diff 39 insertions / 3 deletions 全部对应本变更（无规整误改） | **PASS** |
| G6 回归 | `tools/skctl`：`pnpm test`（经 docker pnpm 包装）→ **tests 47 / pass 47 / fail 0**，退出码 0 | **PASS** |
| G7 提交 | 落档提交只含变更目录 5 文件（含补入的 `.openspec.yaml`，以 `--amend` 归位）；`dsh/profiles/web/cordis.patch.yml` 未混入任何提交 | **PASS** |

## 3. 偏差与裁定

- **D-1（tasks.md 1.1 验证句缺陷，已修正并留痕）**：原验证句 `assert s.count('⑥')==1` 与文件中**既有 3 处** ⑥（六字段清单、L1 档、design 继承）冲突，必然失败；改为唯一串判定 `count('⑥**writer 加载回执**')==1`。属验证句措辞缺陷，非交付缺陷；tasks.md 该条已注明。
- **D-2（入口预算裁定：§五 指针扩写让位给强制标记）**：原计划含「§五 指针扩写（+16）+ 标记（+25）+ §八 标记（+20）」= 61 > 53 码点预算。处置：**放弃指针扩写**（同句已有 planning.md 指针，细节不丢），只保「须先加载栈对应 writer skill」强制标记 + §八 指针句内嵌「（含 writer skill 加载指令）」，实测净 +46，file 7842 ≤7849。按 design.md D6 预案执行，未牺牲 §五 标记；tasks.md 2.1 已同步改写并注明。
- **D-3（failure-modes 门限两轮收紧）**：首版两行合计使文件达 2607 > 自定门限 2600。处置：①「按『所需 `openspec-*` skill 加载失败』同款顺序修复」→「按 `openspec-*` 加载失败同款顺序修复」；②「本条为『必须』级」→「『必须』级」；③统一用「不静默降级」（与 spec delta 措辞同形）。最终 2590 ≤2600，语义无损失。
- **D-4（`.openspec.yaml` 归属）**：新变更目录初始漏建该元数据文件（落档提交后补建），以 `git commit --amend --no-edit` 归入落档提交（未推送、无并发写者，安全），使提交链与历次变更同构。
- **D-5（双源防控落实）**：spec-workflow 侧只写 skill 名与「规范为硬约束」定性，**不复述** writer 的拆分粒度等数值（spring ≤10 / nuxt ≤8 文件均未出现）；「新增 writer skill 需人工同步判据表」作为已知维护点记入 design.md D3。
- **D-6（规格需求结构重构：横切契约独立成 ADDED Requirement）**：首版 delta 把栈识别/加载/未命中/trivial/粒度全部并入「阶段 1.7 代码设计线」，需求正文 271 → **649 字符**，触发 `openspec validate` 的 `>500 characters` 告警（`--strict` 下即失败，退出码 1）。处置：**回退归档**（`git checkout` 主规格 + 归档目录移回活跃目录）→ 重构 delta 为 **ADDED「栈识别与 writer skill 加载（阶段 1.7 与阶段 3）」**（承载全部横切 SHALL + 6 Scenario）＋ **MODIFIED** 三条（1.7 设计线只留一句指认 374 字符；两执行引擎各加一句落点 + 1 Scenario；「落档工件与执行批次契约」不再重复粒度句，单一来源在新需求）→ 重新 strict 校验 exit 0 且无告警 → 重新归档。属交付结构修正（比原计划更好的 Requirement 划分），非语义变更；proposal/design/tasks 已同步。
- **D-7（归档—回退—重归档的提交归属）**：归档目录与 delta 的最终内容随**归档提交**入库（delta 文件本体在落档提交中，重构后的版本由归档提交承载）；未推送、无并发写者，提交链仍为「落档 → 实现 → 归档」三段。
- **自举观察**：本变更仍按轻量过程执行、**无子代理派发**，故「派发前读 refs/planning.md 并注入 writer 加载行」这一新契约在本轮**无执行数据点**；如实记录，不冒充流程执行。

## 4. 宿主操作清单

1. **无需任何宿主操作**：skill 为目录级 symlink（`~/.agents/skills/spec-workflow → agent/skills/spec-workflow`），refs 与入口改动即时生效——无需重登记、无需 `/commands-reload`、无需重启 dsh。
2. `dsh/spec-workflow.yaml`、命令薄壳、宿主 profile 白名单、`spring-writer`/`nuxt-writer` 本体均未改动。
3. 待办：`git push`（本流程不代劳）；`dsh/profiles/web/cordis.patch.yml` 的宿主侧脏改动仍待自行决定提交或还原。
