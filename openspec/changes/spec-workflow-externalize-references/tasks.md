# Tasks

## 1. 生成外移 references 文件

- [x] 1.1 新建 `agent/skills/spec-workflow/routing.md`：将 SKILL.md §十一（模型路由）整节内容剪切搬运（模型路由映射 schema、路由自检 node 脚本、白名单对照表、三档回退、vision 读图覆盖、平台图片能力表），文首加一行「本文件为 SKILL.md §十一的外移正文，回入口引用写『SKILL.md 第 X 节』」；验证：`test -s agent/skills/spec-workflow/routing.md` 通过且 `grep -c '三档回退\|fallback\|vision\|白名单' agent/skills/spec-workflow/routing.md` ≥ 4
- [x] 1.2 新建 `agent/skills/spec-workflow/failure-modes.md`：将 SKILL.md §十二处置表主体剪切搬运（红线级条目除外：绝不副作用创建 openspec/、不静默把待决项变假设、不提交未过审或未验证内容、DELEGATED_CALLER 是平台设计非故障、auto 硬停四条件——这些留入口），文首加同样一行来源说明；验证：`test -s agent/skills/spec-workflow/failure-modes.md` 通过且 `grep -c 'DELEGATED_CALLER\|重派一次\|降级\|interrupt_agent' agent/skills/spec-workflow/failure-modes.md` ≥ 3
- [x] 1.3 新建 `agent/skills/spec-workflow/planning.md`：将 SKILL.md §四的并行派发提示模板（两条线逐字等形模板全文）与串行模式细节、回执核对要求剪切搬运，文首加同样一行来源说明；验证：`test -s agent/skills/spec-workflow/planning.md` 通过且 `grep -c 'DELEGATED_CALLER\|7 个字段\|等形\|待决问题' agent/skills/spec-workflow/planning.md` ≥ 3

## 2. 入口瘦身与外部引用同步

- [x] 2.1 改写 `agent/skills/spec-workflow/SKILL.md` 为入口骨架：保持 12 节结构与 frontmatter 逐字节不变；§四瘦身为骨架（独立性铁律 + 方向表 + 「派发前读 planning.md 取模板」）；§十一瘦身为摘要段（路由键表 + 三档回退顺序 + vision 规则要点 + 「自检脚本与展开见 routing.md」）；§十二瘦身为红线级条目表 + 「其余情形读 failure-modes.md」；总览附近新增 Read-next 路由表（派发规划线前读 planning.md / 派发任一子代理前读 routing.md 并跑自检 / 异常与边界情形读 failure-modes.md）；验证：`git diff agent/skills/spec-workflow/SKILL.md | grep -E '^[+-](name|description):'` 无输出、`grep -n '第十一节' agent/skills/spec-workflow/SKILL.md` 无命中、`python3 -c "print(len(open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read()))"` 输出 ≤ 16000 且 ≥ 11000
- [x] 2.2 同步外部文档：`dsh/README.md` 127 行路径表补充 references 文件条目、193 行「SKILL.md 第十一节」提法改为 `routing.md`，并核对 `agent/skills/README.md` 中 spec-workflow 相关提法一并同步；验证：`grep -n '第十一节' dsh/README.md` 无命中、`grep -n 'routing.md' dsh/README.md` 命中 ≥ 1、`grep -n 'failure-modes.md\|planning.md' dsh/README.md` 合计命中 ≥ 1

## 3. 结构化验证

- [ ] 3.1 引用闭合与内容无损核对：对 SKILL.md 与三个 references 文件中出现的每个 `xxx.md` 文件引用逐一 `test -f` 断言存在；断言外移内容唯一性（`grep -c 'child LLM route' agent/skills/spec-workflow/routing.md` ≥ 1 且同关键词在 SKILL.md 中仅剩摘要级 ≤ 1 次命中）；断言 12 节标题仍在（`grep -c '^## ' agent/skills/spec-workflow/SKILL.md` = 12）；验证：上述每条断言以退出码 0 通过并逐条记录输出
- [ ] 3.2 加载冒烟与码点记录：在会话内按名加载 `spec-workflow` skill 成功、`read` 读取三个 references 文件任一成功；用 `python3 -c "print(len(open(p,encoding='utf-8').read()))"` 记录外移后 SKILL.md 与三个 references 的码点数字（写入变更执行记录，供第二步变更基线）；验证：加载与读取均成功，且四个码点数字已记录（SKILL.md 预期 ≈14000，routing.md 预期 ≈3600）

## Workflow follow-up

- 执行本变更期间记录**自举行为观察**：阶段 3 每次派发子代理前是否实际读取 routing.md、异常时是否读取 failure-modes.md——轨迹记入变更执行记录，作为第二步变更（去重改写压 ≤8192 码点）的形态决策输入。
- 全部任务完成后走阶段 4：目标项目验证（本变更验证 = 组 3 结构化断言）→ `openspec-archive-change` 归档并同步主规格（新增「压缩后指令完整存活」Requirement）→ 归档单独提交一次。
- 宿主操作（本流程不代劳）：归档提交后由用户自行 `git push`；无 skctl 重登记需求（bundle 内文件经目录级 symlink 实时可见）。
