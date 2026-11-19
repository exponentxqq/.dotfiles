# decisions：add-subagent-control-and-coordination

> 串行收敛留痕（阶段 1.5，grill-me 前沿分轮）｜输入：explore.md 待决节 + 探索中新产生待决项

## 设计树

```
需求：spec-apply subagent 控制与协调增强
├── Q1 范围：spec-plan 是否同改？ ──→ a 本次一并改（仅上行两类事件）
│   └── Q6 spec-plan 侧协议口径？（被 Q1 解锁）──→ a 仅待决+异常，无租约/前奏
│   └── Q7 上行早收到的提问节奏？（被 Q1 解锁）──→ a 维持两侧既有节奏
├── Q2 停止口径 ──→ b 软废止 + 派发前引擎升级判据提示
├── Q3 协调载体 ──→ a 扩展 progress.md 为单一登记簿
├── Q4 上行触发（执行侧）──→ b 事件驱动 + 完成前奏必报
└── Q5 提示篇幅预算 ──→ b ≤15 行
```

## 第一轮（5 问）

| # | 问题 | 答复 | 仍待决 |
| --- | --- | --- | --- |
| Q1 | spec-plan 规划子代理中转协议是否同步接入上行通道 | **a 本次一并改**（偏离推荐 b——用户选择两 skill 协议一致，接受触达面扩大） | 否（解锁 Q6/Q7） |
| Q2 | 「停止 subagent」满足口径 | b 软废止 + 前置判据提示（推荐） | 否 |
| Q3 | 协调载体文件形态 | a 扩展 progress.md 单源（推荐） | 否 |
| Q4 | 上行消息触发时机（执行侧） | b 事件驱动 + 完成前奏必报（推荐） | 否 |
| Q5 | 协议注入提示的篇幅预算 | b ≤15 行（推荐） | 否 |

## 第二轮（2 问，Q1=a 解锁）

| # | 问题 | 答复 | 仍待决 |
| --- | --- | --- | --- |
| Q6 | spec-plan 侧上行口径 | a 仅待决+异常两类事件，无租约/无完成前奏（推荐；规划线独立性铁律已防写冲突） | 否 |
| Q7 | 上行早收到的提问节奏 | a 维持既有节奏：规划期并入 1.5 统一收敛、执行期当批次即时代问（推荐；防碎片化） | 否 |

## 裁定依据与结论

- **平台事实基础**（2026-11-19 双探针实证，dsh 0.2.2-rc.1 / web profile）：lead→subagent 下行 ✗（team 版 send_message 报 `active teammate not found`，subagent-control 版被 agent-team-profile 禁用且重名互斥不可共存）；subagent→lead 上行 ✓（subagent 面有 subagent-control 版 send_message，父 session id 在其 runtime context 可得，`"lead"` 名不可寻址）；sibling 互达 ✗；硬中断 ✗（interrupt_agent 仅 teammate，job_list 不含 subagent——探针 2 运行中实测为空）。
- **方案定型**：上行 + 文件混合（方案 B）——progress.md 升级为登记簿（状态机 active→done|void|stalled）承担租约/冲突发现；上行消息承担待决早上浮/异常求援/完成前奏；软废止令走检查点读令（尽力而为）；硬控制需求经派发前判据提示升级 team 引擎。
- **范围定型**：spec-apply 完整协议（租约+检查点+上行+前奏+判据）；spec-plan 仅上行两类事件（待决+异常），提问节奏两侧维持既有。
- **未决项**：无。设计层细节（软废止检查点定义、上行消息格式、协议段权威源归属——倾向 spec-apply refs 权威 + spec-plan 指路，循 worktree.md 跨引用先例）留阶段 1.7 设计契约，不构成需求决策。

## 收敛结论

前沿为空，全部待决项已由用户拍板，无静默假设。可以进入阶段 1.7 代码设计。
