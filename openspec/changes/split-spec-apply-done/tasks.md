# Tasks

## 1. spec-apply 新建(refs 迁移先行)

- [ ] 1.1 按 (b).B2 迁移新建 `agent/skills/spec-apply/refs/execution.md`(整体复制+头部说明替换+删「验证与归档派发要点」整节+worktree.md 链接两处改文字引用+节号引用适配);验证:`test -f agent/skills/spec-apply/refs/execution.md` 退出码 0,且 `grep -c '验证与归档派发要点' agent/skills/spec-apply/refs/execution.md` 输出 0、`grep -c 'spec-workflow 的 refs/worktree.md' agent/skills/spec-apply/refs/execution.md` 输出 2、`grep -o '](worktree.md)' agent/skills/spec-apply/refs/execution.md | wc -l` 输出 0、`python3 -c "assert len(open('agent/skills/spec-apply/refs/execution.md',encoding='utf-8').read())<=7849"` 退出码 0
- [ ] 1.2 按 (b).B3 迁移新建 `agent/skills/spec-apply/refs/routing.md`(整体复制+头部说明替换+verify 键注记+节号引用适配);验证:`grep -c '由 spec-done 复用' agent/skills/spec-apply/refs/routing.md` 输出 ≥1、`grep -c 'spec-workflow.yaml' agent/skills/spec-apply/refs/routing.md` 输出 ≥1,且码点断言 ≤7849 退出码 0
- [ ] 1.3 按 (b).B4 新建 `agent/skills/spec-apply/refs/failure-modes.md`(全文照抄);验证:`grep -c '执行侧处置表' agent/skills/spec-apply/refs/failure-modes.md` 输出 1、`grep -c 'DELEGATED_CALLER\|Team member limit' agent/skills/spec-apply/refs/failure-modes.md` 输出 ≥1,且码点断言 ≤7849 退出码 0
- [ ] 1.4 按 (b).B1 新建 `agent/skills/spec-apply/SKILL.md`(全文照抄);验证:`test -f agent/skills/spec-apply/SKILL.md` 退出码 0,且 `grep -c '## 三、批次循环骨架' agent/skills/spec-apply/SKILL.md` 输出 1、`grep -o 'spec-workflow' agent/skills/spec-apply/SKILL.md | wc -l` 输出 ≥5、`grep -c '不归档、不推送' agent/skills/spec-apply/SKILL.md` 输出 1、`grep -o 'refs/execution.md\|refs/routing.md\|refs/failure-modes.md' agent/skills/spec-apply/SKILL.md | wc -l` 输出 ≥5,且 `python3 -c "assert len(open('agent/skills/spec-apply/SKILL.md',encoding='utf-8').read())<=7849"` 退出码 0
- [ ] 1.5 按 (b).B5 新建 `dsh/commands/spec-apply.md` 并建容器 symlink(`mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md ~/.dsh/commands/spec-apply.md`);验证:`test -f dsh/commands/spec-apply.md && test -f ~/.dsh/commands/spec-apply.md` 退出码 0,且 `readlink ~/.dsh/commands/spec-apply.md` 输出 `/home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md`

## 2. spec-done 归档链并入

- [ ] 2.1 按 (b).B6 变换 `agent/skills/spec-done/SKILL.md`(description/§一总览/§二前置反转/插§二'验证门与归档六步/红线表增三行改一行);验证:`grep -c "## 二'、验证门与归档" agent/skills/spec-done/SKILL.md` 输出 1、`grep -c '六要素汇报' agent/skills/spec-done/SKILL.md` 输出 ≥2、`grep -c 'spec-apply' agent/skills/spec-done/SKILL.md` 输出 ≥3、`grep -c '不自动进入推送' agent/skills/spec-done/SKILL.md` 输出 1,且 `python3 -c "assert len(open('agent/skills/spec-done/SKILL.md',encoding='utf-8').read())<=7849"` 退出码 0

## 3. spec-workflow 残段改述

- [ ] 3.1 按 (b).B7 变换 `agent/skills/spec-workflow/SKILL.md`(description/§一总览与消费时机表/§四尾句/§五衔接③尾+判段路由插步/§六§七指针化/§八§九§十改述);验证:`grep -c '委托 skill `spec-apply`' agent/skills/spec-workflow/SKILL.md` 输出 ≥2、`grep -c '判段路由' agent/skills/spec-workflow/SKILL.md` 输出 ≥2、`grep -c 'refs/execution.md\|refs/routing.md' agent/skills/spec-workflow/SKILL.md` 输出 0、`grep -c 'spec-done' agent/skills/spec-workflow/SKILL.md` 输出 ≥4、`grep -c '自动委托 spec-done' agent/skills/spec-workflow/SKILL.md` 输出 ≥1,且 `python3 -c "assert len(open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read())<=7849"` 退出码 0
- [ ] 3.2 按 (b).B8 变换 `agent/skills/spec-workflow/refs/failure-modes.md`(删执行/终末条目,留衔接编排条目,新增两行权威源指路,头部注记改);验证:`grep -c 'spec-apply' agent/skills/spec-workflow/refs/failure-modes.md` 输出 ≥2、`grep -c 'spec-done' agent/skills/spec-workflow/refs/failure-modes.md` 输出 ≥1、`grep -c '审核被拒' agent/skills/spec-workflow/refs/failure-modes.md` 输出 0、`grep -c 'Team member limit' agent/skills/spec-workflow/refs/failure-modes.md` 输出 0,且码点断言 ≤7849 退出码 0
- [ ] 3.3 按 (b).B9 替换 `dsh/spec-workflow.yaml` 头注释块(键值不动);验证:`git diff --stat dsh/spec-workflow.yaml` 仅注释行变更,且 `grep -c 'spec-apply 消费' dsh/spec-workflow.yaml` 输出 1、`grep -c 'spec-done 复用' dsh/spec-workflow.yaml` 输出 1

## 4. 联动面

- [ ] 4.1 按 (b).B10 修订 `agent/skills/spec-plan/` 四文件十处改指(SKILL.md 三处、refs/routing.md 五处、refs/planning.md 一处、mode/parallel.md 一处;以 `grep -rn 'spec-workflow' agent/skills/spec-plan/` 实际结果全量核对);验证:`grep -rn 'spec-workflow 消费\|spec-workflow 执行侧\|spec-workflow team 执行\|spec-workflow 无缝衔接\|spec-workflow 委托' agent/skills/spec-plan/ | wc -l` 输出 0,且四文件码点断言 ≤7849 退出码 0
- [ ] 4.2 按 (b).B11 修订 `dsh/README.md`(拆分结构四段/文件清单表/路由消费表/入口说明/安装段);验证:`grep -c 'spec-apply' dsh/README.md` 输出 ≥8、`grep -c 'agent/skills/spec-apply/refs/execution.md' dsh/README.md` 输出 1、`grep -c 'skctl/src/cli.ts install' dsh/README.md` 输出 ≥3
- [ ] 4.3 按 (b).B12 修订 `dsh/commands/spec-flow.md`(description+正文一行);验证:`grep -c 'spec-apply' dsh/commands/spec-flow.md` 输出 ≥1

## 5. 全库校验与聚合层登记

- [ ] 5.1 全库校验:①码点断言全绿(四 skill SKILL.md 与全部 refs);②旧指残留核对(`grep -rn 'spec-workflow' agent/skills/ dsh/README.md dsh/commands/spec-flow.md` 逐行核对:worktree.md 权威源/yaml 文件名/编排委托/历史变更叙述四类豁免,其余执行语义行清零);③相对链接断言(spec-apply/refs 内 `](worktree.md)`、`](routing.md)` 跨 bundle 引用为 0);④`openspec validate split-spec-apply-done --strict` 输出 valid;⑤`openspec list --specs` 含 spec-apply。验证:以上五项命令逐一执行并通过
- [ ] 5.2 呈证聚合层登记命令(宿主操作:`node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install /home/xuqinqin/develop/dotfiles/agent/skills/spec-apply`)交用户执行,登记后核对可见;验证:`ls /home/docker/.agents/skills/ | grep -c spec-apply` 输出 1(用户执行登记命令后)
