# spec-workflow-add-design-phase 执行日志

> **非四件套**执行记录（先例形态：`openspec/changes/archive/2026-10-14-spec-workflow-externalize-references/execution-log.md`）。
> 权威进度仍为**工件 + `tasks.md` 勾选态 + `git log` 三方对齐**；`/tmp/spec-flow/<change>/` 材料易失、不入库、不进提交（本文件只承载其结论摘要）。

## 一、阶段边界与用户裁决

- 阶段 1 双线（`/tmp`：line-a 11086 码点、line-b 10619 码点，各自独立）；阶段 1.5 六步收敛留痕 `diff-matrix.md` 4788 码点：三分类矩阵（共识 S1–S12 / 分歧 D1–D4 / 单边遗漏 U1–U11 逐项核验）、自行裁定 7 处、D2 派第三线 fresh 子代理复算（`panel-d2.md`，三线对照 2:1）、设计树前沿分轮问答（轮 1 前沿={D1}，用户裁决「**咬合方案**」；轮 2 前沿为空 → 收敛结束）、未决项「无」。
- 落档提交 `7a60bc9 docs(openspec): 落档 spec-workflow-add-design-phase`（五文件，260 insertions）；`openspec validate --strict` 通过（4/4 工件）。
- 执行参数：模式 **auto**、引擎 **subagent**、句内并行上限 3、`apply` 路由 `opencode-go/deepseek-v4.1-flash`。

### 执行期用户裁决（待决问题中转协议，4 项）

| # | 上浮自 | 问题 | 用户裁决 |
| --- | --- | --- | --- |
| 1 | 任务 1.1 | 3.2 验收句「关键词在 skill 目录内唯一命中 planning.md」与 1.2/1.3 任务原文要求的措辞直接冲突（字面永不可通过） | 改「**定义源唯一**」口径：定义唯一在 planning.md，其余文件仅引用性短句；已重写 tasks.md 3.2 |
| 2 | 任务 2.1 | 收紧来源超出 D5 明列两项（§四此前已被 externalize-references 基本外移完，仅剩 −22，无法覆盖 +233 新增） | **接受**按 D5 Risks 回退「§六落档细节追加外移」（用户已确认），并写入 2.1 原文 |
| 3 | 任务 2.1 | 门2 `grep -c` 无匹配时 POSIX 退出码为 1（实质条件成立但字面「退出码 0」不成立） | 改写为 `test -z "$(git diff … | grep '^[-+]name:\|^[-+]description:')"` 退出码 0 |
| 4 | 任务 2.1 | 五处清单外的「五阶段流水线」→「六阶段流水线」一致性修正（0 码点） | **保留**（否则 §一 与流水线图自相矛盾） |

## 二、批次记录（组间串行、组内并行 ≤3）

### 批次 1 —— 组 1 skill 资源文件展开（3 任务并发）

| 任务 | 写范围 | 结果 | 主会话核对 |
| --- | --- | --- | --- |
| 1.1 | `planning.md` | +38/−4；4496 → **6219** | 验证句 PASS；新节逐项对齐 D3/D4/D7/D9（六字段、二约束、核对清单五步、上浮接线、L2/L1/L0、落档细节四处增补） |
| 1.2 | `execution.md` | 单行两处最小增量；3058 → **3092** | 验证句 PASS；`相关 spec/design 摘录` → 所属组要点**逐字引用** + 写范围须含触达面文件；diff 仅 1 行 |
| 1.3 | `failure-modes.md` | 行内并入设计线同构处置；2169 → **2238** | 验证句 PASS；`grep -c 设计线`=1；diff 仅目标行 |

### 批次 2 —— 组 2 入口与配置（3 任务并发）

| 任务 | 写范围 | 结果 | 主会话核对 |
| --- | --- | --- | --- |
| 2.1 | `SKILL.md`（+剪切承接于 `planning.md`） | 新增 +233 / 收紧 −263，7812 → **7782**（净 −30）；planning 6219 → 6279 | 门1 PASS（7782∈[6800,7830]、`1.7`/`design` 命中、12 节标题）；门2 PASS（frontmatter 逐字节一致，sha256 级复核）；语义保全抽查：grill-me 2 处（§五）、`openspec status` 1 处（§七）、四件套与入口指引在 planning.md 权威承载 |
| 2.2 | `dsh/spec-workflow.yaml`、`routing.md` | yaml `models.design={zai,glm-5.3}` + 注释同步；routing 3738 → **3900**（键表/示例/能力表 4 处同步） | yaml 断言 PASS（docker python）；`grep -c design`=3；**路由自检脚本逻辑实跑**：映射 ⊆ 白名单（`cordis.patch.yml` L136-140 未被改） |
| 2.3 | `dsh/README.md` | +9/−5（限于 spec-workflow 节） | `1.7\|代码设计`=6、`design`=6、`五阶段` 零残留；「六阶段」与 SKILL.md 一致 |

### 批次 3 —— 组 3 结构化验证（3 任务并发，**只读**）

| 任务 | 结论 | 证据摘要 |
| --- | --- | --- |
| 3.1 | PASS（exit 0） | 六 skill 文件各 ≤8192；SKILL.md=7782∈[6800,7830]；frontmatter 字节级不变（sha256 `bb80471c…`）；12 节标题数量与文字一致；主规格=7914 未被触碰 |
| 3.2 | PASS（exit 0） | 定义源唯一：planning 命中 `触达面`5/`六字段`4/`code-design`6/`阶段 1.7`7；SKILL `触达面`0/`六字段`0（`code-design`3 处均为产物路径引用）；execution `触达面`1、failure-modes `阶段 1.7`1（均引用性短句）；同级互引 5 目标 `test -f` 全 PASS；`五阶段` 零残留 |
| 3.3 | PASS（exit 0） | `openspec validate spec-workflow-add-design-phase --strict` → "is valid"，stderr 0 字节、零 error/warning；5 条 Requirement 描述 315/218/476/228/234 全 ≤500（max 476） |

### 批次 4 —— 组 4 运行时与自举冒烟（2 项）

| 任务 | 结论 | 证据摘要 |
| --- | --- | --- |
| 4.1（主会话亲测） | PASS | 按名加载 `spec-workflow` 成功，返回内容为**改后版本**（§一「六阶段流水线」+ 阶段1.7 节点、§五骨架句指向 planning.md、§六 `code-design.md` 输入、§十「规划含阶段 1.7 设计线」、§十一 `design` 键）；部署 symlink `~/.agents/skills/spec-workflow → agent/skills/spec-workflow`（改源即生效）；**渲染 8125~8142 码点**（＝文件 7782 + 包裹开销 343~360）≤ 8192，余量 50~67；`~/.dsh/commands/spec-flow.md` symlink 在位（命令面板可见） |
| 4.2 | PASS（口径见第四节） | `test -s /tmp/spec-flow/…/diff-matrix.md` exit 0（4788 码点，六节留痕齐备）；材料 line-a 22887B / line-b 21265B / panel-d2 6411B 齐全；落档工件自举特征齐备（design.md T1–T9 + file:line 证据锚 + D1–D9 含被否反例；tasks.md 头注指向触达面） |

> 说明：4.1 由主会话亲测而非派子代理——任务语义即「**会话内**按名加载」与「命令面板可见」，其被测主体是主会话自身。

## 三、码点与结构门实测（基线 → 实测）

| 文件 | 基线 | 实测 | Δ | 上限余量(8192) |
| --- | --- | --- | --- | --- |
| `agent/skills/spec-workflow/SKILL.md` | 7812 | **7782** | −30 | 410（门 [6800,7830]） |
| `agent/skills/spec-workflow/planning.md` | 4496 | **6279** | +1783 | 1913 |
| `agent/skills/spec-workflow/convergence.md` | 2864 | 2864 | 0 | 5328 |
| `agent/skills/spec-workflow/execution.md` | 3058 | **3092** | +34 | 5100 |
| `agent/skills/spec-workflow/routing.md` | 3738 | **3900** | +162 | 4292 |
| `agent/skills/spec-workflow/failure-modes.md` | 2169 | **2238** | +69 | 5954 |
| `openspec/specs/spec-workflow/spec.md` | 7914 | 7914 | 0 | 278（归档阶段同步，见第六节） |

口径：`len(open(path, encoding='utf-8').read())`（python3.11.2）。

## 四、执行日志口径裁定（4.2）

- 先例形态（`externalize-references`）：**`/tmp` 的 `diff-matrix.md`（阶段 1.5 收敛）+ 变更目录 `execution-log.md`（阶段 3/4 执行与自举观察）** 两件；其 `execution-log.md` 自身不含「收敛」字样，收敛记录由 `diff-matrix.md` 承载。
- 本变更据此补齐第二件（本文件）；第一件已存在（4788 码点，六节留痕）。二者合起来满足 4.2 验收句「`test -s …/diff-matrix.md` 且执行日志含收敛记录」。
- 辅助证据（仓库外、机器可读，非工作流产物）：harness 会话轨迹 `~/.dsh/sessions/--home-docker--/session-bc0ae92e-…/session.v4.jsonl.zstd`（只读解压 3,178,087B / 589 行），实测 `diff-matrix` 253、`单边遗漏` 33、`收敛结论` 72、`阶段 1.5` 218、`六步` 70 命中。
- `/tmp` 材料**不随变更入库**（工作流明规：易失、不入库、不进提交）；其结论已摘要于本文件第一节。

## 五、D8 触达面引用契约裁定

- 写任务 **1.1–2.3 全覆盖 6/6**（1.1→T2、1.2→T3、1.3→T5、2.1→T1、2.2→T4/T6、2.3→T7）。
- 只读验证任务（3.1–3.3、4.1、4.2）**无写范围**，引用触达面编号无对象，故不适用；T8（本变更工件）由落档阶段自身产出，无对应任务；D8 的目的即「『组内不写同一文件』机械化」，本解释不减损该目的。

## 六、阶段 4（验证与归档）

- 项目声明的验证（`CLAUDE.md` L35-40，仅 `tools/skctl` 组件）：`node --test` **47/47 pass，exit 0**；本变更未触及其任何文件，作为回归证据。
- 变更侧验证：批次 3/4 全部断言通过（第二、三节）。
- 归档：`openspec-archive-change` 流程（delta 同步主规格 + 净增 ≤0 门 + `validate --specs --strict`）→ 归档单独提交 → 四要素汇报。**本节结果以提交历史与归档目录为准。**
