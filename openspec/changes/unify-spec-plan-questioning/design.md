# Design

## Context

spec-plan 的追问散布 9 类落点（L1–L9：参数询问、OpenSpec 根三选一、模式收集、中转代问、1.5 收敛决策、栈识别三选一、1.75 演示确认、落档分歧点、纠错/异常通道），承载与问法无统一约定——全仓仅 `refs/convergence.md:32` 泛泛提「用提问工具（单选/多选 + 推荐项）」未点名工具；问题常缺背景与选项区别。见 proposal.md - Why。

硬约束：① SKILL.md 入口 122 行 / 7687 码点，既有 Requirement「入口与资源按单次加载完整交付」要求渲染 ≤8192（file − frontmatter + 343 包裹口径）；② `writing-skills`（用户 2026-11-12 指认）为设计硬约束——frontmatter 不动、纪律型失败用「一律/不得」措辞、Iron Law 要求失败基线；③ `openspec/config.yaml`：工件简体中文、结构标题与 SHALL/MUST 保留英文；④ openspec 1.16.0：ADDED 正文 >500 码点在 `--strict` 下 invalid，`validate --all --strict` 因主规格既有 2 条超长会红（只能单变更校验）。

**栈识别结论**：`writing-skills`（用户 2026-11-12 指认；证据 = 阶段 1.7 设计子代理加载回执 + decisions.md 收敛留痕）。dotfiles 无 pom.xml/build.gradle/nuxt.config，Spring/Nuxt 均未命中。

**阶段 1.75 界面演示**：未触发——C1 不成立（触达面全部为 skill markdown 与 OpenSpec 工件，无页面/组件/布局/视觉改版，命中排除表「纯后端 / CLI / 配置 / 脚本」同族）；判定见 code-design.md 末尾附录。

## Goals / Non-Goals

**Goals:**

- 三条要求落为 spec-plan 单点权威契约（§十）+ 各落点一句接线 + grill-me 双轨承载段，零双源复述。
- 既有行为语义零改变：0 MODIFIED、纯追加（deletions=0 断言）、1.75 三选项字面不动。

**Non-Goals:**

- 不改 grill-me 方法论（设计树/前沿/≤5 问/推荐措辞）、不改两个 skill 的 frontmatter/description、不重编号 §一–§九。
- 不动 `dsh/spec-workflow.yaml`、命令薄壳、README、`openspec/specs/` 主规格（只由归档经 delta 同步）、不动 add-ui-demo-gate 变更。

## Decisions

> 完整决策（D1–D13，每条含被否方案与反例）见落档副本 `code-design.md` ④；此处逐断言承载。

1. **契约节 = `## 十、追问契约`，追加在 SKILL.md:122 后**（258 码点 / 4 条 bullet：工具强制含范围 / 背景与解释 / 选项区别与举例 / 子代理例外 + grill-me 接线）。被否：插 §一 后无编号（破坏体例）、插作 §二 顺延重编号（十余处「第 X 节」引用失真、违反「节标题不变」Scenario）、并入 §三（语义不正交）。
2. **工具名 = 抽象「宿主结构化提问工具」+ 实名注记 `ask_user_question` 一次**；接线句只指向 §十（convergence 末行按收敛结论点名工具）。被否：照原文 `ask_question`（本部署无此工具名，grep 零命中，执行侧调不到）、只写实名（宿主改名全仓失真）。
3. **接线粒度 = planning/failure-modes 文件头一句覆盖多落点；routing/serial/parallel 就地插句；convergence 末行整句改写；planning 的 1.75 另注「三选项语义不变，只换承载」**。共 7 句、6 文件。被否：逐落点插括号（10 处重复噪音）、六文件全走文件头（短句就地更直接）、完全不加点（refs 按需单独读取，必须在消费点可见）。
4. **grill-me = 英文 `## Carrier by host` 三段（917 码点），插在 :24 格式块后；既有 32 行逐字不动（纯插入）**。被否：全量工具化（无工具宿主独立场景失效）、只在 spec-plan 写承载（独立使用路径等于没做）、拆 refs 文件（读取跳转反成本）。
5. **spec delta = spec-plan 只 ADDED 1 条「追问交互契约」+ 7 Scenario（298 码点）；grill-me 新建 capability（Purpose 120 码点 + 2 条 ADDED 267/147 码点 + 7 Scenario）；全部 ≤500**。
6. **0 MODIFIED = 12 条逐条核对的事实结论**（核对表见 code-design.md ⑤5.0）：既有 12 条无一写死主会话提问的工具/问法——规划入口只管时机、双线收敛⑤只委托方法论、中转条目与契约同向、栈识别未写承载；「1.75 三选一问法」**不在主规格**（在未归档变更 add-ui-demo-gate 的 delta，`specs/spec-plan/spec.md:5`，其 Scenario 未固定承载），MODIFIED 一条不存在的 requirement 会直接 validate 报错。1.75 语义保留改由 planning.md 就地注记 + 三选项字面 grep 断言保证。
7. **长度预算 = 契约 258 码点、不新建 refs 文件、不删改既有入口文字；SKILL.md 7945 / 渲染 8049 ≤ 8192，余量 143**（path 56 字符时 129）。被否：外移 refs/questioning.md（三条要求仅 258 码点，外移收益为负）、压缩到 150 码点以内（必丢「范围/子代理/grill-me」之一，留洞）。
8. **RED 基线组（组 1）= writing-skills Iron Law 的落地**：写前派 fresh 子代理喂 `git show HEAD:` 旧文本 + 场景，记录「是否点名工具/是否含背景」两栏；未复现则如实标注不伪造，design 留痕。GREEN 配对复测在组 6。
9. **工件语言 = 全部简体中文（含 grill-me 的 delta）；grill-me 的 skill 正文仍英文**——工件语言与 skill 正文语言是两回事（config context 约束工件）。

## 触达面清单（16 项）

| # | 路径（仓 = dotfiles 根仓） | 动作 | 关键改动点 |
| --- | --- | --- | --- |
| 1 | agent/skills/spec-plan/SKILL.md | 修改 | :122 后追加 §十（258 码点；不重编号、不改 §一–§九） |
| 2 | agent/skills/spec-plan/refs/convergence.md | 修改 | :32 末行整句改写（点名工具 + 指向 §十 + 保留单选/多选/推荐项） |
| 3 | agent/skills/spec-plan/refs/planning.md | 修改 | :1 后 header 句；:60 的 1.75 注记（三选项字面不动） |
| 4 | agent/skills/spec-plan/refs/failure-modes.md | 修改 | :1 后 header 句（覆盖表内 4 行「问用户/由用户决定」） |
| 5 | agent/skills/spec-plan/refs/routing.md | 修改 | :65 参数纠错改「按契约发起更正问询」 |
| 6 | agent/skills/spec-plan/mode/serial.md | 修改 | :11 问答节奏条追加「两类提问均按契约发起」 |
| 7 | agent/skills/spec-plan/mode/parallel.md | 修改 | :53 回执核对括号内插句 |
| 8 | agent/skills/grill-me/SKILL.md | 修改 | :24 后插 `## Carrier by host`（917 码点；:12-24 格式块与 :26-32 逐字不动） |
| 9 | openspec/changes/unify-spec-plan-questioning/specs/spec-plan/spec.md | 新建 | 只 ADDED「追问交互契约」+ 7 Scenario（无 MODIFIED 节） |
| 10 | openspec/changes/unify-spec-plan-questioning/specs/grill-me/spec.md | 新建 | 新 capability：Purpose + 2 ADDED + 7 Scenario |
| 11–16 | 同目录 proposal.md / design.md / tasks.md / code-design.md（复制） / decisions.md（复制） / .openspec.yaml | 新建/复制 | 四件套 + 两材料落档副本（自此为权威） |

成品措辞（契约节全文、7 句接线、grill-me 英文三段、两条 delta 骨架）逐字见 code-design.md ③——落档副本为执行权威。

## Risks / Trade-offs

- [入口余量仅 143 码点] → 契约节不再扩写；后续细节一律进 refs 或 grill-me；组 2/6 渲染公式 + 「加载无裁剪标记」为硬门。
- [工具名 5 处出现，DSH 改名需同步] → 抽象措辞为主、实名只作锚；`grep -rn 'ask_user_question'` 是改名唯一清单。
- [RED 可能未复现（模型已自发用工具）] → 如实记录不伪造失败，按用户显式需求继续并留痕。
- [add-ui-demo-gate 若中途归档，主规格新增 1.75] → 本变更 0 MODIFIED 不受影响；组 6 重跑单变更 validate 即可。
- [failure-modes 表头句覆盖 4 行，只读表体可能漏] → 表头句在表格前第一行 + 文件级 grep 断言；必要时逐行补括号（约 10 行，不影响长度预算）。
- [validate 只能单变更跑] → 验证句必须写变更名；禁用 `--all --strict`（主规格既有 2 条超长会红）。

## Migration Plan

组间串行（组内并行，单组 ≤ `parallelism: 8`）：组 1 RED 基线 → 组 2 入口契约节 → 组 3 六文件接线 → 组 4 grill-me 承载段 → 组 5 delta 核对 → 组 6 工件校验 + GREEN 复测。聚合层 symlink 实时视图，改源文件即生效，无需 skctl/重启。回滚 = revert 对应提交（纯追加，无状态迁移）。

## Open Questions

- 待决 Q1（RED 基线组去留）与 Q2（1.75 不在主规格、接受 0 MODIFIED）已按「不阻塞、按推荐进 tasks」处置——两项答复只改对应组，不重开收敛；用户在执行前可改（见 code-design.md 待决问题节）。
