# Tasks

## 1. spec-workflow 侧正文与配置

- [x] 1.1 按 (b).T1 新建 `agent/skills/spec-workflow/refs/worktree.md`（worktree 前半程六节全文照抄）；验证：`test -f agent/skills/spec-workflow/refs/worktree.md` 退出码 0，且 `grep -c '## 执行环境块' agent/skills/spec-workflow/refs/worktree.md` 输出 1、`grep -o 'git worktree add' agent/skills/spec-workflow/refs/worktree.md | wc -l` 输出 2、`grep -c '默认值 + 100 × n' agent/skills/spec-workflow/refs/worktree.md` 输出 1、`grep -c 'CREATE DATABASE IF NOT EXISTS' agent/skills/spec-workflow/refs/worktree.md` 输出 1、`grep -o '_wt' agent/skills/spec-workflow/refs/worktree.md | wc -l` 输出 2、`grep -o '本地配置与环境错开' agent/skills/spec-workflow/refs/worktree.md | wc -l` 输出 2、`python3 -c "assert len(open('agent/skills/spec-workflow/refs/worktree.md',encoding='utf-8').read())<=7849"` 退出码 0
- [x] 1.2 按 (b).T2-1~9 修订 `agent/skills/spec-workflow/SKILL.md` 九处（§一两处+参数表行+消费时机表行、§五衔接③+恢复协议插第 5 步并重编号原 5/6/7→6/7/8、§六段尾句、§七⑦整条→六要素+⑧、§十末条追加）；验证：`grep -o -e '--worktree' agent/skills/spec-workflow/SKILL.md | wc -l` 输出 2、`grep -c '执行环境决策' agent/skills/spec-workflow/SKILL.md` 输出 2、`grep -c '执行环境核对' agent/skills/spec-workflow/SKILL.md` 输出 1、`grep -c '汇报六要素' agent/skills/spec-workflow/SKILL.md` 输出 1、`grep -o 'spec-done' agent/skills/spec-workflow/SKILL.md | wc -l` 输出 6、`grep -c '不依赖对话记忆' agent/skills/spec-workflow/SKILL.md` 输出 1，且 `python3 -c "assert len(open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read())<=7849"` 退出码 0
- [x] 1.3 按 (b).T3-1~3 修订 `agent/skills/spec-workflow/refs/execution.md` 三处（项目根注记、多仓分立提交 worktree 变体、汇报第 7 条六要素含④探测语义）；验证：`grep -c '汇报六要素' agent/skills/spec-workflow/refs/execution.md` 输出 1、`grep -c '推送先探测' agent/skills/spec-workflow/refs/execution.md` 输出 1、`grep -o '/spec-done' agent/skills/spec-workflow/refs/execution.md | wc -l` 输出 1，且码点断言 ≤7849 退出码 0
- [x] 1.4 按 (b).T4 修订 `agent/skills/spec-workflow/refs/failure-modes.md`（末行拆推送例外 + 三新行）；验证：`grep -c '推送例外' agent/skills/spec-workflow/refs/failure-modes.md` 输出 1、`grep -c '不强拆他人检出' agent/skills/spec-workflow/refs/failure-modes.md` 输出 1、`grep -c '收尾半程归 skill spec-done' agent/skills/spec-workflow/refs/failure-modes.md` 输出 1，且码点断言 ≤7849 退出码 0
- [x] 1.5 按 (b).T5/T6 修订 `dsh/commands/spec-flow.md`（hint 插 `--worktree`）与 `dsh/spec-workflow.yaml`（键归属注释补 verify 复用）；验证：`grep -o -e '--worktree' dsh/commands/spec-flow.md | wc -l` 输出 1、`grep -c 'spec-done' dsh/spec-workflow.yaml` 输出 1

## 2. spec-done 新建

- [x] 2.1 按 (b).T7 新建 `agent/skills/spec-done/SKILL.md`（收尾半程六节全文照抄）；验证：`test -f agent/skills/spec-done/SKILL.md` 退出码 0，且 `grep -c '## 四、隔离闭环八步' agent/skills/spec-done/SKILL.md` 输出 1、`grep -c '## 三、三方重建' agent/skills/spec-done/SKILL.md` 输出 1、`grep -c '本地环境处置' agent/skills/spec-done/SKILL.md` 输出 1、`grep -o 'DROP' agent/skills/spec-done/SKILL.md | wc -l` 输出 3、`grep -c 'git checkout --' agent/skills/spec-done/SKILL.md` 输出 1，且码点断言 ≤7849 退出码 0
- [x] 2.2 按 (b).T8 新建 `dsh/commands/spec-done.md` 并建容器内 symlink `~/.dsh/commands/spec-done.md`（T9，先例命令 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-done.md ~/.dsh/commands/spec-done.md`）；验证：`test -f dsh/commands/spec-done.md && test -f ~/.dsh/commands/spec-done.md` 退出码 0，且 `readlink ~/.dsh/commands/spec-done.md` 输出 `/home/xuqinqin/develop/dotfiles/dsh/commands/spec-done.md`
- [x] 2.3 呈证聚合层登记命令（T10，宿主操作：`ln -sfn /home/xuqinqin/develop/dotfiles/agent/skills/spec-done /home/xuqinqin/.local/share/agent-skills/skills/spec-done`）交用户执行，登记后核对可见；验证：`ls /home/docker/.agents/skills/ | grep -c spec-done` 输出 1（用户执行登记命令后）

## 3. spec-plan 侧供料契约

- [x] 3.1 按 (b).T11-1~2 修订 `agent/skills/spec-plan/refs/planning.md` 两处（1.7 模板①注明所属仓、落档摘要加触达仓清单）；验证：`grep -c '注明所属仓' agent/skills/spec-plan/refs/planning.md` 输出 1、`grep -c '触达仓清单' agent/skills/spec-plan/refs/planning.md` 输出 1，且码点断言 ≤7849 退出码 0
- [x] 3.2 按 (b).T12 修订 `agent/skills/spec-plan/SKILL.md` §六一处词组；验证：`grep -c '逐条注明所属仓' agent/skills/spec-plan/SKILL.md` 输出 1，且码点断言 ≤7849 退出码 0

## 4. 全量验证与一致性复核（只读）

- [x] 4.1 python3 单脚本汇总断言：10 个入库目标文件（T1/T2/T3/T4/T5/T6/T7/T8/T11/T12）码点全部 ≤7849，且附 (c) 表全部锚点按预期计数命中；验证：该脚本退出码 0
- [x] 4.2 `openspec validate spec-workflow-worktree-lifecycle --strict` 退出码 0（无 error/warning）；skill 内相对链接完整性断言（SKILL.md 与 refs 互引的 .md 文件全部 test -f）；`git status --porcelain` 改动仅限本变更目标文件集合与变更目录工件；验证：以上逐条退出码 0

## Workflow follow-up

- 全组完成后归档：`/spec-flow continue spec-workflow-worktree-lifecycle` → openspec-verify-change 校验 → 归档同步主规格（spec-done 新能力 + 两 MODIFIED）→ 归档提交。
- 本变更自身执行环境 = 直用主工作区（design.md 决策记录已留痕）；归档后收尾预期走 `/spec-done spec-workflow-worktree-lifecycle` 非隔离轻量收尾（首个适用样本）。
