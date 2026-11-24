# Proposal

## Why

执行期 `/compact` 会让 spec-apply 的模型路由静默失效：子代理不再按映射文件 `apply` 路由派发，而是继承主会话模型。benchmark T7.3 实测（会话 `session-8330ed6c-…`）：47 次 `subagent` 派发中 **30 次丢失 `provider`/`model`**，自压缩 #2 后的首个派发 `apply-6-2` 起连续缺失；子会话 `request/header` 实证实际跑在 `zcode-plan/glm-5.3`（主会话模型），而非映射的 `opencode-go/deepseek-v4.1-flash`。

根因不是「模型忘了」，而是**路由从未有持久载体**：

- DSH 的 `subagent` 省略路由 = 继承父会话；白名单只校验显式路由，继承路径无告警——静默失效是平台语义。
- 派发模板只示形 `name/description/prompt` 三字段，路由另在 refs 抽象描述；compact 摘要按示形收敛，压缩后下一轮又可能由子代理消息触发（无用户命令、无 skill 重载）。
- 反压缩唯一台账（登记簿）只记任务/写范围/agent/状态，**没有路由**；派发时无强制填写点，子代理也不校验自身模型。压缩 #2 的摘要其实已含正确路由一行，仍发生漂移——证明「摘要里写一句」不足以约束派发。

## What Changes

- **spec-apply**：新增「路由快照」`/tmp/spec-flow/<change>/routing.md`（阶段开工解析并落盘，来源 `--model` > 映射文件 > 继承）；登记簿升 **v4**（行新增 `route=` 审计字段、`reason` 支持 `ROUTE-DRIFT`）；派发必传 `provider`/`model`；协调协议注入段新增**子代理自证**（读快照本键路由比对系统提示模型名，失配停手 + 上行 + `ROUTE-MISMATCH`，快照缺失 `ROUTE-LEGACY` 不阻断）；组收尾核对回执 `ROUTE-ACK`；漂移留痕、不重跑已验证合格任务。
- **spec-workflow**：衔接的进度笔记逐字记录 `--model` 执行侧覆盖；恢复协议（任何时刻生效）先读路由快照、缺失则重建，重建前不派发；衔接提示建议批次边界压缩；恢复摘要含执行侧路由。
- **spec-done**：`verify-<n>` 验证子代理显式传 `verify` 路由 + 自证；自证失配不归档；快照缺失按映射文件解析并写回。
- **spec-plan**：规划派发（A/B/复算/设计）显式传路由，提示首行含路由键；子代理自证、缺路由行时按提示键读映射文件；压缩后重进重读映射文件，不凭记忆。规划期不新增持久台账（余量不足 + 无 necessity）。
- **仓文档**：`dsh/README.md`「阶段模型路由」补「压缩后的路由持久性」段与「省略路由不走白名单校验」的事实习；零模型值、零 profile 改动。
- 触达 12 个 markdown 文件 + 本变更工件；**零应用代码、零映射文件值改动、零白名单改动**。

## Capabilities

### New Capabilities

（无——本次不引入新 capability。）

### Modified Capabilities

- `spec-apply`: 执行期路由快照、登记簿 v4、派发必传路由、子代理自证与漂移处置。需要 delta 文件 `specs/spec-apply/spec.md`。
- `spec-workflow`: 执行侧路由覆盖的交接记录、压缩后恢复读快照与重建门。需要 delta 文件 `specs/spec-workflow/spec.md`。
- `spec-done`: 终末验证路由显式化与自证。需要 delta 文件 `specs/spec-done/spec.md`。
- `spec-plan`: 规划派发路由显式化与压缩后重读。需要 delta 文件 `specs/spec-plan/spec.md`。

## Impact

- **规范与技能文本**：4 个 skill 的 11 个 markdown 文件 + `dsh/README.md`；`openspec/specs` 仅在归档时同步。
- **运行期状态**：新增 `/tmp/spec-flow/<change>/routing.md`（易失、不入库、随登记簿同域清理）；登记簿 v3→v4（v3 仍可读，legacy 路径不阻断在途变更）。
- **平台/配置**：`dsh/spec-workflow.yaml` 与 `dsh/profiles/web/cordis.patch.yml` 零改动；不新增插件、不改 DSH 平台层。
- **兼容**：登记簿 v3、无快照的旧流程降级为 `ROUTE-LEGACY`；在途变更（如 benchmark T7.3）不被新规则中断。
