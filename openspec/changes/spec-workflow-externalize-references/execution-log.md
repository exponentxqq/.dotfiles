# 执行记录（阶段 3/4）

> 本文件是本变更的**执行证据与自举行为观察**记录，不属四件套工件；供第二步变更（去重改写、压 ≤8192 码点）作决策输入。

## 一、码点基线

| 文件 | 外移前 | 外移后（批次 1 完成时） | 变化 |
| --- | --- | --- | --- |
| `agent/skills/spec-workflow/SKILL.md` | 21464 | 21464（批次 2 瘦身后记录） | — |
| `agent/skills/spec-workflow/routing.md` | — | **3738** | 新建 |
| `agent/skills/spec-workflow/failure-modes.md` | — | **2169** | 新建 |
| `agent/skills/spec-workflow/planning.md` | — | **1590** | 新建 |

测量方式：`python3 -c "print(len(open(p,encoding='utf-8').read()))"`（Unicode 码点；**不用 `wc -m`**，C locale 下退化为字节）。

## 二、批次 1：生成外移 references 文件

- 引擎/模式：`team` + `step-group`；组内 3 任务（task-1/2/3）并行，3 名成员 `impl-routing` / `impl-failure-modes` / `impl-planning` 各认领 1 条。
- 生成方式：**纯剪切**——成员用 shell `sed -n` 提取源行区间写目标文件，零手工复述；Lead 侧独立用 `diff` 复核正文与源行**逐字一致**（三个文件均 exit=0）。
- 外移边界（行号，源 SKILL.md 363 行版）：
  - `routing.md` ← 277–340（§十一全文）
  - `planning.md` ← 120–147（§四 并行/串行/回执核对）
  - `failure-modes.md` ← 342、344–345、347–357、359、361（§十二处置表**去红线行**）
  - 留入口：346（绝不副作用创建 `openspec/`）、358（`DELEGATED_CALLER` 是平台设计）、360（auto 硬停）、363（**绝不做**段落）、§四 其余（方向表/7 字段/独立性铁律/中转协议）
- 验证结论：tasks.md 1.1/1.2/1.3 的验证句逐条实跑通过（非空断言、关键词计数、逐字 diff、红线零命中）；`git diff -- agent/skills/spec-workflow/SKILL.md` 为空（批次 1 未动入口）。

### 自举行为观察（第一步核心目标，D4.6）

| 时点 | 观察 | 结论 |
| --- | --- | --- |
| 批次 1 派发前 | `routing.md` 本批次才生成，**尚不存在** | 该时点无 references 可读，「派发前读 routing.md」不适用；Lead 依据入口 SKILL.md §十一 正文派发（该正文本批次仍在入口，未压缩场景可读） |
| 批次 1 执行中 | 无异常情形；`failure-modes.md` 尚不存在 | 「异常时读 failure-modes.md」本批次不适用 |
| 批次 2 派发前 | 待记录（references 已存在，是本变更的**真实测点**） | — |
| 批次 3 执行中 | 待记录 | — |

## 三、批次 2、3（待记录）

## 四、阶段 4（待记录）
