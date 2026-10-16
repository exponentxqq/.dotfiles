# Tasks

> 触达面：T1–T5 `agent/skills/spec-plan/` 新建、T6–T10 `agent/skills/spec-workflow/` 改写、T11 命令接线、T12 文档、T13 yaml 注释、T14 主规格（归档经 delta 同步，不手改）。全部路径相对仓库根 `/home/xuqinqin/develop/dotfiles`；组间串行；每任务验证句第三方可核对。码点门限：入口 ≤7849（渲染 = 文件 + 343 ≤8192）、refs ≤8192。

## 1. spec-plan skill 新建（T1–T5）

- [ ] 1.1 新建 `agent/skills/spec-plan/SKILL.md`（触达面 T1）：frontmatter `name: spec-plan` + description（含「被 spec-workflow 委托」与「独立使用 / /spec-plan」双触发）；章节：总览（规划四阶段 1→1.5→1.7→2 终于落档提交；状态载体=工件；承诺）｜前置检查（①OpenSpec 根 ②参数 ③工作目录事实 ④能力自检含 grill-me ⑤路由自检）｜模式收集（仅 `--parallel`、`--model` 规划键）｜阶段 1 双线规划（7 字段、独立性铁律、中转协议·规划版：上浮并入 1.5）｜阶段 1.5 收敛（六步骨架 + convergence.md 指针）｜阶段 1.7 代码设计（骨架 + planning.md 指针）｜阶段 2 落档（骨架：①四件套→②批次契约→③分歧点提问→④validate --strict→⑤落档即停→⑥摘要→⑧工件单独提交；固定收尾=告知 `/spec-flow continue <变更名>`；无问执行模式步骤）｜模型路由（规划键）｜边界与失败（红线级 + 按需读取路由表）；验证：`python3 -c "import re;s=open('agent/skills/spec-plan/SKILL.md',encoding='utf-8').read();assert len(s)<=7849,len(s);assert len(s)+343<=8192;assert 'name: spec-plan' in s and 'spec-workflow' in s;assert '/spec-flow continue' in s;assert '问执行模式' not in s;assert '独立性铁律' in s and 'DELEGATED_CALLER' in s;print('cp=',len(s))"` 退出码 0

- [ ] 1.2 新建 `agent/skills/spec-plan/refs/planning.md`（触达面 T2）：迁自 `agent/skills/spec-workflow/refs/planning.md`——双线派发细节（并行/串行模板逐字保留、回执核对）、前置检查展开 ①④⑤、代码设计环节全量契约（栈识别与 writer skill 接线、派发模板、深度契约、回执核对清单、三档分降）、落档细节（9 步删第 7 步问执行模式；第 9 步改为固定收尾告知 continue；第 2 步批次契约补「组=执行审核批次、组内单任务合法、分组兼顾用户审核节奏」；补「栈识别结论写入落档 design.md 决策记录」句）；**不迁**「附：接续细节」；头注按新入口节号改写；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/planning.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert '7 个字段' in s and '独立性铁律' in s or '独立性' in s;assert '栈识别与 writer skill 接线' in s;assert '组即执行审核批次' in s and '单任务' in s;assert 'design.md' in s and '决策记录' in s;assert '问执行模式' not in s and '接续细节' not in s;print('cp=',len(s))"` 退出码 0

- [ ] 1.3 新建 `agent/skills/spec-plan/refs/convergence.md`（触达面 T3）：迁自 spec-workflow 同名文件，六步判据 1–6 与 grill-me 设计树/前沿法逐字保留，头注「本文件为 SKILL.md『阶段 1.5』的外移正文」按新节号改写；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/convergence.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert all(('%d. **'%i) in s for i in range(1,7));assert 'grill-me' in s and '设计树' in s and '前沿' in s;print('cp=',len(s))"` 退出码 0

- [ ] 1.4 新建 `agent/skills/spec-plan/refs/routing.md`（触达面 T4）：规划键表（lineA/lineB/panel/design/vision 五键应用点）、图片输入能力表、白名单硬约束、三档回退、路由自检脚本逐字保留（仍读共用 `/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml` 与 `profiles/web/cordis.patch.yml`）；补一行「apply/verify/engine/parallelism 由 spec-workflow 消费」；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/routing.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert all(k in s for k in ['lineA','lineB','panel','design','vision']);assert 'spec-workflow.yaml' in s and 'OK 全部路由 ⊆ 白名单' in s and 'cands=' in s;print('cp=',len(s))"` 退出码 0

- [ ] 1.5 新建 `agent/skills/spec-plan/refs/failure-modes.md`（触达面 T5）：规划侧行——skill/命令不可见（symlink 路径为 `~/.dsh/commands/spec-plan.md` → `dsh/commands/spec-plan.md`；skctl install spec-plan）、openspec-* 加载失败、grill-me 缺失降级、规划线失败重派、设计线同构、栈识别未命中三选一、writer 加载失败不静默降级、用户中断；红线级条目留 SKILL.md 的注记行保留；验证：`python3 -c "s=open('agent/skills/spec-plan/refs/failure-modes.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert 'spec-plan.md' in s and 'grill-me' in s and '三选一' in s and '不静默降级' in s;print('cp=',len(s))"` 退出码 0

## 2. spec-workflow 改写（T6–T10）

- [ ] 2.1 改写 `agent/skills/spec-workflow/SKILL.md`（触达面 T6）：三个规划节（§四/§五/§六）合并为「规划阶段（1→2）」委托节——加载 `spec-plan` skill 按其执行手册推进至落档提交，`--parallel` 与规划键 `--model` 原样转发、已预置不重问、规划外 scope 变化回到用户；衔接节吸收「确认执行模式与引擎」；接续节「tasks.md 空 → 问是否回阶段 1/2」改为「回规划 = 再加载 spec-plan」；§十一 键枚举改执行键 + 规划键归属注记；中转协议保留执行版；节结构重组（节号连续）；frontmatter 逐字节不变；验证：`python3 -c "import re;s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read();assert len(s)<=7849,len(s);assert len(s)+343<=8192;assert '加载 spec-plan' in s or 'spec-plan' in s;assert '原样转发' in s;assert '确认执行模式与引擎' in s;hs=re.findall(r'^## ',s,re.M);assert len(hs)>=8,hs;assert '独立性铁律' not in s and '设计树' not in s and '六字段' not in s;print('cp=',len(s))"` 退出码 0 且 `test -z "$(git diff agent/skills/spec-workflow/SKILL.md | grep '^[-+]name:\|^[-+]description:')"` 退出码 0

- [ ] 2.2 扩充 `agent/skills/spec-workflow/refs/execution.md`（触达面 T7）：吸收纪律级六条——①审核-提交分离（**任何模式**完成后不自动提交：呈现证据等用户审核确认，确认后才提交；用户明确豁免审核时除外；auto 批次间不打断、全部完成后停留呈证；主会话核对通过≠审核通过）②引擎批次间可切换（team↔subagent）+切换留痕③干净窗口验收两步法（无并发构建进程 + 无 SKIPPED 且 executed）④嵌套子仓分仓提交⑤真实凭据只经参数、缺凭据明确失败⑥执行期留痕与工件维护（code-design.md 组段终形态化、R<n> 编号规则、/tmp/<项目>-evidence/ 证据易失）；writer 加载指令来源改「从落档 design.md 决策记录读取；无从取得则重识别一次」；三模式提交表同步审核-提交分离口径；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/execution.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert 'SKIPPED' in s and 'executed' in s;assert '子仓' in s and '凭据' in s and '留痕' in s;assert '不等同于审核通过' in s and 'design.md' in s and '豁免' in s;print('cp=',len(s))"` 退出码 0

- [ ] 2.3 裁剪 `agent/skills/spec-workflow/refs/routing.md`（触达面 T8）：键表裁至 apply/verify/vision；补「lineA/lineB/panel/design（及 vision·规划侧）由 spec-plan 消费」归属注记；共享纪律（三档回退、图片能力、白名单、生效时机）与自检脚本逐字保留；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/routing.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert 'spec-plan' in s and 'apply' in s and 'verify' in s and 'vision' in s;assert 'OK 全部路由 ⊆ 白名单' in s;print('cp=',len(s))"` 退出码 0

- [ ] 2.4 裁剪 `agent/skills/spec-workflow/refs/failure-modes.md`（触达面 T9）：保留执行侧与共享行（命令不可见、openspec-* 加载失败、用户中断、审核被拒、任务失败、勾选态矛盾、路由白名单、读图、旧会话、team 成员、宿主操作）；删规划专行（grill-me 降级、规划线失败、栈识别三选一、writer 加载失败——已迁 spec-plan 侧）；补「team 成员上限达限（`Team member limit 8 reached`）→ 降级 subagent 完成该任务并留痕」行；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/failure-modes.md',encoding='utf-8').read();assert len(s)<=8192,len(s);assert 'limit 8 reached' in s;assert 'grill-me' not in s and '三选一' not in s;assert '以证据为准' in s;print('cp=',len(s))"` 退出码 0

- [ ] 2.5 删除 `agent/skills/spec-workflow/refs/planning.md` 与 `refs/convergence.md`（触达面 T10）：内容已迁 spec-plan 侧；验证：`test ! -f agent/skills/spec-workflow/refs/planning.md && test ! -f agent/skills/spec-workflow/refs/convergence.md` 退出码 0 且 `grep -rn 'refs/planning.md\|refs/convergence.md' agent/skills/spec-workflow/` 无命中（spec-workflow 目录内零断链）

## 3. 接线与文档（T11–T13）

- [ ] 3.1 新建 `dsh/commands/spec-plan.md`（触达面 T11）：frontmatter `description`（只规划落档不动手实现）+ `argument-hint: "[需求描述] [--parallel] [--model <规划阶段>=<provider>/<模型>]"`；正文「加载 spec-plan skill，并按其固定工作流执行。调用参数：$ARGUMENTS」+ 规则（未预置选项在对应阶段前询问、空参数开放式询问、落档后告知 /spec-flow continue）；验证：`python3 -c "import re;s=open('dsh/commands/spec-plan.md',encoding='utf-8').read();m=re.match(r'^---\n(.*?)\n---\n',s,re.S);assert m and 'description:' in m.group(1) and 'argument-hint' in m.group(1);assert '\$ARGUMENTS' in s and 'spec-plan' in s;print('ok')"` 退出码 0

- [ ] 3.2 建立命令挂载：容器内 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-plan.md ~/.dsh/commands/spec-plan.md`；验证：`readlink -f ~/.dsh/commands/spec-plan.md` 输出源本路径 且 `test -f` 通过

- [ ] 3.3 同步 `agent/skills/README.md` 与 `dsh/README.md`（触达面 T12）：清单表加 `spec-plan`（自写 local symlink）行；dsh/README spec-workflow 节改写——文件表两 skill 分列（spec-plan 5 文件 + spec-workflow 瘦身后清单）、双入口（/spec-plan 与 /spec-flow 及委托关系）、路由表键归属注记、组=审核批次语义、执行纪律六条摘要、宿主操作段补 spec-plan 两条；验证：`grep -c 'spec-plan' dsh/README.md` ≥8 且 `grep -c 'spec-plan' agent/skills/README.md` ≥1 且 `grep -n '组即执行审核批次\|组 = 执行审核批次' dsh/README.md` 命中 ≥1

- [ ] 3.4 `dsh/spec-workflow.yaml` 头注释补键归属分工一行（触达面 T13）：规划键 lineA/lineB/panel/design 与 vision·规划侧由 spec-plan 消费；apply/verify、vision·执行侧、engine、parallelism 由 spec-workflow 消费；验证：`git diff dsh/spec-workflow.yaml | grep '^[+-]' | grep -v '^[+-][+-]' | grep -v '^+ #'` 无输出（仅注释行新增）且 `node -e` 路由自检脚本逻辑输出含「OK 全部路由 ⊆ 白名单」退出码 0

## 4. 注册与冒烟（G4/G5）

- [ ] 4.1 登记 skill 进聚合层：经 node 容器执行 `~/develop/docker/run.sh node "node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install /home/xuqinqin/develop/dotfiles/agent/skills/spec-plan"`（失败则列为宿主操作交接）；验证：`ls -la /home/docker/.agents/skills/spec-plan` symlink 指向仓库目录 且 `test -f /home/docker/.agents/skills/spec-plan/SKILL.md` 退出码 0

- [ ] 4.2 运行时冒烟：会话内按名加载 `spec-plan`（返回规划四阶段版本）与 `spec-workflow`（返回委托化版本）各一次，记录返回码点 ≤8192；`/commands-reload` 后确认 `/spec-plan` 命令可见；验证：实测结果（两 skill 加载成功 + 返回码点数字 + 命令面板可见）记入执行日志

- [ ] 4.3 规格校验：`openspec validate split-spec-plan-skill --strict` 退出码 0 且无 error/warning；Requirement 正文 ≤500 字符复核；验证：`python3 -c "import re,glob;[print(f,len(m)) for f in glob.glob('openspec/changes/split-spec-plan-skill/specs/*/spec.md') for m in [max((len(''.join(l)) ) for l in [open(f,encoding='utf-8').read().split('### Requirement:')[1:]])]]"` 逐条复核 + 命令退出码 0（若拆分后仍 >500 则拆 Requirement 并复跑）

## 5. 归档（T14）

- [ ] 5.1 写执行日志（execution-log.md：码点门禁实测数字、加载冒烟证据、宿主操作清单、偏差记录）→ 确认 tasks.md 全部勾选 → `openspec-archive-change` 归档并同步主规格；归档后逐字复核主规格 diff：`openspec/specs/spec-plan/spec.md` 新建且 Purpose 与 11 个 Requirement 落位、`openspec/specs/spec-workflow/spec.md` MODIFIED 6 条精确替换 / REMOVED 6 条移除 / ADDED 6 条写入、无误伤；验证：`openspec validate --all` 与 `openspec validate --specs --strict` 退出码 0 且主规格无告警

- [ ] 5.2 归档单独提交一次（`docs(openspec): 归档 split-spec-plan-skill`），不与批次改动混提；最终汇报四要素（工件路径 / 验证证据 / 归档位置与主规格 / 宿主操作清单——含用户侧 `git push`、命令面板未出现时 `/commands-reload` 与重启兜底）

## Workflow follow-up

- 三次提交分离：落档提交 `docs(openspec): 落档 split-spec-plan-skill` → 实现批次提交 → 归档提交；一律显式 `git add` 指定文件，**排除** `dsh/profiles/web/cordis.patch.yml`（活 profile，非本变更写范围）与 `nvim/` 既有脏改动
