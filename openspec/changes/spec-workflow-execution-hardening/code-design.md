# 代码设计：spec-workflow-execution-hardening（阶段 1.7）

> 上游：`explore.md`（六项发现证据链）+ `decisions.md`（阶段 1.5 收敛，全部已定）。本文档不复读上游结论，只做代码级展开：逐字新文本、插入点、验证断言、任务分组。发现与收敛的矛盾仅一处（F7 改法「两侧」vs 裁定「执行侧」），已上浮待决（Q-A），不重开收敛。
>
> **未触 writer 约束（用户豁免）**。栈识别复核（实测）：dotfiles 仓 find 探测仅命中 `opencode/package.json` 与 `tools/skctl/package.json`，两文件依赖均不含 `nuxt`，全仓无 `nuxt.config.*`、无 `pom.xml`/`build.gradle*`——Spring/Nuxt 均未命中，触达面为纯 Markdown。
>
> 码点基线（python len 实测）：spec-plan/SKILL.md 7125｜planning.md 5862｜spec-workflow/SKILL.md 6431｜execution.md 4768｜spec-workflow/refs/routing.md 3913。修订后均须 ≤7849。

## ① 触达面清单

| # | 文件（自项目根） | 改动意图 | 关键改动点 | 码点（现→估） |
| --- | --- | --- | --- | --- |
| T1 | `agent/skills/spec-plan/SKILL.md` | F1①落档校验面补两材料断言（入口级一句） | 第七节④步步名扩「两材料断言 + validate」，断言细节指针到 planning.md | 7125→~7170 |
| T2 | `agent/skills/spec-plan/refs/planning.md` | F1①机械断言落地 | 「附：落档细节」第 4 步改两段式：先 `test -f` 断言两材料、再 `openspec validate --strict` | 5862→~5960 |
| T3 | `agent/skills/spec-workflow/SKILL.md` | F1②/F3/F9/F2/F5 五节联动 | ②能力自检加 `openspec-verify-change`；⑤恢复协议插第 4 步「落档副本存在性检查」；⑥骨架行组收尾首步加勾选核对；⑦④步拆「归档前校验＋归档」、⑥汇报四→五要素；⑩绝不做末条「嵌套子仓分仓提交」→「多仓分立提交」 | 6431→~6750 |
| T4 | `agent/skills/spec-workflow/refs/execution.md` | F2/F3/F4/F5/F9/F1③ 六项注入 | 提交纪律条泛化+新增外部仓外溢口径；组收尾清单首步勾选核对；组段终形态化前提句；R<n> 模板加连锁面+推翻标注；归档前 verify-change；汇报四→五要素 | 4768→~5350 |
| T5 | `agent/skills/spec-workflow/refs/routing.md` | F7 provider 名修正 | schema 示例 L13 + 图片能力表 L35-36 共三处 `zai`→`zai-coding-cn` | 3913→~3945 |
| T5b | `agent/skills/spec-plan/refs/routing.md` | F7 provider 名修正（Q-A 裁定随本变更同改） | schema 示例 L9/L10/L11 三处 `provider: zai`→`provider: zai-coding-cn`；图片能力表 :34-35 已是 `zai-coding-cn` 不动；:30 与 L38 事实引用不在范围 | 4374→~4404 |
| T6 | `openspec/changes/spec-workflow-execution-hardening/specs/spec-workflow/spec.md` | **新建**（落档阶段 2 生成，非执行任务） | delta：REMOVED「嵌套子仓提交」+ ADDED「多仓分立提交」成对；ADDED「执行期沉淀回流」；MODIFIED×3（验证门与归档提交 / 落档到执行的衔接与恢复 / 执行期留痕与工件维护） | 新建 ~3000 |
| T7 | `openspec/changes/spec-workflow-execution-hardening/specs/spec-plan/spec.md` | **新建**（落档阶段 2 生成，非执行任务） | delta：MODIFIED「落档工件与执行批次契约」（两材料存在性断言 + 新 Scenario） | 新建 ~1300 |
| T8 | `openspec/changes/spec-workflow-execution-hardening/{proposal,design,tasks}.md` 及两材料副本 | **新建**（openspec-propose 生成） | design.md 逐断言承载本蓝图六字段；tasks.md 按③字段任务行全表落档；`code-design.md`+`decisions.md` 复制入变更目录 | — |

执行任务只覆盖 T1~T5（skill 文本修订）＋只读验证；T6~T8 属落档工件（阶段 2 生成、随落档提交入库），见决策 D9。`dsh/spec-workflow.yaml`、`dsh/commands/*.md`、failure-modes.md 不动。

## ② 证据锚

- **T1**：`agent/skills/spec-plan/SKILL.md:100` 「**④`openspec validate <change> --strict` 退出码 0**（不得带病落档）」——校验步只有 CLI 校验，无两材料存在断言；对照 `:22` 「唯一例外——`code-design.md` 与 `diff-matrix.md`（串行 `decisions.md`）随落档复制入 `openspec/changes/<change>/`，落档后以落档副本为权威」——复制契约已在、校验缺位。
- **T2**：`agent/skills/spec-plan/refs/planning.md:68` 「4. **校验**：`openspec validate <change> --strict`，必须退出码 0 且无 error/warning（此时变更目录已含两份材料副本，校验覆盖其存在）」——括注是叙述性假设而非断言动作，且 CLI 实际只认工件结构、不覆盖附加文件。
- **T3**：`agent/skills/spec-workflow/SKILL.md:46` 「**④能力自检**（`spec-plan` 与 `openspec-archive-change` 可加载；…）」——无 `openspec-verify-change`；`:62-67` 恢复协议六步（重建进度→读勾选→三方对齐→绝不重跑→进度摘要→工件现读）无落档副本检查；`:79` 「组收尾：工件维护（code-design.md 组段终形态化、R<n> 留痕）→ 按执行模式停留呈证 → 用户确认后才提交」——无勾选核对步；`:90` 「**④通过后归档**（`tasks.md` 全部勾选 → `openspec-archive-change` 归档并同步主规格）→ **⑤归档单独提交一次**…→ **⑥汇报四要素**（工件路径 / 验证证据 / 归档位置与主规格 / 宿主操作清单）」；`:112` 末条 「嵌套独立子仓**分仓提交**、不跨仓混提」。
- **T4**：`agent/skills/spec-workflow/refs/execution.md:36` 「**嵌套独立子仓分仓提交**：目标项目含嵌套独立 git 子仓（如根仓承载 openspec 工件、子仓承载代码）时，…**两仓各自形成完整提交、不跨仓混提**」——仅两仓嵌套口径，无外部独立仓；`:42-46` 组收尾清单（工件维护→呈证→提交三段）无勾选核对；`:44` 「**维护目标是变更目录内的落档副本（`openspec/changes/<change>/code-design.md`，spec-plan 落档时复制入库），更新随批次提交入库；`/tmp` 侧原件不再维护**」——无「副本存在」前提检查；`:45` 「条目须自包含（规则 + 依据 + 适用范围）」——模板缺连锁面；`:62` 「4. **通过后归档**：确认 `tasks.md` 全部勾选（有未勾选项不得归档），加载 `openspec-archive-change` skill 执行归档并同步主规格」——无 verify-change 环节；`:64` 「6. **最终汇报四要素**」。
- **T5**：`agent/skills/spec-workflow/refs/routing.md:13` 「`vision: { provider: zai, model: glm-5.3-flash }`」、`:35-36` 图片能力表 「`zai/glm-5.3-flash`」「`zai/glm-5.3`」——与 yaml 实际 `zai-coding-cn`（`dsh/spec-workflow.yaml:15-19,30`）漂移；注意 `:28` pi-ai 数据路径 `{zai,opencode-go,deepseek}.json` 是真实文件名，**不在修正范围**。
- **T5b**（Q-A 裁定纳入）：`agent/skills/spec-plan/refs/routing.md:9-11` 「`lineA: { provider: zai, model: glm-5.3 }`」「`design: { provider: zai, ... }`」「`vision: { provider: zai, ... }`」——schema 示例三处简写与同文件 `:34-35` 图片能力表（`zai-coding-cn`）及 yaml 实际值漂移；`:30` pi-ai 路径 `{zai,...}.json` 为事实引用不动。
- **T6**（delta 引用的主规格现状）：`openspec/specs/spec-workflow/spec.md:224` 「### Requirement: 嵌套子仓提交」（REMOVED 对象）；`:120` 「### Requirement: 验证门与归档提交」；`:28` 「### Requirement: 落档到执行的衔接与恢复」；`:247` 「### Requirement: 执行期留痕与工件维护」。块格式先例（实测归档 `2026-10-16-split-spec-plan-skill/specs/spec-workflow/spec.md:134-138`）：REMOVED 块 = `### Requirement: 名` + `**Reason**` + `**Migration**`，不带正文；MODIFIED 块 = Requirement 全文新版 + 完整 Scenario 集（`2026-10-16-spec-plan-parallel-team-engine/specs/spec-plan/spec.md:59-67`）。
- **T7**：`openspec/specs/spec-plan/spec.md:121` 「### Requirement: 落档工件与执行批次契约」；`:123` 「落档时 SHALL 把 `code-design.md` 与 `diff-matrix.md`（串行：`decisions.md`）复制入变更目录随工件提交；落档副本 SHALL 为执行期维护与接续恢复的权威，`/tmp` 侧原件自此不再维护」——复制义务在、存在性校验缺。
- **T6/T7/T8**：新建文件，标「新建」。

## ③ 接口与数据形状

本变更纯 Markdown 修订，本字段承载：(a) 目标节定位表；(b) 新条目逐字文本（执行子代理照抄，防措辞漂移）；(c) tasks.md 任务行格式与全表；(d) delta 的 Requirement/Scenario 结构形状。

### (a) 目标节定位

| 修订项 | 文件 | 节 | 插入点 |
| --- | --- | --- | --- |
| F1① | T1 | 第七节「落档」 | L100 ④步步内替换 |
| F1① | T2 | 附：落档细节 | L68 第 4 步整步替换 |
| F9 连锁 | T3 | 第二节 前置检查 | L46 ④能力自检括注内 |
| F1② | T3 | 第五节 衔接与恢复协议 | L64 第 3 步后插新第 4 步，原 4/5/6 顺延 5/6/7 |
| F3 | T3 | 第六节 批次循环骨架 | L79 「组收尾：」后行首插「勾选核对 →」 |
| F9②/F5 | T3 | 第七节 验证与归档 | L90 ④步拆两步（新④⑤），原⑤⑥顺延⑥⑦ |
| F2 | T3 | 第十节 绝不做 | L112 末条「嵌套独立子仓分仓提交、不跨仓混提」整段替换 |
| F2 | T4 | 附：三模式与提交纪律 | L36 整条替换＋其后插「外部仓外溢口径」新条 |
| F3 | T4 | 附：执行期留痕与工件维护 | L42 节首（「组段终形态化」条前）插新首条 |
| F1③ | T4 | 同上 | L44 条末追加前提句 |
| F4 | T4 | 同上 | L45 「（规则 + 依据 + 适用范围）」处扩义＋条末加推翻句 |
| F9② | T4 | 附：验证与归档派发要点 | L62 第 4 步拆 4/5 两步，原 5/6 顺延 6/7 |
| F5 | T4 | 同上 | L64 四要素→五要素 |
| F7 | T5 | §九 schema 示例＋图片能力表 | L13、L35、L36 三处替换 |
| F7 | T5b | §八 schema 示例 | L9、L10、L11 三处 `provider: zai`→`zai-coding-cn`（Q-A 裁定） |

### (b) 新条目逐字文本

**T1（L100 ④步替换为）**：

> **④两材料断言 + `openspec validate <change> --strict` 退出码 0**（`code-design.md` 与 `diff-matrix.md`/串行 `decisions.md` 须 `test -f` 在变更目录，断言展开见 [planning.md](refs/planning.md)；不得带病落档）

**T2（L68 整步替换为）**：

> 4. **校验（两段式）**：先机械断言两份落档材料已在变更目录——`test -f openspec/changes/<change>/code-design.md` 与 `test -f openspec/changes/<change>/diff-matrix.md`（串行 `decisions.md`），任一缺失回到第 1 步补复制（`openspec validate` 只认工件结构，不覆盖附加文件）；再跑 `openspec validate <change> --strict`，必须退出码 0 且无 error/warning。任一不通过则修工件重跑，**不得带病落档**。

**T3 五处**：

1. （L46 ④）「**④能力自检**（`spec-plan`、`openspec-verify-change` 与 `openspec-archive-change` 可加载；不可加载按 [failure-modes.md](refs/failure-modes.md) 处置顺序处理）」
2. （恢复协议新第 4 步）「4. **落档副本存在性检查**：`code-design.md` 与 `diff-matrix.md`（串行 `decisions.md`）须在变更目录——缺失且 `/tmp/spec-flow/<change>/` 原件在 → 从原件**补复制入变更目录并留痕**（随下次批次提交）；两者皆无 → 报告问用户，**不以 /tmp 幸存为默认**。」
3. （L79 骨架行）「组收尾：**勾选核对（本组任务全 `- [x]`）** → 工件维护（code-design.md 组段终形态化、R<n> 留痕）→ 按执行模式停留呈证 → 用户确认后才提交」
4. （L90 新④⑤⑦）「**④通过后、归档前加载 `openspec-verify-change` 校验**（任务全勾 + spec 覆盖映射 + design 一致性；缺漏先修复重校——如补勾、补 delta）→ **⑤归档**（`tasks.md` 全部勾选 → `openspec-archive-change` 归档并同步主规格）→ **⑥归档单独提交一次**（报错贴原文并停，**不手工搬移目录**）→ **⑦汇报五要素**（工件路径 / 验证证据 / 归档位置与主规格 / 宿主操作清单 / 沉淀回流清单——执行期改动的工作流仓文件，交用户决定提交与方式）」（①②③原文不动）
5. （L112 末条）「多仓**分立提交**（代码 / 工件 / 生成物各归其仓、N 仓各自完整提交）、不跨仓混提」

**T4 六处**：

1. （L36 替换＋新条）：

> - **多仓分立提交**：代码、工件、生成物各归其仓——嵌套独立子仓（如根仓承载 openspec 工件、子仓承载代码）与工作区外独立仓（用户明示参与后）同循此则：**N 仓各自形成完整提交、不跨仓混提**。
> - **外部仓外溢口径**：执行期需求波及工作区外独立仓 = 规划外 scope 变化 → 停下回用户（呈证点呈报或按硬停条件③）；用户明示后改动随该仓提交、R<n> 留痕注明外溢。

2. （组收尾清单新首条）「- **勾选核对**：本组任务全部 `- [x]` 才进工件维护与呈证——发现未勾先补跑该任务验证句核对再勾；勾选与工件维护、提交同为组收尾必做。」
3. （L44 条末追加）「**前提——落档副本在变更目录**：缺失按 SKILL.md 第五节恢复协议补复制或问用户，**不得以 /tmp 原件替代维护**。」
4. （L45 扩义）「条目须自包含（规则 + 依据 + 适用范围 + **连锁面**——该规则联动需同步的工件 / spec Scenario / 代码 / 测试清单）；推翻前裁定时前条标注「被 R<n'> 推翻」并对其连锁面重跑同步。」
5. （L62 拆两步）「4. **归档前校验**：加载 `openspec-verify-change` skill 校验（任务全勾、spec 覆盖映射、design 一致性），发现缺漏（如勾选遗漏、delta 缺 Scenario）先修复重校——通过才归档。\n5. **归档**：确认 `tasks.md` 全部勾选（有未勾选项不得归档），加载 `openspec-archive-change` skill 执行归档并同步主规格。」
6. （L64 五要素）「6. **最终汇报五要素**：①变更名与工件路径；②验证证据（命令 + 结果摘要）；③归档位置（`openspec/changes/archive/...` 与同步后的主规格）；④后续宿主操作清单（需要用户在容器外做的事，如 skctl 登记、推送 `git push`、以及命令仍不可见时的 `docker compose restart dsh` 兜底——本流程不代劳）；⑤**沉淀回流清单**——执行期改动的工作流仓文件（skill 文本、工作流配置，含未提交项）逐条列明，交用户决定提交与方式，本流程不代提交。」

**T5 三处**（L13 / L35 / L36，仅 provider 名，行内其余字节不动）：
- `vision: { provider: zai-coding-cn, model: glm-5.3-flash }`
- `| zai-coding-cn/glm-5.3-flash | 支持（["text","image"]） | vision 键 |`
- `| zai-coding-cn/glm-5.3 | **不支持**（input: ["text"]） | 规划侧默认路由（spec-plan 消费） |`

**T5b 三处**（L9/L10/L11，仅 provider 名，行内注释字节不动）：
- `lineA: { provider: zai-coding-cn, model: glm-5.3 }`
- `design: { provider: zai-coding-cn, model: glm-5.3 }`
- `vision: { provider: zai-coding-cn, model: glm-5.3-flash }`

### (c) tasks.md 任务行格式与全表

格式（仓契约）：`- [ ] N.M <一句可执行描述，引用触达面条目编号>；验证：<第三方可核对验证句>`；`## N. 组名` = 执行审核批次。全表（3 组 8 任务，组内互不写同一文件、组 1 四文件 / 组 2 两文件 / 组 3 只读）：

```markdown
## 1. spec-plan 侧落档校验与执行侧 routing 修正

- [ ] 1.1 按触达面 T1 修订 agent/skills/spec-plan/SKILL.md：第七节④步扩「两材料断言 + validate」；验证：grep -c '两材料断言' agent/skills/spec-plan/SKILL.md 输出 1，且 python3 -c "assert len(open('agent/skills/spec-plan/SKILL.md',encoding='utf-8').read())<=7849" 退出码 0
- [ ] 1.2 按触达面 T2 修订 agent/skills/spec-plan/refs/planning.md：落档细节第 4 步改两段式校验；验证：grep -c 'test -f openspec/changes/<change>/' agent/skills/spec-plan/refs/planning.md 输出 2，且同文件码点断言 ≤7849 退出码 0
- [ ] 1.3 按触达面 T5 修订 agent/skills/spec-workflow/refs/routing.md：三处 provider 名 zai→zai-coding-cn（L13/L35/L36）；验证：grep -c 'zai-coding-cn' agent/skills/spec-workflow/refs/routing.md 输出 3，grep -En 'provider: zai[,}]' 该文件退出码 1（零命中），grep -En '`zai/glm' 该文件退出码 1
- [ ] 1.4 按触达面 T5b 修订 agent/skills/spec-plan/refs/routing.md：schema 示例 L9/L10/L11 三处 provider: zai→zai-coding-cn（Q-A 裁定）；验证：grep -En 'provider: zai[,}]' agent/skills/spec-plan/refs/routing.md 退出码 1（零命中），且 python3 -c "assert len(open('agent/skills/spec-plan/refs/routing.md',encoding='utf-8').read())<=7849" 退出码 0

## 2. spec-workflow 执行侧正文强化

- [ ] 2.1 按触达面 T3 修订 agent/skills/spec-workflow/SKILL.md：五处节改动（②能力自检、⑤恢复协议插步、⑥骨架行、⑦归档链拆步与五要素、⑩绝不做末条）；验证：grep -c '落档副本存在性检查' 该文件 = 1、grep -c 'openspec-verify-change' 该文件 = 2、grep -c '勾选核对' 该文件 = 1、grep -c '汇报五要素' 该文件 = 1、grep -c '分立提交' 该文件 = 1，且码点断言 ≤7849 退出码 0
- [ ] 2.2 按触达面 T4 修订 agent/skills/spec-workflow/refs/execution.md：六处条目注入（多仓分立提交＋外部仓外溢、勾选核对、前提句、连锁面、归档前校验、五要素）；验证：grep -c '多仓分立提交' = 1、grep -c '外部仓外溢口径' = 1、grep -c '勾选核对' = 1、grep -c '前提——落档副本在变更目录' = 1、grep -c '连锁面' = 2、grep -c 'openspec-verify-change' = 1、grep -c '沉淀回流清单' = 1（均在 agent/skills/spec-workflow/refs/execution.md），且码点断言 ≤7849 退出码 0

## 3. 全量验证与一致性复核（只读）

- [ ] 3.1 按触达面 T1~T5 做机械断言复核：python3 单脚本逐文件断言 5 个修订文件 len ≤7849 且 (b) 节全部 grep 锚点按预期计数命中；验证：该脚本退出码 0
- [ ] 3.2 按触达面 T1~T5 做流程断言：F2 口径「多仓分立提交」在 agent/skills/spec-workflow/SKILL.md、refs/execution.md、openspec/changes/spec-workflow-execution-hardening/specs/spec-workflow/spec.md 三处 grep -c 各 = 1；openspec validate spec-workflow-execution-hardening --strict 退出码 0；git status --porcelain 相对本批开始时快照，除 5 个目标文件外无新增改动行（agent/skills/spring-writer/SKILL.md 与 dsh/spec-workflow.yaml 两处既有脏改动保持原样未卷入）
```

### (d) delta 结构形状（T6/T7，落档生成）

**T6 `specs/spec-workflow/spec.md`**（块序按 openspec-propose 生成器惯例；REMOVED+ADDED 成对表达已过 split 先例 `--strict`，decisions 事实裁定）：

```
## REMOVED Requirements
### Requirement: 嵌套子仓提交
**Reason**: 口径泛化为多仓分立提交（嵌套子仓为其子集），并入新 Requirement。
**Migration**: 语义迁移至本变更 ADDED「多仓分立提交」，原双仓 Scenario 由其承接。

## MODIFIED Requirements
### Requirement: 验证门与归档提交
<新版全文 = 原正文（openspec/specs/spec-workflow/spec.md:122 语义句）+ 扩义：
「项目验证通过后、归档前，工作流 SHALL 加载 `openspec-verify-change` 做完整性校验（任务全勾、spec 覆盖映射、design 一致性），发现缺漏 SHALL 先修复重校，校验通过 SHALL 才归档」>
#### Scenario: 验证失败不归档（保留原文）
#### Scenario: verify-change 拦截勾选遗漏（新增）
- WHEN 归档前校验发现已入库任务的勾选遗漏
- THEN 先补核对勾选并修复重校，通过才归档，不绕过校验归档

### Requirement: 落档到执行的衔接与恢复
<新版全文 = 原正文（:30 语义句）+ 扩义：
「恢复时 SHALL 校验两份落档材料在变更目录：缺失且 /tmp 原件在 SHALL 从原件补复制入变更目录并留痕（随下次批次提交）；两者皆无 SHALL 报告问用户，SHALL NOT 以 /tmp 幸存为默认」>
#### Scenario: 落档完成后衔接 / 压缩上下文后继续执行 / auto 中途恢复保留已完成任务（三则保留原文）
#### Scenario: 恢复时补复制落档副本（新增）
- WHEN 恢复时变更目录缺 code-design.md 或 diff-matrix.md（串行 decisions.md）而 /tmp 原件存在
- THEN 从原件补复制入变更目录并留痕，随下次批次提交；不以 /tmp 幸存为默认继续

### Requirement: 执行期留痕与工件维护
<新版全文 = 原正文（:249 语义句）+ 扩义三句：
「每组收尾 SHALL 先核对本组任务全部勾选才进工件维护与呈示」「组段终形态化以落档副本在变更目录为前提，缺失按恢复协议处置，SHALL NOT 以 /tmp 原件替代维护」「编号条目 SHALL 自包含（规则、依据、适用范围、连锁面——联动需同步的工件/代码/测试清单）；推翻前裁定 SHALL 在前条标注被推翻并重跑连锁面同步」>
#### Scenario: 组段终形态化 / 运行规则编号留痕 / 证据不入库（三则保留原文）
#### Scenario: 组收尾勾选核对（新增）
- WHEN 某组全部任务核对完成进入收尾
- THEN 先确认本组任务全部勾选（漏勾先补核对验证句再勾），再进工件维护与呈证
#### Scenario: 留痕条目含连锁面（新增）
- WHEN 执行期以 R<n> 留痕新证实规则
- THEN 条目含连锁面清单；后续条目推翻它时前条标注「被 R<n'> 推翻」并重跑连锁同步

## ADDED Requirements
### Requirement: 多仓分立提交
目标项目涉及多个独立 git 仓（嵌套子仓、工作区外独立仓）时，提交 SHALL 分仓进行：代码、工件、生成物各归其仓，N 仓 SHALL 各自形成完整、可独立回溯的提交，SHALL NOT 跨仓混提或以单仓提交覆盖另一仓改动。执行期需求波及工作区外独立仓 SHALL 先停下回用户（呈证点呈报或按硬停条件）；用户明示后改动 SHALL 随该仓提交并以留痕注明外溢。
#### Scenario: 双仓分别提交（承接原「嵌套子仓提交」Scenario 语义）
- WHEN 某批次同时产出子仓代码改动与根仓工件改动
- THEN 两仓分别显式 add 并各自提交，提交信息各自描述本仓改动
#### Scenario: 外部独立仓外溢经用户明示（新增）
- WHEN 执行期需求波及工作区外独立仓
- THEN 停下呈报等用户明示；明示后改动随该仓提交、留痕注明外溢，不并入目标项目仓

### Requirement: 执行期沉淀回流
最终汇报 SHALL 含沉淀回流清单：执行期改动的工作流仓文件（skill 文本、工作流配置）逐条列明（含已提交项的去向与未提交项），交用户决定提交与方式；工作流 SHALL NOT 代为提交工作流仓。
#### Scenario: 汇报含沉淀回流清单（新增）
- WHEN 阶段 4 最终汇报
- THEN 增列沉淀回流清单（含未提交项与去向建议），由用户决定提交，流程不代提交
```

**T7 `specs/spec-plan/spec.md`**：

```
## MODIFIED Requirements
### Requirement: 落档工件与执行批次契约
<新版全文 = 原正文（openspec/specs/spec-plan/spec.md:123 语义句）+ 扩义：
「落档校验 SHALL 含两份材料副本存在性的机械断言（test -f 逐文件），任一缺失 SHALL 回到复制步补齐后再跑 `openspec validate --strict`」>
#### Scenario: 分组内任务并行执行 / 分组间串行 / 组内单任务合法 / design 继承设计草案深度 / 任务引用触达面条目 / 落档含规划材料 / 执行期维护落档副本（七则保留原文）
#### Scenario: 落档校验断言材料存在（新增）
- WHEN 落档校验步执行
- THEN 先断言 code-design.md 与 diff-matrix.md（串行 decisions.md）在变更目录（test -f），缺失回复制步补齐，再跑 openspec validate --strict
```

## ④ 决策记录

- **D1 F1① 断言形态 = planning.md 第 4 步两段式（test -f + validate），SKILL.md 只留一句**。被否：扩展 `openspec validate` 覆盖附加文件——CLI 只认工件结构（explore F1 已否）。反例：T3.1 落档时 `openspec validate --strict` 通过、两材料却在 opc 仓 git 零足迹——validate 通过不证明材料入库。
- **D2 F1② 恢复防线按 Q2 裁定落逐字文本（自动补复制 + 两者皆无问用户）**。被否：恢复时静默改用 /tmp 原件——T3.1 实况，恰好掩盖契约缺口，是本次要修的对象本身。
- **D3 F9 连锁：`openspec-verify-change` 同步进 T3 第二节④能力自检**（explore 拆分草案未列，本设计补的连锁面——必经环节缺失不能等到归档才发现）。被否：仅阶段 4 现场加载、缺失再处置。反例：若沿此路，执行跑到归档前才发现 skill 不可加载，整个批次停在最后一步，而前置检查④的存在意义正是开工前兜住 skill 依赖（对 `grill-me`/`openspec-explore` 已是此用法，spec-plan SKILL.md L48）。
- **D4 F2 措辞「多仓分立提交」三处逐字同源**（T3⑩ / T4 提交纪律 / T6 ADDED Requirement 名）。被否：各处意译。反例：F7 本身就是双源漂移实例——routing.md 两版本表内 provider 名各自演化出 `zai` vs `zai-coding-cn` 两套口径。
- **D5 F5 delta 形态 = ADDED 独立 Requirement「执行期沉淀回流」**（explore「可能 ADDED」不确定表述，decisions 未裁定，此处定形）。被否：并入「验证门与归档提交」MODIFIED——主规格现文（:120-126）不含任何汇报要素，该 Requirement 主题是验证与归档提交，并入使主题漂移。
- **D6 F4 连锁面模板写进主规格「执行期留痕与工件维护」MODIFIED 正文**。被否一：只进 skill 层——主规格已承载「以编号条目留痕」，条目格式是行为契约一半，分层反而制造 skill/spec 漂移面。被否二：连锁面独立成工件（explore 已否：加重执行负担，T3.1 R9~R11 证明条目内承载足够）。
- **D7 F7 范围 = 两侧（Q-A 裁定随本变更同改）**：执行侧三处（T5）+ 规划侧 schema 示例三处（T5b）；设计期实测发现规划侧 `refs/routing.md:9-11` 同款 `provider: zai` 简写漂移，上浮 Q-A 后用户裁定纳入。仍排除：两侧 pi-ai 数据路径 `{zai,...}.json`（真实文件名，事实引用）。
- **D8 任务分 3 组；组 1 经 Q-A 扩为 4 任务**（≤ 工作区 parallelism=8；yaml 值随 Q6 裁定落档后提交转正，无时序依赖——即便回到 3，4 任务仅并行度受限、批次契约不破）。被否一：T1~T5 五文件并一组（无依赖强行同批，审核粒度差）；被否二：每文件一组共 5 组（拖长审核节奏）。
- **D9 delta（T6/T7）与落档工件不设执行任务**——delta 随落档生成、随落档提交入库（planning.md 落档第 7 步只 add 变更目录），执行期不动 `openspec/`。被否：把 delta 写入列为执行任务——违反「落档工件单独提交一次」时序与归档同步主规格的职责边界（openspec-archive-change）。
- **D10 T3 五节改动合单任务 2.1、T4 六条目合单任务 2.2**（同文件不同节禁止同组拆任务，任务内部按 (a) 表逐处顺改）。被否：T3 的 F1② 与 F9 拆两组串行——同文件跨组无写冲突收益，徒增两个审核批次。

## ⑤ 逐任务组实现要点

（与 (c) tasks 全表一一对应；组间串行、组内并行、组内不写同一文件：组 1 = T1/T2/T5/T5b 四文件、组 2 = T3/T4 两文件、组 3 只读。）

**组 1**
- 1.1（T1）：只动 L100 ④步步内文本；①②③⑤⑥⑦⑧步名与文本零改动；`refs/planning.md` 链接写法与该节既有链接一致。
- 1.2（T2）：整步替换 L68，保留「不得带病落档」收尾；`test -f` 路径用 `openspec/changes/<change>/` 占位符（与全文风格一致）；「回到第 1 步」指本节第 1 步（生成四件套+复制两材料）。
- 1.3（T5）：三处仅替换 provider 名，行内注释/说明列字节不动；改后 L35-36 与 spec-plan 侧同表（`agent/skills/spec-plan/refs/routing.md:34-35`）逐字一致；**不得触碰 L28 的 `{zai,...}.json`**（真实数据文件名）。
- 1.4（T5b，Q-A 裁定新增）：仅替换 L9/L10/L11 三处 provider 名，行内注释不动；**:30 pi-ai 路径 `{zai,...}.json` 不触碰**；改后与本文件图片能力表及 yaml 实际值一致。
**组 2**
- 2.1（T3）：五处按 (b) 逐字落；两处步序重编号必须完整：恢复协议原 4/5/6 → 5/6/7（含编号数字本身），第七节原⑤⑥ → ⑥⑦（原④拆新④⑤）；第五节其余步文本不动；「汇报五要素」括注五项逐字。
- 2.2（T4）：六处按 (b) 逐字落；L36 原例（根仓工件、子仓代码）保留在新条目内；派发要点原 5/6 步重编号 6/7；总增量实测 ~580 码点（4768→~5350，余量 ~2500），若实测超 5500 须回查是否有文本走样。
**组 3**
- 3.1：单 python 脚本断言两件事——5 文件 `len()<=7849`；(b) 节全部锚点按 (c) 表预期计数（含 2.2 的 `连锁面=2`、T3 的 `openspec-verify-change=2`）。
- 3.2：三口径跨文件抽查（F2 三处 `多仓分立提交` 各 =1、F1 双侧「落档副本」表述在场：spec-plan SKILL.md 既有 L22「落档副本为权威」未删 + spec-workflow SKILL.md 新增第 4 步）；`openspec validate spec-workflow-execution-hardening --strict` 退出码 0；提交前 `git status --porcelain` 快照比对，`agent/skills/spring-writer/SKILL.md` 与 `dsh/spec-workflow.yaml` 两行与本批开始前逐字一致。

## ⑥ 设计假设与未决项

- **A1** parallelism=8（`dsh/spec-workflow.yaml:36` 工作区实测值，Q6 裁定落档后单独提交使其转正）；即便未提交，本设计组内 ≤3 任务兼容 parallelism=3，无时序依赖。
- **A2** `openspec-verify-change` 实名已核：聚合层 `~/.agents/skills/openspec-verify-change` 存在，`agent/skills/` 下无重名副本——skill 文引用统一写 `openspec-verify-change`。
- **A3** 码点估算是 (b) 逐字文本长度的线性测算（±10%），以任务 3.1 的 python 断言为准；最紧文件 execution.md（~5350/7849）余量充足。
- **A4** MODIFIED 语义 = Requirement 全文替换：T6/T7 各 MODIFIED 块须承载原正文全部语义＋扩义句，原 Scenario 除新增外逐则保留（块格式先例见 ②）。
- **A5** 主规格本身超 7849（9224/10622）不构成问题——本变更不手改主规格（delta 随归档同步，仓惯例）。
- **A6** 两处既有脏改动（spring-writer/SKILL.md、spec-workflow.yaml）按 Q6 由执行方落档后单独提交；本变更批次 add 范围严格限 5 文件＋变更目录。
- **A7** F7 的 `:28` pi-ai 数据路径 `{zai,...}` 与 L38 报错原文中的 model 串均为事实引用，不在修正范围（任务 1.3 验证句已用精确 pattern 排除误伤）。
- 未决项：见「待决问题」Q-A/Q-B；其余设计自由度已在 ④ 裁定，无未答项。

## 待决问题（六字段之外）

> 落档分歧点提问已裁定（见 decisions.md「落档分歧点记录」）：**Q-A = 随本变更同改**（本文档 T5b/任务 1.4 已同步）；**Q-B = 已提交与未提交都列**（delta 措辞已按此预写）。前沿为空，无剩余待决项。
