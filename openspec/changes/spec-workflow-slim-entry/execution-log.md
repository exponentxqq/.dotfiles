# 执行记录：spec-workflow-slim-entry

> 本文件记录阶段 3 执行与阶段 4 验证期间的**轨迹与证据**（执行者、实跑输出、偏差、自举观察），随变更归档。所有数字均为实跑所得；未实测项一律标注「未执行」。

## 一、阶段 3 批次 1（组 1：生成新 references 文件）

**批次目标**：纯剪切外移——新建 `convergence.md`（§五第 4 步 `grill-me` 方法展开，SKILL.md 149–156 行）、`execution.md`（§八两个引擎小节，SKILL.md 210–227 行）；**本批次不改入口**。

**执行编排**：引擎 `team`，模式 `step-group`；组内 2 任务并行派发，任务板卡片 `task-8`（1.1）、`task-9`（1.2）。

| 任务 | 执行者 | 卡片 | 产物 | 码点 | 行数 |
| --- | --- | --- | --- | --- | --- |
| 1.1 `convergence.md` | teammate `conv-writer`（fresh，`deepseek-v4.1-flash`） | task-8 → completed | `agent/skills/spec-workflow/convergence.md` | 881 | 10（1 说明 + 空行 + 8 正文） |
| 1.2 `execution.md` | **降级 fresh subagent**（`apply` 路由 `opencode-go/deepseek-v4.1-flash`） | task-9（Lead 记账） | `agent/skills/spec-workflow/execution.md` | 1582 | 20（1 说明 + 空行 + 18 正文） |

两文件均由卡片给出的**确切 shell 命令**机械生成（`printf` 说明行 + `printf` 空行 + `sed -n 'a,bp'` 重定向），正文零手打、零改写。

### 偏差 D-1：引擎降级（非故障）

`spawn_teammate` 创建第二个成员时返回 **`Team member limit 8 reached`**：本会话已有 7 个第一步变更（`spec-workflow-externalize-references`）遗留的 inactive 成员，加本批次 1 个成员 = 8，达上限。处置：按 SKILL.md 第八节「成员创建失败或不可用时按 design『风险与回退』**降级为 subagent** 完成该任务」，**1.2 降级为 fresh subagent** 并按其 `apply` 路由派发（派发成功，无路由错误）；卡片 `task-9` 由 Lead 记账（claim → complete）。组内实际并行度 = 1 成员 + 1 子代理；两任务同形（机械剪切），交付质量与路径无关。

### Lead 独立核对（§八「两引擎共同纪律」：不采信回执结论，实跑验证句）

```
$ python3 -c "s=open('agent/skills/spec-workflow/convergence.md',encoding='utf-8').read(); assert s.strip() and len(s)<=8192; print('cp=',len(s))"
cp= 881
$ sed -n '149,156p' agent/skills/spec-workflow/SKILL.md | diff - <(tail -n +3 agent/skills/spec-workflow/convergence.md) && echo CONV_DIFF_OK
CONV_DIFF_OK
$ wc -l agent/skills/spec-workflow/convergence.md
10 agent/skills/spec-workflow/convergence.md

$ python3 -c "s=open('agent/skills/spec-workflow/execution.md',encoding='utf-8').read(); assert s.strip() and len(s)<=8192; print('cp=',len(s))"
cp= 1582
$ sed -n '210,227p' agent/skills/spec-workflow/SKILL.md | diff - <(tail -n +3 agent/skills/spec-workflow/execution.md) && echo EXEC_DIFF_OK
EXEC_DIFF_OK
$ wc -l agent/skills/spec-workflow/execution.md
20 agent/skills/spec-workflow/execution.md

$ git status --porcelain
?? agent/skills/spec-workflow/convergence.md
?? agent/skills/spec-workflow/execution.md
$ git diff --stat          # tracked 文件零改动 → 组 1 未触碰 SKILL.md
（无输出）
```

**幂等复算**（源块与成品正文 md5 对照，两者相同即逐字节一致）：

| 对象 | 源块 md5 | 成品正文 md5 | 结论 |
| --- | --- | --- | --- |
| `convergence.md` ← SKILL.md 149–156 行 | `eb871b0d430c85f5b5de11612cb0c71e` | `eb871b0d430c85f5b5de11612cb0c71e` | 一致 |
| `execution.md` ← SKILL.md 210–227 行 | `76786ade73e81c48d10888a55dfc5d8d` | `76786ade73e81c48d10888a55dfc5d8d` | 一致 |

**其他旁证**：文件权限 `644`，与既有 `routing.md` / `failure-modes.md` / `planning.md` 一致；两文件首行来源说明与卡片要求逐字一致（`本文件为 SKILL.md 第五节第 4 步…` / `本文件为 SKILL.md 第八节…`）；成员与子代理均未执行 `git add` / `commit` / `stash`，暂存区为空。

## 二、自举行为观察（tasks.md Workflow follow-up）

1. **派发前是否按路由表读 `routing.md`**：本批次派发前，Lead 按**现行入口**路由表第 2 行「派发任一子代理 / 团队成员前 → 读 `routing.md`」读取了 `routing.md`；读后确认其第 63 行「`team` 引擎**忽略 `apply` 键，阶段级模型路由整体不适用**」。即：按现行措辞，team 引擎派发前读该文件的实际收益仅为「确认无需应用路由」——**这正是组 2 把该行收窄为「仅 `subagent` 引擎派发前读」的实证依据**。
2. **降级路径的路由可用性**：降级 subagent 应用 `apply` 路由（`opencode-go/deepseek-v4.1-flash`）派发一次成功，**三档回退未触发** → 映射文件与 profile 白名单一致。
3. **机械任务的口头汇报风险**：两执行者回执均附原始命令输出，Lead 复核一致；未出现「只报结论」情形。

## 三、阶段 3 批次 2（组 2：入口改写与外部引用同步）

**批次目标**：把入口从 15971 压入宿主 pruner 阈值之内（免裁），并同步外部引用；**本批次含 Lead 起草的确定性期望成品 + md5 门**。

### 3.1 阈值与包裹开销的**精确标定**（取代先前 +360 估算）

读 dsh 实现得到确定性包裹模板（`dsh-skill` `renderSkillContent`）：

```
<skill_content name="spec-workflow">\n<skill_resources>\nBase directory for this skill: <path>\nResolve relative paths mentioned by this skill against the base directory before using them. Load referenced resources only as needed.\n</skill_resources>\n\n<skill_instructions>\n{content}\n</skill_instructions>\n</skill_content>
```

据此计算（`path` 取 symlink 解析后的宿主路径 56 字符）：

| 项 | 值 |
| --- | --- |
| 包裹码点（不含内容） | **343** |
| pruner `thresholdChars` | 8192 |
| **内容上限** | **7849**（= 8192 − 343；若 path 取容器短路径 42 字符则为 7863） |

对照 `dsh-compaction-tool-result-pruner`：超限即裁为 head 4096 + marker 39 + tail 1024 = **5159**，**与超限多少无关**——故「中间态」机制收益为零（design D6 的定量确认）。

### 3.2 Lead 起草：17 版迭代与实测（每版均 `python3 len()` 实测）

| 版本 | 手段 | 码点 |
| --- | --- | --- |
| 现状 | — | 15971 |
| v1 | 去重四项 + 骨架化 + 句式收紧 | 12538 |
| v2 | + §二/§六 细节外移 + 行级短句 | 10790 |
| v5 / v7 / v9 | 逐步链式化 + 续删非红线内容 | 9766 / 9042 / 8817 |
| v11 / v13 / v15 | 结构性合并 + 定点删除 | 8323 / 8086 / 7921 |
| **v17（定稿）** | 方向表改文字式 + 收口 | **7812** |

**关键实测结论**：措辞级压缩在 v11 后完全饱和（每版仅省 100–200）；`[6800, 7830]` 区间**可达但需追加外移**（design D1 未声明的 §二/§五/§六/§八 判据外移），故经用户批准新增任务 2.3 承接。

**定稿产物**：`/tmp/spec-flow/spec-workflow-slim-entry/expected-SKILL.md`，md5 **`613e3a9c27bfe54c20930930c559440a`**，7812 码点 → 渲染后 **8155 ≤ 8192（免裁）**；12 节标题与 frontmatter 逐字节一致；红线内联最小集 9/9 全在（恢复速查 / 绝不做 / §十二红线表 / §七六步恢复协议 / §四①–⑤ / 两条禁令 / 独立性铁律 / 参数面合并表 / 按需读取路由表）。

### 3.3 执行编排与偏差

**偏差 D-2（引擎降级，同 D-1 成因）**：团队席位仍为 8/8（第一步变更遗留 7 个 inactive 成员 + 批次 1 的 1 个），三个任务**全部降级 fresh subagent**（`apply` 路由 `opencode-go/deepseek-v4.1-flash`）并行执行：2.1 SKILL.md 替换（双 md5 门）、2.2 `dsh/README.md` 路径表 +2 条目、2.3 三个 references 追加承接段落（源取 `git show HEAD:` 改前基线，与 2.1 无依赖）。

**Lead 独立核对**（实跑，不采信回执结论）：

```
$ md5sum agent/skills/spec-workflow/SKILL.md
613e3a9c27bfe54c20930930c559440a  agent/skills/spec-workflow/SKILL.md     # = 期望成品 md5 ✓
$ python3 -c "s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read(); print(len(s), len(s)+343)"
7812 8155                                                                # 码点门 [6800,7830] ✓；渲染 8155 ≤ 8192 免裁 ✓
$ grep -c '^## ' agent/skills/spec-workflow/SKILL.md
12                                                                       # 12 节 ✓
$ git diff agent/skills/spec-workflow/SKILL.md | grep -E '^[+-](name|description):'
（无输出）                                                                # frontmatter 逐字节未变 ✓
红线内联最小集 9/9：恢复速查 / 绝不做段 / §十二红线表 / §七六步恢复协议 / §四①–⑤ / 两条禁令 / 独立性铁律 / 参数面表 / 按需读取路由表  —— 全部命中 ✓
$ grep -c '^| `agent/skills/spec-workflow/\(routing\|failure-modes\|planning\|execution\|convergence\)\.md`' dsh/README.md
5                                                                        # 路径表内 5 条 entries ✓
$ git diff --stat dsh/README.md
 dsh/README.md | 2 ++                                                    # 纯新增 2 行 ✓
```

**验证句假阳性 V-1（如实记录，卡片不改）**：tasks.md 任务 2.2 的验证句写 `grep -c 'spec-workflow/\(routing\|failure-modes\|planning\|execution\|convergence\)\.md' dsh/README.md` 期望 **5**，实测为 **6**——多出的 1 处是**表外第 198 行散文引用** `agent/skills/spec-workflow/routing.md`（HEAD 基线即存在，非本次引入）。改为限定表内行前缀（`^| \`agent/skills/...`）后精确命中 **5**，交付内容正确；属卡片验证句未限定匹配范围，非交付缺陷。

### 3.4 任务 2.3 核对（承接外移、内容无损）

```
$ 5 个 references 码点（上限 8192）
SKILL.md 7812 / convergence.md 2864 / execution.md 3058 / failure-modes.md 2169 / planning.md 4496 / routing.md 3738   —— 全部 ≤ 8192 ✓
$ 逐字 diff 复核（6 个外移片段 vs 改前基线对应行区间，Lead 独立实跑）
§二 前置检查展开 → planning.md   逐字一致 (1033 cp)
§六 落档细节   → planning.md   逐字一致 (1375 cp)
§十 接续细节   → planning.md   逐字一致  (401 cp)
§五 六步判据   → convergence.md 逐字一致 (1948 cp)
§八 三模式与硬停 → execution.md  逐字一致  (698 cp)
§九 验证归档   → execution.md   逐字一致  (701 cp)
$ 交叉验证：7 处源区间在改写后的入口中逐个检测 → 全部 False（已外移）
```

**结论**：外移内容唯一存在于三个 references，**无重复、无丢失**；2.1（删）与 2.3（承接）交接闭合。

**格式观察（保留原样，不手改）**：追加块前为 3 个换行（空 2 行），共 3 处（planning.md ×2、execution.md ×1），系追加脚本固有产物；Markdown 折叠连续空行，不影响内容与读取。

## 四、阶段 3 批次 3（组 3：结构化验证与渲染后实测）

**批次目标**：引用闭合与内容无损核对（3.1，只读）+ 渲染后实测与码点记录（3.2，只读）。

### 4.1 任务 3.2 渲染后实测（**Lead 本人执行**：`skill` 工具仅根会话可用）

**方法**：在会话内用 `skill` 工具按名加载 `spec-workflow`，直接检验宿主 pruner 行为。

**形态证据（实测返回）**：

| 检查项 | 结果 |
| --- | --- |
| 首部 | `<skill_content name="spec-workflow">` → `<skill_resources>`（含 `Base directory for this skill: /home/docker/.agents/skills/spec-workflow`）✓ |
| **裁剪标记** | **无**（未见 `[... tool result middle pruned ...]`）→ pruner **未触发** ✓ |
| 中段连续性 | §一 → §十二 顺序完整，骨架 / 红线表 / 恢复协议 / 绝不做段全部可读 ✓ |
| 尾部 | `</skill_instructions>` + `</skill_content>`，§十二「绝不做」段完整 ✓ |
| frontmatter | **被加载器剥离**（返回从 `# spec-workflow 固定工作流` 开始，剥离 198 cp）——文件码点 ≠ 渲染正文码点 |

**精确复现渲染长度**（按 `dsh-skill` `renderSkillContent` 模板 + 实测 path）：

| 项 | 码点 |
| --- | --- |
| 入口文件全文 | 7812 |
| 渲染正文（剥离 frontmatter 198 cp） | 7614 |
| 包裹（path 取实测容器短路径，42 字符） | 343 |
| **渲染后总量** | **7957 ≤ 8192** ✓（**余量 235**） |
| 保守情形（path 取宿主路径 56 字符） | 7971（余量 221） |

**结论**：入口在 `skill` 按名加载路径下**不再触发宿主裁剪**——本变更的核心机制目标达成；余量 ~235 码点可吸收 path 差异与未来小幅增补。

**6 个码点数字（供后续变更作为基线）**：

| 文件 | 码点 | 上限判定 |
| --- | --- | --- |
| `SKILL.md`（入口） | 7812 | 渲染 7957 ≤ 8192 ✓ |
| `planning.md` | 4496 | ≤8192 ✓ |
| `routing.md` | 3738 | ≤8192 ✓ |
| `execution.md` | 3058 | ≤8192 ✓ |
| `convergence.md` | 2864 | ≤8192 ✓ |
| `failure-modes.md` | 2169 | ≤8192 ✓ |

### 4.2 任务 3.1 引用闭合与内容无损核对

**Lead 侧独立核对（与 3.1 执行者构成双证据源）**：

```
① 引用闭合：从 SKILL.md + 5 个 references 抽出全部 `](xxx.md)` 链接并去重 → convergence.md / execution.md / failure-modes.md / planning.md / routing.md 逐一 test -f → 全部 OK
② 关键词唯一归属：
   matchAll        → SKILL.md 0 | routing.md 1（自检脚本唯一归属 ✓）
   spawn_teammate  → execution.md 1 | 其余 0（team 引擎细节已外移 ✓）
   设计树          → SKILL.md 4 | convergence.md 7 | planning.md 1（见下方说明）
③ 旧节号：Lead 侧首轮 grep 用 `第十[一二三四五六七八九]节` **漏掉「第十节」→ 假阴性**（自我纠错，见裁定 R-2）；改用族正则复核得 4 处命中，均为**指向入口内活节**的交叉引用；`第十一节` 全域 0 ✓
④ 结构不变（对照基线 9048fcf^）：12 节标题逐字节一致 ✓；frontmatter 逐字节一致 ✓
```

**说明 K-1（关键词归属的语义澄清，非缺陷）**：`设计树` 在入口出现 4 次、`convergence.md` 7 次、`planning.md` 1 次。入口的 4 次是**红线要点**（§五 步骤链「设计树**只问前沿**」、§四 中转协议「并入阶段 1.5 设计树统一提问」），属 D3 要求内联的最小集；方法**展开**（映射为设计树 / 只问前沿 / 承重 / 轮次 / 答复回送 / 不因此改变的部分）唯一在 `convergence.md`；`planning.md` 的 1 次来自第一步已有的 §四 派发模板原文。故「设计树方法唯一归属 convergence.md」在**展开语义**上成立，在**字面关键词**上不成立——记录实际分布，不做「已唯一」的过度声明。

**3.1 执行者回执（已合并）**：8 项断言 7 通过、1 项字面不通过；另 1 项界定差异。两项均经 Lead 裁定为**措辞造成的假阳性，产物正确不需改动**：

**裁定 R-2（断言 6「`第十X节` 零残留」字面不通过，4 处命中）**：

| 位置 | 原文片段 | 判定 |
| --- | --- | --- |
| `SKILL.md:30` | `接续未完成变更（第十节）` | 指向**入口内活节** §十 ✓ |
| `SKILL.md:44` | `处置表主体（红线见第十二节）` | 指向**入口内活节** §十二（红线表仍在入口）✓ |
| `SKILL.md:102` | `（第六节第 7 步；接续场景见第十节需重选）` | 指向入口内活节 §六 / §十 ✓ |
| `dsh/README.md:129` | `红线级条目留在 SKILL.md 第十二节` | 描述正确（红线确实留在入口 §十二）✓ |

定性：`第十一节` 全域 **0 命中**（第一步外移后已改 `[routing.md](routing.md)` 链接）；`第十节` 基线 3 → 改后 2、`第十二节` 基线 1 → 改后 1，**无新增旧提法**；入口 12 个 `^## ` 标题含「十」「十二」，4 处命中**均指向仍存在的节**，无悬空引用。**裁定：不改产物**——任务断言「无命中」过严，未区分「指向已外移内容的旧引用」与「指向入口内活节的同文件交叉引用」，与 V-1 同类的措辞假阳性。

**裁定 R-3（断言 3 §二 对字面 diff 有 1 行空行差异）**：`planning.md:40` 为空行——因 §二 的待外移区间**不连续**（59–62 与 65–66，中间 63–64「确认参数 / 工作目录事实」仍留入口），并入一处必须以空行分隔以免两段粘连。拆分核验（`59-62 ↔ planning.md 36-39`、`65-66 ↔ 41-42`）**均逐字无差异**。**裁定：接受**。

**3.1 其余通过项（执行者证据，与 Lead 侧独立核对一致）**：单文件码点 6/6 ≤8192；引用闭合 5/5（README 路径表 5 项亦 5/5）；无重复（7 源区间 71 行整行命中 0）；关键词唯一（`matchAll` 仅 routing.md、`spawn_teammate` 仅 execution.md）；结构 12 节 + frontmatter 逐字节一致（两侧 md5 `df7ac212aa8c1aa21f47749e9f902fc4`）；红线内联最小集 9/9（命中行号 :46 / :154 / :146 / :104+106-111 / :76-80 / :82 / :64 / :27 / :36+38）。只读合规：核对对象审计前后 md5 全部稳定。

### 4.3 自举行为观察（tasks.md「Workflow follow-up」收口）

1. **收窄后的路由表在批次 2/3 生效**：新入口的路由表行写「**仅 `subagent` 引擎**派发前读 [routing.md](routing.md)」，并删除了旧措辞「派发任一子代理 / 团队成员前」。批次 2/3 全部为**降级 subagent 派发**（`apply` 路由 `opencode-go/deepseek-v4.1-flash`），Lead 未重复读取 `routing.md`——批次 1 已读且同一会话内该文件未变、路由已确认在白名单内。**行为与收窄后的规则一致**（旧措辞下 team 引擎派发前也要读，实际无收益；新措辞消除了这一空读）。
2. **改写任务对外移文件的引用**：批次 2 的任务 2.3 明确以 `planning.md` / `convergence.md` / `execution.md` 为写入目标并从改前基线取源；任务 2.1 以 `expected-SKILL.md` + md5 门执行。三个 references 在派发前均由 Lead 实读确认（`planning.md` / `failure-modes.md` / `routing.md`），`convergence.md` / `execution.md` 为组 1 新建、内容为 Lead 指定。
3. **降级路径的稳定性**：本变更三个阶段共 6 个执行任务，因团队席位 8/8 占满，**全部走降级 fresh subagent**（偏差 D-1/D-2 已记录）；`apply` 路由派发 6 次全部一次成功，**三档回退未触发**，说明「成员创建失败 → 降级 subagent」这条回退在真实场景下可用（这条纪律本身写在入口 §八 与 `execution.md`）。

## 五、阶段 4（验证与归档）

（待记录）
