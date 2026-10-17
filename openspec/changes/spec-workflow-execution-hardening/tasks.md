# Tasks

## 1. spec-plan 侧落档校验与 routing 修正

- [x] 1.1 按触达面 T1 修订 agent/skills/spec-plan/SKILL.md：第七节④步扩「两材料断言 + validate」（步名与断言指针，逐字文本见 code-design.md (b)）；验证：grep -c '两材料断言' agent/skills/spec-plan/SKILL.md 输出 1，且 python3 -c "assert len(open('agent/skills/spec-plan/SKILL.md',encoding='utf-8').read())<=7849" 退出码 0
- [x] 1.2 按触达面 T2 修订 agent/skills/spec-plan/refs/planning.md：落档细节第 4 步整步替换为两段式校验（先 test -f 两材料、再 validate --strict）；验证：grep -o 'test -f openspec/changes/<change>/' agent/skills/spec-plan/refs/planning.md | wc -l 输出 2（验证句更正见 R1：grep -c 按行计数，同行双锚点改用出现次数口径，用户裁定 A），且同文件 python3 码点断言 ≤7849 退出码 0
- [x] 1.3 按触达面 T5 修订 agent/skills/spec-workflow/refs/routing.md：L13/L35/L36 三处 provider 名 zai→zai-coding-cn（行内其余字节不动，L28 的 `{zai,...}.json` 不触碰）；验证：grep -c 'zai-coding-cn' agent/skills/spec-workflow/refs/routing.md 输出 3，grep -En 'provider: zai[,}]' 该文件退出码 1，grep -En '`zai/glm' 该文件退出码 1
- [x] 1.4 按触达面 T5b 修订 agent/skills/spec-plan/refs/routing.md：schema 示例 L9/L10/L11 三处 provider: zai→zai-coding-cn（Q-A 裁定；:30 pi-ai 路径 `{zai,...}.json` 不触碰）；验证：grep -En 'provider: zai[,}]' agent/skills/spec-plan/refs/routing.md 退出码 1（零命中），且该文件 python3 码点断言 ≤7849 退出码 0

## 2. spec-workflow 执行侧正文强化

- [x] 2.1 按触达面 T3 修订 agent/skills/spec-workflow/SKILL.md：五处节改动（②能力自检加 openspec-verify-change、⑤恢复协议插第 4 步落档副本存在性检查并重编号原 4/5/6→5/6/7、⑥骨架行组收尾首加勾选核对、⑦原④拆归档前校验+归档两步并原⑤⑥→⑥⑦、⑩绝不做末条改多仓分立提交），逐字文本见 code-design.md (b)；验证：grep -c '落档副本存在性检查' = 1、grep -c 'openspec-verify-change' = 2、grep -c '勾选核对' = 1、grep -c '汇报五要素' = 1、grep -c '分立提交' = 1（均在 agent/skills/spec-workflow/SKILL.md），且码点断言 ≤7849 退出码 0
- [x] 2.2 按触达面 T4 修订 agent/skills/spec-workflow/refs/execution.md：六处条目注入（多仓分立提交＋外部仓外溢口径替换原嵌套子仓条、组收尾清单首插勾选核对、组段终形态化条末加落档副本前提句、R<n> 模板扩连锁面＋推翻标注、验证与归档派发要点第 4 步拆归档前校验/归档并原 5/6→6/7、最终汇报四→五要素含沉淀回流清单），逐字文本见 code-design.md (b)；验证：grep -c '多仓分立提交' = 1、grep -c '外部仓外溢口径' = 1、grep -c '勾选核对' = 1、grep -c '前提——落档副本在变更目录' = 1、grep -o '连锁面' <该文件> | wc -l = 2（R1/R2 口径：单行双锚点，行口径 grep -c 只得 1）、grep -c 'openspec-verify-change' = 1、grep -c '沉淀回流清单' = 1（均在 agent/skills/spec-workflow/refs/execution.md），且码点断言 ≤7849 退出码 0

## 3. 全量验证与一致性复核（只读）

- [x] 3.1 按触达面 T1~T5b 做机械断言复核：python3 单脚本逐文件断言 6 个修订文件 len ≤7849 且 code-design.md (b) 节全部 grep 锚点按预期计数命中（含 2.2 的 连锁面=2、2.1 的 openspec-verify-change=2）；验证：该脚本退出码 0
- [x] 3.2 按触达面 T1~T5b 做流程断言：「多仓分立提交」三处语义同源断言（R3 口径）——agent/skills/spec-workflow/SKILL.md grep -c '分立提交' = 1、agent/skills/spec-workflow/refs/execution.md grep -c '多仓分立提交' = 1、openspec/changes/spec-workflow-execution-hardening/specs/spec-workflow/spec.md `grep -o '多仓分立提交' | wc -l` = 3 且 grep -c '### Requirement: 多仓分立提交' = 1；openspec validate spec-workflow-execution-hardening --strict 退出码 0；git status --porcelain 相对本批开始时快照（基线 /tmp/spec-workflow-exec-hardening-baseline-status.txt），新增改动行仅限 6 个目标文件与变更目录 tasks.md/code-design.md 两工件（执行期勾选与组段终形态化），无其他新增（spring-writer/SKILL.md 与 dsh/spec-workflow.yaml 已随 176e3c6 入库、不在 status；cordis.patch.yml 既有脏行保持原样未卷入）

## Workflow follow-up

- 变更归档（全组勾选后）：`/spec-flow continue spec-workflow-execution-hardening` 接续执行 → 归档前经 openspec-verify-change 校验（本变更自身即新纪律首个适用样本）
- Q6 授权的沉淀单独提交：本变更落档提交后，把 `agent/skills/spring-writer/SKILL.md`（+2 条 T3.1 执行期勘误规则）与 `dsh/spec-workflow.yaml`（parallelism 3→8）按「T3.1 执行期沉淀」主题单独提交一次（用户 2026-10-16 授权）（已履行：commit 176e3c6）

## 执行期运行规则留痕

- **R1 验证句锚点计数口径**：`grep -c` 统计**匹配行数**；同一行出现多次的锚点须改用 `grep -o '<pattern>' <file> | wc -l` 计出现次数。依据：任务 1.2 逐字新文本为单行内双锚点（两处 `test -f openspec/changes/<change>/`），原验证句 `grep -c … 输出 2` 字面不可满足（实得 1）；用户裁定 A——修验证句口径、不动逐字合规实现（2026-10-16）。连锁面：tasks.md 1.2 行与 code-design.md (c) 表 1.2 行已同步更正；组 3 全量复核沿用更正后口径。
- **R2 派发要点重编号与设计稿笔误处置**：execution.md 验证与归档派发要点第 4 步拆分后，最终汇报步编号取 **7**（4 归档前校验 / 5 归档 / 6 归档单独提交 / 7 汇报五要素）——依处 5 重编号指令「原 5/6 → 6/7（含编号数字本身）」与 code-design.md (a) 定位表「原 5/6 顺延 6/7」，并与 SKILL.md 第七节「⑦汇报五要素」同构；code-design.md (b) T4 处 6 逐字块首编号「6.」系拆步前旧编号笔误（取 6 将与「6. 归档单独提交」重号），实现取 7、(b) 块已就地更正加注（2026-10-16，主会话裁定、R1 先例延伸，呈证审核时可推翻）。连锁面：tasks.md 2.2 与 (c) 表 2.2 行验证句「连锁面」同步为出现次数口径（R1）；2.2 的「连锁面」同行双锚点属 R1 第二实例。
- **R3 「多仓分立提交」跨文件断言口径**：该措辞三处语义同源但字面形态各异——spec-workflow/SKILL.md 侧为 `多仓**分立提交**`（(b) 逐字文本含粗体切分，连写子串零命中，断言用 `分立提交` = 1，与 2.1 同款）；execution.md 侧连写 `多仓分立提交` = 1；specs delta 按 (d) 结构强制三处（REMOVED Reason / Migration / ADDED Requirement 标题），断言出现次数 = 3 + Requirement 标题行 = 1。依据：3.2 原验证句「三处 grep -c 各 = 1」与设计 (b)/(d) 自相矛盾（实测 SKILL.md = 0、spec.md = 3），实现均逐字合规（2026-10-16，主会话裁定、R1 先例第三实例，呈证可推翻）。连锁面：tasks.md 3.2 行与 code-design.md (c) 表 3.2 行已同步更正；3.2 快照口径同步现实化（允许集合补两工件；spring-writer/yaml 已随 176e3c6 入库不再在 status）。
