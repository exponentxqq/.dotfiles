# Tasks

> 执行契约：组间严格串行（1→2→3→4）；组 1 内 1.1/1.2 无文件交集可并行，组 2/3 内任务强前置（2.1→2.2、3.1→3.2）串行；单组 ≤ parallelism 8。全部断言可照抄 [code-design.md](code-design.md) ③3.7（V1–V9），统一前置 `cd /home/xuqinqin/develop/dotfiles && BASE=a3412d793b3bb3db5e9a5e9b4f08928a4ce3d870`。触达面条目编号（#1–#8）指 code-design.md ①触达面清单。

## 1. 新文件与子目录化（2 任务，可并行）

- [x] 1.1 新建 `agent/skills/smoke-testing-local-env/refs/test-case-design.md`（触达 #1；按 code-design ③3.1 六节骨架与 ③3.2 逐字表头整文件创建，不写 frontmatter，头部相对链接 `[SKILL.md](../SKILL.md)` / `[reference.md](reference.md)`，目标 100–140 行、硬上限 160）；验证：code-design ③3.7 V3 全量关键字断言退出码 0，且 `test "$(wc -l < agent/skills/smoke-testing-local-env/refs/test-case-design.md)" -le 160`
- [x] 1.2 子目录迁移与冻结区授权行（触达 #2/#3/#4：`git mv agent/skills/smoke-testing-local-env/reference.md agent/skills/smoke-testing-local-env/refs/reference.md` 与 `git mv …/project-profile-template.md …/refs/project-profile-template.md` 纯移动零内容改动；SKILL.md L19/L20/L57 三行锚点编辑仅更新链接目标为 `refs/` 前缀，链接文本与用途描述逐字不变，old/new 见 code-design ③3.3.0）；验证：迁移即纯移动 `diff <(git show $BASE:agent/skills/smoke-testing-local-env/reference.md) agent/skills/smoke-testing-local-env/refs/reference.md` 为空（模板同法），SKILL.md `wc -l` 仍 188 且 `sed -n '1,60p' | sed -e '19d' -e '20d' -e '57d'` 与 BASE 对应段 diff 为空

## 2. 三处指路与断言（2 任务，串行）

- [x] 2.1 三处指路锚点编辑（触达 #2/#3/#4：SKILL.md L108 行尾同行追加、链接目标 `refs/test-case-design.md`；`refs/reference.md` §6.2 码块 fence 后插 blockquote 净 +1 行、同目录相对链接；`refs/project-profile-template.md` §7 L79 尾注扩写纯文本文件名；old/new 逐字见 code-design ③3.3，每处先 `grep -cF` 锚串唯一 =1 再编辑）；验证：code-design ③3.7 V1（冻结区授权三层断言）+ V2（节号集合零缺失零新增，`^## [0-9]+\.`=9 且 `^### [0-9]+\.[0-9]+`=38）+ V4（三文件 `grep -cF 'test-case-design.md'` 各 =1，链接目标存在，七列名/组名对齐）
- [x] 2.2 断言全绿后勾选并实施提交（V1–V5 + V9：V9 按 code-design ③3.7 固定样例产出 `/tmp/test-case-design-drill.md` 三段式并逐项断言，建议由未参与写作的子代理执行，产物不入库；行数台账 SKILL=188 / refs/reference.md=584 / refs/project-profile-template.md=95 记入本文件附录）；验证：V5 行数断言退出码 0 + V9-OK + 提交 ② `feat(skills): 增补测试用例编写标准并收敛文档入 refs`（`git add agent/skills/smoke-testing-local-env` 整目录——提交前 `git status --short` 核对该目录内全部改动均属本变更——加 `openspec/changes/add-test-case-design-standard/tasks.md`，见 code-design ③3.8）

## 3. D6 自检修复（2 任务，串行）

- [x] 3.1 `agent/skills/spec-plan/refs/routing.md` L49 单行锚点替换为 4 行双形态正则（触达 #5；before/after 逐字见 code-design ③3.4，新增行不含单引号，先 `grep -cF` 旧行唯一 =1）；验证：code-design ③3.7 V8 静态四断言（`const flow=`/`const block=`/`const wl=` 各 =1 且旧串 =0）
- [x] 3.2 真实文件动态验证与混合样例后勾选并提交 ③（从 routing.md 抽取脚本原样执行：白名单 8 项、映射 13 条、`OK 全部路由 ⊆ 白名单`、退出码 0；routing.md 67→70 行记入附录）；验证：V8 动态三断言 + V8b 混合样例（恰解析 2 项且注释行不入选）退出码 0 + 提交 ③ `fix(skills): 修正 spec-plan 路由自检白名单解析`（routing.md + tasks.md 精确路径）

## 4. 归档（单任务）

- [x] 4.1 干净窗口（`git status --short` 现场复核外部在途白名单——台账动态，落档期已见 6→7→8 漂移（dsh/profiles/web×3、add-subagent×3、`spec-apply/refs/{coordination,execution}.md`×2），能归属他会话的新项纳入白名单并附录留痕、无法归属即停；白名单正则见 code-design ⑤5.4）→ 复跑 V6a → 勾 1.1–3.2 → `openspec archive add-test-case-design-standard --yes` → V6b + V7（主规格 10 Requirement/18 Scenario；diff 删除行仅出现在「文档结构兼容约束」节内、其余 7 条零触碰；活跃目录移走、archive 目录在、其余两活跃变更未受损、归档提交白名单）→ 归档目录内勾 4.1 → 提交 ④ `docs(openspec): 归档 add-test-case-design-standard`（`git add -u` 旧目录 + 精确 add 归档目录与主规格，禁 `git add -A openspec`）→ 六要素汇报后停留不推送；验证：V6b/V7 全绿 + `git log -1` 提交 ④ 在顶 + `git status --short` 仅剩外部在途白名单项

## 附录：执行留痕（执行期回填，落档时留空）

- 行数台账：SKILL.md 188 / refs/reference.md 584 / refs/project-profile-template.md 95 / refs/test-case-design.md 102 / routing.md 70（原 67，+3 净增）
- V9 执行者与方式：fresh 子代理 session-c79b2853（未参与写作，无自证局限）；V9-OK 子代理 + 主会话双跑；演练稿 /tmp/test-case-design-drill.md 202 行（26 TP / 28 TC / §5.1–5.3 齐备，sha256 前缀 1bb2ab3e8d172a80，不入库）
- V9 观察与裁定（P1–P4，2026-11-19，审提点呈报）：P1 类型枚举写法——§3 规则行已声明「可多值（用『/』连接）」，「异常/空值」系多值组合、「空值」为「空值与非法值」简称，维持定稿；P2 A–G vs A–F——G 为 reference §6.2「补充」组（L384）不在附加覆盖典型落点，组定义外置系 writing-skills 重参考外移设计，维持定稿；P3 直接交付前置——§6 映射明确限于入库去向，直接交付不入库（§1.1）不触发 §6，自包含前置符合设计意图；P4 TP↔TC 硬追溯——现设计经「对应需求/规则 ↔ 覆盖需求/规则」间接对齐，升格属标准内容变更 = 规划外，不改动、留作后续演化建议。
- Q1 裁决回填：已决（落档期 2026-11-19）——`coordination.md` 按外部在途处理，干净窗口白名单第 7 项，台账 6→7
- V7-LIST 前提漂移留痕（2026-11-19 归档时点）：V7「其余两活跃变更未受损」断言写于落档期，当时 add-subagent-control-and-coordination 仍活跃；归档时点它已被他会话自行归档（提交 92eead4，R100 rename 证据），活跃列表恰剩 add-ui-demo-gate——修正口径 V7-LIST-ADJUSTED-OK 通过（本操作未损伤任何活跃变更）；属落档预判的「台账动态」范畴（4.1 现场复核口径），无断言改动。外部在途台账终值：8→3（add-subagent×3 与 spec-apply refs×2 均随他会话提交入库）。
- R1（执行期运行规则，2026-11-19 组 1）：write 工具新建文件默认权限 600，本仓 Markdown 惯例 644——新建入库文件后需 `chmod 644` 对齐。依据：T1.1 实测（`refs/test-case-design.md` 初建 600，同目录既有文件 644）。适用范围：本仓「新建文件」类执行任务。连锁面：无断言涉及文件权限；组 2/3 均为编辑既有文件，无后续动作。
- R2（执行期裁决，2026-11-19 用户）：auto 提交口径 = 任务 2.2/3.2/4.1 明文的提交步骤**不在组内实施**，统一延后至全部批次完成后的审核点；用户确认后按 code-design ③3.8 序列与提交信息原样补交（② skill 整目录 + tasks 勾 1.1–2.2 → ③ routing.md + tasks 勾 3.1/3.2 → ④ `openspec archive` + V6b/V7 + 勾 4.1 + 提交④）。2.2/3.2 勾选口径 = 除提交步骤外验收全绿；**openspec archive 随提交④序列在审提点后执行**（归档移动目录后旧路径 tasks.md 不可再供②③ add，故 4.1 审提前仅完成干净窗口复核 + V6a 复跑）。依据：execution.md「提交一律在用户审核确认后」与 tasks 验收句「提交在顶」冲突，用户选严格审核口径。适用范围：本变更执行期全部提交。连锁面：2.2/3.2/4.1 验收句中提交相关项延后满足；spec-done 六要素汇报的提交历史要素在补交完成后读出。
- R3（执行期裁决，2026-11-19 组 3 用户）：V8 动态断言的 awk 抽取命令假设 `node -e '…'` 收尾引号独占一行，与 routing.md 末行形态（`console.log("OK 全部路由 ⊆ 白名单");'` 引号与代码同行）不兼容 → 抽取缺末行、OK 断言原文不可满足；该缺陷 HEAD 67 行版即存在，**非 T3.1 引入**（落档断言自带）。验收口径改为 `sed 42,57p | bash` 整块原样执行，实质验证全绿：白名单 8 / 映射 13 / `OK 全部路由 ⊆ 白名单` 在 / rc=0（T3.2 子代理与主会话双跑一致；主会话曾误报全绿——GREP-OK 实际未出现，经 T3.2 揭穿后纠正）。routing.md 不为此改动（70 行维持）。适用范围：本变更 V8 动态验收；后续抽取该脚本一律沿用整块执行口径。连锁面：tasks 3.2 验收句 OK 断言以本口径满足；code-design ③3.7 V8 段执行注记；无文件改动。
