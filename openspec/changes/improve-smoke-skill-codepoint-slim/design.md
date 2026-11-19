# Design

## Context（已核实事实）

- 基线 commit `fdddebd91b7f9751bedf3a77d599719308d68a4b`（2026-11-19）；实存 SKILL.md 199 行 / reference.md 584 行 / project-profile-template.md 94 行 / 主规格 spec.md 95 行（7 Requirements / 12 Scenario）
- 全仓 grep（排除 archive）：指向本 skill 文档的**活行号引用仅** add-ui-demo-gate 的 4 处（tasks.md:5、code-design.md:100/215/416），全部指向 `SKILL.md:30-34` 与 `reference.md:19`；实测 `reference.md:19` **不在** spec 字面冻结区 L1–18 内（§1.1 代码块第 19 行）
- 主规格既有 7 条 Requirements 之间无文字重复（重复在 skill 文档内部，不在 spec 侧）
- `openspec validate --all --strict` 基线已因 spec/spec-plan 长文本警告 exit 1（非本变更引入）→ 验证一律定向
- 分发为 symlink（`~/.agents/skills/smoke-testing-local-env` → dotfiles 实体），改完即时生效
- 探索与收敛材料：`/tmp/spec-flow/improve-smoke-skill-codepoint-slim/{explore.md,decisions.md}`（explore 不入库；decisions.md 与 code-design.md 复制入本目录，落档副本为权威）

## 触达面

**全部在 dotfiles 根仓**（逐路径与关键改动点，全文见 [code-design.md](code-design.md) ①，含负面清单）：

| 文件 | 改动 | 行数账 |
| --- | --- | --- |
| `agent/skills/smoke-testing-local-env/SKILL.md` | 阶段 4 +1 条码点指路；S1 模式表 4→3 行 / S2 纪律 4→2 / S3 三层证据表并 1 行 / S4 回写并入通过公式 | 199 → 188 |
| `agent/skills/smoke-testing-local-env/reference.md` | 新增 §3.7（四行检查表）；§5.2 +长度边界行；§8 +#24/#25；S5 §9 表→3 行指路；S6 §6.4/§7.2 去双写 | 584 → 583 |
| `agent/skills/smoke-testing-local-env/project-profile-template.md` | §3 +「字符集/排序规则」行 | 94 → 95 |
| `openspec/specs/smoke-testing-local-env/spec.md` | 归档 sync 追加第 8 条 Requirement + 2 Scenario（仅 ADDED） | 95 → 约 109 |

**零触达**：scripts/recon.sh、scripts/tcp-bridge.mjs、Top 12 陷阱表、主规格既有 7 条、add-ui-demo-gate 目录、agent/skills/README.md、tools/skctl。

## 接口与数据形状

文档变更，本字段承载**文档结构契约**（定稿块全文见 code-design.md ③3.2–③3.5，行数账见 ③3.1）：

- **§3.7「多字节字符与码点口径」**：三列表 `| 检查点 | 怎么查 | 判据 / 处置 |` × 4 数据行（DB 字符集 / 计数单位 / 落库完整性 / 截断显示）；插入点 = §3.6 之后、`## 4.` 之前（L174/175 之间）
- **计数单位按层写精确**（修正探索稿「后端字节」的简化）：前端/Java `length` = UTF-16 code unit（emoji 计 2）；DB `VARCHAR(n)`/`char_length` = 码点；索引与报文按 UTF-8 字节
- **§5.2 新行**：`| 长度边界 | 按被测层计数单位取上限 / 上限+1（前端 code unit、DB 码点、字节上限） | 业务错误码 |`
- **§8 #24/#25**：四列陷阱行（字符集 utf8mb3 静默截断 / 计数单位错配），各指向 §3.7
- **模板 §3 新行**：`| 字符集 / 排序规则 | 例：utf8mb4_general_ci（可存 emoji/生僻字）；若为 utf8（= utf8mb3），4 字节字符用例预期受限（技能 reference §3.7） |`
- **第 8 条 Requirement**：4 个 SHALL（确认前置 / 字符集判环境限制 / 计数单位构造 / 落库逐字符比对）；delta 文件仅 `## ADDED Requirements` 包裹（无 Purpose，按归档先例）

## 决策记录

全文 D1–D15（各含被否方案与反例）见 [code-design.md](code-design.md) ④；此处记**裁决与豁免**：

- **D-栈识别**：`writing-skills`（用户指认，触发面「editing existing skills」命中；上次同类变更按「三 writer 均不命中」豁免且仅当次有效，本次重新识别）。采用其「消除重复 / 交叉引用 / 重参考外移」三技法为瘦身硬依据；其「<500 words 入口」「description 只写触发条件」与冻结区冲突时**冻结区优先**（SKILL.md L1–60 跨变更契约 > 局部长度目标）
- **D-Q1 压测豁免**：不补 RED/GREEN 子代理压测。依据：本次为事实补全 + 结构槽位 + 去重，非新增纪律；失效形态是「遗漏」而非「压力下违规」，按 writing-skills 的 Match the Form to the Failure，模板字段/矩阵行/陷阱行（结构）是正确形态；可判定性由 spec 2 Scenario + 真实冒烟复测承担（用户已裁决）
- **D-Q2 spec 括号冲突**：主规格「文档结构兼容约束」中「只新增 §6.1–§6.5」按**历史时点解释**为上次变更 delta 范围记录，非永久白名单；本变更不改既有 7 条，§3.7 为子节新增、既有节号零缺失（用户已裁决；备选 MODIFIED 改写因复测标准漂移风险被否）
- **D-Q3 断言上扩**：reference 冻结断言从 L1–18 上扩至 **L1–174**（首个插入点 L175 之前逐字节不变），V2b 一次覆盖 L1–18 与 L19 活引用，另留 V2c 单点断言（事实修正，用户已裁决）
- **D-验证基线**：全部冻结 diff 断言 pin `BASE=fdddebd`（防「先提交后验证」假绿，D12）；validate 定向不用 `--all`
- **D-归档形态**：只 ADDED 追加（既有 7 条逐字不动，删除列=0 为硬断言）；第 8 条落在文件末尾（工具行为），不为此改用 MODIFIED 重排
- 执行环境：直用主工作区（衔接点用户裁决）。判据虽命中「主工作区有无关脏改动 `dsh/profiles/web/`」，但触达面全部位于根仓=工件仓，worktree.md「根仓不建 worktree」→ 隔离无可建对象；该脏改动全程不触碰且被 V15 允许范围覆盖。无 worktree、无环境错开、非装载类（symlink 分发即时生效）。创建于 2026-11-19

## 逐任务组实现要点

四组**严格串行**，与 tasks.md `## 1.–## 4.` 一一对应；实现一律**锚点字符串编辑**（禁按行号 sed -i），每完成一处编辑立即跑 V1/V2 冻结断言：

1. **组 1 码点五处**（1.1 §3.7 / 1.2 §5.2 行 / 1.3 §8 两行 / 1.4 模板行 / 1.5 SKILL 指路句）
2. **组 2 瘦身六处**（2.1 §9 / 2.2 §6.4+§7.2 / 2.3 S4 / 2.4 S3 / 2.5 S2 / 2.6 S1；自下而上避免行号漂移干扰核对）
3. **组 3 全量断言**（V1–V15：冻结区 / 节号集合 / 新增结构 / 瘦身形态 / 行为零变更关键字 / 交叉引用 / 零触达 / validate 定向 / 工作区范围）
4. **组 4 sync 与归档**（提交实现 → `openspec archive --yes` → 归档后断言 V14 → 提交归档）

验证映射 V1–V15 全部为可复制命令，全文见 [code-design.md](code-design.md) ⑤验证映射。

## 设计假设与未决项

A1–A12 全文见 [code-design.md](code-design.md) ⑥（基线/锚点编辑/行数预测/技术事实/MySQL 为主/validate 定向依据/ADDED 追加行为/symlink 分发/压测豁免/工件清单/副本同字节）。**未决项：无**——阶段 1.5 三项（变更名/spec 形态/Top 12）与阶段 1.7 三项（压测豁免/spec 括号解释/断言上扩）均已收敛。

## Risks / Trade-offs

- 压缩误伤关键句（如 S1 丢「歧义必问」）→ V6/V10 关键字断言 + 行为零变更人工对照兜底
- 终态行数偏差 >2 行说明定稿块被改写 → tasks 附录留痕回查 ③
- reference 总行数基本持平（−1）是**接受的结构性取舍**：瘦身腾出的 15 行容纳码点 14 行；进一步变短（§4 外移等）属结构性重构，会动节号引用面，须另开变更
- utf8mb3 行为随 sql_mode 分严格（报错）/非严格（静默截断）→ §3.7 表述写「报错或静默截断（视 sql_mode）」避免绝对化

---

## 附：阶段 1.75 界面演示（判定）

未触发：本变更触达对象为 skill 三文档、主规格与 openspec 工件，全是 markdown，无页面/组件/布局/视觉改版——C1（界面产出）不成立，命中「纯文档/配置/脚本」排除行，不产出演示、不进入确认环节。
