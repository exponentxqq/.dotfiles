# Design

## Context

`smoke-testing-local-env` skill（dotfiles 仓 `agent/skills/smoke-testing-local-env/`）现行六阶段规程无「先写用例」环节，用例矩阵只在收尾报告事后呈现。三文档现状：SKILL.md 156 行、reference.md 424 行、project-profile-template.md 91 行；容器 `~/.agents/skills/` 为 symlink，改动即对两 agent 生效。约束：活跃变更 `add-ui-demo-gate` 按行号引用 `SKILL.md:30-34` 与 `reference.md:19`，文档改造必须保住这些引用（动机见 proposal.md - Why；行为契约见 specs/smoke-testing-local-env/spec.md）。

完整代码级蓝图（证据锚逐条 file:line、结构契约全文、验证命令 V1–V10）在本变更目录的 `code-design.md`（阶段 1.7 产物副本，**权威**）；收敛过程见 `decisions.md`。本文件承载其六字段深度契约的断言级要点。

## Goals / Non-Goals

**Goals:**

- 「先有用例库、再按编号逐项执行」成为可判定规程：用例未落库不得开测、编号集未落运行记录不得执行。
- 用例与运行记录成为所测项目长期资产：`smoke/cases.md` 纯定义稳定，`smoke/runs/<运行>/` 历次独立可对比。
- 全量/单任务双模式的判定、范围与收尾差异在 skill 内自解释。
- 三文档改造后既有节号与行号引用（`SKILL.md:30-34`、`reference.md:19`）零破坏。

**Non-Goals:**

- 不改 `scripts/`（recon.sh、tcp-bridge.mjs）、`agent/skills/README.md`、`openspec/` 及其他 skill。
- 不做存量项目 `smoke/` 目录迁移；不为 skill 文档写自动化测试。
- 不引入用例管理工具/脚本——纯文档规程。

## 触达面清单（①）与证据锚（②）

| 文件（均在 dotfiles 根仓） | 量级 | 关键改动点（锚点详见 code-design.md ②，行号为 HEAD 版本） |
| --- | --- | --- |
| `agent/skills/smoke-testing-local-env/SKILL.md` | 中（156→约200） | L3/L11 同行替换（description 触发词；六阶段→七阶段）；L60 后插「两种冒烟模式」小节（恰在第 61 行）；核心原则插第 3 条并顺延；新阶段 3 + 原阶段 3–6 顺延 4–7（阶段 5 改名前置执行纪律）；陷阱 Top 12；验收 6 条；收尾 7 项 |
| `agent/skills/smoke-testing-local-env/reference.md` | 大（424→约550） | §6 改标题「测试用例：用例库与逐项执行」拆 §6.1–§6.5（A–G 块逐字节保留进 §6.2）；§7.1 进 scope 与分组汇总；§7.2 改运行目录收纳；§7.4 加预期入库改动白名单；§8 表 +2 行（顺带转义 L410 内联竖线）；§9 表 +1 行 |
| `agent/skills/smoke-testing-local-env/project-profile-template.md` | 小（91→约96） | §7 表后 blockquote「本表是用例库的输入」；§9 表 4 行重写为 5 行（用例库/运行目录/截图/画像覆盖/测试数据清理） |

关键证据锚（完整 27 条见 code-design.md ②）：`SKILL.md:11`（六阶段一句话，L1–60 冻结区）、`SKILL.md:61`（`## 核心原则`，新小节插入锚）、`SKILL.md:92`（原阶段 3 标题）、`reference.md:336`（§6 标题）、`reference.md:341-347`（A–G 块）、`reference.md:384`（洁净核验「禁止任何入库改动」，与回写用例库字面冲突 → 见决策 D8）、`project-profile-template.md:86-91`（§9 归档表）、`openspec/changes/add-ui-demo-gate/{code-design.md:100, tasks.md:5}`（行号引用来源）、`tools/skctl/src/doctor.ts:61-63`（frontmatter name 必须等于目录名 → name 不可改）。

## 结构契约（③：接口与数据形状）

- **`smoke/` 目录树**（所测项目仓，路径可被画像 §9 覆盖）：`cases.md`（入库）+ `.gitignore`（入库，随建库创建）+ `runs/<YYYY-MM-DD>-<full|任务号>/`（record.md + report.md 入库；`*.png/*.jpg/*.webp/*.gif/*.webm/*.har` 等二进制被 `runs/*/*.<ext>` 单层 glob 忽略）。
- **cases.md**：3 行 preamble（含「用例定义只增不删、结果不回填本文件」声明）+ 七列表头 `| 编号 | 用例 | 类型 | 前置 | 步骤 | 期望结果 | 证据要求 |`；编号 `<组>-<两位序号>`（组 ∈ A–G）；废弃注「（已废弃：原因）」于用例列；修订原地改行；前置列引用画像条目。
- **运行目录命名**：日期取业务时区（画像 §0）；`full` 小写字面量；任务号仅留字母/数字/`.`/`-`；同日冲突追加 `-2`、`-3`。
- **record.md 骨架**：头（项目/分支/commit、模式、环境、执行时间、所选用例编号集——执行前写入作执行清单）+ 逐项结果表（`| 编号 | 结果 | 证据 | 备注 |`，结果值域固定 4 值：通过/失败/N/A/观察项，证据用相对链接）+ 分组汇总表（组/总数/通过/失败/N/A/观察项）。
- **report.md 骨架**：复用 §7.1（scope 入标题；「二、用例结果汇总」放分组表并指向同目录 record.md）。
- **SKILL.md 新小节落位**：`## 两种冒烟模式：全量 smoke 与单任务 smoke` 恰在改后第 61 行；七阶段标题序列固定（`### 阶段 1　环境侦察（不可跳过）` … `### 阶段 7　归档收尾`，全角空格）。

## Decisions（④）

完整决策 D1–D10（各含被否方案与反例）见 code-design.md ④，要点：

- **D1** 模式小节插 L61 边界（`## 核心原则` 前），不内嵌流程阶段 3——保冻结区且阅读路径先模式后原则。
- **D2** 「用例先行，逐项执行」插核心原则第 3 条并顺延编号——原则顺序与流程顺序同构。
- **D3** reference §6 拆 5 子节（模式→能力组→用例库→运行目录→执行纪律）——读者见 `A-01` 时已知 A 是什么。
- **D4** 废弃标记落「用例」列、不加第 8 状态列——编号是唯一键，cases.md 保持纯定义。
- **D5** 同日同 scope 重跑追加 `-2` 绝不覆盖——保历次可比。
- **D6** 截图忽略规则落新建 `smoke/.gitignore`（单层 glob），不改项目根 `.gitignore`——与零侵入红线零冲突，删库即删规则。（落档分歧点 Q2 已确认此方案。）
- **D7** record.md 与 report.md 两文件并存不合并——受众不同（追溯明细 vs 用户结论），合并后验收无法分别判定。
- **D8** §7.4 增「预期入库改动」白名单（cases.md 修订、runs/**/*.md、首次建库 .gitignore）——否则「禁止任何入库改动」与「必须回写用例库」直接矛盾。
- **D9** 冻结区验证按行区间拆分（L1–2/L4–10/L12–60 逐字节 + L3/L11 同行替换断言 + 行数 60）——全量 diff 必然败于授权变更行。（落档分歧点 Q1 已确认放行 L11 同行替换。）
- **D10 栈识别结论**：writer skill 未命中——全仓无 `pom.xml`/`build.gradle(.kts)`/`nuxt.config.*`/`settings.gradle*`（find 实测无输出）；仓根无 package.json，全仓 5 个 package.json 均无 nuxt 依赖；spring-writer/nuxt-writer/dsh-plugin-writer 触发面（各自 SKILL.md:3-4）均未命中。**用户已确认本次豁免 writer 加载（仅本次有效）**，设计不受 writer 硬约束；结论随工件传递，执行侧不再依赖会话记忆。
- **执行环境**：直用主工作区。布局：dotfiles → 主检出 `/home/xuqinqin/develop/dotfiles` @ master；装配：无（纯 markdown 规程改动，`~/.agents/skills/smoke-testing-local-env` symlink 指向主检出实体，改动即时生效，无构建/依赖安装）；环境错开：无（不涉端口/数据库/不入库本地配置；主检出既有无关脏改动 `dsh/profiles/web/` 与本变更触达面 `agent/skills/` 零重叠，已向用户披露并经确认直用）；装载指纹：不适用（不改导出符号）；创建于 2026-11-19

## 逐任务组实现要点（⑤）

四组**串行**（与 tasks.md 分组一一对齐；实现一律锚点字符串编辑，禁止行号 sed）：

1. **组 1　reference.md §6 扩造 + §7/§8/§9 联动**：§6 整节替换为 5 子节（A–G 块逐字节保留）；§7.1 scope 与汇总表；§7.2 运行目录收纳重写；§7.4 白名单段；§8 +2 行与 L410 竖线转义；§9 +1 行。
2. **组 2　SKILL.md 规程改造**：L3/L11 同行替换；L61 新小节；核心原则插条顺延；新阶段 3 + 阶段顺延改名 + 执行纪律前置（原浏览器要点原样保留）；陷阱/验收/收尾清单扩容。
3. **组 3　project-profile-template.md**：§7 blockquote；§9 表重写 5 行。
4. **组 4　一致性核验**：冻结区拆区间 diff、七阶段标题全等、§6 结构与节号 comm 校验、交叉引用、表格竖线 awk、工作区与 symlink（命令即 code-design.md ⑤验证映射 V1–V10）。

## Risks / Trade-offs

- [实现期行号漂移破坏冻结区] → 实现用锚点匹配编辑；组 4 的 V2/V3 断言逐字节校验 L1–60 与第 61 行落位。
- [§6.1 模式表与 SKILL.md 新小节表格双写漂移] → SKILL.md 表为 4 行精简版并引用 reference §6.1（5 行详表唯一权威在 reference）。
- [存量项目无 smoke/ 时的引导断层] → 阶段 3 写明两条路径（复用/筛选 vs 现场建库），卡点句兜底「用例未落盘不得开测」。
- [cases.md 示例行被照抄成真实用例] → 示例行标注「只示范形态，内容随项目」，且 preamble 声明在建库时被读到。
- [全量 smoke 用例规模大导致 record 冗长] → 接受（历次可比是核心价值）；report 只放汇总收口。

## Migration Plan

纯 markdown 文档改动，symlink 即时生效，无部署步骤。回滚 = `git revert` 单提交。所测项目侧的 `smoke/` 资产由后续各项目首次冒烟时自然产生，无迁移动作。

## Open Questions

无——阶段 1.5 六项待决与阶段 1.7 两项上浮（L11 冻结区、忽略规则落点）均已在收敛/落档提问中裁决（见 `decisions.md` 与上文 D6/D9）。1.75 界面演示 gate 未触发（纯文档改动，C1 不成立），判定事实已留痕于 `code-design.md` 附录。

## 设计假设（⑥）

code-design.md ⑥ 列 12 项假设，关键项：L1–60 执行口径 = 行数 60 + L1–2/L4–60 逐字节不变 + L3/L11 授权替换；新内容一律插 L61 边界；运行目录日期取业务时区；截图放运行目录根用单层 glob 匹配；record 结果值域 4 值；「何时使用」（L39–44）与「配套文件」表（L15–22）在冻结区内不补复测/回归字样（触发召回由 L3 承担）。
