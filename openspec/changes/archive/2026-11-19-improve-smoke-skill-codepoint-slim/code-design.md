# improve-smoke-skill-codepoint-slim · 代码级蓝图（阶段 1.7）

> 设计对象：dotfiles 根仓 `agent/skills/smoke-testing-local-env/` 三份文档 + 主规格（HEAD `fdddebd91b7f9751bedf3a77d599719308d68a4b`，2026-11-19；实存 SKILL.md 199 行 / reference.md 584 行 / project-profile-template.md 94 行 / `openspec/specs/smoke-testing-local-env/spec.md` 95 行）。
> 输入：`explore.md`（7 字段草案）+ `decisions.md`（Q1–Q3 已决，视同预置参数，本文件不重开）。
> 本文件是阶段 1.7 的唯一产物，**不写任何项目文件**。文内行号均为**改动前 HEAD 行号**；执行一律用**锚点字符串**匹配（`edit` 工具），禁止按行号 `sed -i` 插入（前置插入会漂移，见 ⑥A2）。
> 栈识别：`writing-skills`（用户指认，触发面「editing existing skills」命中）。其**渐进式披露、长度控制、结构约定**是瘦身六处的硬依据；与冻结区冲突处按冻结区优先（D11）。

**五条设计不变量**（后续所有取舍以此裁决）：

1. SKILL.md **L1–60 逐字节不变、行数恒 60**；全部改动只在 L61 之后（含 L61 本身可动，但本次保留原样，见 V1d）。
2. reference.md **L1–174 逐字节不变**（严于任务书的 L1–18：首个插入点在 L175，上扩区间同时覆盖 `reference.md:19` 活引用），既有节号 §1–§9 一个不少，**只新增 §3.7**。
3. 主规格既有 **7 Requirements 逐字不变**（归档只追加第 8 条 Requirement + 2 Scenario，零删除、零改写）。
4. `scripts/recon.sh`、`scripts/tcp-bridge.mjs` **零改动**；SKILL.md「高频陷阱（Top 12）」表**零改动**（Q3）。
5. writing-skills 的「<500 words 入口」「description 只写触发条件」与冻结区冲突时，**冻结区优先**（D11），只采用其「消除重复 / 交叉引用 / 重参考外移」三条技法。

---

## ① 触达面清单

**全部在 dotfiles 根仓**（`/home/xuqinqin/develop/dotfiles`），无跨仓改动；参考仓 `~/develop/docker`、`~/develop/person/dsh-plugins` 零触达。

| 文件（仓） | 量级 | 改动意图 | 关键改动点 |
| --- | --- | --- | --- |
| `agent/skills/smoke-testing-local-env/SKILL.md`（dotfiles） | 中（199 → 188，−11） | 入口层补一条码点指路 + 四处保守去双写（S1–S4），触发即读成本下降 | ①阶段 4 数据准备 +1 条码点指路（唯一码点可见性，Q3）；②S1 模式表 4→3 数据行、删 intro、§6.1 指路折入歧义句（−3）；③S2 执行纪律 4→2 条（−2）；④S3 三层证据表+判定句并 1 行（−6）；⑤S4「回写」并入「冒烟通过」公式并删重复验收条（−1） |
| `agent/skills/smoke-testing-local-env/reference.md`（dotfiles） | 大（584 → 583，净 −1） | 补码点四行检查表 + 负例矩阵行 + 陷阱 #24/#25；同时消除 §9 映射表与 §6.4/§7.2 的双写（+14/−15） | ①新增 §3.7（4 行检查表，+11）；②§5.2 +长度边界行（+1）；③§8 +#24/#25（+2）；④§9 14 行映射表 → 3 行指路（−11，节号保留）；⑤§6.4 入库/忽略 4 条→2 条 + 清多余空行（−3）；⑥§7.2 3 条→2 条（−1） |
| `agent/skills/smoke-testing-local-env/project-profile-template.md`（dotfiles） | 小（94 → 95，+1） | 给码点口径一个**结构化落点**（画像字段），使「查字符集」成为填表动作而非记忆动作 | §3 数据存储表「库名」后 +1 行「字符集 / 排序规则」（两列，见 ③3.4） |
| `openspec/specs/smoke-testing-local-env/spec.md`（dotfiles） | 小（95 → 约 109） | 归档 sync 新增第 8 条 Requirement「多字节字符口径」+2 Scenario；既有 7 条逐字不动 | 只在文件末尾追加（见 ③3.5）；Requirement 含 4 个 SHALL（确认前置 / 字符集判定 / 计数单位构造 / 落库完整性） |
| `openspec/changes/improve-smoke-skill-codepoint-slim/`（dotfiles，**新建**） | 新建 6 文件 | openspec 落档工件 + spec delta，承载本蓝图的提案/设计/任务/收敛留痕 | `proposal.md`、`design.md`、`tasks.md`、`decisions.md`（复制 /tmp 收敛留痕）、`code-design.md`（本文件）、`specs/smoke-testing-local-env/spec.md`（仅 `## ADDED Requirements`） |

**负面清单（零触达，附理由）**：

| 对象 | 理由 |
| --- | --- |
| `agent/skills/smoke-testing-local-env/scripts/recon.sh`、`scripts/tcp-bridge.mjs` | 硬约束零改动；脚本内嵌帮助虽与 reference §2 重复，但脚本独立可用性 > 去重收益（explore 取舍已定） |
| `SKILL.md`「高频陷阱（Top 12）」表（L165–180） | Q3 已决：保持 12 条不动，码点可见性由阶段 4 指路句承担；扩 Top 13 会反向拉长入口 |
| `openspec/specs/smoke-testing-local-env/spec.md` L1–95（既有 7 Requirements） | 行为零变更；归档只做 ADDED 追加（D13） |
| `openspec/changes/add-ui-demo-gate/**` | 活跃变更，其 `SKILL.md:30-34` 与 `reference.md:19` 引用必须保持有效；本变更不做任何编辑 |
| `agent/skills/README.md` | 只登记来源列（L32），不含能力描述，无新增 skill |
| `tools/skctl/**`、`dsh/**`、其他 skill | 纯文档变更，无代码/分发动作；skctl 只校验 frontmatter（name==目录名），本变更不动 frontmatter |

**新建/移动产物（本变更内定义形状，不在 ① 之外扩面）**：

| 路径 | 时机 | 内容契约 |
| --- | --- | --- |
| `openspec/changes/improve-smoke-skill-codepoint-slim/{proposal,design,tasks,decisions,code-design}.md` | 阶段 2 落档 | 标题契约见 ③3.6；`decisions.md` 为 `/tmp/spec-flow/.../decisions.md` 原样复制，`code-design.md` 为本文件复制 |
| `openspec/changes/improve-smoke-skill-codepoint-slim/specs/smoke-testing-local-env/spec.md` | 阶段 2 落档 | `## ADDED Requirements` + 第 8 条 + 2 Scenario（③3.5） |
| `openspec/changes/archive/<YYYY-MM-DD>-improve-smoke-skill-codepoint-slim/` | 阶段 4 `openspec archive` | 上述整目录移动，日期由 CLI 取归档当天（不硬编码） |

---

## ② 证据锚

每条锚点摘自 HEAD 原文；新建文件标「新建」。**行号为 HEAD 版本**。

| # | file:line（仓 = dotfiles） | 原文（摘录） | 支撑的设计判断 |
| --- | --- | --- | --- |
| 1 | `agent/skills/smoke-testing-local-env/SKILL.md:30-34` | MCP 降级表：`\| 缺失 \| 降级方式 \| 证据缺口 \|` … `\| dbx \| 请用户在宿主执行 SQL 回传结果 \| 持久层证据缺失 \|` | `add-ui-demo-gate` 的活行号引用（#24–#27），位于 L1–60 冻结区，本次不动 → 自动有效（V1c） |
| 2 | `SKILL.md:61` | `## 两种冒烟模式：全量 smoke 与单任务 smoke` | S1 落点；改后仍须在第 61 行（L1–60 未越界的直接证据，V1d） |
| 3 | `SKILL.md:63` | `用例库与运行记录固定在所测项目根 smoke/（路径可由项目画像 §9 覆盖），格式与纪律见 reference §6；模式判定与「受影响条目」筛选的详版见 reference §6.1。` | S1 删此 intro；其中 §6.1 指路折入 L72 歧义句（不丢交叉引用），`smoke/` 位置由阶段 3 步骤 2/4/5 承载 |
| 4 | `SKILL.md:65-70` | 表头 `\| 维度 \| 全量 smoke \| 单任务 smoke \|` + 4 数据行（触发话术/用例范围/用例库缺失/收尾动作） | S1 压到 3 数据行；删「用例库缺失」行（阶段 3 步骤 2 已写「无则按 A–G 建库」，非独有信息） |
| 5 | `SKILL.md:72` | `话术有歧义（既有任务号又说"全量"）→ 问用户一句，不自行猜，确认前不建运行目录。` | S1 保留原句，句末追加 `；模式判定与「受影响条目」筛选详见 reference §6.1。`（0 新增行） |
| 6 | `SKILL.md:118-124` | 阶段 4 五条，末条为「数据带可检索前缀」条（L124） | 码点指路句插在该条之后（唯一码点入口，+1 行）；该插入点在 L61 之后，合法 |
| 7 | `SKILL.md:128-133` | `**执行纪律**（详版见 reference §6.5）：` + 4 条 bullet | S2 压 2 条；§6.5 已含 6 条完整版（六条权威不动） |
| 8 | `SKILL.md:146-152` | 三层证据表（UI/网络/持久化 3 行）+ `"页面提示成功"或"接口 200"单独都不构成通过。` | S3 并 1 行：三层语义 + 判定句 + `reference §5.1` 指路；§5.1 已有同表（双写来源） |
| 9 | `SKILL.md:184` | `- 冒烟通过 = 所选用例在运行记录中全部有结果且无失败项 + 三层证据齐全 + 工作区洁净` | S4 追加 `+ （单任务）新用例已回写`，与 spec「逐项执行纪律」的验收公式对齐（#22） |
| 10 | `SKILL.md:189` | `- 单任务新增/修订用例未回写 smoke/cases.md → 未回写不算完成，不得勾选` | S4 删除；语义并入 L184 公式，收尾清单 L199 仍保留可执行勾选项 |
| 11 | `SKILL.md:165-180` | `## 高频陷阱（Top 12，全表见 reference §8）` + 12 数据行 | Q3 冻结不动；V9b 逐字节 diff |
| 12 | `reference.md:1-18` + `:19` | 头引用两行 + `dsh 容器（agent + 浏览器）` … 浏览器行 `chrome-devtools-mcp 运行在容器内 → localhost 是容器自己` | L1–18 冻结；**L19 实测不在 L1–18**（见 Q3），用 L1–174 上扩保护，V2b/V2c 双断言 |
| 13 | `reference.md:169-173` | `### 3.6 dbx 使用纪律` + 3 条（末条 `落库核验要查状态机字段 + 时间戳…`） | §3.7 的唯一合法插入点：§3 末尾、`## 4.` 之前（L174 空行后） |
| 14 | `reference.md:175` | `## 4. 浏览器操作配方` | 插入锚点字符串（`edit` 以 `## 4. 浏览器操作配方` 前的空行定位） |
| 15 | `reference.md:305-312` | §5.2 负例矩阵表头 `\| 用例类型 \| 变更方式 \| 期望 \|` + 6 数据行（含 `\| 边界值 \| 截止时间 = 当天 \| 业务错误码 \|` 在 L309） | 长度边界行插在「边界值」之后，保持「边界 → 长度边界 → 层级/枚举」的聚类 |
| 16 | `reference.md:543-569` | `## 8. 陷阱全表` + #1–#23（末行 #23 在 L569） | +#24 字符集、#25 计数单位；V4 断言数据行 = 25 |
| 17 | `reference.md:571-584` | `## 9. 项目画像字段` + 8 行映射表（`\| 画像字段 \| 采集方式（§1.2） \|`） | S5：整表 → 3 行指路；保留模板入口与 3 条模板/§1.2 未覆盖的采集来源（账号与凭据、已知坑、日志归属由模板承载） |
| 18 | `reference.md:472-488` | `入库与忽略：` + 4 条（入库清单 / 截图忽略 lead-in + 7 行 glob / 忽略规则落点 / report.md 落盘） | S6：忽略规则落点并入 lead-in，删 report.md 落盘条（已由新 §7.2 承载）→ 4→2 条 |
| 19 | `reference.md:513-517` | `### 7.2 归档位置` + 3 条（默认收纳 / 画像 §9 覆盖 / 存量约定） | S6：3→2 条，画像覆盖与存量约定合并；spec「归档与洁净核验兼容」语义逐项保留 |
| 20 | `project-profile-template.md:36-44` | `## 3. 数据存储` + 表头 `\| 项 \| 值 \|` + 5 数据行（「库名」行在 L41） | 字符集/排序规则行插在「库名」之后（+1，V5） |
| 21 | `openspec/specs/smoke-testing-local-env/spec.md:90` | `skill 三文档改造 SHALL 保持既有节号与行号引用有效：… SKILL.md L1–60 仅允许 L3（description）与 L11（六阶段→七阶段概述）两处同行替换…；reference.md L1–18 逐字节不变且既有节号一个不少（只新增 §6.1–§6.5）…` | 既有 7 条零变更；括号「只新增 §6.1–§6.5」的历史时点解释见 Q2 |
| 22 | `openspec/specs/smoke-testing-local-env/spec.md:67` | `…冒烟通过 = 所选用例在运行记录中全部有结果且无失败项 + 三层证据齐全 + 工作区洁净（预期入库改动白名单内）+（单任务）新用例已回写…` | S4 把 SKILL 公式补齐为该口径，避免入口文档与规格分叉 |
| 23 | `openspec/specs/smoke-testing-local-env/spec.md:95` | 文件末行 `- **THEN** SKILL.md L1–2、L4–10、L12–60 与 HEAD 逐字节一致…` | 第 8 条 Requirement 的追加点（L95 之后） |
| 24 | `openspec/changes/add-ui-demo-gate/tasks.md:5` | `含①降级表体例与容器内浏览器事实（agent/skills/smoke-testing-local-env/SKILL.md:30-34、reference.md:19）` | 活引用来源①；V1c/V2c 的直接验收对象 |
| 25 | `openspec/changes/add-ui-demo-gate/code-design.md:100` | `reference.md:19——「chrome-devtools-mcp 运行在容器内 → localhost 是容器自己」… SKILL.md:30-34——MCP 缺失时的降级表体例` | 活引用来源②（同文件 `:215`、`:416` 同形） |
| 26 | `tools/skctl/src/doctor.ts:56-65` | `parseFrontmatter(...)` 失败 → `invalid: … (bad frontmatter)`；`fm.name !== name` → `invalid: …` | 本变更不动 frontmatter（L1–4 冻结），skctl 无回归 |
| 27 | `agent/skills/README.md:32` | `\| smoke-testing-local-env \| 自写（本目录 local symlink） \|` | 零触达；分发为 symlink 实时生效，无构建步骤 |
| 28 | `agent/skills/smoke-testing-local-env/scripts/recon.sh:1` / `scripts/tcp-bridge.mjs:1`（157 / 119 行） | `#!/usr/bin/env bash` / `#!/usr/bin/env node` | 零改动，V9a 的 `git diff --quiet` 对象 |
| 29 | `openspec/changes/improve-smoke-skill-codepoint-slim/{proposal,design,tasks,decisions,code-design}.md` | **新建** | 格式锚：`openspec/changes/add-ui-demo-gate/proposal.md:3`（`## Why`）、`design.md:5`（`## Context（已核实事实）`）、`tasks.md`（`## N.` + `- [ ] N.M`） |
| 30 | `openspec/changes/improve-smoke-skill-codepoint-slim/specs/smoke-testing-local-env/spec.md` | **新建** | delta 格式锚：`openspec/changes/archive/2026-10-14-spec-workflow-externalize-references/specs/spec-workflow/spec.md:3`（只有 `## ADDED Requirements`，无 `## Purpose`） |
| 31 | `openspec/changes/archive/<YYYY-MM-DD>-improve-smoke-skill-codepoint-slim/` | **新建（移动）** | 归档落位先例：`openspec/changes/archive/2026-11-19-update-smoke-skill-case-first/`（proposal/design/tasks/decisions/code-design/specs 六件套齐备）；`openspec archive` 由 CLI 加日期前缀 |

**活行号引用面（全仓 grep 复核，2026-11-19）**：排除 `openspec/changes/archive/**` 后，指向本 skill 文档的行号引用**仅** `add-ui-demo-gate` 的 4 处（`tasks.md:5`、`code-design.md:100/215/416`），全部指向 `SKILL.md:30-34` 与 `reference.md:19`；本设计用 V1c/V2c 逐点断言，V2b 用 L1–174 上扩兜底。瘦身导致的 L61 之后行号漂移**无外部消费者**。

---

## ③ 接口与数据形状

本变更为文档变更；本字段承载**文档结构契约**：定稿块、表头/列结构、行数账、新建工件的标题契约。

### 3.1 净效果核算（与 explore 估算对账）

| 文件 | HEAD | 码点 | 瘦身 | 预计 | 与 explore 估算的差异 |
| --- | --- | --- | --- | --- | --- |
| `SKILL.md` | 199 | +1 | −12（S1 3 / S2 2 / S3 6 / S4 1） | **188** | explore ≈186（−13）：S1 −3（估 −4）、S2 −2（估 −3）、S3 −6（估 −5）、S4 −1（同） |
| `reference.md` | 584 | +14（§3.7 +11 / §5.2 +1 / §8 +2） | −15（§9 11 / §6.4 3 / §7.2 1） | **583** | explore ≈587（+3）：§3.7 实测 10 行正文（估 15）、§9 −11（估 −10）、§6.4 −3（探索未计，含清空行）、§7.2 −1（估 −3） |
| `project-profile-template.md` | 94 | +1 | 0 | **95** | 同估 |
| 合计 | 877 | +16 | −27 | **866** | explore ≈868 |

**诚实口径**：SKILL 触发即读成本 −11 行；reference **基本持平（−1）**——瘦身腾出的 15 行容纳码点 14 行，收益是结构性的（双写消除、单点维护、码点误判有规程），不是 reference 变短。与 explore 的 1–3 行差来自「保留可读性/保留 §6.1 指路」的取舍（S1/S2）与 §6.4 清空行，已在下文逐条记录。

**边界说明**：reference 继续变短（如把 §4 浏览器配方外移为 `refs/`）属于**结构性重构**，会改变既有节号/引用面，超出「保守去双写」档位与本次冻结区约束，须另开变更；本变更的收益口径止于「双写归零 + 码点有落点」。

### 3.2 SKILL.md 定稿块（4 处瘦身 + 1 条码点指路）

**S1（替换 L61–72 整块，12 → 9 行，−3）**——删除 intro 段（L63）与其后空行；表 4→3 数据行；§6.1 指路折入歧义句：

```markdown
## 两种冒烟模式：全量 smoke 与单任务 smoke

| 维度 | 全量 smoke | 单任务 smoke |
| --- | --- | --- |
| 触发话术 | 全量冒烟、复测、回归、上线前验收 | 带任务号或里程碑（如"T2.1 冒烟""只验这个需求"） |
| 用例范围 | `cases.md` 全部在用条目（缺库先按 A–G 建库） | 受影响旧条目 + 本任务新用例（缺库先补齐再执行） |
| 收尾动作 | 运行记录汇总 + 报告 | 同上 + **新用例回写 `cases.md`（硬性）** |

话术有歧义（既有任务号又说"全量"）→ 问用户一句，不自行猜，确认前不建运行目录；模式判定与「受影响条目」筛选详见 reference §6.1。
```

**S2（替换 L128–133，6 → 4 行，−2）**：

```markdown
**执行纪律**（详版见 reference §6.5）：

- 按 `record.md` 的所选用例编号集顺序逐条执行，每跑完一条立即回填结果与证据，不跳号、不并发；单条失败记证据后继续，不中断整轮
- 无法构造的前置或未实现能力记 `N/A` 并给等效证据；执行中发现缺用例 → 先补进 `cases.md` 拿编号，再执行并回填
```

**S3（替换 L146–152，7 → 1 行，−6）**：

```markdown
三层证据缺一不可：UI（页面文本/状态 + 截图）、网络（端点、状态码、请求/响应体）、持久化（落库行含状态机字段、外部对象存在性）；"页面提示成功"或"接口 200"单独都不构成通过（详表见 reference §5.1）。
```

**S4（两处，净 −1）**：

```markdown
- 冒烟通过 = 所选用例在运行记录中全部有结果且无失败项 + 三层证据齐全 + 工作区洁净 + （单任务）新用例已回写
```

删除原 L189：`- 单任务新增/修订用例未回写 smoke/cases.md → 未回写不算完成，不得勾选`。

**阶段 4 码点指路（在 L124 `- 数据带可检索前缀…` 之后插入，+1）**：

```markdown
- 中文/emoji/生僻字数据先确认 DB 字符集与校验层计数单位，落库比对原值（reference §3.7）
```

### 3.3 reference.md 定稿块（§3.7 新增 + §5.2/§8 增量 + S5/S6 瘦身）

**§3.7（在 L174 空行后、`## 4. 浏览器操作配方` 前插入，+11 行含尾空行）**——四行检查表，三列 `| 检查点 | 怎么查 | 判据 / 处置 |`：

```markdown
### 3.7 多字节字符与码点口径

中文/emoji/生僻字在三层各有计数单位，先分清「环境限制」与「功能缺陷」：

| 检查点 | 怎么查 | 判据 / 处置 |
| --- | --- | --- |
| DB 字符集 | `show create table <表>;` 看 `CHARSET`（MySQL）；`utf8` 即 utf8mb3 | utf8mb3 遇 4 字节字符报错或静默截断（视 sql_mode）→ 判环境限制、记观察项，非功能缺陷 |
| 计数单位 | 前端/Java 的 `length` 为 UTF-16 code unit（emoji 计 2）；DB `VARCHAR(n)`/`char_length` 为码点；索引与报文按 UTF-8 字节 | 边界用例按**被测校验层**单位取上限 / 上限+1，断言同单位；单位不明先查校验代码 |
| 落库完整性 | dbx 查回原值逐字符比对，`char_length` 与 `length` 并看 | 变 `???`、空串或尾部乱码 → 先查字符集，不要先判业务缺陷 |
| 截断显示 | 看 UI 回显与导出的截断边界 | 半个字符的乱码尾巴 → 按缺陷记（渲染/导出按字节截断） |
```

**§5.2 增量（在「边界值」行 L309 之后插 1 行）**：

```markdown
| 长度边界 | 按被测层计数单位取上限 / 上限+1（前端 code unit、DB 码点、字节上限） | 业务错误码 |
```

**§8 增量（在 #23 行 L569 之后追加 2 行，四列 `| # | 陷阱 | 根因 | 规避 |`）**：

```markdown
| 24 | 中文/emoji 落库变 `???`、空串或尾部乱码 | 表/库字符集为 utf8mb3（`utf8`），4 字节字符报错或静默截断 | 先 `show create table` 看 `CHARSET`，判环境限制而非功能缺陷（§3.7） |
| 25 | 「限 50 字」长度边界负例全不生效 | 校验层计数单位错配（前端 UTF-16 code unit / DB 码点 / 字节） | 按被测层单位构造上限 / 上限+1（§3.7、§5.2） |
```

**S5（替换 L571–584，14 → 3 行，−11）**——映射表删除（字段定义归模板、采集方式归 §1.2），保留 3 条模板/§1.2 未覆盖的来源：

```markdown
## 9. 项目画像字段

字段定义与逐项取值见 [project-profile-template.md](project-profile-template.md)；采集方式对应 §1.2，「账号与凭据」另见项目 AGENTS.md 或前端请求层代码，「已知坑」来自历次冒烟报告的观察项。
```

**S6-a（§6.4「入库与忽略」4 → 2 条 + 清多余空行，−3）**：

````markdown
入库与忽略：

- `cases.md`、`record.md`、`report.md`、`smoke/.gitignore` **入库**。
- 截图/大文件直接放运行目录根（单层 glob 可忽略），由 `smoke/.gitignore`（模式相对 `smoke/` 解析）忽略，**不修改项目根 `.gitignore`**：

```text
runs/*/*.png
runs/*/*.jpg
runs/*/*.jpeg
runs/*/*.webp
runs/*/*.gif
runs/*/*.webm
runs/*/*.har
```
````

删除原「忽略规则写 `smoke/.gitignore`…」条（语义并入上式）与原「`report.md` 复用 §7.1 骨架，落盘在本次运行目录根（§7.2）」条（语义由新 §7.2 首条承载）；并删两条 bullet 留下的多余空行，保留代码块后一个空行与 `### 6.5` 分隔。

**S6-b（§7.2，5 → 4 行，−1）**：

```markdown
### 7.2 归档位置

- **默认：运行目录收纳**——每次运行一个目录 `smoke/runs/<YYYY-MM-DD>-<full|任务号>/`，`record.md`（逐项结果）、`report.md`（§7.1 骨架）、截图/网络导出都放该目录；入库与忽略口径见 §6.4。
- **画像 §9 覆盖**——项目画像 §9 若写明其他路径或忽略规则，以画像为准，本节只提供默认值；仍沿用 openspec 归档的项目属覆盖示例（浏览器报告 + 截图 → `openspec/changes/<change>/artifacts/`，gitignore 忽略；纯接口/构建类记录 → `<change>/smoke-record.md`，入库；无 openspec 的项目放约定的 `docs/` 或 `artifacts/` 并在画像写明）。
```

### 3.4 project-profile-template.md 定稿行（§3 表，+1）

在 ``| 库名 | 例：`opc` |``（L41）之后插入（两列 ``| 项 | 值 |``）：

```markdown
| 字符集 / 排序规则 | 例：`utf8mb4_general_ci`（可存 emoji/生僻字）；若为 `utf8`（= utf8mb3），4 字节字符用例预期受限（技能 reference §3.7） |
```

### 3.5 spec 主规格新增（归档 sync，第 8 条）

**位置**：`openspec/specs/smoke-testing-local-env/spec.md` L95 之后追加（openspec 的 ADDED 只追加到 Requirements 末尾，见 ⑥A8）。**标题与结构**如下（正文即归档后主规格终形态）：

```markdown
### Requirement: 多字节字符口径

测试数据含中文、emoji 或生僻字时，skill SHALL 在数据准备阶段先确认 DB 字符集与各校验层计数单位：字符集为 `utf8`（utf8mb3）时，4 字节字符的报错或截断 SHALL 判为环境限制并记观察项，不得判为功能缺陷；长度边界用例 SHALL 按被测校验层单位（前端/Java 为 UTF-16 code unit，DB `VARCHAR`/`char_length` 为码点）取上限与上限+1，MUST NOT 跨层换算；落库断言 SHALL 查回多字节原值逐字符比对。

#### Scenario: utf8mb3 表写入 emoji

- **WHEN** 目标表字符集为 `utf8`（utf8mb3）而用例需写入 emoji 或生僻字
- **THEN** 插入报错或值被静默截断时判为环境限制，记观察项并写明影响面，不记为功能缺陷；确需覆盖该能力时向用户确认改表或换库

#### Scenario: 长度边界负例全不生效

- **WHEN** 「限 50 字」的边界负例误按字节构造（51 字节 ≈ 17 个汉字）而全部提交成功
- **THEN** 先确认校验层计数单位（前端/Java `length` 为 UTF-16 code unit），按该单位重构造上限+1（51 个汉字）再断言业务错误码，不得直接判为校验缺失
```

**change delta 文件**（`openspec/changes/improve-smoke-skill-codepoint-slim/specs/smoke-testing-local-env/spec.md`）只加一层 `## ADDED Requirements` 包裹上述 Requirement 与 2 个 Scenario（无 `## Purpose`，按 #30 先例）；主规格的 7 条 Requirement 与 Purpose 零改写。

### 3.6 change 工件标题契约（新建）

```
openspec/changes/improve-smoke-skill-codepoint-slim/
├── proposal.md      # # Proposal → ## Why / ## What Changes / ## Capabilities（### Modified Capabilities: smoke-testing-local-env）/ ## Impact
├── design.md        # # Design → ## Context（已核实事实）/ ## 触达面 / ## 接口与数据形状 / ## 决策记录（D1–D15 摘要，全文见 code-design.md ④）/ ## 逐任务组实现要点 / ## 设计假设与未决项 / ## Risks / Trade-offs
├── tasks.md         # # Tasks → ## 1. 码点五处 / ## 2. 瘦身六处 / ## 3. 全量断言 / ## 4. sync 与归档；每条 - [ ] N.M 含「验证：<命令>」
├── decisions.md     # /tmp/spec-flow/improve-smoke-skill-codepoint-slim/decisions.md 原样复制
├── code-design.md   # 本文件原样复制
└── specs/smoke-testing-local-env/spec.md   # 仅 ## ADDED Requirements + 第 8 条 + 2 Scenario
```

### 3.7 新增/修改小节位置总表（HEAD 行号）

| 文件 | 位置 | 动作 | 行数 |
| --- | --- | --- | --- |
| SKILL.md | L61–72 | S1：删 intro、表 4→3 行、§6.1 折入歧义句 | −3 |
| SKILL.md | L124 后 | 阶段 4 +码点指路句 | +1 |
| SKILL.md | L128–133 | S2：4→2 条 | −2 |
| SKILL.md | L146–152 | S3：表+句 → 1 行 | −6 |
| SKILL.md | L184 / L189 | S4：公式补回写项 / 删重复验收条 | −1 |
| reference.md | L174/175 之间 | 新增 `### 3.7 多字节字符与码点口径`（插入点在 `## 4.` 前） | +11 |
| reference.md | L309 后 | §5.2 +长度边界行 | +1 |
| reference.md | L569 后 | §8 +#24/#25 | +2 |
| reference.md | L472–488 | §6.4 入库/忽略 4→2 条 + 清多余空行 | −3 |
| reference.md | L513–517 | §7.2 3→2 条 | −1 |
| reference.md | L571–584 | §9 映射表 → 3 行指路（节号保留） | −11 |
| project-profile-template.md | L41 后 | §3 +字符集/排序规则行 | +1 |
| spec.md | L95 后 | 归档 sync：第 8 条 +2 Scenario | +14（约 109 行） |

---

## ④ 决策记录

### D1 §3.7 落 reference §3 末尾（唯一新增节号）

- **决策**：码点检查表作为 §3 数据准备的子节 §3.7，位于 §3.6 dbx 纪律之后、`## 4.` 之前；**不新增顶级节**。
- **被否方案**：放 §5.2/§5.5（判定阶段）；放 SKILL.md 新小节；新增 §10。
- **理由**：字符集是数据准备事实，不是判定结论；放 §5 会在数据已写入失败/截断后才检查，要重跑；SKILL 新小节撞长度目标且与 reference 双写；新增 §10 违反硬约束「只新增 §3.7」。
- **反例**：若放 §5.2，负例矩阵用完才发现 utf8mb3 截断，测试数据与运行记录已污染，只能整轮重跑——正是本需求要防的浪费。

### D2 用「结构槽位」补码点，不写 prose 提醒（writing-skills「Match the Form to the Failure」）

- **决策**：五处落点全部是可填/可勾的结构槽位：§3.7 检查表 4 行、§5.2 矩阵 1 行、§8 陷阱 2 行、模板 §3 字段 1 行、SKILL 阶段 4 清单 1 行。writing-skills 明示：**遗漏型失效要用 REQUIRED slot/结构，而非「注意 X」式提醒**。
- **被否方案**：只加一段「注意多字节字符」的散文；把码点塞进 Top 12（Q3 已决不动）；新增独立脚本自动探测（违反脚本零改动）。
- **理由**：结构槽位在流程里必被填、必被读；散文提醒在长流程中会被跳过。writing-skills 对「遗漏型失效」明确要求槽位/契约，而不是禁令或提醒。
- **反例**：纯提醒会漏——没有模板字段就没有人填字符集；没有矩阵行，长度边界仍按「字数」硬凑；没有陷阱行，复测时不会联想到 utf8mb3 静默截断。

### D3 计数单位按「层」写精确，不写「后端字节」

- **决策**：写「前端/Java `length` = UTF-16 code unit；DB `VARCHAR(n)`/`char_length` = 码点；索引与报文按 UTF-8 字节」。
- **被否方案**：explore 草案的「后端字节（UTF-8 汉字 3 / emoji 4）」作为通用后端口径。
- **理由**：Java `String.length()` / `@Size` 数的是 UTF-16 code unit，不是字节；把「后端 = 字节」写死会把代理引向错误边界（按 50 字节 = 17 汉字构造「51 字」，负例自然不生效——正是陷阱 #25）。
- **反例**：按「字节」构造 51 字节（17 汉字）当「51 字」负例 → 被系统接受，误判「校验缺失」；实际是单位换算错。

### D4 五处即最小充分集

- **决策**：只补 DB 字符集、计数单位、落库完整性、截断显示四类，加矩阵/陷阱/模板/SKILL 指路。
- **被否方案**：全面版（jq/curl/grep 的中文处理、Unicode NFC/NFD 规范化、全角/半角、所有 DB 的等价 DDL 查询）。
- **理由**：最小充分集是用户三轮预裁决的档位；每加一类都要永久占用入口与参考的维护面，收益与命中率不匹配。
- **反例**：NFC/NFD 会让「生僻字显示不一致」的浏览器渲染问题被误导向数据层；大多数项目用不到，却永久占用触发成本。

### D5 S1 保留 3 数据行（触发话术/用例范围/收尾动作），删「用例库缺失」行

- **决策**：删 intro 段与「用例库缺失」维度，缺库处理折入「用例范围」两格；保留两模式唯一的行为差异行「收尾动作」。
- **被否方案**：删「收尾动作」行（阶段 7/验收/§6.1 都写了回写）；保留 4 行只删 intro（只省 2 行）；保留 intro 删表（丢掉扫读入口）。
- **理由**：「收尾动作」是两模式唯一不可由上下文推断的行为差异；缺库处理在阶段 3 步骤 2 已有完整表述。
- **反例**：删「收尾动作」后，模式表不再呈现「单任务多一步回写」的对照，而模式判定发生在阶段 3、回写核对在阶段 7——越晚发现越容易漏，恰恰是 spec 要求「硬性」的那条。

### D6 S2 压 2 条而非 1 条（保留空行）

- **决策**：4 条 bullet → 2 条，保留「标签行 + 空行 + 列表」的既有排版。
- **被否方案**：单条 bullet（−3 行）；无空行紧贴标签（−3 行）。
- **理由**：两条保留「顺序 + 回填」「失败不中断 / N/A / 补库」两个可执行单元，压缩率 33% 而扫读性不降。
- **反例**：单条 100+ 字多从句句子在扫读时与段落无异，「失败不中断」「缺用例先补库」两条最容易漏读；无空行排版则破坏全文件一致的列表体例。

### D7 S3 三层证据表并 1 行（含判定句）

- **决策**：表格 5 行 + 判定句 → 1 行，保留三层名与「200/提示 ≠ 通过」，指路 §5.1 详表。
- **被否方案**：保留表删判定句（只 −1，且丢掉真正起判定作用的那句）；保留 3 行 bullet（−2，仍是双写）。
- **理由**：三层证据表在 reference §5.1 有权威版本，SKILL 只需保留三层名与判定句；1 行是触发即读场景的最小可判定形态。
- **反例**：只留表删句，读者会把「有 UI/有响应」当成通过——三层证据的效力恰恰来自「单独都不构成通过」这句。

### D8 S4 把「回写」并入「冒烟通过」公式，再删重复验收条

- **决策**：L184 公式追加 `+ （单任务）新用例已回写`；删 L189「未回写不算完成，不得勾选」。
- **被否方案**：只删 L189（公式缺回写项）；只删收尾清单勾选项（失去可执行 checklist）。
- **理由**：验收公式是 spec 验收口径的镜像；公式补全后，重复的「不得勾选」条不再承载新信息。
- **反例**：只删 L189 后，SKILL 的「冒烟通过」不含回写，而 spec.md:67 的验收公式含「（单任务）新用例已回写」——入口文档与规格分叉，按 SKILL 勾选会漏（这正是 spec 要防的「未回写不算完成」）。

### D9 S5：§9 映射表 → 3 行指路，保留 3 条唯一来源

- **决策**：删 8 行映射数据（整节 14 行 → 3 行；字段定义归模板、采集方式归 §1.2），保留「账号与凭据 → AGENTS.md/请求层」「已知坑 → 历次报告观察项」两条模板/§1.2 没有的来源，外加模板链接。
- **被否方案**：整节删除（违反「既有节号一个不少」+ 丢模板入口）；保留表（双写不消除，字段改动要两处维护）。
- **理由**：映射表的字段侧已在模板、采集侧已在 §1.2；保留唯一来源，避免填画像时找不到出处。
- **反例**：整表删除只留「见模板」，填画像的人拿不到「账号凭据从哪来」「已知坑从哪来」，只能猜——这两条恰恰不在模板与 §1.2 里。

### D10 S6：§6.4 与 §7.2 的入库/忽略双写一起收

- **决策**：§6.4 忽略规则并入 lead-in（−1）、删 report 落盘条（−1）、清多余空行（−1）；§7.2 三条并两条（−1）；合计 −4。
- **被否方案**：只压 §7.2（−1，双写仍在 §6.4）；把入库/忽略整体搬到 §7.2（§6.4 定义目录树处失去就地规则，读者看目录树要跳 §7）。
- **理由**：§6.4 定义目录树与忽略 glob，§7.2 定义归档位置；把忽略规则落点留在 §6.4、把 report 落盘移到 §7.2，各归其位。
- **反例**：只改 §7.2 时，`smoke/.gitignore` 的落点规则仍两处维护，改一处漏一处；把规则整体搬到 §7 则「目录树 → 忽略 glob」被拆散。

### D11 writing-skills 的长度/描述规范与冻结区冲突 → 冻结优先

- **决策**：采用其「消除重复（Eliminate redundancy）」「交叉引用（Use cross-references）」「重参考外移（Separate files for heavy reference）」三技法；**不**按 <500 words 重写入口、**不**改 description（SDO 要求 description 只写触发条件，但现 L3 含流程概述且被冻结）。
- **被否方案**：为满足 <500 words 重写 L1–60；改 L3 去掉流程概述；把 Top 12 移到 reference 以再瘦身。
- **理由**：冻结区是跨变更契约（add-ui-demo-gate 的活引用）；长度目标是本 skill 的局部优化，局部让位契约。
- **反例**：重写 L1–60 会让 `add-ui-demo-gate` 的 `SKILL.md:30-34` 指到无关行，其 tasks 的验收证据链跨变更失效——本次硬约束正是禁止此点。

### D12 验证命令 pin 基线 commit，不用裸 HEAD

- **决策**：所有冻结/结构 diff 用 `BASE=fdddebd91b7f9751bedf3a77d599719308d68a4b`（设计时 HEAD），并在任务书要求的 `git show HEAD:` 形态之外并列给出。
- **被否方案**：直接用 `git show HEAD:`。
- **理由**：冻结断言的语义是「相对本次改动前」；一旦提交，HEAD 漂移会让断言失去意义。
- **反例**：若执行顺序是「先实现提交、后跑断言」，`HEAD` 已是新版，`diff <(git show HEAD:…) <(…)` 恒空——冻结区被破坏也验不出来（假绿）。

### D13 归档只 ADDED，既有 7 Requirements 零改写

- **决策**：delta 只写 `## ADDED Requirements`；主规格 L1–95 逐字不动，第 8 条追加在 EOF。
- **被否方案**：用 MODIFIED 重排（把第 8 条插到「文档结构兼容约束」之前）；顺带压缩既有 Requirement 的文字重复。
- **理由补充**：既有 7 条之间没有可删的重复表述（重复在 skill 文档内部，不在 spec），所以「只去文字重复」在本变更里没有 spec 侧落点。
- **反例**：用 MODIFIED 重抄既有 Requirement，任何措辞微调都会被 openspec 当作新基线，复测的验收标准悄悄变化；而 spec 是权威源，压缩文字的收益远小于漂移风险。

### D14 不新增脚本/测试

- **决策**：纯文档改动，验证靠 shell 断言；不写字符集探测脚本、不加 CI。
- **被否方案**：新增 `scripts/check-codepoint.mjs`；给 skill 加 markdown lint 任务。
- **理由**：纯文档变更的可验证性由 shell 断言 + `openspec validate` 覆盖；新增脚本反而引入第二权威源与维护面。
- **反例**：脚本会变成第二份「权威口径」，且 DB 字符集只能在目标环境探测；脚本目录本次是硬约束零改动。

### D15 第 8 条形态 = 独立 Requirement + 2 Scenario（承接 decisions，不重开）

- **决策**：独立 Requirement「多字节字符口径」，2 Scenario（utf8mb3 写入 / 长度边界负例不生效）。
- **被否方案**：并入「逐项执行纪律」作 Scenario 补充。
- **理由**：独立 Requirement 可被单独 validate、单独定位失败，符合 decisions Q2 的可判定性要求。
- **反例**：并入后，「先查字符集」会被读成执行阶段动作，而它实际发生在数据准备（阶段 4）；复测时也无法单独定位这条能力的失败。

---

## ⑤ 逐任务组实现要点

四组**串行**：组 1 → 组 2 → 组 3 → 组 4，与 `tasks.md` 的 `## 1.–## 4.` 一一对应。实现一律用**锚点字符串**编辑（`edit` 工具按原文匹配），**不得按行号 `sed -i`**；每完成一处编辑**立即**跑 V1/V2 冻结断言（不积压，explore R4）。

**文风约束**：简体中文；沿用现有表格化写法、全角标点与 `§N` 引用；表格分隔行统一 `| --- |`；不引入 emoji、不写英文长句；新增表格行不得含未转义的内联竖线。

**瘦身依据（writing-skills 三原则 → 六处）**：S1/S2/S3/S4 命中「Eliminate redundancy + Use cross-references」——删的是与 reference §6.1/§6.5/§5.1 的重复表述，保留指向详版的交叉引用；S5 命中「Separate files for heavy reference」——8 行映射表本就属于模板文件，reference 只留指路与 3 条唯一来源；S6 命中「Eliminate redundancy」——§6.4 与 §7.2 对 `smoke/.gitignore`/report 落盘各写一遍。入口长度目标（<500 words）与冻结区冲突，按 D11 只做结构去重、不做重写。

### 组 1　码点五处（1.1–1.5）

1. **1.1 §3.7**：以锚点 `## 4. 浏览器操作配方` 定位，在其前一个空行之后插入 ③3.3 的 §3.7 块（含尾空行）。**完成判据**：V3（§3.7 恰 1 处、4 数据行、节号集合只多 `### 3.7`）+ V2b（L1–174 不变）。
2. **1.2 §5.2 行**：在 `| 边界值 | 截止时间 = 当天 | 业务错误码 |` 之后插入长度边界行。**完成判据**：`grep -c '^| 长度边界 '` = 1，且行号在「边界值」之后、「层级/枚举非法」之前。
3. **1.3 §8 两行**：在 `| 23 | 单任务新用例测完未回写用例库 | …` 之后追加 #24/#25。**完成判据**：V4（§8 数据行 = 25；`^| 24 |`、`^| 25 |` 各 1）。
4. **1.4 模板 §3 行**：在 ``| 库名 | 例：`opc` |`` 之后插入字符集行。**完成判据**：V5。
5. **1.5 SKILL 阶段 4 指路**：在阶段 4 末条（`- 数据带可检索前缀…记录全部主键与外部对象 key`）之后追加 1 条。**完成判据**：V6 末两条（阶段 4 bullet = 6；`reference §3.7` 存在）+ V1（L1–60 冻结）。

> **【执行终形态 · tasks 1.1/1.2/1.3 · 2026-11-19】** 组 1 已完成（映射见 tasks.md R1）。实测：§3.7 块 @reference L175–184（含尾空行 +11）、§5.2 长度边界行 @L321、#24/#25 @L582/583、SKILL 指路句 @L125、模板字符集行 @L42；行数 reference 598 / SKILL 200 / 模板 95；V1a'/V1b/V1d/V2a'/V2b/V2c/V3/V4 全绿，冻结区逐字节未动。此后行号整体漂移，编辑一律锚点字符串。

### 组 2　瘦身六处（2.1–2.6；先 reference 后 SKILL，组内自下而上以免内部行号漂移影响人工核对）

1. **2.1 S5 §9**：整块替换 L571–584 为 ③3.3 的 3 行；节标题 `## 9. 项目画像字段` 原样保留。**完成判据**：V7（§9 段 3 行、无表格、模板链接在）。
2. **2.2 S6**：先 §6.4（合并忽略规则、删 report 落盘条、清多余空行），再 §7.2（3→2 条）。**完成判据**：V8（§7.2 bullet = 2；§6.4 bullet = 2）。
3. **2.3 S4**：L184 行尾追加 ` + （单任务）新用例已回写`；删 L189 整行（含其前导 `- `，保留其后空行结构）。**完成判据**：V6 的公式句与 `未回写不算完成` = 0。
4. **2.4 S3**：L146–152 整块替换为 ③3.2 的 1 行。**完成判据**：V6（`| 层 | 证据 |` = 0；`三层证据缺一不可` 存在）。
5. **2.5 S2**：L128–133 整块替换为 ③3.2 的 4 行。**完成判据**：阶段 5 bullet = 8（2 纪律 + 6 浏览器要点）。
6. **2.6 S1**：L61–72 整块替换为 ③3.2 的 9 行；确认 L61 仍是 `## 两种冒烟模式…`。**完成判据**：V6（3 数据行、无「用例库缺失」、§6.1 指路）+ V1d（L61 = 61）。

> 组 2 全部完成后行数应为 SKILL 188 / reference 583（③3.1）；若偏差 >2 行，说明定稿块被改写，按 tasks 附录留痕并回查 ③。

> **【执行终形态 · tasks 2.1/2.2 · 2026-11-19】** 组 2 已完成。实测：SKILL 188（S4@L174 公式句+删 L190、S3@L142 并 1 行、S2@L126 4 行、S1@L61–69 九行）；reference 583（S6-a §6.4 14 行形态、S6-b §7.2 4 行、S5 §9 3 行）；冻结区 V1a'/V1b/V1d/V2b 每处编辑后复跑全绿；定稿块逐字节回验一致、偏差 0 行。阶段 5 bullet 断言收口口径见 tasks.md R2。

### 组 3　全量断言（3.1–3.5）

1. **3.1 冻结区**：V1 + V2（pin BASE）；显式覆盖 `SKILL.md:30-34`、`reference.md:19`。
2. **3.2 结构与新增**：V3（§3.7 + 节号集合）、V4（§5.2/§8）、V5（模板）。
3. **3.3 瘦身**：V6（SKILL 五处）、V7（§9）、V8（S6）。
4. **3.4 行为零变更**：V10（关键字清单）+ V12（交叉引用无悬空）+ V9b（Top 12 逐字节）。
5. **3.5 零触达与卫生**：V9a（脚本）、V11（表格 pipe 一致）、V13（`openspec validate` 定向，**不得用 `--all --strict`**——基线已有 `spec/spec-plan` 长文本警告导致 exit 1，见 ⑥A6）、V15（`git status` 范围）。

> **【执行终形态 · tasks 3.1/3.2/3.3 · 2026-11-19】** 组 3 全量断言 PASS（三只读任务并行，无写操作）：V1a'/V1b/V1c/V1d/V2a'/V2b/V2c 七条冻结断言全绿（sha256 双证）；V3–V12 全绿（含 V9b Top 12 逐字节、V10 关键字 7/7、V12 交叉引用 miss=0、V11 pipe 检测器自检防假绿）；V13a 定向 validate exit=0、V15 越界 0 行、V9a 脚本零改动；行数对账 SKILL 188 / reference 583 / 模板 95 零偏差。

### 组 4　sync 与归档（4.1–4.4）

1. **4.1 提交实现**：3 份目标 md（SKILL/reference/template）+ `tasks.md` 勾选 → `feat(skills): 冒烟 skill 补齐码点口径并保守去重`。提交前重跑组 3 全绿。
2. **4.2 归档**：核对 delta（③3.5）与最终文档措辞一致 → 确认 `tasks.md` 无 `- [ ]` → `openspec archive improve-smoke-skill-codepoint-slim --yes`（自动加日期前缀、自动 sync 主规格）。
3. **4.3 归档后断言**：V14（8 Requirements / 14 Scenarios / 既有非空行逐字 / `git diff --numstat` 删除列 = 0 / archive 目录存在 / 活跃目录消失）+ `openspec validate smoke-testing-local-env --type spec --strict`。
4. **4.4 提交归档**：归档目录移动 + 主规格 sync + tasks 终态 → `docs(openspec): 归档 improve-smoke-skill-codepoint-slim`。

> 阶段 2「落档」不在本组：proposal/design/tasks/decisions/code-design/spec delta 由落档流程按 ③3.6 生成并单独提交（`docs(openspec): 落档 improve-smoke-skill-codepoint-slim`），在组 1 之前完成。

### 验证映射（需求/不变量 → 具体命令或断言）

以下命令默认在 `/home/xuqinqin/develop/dotfiles` 执行。**基线必须 pin**（D12）：

```bash
cd /home/xuqinqin/develop/dotfiles
BASE=fdddebd91b7f9751bedf3a77d599719308d68a4b
F=agent/skills/smoke-testing-local-env/SKILL.md
R=agent/skills/smoke-testing-local-env/reference.md
T=agent/skills/smoke-testing-local-env/project-profile-template.md
S=openspec/specs/smoke-testing-local-env/spec.md
C=openspec/changes/improve-smoke-skill-codepoint-slim
```

**V1　SKILL.md 冻结区 + L61 边界 + 活引用**（任务书要求形态 + pin 形态并列）

```bash
# 任务书要求形态（未提前提交时 HEAD 即基线）
diff <(git show HEAD:agent/skills/smoke-testing-local-env/SKILL.md | sed -n '1,60p') \
     <(sed -n '1,60p' agent/skills/smoke-testing-local-env/SKILL.md) && echo "V1a 冻结区一致"
# 本设计口径（pin 基线，防"先提交后验证"假绿）
diff <(git show "$BASE:$F" | sed -n '1,60p') <(sed -n '1,60p' "$F") && echo "V1a' 一致"
test "$(sed -n '1,60p' "$F" | wc -l)" = 60 && echo "V1b L1–60 = 60 行"
diff <(git show "$BASE:$F" | sed -n '30,34p') <(sed -n '30,34p' "$F") && echo "V1c 活引用 L30-34"
test "$(grep -n '^## 两种冒烟模式' "$F" | cut -d: -f1)" = 61 && echo "V1d L61 未漂移"
```

**V2　reference.md 冻结区（L1–18 任务书口径 + L1–174 上扩 + L19 单点）**

```bash
# 任务书要求形态（HEAD 即基线时）
diff <(git show HEAD:agent/skills/smoke-testing-local-env/reference.md | sed -n '1,18p') \
     <(sed -n '1,18p' agent/skills/smoke-testing-local-env/reference.md) && echo "V2a 一致"
# 本设计口径（pin 基线 + 上扩）
diff <(git show "$BASE:$R" | sed -n '1,18p') <(sed -n '1,18p' "$R") && echo "V2a' 一致"
diff <(git show "$BASE:$R" | sed -n '1,174p') <(sed -n '1,174p' "$R") && echo "V2b L1–174 不变"
diff <(git show "$BASE:$R" | sed -n '19p') <(sed -n '19p' "$R") && echo "V2c reference.md:19 有效"
```

**V3　§3.7 与节号集合**

```bash
old=$(git show "$BASE:$R" | grep -oE '^#{2,3} [0-9]+(\.[0-9]+)?' | sort -u)
new=$(grep -oE '^#{2,3} [0-9]+(\.[0-9]+)?' "$R" | sort -u)
comm -23 <(printf '%s\n' "$old") <(printf '%s\n' "$new")                      # 无缺失
comm -13 <(printf '%s\n' "$old") <(printf '%s\n' "$new")                      # 期望仅 "### 3.7"
test "$(grep -c '^### 3\.7 多字节字符与码点口径$' "$R")" = 1
test "$(sed -n '/^### 3\.7 /,/^## 4\./p' "$R" | grep -cE '^\| (DB 字符集|计数单位|落库完整性|截断显示) ')" = 4
```

**V4　§5.2 行与 §8 全表**

```bash
test "$(grep -c '^| 长度边界 ' "$R")" = 1
test "$(sed -n '/^## 8\./,/^## 9\./p' "$R" | grep -cE '^\| [0-9]+ \|')" = 25
test "$(grep -c '^| 24 |' "$R")" = 1 && test "$(grep -c '^| 25 |' "$R")" = 1
```

**V5　模板 §0–§9 不变 + §3 新行**

```bash
diff <(git show "$BASE:$T" | grep -E '^## [0-9]') <(grep -E '^## [0-9]' "$T")  # 期望：无输出
test "$(grep -c '^| 字符集 / 排序规则 ' "$T")" = 1
test "$(sed -n '/^## 3\./,/^## 4\./p' "$T" | grep -cE '^\| .+ \| .+ \|$')" = 8   # 表头 + 分隔 + 6 数据
```

**V6　SKILL 五处（S1–S4 + 阶段 4）**

```bash
test "$(grep -cF '| 用例库缺失 |' "$F")" = 0
test "$(sed -n '/^## 两种冒烟模式/,/^## 核心原则/p' "$F" | grep -cE '^\| (触发话术|用例范围|收尾动作) ')" = 3
grep -qF '模式判定与「受影响条目」筛选详见 reference §6.1' "$F"
test "$(grep -cF '| 层 | 证据 |' "$F")" = 0 && grep -qF '三层证据缺一不可' "$F"
test "$(sed -n '/^### 阶段 5/,/^### 阶段 6/p' "$F" | grep -c '^- ')" = 8   # 2 纪律 + 6 浏览器要点
grep -qF '（单任务）新用例已回写' "$F" && test "$(grep -cF '未回写不算完成' "$F")" = 0
test "$(sed -n '/^### 阶段 4　数据准备/,/^### 阶段 5/p' "$F" | grep -c '^- ')" = 6
grep -qF 'reference §3.7' "$F"
```

**V7　§9 指路**

```bash
test "$(sed -n '/^## 9\./,$p' "$R" | wc -l)" = 3
test "$(sed -n '/^## 9\./,$p' "$R" | grep -cE '^\|')" = 0
grep -q 'project-profile-template.md' "$R"
```

**V8　S6（§6.4 与 §7.2）**

```bash
test "$(sed -n '/^### 7\.2 /,/^### 7\.3 /p' "$R" | grep -c '^- ')" = 2
test "$(sed -n '/^入库与忽略：/,/^### 6\.5 /p' "$R" | grep -c '^- ')" = 2
```

**V9　零触达**

```bash
git diff --quiet "$BASE" -- agent/skills/smoke-testing-local-env/scripts/ && echo "V9a 脚本零改动"
git status --short -- agent/skills/smoke-testing-local-env/scripts/           # 期望：空
diff <(git show "$BASE:$F" | sed -n '/^## 高频陷阱/,/^## 验收/p') \
     <(sed -n '/^## 高频陷阱/,/^## 验收/p' "$F")                              # Top 12 逐字节
```

**V10　行为零变更关键字清单**

```bash
grep -qF '| 编号 | 用例 | 类型 | 前置 | 步骤 | 期望结果 | 证据要求 |' "$R"
grep -qF '编号续接' "$R"
grep -qF '结果值域（固定 4 值）' "$R"
grep -qF '预期入库改动白名单' "$R"
grep -qF '话术有歧义' "$F"
grep -qF '单任务新用例已回写 `smoke/cases.md`' "$F"
grep -qF '临时环境已清理' "$F"
```

**V11　表格 pipe 一致（三文件，与基线比不新增坏行）**

```bash
pipe_err() {
  awk '
    /^\|/ {
      line=$0; gsub(/\\\|/,"",line); n=gsub(/\|/,"",line);
      if (!intable) { intable=1; base=n } else if (n != base) print FNR": "n" != "base;
      next
    }
    { intable=0 }
  '
}
for x in "$F" "$R" "$T"; do
  diff <(git show "$BASE:$x" | pipe_err) <(pipe_err < "$x") || echo "PIPE-DIFF $x"
done                                                                          # 期望：无输出
```

**V12　交叉引用无悬空（SKILL 的每个 §N 在 reference/模板有同名标题）**

```bash
miss=0
for n in $(grep -oE '§[0-9]+(\.[0-9]+)?' "$F" | sed 's/§//g' | sort -u); do
  if [ "$n" = 0 ]; then src="$T"; else src="$R"; fi
  grep -qE "^#{2,3} ${n//./\\.}([ .]|$)" "$src" || { echo "MISS §$n"; miss=1; }
done
test "$miss" = 0
```

**V13　openspec 严格校验（定向，不用 `--all --strict`）**

```bash
openspec validate improve-smoke-skill-codepoint-slim --strict && echo "V13a change 通过"
openspec validate smoke-testing-local-env --type spec --strict && echo "V13b 主规格通过"
```

**V14　归档后主规格与归档落位**

```bash
test "$(grep -c '^### Requirement:' "$S")" = 8
grep -q '^### Requirement: 多字节字符口径$' "$S"
test "$(grep -c '^#### Scenario:' "$S")" = 14                                # 既有 12 + 新增 2
test "$(git diff --numstat "$BASE" -- "$S" | cut -f2)" = 0                    # 删除行数 = 0
base_nonblank=$(git show "$BASE:$S" | grep -vc '^$')
diff <(git show "$BASE:$S" | grep -v '^$') <(grep -v '^$' "$S" | head -n "$base_nonblank")  # 既有文字零改动
ls -d openspec/changes/archive/*-improve-smoke-skill-codepoint-slim >/dev/null && echo "V14c 已归档"
test ! -d "$C" && echo "V14d 活跃目录已移走"
test "$(grep -c '^- \[ \]' openspec/changes/archive/*-improve-smoke-skill-codepoint-slim/tasks.md)" = 0
openspec validate smoke-testing-local-env --type spec --strict
```

**V15　工作区范围（允许脏项之外无输出）**

```bash
test -z "$(git status --short | grep -vE 'dsh/profiles/web/|agent/skills/smoke-testing-local-env/|openspec/specs/smoke-testing-local-env/|openspec/changes/improve-smoke-skill-codepoint-slim/|openspec/changes/archive/')"   # 期望：通过（无越界改动）
wc -l "$F" "$R" "$T" "$S"   # 期望 188 / 583 / 95 / 约 109（行数只记录，不作硬断言）
```

---

## ⑥ 设计假设与未决项

| # | 假设 | 依据 / 影响 |
| --- | --- | --- |
| A1 | 设计基线 = `fdddebd91b7f9751bedf3a77d599719308d68a4b`；工作区既有脏改动仅 `dsh/profiles/web/` 三文件，与触达面零重叠 | `git status` 实测；V15 排除该前缀 |
| A2 | 文内行号是 HEAD 行号，执行以锚点字符串定位；组 1 的 SKILL 插入（+1）会使 L125 之后整体 +1，组 2 自下而上避免人工核对时看错行 | 与 prior 变更同法；行号仅作证据锚 |
| A3 | 终态行数预测：SKILL 188 / reference 583 / 模板 95 / 主规格约 109 | 按 ③ 定稿块逐行计数；偏差 >2 行须留痕回查 |
| A4 | 技术事实：MySQL `utf8`=utf8mb3、utf8mb4 支持 4 字节；前端/Java `length` 数 UTF-16 code unit；MySQL `VARCHAR(n)`/`char_length` 数码点、`length` 数字节；索引与报文按字节 | explore A1（无需用户确认）+ D3 的精确化；**改写了 explore「后端字节」的简化表述** |
| A5 | 被测栈以 MySQL 为主（模板示例 `localhost@mysql5.7`）；其他 DB 的等价 DDL（如 PG `\d+`）不入最小充分集 | §3.7 的 `show create table` 标注「（MySQL）」，避免过度承诺 |
| A6 | `openspec validate --all --strict` 基线已失败：`spec/spec-plan` 两条 Requirement 超长警告在 strict 下计失败（exit 1，实测）；故 V13/V14 用定向命令 | 不是本变更引入；若用 `--all` 当门禁会永远红 |
| A7 | openspec v1.16.0；ADDED 在归档时按「保留原顺序 + 新块追加末尾」重建 Requirements 段；既有段已规范（块间单空行），预期重建后 L1–95 逐字节稳定、删除列 0 | 读 `dist/core/specs-apply.js` 的 `buildUpdatedSpec`；V14 的删除列 = 0 是硬断言，若失败须人工核对后留痕 |
| A8 | 第 8 条落在「文档结构兼容约束」之后（工具只能追加），语义顺序略odd 但 openspec 按标题引用，不影响可读性 | 与 D13 一致；不为此改用 MODIFIED 重排 |
| A9 | 分发：`~/.agents/skills/smoke-testing-local-env` 为 symlink 指向 dotfiles 实体，三文档改完即时生效、无构建步骤 | 实测 `readlink -f` → `/home/xuqinqin/develop/dotfiles/agent/skills/smoke-testing-local-env` |
| A10 | 本次不安排子代理 RED/GREEN 压测（见待决 Q1）；码点能力的可判定性由 spec Scenario + 结构槽位 + 后续真实冒烟复测承担 | writing-skills Iron Law 与收敛预算的张力，已显式上浮 |
| A11 | 变更目录不含 `explore.md`（按 prior 变更先例：只复制 decisions.md 与本 code-design.md） | 归档件清单实测（proposal/design/tasks/decisions/code-design/specs） |
| A12 | `code-design.md`/`decisions.md` 复制件与 `/tmp/spec-flow/.../` 同字节；归档后仍可在 archive 目录追溯 | 与 prior 变更一致 |

**未决项**：3 项，见下节；其余无待决。**与 explore 估算的 1–3 行差已在 ③3.1 逐项对账，不构成待决。**

---

## 待决问题（六字段之外）

### Q1　writing-skills 的「Iron Law」（编辑 skill 前须有失败测试）是否补做行为压测？

- **问题**：writing-skills 明确「NO SKILL WITHOUT A FAILING TEST FIRST」适用于新 skill 与**编辑**；本变更未安排子代理 RED/GREEN 压测，与收敛留痕的预算分配存在张力。
- **选项**：
  - **A. 不补（推荐）**：本次是事实补全 + 结构槽位 + 去双写，不是新增纪律或流程；失效形态是「遗漏」而非「压力下违规」，按 writing-skills 自己的 `Match the Form to the Failure`，用模板字段/矩阵行/陷阱行（结构）比散文提醒更有效；可判定性由 spec 的 2 个 Scenario 与后续真实冒烟复测承担。
  - B. 补一次 A/B 子代理压测：无 §3.7 vs 有 §3.7，喂「utf8mb3 表插 emoji 被判为功能缺陷」场景，产出 baseline 留痕。
- **推荐**：A。理由：收敛未分配该预算；变更不改变既有行为，只补事实与去重；结构槽位已是对「遗漏型失效」的正确形态。
- **影响面**：A 需在 `design.md` 记录豁免依据与「以 Scenario 代替压测」的判据；B 需在 tasks 增组 0/组 5 与一次子代理成本，且压测命中缺陷时要回改文案、延后归档。

### Q2　spec 既有「文档结构兼容约束」括号「只新增 §6.1–§6.5」与新 §3.7 的字面冲突

- **问题**：`openspec/specs/smoke-testing-local-env/spec.md:90` 的既有 Requirement 写「reference.md L1–18 逐字节不变且既有节号一个不少（**只新增 §6.1–§6.5**）」。本变更新增 §3.7；若把括号读作长期白名单，则字面冲突，而硬约束又要求既有 7 条零变更。
- **选项**：
  - **A. 按历史时点解释（推荐）**：该括号记录的是 2026-11-19 那次改造的 delta 范围，不是永久上限；本变更不改该 Requirement，只在 `proposal.md`/`design.md` 注明「§3.7 为子节新增、既有节号零缺失、既有 7 条逐字未动」。
  - B. 用 MODIFIED 重写该括号为通用规则（「新增节号限子节且不改既有编号」）：修改既有 Requirement 文本，违反「行为零变更」硬约束。
  - C. 放弃 §3.7，把码点并入 §5.2/§5.5：推翻阶段 1.5 已收敛的落点，且 §5 阶段检查太晚（D1 反例）。
- **推荐**：A。理由：不改规格权威文本、不重开收敛，且归档后 `openspec validate --type spec --strict` 仍通过（该 Requirement 是描述性历史约束，不校验节号集合）。
- **影响面**：A 无额外改动；B 需把 delta 扩为 MODIFIED 并重写既有 Requirement（行为面扩大、复测标准漂移风险）；C 需重开收敛并改本蓝图多处。

### Q3　`reference.md:19` 不在任务书所称「冻结区」内的表述差异

- **问题**：任务书称 add-ui-demo-gate 的两个活引用「均在冻结区内」；实测 `SKILL.md:30-34` 在 L1–60 内，但 `reference.md:19`（拓扑图浏览器行）**不在 L1–18**，而在 §1.1 代码块第 19 行。只断言 L1–18 时，L19 的有效性缺少直接覆盖。
- **选项**：
  - **A. 冻结断言上扩到 L1–174（推荐）**：§3.7 的首个插入点在 L175，L1–174 必然逐字节不变，V2b 一次覆盖 L1–18 与 L19，另保留 V2c 单点断言。
  - B. 严格按 L1–18 + 单点 L19 两条断言（等价安全，保护面更窄）。
- **推荐**：A。理由：不增加动作、只加强断言；且给未来「§3 内插入」留出明确边界（首次插入点必须 ≥L175）。
- **影响面**：A 无；B 同样满足硬约束，但若有人在 L1–174 内做微小插入，B 不会整体报警。

---

## 附：阶段 1.75 界面演示（判定）

未触发：本变更触达对象为 skill 三文档、主规格与 openspec 工件，全是 markdown，无页面/组件/布局/视觉改版——C1（界面产出）不成立，命中「纯文档/配置/脚本」排除行，不产出演示、不进入确认环节。

---

> 本文件落盘于 `/tmp/spec-flow/improve-smoke-skill-codepoint-slim/code-design.md`（未写任何项目文件）；阶段 2 落档时连同 `decisions.md` 复制进 `openspec/changes/improve-smoke-skill-codepoint-slim/`，成为归档件的一部分。
