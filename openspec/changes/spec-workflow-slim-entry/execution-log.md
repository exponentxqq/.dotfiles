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

（待记录）

## 五、阶段 4（验证与归档）

（待记录）
