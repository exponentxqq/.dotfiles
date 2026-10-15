# Tasks

> 触达面：T1 `refs/planning.md`、T2 `refs/execution.md`、T3 `SKILL.md`、T4 `refs/failure-modes.md`、T5 `dsh/README.md`、T6 主规格（归档时经 delta 同步，不手改）；主会话串行执行（轻量变更，无子代理派发）；每任务验证句第三方可核对；全部路径相对仓库根 `/home/xuqinqin/develop/dotfiles`。

## 1. refs 接线（阶段 1.7 与两引擎的 writer skill 加载）

- [x] 1.1 `refs/planning.md`「附：代码设计环节（阶段 1.7）」接 writer skill（触达面 T1）：新增小节「栈识别与 writer skill 接线（派发前，主会话）」——判据（`pom.xml`/`build.gradle(.kts)` 含 `spring-boot` 判 Spring；`nuxt.config.*` 或 package.json 依赖含 `nuxt` 判 Nuxt；monorepo 子包一并探测；双命中全加载）、未命中问用户三选一（指认／豁免并如实标注／终止，不静默跳过）、可加载性核对（聚合层 `~/.agents/skills/<name>/`，失败按 failure-modes 处置顺序后报告问用户）、结论与证据记阶段摘要、阶段 3 沿用结论；设计提示模板加「先加载 skill：<点名>，其规范是本次设计的硬约束」行；回执核对清单加第 ⑥ 条「回执注明已加载的 writer skill 名（或豁免依据）」；三档分降补 L0 断言标注「未触 writer 约束、涉分层/拆分/接口即升档」；「附：落档细节」第 2 步加「任务粒度同时满足所加载 writer skill 的拆分规定（引名不复述数值）」；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/planning.md',encoding='utf-8').read();assert len(s)<=7200,len(s);assert s.count('栈识别与 writer skill 接线')==1;assert '先加载 skill' in s and 'spring-writer' in s and 'nuxt-writer' in s;assert '三选一' in s and '不静默跳过' in s;assert '未触 writer 约束' in s and '拆分规定' in s;assert s.count('⑥**writer 加载回执**')==1;print('cp=',len(s))"` 退出码 0（门限 ≤7200；实测 7133。偏差 D-1：原验证句 `count('⑥')==1` 与文件中既有 4 处 ⑥ 冲突，改为唯一串判定，见执行日志）

- [x] 1.2 `refs/execution.md` 两引擎派发提示接 writer skill（触达面 T2）：subagent 引擎「提示自包含」清单加「栈对应 writer skill 加载指令（点名 skill 名，沿用阶段 1.7 栈识别结论；豁免时注明依据）」；team 引擎任务卡内容加同款指令；§九 验证环节不动（只读不写码）；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/execution.md',encoding='utf-8').read();assert len(s)<=3500,len(s);assert s.count('writer skill 加载指令')>=2;assert '沿用阶段 1.7 栈识别结论' in s;print('cp=',len(s))"` 退出码 0

- [x] 1.3 `refs/failure-modes.md` 加两行处置（触达面 T4）：「栈识别未命中 writer skill」→ 问用户三选一（指认／豁免并如实标注／终止），不静默跳过；「writer skill 加载失败」→ 按既有处置顺序（登记核对 → `/commands-reload` → 重启兜底）修复，仍失败报告问用户（不允许静默降级，区别于 `grill-me` 缺失降级）；验证：`python3 -c "s=open('agent/skills/spec-workflow/refs/failure-modes.md',encoding='utf-8').read();assert len(s)<=2600,len(s);assert s.count('三选一')==1 and '加载失败' in s and '不静默降级' in s;print('cp=',len(s))"` 退出码 0

## 2. 入口标记与文档同步

- [x] 2.1 `SKILL.md` §五/§八 最短标记（触达面 T3）：§五 阶段 1.7 段加「**须先加载栈对应 writer skill**」（细节由同句 planning.md 指针承载）；§八 已有 execution.md 指针句内加「提示模板（含 writer skill 加载指令）」；两处合计净增 ≤53 码点且 file ≤7849；**不得触及** frontmatter、12 个 `## ` 节标题、红线表、恢复协议、中转协议与「绝不做」段；验证：`python3 -c "import re;s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read();assert len(s)<=7849,len(s);assert len(re.findall(r'^## ',s,re.M))==12;assert '须先加载栈对应 writer skill' in s and '含 writer skill 加载指令' in s;print('cp=',len(s))"` 退出码 0（偏差 D-2：§五 指针「writer skill 接线」扩写与要求重复且超 53 码点预算，改为只留强制标记 + §八 指针内嵌加载指令，见执行日志） 且 `test -z "$(git diff agent/skills/spec-workflow/SKILL.md | grep '^[-+]name:\|^[-+]description:')"` 退出码 0

- [x] 2.2 `dsh/README.md` 同步 writer 接线（触达面 T5）：文件表 `refs/planning.md` 行（L130）与 `refs/execution.md` 行（L131）描述各补「writer skill 接线/加载指令」；阶段 1.7 段（L149）补「派发前主会话做栈识别、设计子代理先加载栈对应 writer skill（spring-writer/nuxt-writer），未命中问用户三选一」；design 路由表行（L191）补同口径短句；阶段 3 引擎段补「执行提示/任务卡含 writer skill 加载指令」；验证：`python3 -c "s=open('dsh/README.md',encoding='utf-8').read();assert s.count('writer skill')>=5;assert 'spring-writer' in s and 'nuxt-writer' in s and '三选一' in s;print('ok,count=',s.count('writer skill'))"` 退出码 0

## 3. 验证与冒烟（只读）

- [x] 3.1 码点与结构门禁（G1/G2/G3）：六文件码点逐项 ≤8192、`SKILL.md` ≤7849 且渲染上界（码点+343）≤8192；`SKILL.md` `## ` 标题 12、frontmatter 逐字节不变、全部 href 目标存在；planning/execution/failure-modes 接线断言（G3）复跑通过；验证：逐条断言退出码 0 并把实测数字记入执行日志

- [x] 3.2 运行时冒烟（G4）：会话内按名加载 `spec-workflow` 返回改后版本（§五 新标记、planning 新小节可见）、`refs/` 五文件可见；聚合层 `~/.agents/skills/spring-writer/SKILL.md`、`~/.agents/skills/nuxt-writer/SKILL.md` 存在（`test -f`）；验证：实测结果记入执行日志

- [x] 3.3 规格与回归（G5/G6）：`openspec validate spec-workflow-writer-skill-integration --strict` 退出码 0；`tools/skctl` 下经 pnpm 包装跑 `node --test 'test/*.test.ts'` 47/47 通过退出码 0

## Workflow follow-up

- 全部勾选后：写 `execution-log.md` → `openspec-archive-change` 归档并逐字复核主规格 diff（确认四个 MODIFIED Requirement 与 8 个新 Scenario 写入、其余 Requirement 未被规整误改）→ 归档单独提交 → 四要素汇报；三次提交一律显式 `git add` 指定文件，**排除** `dsh/profiles/web/cordis.patch.yml`。
