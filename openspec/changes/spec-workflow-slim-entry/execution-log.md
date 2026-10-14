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

（待记录）

## 四、阶段 3 批次 3（组 3：结构化验证与渲染后实测）

（待记录）

## 五、阶段 4（验证与归档）

（待记录）
