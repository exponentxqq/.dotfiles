# Tasks

> 触达面：T1 `refs/convergence.md`、T2 `refs/planning.md`、T3 `refs/execution.md`、T4 `refs/routing.md`、T5 `refs/failure-modes.md`、T6 `SKILL.md`、T7 `dsh/README.md`；主会话串行执行（轻量变更，无子代理派发）；每任务验证句第三方可核对。

## 1. refs 无损修缮（去重、编号、结构、头注）

- [ ] 1.1 删除 `refs/convergence.md` 顶部重复块并校正头注（触达面 T1）：删 L3–10 与六步展开内第 4 步逐字一致的 801 码点块（保留展开内那份），L1 头注改为「§五外移正文（六步判据全文，含第 4 步 `grill-me` 方法）」；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/convergence.md',encoding='utf-8').read();assert len(s)<=2100,len(s);ms=['映射为设计树','只问前沿','每轮 ≤5 问','事实自行查证','答完重算前沿','收敛结束条件','答复回送','不因此改变的部分'];assert all(s.count(m)==1 for m in ms),[m for m in ms if s.count(m)!=1];assert all(('%d. **'%i) in s for i in range(1,7));print('cp=',len(s))"` 退出码 0

- [ ] 1.2 `refs/planning.md` 头注补齐、补父级 H2、删冗余残段、前置检查展开改标 ①④⑤（触达面 T2）：L1 补 §二/§四/§六/§十 与阶段 1.7；`### 并行模式` 前插入 `## 附：阶段 1 双线派发细节（自 SKILL.md §四 外移）`；删「**入口指引**（自 SKILL.md §四 剪切）」残段；§二 展开三项改标 ①/④/⑤ 并注明「②参数 与 ③工作目录事实 正文留在入口 §二，此处不重复」；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/planning.md',encoding='utf-8').read();assert len(s)<=6500,len(s);assert s.count('## 附：阶段 1 双线派发细节')==1;assert '入口指引（自 SKILL.md §四 剪切）' not in s;assert '①OpenSpec 根' in s and '④能力自检' in s and '⑤路由自检' in s;assert '§十' in s and '阶段 1.7' in s;print('cp=',len(s))"` 退出码 0

- [ ] 1.3 `refs/execution.md` 头注补齐 §九 并补「中途恢复以现存 diff 为准」要点（触达面 T3）：L1 改为 §八（双引擎、三模式与提交纪律、硬停条件）与 §九（验证与归档派发要点）；三模式节增一条（auto 收尾才提交 → 先跑验证句 → 通过即保持勾选不重派）；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/execution.md',encoding='utf-8').read();assert len(s)<=3300,len(s);assert '§九' in s;assert '现存 diff' in s and '保持勾选' in s;print('cp=',len(s))"` 退出码 0

## 2. 语义澄清与自检健壮化

- [ ] 2.1 `SKILL.md` §七 恢复协议第 3 步补「以现存 diff 为准」并以冗余收紧置换（触达面 T6）：改写第 3 步（勾选无证据 → 回退；提交对不上 → 先跑验证句，通过即保持勾选不重派，auto 未提交属预期）；删除 §四 末行「**派发前先读 [planning.md]…逐字等形**」冗余指针；收紧 §七 第 1 步注记（`openspec status --all --json` → `--all --json`、去粗体）、§一「（唯一源）」；**不得触及** frontmatter、12 个 `## ` 节标题、红线表、恢复协议语义、中转协议与「绝不做」段；验证：`python3 -c "import re;s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read();assert len(s)<=7816,len(s);assert len(re.findall(r'^## ',s,re.M))==12;assert '以现存 diff 为准' in s;assert '**派发前先读 [planning.md]' not in s;print('cp=',len(s))"` 退出码 0 且 `test -z "$(git diff agent/skills/spec-workflow/SKILL.md | grep '^[-+]name:\|^[-+]description:')"` 退出码 0

- [ ] 2.2 `refs/routing.md` 自检脚本 yaml 依赖候选探测 + 全缺降级（触达面 T4）：候选 `yaml`（cwd）→ `/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/yaml` → `/home/xuqinqin/develop/dotfiles/opencode/node_modules/yaml`；全缺时打印「缺 yaml 依赖：路由自检跳过（未校验，不等于通过）」并退出码 0；白名单正则、映射展开、正例输出与越界退出码 1 保持逐字不变；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/routing.md',encoding='utf-8').read();assert len(s)<=4100,len(s);assert 'cands=' in s and '不等于通过' in s and 'OK 全部路由 ⊆ 白名单' in s;print('cp=',len(s))"` 退出码 0

- [ ] 2.3 `refs/failure-modes.md`「勾选态与证据矛盾」行改为执行纪律同口径（触达面 T5）：以证据为准 → 先对现存 diff 跑该任务验证句（auto 收尾才提交、未提交属预期），通过即保持勾选不重派，不通过才回退并报告；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/failure-modes.md',encoding='utf-8').read();assert len(s)<=2350,len(s);assert '以证据为准' in s and '现存 diff' in s and '保持勾选' in s;print('cp=',len(s))"` 退出码 0

## 3. 文档同步

- [ ] 3.1 `dsh/README.md` 文件表与三模式段同步（触达面 T7）：`refs/planning.md` 行补 §二/§六/§十 来源、`refs/execution.md` 行补 §九、三模式段补「auto 收尾才提交；中途恢复先对现存 diff 跑验证句，通过即保持勾选」；验证：`python3 -c "s=open('dsh/README.md',encoding='utf-8').read();import re;assert '§二' in s and '§十' in s;assert s.count('refs/execution.md')>=1 and s.count('refs/planning.md')>=1;assert '现存 diff' in s or '中途恢复' in s;print('ok')"` 退出码 0

## 4. 验证与冒烟（只读）

- [ ] 4.1 码点与结构门禁（G1/G2/G3）：六文件码点逐项 ≤8192（SKILL.md ≤7816）；`SKILL.md` `## ` 标题 12、frontmatter 门禁、全部 href 目标存在；`convergence.md` 要点唯一性；验证：逐条断言退出码 0 并把实测数字记入执行日志

- [ ] 4.2 渲染预算与加载冒烟（G4）：渲染上界 = `SKILL.md` 码点 + 343 ≤8192；会话内按名加载 `spec-workflow` 返回改后版本、`refs/` 五文件可见；验证：实测数字与加载结果记入执行日志

- [ ] 4.3 路由自检三例（G5）：正例（原样脚本）退出码 0 且打印「OK 全部路由 ⊆ 白名单」；负例（`/tmp` 夹具含越白名单路由）退出码 1 且打印「不在白名单」；降级例（候选全为不存在路径）打印「跳过」且退出码 0；验证：三例退出码与输出摘要记入执行日志

- [ ] 4.4 项目声明回归（G7）：`tools/skctl` 下经 pnpm 包装跑 `node --test 'test/*.test.ts'`；验证：退出码 0、tests 47 / pass 47 / fail 0

- [ ] 4.5 变更校验（G6）：`openspec validate spec-workflow-consolidation-polish --strict`；验证：输出 valid、退出码 0

## Workflow follow-up

- 全部勾选后：写 `execution-log.md` → `openspec-archive-change` 归档并逐字复核主规格 diff（确认「调研」已改为「规划」、新 Scenario 已写入、其余 Requirement 未被规整误改）→ 归档单独提交 → 四要素汇报；三次提交一律显式 `git add` 指定文件，**排除** `dsh/profiles/web/cordis.patch.yml`。
