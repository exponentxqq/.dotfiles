# Design

## Context

- 基线 `BASE=a3412d793b3bb3db5e9a5e9b4f08928a4ce3d870`（=落档时 HEAD；断言一律与 BASE 比对，不与移动的 HEAD 比）。
- 冻结区（主规格「文档结构兼容约束」Requirement，规格级）：SKILL.md L1–60、reference.md L1–18 逐字节不变；reference 既有节号 §1–§9 全部子节一个不少、不新增子节；`reference.md:19` 受独立行号引用 SHALL 保护。
- cases.md 七列资产契约与 `<组>-<两位序号>` 编号体系零改动；主规格既有 8 条 Requirement 零删除零改写。
- 外部在途脏项 7 个（`dsh/profiles/web/` 3、`add-subagent-control-and-coordination` 3、未跟踪 `agent/skills/spec-apply/refs/coordination.md` 1）——不触碰、不暂存、不清理，全部提交走精确路径。
- **栈识别结论**：本变更触达面全部为 skill Markdown 文档与文档内嵌脚本；dotfiles 无 Spring/Nuxt 特征（无 `pom.xml`/`build.gradle`、无 `nuxt.config.*`），用户指认 **`writing-skills`**（聚合层 `~/.agents/skills/writing-skills` 实存）。其「重参考外移为独立文件」「交叉引用不用 `@`」「description 只写触发条件」「结构模板优先于禁令（Match the Form to the Failure：遗漏必填元素用结构槽位而非禁令防）」为本设计硬约束；验证形态取「检索（V3）+ 应用演练（V9）」而非压力场景。

> 本文件承载设计期结论摘要；**代码级蓝图（触达面逐文件清单、file:line 证据锚、锚点 old/new 串、正则前后形态、V1–V9 断言全文、提交序列全文）的权威副本 = 本目录 [code-design.md](code-design.md)**（阶段 1.7 产物，随落档复制入库）；收敛留痕见 [diff-matrix.md](diff-matrix.md)。

## Goals / Non-Goals

**Goals:**

- 用户给定的「五步工作法 + 三段式输出格式」原义完整固化为独立标准文件，一次性全覆盖（含接口型 8 项 / 页面型 6 项附加覆盖、P0/P1/P2 三档定义、TC-001 递增、两条红线、待确认纪律）。
- skill 文档结构收敛为「根入口 + `refs/` 参考子目录」：`reference.md`、`project-profile-template.md`、`test-case-design.md` 归入 `refs/`（前两者 git mv 纯移动），`SKILL.md` 与 `scripts/` 留根——落档后用户裁决并入本次变更完成（D15）。
- 三处指路接线语义各覆盖一条读者路径：SKILL.md L108（阶段 3 建库动作点）、`refs/reference.md` §6.2 后（能力组→七列接缝）、`refs/project-profile-template.md` §7 L79（用例入口转写点）。
- 11 列设计稿 → 七列入库的收敛规则可机械执行（「证据要求」列有派生规则，四列不迁移有显式声明）。
- D6 顺带修使路由自检在真实 block-style 白名单下可用（并兼容 flow 形态回摆）。

**Non-Goals:**

- 不改 cases.md 七列契约、编号体系、`smoke/.gitignore` 约定；不为任何项目仓建库。
- 不改 SKILL.md L3 触发词；L15–22 配套文件表中仅 L19/L20 为授权链接行（链接目标更新，行数与表格结构不变），新文件仍不登记该表（已知缺口以 L108 指路补偿，留痕防后人误扩冻结区改动）。
- 不给 spec-plan 加 spec delta（其主规格 13 条 Requirement 零管辖自检；D6 顺带修边界 = 只改 routing.md）。
- 不迁移 P0/P1/P2、TC 编号、覆盖需求/规则、备注四列入库；优先级不影响执行顺序。
- 不触碰 add-ui-demo-gate 变更工件（其对 `reference.md:19` 的路径引用随迁移失效，行号与内容不变，见 Risks）。

## Decisions

| # | 决策 | 被否方案与理由 |
| --- | --- | --- |
| D1 | SKILL.md L108 **行尾同行追加**指路半句（188 行不变，L109+ 零位移） | 否「新增列表行」（189 行，L109+ 全体 +1，任何未来行号引用都要重算）；否「改 L3 触发词」（L1–60 冻结区，用户已裁不改） |
| D2 | 三段式**分级**：建库/直接交付 = 完整三段式；单任务补新用例 = 增量（新增用例行 + 一句话覆盖说明） | 否「全场景完整」（已有 40 条库补 1 条要重抄 90% 旧库）；否「全场景增量」（建库漏测试点清单与覆盖说明，直接交付缺风险段） |
| D3 | 三处指路点位 = L108 / §6.2 码块后 / 模板 L79；SKILL 与 reference 用相对链接，**模板用纯文本文件名** | 否「reference 放 §6.3 后」（与七列正文混读，诱发 cases.md 有 11 列的误读）；否「模板 L91 第四处」（归档约定非用例生成入口）；否「模板用链接」（模板复制到项目仓后相对链必断） |
| D4 | P0/P1/P2 **仅设计期口径**，执行仍按编号升序（reference §6.5） | 否「执行期 P0 优先」（需改主规格「逐项执行纪律」，且编号集顺序与升序打架使收尾核对歧义；时间紧正确做法 = 人工按 P0 筛子集，集内仍升序） |
| D5 | 「证据要求」列按**测试类型 + 模块依 reference §5.1 三层证据口径派生**（接口型以网络+持久化为主，页面型三层齐） | 否「11 列加第 12 列」（改用户给定格式，失去收敛动作）；否「留空执行期再想」（单层证据假通过——正是用户要防的不规范） |
| D6 | routing.md L49 单行 → **4 行双形态正则**（flow + block、行首锚定、Set 去重） | 否「只认 block」（把当前形态写死，下次回摆再犯）；否「YAML 结构化解析」（`cordis.patch.yml` L204 含 `!!js` 自定义 tag，解析告警且被无关节 YAML 合法性绑架）；否「不锚定行首」（注释行入选 = 假通过，比误报更危险）。实测：旧脚本白名单 0 项/13 路由全误报/exit 1 → 新脚本 8 项/13 条/OK/exit 0 |
| D7 | tasks **4 组**：组1 新文件 / 组2 接线+断言 / 组3 D6 修复 / 组4 归档；组间串行 | 否「D6 并入组2」（skill 文档交付与 D6 修复无法分别回滚、归因污染）；否「落档设组0」（落档是 spec-plan 阶段 2 本身，写进 tasks 致执行侧重复落档）；组1/组3 虽零文件交集但同记 tasks.md，不并行 |
| D8 | 归档提交 **`git add -u` 旧目录 + 精确 add 归档目录/主规格** | 否「先例 `git add -A openspec`」（当前 openspec/ 下有他会话 3 个在途脏文件，`-A` 会卷入他人半成品） |
| D15 | **文档子目录化（落档后用户裁决并入）**：`reference.md`/`project-profile-template.md`/`test-case-design.md` 归 `refs/`（前两者 git mv 纯移动），SKILL.md 与 scripts/ 留根；SKILL.md 冻结区授权 L19/L20/L57 三行仅更新链接目标；spec delta MODIFIED「文档结构兼容约束」承载授权 | 否「维持平铺」（用户裁决子目录化）；否「只新文件进 refs/」（新旧分裂的混合结构，用户要求对 skill 整体做）；否「另立变更」（用户明确本次变更内一并完成）；否「迁移同时改写文档内容」（纯移动与内容编辑分离，归因清晰） |

收敛期六决议（触发词不改 / 分级三段式 / 同行追加 / 仅设计期 / 模板加第三指路 / 顺带修 routing.md）与三分类矩阵、裁定依据的完整留痕见 [diff-matrix.md](diff-matrix.md)；代码级全部决策（D1–D14）见 [code-design.md](code-design.md) ④。

## Risks / Trade-offs

- [新文件对非冒烟语境不可达（L3 无用例设计触发词）] → D1 已裁：限定被测项目/冒烟语境内或用户点名文件；已知取舍留痕。
- [add-ui-demo-gate 对 `reference.md:19` 的路径引用随 refs/ 迁移失效] → 不触碰其工件；MODIFIED 约束已把行号引用锚定到 `refs/reference.md:19`；proposal Impact 留痕提示其剩余任务按新路径解析；内容零改动保证行号语义不变。
- [冻结区断言复杂化（三行授权开口）] → V1 重写为「授权行外逐字节一致 + 授权行新内容逐字断言 + 纯移动 diff 为空」三层；授权范围写死在 MODIFIED Requirement 内，超出即断言失败。
- [11 列设计稿与七列库表双表述漂移] → 双向对账映射表（12 行）+ V3/V4 断言 +「待确认未决不入库」+「执行期不回补设计稿」声明。
- [他会话并发卷入提交] → 全部提交精确路径（skill 目录整目录 add 前先 `git status` 核对该目录无外来改动）；组 4 干净窗口白名单核对（含未跟踪 `coordination.md`，Q1 已裁按外部在途）；归档禁 `git add -A openspec`。
- [锚点漂移（他人先改 skill 文件）] → 每处编辑前 `grep -cF` 锚串唯一性检查，失败即停（保护性失败），重取 BASE 重新对表。
- [行数预算超限] → ≤160 硬上限 + V3 模板完整性断言双保险；超限砍示例行不砍模板与清单。
- [新文件无分发侧门禁的假设不成立] → 未查到任何行数/码点门禁（reference.md 583 行长期在分发）；若实施时遇校验，回退 = 压缩示例与注释，不动内容清单。

## Migration Plan

提交序列 4 步（全部精确路径，全文见 code-design.md ③3.8）：① `docs(openspec): 落档 add-test-case-design-standard`（四件套 + 两材料）→ ② `feat(skills): 增补测试用例设计标准`（skill 4 文件 + tasks 勾选）→ ③ `fix(skills): 修正 spec-plan 路由自检白名单解析`（routing.md + tasks 勾选）→ ④ `docs(openspec): 归档 add-test-case-design-standard`（`git add -u` 旧目录 + 归档目录 + 主规格 sync）。回滚：②③ 独立提交可分别 `git revert`；skill 分发为 symlink，回滚即时生效。

## Open Questions

- ~~Q1：未跟踪文件 `agent/skills/spec-apply/refs/coordination.md` 是否按「外部在途」处理？~~ **已决（落档分歧点提问，2026-11-19）**：按外部在途处理——不触碰、不暂存、不清理；组 4 干净窗口白名单纳入第 7 项；外部在途台账记 7 项（`dsh/profiles/web/` 3 + `add-subagent-control-and-coordination` 3 + 本文件 1）。
