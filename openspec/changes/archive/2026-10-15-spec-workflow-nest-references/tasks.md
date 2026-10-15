# Tasks

> 触达面：T1 `agent/skills/spec-workflow/SKILL.md`（改）、T2 `agent/skills/spec-workflow/refs/*.md`（移动、内容零改动）、T3 `dsh/README.md`（改）；串行执行（机械重构，无并行收益）；每任务验证句第三方可核对。

## 1. 资源文件子目录化与引用改写

- [x] 1.1 `git mv` 5 个 references（planning.md、convergence.md、routing.md、execution.md、failure-modes.md）至 `refs/`（触达面 T2）；验证：`test -d agent/skills/spec-workflow/refs` 退出码 0 且 `ls agent/skills/spec-workflow/*.md` 仅输出 SKILL.md 且 `git diff --cached -M --name-status | grep -c '^R100'` 输出 5 且 `python3 -c "b='agent/skills/spec-workflow/refs/';assert [len(open(b+f,encoding='utf-8').read()) for f in ['planning.md','convergence.md','routing.md','execution.md','failure-modes.md']]==[6279,2864,3900,3092,2238]"` 退出码 0

- [x] 1.2 `SKILL.md` 改写（触达面 T1）：16 处链接 href 加 `refs/` 前缀（标签保持裸文件名）、「外移到**同目录** references」措辞改指 `refs/` 子目录、等量收紧 ≥37 码点（净 ≤7825；候选：第一节流水线输出行的对齐空格、第七节 `status` 平台注记冗余子句、第四节 `DELEGATED_CALLER` 句中「以错误码」、第一节「（唯一源）」）；**不得触及** frontmatter、12 个 `## ` 节标题、红线表与恢复协议语义；验证：`python3 -c "import re;s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read();assert len(s)<=7825,len(s);assert len(re.findall(r'^## ',s,re.M))==12;h=re.findall(r'\]\(([^)]+\.md)\)',s);assert len(h)==16 and all(x.startswith('refs/') for x in h),h;assert '同目录' not in s;print('cp=',len(s))"` 退出码 0 且 `test -z "$(git diff agent/skills/spec-workflow/SKILL.md | grep '^[-+]name:\|^[-+]description:')"` 退出码 0

- [x] 1.3 `dsh/README.md` 路径同步（触达面 T3）：文件表 5 行 + 2 处散文路径 → `agent/skills/spec-workflow/refs/xxx.md`；验证：`grep -c 'spec-workflow/refs/' dsh/README.md` 输出 7 且 `grep -rn 'spec-workflow/\(planning\|convergence\|routing\|execution\|failure-modes\)\.md' --include='*.md' . | grep -v '^\./openspec/changes/'` 无输出

## 2. 验证与冒烟（只读）

- [x] 2.1 结构与引用闭合（G1 / G3）：skill 根仅 `SKILL.md` 与 `refs/`；`SKILL.md` 全部 16 个 href 经仓库路径与 `~/.agents/skills/spec-workflow/` 双路 `test -f`；5 个 references 互链 `test -f`；验证：逐条断言退出码 0 并记录输出

- [x] 2.2 项目声明验证回归（G5）：`node --test 'test/*.test.ts'`（工作目录 `tools/skctl`）；验证：退出码 0、用例 47 通过

- [x] 2.3 运行时冒烟（G4）：会话内按名加载 `spec-workflow` skill，确认加载成功且渲染码点 ≤8192（余量 ≥15）；`ls ~/.agents/skills/spec-workflow/refs/` 5 文件可见（改源即生效，无需重登记）；验证：实测数字与加载结果记录入执行日志

## Workflow follow-up

- 全部勾选后：写 `execution-log.md` → `openspec-archive-change` 归档（规格中性，无主规格 delta 需同步）→ 归档单独提交 → 四要素汇报；提交一律显式 `git add` 指定文件，**排除** `dsh/profiles/web/cordis.patch.yml`。
