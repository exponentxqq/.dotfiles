# Tasks

> 执行批次契约：组间严格串行（1→2→3→4），组内单任务（各触达单一文件）。验证命令均在 `/home/xuqinqin/develop/dotfiles` 执行；V1–V10 完整命令见本变更目录 `code-design.md` ⑤验证映射（权威）。

## 1. reference.md §6 扩造与 §7/§8/§9 联动

- [x] 1.1 按 code-design.md ①触达面第 2 行（reference.md）与 ⑤组 1 要点扩造：§6 整节替换为「测试用例：用例库与逐项执行」5 子节（§6.1 模式与范围 / §6.2 能力组 A–G 原块逐字节保留 / §6.3 用例库 cases.md / §6.4 运行目录与 smoke/.gitignore / §6.5 执行纪律），§7.1 加 scope 与分组汇总表、§7.2 重写为运行目录收纳（存量 openspec 约定降为画像 §9 覆盖示例）、§7.4 追加「预期入库改动」白名单段、§8 表尾追加第 22/23 行并转义 L410 内联竖线、§9 表尾追加 smoke/ 字段行；验证：`f=agent/skills/smoke-testing-local-env/reference.md; grep -q '^## 6\. 测试用例：用例库与逐项执行$' "$f" && test "$(grep -cE '^### 6\.[1-5] ' "$f")" = 5 && test "$(grep -cF '| 编号 | 用例 | 类型 | 前置 | 步骤 | 期望结果 | 证据要求 |' "$f")" = 1 && test "$(sed -n '/^## 8\./,/^## 9\./p' "$f" | grep -cE '^\| [0-9]+ \|')" = 23 && git show HEAD:"$f" | sed -n '341,347p' | while IFS= read -r l; do grep -qF -- "$l" "$f" || echo "MISS: $l"; done` 输出无 MISS 且整体退出码 0（即 V4），另跑 V5 节号 comm 断言无输出

## 2. SKILL.md 规程改造

- [x] 2.1 按 code-design.md ①触达面第 1 行（SKILL.md）与 ⑤组 2 要点改造：L3 description 同行替换（补能力句与触发词「全量冒烟、复测、回归、上线前验收」，仍单行）、L11 同行替换为七阶段概述；L60 后插入「## 两种冒烟模式：全量 smoke 与单任务 smoke」小节（恰第 61 行）；核心原则插第 3 条「用例先行，逐项执行」并顺延编号；新「### 阶段 3　准备测试用例（不可跳过）」+ 原阶段 3–6 顺延为 4–7（阶段 5 改名「按用例逐项执行」并前置 4 条执行纪律，原 6 条浏览器要点原样保留，阶段 7 追加运行目录归档与用例回写两条）；陷阱表改 Top 12 追加 2 行；验收口径改 6 条；收尾清单 5→7 项；验证：V1（L1–4 frontmatter 结构 + L3 含全部新触发词）+ V3（`grep -n '^## 两种冒烟模式' … | cut -d: -f1` = 61、七阶段标题序列全等、`grep -c '^- \[ \]'` = 7、陷阱数据行 = 12）+ V2 冻结区（`diff <(git show HEAD:agent/skills/smoke-testing-local-env/SKILL.md | sed -n '1,2p;4,10p;12,60p') <(sed -n '1,2p;4,10p;12,60p' agent/skills/smoke-testing-local-env/SKILL.md)` 无输出、L30–34 独立 diff 无输出、L1–60 行数 = 60）

## 3. project-profile-template.md 更新

- [x] 3.1 按 code-design.md ①触达面第 3 行（project-profile-template.md）与 ⑤组 3 要点更新：§7「用例入口」表后追加 blockquote「本表是用例库的输入（按功能→入口路径→前置数据逐行转成用例，格式见技能 reference §6.3）」；§9 归档约定表由 4 数据行重写为 5 行（用例库 cases.md / 运行目录 runs / 截图忽略 / 本画像覆盖说明「留空 = 默认 smoke/ 约定」/ 测试数据清理）；验证：`t=agent/skills/smoke-testing-local-env/project-profile-template.md; diff <(git show HEAD:"$t" | grep -E '^## [0-9]') <(grep -E '^## [0-9]' "$t")` 无输出（§0–§9 标题集合不变）`&& test "$(sed -n '/^## 9\./,$p' "$t" | grep -cE '^\| .+ \| .+ \|$')" = 7 && grep -q '本表是用例库的输入' "$t"`（即 V7）

## 4. 一致性核验（跨文件断言，不新增改动）

- [x] 4.1 跑 code-design.md ⑤验证映射 V1–V9 全量断言（V10 可选）：V6 交叉引用无悬空（SKILL.md 每个 §N 在 reference.md/模板有同名标题）、V8 表格竖线 awk 一致（含 L410 转义后 0 报错）、V9 工作区（`git status --short | grep -v '^ M dsh/profiles/web/'` 恰好 3 行且均为三份目标 md、symlink `readlink -f ~/.agents/skills/smoke-testing-local-env` 指向 dotfiles 实体）；验证：各断言命令退出码 0 且无输出（V6/V8/V9 详命令见 code-design.md ⑤）；发现任一断言失败回组 1–3 修复后重跑本组

---

## 附录：执行期留痕（R<n>）

- **R1　围栏外行内路径含 `<YYYY-MM-DD>` 一律 code span 包裹**（2026-11-19，组 1 收尾，用户裁决选 B）：依据——CommonMark 将裸 `<YYYY-MM-DD>` 解析为原始 HTML 标签，GitHub 等渲染器吞段（raw 文本与 agent 读取不受影响）；适用范围——reference.md §6.4 标题已修（路径加反引号，复跑 V4/V5/L1-18 全绿），§6.1 表格与 §7.2 正文原本已有 code span 无需动；连锁面——**组 2** SKILL.md 新小节凡写 `runs/<YYYY-MM-DD>-full/` 类路径一律 code span；**组 3** 模板同此口径；**组 4** 核验时顺带确认三文件围栏外无新增裸 `<>` 日期路径。
- **R2　V2 冻结区断言以分区间版为准**（2026-11-19，组 2 收尾）：依据——Q1 落档裁决「L11 同行替换放行 + V2 拆 L1–2/L4–10/L12–60 逐字节 + L11 允许变更 + 行数 60」（design.md D9 同旨）；组 2 实测 ⑤ 字面版 `1,2p;4,60p` exit=1 且唯一差异行 = L11 授权替换；适用范围——所有后续 V2 执行（尤其组 4 全量断言）；连锁面——code-design.md ⑤ V2 命令块已就地修正为分区间版并注明依据，tasks.md 4.1 引用的「V1–V9」以修正后为准。
- **R3　V9a 工作区断言排除规则补工件前缀**（2026-11-19，组 4 收口）：依据——组 4 实测执行期工件维护使 `openspec/changes/update-smoke-skill-case-first/{design,code-design,tasks}.md` tracked-modified（执行环境块、勾选、R 留痕、终形态化均随批次提交入库，属预期），⑤ 原口径「排除 web 后恰好 3 行」不可达；规则——排除集合追加 `openspec/changes/update-smoke-skill-case-first/` 前缀，期望仍为恰好 3 行且均为三份目标 md；适用范围——本变更 V9 全部后续执行（含 spec-done 归档前复验）；连锁面——code-design.md ⑤ V9 命令已就地修正；spec-done 复验读修正版。

## 附录：沉淀回流清单（spec-done 六要素汇报读此节）

- **执行期改动的入库文件（全部随最后批次提交，无遗留未提交待决）**：
  - 目标实现：`agent/skills/smoke-testing-local-env/{SKILL.md, reference.md, project-profile-template.md}`（dotfiles 根仓主检出 @ master）
  - 变更工件：`openspec/changes/update-smoke-skill-case-first/{design.md（执行环境块）, code-design.md（V2/V9 就地修正 + 组 1–4 终形态）, tasks.md（勾选态 + R1–R3 + 本清单）}`
- **波及其他工作流仓文件**：无（未触 `dsh/`、`scripts/`、其他 skill；`dsh/profiles/web/{package.json,pnpm-lock.yaml}` 为会话前既有无关脏改动，未触碰）
- **裁决与偏差索引**：R1（用户裁决 B）/ R2（Q1 裁决落实）/ R3（实测口径修正）/ 组 1–4 终形态段（code-design.md ⑤ 内四处 blockquote）
- **spec-done 收尾提示**：非隔离收尾轻量路径（直用主工作区，无 worktree 清理八步）；归档暂存纪律照 spec-done 红线（工件提交只含本变更目录 + 三份 md，排除既有脏改动）。
