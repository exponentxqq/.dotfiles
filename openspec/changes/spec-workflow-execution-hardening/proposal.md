# Proposal

## Why

T3.1 skill 域变更（opc 仓，2026-10-16 落档归档，四仓分立提交、R1~R11 执行期裁定链）是 spec-plan 拆分后两个 skill 的首个完整实战。复盘暴露六项现存 spec 未承载、且已被 git 与 /tmp 证据坐实的流程缺口：

1. **两材料落档契约无落地校验**：T3.1 落档（14:57:30）早于 parallel-team-engine 纪律生效（15:10:27）13 分钟，`code-design.md`/`diff-matrix.md` 在 opc 仓 git 零足迹、从未入库；落档校验只有 `openspec validate --strict`（不覆盖附加文件），执行期「组段终形态化」因落档副本不存在而实质落空，`continue` 恢复时无人发现契约未满足——/tmp 原件幸存掩盖了缺口。
2. **多仓与外部独立仓口径不足**：实战四仓分立（根仓/service/portal/**apigen 独立仓**，非嵌套子仓）；R9 执行期需求外溢到 apigen（工作区外独立仓）走呈证期用户明示合法化，spec 仅「嵌套独立子仓（两仓）」口径，外溢无正路。
3. **勾选核对缺组级兜底**：T3.1 tasks 3.1/4.1（组 2/3 已入库工作）勾选遗漏直到归档前手动插入的 openspec-verify-change 校验才暴露——组收尾清单无勾选核对步，归档前校验环节本身也未入流程（spec-workflow 全文对 verify-change 零提及）。
4. **R<n> 留痕模板缺连锁面**：R9/R10/R11 自发写全了工件连锁清单（契约 desc/spec/design/生成物/代码/测试），R10→R11 推翻链的连锁同步靠自觉——模板缺「连锁面」要素与推翻标注。
5. **执行期沉淀回流无通道**：spring-writer/SKILL.md +2 条规则、spec-workflow.yaml parallelism 3→8 两处沉淀躺在工作区未提交——最终汇报无「沉淀回流清单」要素。
6. **routing provider 名漂移**：两侧 routing.md 的 schema 示例与图片能力表存在 `zai` vs `zai-coding-cn`（yaml 实际值）双源漂移（执行侧表格 + 规划侧 schema 示例，共六处）。

（审核另核：全部 11 个 skill 文件码点 ≤7849 合规、routing 其余双源表述对称一致——证伪项不留需求。）

## What Changes

- **落档材料存在性校验（F1①）**：spec-plan 落档校验步改两段式——先 `test -f` 机械断言两材料副本在变更目录（缺失回到复制步），再 `openspec validate --strict`；SKILL.md 入口④步名同步。
- **恢复防线（F1②③）**：spec-workflow 恢复协议插「落档副本存在性检查」步——缺失且 /tmp 原件在 → 自动补复制入变更目录并留痕（随下次批次提交）；两者皆无 → 报告问用户，不以 /tmp 幸存为默认；execution.md 组段终形态化加前提句。
- **组收尾勾选核对（F3）**：批次循环骨架与组收尾清单首步加「本组任务全 `- [x]` 才进工件维护与呈证」。
- **归档前校验必经（F9）**：阶段 4 在归档前加载 `openspec-verify-change`（任务全勾 + spec 覆盖映射 + design 一致性），缺漏先修复重校；skill 同步进前置检查④能力自检。
- **多仓分立提交 + 外部仓外溢口径（F2）**：提交纪律泛化「代码/工件/生成物各归其仓，N 仓各自完整提交」；外部独立仓外溢 = 规划外 scope 变化 → 停下回用户，明示后随该仓提交并留痕；主规格 REMOVED「嵌套子仓提交」+ ADDED「多仓分立提交」成对表达。
- **R<n> 模板扩连锁面（F4）**：条目模板「规则+依据+适用范围」→ 追加「连锁面」；推翻前裁定须标注并重跑连锁同步。
- **汇报五要素 + 沉淀回流（F5）**：最终汇报四要素 → 五要素（⑤沉淀回流清单：执行期改动的工作流仓文件，已提交标去向、未提交交用户定夺，流程不代提交）。
- **provider 名修正（F7/Q-A）**：两侧 routing.md 共六处 `zai` → `zai-coding-cn`（与 yaml 实际值对齐；pi-ai 数据路径 `{zai,...}.json` 为真实文件名不动）。

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `spec-workflow`：**REMOVED**×1（嵌套子仓提交——语义迁移）；**ADDED**×2（多仓分立提交、执行期沉淀回流）；**MODIFIED**×3（验证门与归档提交——归档前 verify-change 必经；落档到执行的衔接与恢复——落档副本存在性检查与补复制；执行期留痕与工件维护——组收尾勾选核对、落档副本前提、连锁面模板与推翻标注）。
- `spec-plan`：**MODIFIED**×1（落档工件与执行批次契约——落档校验含两材料存在性机械断言 + 新 Scenario）。

## Impact

- 代码/文档：`agent/skills/spec-workflow/SKILL.md`（五节联动）、`refs/execution.md`（六处条目）、`refs/routing.md`（三处 provider 名）、`agent/skills/spec-plan/SKILL.md`（④步一句）、`refs/planning.md`（第 4 步两段式）、`refs/routing.md`（三处 provider 名）；主规格随归档 delta 同步，不手改。
- 不影响：两 skill 方法论内核（双线独立性、七步收敛、设计深度契约、引擎与三模式、模型路由架构）、`dsh/commands/*.md`、`dsh/spec-workflow.yaml` 键值、openspec-* skills。
- 风险：execution.md 注入五项（4768→~5350 码点，余量充足）；步序重编号三处已逐字列明防漏改。
