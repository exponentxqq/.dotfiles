# Design

## Context

T3.1 skill 域变更（opc 仓，2026-10-16 14:57:30 落档、20:08 归档）是 spec-plan 拆分后两 skill 的首个完整实战：step-group 模式、subagent 引擎、四仓分立提交（根/service/portal/apigen）、R1~R11 执行期裁定链（含 R10→R11 推翻）、openspec-verify-change 手动插入归档前校验并拦住勾选遗漏。

**素材时效边界**：T3.1 落档早于 parallel-team-engine 纪律生效（15:10:27）13 分钟——规划半程跑在旧版 spec-plan 上，两材料落档契约从未落地（`code-design.md`/`diff-matrix.md` 在 opc 仓 git 零足迹、/tmp 原件 mtime 停在规划期、执行期组段终形态化落空、continue 恢复无人发现）。本设计基于此证据链补机械校验与恢复防线，不依赖「违背实例」——缺口属契约自身。

码点基线（python len 实测）：spec-plan/SKILL.md 7125｜planning.md 5862｜spec-plan routing.md 4374｜spec-workflow/SKILL.md 6431｜execution.md 4768｜spec-workflow routing.md 3913。修订后均须 ≤7849。

**栈识别结论（决策记录硬项）**：writer skill **豁免**（用户裁定，仅本次有效）——栈识别探测 dotfiles 全仓无 `pom.xml`/`build.gradle*`（Spring 未命中）、无 `nuxt.config.*` 且全部 package.json 依赖不含 `nuxt`（Nuxt 未命中），触达面为纯 Markdown skill 文本；设计产物全程标注「未触 writer 约束（用户豁免）」。

## Goals / Non-Goals

**Goals**：六项实证缺口全部入 spec 与 skill 文本（F1 落档材料校验+恢复防线、F2 多仓分立+外部仓外溢、F3 组收尾勾选核对、F9 verify-change 归档前必经、F4 R<n> 连锁面模板、F5 沉淀回流清单、F7 两侧 provider 名）；新条目逐字定稿供执行照抄，消除并行任务措辞漂移；全部修订文件码点 ≤7849。

**Non-Goals**：不改方法论内核（双线独立性、七步收敛、设计深度契约、引擎与三模式语义、模型路由架构）；不动 `dsh/commands/*.md`、`dsh/spec-workflow.yaml` 键值与 failure-modes.md；不处理工作区两处既有脏改动（Q6 裁定由执行方落档后按「T3.1 执行期沉淀」单独提交）；split-spec-plan-skill 遗留的对抗性复核分档等独立蓝图不在本变更。

## Decisions

- **D1 F1① 断言形态 = planning.md 第 4 步两段式（`test -f` 两材料 + `validate --strict`），SKILL.md 入口只留一句**。被否：扩展 openspec validate 覆盖附加文件——CLI 只认工件结构。反例：T3.1 落档时 validate 通过、两材料却 git 零足迹，validate 通过不证明材料入库。
- **D2 F1② 恢复防线 = 自动补复制 + 两者皆无问用户**（Q2 裁定）。被否：静默改用 /tmp 原件——T3.1 实况，恰好掩盖契约缺口，是本变更要修的对象本身。
- **D3 F9 连锁：`openspec-verify-change` 同步进 spec-workflow 第二节④能力自检**（必经环节缺失不能等到归档才发现；前置检查④对 grill-me/openspec-explore 已是此用法）。被否：仅阶段 4 现场加载、缺失再处置——批次会停在最后一步。
- **D4 F2 措辞「多仓分立提交」三处逐字同源**（SKILL.md 第十节 / execution.md 提交纪律 / 主规格 ADDED Requirement 名）。被否：各处意译。反例：F7 本身即双源漂移实例。
- **D5 F5 delta 形态 = ADDED 独立 Requirement「执行期沉淀回流」**。被否：并入「验证门与归档提交」MODIFIED——该 Requirement 主题是验证与归档，并入使主题漂移。Q-B 裁定：清单含已提交（标去向）与未提交项。
- **D6 F4 连锁面模板写进主规格「执行期留痕与工件维护」MODIFIED 正文**（skill 层 execution.md 同步扩义）。被否一：只进 skill 层——条目格式是行为契约一半，分层制造漂移面。被否二：连锁面独立成工件——T3.1 R9~R11 证明条目内承载足够。
- **D7 F7 范围 = 两侧（Q-A 裁定随本变更同改）**：执行侧表格 L35-36 + schema 示例 L13（T5）、规划侧 schema 示例 L9-11（T5b）；排除 pi-ai 数据路径 `{zai,...}.json`（真实文件名，事实引用）。
- **D8 任务分 3 组；组 1 经 Q-A 扩为 4 任务**（≤ 工作区 parallelism=8；yaml 值随 Q6 提交转正，无时序依赖）。被否：五文件并一组（审核粒度差）/ 每文件一组（拖长节奏）。
- **D9 delta 与落档工件不设执行任务**——delta 随落档生成入库，执行期不动 `openspec/`。被否：把 delta 写入列为执行任务——违反「落档工件单独提交一次」时序与归档同步职责边界。
- **D10 同文件多处改动合单任务**（T3 五节→2.1、T4 六条→2.2）。被否：同文件拆两组——无写冲突收益，徒增审核批次。

## 触达面清单（与 code-design.md ①逐项对应，逐字新文本见其 (b) 节）

| # | 文件 | 改动意图 | 码点（现→估） |
| --- | --- | --- | --- |
| T1 | `agent/skills/spec-plan/SKILL.md` | 第七节④步扩「两材料断言 + validate」 | 7125→~7170 |
| T2 | `agent/skills/spec-plan/refs/planning.md` | 落档细节第 4 步改两段式校验 | 5862→~5960 |
| T3 | `agent/skills/spec-workflow/SKILL.md` | 五节联动：②能力自检加 verify-change、⑤恢复协议插「落档副本存在性检查」步、⑥骨架行组收尾首加勾选核对、⑦④步拆归档前校验+归档、⑦⑦汇报五要素、⑩绝不做末条多仓分立 | 6431→~6750 |
| T4 | `agent/skills/spec-workflow/refs/execution.md` | 六处：多仓分立提交+外部仓外溢口径、组收尾勾选核对首条、组段终形态化前提句、R<n> 模板扩连锁面+推翻标注、归档前 verify-change 拆步、汇报五要素 | 4768→~5350 |
| T5 | `agent/skills/spec-workflow/refs/routing.md` | L13/L35/L36 三处 `zai`→`zai-coding-cn` | 3913→~3945 |
| T5b | `agent/skills/spec-plan/refs/routing.md` | L9/L10/L11 三处 provider 名（Q-A） | 4374→~4404 |
| T6 | `specs/spec-workflow/spec.md`（delta，随落档生成） | REMOVED×1 + MODIFIED×3 + ADDED×2 | 新建 |
| T7 | `specs/spec-plan/spec.md`（delta，随落档生成） | MODIFIED×1 | 新建 |

步序重编号三处必须完整：SKILL.md 恢复协议原 4/5/6→5/6/7、第七节原⑤⑥→⑥⑦（原④拆新④⑤）、execution.md 派发要点原 5/6→6/7（原 4 拆 4/5）。

## Risks / Trade-offs

- [execution.md 注入五项超码点预算] → 逐字文本已预排（~5350/7849），任务 3.1 python 断言逐文件复核。
- [步序重编号漏改致节内编号断裂] → 设计逐字列出三处重编号范围；验证句含新关键词唯一计数。
- [verify-change 作为必经环节在 skill 不可加载时卡死归档] → 前置检查④能力自检兜底（D3），缺失按 failure-modes 处置顺序修复后才开工。
- [T3.1 类「落档早于纪律生效」的存量变更继续恢复] → 恢复防线对存量变更同样生效（副本缺失→补复制），不要求重构历史。

## Migration Plan

纯 Markdown 文本修订，无迁移；六文件按任务组 1（spec-plan 侧+routing 两侧）→ 组 2（spec-workflow 执行侧正文）→ 组 3（只读全量验证）顺序实施，批次提交即可回滚。主规格由归档流程按 delta 同步。

## Open Questions

（无——Q1~Q6、Q-A/Q-B 已全部裁定，留痕 decisions.md 落档副本。）
