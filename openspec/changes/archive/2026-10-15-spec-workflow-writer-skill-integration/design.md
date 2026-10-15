# Design

## 触达面

| # | 文件 | 改动意图 | 关键改动点 |
| --- | --- | --- | --- |
| T1 | `agent/skills/spec-workflow/refs/planning.md` | 1.7 节接 writer skill | 新增「栈识别与 writer skill 接线」小节（判据/双命中/未命中三选一/可加载性核对/结论记阶段摘要）；模板加「先加载 skill：<点名>」行；回执核对加第 ⑥ 条；三档分降补 L0 标注；落档 tasks 契约加粒度句 |
| T2 | `agent/skills/spec-workflow/refs/execution.md` | 两引擎派发接线 | subagent「提示自包含」清单 + team 任务卡内容各加 writer skill 加载指令（点名、沿用 1.7 结论）；§九 不动 |
| T3 | `agent/skills/spec-workflow/SKILL.md` | 入口最短标记 | §五 1.7 指针句加「（恒先加载栈对应 writer skill）」并扩「writer skill 接线」；§八 共同纪律加最短标记；合计 ≤53 码点、file ≤7849 |
| T4 | `agent/skills/spec-workflow/refs/failure-modes.md` | 失败处置两行 | 「栈识别未命中」→ 问用户三选一；「writer skill 加载失败」→ 处置顺序后仍失败报告问用户 |
| T5 | `dsh/README.md` | 文档同步 | 文件表 planning/execution 行、阶段 1.7 段、design 路由表行、阶段 3 引擎段补 writer 接线一句 |
| T6 | `openspec/specs/spec-workflow/spec.md` | 经 delta 同步（不手改） | ADDED 一个横切 Requirement（栈识别与 writer skill 加载，6 Scenario）+ MODIFIED 三个 Requirement（1.7 设计线／subagent 引擎／team 引擎）+ 2 个引擎级新 Scenario |

## 决策记录

**D1：栈识别由主会话做，结论沿派发提示传导。** 识别是只读证据判定（构建文件与依赖清单），主会话在阶段 1.7 派发前做一次、记入阶段摘要；阶段 3 不重复探测，直接沿用结论（接续恢复后无从取得则重识别一次）。被否方案：让设计子代理自行识别——主会话拿不到可核对证据，且「未命中问用户三选一」必须在派发前由主会话执行；被否方案二：阶段 3 各任务自行识别——每任务重复探测且可能与 1.7 结论漂移。

**D2：加载动作放在子代理侧，提示点名 skill 名。** fresh 子代理无本次对话上下文，提示内点名「先加载 skill：spring-writer」即自包含；聚合层 `~/.agents/skills/` 已含两 skill，子代理会话可按名加载。被否方案：主会话预读 writer skill 全文粘进提示——14644/10438 码点远超派发提示合理体积，且复制即双源；被否方案二：主会话替子代理加载——加载发生在子代理会话才有约束力，主会话加载只消耗自己上下文。

**D3：双源防控——引名不复述数值。** spec-workflow 侧只写 skill 名与「规范为设计/实现硬约束」定性，writer 的拆分粒度等具体数值（spring ≤10 文件、nuxt ≤8 文件）一律不复述，写「以所加载 writer skill 的规定为准」。新增 writer skill 时需人工同步 planning.md 的判据表——作为已知维护点接受，不做通用插件机制（当前仅两类栈，抽象成本大于收益）。

**D4：未命中问用户三选一（用户裁定）。** 指认现有 skill（含未来新增 writer skill，可点名任一聚合层 skill）／明确豁免本次加载并如实标注（豁免仅本次有效）／终止流程。不设硬门禁（未命中≠不支持，用户可豁免）；不允许静默跳过——与「不假设未给出的选项」红线同构。加载失败也不静默降级：先走既有处置顺序（登记核对 → `/commands-reload` → 重启兜底），仍失败报告问用户（区别于 `grill-me` 缺失允许降级——本条为「必须」级）。

**D5：L0（trivial）豁免派遣同时豁免加载，但断言必须标注。** L0 = 单文件 + 无接口变更 + 无逻辑分支变化，writer 约束（分层/拆分/复用）大概率无增量；强制主会话加载 1.4 万码点规范换一行断言不成比例。但断言须写「未触 writer 约束」，发现涉分层/拆分/接口即升 L1/L2 自然引入加载——豁免可审计、可升档，不是盲区。

**D6：入口标记以 53 码点为硬预算。** file+343 ≤8192 → file ≤7849，现 7796。首选两处最短标记（§五 指针句扩写 + §八 一句）；若超支，§八 完全外移（execution.md 已有「提示模板见 refs/execution.md」指针承载），只保 §五 标记——§五 是阶段 1.7 的入口权威句，标记不可全缺。frontmatter、12 节标题、红线表、恢复协议、中转协议、「绝不做」段不动。

**D7：横切契约独立成 ADDED Requirement，不并入 1.7 设计线需求。** 首版把栈识别/加载/未命中/trivial/粒度全部并入「阶段 1.7 代码设计线」，需求正文由 271 涨到 649 字符，触发 `openspec validate` 的 >500 字符告警（`--strict` 下即失败）。拆法：①新增「栈识别与 writer skill 加载（阶段 1.7 与阶段 3）」承载全部横切 SHALL 与其 6 个 Scenario；②1.7 需求只留一句指认（361/374 字符，均 <500）；③两执行引擎需求各加一句落点说明 + 1 Scenario；④「落档工件与执行批次契约」不再重复粒度句（单一来源在新需求）。被否方案：把判据与 trivial 细节塞进正文——告警根源，且场景本就是边缘情况的正确归属。

**D8：主规格只在归档时由 delta 同步。** 与历次变更一致；归档后逐字复核主规格 diff，确认 ADDED 1 + MODIFIED 3 之外的 Requirement 未被规整误改。

## 门禁

| 门 | 判据 |
| --- | --- |
| G1 结构 | `SKILL.md` `## ` 标题数 = 12；frontmatter 逐字节不变；全部 href 目标 `test -f` 通过 |
| G2 码点 | 六文件 ≤8192；`SKILL.md` ≤7849（本变更换新门限：file+343 ≤8192），渲染上界 ≤8192 |
| G3 接线 | planning.md 含「栈识别与 writer skill 接线」小节与模板加载行；execution.md 两引擎各含加载指令；failure-modes.md 两行新处置；回执核对第 ⑥ 条存在 |
| G4 运行时 | 会话内按名加载 `spec-workflow` 返回改后版本；`refs/` 五文件可见；聚合层 `~/.agents/skills/spring-writer`、`nuxt-writer` 存在 |
| G5 规格 | `openspec validate spec-workflow-writer-skill-integration --strict` 退出码 0 **且无告警**；归档后 `--all`/`--archived` 退出码 0 且主规格无 >500 字符告警 |
| G6 回归 | `tools/skctl`：`node --test 'test/*.test.ts'` 47/47 通过 |
| G7 提交 | 三次提交（落档/实现/归档）显式 `git add`，`dsh/profiles/web/cordis.patch.yml` 不混入 |

## 风险与处置

- 入口两处标记超 53 码点 → 触发 D6 降级方案（§八 外移），不牺牲 §五 标记。
- 子代理会话缺 `skill` 工具或加载报错 → 子代理按中转协议上浮 TOP 待决项，主会话按 failure-modes 处置顺序修复或问用户；不视为流程失败。
- 双栈同仓时两侧规范冲突（分层归属）→ 各侧触达面各用各的 writer 约束，冲突点按设计线上浮待决，不在 skill 层硬编码优先级。
- `openspec archive` 规整误改其他 Requirement → 归档后逐字复核主规格 diff，异常即回退归档提交修正。
- 回滚：`git revert` 三次提交即可完全还原（改动集中在 5 个文件 + 变更目录）。
