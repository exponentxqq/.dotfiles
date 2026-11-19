# Tasks：add-subagent-control-and-coordination

> 执行批次契约：`## N. 组名` = 执行审核批次，组间严格串行、组内可并行（写不同文件）；单组 ≤ `parallelism`（=8）。每任务描述引用 `code-design.md` 触达面条目编号（#N）；验证句第三方可跑。逐字协议文案一律从 `code-design.md` ③ 抄，不再二次创作。

## 1. RED 基线（写作前）

- [x] 1.1 派 1 个 fresh 子代理做 RED 基线（触达 #1 前置）：喂 `git show HEAD:agent/skills/spec-apply/refs/execution.md` 的 :8 台账段原文 + 场景「你与另一子代理同批执行、写范围都含 agent/skills/spec-apply/SKILL.md，你的提示里没有任何协调指令」+ 只答「开工第一件事做什么 / 发现写范围重叠怎么办 / 会不会通知主会话」三问（不执行、不写文件）；逐字记入 /tmp/spec-flow/add-subagent-control-and-coordination/red-baseline.md，含三栏（是否提及读 progress.md / 是否让路 / 是否提及上行）与一行 `RED 结果：复现|未复现`，未复现如实标注不伪造；验证：test -s /tmp/spec-flow/add-subagent-control-and-coordination/red-baseline.md 退出码 0，且 grep -qE '^RED 结果：(复现|未复现)$' 该文件，且三栏关键字（progress.md/让路/上行）各至少出现一次，且 test -z "$(git status --porcelain -- agent/skills openspec/specs)" 退出码 0（本组零落盘）

## 2. 协议权威源

- [x] 2.1 新建 agent/skills/spec-apply/refs/coordination.md（触达 #1）：按 code-design.md ③3.1–3.7 逐字创建 10 节（§1 平台事实｜§2 登记簿 schema+状态机｜§3 派发前登记序｜§4 注入段模板（含 coord-inject 标记）｜§5 上行格式+三示例｜§6 检查点与软废止｜§7 spec-plan 精简段｜§8 冲突矩阵｜§9 升级判据｜§10 长度与维护），不写其他任何文件；验证：test -f agent/skills/spec-apply/refs/coordination.md 且 python3 -c "s=open('agent/skills/spec-apply/refs/coordination.md',encoding='utf-8').read();assert 3800<=len(s)<=5000,len(s)" 退出码 0；注入段行数 awk '/<!-- coord-inject:start -->/,/<!-- coord-inject:end -->/' agent/skills/spec-apply/refs/coordination.md | sed '1d;$d' | wc -l 落在 7–15；grep -c 'active→done|void|stalled' 该文件 =1；grep -c '写者 SHALL 仅为主会话' 该文件 ≥1；grep -c '^## §' 该文件 =10；grep -c 'spec-plan' 该文件 ≥1

## 3. spec-apply 接线

- [x] 3.1 改 agent/skills/spec-apply/refs/execution.md（触达 #2）：:8 台账段重写为 v2 登记簿（③3.1 字段与状态机）+ 其后插「协调注入（仅 subagent 引擎）」行 + team 段后插「team 引擎不注入协调段」行；:5 提示自包含清单不改；:9 回执格式追加「检查点命中废止/停滞时回执首行 VOIDED/STALLED」；验证：python3 -c "s=open('agent/skills/spec-apply/refs/execution.md',encoding='utf-8').read();assert 5250<=len(s)<=5500,len(s)" 退出码 0；grep -c 'coordination.md' 该文件 =1；grep -c 'state=active' 该文件 ≥1；grep -c 'active→done|void|stalled' 该文件 =1；grep -c 'VOIDED' 该文件 =1；grep -c 'team 引擎不注入协调段' 该文件 =1
- [x] 3.2 改 agent/skills/spec-apply/SKILL.md（触达 #3）：:39 路由行追加「仅 subagent 派发前另读 coordination.md」；:37 后插「协调纪律（仅 subagent 引擎）」行（含派发前升级判据提示，③3.6）；:43 §四 追加「上行通道」句；:55 红线区与 frontmatter 零改动；验证：python3 -c "import re;s=open('agent/skills/spec-apply/SKILL.md',encoding='utf-8').read();fm=re.match(r'^---\n.*?\n---\n\n',s,re.S).group(0);r=len(s)-len(fm)+343;print(len(s),r);assert r<=8192 and 3600<=len(s)<=3800" 退出码 0；grep -c 'refs/coordination.md' 该文件 =1；grep -c '协调纪律' 该文件 =1；grep -c '上行通道' 该文件 =1；test -z "$(git diff -- agent/skills/spec-apply/SKILL.md | grep '^[-+]description:\|^[-+]name:')"；grep -c '^## ' 该文件 =7（未新增节）
- [x] 3.3 改 agent/skills/spec-apply/refs/failure-modes.md（触达 #4）：:17 拆方向重写（下行不可达/上行可用）；:18 作废 job_list 判据（改「登记簿条目状态 + 写范围落盘事实」）；新增 2 行（检查点命中 void/stalled、上行发送失败降级回执）；验证：test -z "$(grep '子代理不是 teammate、不可消息寻址' agent/skills/spec-apply/refs/failure-modes.md)"（矛盾句消失）；test -z "$(grep 'job_list' agent/skills/spec-apply/refs/failure-modes.md | grep -v '不得作为在途判据')"；grep -c '上行' 该文件 ≥2；grep -c 'VOIDED' 该文件 =1；python3 -c "s=open('agent/skills/spec-apply/refs/failure-modes.md',encoding='utf-8').read();assert 2100<=len(s)<=2350,len(s)" 退出码 0；grep -c '^|' 该文件 由 17 → 19

## 4. spec-plan 接线与联动修正

- [x] 4.1 改 agent/skills/spec-plan/SKILL.md（触达 #5）：仅 :80（两条禁令）后插 1 行 97 cp 上行通道指路句（③3.7 指路版）；验证：python3 -c "import re;s=open('agent/skills/spec-plan/SKILL.md',encoding='utf-8').read();fm=re.match(r'^---\n.*?\n---\n\n',s,re.S).group(0);r=len(s)-len(fm)+343;print(len(s),r);assert r<=8192 and 8192-r>=40" 退出码 0（余量 ≥40 cp 硬门；不足则改用 58 cp 降级版并将指路句移入 parallel.md/planning.md，见 code-design ⑥U1）；grep -c '上行通道' 该文件 =1；grep -c 'send_message' 该文件 =3；git diff --numstat -- agent/skills/spec-plan/SKILL.md 新增行 =2（1 空行 + 1 内容行）、删除行 =0
- [x] 4.2 改 agent/skills/spec-plan/mode/parallel.md（触达 #6）：:45 硬约束块末补 2 行（A/B 线注入精简段，两线除占位外逐字等形）；:53 回执核对追加「收到上行仍并入 1.5」一句；验证：python3 -c "s=open('agent/skills/spec-plan/mode/parallel.md',encoding='utf-8').read();assert 2900<=len(s)<=3100,len(s)" 退出码 0；grep -c '上行（可选，仅两类事件）' 该文件 =1；grep -c '提问节奏不变' 该文件 =1；grep -c 'A线|B线' 该文件 =1；grep -c '不在此等待答复' 该文件 =1
- [x] 4.3 改 agent/skills/spec-plan/refs/planning.md（触达 #7）：:41（先加载 writer skill 行）后插设计线精简段 1 行；六字段与回执核对清单不动；验证：python3 -c "s=open('agent/skills/spec-plan/refs/planning.md',encoding='utf-8').read();assert 7550<=len(s)<=7849,len(s)" 退出码 0（余量 ≤300 cp 硬门）；grep -c '设计\]\[决|异\]' 该文件 =1；grep -c '六字段' 该文件 =4（基线不变）；grep -c '深度契约' 该文件 =2（基线不变）
- [x] 4.4 改 agent/skills/spec-plan/refs/convergence.md（触达 #8）：:13 复算子代理 bullet 追加「上行同学 §四 精简段：仅决/异，无租约、无检查点」；验证：grep -c '无租约、无检查点' agent/skills/spec-plan/refs/convergence.md =1；python3 -c "s=open('agent/skills/spec-plan/refs/convergence.md',encoding='utf-8').read();assert 2560<=len(s)<=2650,len(s)" 退出码 0
- [x] 4.5 改 agent/skills/spec-plan/refs/failure-modes.md（触达 #9）：表末新增「上行发送失败降级为回执上浮」1 行；验证：grep -c '降级为回执上浮' agent/skills/spec-plan/refs/failure-modes.md =1；python3 -c "s=open('agent/skills/spec-plan/refs/failure-modes.md',encoding='utf-8').read();assert 3080<=len(s)<=3160,len(s)" 退出码 0；grep -c '^|' 该文件 由 16 → 17
- [x] 4.6 改 agent/skills/spec-workflow/SKILL.md:65（触达 #13，P1=a）：恢复协议第 3 步删「job_list 判在途/已丢」判据，改「登记簿条目状态 + 写范围落盘事实」（单行改写，无 spec delta）；验证：test -z "$(grep 'job_list' agent/skills/spec-workflow/SKILL.md | grep -v '不得作为在途判据')"（原判据消失）；grep -c '登记簿' agent/skills/spec-workflow/SKILL.md ≥1；python3 -c "import re;s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read();fm=re.match(r'^---\n.*?\n---\n\n',s,re.S).group(0);assert len(s)-len(fm)+343<=8192" 退出码 0

## 5. spec delta 只读核对（delta 已随落档生成，本组不写工件）

- [x] 5.1 核对 openspec/changes/add-subagent-control-and-coordination/specs/spec-apply/spec.md 与 code-design.md ③3.8 逐字一致：MODIFIED ×1 段（2 条）+ ADDED ×1 段（1 条）、场景 16 个、ADDED 正文 ≤500 cp；验证：grep -c '^## MODIFIED Requirements' 该文件 =1；grep -c '^## ADDED Requirements' 该文件 =1；grep -c '^### Requirement:' 该文件 =3；grep -c '^#### Scenario:' 该文件 =16；python3 -c "import re;s=open('openspec/changes/add-subagent-control-and-coordination/specs/spec-apply/spec.md',encoding='utf-8').read();m=re.search(r'### Requirement: subagent 运行协调.*?\n(.*?)#### Scenario:',s,re.S);assert len(m.group(1).strip())<=500" 退出码 0；test -z "$(grep -n 'ask_question' 该文件)"
- [x] 5.2 同法核对 specs/spec-plan/spec.md：MODIFIED ×1 段（1 条）、场景 5 个、正文 422±20 cp；验证：grep -c '^## ADDED Requirements' 该文件 =0；grep -c '^### Requirement:' 该文件 =1；grep -c '^#### Scenario:' 该文件 =5；python3 -c "import re;s=open('openspec/changes/add-subagent-control-and-coordination/specs/spec-plan/spec.md',encoding='utf-8').read();m=re.search(r'### Requirement:.*?\n(.*?)#### Scenario:',s,re.S);assert 400<=len(m.group(1).strip())<=500" 退出码 0
- [x] 5.3 组级门：openspec validate add-subagent-control-and-coordination --strict 退出码 0 且无 error/warning（不得用 --all --strict——spec-plan 主规格基线已红 2 条，非本次引入）；验证：cd /home/xuqinqin/develop/dotfiles && openspec validate add-subagent-control-and-coordination --strict; echo exit=$? 断言 exit=0

## 6. GREEN 配对复测与无裁剪终检

- [x] 6.1 派 1 个 fresh 子代理做 GREEN 配对（与 1.1 同场景，提示换为 ③3.2 注入段全文 + 3 条上行示例）：记录 /tmp/spec-flow/add-subagent-control-and-coordination/green-check.md，含三栏（是否读登记簿/是否让路/是否按格式上行）+ 一行 `GREEN 结果：通过|摇摆` + 与 RED 的一行对比结论；验证：grep -q 'send_message(agent_id' green-check.md 且 grep -q 'VOIDED' green-check.md 且 grep -qE '^GREEN 结果：(通过|摇摆)$' green-check.md 且 grep -q 'RED' green-check.md 均命中
- [x] 6.2 无裁剪终检：主会话按名加载 skill spec-plan 与 skill spec-apply，断言返回正文含新增句且不含中段裁剪标记；验证：加载回执含「上行通道」（spec-plan）与「协调纪律」（spec-apply）；grep -c '^## ' agent/skills/spec-plan/SKILL.md =10（未新增节）；重跑 4.1 渲染公式（渲染 ≤8192、余量 ≥40）

## 附录：执行期留痕

- **R1（writer skill 与探针纪律冲突的裁定）**：RED/GREEN 探针任务（组 1/组 6）的派发提示同时含 execution.md v1 的「writer skill 加载指令」与任务本体的「仅凭探针材料作答、不补课」纪律，二者冲突 → 探针纪律优先、跳过加载。依据：writing-skills 为 skill 写作纪律库，探针产出仅为行为记录文件，加载对产出无影响且可能污染第一反应；重跑无法恢复纯净基线。适用范围：组 1（已裁定 2026-11-19）、组 6 GREEN 探针（同此裁定）。连锁面：组 6 派发提示按本条省略 writing-skills 加载指令；6.1 验证句不涉及 writing-skills，无连锁修改。
- **R2（长度门优先于 ③逐字素材）**：coordination.md 实测 ③3.1–3.7 原文合计约 5733 cp，与验证句硬断言 `3800<=len<=5000` 不可同时满足 → **验证句优先**（tasks.md 是落档审核过的验收权威；code-design 3.9 设计目标 ~4600 佐证长度门为设计意图，③逐字超长系规划期写作疏漏）。裁定 a 案：保协议语义+关键逐字串（状态机、写者规则、机械判据、注入段全文连标记、上行三示例、§7 精简段代码块、冲突矩阵 5 行、升级判据表），压缩表格冗长解释，实测 len=4996（2026-11-19，子代理 c4b6ccaf）。适用范围：coordination.md 全文件。连锁面：§7 精简段删去 `parallel.md:27` file:line（等形要求保留，不影响 4.2 验证句）；组 5 delta 核对对象是 spec delta 文件、不受本裁定影响；消费方 grep 常量（`active→done|void|stalled` 等）保持不变。

## 附录：沉淀回流清单（spec-done 六要素汇报数据源，工件化于最后批次组收尾）

执行期改动全部落在本仓（dotfiles）工作区，**auto 模式：经用户审核确认后一次提交**。逐条去向：

| 触达 | 文件 | 性质 |
| --- | --- | --- |
| #1 | agent/skills/spec-apply/refs/coordination.md | 新建（协议权威源，10 节） |
| #2 | agent/skills/spec-apply/refs/execution.md | 改（v2 登记簿 + 协调注入 + team 不注入 + VOIDED 回执） |
| #3 | agent/skills/spec-apply/SKILL.md | 改（协调纪律 + 路由 + 上行通道，frontmatter/红线区零改动） |
| #4 | agent/skills/spec-apply/refs/failure-modes.md | 改（拆方向 + job_list 作废 + 新增 2 行） |
| #5 | agent/skills/spec-plan/SKILL.md | 改（上行通道指路句 1 行） |
| #6 | agent/skills/spec-plan/mode/parallel.md | 改（A/B 线注入 + 收到上行仍并入 1.5） |
| #7 | agent/skills/spec-plan/refs/planning.md | 改（设计线精简段 1 行） |
| #8 | agent/skills/spec-plan/refs/convergence.md | 改（复算 bullet 追加） |
| #9 | agent/skills/spec-plan/refs/failure-modes.md | 改（上行失败降级 1 行） |
| #13 | agent/skills/spec-workflow/SKILL.md | 改（恢复协议第 3 步登记簿判据单行改写） |
| 工件 | openspec/changes/add-subagent-control-and-coordination/{tasks,design,code-design}.md | 勾选态 + 执行环境块 + 各组终形态/R<n>（#10/#11 两 delta 落档后未动，本组只读核对） |

未提交待决：无（除上表外无执行期改动；`/tmp/spec-flow/` 与证据材料不入库）。范围外披露（不在本变更提交面）：①`dsh/profiles/web/cordis.patch.yml`（执行窗口内出现的外部改动：agent-default-model glm-5.3-flash→glm-5.3，非触达面，显式排除，归属待用户确认）；②`spec-done/SKILL.md:49` 旧术语「progress 派发台账」（触达面外，未改）。
