# Tasks

> 执行契约：组间严格串行（1→2→3→4）；组 1 内 1.1/1.2 无文件交集可并行，组 2/3 内任务强前置（2.1→2.2、3.1→3.2）串行；单组 ≤ parallelism 8。全部断言可照抄 [code-design.md](code-design.md) ③3.7（V1–V9），统一前置 `cd /home/xuqinqin/develop/dotfiles && BASE=a3412d793b3bb3db5e9a5e9b4f08928a4ce3d870`。触达面条目编号（#1–#8）指 code-design.md ①触达面清单。

## 1. 新文件与子目录化（2 任务，可并行）

- [ ] 1.1 新建 `agent/skills/smoke-testing-local-env/refs/test-case-design.md`（触达 #1；按 code-design ③3.1 六节骨架与 ③3.2 逐字表头整文件创建，不写 frontmatter，头部相对链接 `[SKILL.md](../SKILL.md)` / `[reference.md](reference.md)`，目标 100–140 行、硬上限 160）；验证：code-design ③3.7 V3 全量关键字断言退出码 0，且 `test "$(wc -l < agent/skills/smoke-testing-local-env/refs/test-case-design.md)" -le 160`
- [ ] 1.2 子目录迁移与冻结区授权行（触达 #2/#3/#4：`git mv agent/skills/smoke-testing-local-env/reference.md agent/skills/smoke-testing-local-env/refs/reference.md` 与 `git mv …/project-profile-template.md …/refs/project-profile-template.md` 纯移动零内容改动；SKILL.md L19/L20/L57 三行锚点编辑仅更新链接目标为 `refs/` 前缀，链接文本与用途描述逐字不变，old/new 见 code-design ③3.3.0）；验证：迁移即纯移动 `diff <(git show $BASE:agent/skills/smoke-testing-local-env/reference.md) agent/skills/smoke-testing-local-env/refs/reference.md` 为空（模板同法），SKILL.md `wc -l` 仍 188 且 `sed -n '1,60p' | sed -e '19d' -e '20d' -e '57d'` 与 BASE 对应段 diff 为空

## 2. 三处指路与断言（2 任务，串行）

- [ ] 2.1 三处指路锚点编辑（触达 #2/#3/#4：SKILL.md L108 行尾同行追加、链接目标 `refs/test-case-design.md`；`refs/reference.md` §6.2 码块 fence 后插 blockquote 净 +1 行、同目录相对链接；`refs/project-profile-template.md` §7 L79 尾注扩写纯文本文件名；old/new 逐字见 code-design ③3.3，每处先 `grep -cF` 锚串唯一 =1 再编辑）；验证：code-design ③3.7 V1（冻结区授权三层断言）+ V2（节号集合零缺失零新增，`^## [0-9]+\.`=9 且 `^### [0-9]+\.[0-9]+`=38）+ V4（三文件 `grep -cF 'test-case-design.md'` 各 =1，链接目标存在，七列名/组名对齐）
- [ ] 2.2 断言全绿后勾选并实施提交（V1–V5 + V9：V9 按 code-design ③3.7 固定样例产出 `/tmp/test-case-design-drill.md` 三段式并逐项断言，建议由未参与写作的子代理执行，产物不入库；行数台账 SKILL=188 / refs/reference.md=584 / refs/project-profile-template.md=95 记入本文件附录）；验证：V5 行数断言退出码 0 + V9-OK + 提交 ② `feat(skills): 增补测试用例编写标准并收敛文档入 refs`（`git add agent/skills/smoke-testing-local-env` 整目录——提交前 `git status --short` 核对该目录内全部改动均属本变更——加 `openspec/changes/add-test-case-design-standard/tasks.md`，见 code-design ③3.8）

## 3. D6 自检修复（2 任务，串行）

- [ ] 3.1 `agent/skills/spec-plan/refs/routing.md` L49 单行锚点替换为 4 行双形态正则（触达 #5；before/after 逐字见 code-design ③3.4，新增行不含单引号，先 `grep -cF` 旧行唯一 =1）；验证：code-design ③3.7 V8 静态四断言（`const flow=`/`const block=`/`const wl=` 各 =1 且旧串 =0）
- [ ] 3.2 真实文件动态验证与混合样例后勾选并提交 ③（从 routing.md 抽取脚本原样执行：白名单 8 项、映射 13 条、`OK 全部路由 ⊆ 白名单`、退出码 0；routing.md 67→70 行记入附录）；验证：V8 动态三断言 + V8b 混合样例（恰解析 2 项且注释行不入选）退出码 0 + 提交 ③ `fix(skills): 修正 spec-plan 路由自检白名单解析`（routing.md + tasks.md 精确路径）

## 4. 归档（单任务）

- [ ] 4.1 干净窗口（`git status --short` 现场复核外部在途白名单——台账动态，落档期已见 6→7→8 漂移（dsh/profiles/web×3、add-subagent×3、`spec-apply/refs/{coordination,execution}.md`×2），能归属他会话的新项纳入白名单并附录留痕、无法归属即停；白名单正则见 code-design ⑤5.4）→ 复跑 V6a → 勾 1.1–3.2 → `openspec archive add-test-case-design-standard --yes` → V6b + V7（主规格 10 Requirement/18 Scenario；diff 删除行仅出现在「文档结构兼容约束」节内、其余 7 条零触碰；活跃目录移走、archive 目录在、其余两活跃变更未受损、归档提交白名单）→ 归档目录内勾 4.1 → 提交 ④ `docs(openspec): 归档 add-test-case-design-standard`（`git add -u` 旧目录 + 精确 add 归档目录与主规格，禁 `git add -A openspec`）→ 六要素汇报后停留不推送；验证：V6b/V7 全绿 + `git log -1` 提交 ④ 在顶 + `git status --short` 仅剩外部在途白名单项

## 附录：执行留痕（执行期回填，落档时留空）

- 行数台账：SKILL.md ____ / refs/reference.md ____ / refs/project-profile-template.md ____ / refs/test-case-design.md ____ / routing.md ____
- V9 执行者与方式：____（是否子代理 / 是否自证局限说明）
- Q1 裁决回填：已决（落档期 2026-11-19）——`coordination.md` 按外部在途处理，干净窗口白名单第 7 项，台账 6→7
