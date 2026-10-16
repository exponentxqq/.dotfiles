# Tasks

## 1. spec-plan 侧落档校验与 routing 修正

- [ ] 1.1 按触达面 T1 修订 agent/skills/spec-plan/SKILL.md：第七节④步扩「两材料断言 + validate」（步名与断言指针，逐字文本见 code-design.md (b)）；验证：grep -c '两材料断言' agent/skills/spec-plan/SKILL.md 输出 1，且 python3 -c "assert len(open('agent/skills/spec-plan/SKILL.md',encoding='utf-8').read())<=7849" 退出码 0
- [ ] 1.2 按触达面 T2 修订 agent/skills/spec-plan/refs/planning.md：落档细节第 4 步整步替换为两段式校验（先 test -f 两材料、再 validate --strict）；验证：grep -c 'test -f openspec/changes/<change>/' agent/skills/spec-plan/refs/planning.md 输出 2，且同文件 python3 码点断言 ≤7849 退出码 0
- [ ] 1.3 按触达面 T5 修订 agent/skills/spec-workflow/refs/routing.md：L13/L35/L36 三处 provider 名 zai→zai-coding-cn（行内其余字节不动，L28 的 `{zai,...}.json` 不触碰）；验证：grep -c 'zai-coding-cn' agent/skills/spec-workflow/refs/routing.md 输出 3，grep -En 'provider: zai[,}]' 该文件退出码 1，grep -En '`zai/glm' 该文件退出码 1
- [ ] 1.4 按触达面 T5b 修订 agent/skills/spec-plan/refs/routing.md：schema 示例 L9/L10/L11 三处 provider: zai→zai-coding-cn（Q-A 裁定；:30 pi-ai 路径 `{zai,...}.json` 不触碰）；验证：grep -En 'provider: zai[,}]' agent/skills/spec-plan/refs/routing.md 退出码 1（零命中），且该文件 python3 码点断言 ≤7849 退出码 0

## 2. spec-workflow 执行侧正文强化

- [ ] 2.1 按触达面 T3 修订 agent/skills/spec-workflow/SKILL.md：五处节改动（②能力自检加 openspec-verify-change、⑤恢复协议插第 4 步落档副本存在性检查并重编号原 4/5/6→5/6/7、⑥骨架行组收尾首加勾选核对、⑦原④拆归档前校验+归档两步并原⑤⑥→⑥⑦、⑩绝不做末条改多仓分立提交），逐字文本见 code-design.md (b)；验证：grep -c '落档副本存在性检查' = 1、grep -c 'openspec-verify-change' = 2、grep -c '勾选核对' = 1、grep -c '汇报五要素' = 1、grep -c '分立提交' = 1（均在 agent/skills/spec-workflow/SKILL.md），且码点断言 ≤7849 退出码 0
- [ ] 2.2 按触达面 T4 修订 agent/skills/spec-workflow/refs/execution.md：六处条目注入（多仓分立提交＋外部仓外溢口径替换原嵌套子仓条、组收尾清单首插勾选核对、组段终形态化条末加落档副本前提句、R<n> 模板扩连锁面＋推翻标注、验证与归档派发要点第 4 步拆归档前校验/归档并原 5/6→6/7、最终汇报四→五要素含沉淀回流清单），逐字文本见 code-design.md (b)；验证：grep -c '多仓分立提交' = 1、grep -c '外部仓外溢口径' = 1、grep -c '勾选核对' = 1、grep -c '前提——落档副本在变更目录' = 1、grep -c '连锁面' = 2、grep -c 'openspec-verify-change' = 1、grep -c '沉淀回流清单' = 1（均在 agent/skills/spec-workflow/refs/execution.md），且码点断言 ≤7849 退出码 0

## 3. 全量验证与一致性复核（只读）

- [ ] 3.1 按触达面 T1~T5b 做机械断言复核：python3 单脚本逐文件断言 6 个修订文件 len ≤7849 且 code-design.md (b) 节全部 grep 锚点按预期计数命中（含 2.2 的 连锁面=2、2.1 的 openspec-verify-change=2）；验证：该脚本退出码 0
- [ ] 3.2 按触达面 T1~T5b 做流程断言：「多仓分立提交」在 agent/skills/spec-workflow/SKILL.md、refs/execution.md、openspec/changes/spec-workflow-execution-hardening/specs/spec-workflow/spec.md 三处 grep -c 各 = 1；openspec validate spec-workflow-execution-hardening --strict 退出码 0；git status --porcelain 相对本批开始时快照，除 6 个目标文件外无新增改动行（agent/skills/spring-writer/SKILL.md 与 dsh/spec-workflow.yaml 两处既有脏改动保持原样未卷入）

## Workflow follow-up

- 变更归档（全组勾选后）：`/spec-flow continue spec-workflow-execution-hardening` 接续执行 → 归档前经 openspec-verify-change 校验（本变更自身即新纪律首个适用样本）
- Q6 授权的沉淀单独提交：本变更落档提交后，把 `agent/skills/spring-writer/SKILL.md`（+2 条 T3.1 执行期勘误规则）与 `dsh/spec-workflow.yaml`（parallelism 3→8）按「T3.1 执行期沉淀」主题单独提交一次（用户 2026-10-16 授权）
