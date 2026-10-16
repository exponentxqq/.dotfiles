# Tasks

> 触达面：T1–T3 spec-plan 入口与 mode/、T4–T7 refs、T8–T9 spec-workflow 交叉改动、T10 主规格（归档经 delta 同步，不手改）。全部路径相对仓库根 `/home/xuqinqin/develop/dotfiles`；组间串行；每任务验证句第三方可核对。码点门限：spec-plan 入口文件 ≤7849（渲染 = 文件 + 343 ≤8192）、mode/ 与 refs/ 各文件 ≤8192。

## 1. spec-plan 入口与编排手册（T1–T3）

- [ ] 1.1 改写 `agent/skills/spec-plan/SKILL.md`（触达面 T1）：frontmatter 仅 description 微调（并行=team 驱动、串行=单线探索措辞）；§一 参数表（`--parallel` 行=team 驱动+按线回退、串行行=openspec-explore+grill-me）与「状态载体」句（code-design/diff-matrix/decisions 落档后权威在变更目录）；§四 重构「阶段 1 规划编排」（并行双线铁律与中转协议保留+适用范围注记、串行单线骨架、细节指向 mode/）；§五 概述改七步（并行）/grill-me 直收（串行）；§六/§七 输入材料分支与落档第①步扩「复制两份规划材料」；§二 ④ 自检加 openspec-explore；§八 路由适用性一句；§一 路由表加 mode/ 两行；验证：`python3 -c "s=open('agent/skills/spec-plan/SKILL.md',encoding='utf-8').read();assert len(s)<=7849,len(s);assert 'team 驱动' in s and 'openspec-explore' in s and 'decisions.md' in s;assert 'mode/parallel.md' in s and 'mode/serial.md' in s;assert '串行独立性弱于并行' not in s;print('cp=',len(s))"` 退出码 0

- [ ] 1.2 新建 `agent/skills/spec-plan/mode/parallel.md`（触达面 T2）：team 派发流程（spawn_teammate、命名、context fresh、提示模板=自 planning.md 迁移的 subagent 模板改引擎段）、5 条不可行判据与按线回退、双引擎回执核对（team 失败=send_message 同成员补正一次）、成员生命周期（闲置不复用于 panel/design、正常完成不 interrupt、8 名额提示）；头注标「自 SKILL.md §四 外移·并行编排手册」；验证：`python3 -c "s=open('agent/skills/spec-plan/mode/parallel.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert 'spawn_teammate' in s and 'send_message' in s and 'line-b.md' in s;assert 'Team member limit 8 reached' in s and 'interrupt_agent' in s;print('cp=',len(s))"` 退出码 0

- [ ] 1.3 新建 `agent/skills/spec-plan/mode/serial.md`（触达面 T3）：openspec-explore 探索契约（加载、纪律、explore.md 7 字段+待决节、产物契约由本 skill 规定、忽略交接段与写前确认护栏）、问答节奏、grill-me 收敛接线与 decisions.md 契约、explore 不可载三选一；头注标「自 SKILL.md §四外移·串行编排手册」；验证：`python3 -c "s=open('agent/skills/spec-plan/mode/serial.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert 'openspec-explore' in s and 'explore.md' in s and 'decisions.md' in s and 'grill-me' in s;assert 'line-b' not in s;print('cp=',len(s))"` 退出码 0

## 2. refs 改写（T4–T7）

- [ ] 2.1 改写 `agent/skills/spec-plan/refs/convergence.md`（触达面 T4）：导语注明仅并行编排；六步扩七步（第 4 步插入探索审视：加载 openspec-explore、范围约束两条、留痕 diff-matrix 新节、与 grill-me 接线；原第 4–6 步顺延为 5–7）；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/convergence.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert '探索审视' in s and 'openspec-explore' in s and '双边' in s;assert all(('%d. **'%i) in s for i in range(1,8));assert '仅并行' in s;print('cp=',len(s))"` 退出码 0

- [ ] 2.2 瘦身改写 `agent/skills/spec-plan/refs/planning.md`（触达面 T5）：删「附：阶段 1 双线派发细节」整节（并行模板迁 mode/parallel.md、串行节删除）；前置检查展开 ④ 自检加 openspec-explore（串行/审视段）；阶段 1.7 契约输入材料按编排分支（并行 line-a+line-b+diff-matrix / 串行 explore+decisions）；落档细节第 1 步扩「四件套 + 复制 code-design.md 与 diff-matrix.md（串行 decisions.md）入变更目录」、第 6 步摘要列两材料、第 7 步提交范围措辞；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/planning.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert '复制' in s and 'code-design.md' in s and 'decisions.md' in s;assert 'explore.md' in s;assert '### 并行模式' not in s and '串行模式（默认）' not in s;print('cp=',len(s))"` 退出码 0

- [ ] 2.3 修改 `agent/skills/spec-plan/refs/routing.md`（触达面 T6）：lineA/lineB 应用点注「仅 subagent 派发时应用；team 编排与串行单线不适用/不消费」；硬约束补 teammate 无模型选择、显式 `--model lineA|lineB` → 该线 subagent 派发、键适用性矩阵（lineA/lineB/panel/design/vision × 三编排）；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/routing.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert '无模型' in s and '适用' in s and 'subagent' in s;print('cp=',len(s))"` 退出码 0

- [ ] 2.4 修改 `agent/skills/spec-plan/refs/failure-modes.md`（触达面 T7）：新增行——Agent Teams 未挂载/spawn_teammate 失败或 provisioning failed/`Team member limit 8 reached` → 按线回退 subagent 留痕不重试；成员卡死 → interrupt_agent 重建一次仍失败回退；openspec-explore 不可载（串行阶段 1 与并行审视段）→ 修复后问用户三选一；用户中断行补恢复按文件名辨编排（explore.md/decisions.md=串行、line-*.md=并行）、落档后两材料从变更目录取；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/failure-modes.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert 'limit 8 reached' in s and 'interrupt_agent' in s and 'openspec-explore' in s and 'explore.md' in s;print('cp=',len(s))"` 退出码 0

## 3. spec-workflow 交叉一致性（T8–T9）

- [ ] 3.1 微改 `agent/skills/spec-workflow/SKILL.md`（触达面 T8）：§一 工件跨界所有权句改为「`code-design.md`/`diff-matrix.md`（串行 `decisions.md`）由 spec-plan 产出并随落档提交至变更目录，执行期由本 skill 维护落档副本（组段终形态化，见第六节）」；frontmatter 逐字节不变；验证：`python3 -c "s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read();assert len(s)<=7849,len(s);assert '落档副本' in s and 'decisions.md' in s;print('cp=',len(s))"` 退出码 0 且 `git diff agent/skills/spec-workflow/SKILL.md | grep '^[-+]name:\|^[-+]description:'` 无输出

- [ ] 3.2 微改 `agent/skills/spec-workflow/refs/execution.md`（触达面 T9）：组段终形态化与 R<n> 留痕两条注明维护 `openspec/changes/<change>/` 落档副本、更新随批次提交；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/execution.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert '落档副本' in s and '变更目录' in s;print('cp=',len(s))"` 退出码 0

## 4. 落档校验与提交（流程批次）

- [ ] 4.1 落档校验：`cd /home/xuqinqin/develop/dotfiles && openspec validate spec-plan-parallel-team-engine --strict` 退出码 0 且无 error/warning；验证：同命令退出码 0

- [ ] 4.2 实现提交：skill 改动全部通过上述验证句后，`git add agent/skills/spec-plan agent/skills/spec-workflow && git commit -m "feat(skills): spec-plan 并行 team 驱动+explore 审视，串行单线，落档扩充 code-design 与 diff-matrix"`；验证：`git log --oneline -1` 含 `feat(skills): spec-plan`

- [ ] 4.3 归档：`openspec archive spec-plan-parallel-team-engine`（或 `--yes`）成功后主规格 `openspec/specs/spec-plan/spec.md` 含「阶段 1 并行双线规划（team 驱动）」「阶段 1 串行单线探索」且不含「阶段 1 独立双线规划」；归档单独提交 `docs(openspec): 归档 spec-plan-parallel-team-engine`；验证：`grep -c "串行单线探索" openspec/specs/spec-plan/spec.md` ≥ 1 且 `grep -c "独立双线规划" openspec/specs/spec-plan/spec.md` = 0
