# update-smoke-skill-case-first · 代码级蓝图（阶段 1.7）

> 设计对象：dotfiles 仓 `agent/skills/smoke-testing-local-env/` 三份文档（HEAD 版本：SKILL.md 156 行 / reference.md 424 行 / project-profile-template.md 91 行）。
> 输入：`explore.md`（探索）+ `decisions.md`（6 项收敛结论，视为不可推翻）。本文件只回答「改哪些文件、怎么改、文档结构契约为何、为什么这么定」，不复述需求与探索结论。
> 本文件是本次唯一产物，不写任何项目文件；文内行号均为**改动前 HEAD 版本**行号。

**三条设计不变量**（后续所有取舍以此裁决）：

1. SKILL.md L1–60 **行数恒为 60**；L1–2、L4–60 逐字节不变。唯一授权字节变化是 L3 description 同行替换（决策 4）；L11 的处置见文末待决 #1。
2. reference.md §1 之前（L1–18）逐字节不变；既有节号一个不少，只新增 §6.1–§6.5。
3. 有用例契约不可覆盖：编号稳定、7 列固定、结果只进运行记录；可覆盖的只有 `smoke/` 路径（画像 §9）。

---

## ① 触达面清单

**本需求全部在 dotfiles 根仓**（`/home/xuqinqin/develop/dotfiles`），无跨仓改动。

| 文件（仓） | 量级 | 改动意图 | 关键改动点 |
| --- | --- | --- | --- |
| `agent/skills/smoke-testing-local-env/SKILL.md`（dotfiles） | 中（156 → 约 200 行） | 把六阶段规程改造成七阶段，并让「先有用例库、再按编号执行」成为可判定规程 | ①L3 description 同行替换补触发词；②L60 后插入「两种冒烟模式」小节；③核心原则插入「用例先行，逐项执行」并顺延编号；④流程插入阶段 3、原 3–6 顺延为 4–7（阶段 5 改名并前置执行纪律）；⑤陷阱 Top 10→12；⑥验收口径 6 条；⑦收尾清单 5→7 项 |
| `agent/skills/smoke-testing-local-env/reference.md`（dotfiles） | 大（424 → 约 550 行） | 把 §6 从「用例矩阵模板」扩造成完整用例契约（模式/库/运行目录/执行纪律），并联动 §7/§8/§9 | ①§6 标题与整节替换，拆 §6.1–§6.5（原 A–G 块逐字节保留）；②§7.1 报告骨架加 scope 与分组汇总；③§7.2 归档改运行目录收纳；④§7.4 加「预期入库改动」白名单；⑤§8 表 +2 行（顺带转义 L410 内联竖线）；⑥§9 表 +1 行 |
| `agent/skills/smoke-testing-local-env/project-profile-template.md`（dotfiles） | 小（91 → 约 96 行） | 让画像成为用例库的输入，并把归档约定默认值改成运行目录 | ①§7 表后加 blockquote「本表是用例库的输入」；②§9 表 4 行重写为 5 行（用例库/运行目录/截图/画像覆盖/测试数据清理） |

**负面清单（零触达，附理由）**：

| 对象 | 理由 |
| --- | --- |
| `agent/skills/smoke-testing-local-env/scripts/`（recon.sh、tcp-bridge.mjs） | 侦察与桥接脚本行为不变；用例规程不引入新脚本（2 个文件，目录总 10.1KB） |
| `agent/skills/README.md` | 只登记来源列，不含能力描述；`README.md:32` 行不变 |
| `openspec/`（含活跃变更 `add-ui-demo-gate`） | 本 skill 无 spec 管辖；且活跃变更按行号引用 `SKILL.md:30-34`，本次设计的目标就是保住该引用 |
| 其他 skill、代码、测试 | 纯文档改动，仓内 skill 无测试先例 |

**外溢产物（所测项目仓，非本次改动；仅在本设计中定义形状）**：

| 产物 | 生成时机 | 入库 |
| --- | --- | --- |
| `smoke/cases.md` | 首次建库 | 入库 |
| `smoke/.gitignore` | 首次建库 | 入库 |
| `smoke/runs/<YYYY-MM-DD>-<full\|任务号>/record.md` | 每次运行（阶段 3 起） | 入库 |
| `smoke/runs/<YYYY-MM-DD>-<full\|任务号>/report.md` | 每次运行（阶段 7） | 入库 |
| `smoke/runs/<运行>/` 内 `*.png` 等 | 每次运行 | **不入库**（由 `smoke/.gitignore` 忽略） |
| 所测项目根 `.gitignore` | — | **不改**（理由见决策 D6 与待决 #2） |

---

## ② 证据锚

每条锚点均摘自 HEAD 版本原文；新建文件另标「新建」。

| # | file:line | 原文（摘录） | 支撑的设计判断 |
| --- | --- | --- | --- |
| 1 | `SKILL.md:3` | `description: Use when 需要在本机 docker 化开发环境里对任意项目做端到端冒烟/验收验证……触发词：冒烟测试、联调、端到端验证、真机测试、验收用例、跑一遍流程、E2E、smoke test、browser 验证。` | 单行 description 是唯一 frontmatter 改动点；触发词追加即在此行内完成（决策 4） |
| 2 | `SKILL.md:11` | `规程固定为：**环境侦察 → 零侵入链路 → 数据准备 → 浏览器执行 → 三层证据 → 归档收尾**。` | 六阶段一句话；位于 L1–60 冻结区，与新七阶段冲突 → 待决 #1 |
| 3 | `SKILL.md:61` | `## 核心原则` | 新的「两种冒烟模式」小节插入锚点（L60 之后、本行之前），可保证 L1–60 不动 |
| 4 | `SKILL.md:63` | `1. **环境事实先行**——端口、进程、浏览器位置、网络路径先测清楚再谈用例；多数"功能不通"实为链路错位。` | 核心原则为有序列表（1–6），插入新原则需顺延编号 |
| 5 | `SKILL.md:92` | `### 阶段 3　数据准备` | 新阶段 3「准备测试用例」插在 L91 空行与本行之间；原 3–6 顺延 |
| 6 | `SKILL.md:145` | `- 冒烟通过 = 用例矩阵无失败项 + 三层证据齐全 + 工作区洁净` | 验收口径以「用例矩阵」表述，需改为「所选用例在运行记录中全部有结果」 |
| 7 | `SKILL.md:128` | `## 高频陷阱（Top 10，全表见 reference §8）` | 标题数字与表行数需同步改为 12 |
| 8 | `SKILL.md:150` | `## 收尾清单` | 清单为 5 项，追加 2 项 |
| 9 | `reference.md:336` | `## 6. 用例矩阵模板` | §6 是扩造主体；节号固定不变，只改标题与内容 |
| 10 | `reference.md:338` | `按"能力组"切分，组内正反例并列，标注结果与证据：` | 原「标注结果与证据」与新契约冲突（结果只进 record），需改写引入句 |
| 11 | `reference.md:341-347` | `A 账号与身份      注册/发码/登录态/资料完善` … `G 补充            无法自然构造的场景（单测已覆盖则标注"未浏览器验证"）` | A–G 能力组块逐字节保留，作为 §6.2 |
| 12 | `reference.md:364` | `### 7.2 归档位置` | 归档从 openspec artifacts 改为运行目录收纳（决策 5），节号不动 |
| 13 | `reference.md:366` | - 浏览器冒烟报告 + 截图 → `openspec/changes/<change>/artifacts/`（**gitignore 忽略，不入库**） | 旧默认归档位置，降为「画像 §9 覆盖示例」 |
| 14 | `reference.md:384` | `各仓只允许出现**预期的**新增文件。冒烟期间禁止产生任何入库文件改动（含格式化、codegen 产物）。` | 与「用例回写 cases.md」字面冲突，需加预期入库改动白名单（D8） |
| 15 | `reference.md:410` | 第 21 行「端口排查命令 not found」（原文含内联竖线，见下方【A15】） | 该行内联竖线未转义，新增表行后整表渲染有断裂风险 → 顺带转义 |
| 16 | `reference.md:412` | `## 9. 项目画像字段` | §9 字段表 +1 行（用例库与运行目录的采集来源） |
| 17 | `project-profile-template.md:72` | `## 7. 用例入口` | §7 表是用例库的直接输入，需加一句 blockquote 说明 |
| 18 | `project-profile-template.md:86-91` | §9 表头与 4 行数据（原文见下方【A18】） | §9 表（4 数据行）重写为 5 行，默认值改运行目录 |
| 19 | `agent/skills/smoke-testing-local-env/scripts/`（目录） | 仅 `recon.sh`、`tcp-bridge.mjs` | 本次不新增/不改脚本，规程不引入工具 |
| 20 | 新建 `smoke/cases.md` | 新建（所测项目仓） | 用例库；7 列、编号 `<组>-<序号>`、废弃不删行 |
| 21 | 新建 `smoke/runs/<YYYY-MM-DD>-<full\|任务号>/record.md` | 新建（所测项目仓） | 逐项回填 + 分组汇总；结果值域 4 值 |
| 22 | 新建 `smoke/runs/<YYYY-MM-DD>-<full\|任务号>/report.md` | 新建（所测项目仓） | 结论报告，复用 §7.1 骨架 |
| 23 | 新建 `smoke/.gitignore` | 新建（所测项目仓） | 运行目录图片忽略规则，避免改项目根 `.gitignore` |

**约束类证据（行号引用为什么不能动）**：

| # | file:line | 原文（摘录） | 支撑的设计判断 |
| --- | --- | --- | --- |
| 24 | `openspec/changes/add-ui-demo-gate/code-design.md:100` | 摘录：…… `SKILL.md:30-34`——MCP 缺失时的降级表体例（skill 降级段照抄此形态） | 活跃变更按行号引用 L30–34；设计以「行数与行号位置不变」保护它 |
| 25 | `openspec/changes/add-ui-demo-gate/tasks.md:5` | 摘录：含①降级表体例与容器内浏览器事实（`agent/skills/smoke-testing-local-env/SKILL.md:30-34`、`reference.md:19`） | 同上；`reference.md:19` 在 §1 冻结区内 |
| 26 | `tools/skctl/src/doctor.ts:61-63` | 报错文案 `invalid: … (bad frontmatter)` 与 `(frontmatter name … != dir name)` | frontmatter `name` 不可改（必须等于目录名），只动 description |
| 27 | `agent/skills/README.md:32` | 当前清单中 smoke 行的来源列写「自写（本目录 local symlink）」（原文见下方【A27】） | README 只登记来源，本次零触达 |

**原文逐字块**（含竖线/反引号，表格内转义会失真，故单列）：

```text
【A15】reference.md:410
| 21 | 端口排查命令 not found | 容器内无 ss/netstat/lsof | 用 `ps aux | grep <进程>` |

【A18】project-profile-template.md:86-91
| 项 | 值 |
| --- | --- |
| 报告路径 | 例：`openspec/changes/<change>/artifacts/browser-smoke-<date>.md`（gitignore） |
| 接口冒烟记录 | 例：`<change>/smoke-record.md`（入库） |
| 截图目录 | 例：`openspec/changes/<change>/artifacts/` |
| 测试数据清理 | 默认保留痕迹，报告"测试数据"节列明 |

【A27】agent/skills/README.md:32
| `smoke-testing-local-env` | 自写（本目录 local symlink） |
```

---

## ③ 接口与数据形状

本需求是纯 markdown 文档改动，本字段承载**文档结构契约**：目录树、表头、文件构成、命名格式与小节位置。

### 3.1 `smoke/` 目录树（所测项目仓）

```
<所测项目根>/smoke/
├── cases.md                         # 全量用例库（入库，长期维护；7 列 + 稳定编号）
├── .gitignore                       # 仅忽略运行目录里的图片/大文件（入库；建库时一并建）
└── runs/
    └── <YYYY-MM-DD>-<full|任务号>/   # 一次运行一个目录
        ├── record.md                # 逐项结果回填 + 分组汇总（入库）
        ├── report.md                # 结论性报告（入库）
        └── *.png / *.jpg / *.webm    # 截图等二进制（gitignore 不入库）
```

路径可被项目画像 §9 覆盖；**编号稳定、7 列、结果只进运行记录**三项不可覆盖。

### 3.2 `cases.md` 契约

文件头（必填 preamble，3 行）：

```markdown
# <项目名> 冒烟用例库

> 用例定义只增不删：弃用行保留并注「已废弃：原因」。运行结果写入 `runs/<YYYY-MM-DD>-<full|任务号>/record.md`，**不回填本文件**。
```

**七列表头（逐列名，顺序固定）**：

```markdown
| 编号 | 用例 | 类型 | 前置 | 步骤 | 期望结果 | 证据要求 |
| --- | --- | --- | --- | --- | --- | --- |
```

| 列 | 语义 | 取值约束 |
| --- | --- | --- |
| 编号 | 用例唯一键 | `<组>-<两位序号>`，组 ∈ A–G，如 `A-01`、`C-03` |
| 用例 | 一句话场景名 | 废弃时行保留，在本列末尾注 `（已废弃：<原因>）`，编号不复用 |
| 类型 | 正/反例 | 仅 `正` 或 `反` |
| 前置 | 前置条件与数据 | 引用画像条目（如「画像 §5 已发码账号」），不复制画像内容 |
| 步骤 | 可复现步骤 | 编号子步（① ② ③），含入口路径与关键操作 |
| 期望结果 | 可判定终态 | UI + 接口 + 落库中至少一项可判定；避免「正常显示」类空话 |
| 证据要求 | 本次必须留的证据 | 写明三层各自的具体物（截图 / 端点与状态码 / 表与主键） |

规则：

- **编号续接**：同组新增取当前最大序号 +1；跨运行永不复用。
- **修订**：既有用例期望变化 → 原地改该行（编号不变，版本差异交给 git），不新增编号。
- **粒度**：一条用例 = 一个可独立判定通过/失败的场景；不把多场景塞进一行。
- **排列**：单表按编号升序；不按组拆多张表（分组信息在编号首字母）。
- **「在用条目」**：未标「已废弃」的行；全量 smoke 只跑在用条目。
- 分组沿用 §6.2 能力组 A–G；组内正反例并列。

示例行（只示范形态，内容随项目）：

```markdown
| A-01 | 手机号 + 验证码登录 | 正 | 已发码账号（画像 §5） | ①打开 `/login` ②填手机号与库中验证码 ③提交 | 进入 `/account`，本地凭据含 token | 截图 + `POST /api/auth/login` 200 + `account_token` 新行 |
```

### 3.3 运行目录契约

**命名**：`runs/<YYYY-MM-DD>-<full|任务号>/`

| 片段 | 规则 |
| --- | --- |
| `YYYY-MM-DD` | 按**项目业务时区**（画像 §0）取日期，不取容器本地时区 |
| `full` | 全量 smoke 固定字面量，小写 |
| 任务号 | 原样保留（如 `T2.1`）；仅保留字母/数字/`.`/`-`，空格替换为 `-`，其余字符删除 |
| 冲突 | 同日同 scope 重复运行追加 `-2`、`-3`（如 `2026-11-19-full-2`），不覆盖已有目录 |

示例：`smoke/runs/2026-11-19-full/`、`smoke/runs/2026-11-19-T2.1/`。

**文件构成**：`record.md`（逐项记录，阶段 3 创建、阶段 5 回填）、`report.md`（结论报告，阶段 7 落盘）、截图/大文件（直接放运行目录根，单层 glob 可忽略）。

### 3.4 `record.md` 骨架

```markdown
# <YYYY-MM-DD>-<full|任务号> 运行记录

- 项目 / 分支 / commit：
- 模式：全量 | 单任务（任务号 ____）
- 环境：服务地址 / 浏览器位置 / 桥接 / MCP 降级
- 执行时间：YYYY-MM-DD HH:mm（业务时区）
- 所选用例编号集：A-01, A-03, C-02 …（与 cases.md 对齐）

## 逐项结果

| 编号 | 结果 | 证据 | 备注 |
| --- | --- | --- | --- |
| A-01 | 通过 | 截图 [A-01-login.png](./A-01-login.png)；网络 `POST /api/auth/login` 200；`account_token` id=… | |
| C-03 | 失败 | [C-03-upload.png](./C-03-upload.png)；网络 500 | 阻塞：对象存储不可达 |
| D-02 | N/A | 原因：依赖能力未实现；等效证据：单测 `draft.spec.ts` 通过 | |

## 分组汇总

| 组 | 总数 | 通过 | 失败 | N/A | 观察项 |
| --- | --- | --- | --- | --- | --- |
```

- **结果值域（固定 4 值）**：`通过` / `失败` / `N/A` / `观察项`；`观察项` = 用例可判通过但存在非阻断异常，须在 report.md 观察项节另行编号。
- 证据列写**相对本目录**的链接（`./A-01-login.png`）+ 关键标识（端点、主键）。
- 逐项表**不复制用例名/期望**，只用编号引用 `cases.md`，避免双写漂移；编号是唯一键。
- 逐项行按 record.md 里「所选用例编号集」的顺序排列，与 cases.md 的编号升序一致（单任务子集保持升序）。
- 「所选用例编号集」在**执行前**写入（阶段 3），结果列留空，作为执行清单。

### 3.5 `report.md` 骨架（§7.1 改造后的契约）

```
标题：<YYYY-MM-DD>-<full|任务号> <能力名> —— <全量|单任务>冒烟报告
一、测试环境        服务地址/profile/MOCK 组件/测试账号（含桥接说明与 MCP 降级声明）
二、用例结果汇总    分组表：组 | 总数 | 通过 | 失败 | N/A | 观察项；逐项明细见同目录 record.md
三、观察项          编号 + 影响面 + 建议归属任务
四、外部组件结论    如真机直传的证据链
五、证据文件        截图清单（相对链接）
六、测试数据        产生的主键与对象 key（便于清理）
```

### 3.6 `smoke/.gitignore` 契约

```
runs/*/*.png
runs/*/*.jpg
runs/*/*.jpeg
runs/*/*.webp
runs/*/*.gif
runs/*/*.webm
runs/*/*.har
```

单层 glob 正好匹配 `smoke/runs/<运行>/<文件>`；模式相对 `smoke/` 解析，因此不需要改项目根 `.gitignore`。

### 3.7 新增/改写小节标题与位置总表

| 文件 | 位置（改动前锚点） | 标题 | 动作 |
| --- | --- | --- | --- |
| SKILL.md | L60 空行后、L61 `## 核心原则` 前 | `## 两种冒烟模式：全量 smoke 与单任务 smoke` | 新增（含 4 行维度表 + 判定句） |
| SKILL.md | L91 空行后、L92 `### 阶段 3　数据准备` 前 | `### 阶段 3　准备测试用例（不可跳过）` | 新增（5 步 + 卡点） |
| SKILL.md | L92 原阶段 3 | `### 阶段 4　数据准备` | 改号（内容不动） |
| SKILL.md | L100 原阶段 4 | `### 阶段 5　按用例逐项执行` | 改号 + 改名；前置 4 条执行纪律，原 6 条浏览器要点保留 |
| SKILL.md | L109 原阶段 5 | `### 阶段 6　三层证据` | 改号（内容不动） |
| SKILL.md | L121 原阶段 6 | `### 阶段 7　归档收尾` | 改号 + 追加 2 条（运行目录归档、用例回写） |
| SKILL.md | L128 | `## 高频陷阱（Top 12，全表见 reference §8）` | 改标题数字 + 表尾加 2 行 |
| SKILL.md | L143–148 | `## 验收与勾选口径` | 首条改写 + 新增 2 条（共 6 条） |
| SKILL.md | L150–156 | `## 收尾清单` | 5 项 → 7 项 |
| SKILL.md | L3 | `description: …` | 同行替换（补能力句 + 触发词，仍单行） |
| SKILL.md | L11（条件，待决 #1 放行后） | `规程固定为：…` | 同行替换为七阶段（行数不变） |
| reference.md | L336–348 整节 | `## 6. 测试用例：用例库与逐项执行` | 改标题 + 换成 5 子节 |
| reference.md | §6 内（按序） | `### 6.1 两种冒烟模式与用例范围`<br>`### 6.2 能力组 A–G`<br>`### 6.3 用例库：smoke/cases.md`<br>`### 6.4 运行目录：smoke/runs/<YYYY-MM-DD>-<full\|任务号>/`<br>`### 6.5 逐项执行纪律` | 新增 5 子节（A–G 块逐字节保留在 6.2） |
| reference.md | L352–362 | `### 7.1 报告骨架（固定）` | 标题行加 scope；「二、」改「用例结果汇总」+ 分组表头 + 指向 record.md |
| reference.md | L364–368 | `### 7.2 归档位置` | 重写：默认运行目录收纳 + 画像 §9 覆盖 + 存量约定示例 |
| reference.md | L376–384 | `### 7.4 工作区洁净核验（必须）` | 追加「预期入库改动」白名单段 |
| reference.md | L410 之后 | `## 8. 陷阱全表` | 追加第 22、23 行；顺带转义 L410 内联竖线 |
| reference.md | L423 之后 | `## 9. 项目画像字段` | 表尾 +1 行 |
| project-profile-template.md | L76 之后 | `## 7. 用例入口` | 表后加 1 条 blockquote |
| project-profile-template.md | L86–91 | `## 9. 归档约定` | 4 数据行重写为 5 行 |

---

## ④ 决策记录

### D1 新小节放在 L61 边界（`## 核心原则` 之前）

- **决策**：插入 `## 两种冒烟模式…` 于 L60 之后，作为「第一原则 → 模式判定 → 核心原则」的阅读路径。
- **被否方案**：改写概述 L11 把六阶段换成七阶段（直接撞 L1–60 冻结区，且 L11 不在本设计的授权字节变化清单内 → 升级为待决 #1，不在此处偷渡）；把模式表塞进流程阶段 3（读者先读阶段细节才见模式，且核心原则/验收口径要向前跳转引用）。
- **反例**：若按「流程内嵌」实现，阶段 3 会同时承担「判模式 / 建库 / 写编号集 / 数据准备」四件事，单向流程被拉成前置条件判断，复测时容易漏判模式。

### D2 核心原则插入为第 3 条，原 3–6 顺延为 4–7

- **决策**：`3. **用例先行，逐项执行**——…`，插在「零侵入」之后、「三层证据」之前，使原则顺序与流程顺序同构（侦察 → 链路 → 用例 → 数据 → 执行 → 证据 → 归档）。
- **被否方案**：追加为第 7 条（diff 最小，但新要求的中心地位被埋没，且与流程阶段顺序错位）；不改原则、只改流程（验收口径与陷阱表失去引用落点）。
- **反例**：若追加为第 7 条，读者按「原则 1→6」读到执行阶段才遇到「用例先行」，而流程阶段 3 已在要求用例落库——原则与流程相互矛盾。

### D3 reference §6 拆 5 子节，顺序：模式 → 能力组 → 用例库 → 运行目录 → 执行纪律

- **决策**：先判模式（决定范围），再给分组词表（决定编号首字母），再给库格式（决定 7 列/编号/废弃），再给运行目录（决定结果去哪），最后给执行纪律（决定怎么跑）。
- **被否方案**：把能力组放 §6.5（读者在 §6.3 看到 `A-01` 时不知道 A 是什么）；把运行目录并入 §6.3（库格式与记录格式混节，`§6.3/§6.4` 的引用粒度变粗，SKILL.md 无法精确指向「记录骨架」）。
- **反例**：若运行目录并入用例库节，单任务收尾「回写 cases.md」与「回填 record.md」两个动作在同一小节里没有分界，验收口径写「有结果」时无法区分是库内结果列还是运行记录。

### D4 7 列固定，废弃标记落在「用例」列，不加状态列

- **决策**：表头固定 7 列；废弃行的编号保留，在「用例」列文本末尾注 `（已废弃：<原因>）`；编号永不复用。
- **被否方案**：加第 8 列「状态」（破坏 decisions 的 7 列契约；且状态是随运行变化的字段，会让 cases.md 不再是纯定义）；编号加后缀 `A-05-废弃`（历史 record 引用失配）；直接删行（历次运行记录引用悬空）。
- **反例**：加状态列后，`smoke/runs/2026-11-19-full/record.md` 里引用的 `A-05` 在下一次运行可能因状态列变化而「同名不同义」，复测对比失效——这正是决策 6 要防的。

### D5 运行目录命名固定 `<YYYY-MM-DD>-<full|任务号>`，同日重跑加 `-2`

- **决策**：`<YYYY-MM-DD>-<full|任务号>`；冲突时追加 `-2`、`-3`，绝不覆盖。
- **被否方案**：同日覆盖（丢历史，违背「复测可对比」）；追加时分秒（`2026-11-19-1430-full` 破坏 `<日期>-<scope>` 固定格式，且语义上是时间戳不是 scope）；把 scope 放前缀（`full-2026-11-19` 与决策文本相反）。
- **反例**：覆盖同名目录后，第二次复测的失败证据会覆盖第一次的通过证据，报告与 record 对不上号。

### D6 归档 = 运行目录收纳 + `smoke/.gitignore`，不碰项目根 `.gitignore`

- **决策**：截图直接放运行目录根（与 decisions 树形一致），忽略规则写在 `smoke/.gitignore`（单层 glob）；建库时一并创建。
- **被否方案**：改项目根 `.gitignore`（与 reference §2.5 红线「不改 .gitignore」字面冲突，且给项目留下与冒烟无关的根配置改动）；`runs/<运行>/assets/` 子目录（偏离 decisions 的目录树，多一层且 `assets/` 命名无额外收益）；沿用 openspec artifacts（等于不回执行决策 5）。
- **反例**：改根 `.gitignore` 后，若用户在冒烟后 revert 该改动（视为污染），截图立刻变成未跟踪文件，§7.4 洁净核验反而失败。

### D7 report.md 与 record.md 两文件并存，report 只放汇总与结论

- **决策**：record.md 存逐项（编号/结果/证据/备注）+ 分组汇总；report.md 复用 §7.1 骨架，第二节改为分组汇总表并指向同目录 record.md；两文件都入库。
- **被否方案**：合并为单文件（decisions 明确受众不同；合并后报告被上百行明细淹没）；report 复制逐项明细（双写、易漂移）。
- **反例**：合并后全量 smoke 的报告长达数百行，用户读不到结论；且「报告已落盘」与「逐项已回填」变成同一个可空项，验收无法分别判定。

### D8 §7.4 洁净核验加「预期入库改动」白名单

- **决策**：在 §7.4 原文后补一段：`smoke/cases.md` 新增/修订、`smoke/runs/**/*.md`、首次建库的 `smoke/.gitignore` 属预期入库改动；其余（格式化、codegen、锁文件）仍按污染处理。
- **被否方案**：不改 §7.4、靠验收口径口头解释（同一文档内「禁止任何入库改动」与「必须回写用例库」直接矛盾）；要求用户代提交（把可自动化的资产沉淀变成人工步骤）。
- **反例**：单任务 smoke 按需求回写 `cases.md`，若 §7.4 不退让，收尾核验必然报「工作区不洁净」，agent 只有两个选择：谎报干净或放弃回写——后者让需求 3 落空。

### D9 验证断言按行区间拆分，不做 L1–60 全量 diff

- **决策**：`diff` L1–2、L4–60（及独立断言 L30–34）为空；L3 由「单行 + 触发词齐全」断言；L1–60 行数仍为 60。
- **被否方案**：`diff <(git show HEAD:… | head -60) <(head -60 …)` 为空（与决策 4 的 description 替换必然冲突，绿灯永远拿不到）；只 diff L30–34（无法证明其余区域未被误改）。
- **反例**：若照搬全量 diff 断言，实现者为了拿绿灯会放弃决策 4 的触发词追加，直接推翻已定结论。

### D10 栈识别结论：writer skill 未命中，本次豁免（仅本次有效）

- **决策**：不加载任何 writer skill；经用户确认本次豁免，**仅本次有效**，后续同类改动需重新识别栈。
- **被否方案**：因文档正文出现 Spring/Nuxt 字样就加载对应 writer（误把「被描述的技术栈」当「本仓实现栈」）；把三个 writer 全部加载后再筛选（无谓加载且引入与本改动无关的硬约束）。
- **事实证据**（命令在本仓根实测）：
  - `find . -name 'pom.xml' -o -name 'build.gradle' -o -name 'build.gradle.kts' -o -name 'nuxt.config.*' -o -name 'settings.gradle*'` → **无输出**（dotfiles 仓无 Spring / Nuxt 栈证据）。
  - 仓根**无** `package.json`；全仓 5 个 `package.json`（`opencode/`、`tools/skctl/`、`dsh/profiles/{acp,headless,web}/`）均为工具或容器 profile 自身依赖，`grep -l nuxt` **无命中**；`opencode/package.json:2-4` 仅 `{"@opencode-ai/plugin": "1.17.13"}`。
  - 三个 writer 的触发面：`agent/skills/spring-writer/SKILL.md:3`（`Use when writing, modifying, or reviewing any Java/Spring Boot code…`）、`agent/skills/nuxt-writer/SKILL.md:3`（`…any Vue/Nuxt frontend code…`）、`agent/skills/dsh-plugin-writer/SKILL.md:3-4`（`在 dsh-plugins 仓…新增、脚手架或结构性修改 DSH 插件`）。
- **结论**：本次对象是 dotfiles 仓的三份 markdown skill 文档，三者触发面均未命中；设计不受 writer 硬约束（与决策一致）。
- **反例**：若因「文档里出现 Spring/Nuxt 字样」就加载 writer，会把「被描述的技术栈」误当「本仓实现栈」，引入与改动对象无关的硬约束（如要求 Java 代码风格），反而阻碍文档改动。

---

## ⑤ 逐任务组实现要点

四组**串行**：组 1 → 组 2 → 组 3 → 组 4。实现一律用锚点字符串编辑（edit 工具按原文匹配），**不得按行号 sed 插入**，避免前置改动导致行号漂移。

**文风约束**：简体中文；沿现有文档的表格化写法、规程句式与 `§N` 引用；阶段标题沿用全角空格（`### 阶段 3　准备测试用例`）；表格分隔行统一 `| --- |`；不引入 emoji、不写英文长句。

### 组 1　reference.md §6 扩造 + §7/§8/§9 联动

**输入锚点**：L336 `## 6. 用例矩阵模板`、L338 引入句、L341–347 A–G 块、L352 `### 7.1`、L364 `### 7.2`、L376 `### 7.4`、L410 第 21 行、L412 `## 9.`。

1. 用 §6 新内容替换 L336–348 整节（约 +125 行）：
   - `## 6. 测试用例：用例库与逐项执行` + 一句引入（用例是长期资产、落 `smoke/`、路径可由画像 §9 覆盖）。
   - `### 6.1 两种冒烟模式与用例范围`：表头 `| 维度 | 全量 smoke | 单任务 smoke |`，5 行（触发话术 / 用例范围 / 用例库动作 / 运行目录 scope / 收尾动作）；下接判定句（话术判定 + 存疑必问）与「受影响条目」筛选 4 条启发式（入口/接口/数据/共享组件 → 对应能力组；编号集写 record.md 并在用户在场时确认）。
   - `### 6.2 能力组 A–G`：**逐字节保留** L341–347 七行代码块；只改写引入句（去掉「标注结果与证据」，改为「结果回填见 §6.4」）。
   - `### 6.3 用例库：smoke/cases.md`：按 ③3.2 落 preamble、7 列代码块、逐列语义表、编号/修订/废弃/粒度规则、示例行。
   - `### 6.4 运行目录：smoke/runs/<YYYY-MM-DD>-<full|任务号>/`：按 ③3.3–3.4 落目录树、命名表、文件构成、record.md 骨架、结果 4 值、入库/忽略策略与 `smoke/.gitignore` 内容、report.md 归属。
   - `### 6.5 逐项执行纪律`：6 条（顺序执行 / 即时回填 / 失败不中断 / N/A 写理由 / 临场先补库 / 收尾回写与全量核对）。
2. §7.1：标题行与「二、」按 ③3.5 改；一/三/四/六原样保留。
3. §7.2：按 ③3.1–3.4 的运行目录契约与决策 5 重写三条（默认运行目录 / 画像 §9 覆盖 / 存量 openspec 约定降为覆盖示例）。
4. §7.4：追加「预期入库改动」白名单段（D8）。
5. §8：表尾追加两行（第 22、23 行），并把 L410 的 `ps aux | grep` 内联竖线转义为 `ps aux \| grep`（只加反斜杠，文本不变）。
6. §9：表尾追加 `| 用例库与运行目录（smoke/ 路径与忽略规则） | 项目画像 §7/§9；首次建库时确定 |`。

**完成判据**（命令见 ⑤ 验证映射 V4–V7、V9）。

> **终形态（组 1 完成 · 2026-11-19，主会话核对通过）**：实测 584 行（量级「约 550」为近似值，超出部分来自 ③ 强制的完整 record.md 骨架与 smoke/.gitignore 忽略清单，不影响契约）；A–G 块逐字节保留于新 L366–372（HEAD L341–347 diff 无差异）；V4/V5 全绿（主会话复跑 exit=0）、V6/V8 自检 0 行、L1–18 冻结 diff 无差异。偏差留痕三项：①§7.1「五、证据文件」同步改为「截图清单（相对链接）」（③3.5 对齐——⑤保留清单未含「五」，如需旧文案可单行回退）；②§8 第 22/23 行文案自拟（蓝图未给逐字），与组 2 拟增陷阱同义（未落库即测 / 单任务未回写）；③§6.4 标题含 `<YYYY-MM-DD>` 原始字面（3.7 契约字面），CommonMark 渲染器可能吞段（raw/agent 读取不受影响）——待决已上浮，裁决记 R1。

### 组 2　SKILL.md 规程改造

**输入锚点**：L3、L60/L61、L63–68、L70、L91/L92、L100、L109、L121、L128–141、L143–148、L150–156；条件锚点 L11。

1. L3 同行替换：保留原 `Use when …` 主干，追加「先落 `smoke/cases.md` 用例库再按编号逐项执行，区分全量 smoke 与单任务 smoke」能力句；触发词追加 `全量冒烟、复测、回归、上线前验收`（原触发词全保留）。仍为**一行**。建议定稿（单行，可直接采用）：
   `description: Use when 需要在本机 docker 化开发环境里对任意项目做端到端冒烟/验收验证——从 dsh 容器驱动浏览器真机走流程、跨容器访问宿主服务、判断"接口 200 但数据没落库"、组织正反用例矩阵；先落 smoke/cases.md 用例库、再按编号逐项执行，并区分全量 smoke 与单任务 smoke。触发词：冒烟测试、联调、端到端验证、真机测试、验收用例、跑一遍流程、全量冒烟、复测、回归、上线前验收、E2E、smoke test、browser 验证。`
2. 在 `## 核心原则` 前插入新小节（L60 后、L61 前），骨架：
   - 一句引入：用例库与运行记录固定在所测项目根 `smoke/`（路径可由画像 §9 覆盖），格式与纪律见 reference §6；
   - 表头 `| 维度 | 全量 smoke | 单任务 smoke |`，4 行：`触发话术`（全量冒烟/复测/回归/上线前验收 ↔ 带任务号或里程碑）、`用例范围`（全部在用条目 ↔ 受影响旧条目 + 本任务新用例）、`用例库缺失`（按 A–G 建库 ↔ 先补齐本任务用例）、`收尾动作`（运行记录汇总 + 报告 ↔ 同上 + **新用例回写 cases.md（硬性）**）；
   - 一句判定纪律：话术有歧义（既有任务号又说「全量」）→ 问用户一句，不自行猜。
3. 核心原则：插入第 3 条 `3. **用例先行，逐项执行**——…`；原 3–6 编号顺延为 4–7（只改编号，文案不动）。
4. 流程：
   - L91 空行后插 `### 阶段 3　准备测试用例（不可跳过）`：5 步（判模式 / 读库或建库 / 单任务补新用例 / 编号集写入 record / `smoke/.gitignore` 随建库）＋ 卡点句（用例未落盘不得开测、编号集未落 record 不得执行）。
   - 原阶段 3→`### 阶段 4　数据准备`；阶段 4→`### 阶段 5　按用例逐项执行`（前置 4 条执行纪律：按编号顺序逐条且即时回填、失败不中断、N/A 写理由、临场先补库再执行；原 6 条浏览器要点**原样保留**）；阶段 5→`### 阶段 6　三层证据`；阶段 6→`### 阶段 7　归档收尾`（追加「报告+record+截图归档到 smoke/runs/<运行>/」与「单任务新用例回写 cases.md」）。
5. 陷阱：标题 `Top 12`；表尾追加第 11 行「用例只在脑子里/报告里，未进 smoke/cases.md → 先落库再执行」、第 12 行「单任务新用例测完没回写库 → 收尾回写，否则复测漏测」。
6. 验收口径：按 ③ 所述改为 6 条（首条改「所选用例在运行记录中全部有结果且无失败项」；新增全量/单任务覆盖范围条与「未回写不算完成」条）。
7. 收尾清单：按 ③ 增补为 7 项（record 全回填、用例已回写）。
8. **条件步骤**：待决 #1 若放行，再做 L11 同行替换为七阶段（1 行→1 行）；未放行则跳过并保留待决。

> **终形态（组 2 完成 · 2026-11-19，主会话核对通过）**：实测 199 行（蓝图估「约 200」）；V1/V2/V3 全绿（主会话复跑复核：分区间冻结 diff 无输出、L30–34 无输出、L1–60 行数 60、两种冒烟模式恰 L61、七阶段标题序列全等、复选框 7、陷阱数据行 12）。落地口径三项：①阶段 7 保留原「报告 + 截图归档到项目约定位置」条目不动，其后追加运行目录归档、用例回写 2 条（与 reference §7.2 新口径并存不冲突）；②阶段 5 四条纪律由 §6.5 六条合并而来（「顺序执行」与「即时回填」合 1 条，「收尾回写与全量核对」落阶段 7 与验收口径）；③主会话定稿措辞范围 = 核心原则 3、阶段 3 五步与卡点句、模式表 4 行精简文案、陷阱 11/12、验收 +2、收尾 +2（详版权威仍在 reference §6.1）。**V2 断言口径修正见 R2**（⑤ V2 命令已就地改为分区间版）。

### 组 3　project-profile-template.md

1. §7 表（L74–76）后加 blockquote：`> 本表是用例库的输入：编写 / 补充 smoke/cases.md 时，按「功能 → 入口路径 → 前置数据」逐行转成用例（格式见技能 reference §6.3）。`
2. §9 表（L86–91）重写为 5 数据行（用例库 / 运行目录 / 截图 / 本画像覆盖 / 测试数据清理），内容见 ③；「本画像覆盖」行明确「留空 = 默认 smoke/ 约定」。

> **终形态（组 3 完成 · 2026-11-19，主会话核对通过）**：实测 94 行（蓝图「约 96」为估算）；V7/V8 全绿（主会话复跑复核：§0–§9 标题集合 diff 无输出、§9 表格行 7、blockquote 关键句在）。落地口径两项：①blockquote 采用 ⑤组 3 逐字句（`smoke/cases.md` 加反引号属行文风格，语义与 tasks.md 括注一致）；②§9「运行目录」行单元格内联竖线按 GFM 转义为 `\|`（`<full\|任务号>`——否则破坏列数并触发 V8 pipe-lint；渲染后仍显示 `full|任务号`，`<>` 路径已按 R1 在 code span 内）。§9 五行文案为主会话子代理按 ③ 契约自拟（蓝图只给 5 行主题）。

### 组 4　一致性核验（不新增文件，只跑断言）

1. **冻结区**：L1–2、L4–60 与 HEAD 逐字节一致；L30–34 独立再证；L1–60 行数 = 60；L11 仅当待决 #1 放行时才允许变化。
2. **frontmatter**：L1–4 为 `---` / `name: smoke-testing-local-env` / `description: ` 单行 / `---`；`name` 不改（doctor 校验名=目录名）。
3. **七阶段**：7 个 `### 阶段 N　` 标题按序匹配期望列表；新小节恰在第 61 行。
4. **reference 结构**：§6.1–§6.5 恰 5 个；7 列表头恰 1 处；§8 数据行 = 23；§9 含 `smoke/`；既有节号集合无缺失（`comm -23` 旧→新为空）；A–G 七行原文仍在。
5. **模板**：§0–§9 标题集合不变；§9 表行数 = 7（表头 + 分隔 + 5 数据）。
6. **交叉引用**：SKILL.md 中每个 `§N` 都能在 reference.md（或 §0 → 模板）找到同名标题，无悬空。
7. **Markdown 表格**：三文件 pipe 计数一致（L410 转义后应为 0 报错）。
8. **工作区**：`git status --short` 仅 3 个目标 md 变化 + 既有脏改动 `dsh/profiles/web/` 三文件；symlink 指向不变；skctl 仍能解析 frontmatter（可选）。

> **终形态（组 4 完成 · 2026-11-19，执行半程收口）**：V1–V9 全部 exit=0（verify 子代理逐字跑 + 主会话按 ⑤ 原文口径复核 V6/V8/V9a 一致）；V10 可选经容器适配通过（`node tools/skctl/src/cli.ts --store ~/.agents list --all --desc` exit=0 且解析出新 description 单行含 4 触发词；原命令依赖宿主 skctl store，容器内无该路径）。V9a 实测口径：`git status --short` 排除 `dsh/profiles/web/` 后为 6 行 = 3 目标 md + 3 变更目录工件（design/code-design/tasks，tracked-modified 属执行期工件维护预期，无 untracked）——⑤ 原命令排除规则已按 R3 就地修正。**勾选时序留痕**：tasks.md 4.1 勾选发生于 13:53 主会话 R1 附录编辑（误先行），组 4 实际核验完成于 14:07、主会话 14:10 补复核成立，勾选保留。补充交叉证据：三文件共用关键路径（cases.md/runs/.gitignore）齐备；reference 与模板内部 § 引用全可解析；R1 复核三文件围栏外 0 裸 `<>` 日期路径（模板 L1 `<项目名>` 为 HEAD 既有非日期路径）。

### 验证映射（需求/不变量 → 具体命令或断言）

以下命令默认在 `/home/xuqinqin/develop/dotfiles` 执行。

**V1　description 单行 + 触发词齐全**

```bash
cd /home/xuqinqin/develop/dotfiles
awk 'NR==1 && $0!="---"{exit 1} NR==2 && $0!="name: smoke-testing-local-env"{exit 1}
     NR==3 && !/^description: /{exit 1} NR==4 && $0!="---"{exit 1}' \
  agent/skills/smoke-testing-local-env/SKILL.md
for w in 全量冒烟 复测 回归 上线前验收; do
  sed -n '3p' agent/skills/smoke-testing-local-env/SKILL.md | grep -qF "$w" || { echo "MISS $w"; exit 1; }
done
```

**V2　SKILL.md 冻结区（拆区间，全量 diff 必然失败于 L3）**

```bash
cd /home/xuqinqin/develop/dotfiles
# R2 修正（组 2 实测回写）：原字面版 `1,2p;4,60p` 必然败于 L11 授权替换（Q1/D9 裁决口径），
# 按裁决改为分区间逐字节断言（L11 允许变更，行数守恒另断言）。
diff <(git show HEAD:agent/skills/smoke-testing-local-env/SKILL.md | sed -n '1,2p;4,10p;12,60p') \
     <(sed -n '1,2p;4,10p;12,60p' agent/skills/smoke-testing-local-env/SKILL.md)      # 期望：无输出
diff <(git show HEAD:agent/skills/smoke-testing-local-env/SKILL.md | sed -n '30,34p') \
     <(sed -n '30,34p' agent/skills/smoke-testing-local-env/SKILL.md)              # 期望：无输出
test "$(sed -n '1,60p' agent/skills/smoke-testing-local-env/SKILL.md | wc -l)" = 60
diff <(git show HEAD:agent/skills/smoke-testing-local-env/reference.md | sed -n '1,18p') \
     <(sed -n '1,18p' agent/skills/smoke-testing-local-env/reference.md)           # 期望：无输出
```

**V3　新小节落位与七阶段**

```bash
cd /home/xuqinqin/develop/dotfiles
test "$(grep -n '^## 两种冒烟模式' agent/skills/smoke-testing-local-env/SKILL.md | cut -d: -f1)" = 61
expected=$(printf '%s\n' '### 阶段 1　环境侦察（不可跳过）' '### 阶段 2　零侵入链路' \
  '### 阶段 3　准备测试用例（不可跳过）' '### 阶段 4　数据准备' \
  '### 阶段 5　按用例逐项执行' '### 阶段 6　三层证据' '### 阶段 7　归档收尾')
[ "$(grep -E '^### 阶段 [0-9]　' agent/skills/smoke-testing-local-env/SKILL.md)" = "$expected" ]
test "$(grep -c '^- \[ \]' agent/skills/smoke-testing-local-env/SKILL.md)" = 7
sed -n '/^## 高频陷阱/,/^## 验收/p' agent/skills/smoke-testing-local-env/SKILL.md | grep -cE '^\| [0-9]+ \|'   # 期望 12
```

**V4　reference §6 结构**

```bash
cd /home/xuqinqin/develop/dotfiles
f=agent/skills/smoke-testing-local-env/reference.md
grep -q '^## 6\. 测试用例：用例库与逐项执行$' "$f"
test "$(grep -cE '^### 6\.[1-5] ' "$f")" = 5
test "$(grep -cF '| 编号 | 用例 | 类型 | 前置 | 步骤 | 期望结果 | 证据要求 |' "$f")" = 1
test "$(sed -n '/^## 8\./,/^## 9\./p' "$f" | grep -cE '^\| [0-9]+ \|')" = 23
test "$(sed -n '/^## 9\./,$p' "$f" | grep -cF 'smoke/')" -ge 1
git show HEAD:"$f" | sed -n '341,347p' | while IFS= read -r l; do grep -qF -- "$l" "$f" || echo "MISS: $l"; done   # 期望：无 MISS
```

**V5　reference 既有节号一个不少**

```bash
cd /home/xuqinqin/develop/dotfiles
comm -23 \
  <(git show HEAD:agent/skills/smoke-testing-local-env/reference.md | grep -oE '^#{2,3} [0-9]+(\.[0-9]+)?' | sort -u) \
  <(grep -oE '^#{2,3} [0-9]+(\.[0-9]+)?' agent/skills/smoke-testing-local-env/reference.md | sort -u)
# 期望：无输出（只允许新增 §6.1–§6.5）
```

**V6　交叉引用无悬空**

```bash
cd /home/xuqinqin/develop/dotfiles/agent/skills/smoke-testing-local-env
for r in $(grep -oE '§[0-9]+(\.[0-9]+)?' SKILL.md | tr -d '§' | sort -u); do
  if [ "$r" = 0 ]; then f=project-profile-template.md; else f=reference.md; fi
  grep -qE "^#{2,3} ${r//./\\.}(\\.| |$)" "$f" || echo "DANGLING §$r in $f"
done
# 期望：无输出
```

**V7　模板结构与 5 行归档表**

```bash
cd /home/xuqinqin/develop/dotfiles
t=agent/skills/smoke-testing-local-env/project-profile-template.md
diff <(git show HEAD:"$t" | grep -E '^## [0-9]') <(grep -E '^## [0-9]' "$t")   # 期望：无输出
test "$(sed -n '/^## 9\./,$p' "$t" | grep -cE '^\| .+ \| .+ \|$')" = 7
grep -q '本表是用例库的输入' "$t"
```

**V8　Markdown 表格竖线一致（含 L410 修复）**

```bash
cat > /tmp/pipe-lint.awk <<'AWK'
BEGIN { fence = 0; prev = 0 }
/^```/ { fence = !fence; next }
fence { next }
/^\|/ {
  n = 0
  for (i = 1; i <= length($0); i++) {
    if (substr($0, i, 1) == "|") {
      p = (i > 1) ? substr($0, i-1, 1) : ""
      if (p != "\\") n++
    }
  }
  if (prev != 0 && n != prev) printf "%s:%d: pipes %d != %d\n", FILENAME, FNR, n, prev
  prev = n
  next
}
{ prev = 0 }
AWK
cd /home/xuqinqin/develop/dotfiles/agent/skills/smoke-testing-local-env
awk -f /tmp/pipe-lint.awk SKILL.md reference.md project-profile-template.md   # 期望：无输出
```

**V9　触达面与工作区**

```bash
cd /home/xuqinqin/develop/dotfiles
git status --short | grep -v -e '^ M dsh/profiles/web/' -e 'openspec/changes/update-smoke-skill-case-first/'   # 期望：恰好 3 行（三份 md；R3：工件目录前缀一并排除——工件维护随批次提交属预期）
git diff --stat -- agent/skills/smoke-testing-local-env   # 期望：3 files changed
readlink -f ~/.agents/skills/smoke-testing-local-env       # 期望：<dotfiles>/agent/skills/smoke-testing-local-env
```

**V10　可选的 skctl 解析校验**（需 skctl 依赖已装；在 dsh 容器内或宿主 node 执行）

```bash
cd /home/xuqinqin/develop/dotfiles
node tools/skctl/src/cli.ts list --all --desc | grep -q 'smoke-testing-local-env'   # 期望 exit 0
```

---

## ⑥ 设计假设与未决项

| # | 假设 | 依据/影响 |
| --- | --- | --- |
| 1 | 「L1–60 不可动」的执行口径 = 行数恒 60、L1–2/L4–60 逐字节不变，L3 是决策 4 授权的唯一字节变化 | 与决策 4 相容的最小不变量；若按逐字节包含 L3，决策 4 无法执行（见 D9） |
| 2 | 新内容一律插在 L61 边界，实现用锚点匹配而非行号偏移 | 防实现期行号漂移；保证 L30–34 引用永久有效 |
| 3 | 运行目录日期取项目业务时区（画像 §0），不取容器本地时区 | 与 §5.5 时间断言口径一致；避免跨日归属歧义 |
| 4 | 截图/大文件直接放运行目录根，忽略规则用单层 glob | 与 decisions 目录树一致；`runs/*/*` 精确匹配运行目录深度 |
| 5 | cases.md 7 列固定，不新增状态列；废弃标记落在「用例」列 | 决策 6 的可实现形态；编号是唯一键 |
| 6 | record.md 结果值域固定 4 值；「观察项」= 用例可判通过但存在非阻断异常，须在 report 观察项节单列 | 与决策 1 的「通过/失败/N/A/观察项」对齐；不新增第五种状态 |
| 7 | 单任务「受影响条目」用能力组启发式筛选，不引入工具/脚本；编号集执行前落 record.md，用户在场时确认 | 风险 6 的处置方向；保持纯文档规程 |
| 8 | 不改 `scripts/`、`agent/skills/README.md`、`openspec/`、其他 skill | 本次范围边界；三份 md 之外零触达 |
| 9 | 本设计不产生 commit；实现、提交与落档由 spec-apply / 执行流程管理 | 阶段 1.7 只出蓝图 |
| 10 | 验证以 ⑤ 的命令/断言为准，不接受「已实现/正常」类描述 | 行为约束二条 |
| 11 | 产品域示例行（手机号登录、需求发布）只示范格式，实际项目按画像填写 | 与参考文档现有示例域一致 |
| 12 | SKILL.md「何时使用」（L39–44）与「配套文件」表（L15–22）也在冻结区内，不补「复测/回归」字样、不列 `smoke/` | 触发场景由 L3 description 的触发词承担；`smoke/` 的可发现性由新小节、核心原则与阶段 3 的 reference §6 引用承担 |

**未决项**：2 项，见下节「待决问题」（L11 冻结区冲突、建库忽略规则落点）。除此之外无待决。

---

## 待决问题（六字段之外）

### Q1　SKILL.md L11「六阶段」一句话与新七阶段流程的冲突

- **问题**：L11 位于硬约束 L1–60 冻结区内，原文写死六阶段（`环境侦察 → 零侵入链路 → 数据准备 → 浏览器执行 → 三层证据 → 归档收尾`）。不放行修改，则「概述」与改造后的「流程」（七阶段）长期自相矛盾；放行则突破字面约束。
- **选项**：
  - **A. 放行 L11 同行替换**（1 行 → 1 行，文本换成七阶段；行号零位移，L12–60 与 L30–34 均不动）。**推荐。**
  - B. 严守 L1–60 字节不变，在 L61 新小节里加一句「规程已扩为七阶段」——文档仍自相矛盾，且读者要读到第二屏才发现。
  - C. 严守不变、接受概述滞后（只让流程体现七阶段），并在验收口径注明已知偏差。
- **推荐理由**：L11 不被任何活跃变更按行号引用（唯一引用是 L30–34 与 reference.md:19）；同行替换不改变任何行号，实质风险为零，而文档一致性收益明确。
- **影响面**：A 需把 V2 断言改成「L1–2/L4–10/L12–60 逐字节不变 + L11 允许变更 + 行数 60」；B/C 需在验收口径写「概述滞后」的已知偏差，且后续每次读 skill 都要额外解释。

### Q2　建库忽略规则的落点（`smoke/.gitignore` / 项目根 `.gitignore` / 指定 ignored 目录）

- **问题**：决策 5 要求「图片等二进制 gitignore、markdown 入库」，但没指定忽略规则写在哪；而 reference §2.5 红线写明「不改宿主任何项目配置/入库文件（含 .gitignore）」。
- **选项**：
  - **A. 新建 `smoke/.gitignore`**（模式相对 smoke/ 解析，单层 glob；零触碰项目根配置，红线不受影响）。**推荐。**
  - B. 建库时改项目根 `.gitignore`（一次性，但与 §2.5 字面冲突，需同时修订红线或在流程里向用户申请）。
  - C. 不建忽略文件，截图落到画像约定的已 ignored 目录（退化为两套归档口径，与决策 5 的运行目录收纳冲突）。
- **推荐理由**：A 同时满足「运行目录收纳」与「零侵入」，把忽略规则变成用例库资产的一部分，删库即删规则。
- **影响面**：A 需在 reference §6.4、SKILL.md 阶段 3 与模板 §9 三处写明 `smoke/.gitignore`；B 需先改 §2.5 并获用户确认（改动面更大）；C 需改 §7.2 与模板 §9，等于弱化决策 5。

---

## 附：阶段 1.75 界面演示（判定与确认）

1.75 未触发：需求触达对象为三份 markdown 规程文档（SKILL.md/reference.md/project-profile-template.md），无页面、组件、布局或视觉改版——C1（界面产出）不成立，命中排除表「纯后端/CLI/配置/脚本（C1 不成立）」同构行。
