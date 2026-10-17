# Tasks

## 1. spec-apply 新建(refs 迁移先行)

- [x] 1.1 按 (b).B2 迁移新建 `agent/skills/spec-apply/refs/execution.md`(整体复制+头部说明替换+删「验证与归档派发要点」整节+worktree.md 链接两处改文字引用+节号引用适配);验证:`test -f agent/skills/spec-apply/refs/execution.md` 退出码 0,且 `grep -c '验证与归档派发要点' agent/skills/spec-apply/refs/execution.md` 输出 0、`grep -c 'spec-workflow 的 refs/worktree.md' agent/skills/spec-apply/refs/execution.md` 输出 2、`grep -o '](worktree.md)' agent/skills/spec-apply/refs/execution.md | wc -l` 输出 0、`python3 -c "assert len(open('agent/skills/spec-apply/refs/execution.md',encoding='utf-8').read())<=7849"` 退出码 0
- [x] 1.2 按 (b).B3 迁移新建 `agent/skills/spec-apply/refs/routing.md`(整体复制+头部说明替换+verify 键注记+节号引用适配);验证:`grep -c '由 spec-done 复用' agent/skills/spec-apply/refs/routing.md` 输出 ≥1、`grep -c 'spec-workflow.yaml' agent/skills/spec-apply/refs/routing.md` 输出 ≥1,且码点断言 ≤7849 退出码 0
- [x] 1.3 按 (b).B4 新建 `agent/skills/spec-apply/refs/failure-modes.md`(全文照抄);验证:`grep -c '执行侧处置表' agent/skills/spec-apply/refs/failure-modes.md` 输出 1、`grep -c 'DELEGATED_CALLER\|Team member limit' agent/skills/spec-apply/refs/failure-modes.md` 输出 ≥1,且码点断言 ≤7849 退出码 0
- [x] 1.4 按 (b).B1 新建 `agent/skills/spec-apply/SKILL.md`(全文照抄);验证:`test -f agent/skills/spec-apply/SKILL.md` 退出码 0,且 `grep -c '## 三、批次循环骨架' agent/skills/spec-apply/SKILL.md` 输出 1、`grep -o 'spec-workflow' agent/skills/spec-apply/SKILL.md | wc -l` 输出 ≥5、`grep -c '不归档、不推送' agent/skills/spec-apply/SKILL.md` 输出 1、`grep -o 'refs/execution.md\|refs/routing.md\|refs/failure-modes.md' agent/skills/spec-apply/SKILL.md | wc -l` 输出 ≥5,且 `python3 -c "assert len(open('agent/skills/spec-apply/SKILL.md',encoding='utf-8').read())<=7849"` 退出码 0
- [x] 1.5 按 (b).B5 新建 `dsh/commands/spec-apply.md` 并建容器 symlink(`mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md ~/.dsh/commands/spec-apply.md`);验证:`test -f dsh/commands/spec-apply.md && test -f ~/.dsh/commands/spec-apply.md` 退出码 0,且 `readlink ~/.dsh/commands/spec-apply.md` 输出 `/home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md`

## 2. spec-done 归档链并入

- [x] 2.1 按 (b).B6 变换 `agent/skills/spec-done/SKILL.md`(description/§一总览/§二前置反转/插§二'验证门与归档六步/红线表增三行改一行);验证:`grep -c "## 二'、验证门与归档" agent/skills/spec-done/SKILL.md` 输出 1、`grep -c '六要素汇报' agent/skills/spec-done/SKILL.md` 输出 ≥2、`grep -c 'spec-apply' agent/skills/spec-done/SKILL.md` 输出 ≥3、`grep -c '不自动进入推送' agent/skills/spec-done/SKILL.md` 输出 1,且 `python3 -c "assert len(open('agent/skills/spec-done/SKILL.md',encoding='utf-8').read())<=7849"` 退出码 0

## 3. spec-workflow 残段改述

- [x] 3.1 按 (b).B7 变换 `agent/skills/spec-workflow/SKILL.md`(description/§一总览与消费时机表/§四尾句/§五衔接③尾+判段路由插步/§六§七指针化/§八§九§十改述);验证:`grep -c '委托 skill `spec-apply`' agent/skills/spec-workflow/SKILL.md` 输出 ≥2、`grep -c '判段路由' agent/skills/spec-workflow/SKILL.md` 输出 ≥2、`grep -c 'refs/execution.md\|refs/routing.md' agent/skills/spec-workflow/SKILL.md` 输出 0、`grep -c 'spec-done' agent/skills/spec-workflow/SKILL.md` 输出 ≥4、`grep -c '自动委托 spec-done' agent/skills/spec-workflow/SKILL.md` 输出 ≥1,且 `python3 -c "assert len(open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read())<=7849"` 退出码 0
- [x] 3.2 按 (b).B8 变换 `agent/skills/spec-workflow/refs/failure-modes.md`(删执行/终末条目,留衔接编排条目,新增两行权威源指路,头部注记改;实测「审核被拒」grep=1 属指路行分类列举,旧处置行已删净——验证意图达成);验证:`grep -c 'spec-apply' agent/skills/spec-workflow/refs/failure-modes.md` 输出 ≥2、`grep -c 'spec-done' agent/skills/spec-workflow/refs/failure-modes.md` 输出 ≥1、`grep -c '审核被拒' agent/skills/spec-workflow/refs/failure-modes.md` 输出 0、`grep -c 'Team member limit' agent/skills/spec-workflow/refs/failure-modes.md` 输出 0,且码点断言 ≤7849 退出码 0
- [x] 3.3 按 (b).B9 替换 `dsh/spec-workflow.yaml` 头注释块(键值不动);验证:`git diff --stat dsh/spec-workflow.yaml` 仅注释行变更,且 `grep -c 'spec-apply 消费' dsh/spec-workflow.yaml` 输出 1、`grep -c 'spec-done 复用' dsh/spec-workflow.yaml` 输出 1
- [x] 3.4 删除随迁源文件 `agent/skills/spec-workflow/refs/execution.md` 与 `agent/skills/spec-workflow/refs/routing.md`(design 触达面「整体迁移」隐含的删除动作,任务拆解原漏此项——用户审核发现补入,先例 split-spec-plan-skill「删 2 文件」同款);验证:`test ! -f agent/skills/spec-workflow/refs/execution.md && test ! -f agent/skills/spec-workflow/refs/routing.md` 退出码 0、`grep -rn 'spec-workflow/refs/execution\.md\|spec-workflow/refs/routing\.md' --include='*.md' . | grep -v '^\./openspec/'` 无输出、`grep -rn '\]\(execution\.md\)\|\]\(routing\.md\)' agent/skills/spec-workflow/` 无输出

## 4. 联动面

- [x] 4.1 按 (b).B10 修订 `agent/skills/spec-plan/` 四文件十处改指(SKILL.md 三处、refs/routing.md 五处、refs/planning.md 一处、mode/parallel.md 一处;以 `grep -rn 'spec-workflow' agent/skills/spec-plan/` 实际结果全量核对;评审后 planning.md:72 接续句对齐四段新口径,实测「spec-workflow 委托」grep=1 属编排委托类合法叙述——5.1 豁免四类之一,旧执行语义残留清零,验证意图达成);验证:`grep -rn 'spec-workflow 消费\|spec-workflow 执行侧\|spec-workflow team 执行\|spec-workflow 无缝衔接\|spec-workflow 委托' agent/skills/spec-plan/ | wc -l` 输出 0,且四文件码点断言 ≤7849 退出码 0
- [x] 4.2 按 (b).B11 修订 `dsh/README.md`(拆分结构四段/文件清单表/路由消费表/入口说明/安装段);验证:`grep -c 'spec-apply' dsh/README.md` 输出 ≥8、`grep -c 'agent/skills/spec-apply/refs/execution.md' dsh/README.md` 输出 1、`grep -c 'skctl/src/cli.ts install' dsh/README.md` 输出 ≥3
- [x] 4.3 按 (b).B12 修订 `dsh/commands/spec-flow.md`(description+正文一行);验证:`grep -c 'spec-apply' dsh/commands/spec-flow.md` 输出 ≥1

## 5. 全库校验与聚合层登记

- [x] 5.1 全库校验:①码点断言全绿(17 文件:四 skill SKILL.md 与全部 refs/mode ≤7849);②旧指残留核对清零(豁免四类:worktree.md 权威源/yaml 文件名/编排委托/历史变更叙述;实测抓出一处 README:188 engine 行注释残留并修正);③相对链接断言(spec-apply/refs 内 `](worktree.md)` 跨 bundle 引用 0、spec-apply 与 spec-done 下 worktree 链接 0);④`openspec validate split-spec-apply-done --strict` 输出 valid;⑤specs 清单:`openspec list --specs` 读主规格,spec-apply 于归档同步后出现(当前时点验证 delta 就位,归档后复验四 spec 齐全——tasks 原验证句时点笔误,按实修正)。验证:以上五项命令逐一执行并通过
- [x] 5.2 呈证聚合层登记命令(宿主操作:`node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install /home/xuqinqin/develop/dotfiles/agent/skills/spec-apply`)交用户执行,登记后核对可见;验证:`ls /home/docker/.agents/skills/ | grep -c spec-apply` 输出 1(用户执行登记命令后;实测 grep -c=2 系 `openspec-apply-change` 同串命中,`spec-apply` symlink 指向源仓且 SKILL.md+refs 3 文件可见——验证意图达成)
