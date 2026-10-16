# Proposal

## Why

`spec-plan` 自拆分独立以来经实战暴露四处结构性问题：

1. **并行双线的编排载体落后于执行侧**：`--parallel` 仍是「同一条消息派两个 fresh 子代理」——子代理一次性、回执即弃，规划线上浮待决项后答复只能「接续重派」（上下文重建、非同一实例），多轮澄清成本高；而 spec-workflow 执行侧已有成熟 team 引擎先例（具名成员 + `send_message` 同实例回送多轮澄清）。
2. **串行模式的方法论错位**：串行为「主会话先后独立做两遍双线」——「独立性弱于并行」是已知注记，且需求小时双线成本不必要；实际需要的轻量路径是「单线探索 + 收敛提问」，`openspec-explore` + `grill-me` 组合恰好提供该方法论。
3. **交叉比对的固有盲区与提问浪费**：双线比对只能发现单边遗漏、发现不了双边遗漏；「先问后查」浪费提问额度。差异收敛后在 grill-me 提问前插入一段 openspec-explore 审视，可补双边盲区并把可查证待决项降级为事实裁定。
4. **规划材料滞留 /tmp 易失**：`code-design.md`、`diff-matrix.md` 由 spec-plan 产出却不随落档入库，执行期组段终形态化与接续恢复在会话重启后无从读取，与「权威进度 = 工件 + 勾选态 + 提交历史」的三方对齐原则矛盾。

## What Changes

- **并行编排 team 驱动（默认）**：`spawn_teammate` 派两个具名 fresh 成员（`spec-plan-<change>-line-a|b`），待决答复以 `send_message` 回同一成员多轮澄清；不可行时（Agent Teams 未挂载 / 成员创建失败 / 达 8 上限 / 卡死重建一次仍失败 / 该线显式 `--model` 覆盖）**按线回退 subagent** 并留痕，两线引擎可混合。team 编排下 `lineA`/`lineB` 路由不适用（成员无模型参数），显式覆盖该两键的线以 subagent 派发兑现路由。
- **串行编排改单线**：主会话加载 `openspec-explore` 探索并产出单份 7 字段草案（`explore.md` + 待决问题节），再以 `grill-me` 设计树/前沿分轮收敛（`decisions.md` 留痕）；**不再 A/B 双线**，「串行独立性弱于并行」注记随双线语义一并移除。
- **并行 1.5 收敛六步改七步**：交叉比对/自行裁定/分歧复算之后、grill-me 提问之前插入 **openspec-explore 审视段**（主会话以探索姿态审合并视图——补双边盲区、把可查证待决项降级为事实裁定；不重开双线调研、不推翻已收敛共识），再问决策项。
- **目录重组**：新增 `mode/` 目录（`parallel.md` 并行手册、`serial.md` 串行手册，按编排互斥读取）；`refs/` 只留跨编排公共参考（planning / convergence / routing / failure-modes）。
- **落档材料扩充**：阶段 2 落档时把 `code-design.md` 与 `diff-matrix.md`（串行对应物 `decisions.md`）复制入 `openspec/changes/<change>/` 随工件提交；**落档副本为权威**，执行期组段终形态化与 R<n> 留痕写落档副本，`explore.md`/`line-a.md`/`line-b.md` 仍 /tmp 易失。
- **spec-workflow 最小交叉一致性改动**：SKILL.md 工件跨界所有权句与 execution.md 组段终形态化/留痕的维护目标改为落档副本（其主规范本就称 `code-design.md` 为变更工件，无 spec delta）。
- **不做（本期）**：spec-workflow 执行引擎语义改动；`dsh/spec-workflow.yaml` 键值改动（`--model lineA|lineB` 显式覆盖即隐式回退 subagent 的开关）；panel/design 键与阶段 1.7 恒派 fresh 子代理语义不变。

## Capabilities

### Modified Capabilities

- `spec-plan`：**REMOVED**×1（阶段 1 独立双线规划——被并行/串行两条编排 Requirement 取代）；**ADDED**×2（阶段 1 并行双线规划（team 驱动）、阶段 1 串行单线探索）；**MODIFIED**×4（双线差异收敛与分歧复算——七步+限定并行；落档工件与执行批次契约——两材料落档与落档副本权威；子代理与用户的交互中转（规划期）——适用范围收窄；阶段级模型路由（规划键）——编排适用性矩阵）。其余 Requirement（入口、压缩存活、单次加载、栈识别与 writer skill、读图覆盖与路由回退）行为语义不变；mode 目录重组不改变行为语义。

## Impact

- 代码/文档：`agent/skills/spec-plan/`（SKILL.md 改写、`mode/` 新建 2 文件、refs 4 文件改写、planning.md 瘦身）、`agent/skills/spec-workflow/`（SKILL.md 一句、execution.md 两条注记）、`openspec/specs/spec-plan/spec.md`（归档时经 delta 同步，不手改）。
- 不影响：spec-workflow 主规范与执行引擎语义、`dsh/spec-workflow.yaml`、`dsh/commands/spec-plan.md`、openspec-* skills、web profile。
- 宿主操作：无（skill 路径不变，聚合层实时 bind mount 即时生效）。
- 风险：spec-plan 入口码点超预算（文件 ≤7849，渲染 ≤8192）→ 编排细节全部下放 `mode/`，入口只保骨架 + 铁律 + 红线 + 指针；`mode/`、refs 各文件 ≤8192 码点；openspec validate 对变更目录附加材料（code-design.md 等）报错 → 落档后即验，验证句覆盖；team 派发在 Agent Teams 未挂载会话不可用 → 按线回退 subagent 并留痕，不判工具故障。
