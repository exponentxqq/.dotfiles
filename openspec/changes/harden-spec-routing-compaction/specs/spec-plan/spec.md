# Spec Delta

## ADDED Requirements

### Requirement: 规划派发的路由显式化与压缩恢复

规划半程派发任何 fresh 子代理（A/B 线、复算线、设计线）SHALL 显式传 `provider`/`model`（`--model` 覆盖 > 映射文件 `models`），提示 SHALL 含路由键（`lineA`/`lineB`/`panel`/`design`）与路由行；规划期 SHALL NOT 因无派发台账而省略路由。子代理 SHALL 比对系统提示声明的模型名与路由行：不一致 SHALL 停手并上行；提示缺路由行时子代理 SHALL 按提示中的路由键读取映射文件该键路由并报告（`--model` 覆盖不可辨由主会话裁定）。压缩后重进规划 SHALL 重读映射文件再派发，SHALL NOT 凭会话记忆。

#### Scenario: 规划派发显式路由

- **WHEN** 派发 `plan-a`/`plan-b`/复算线/设计线
- **THEN** 调用参数显式携带 `provider`/`model`，提示首行给出路由键与路由值

#### Scenario: 压缩后重读映射再派发

- **WHEN** 规划期压缩上下文后继续
- **THEN** 先重读映射文件与 `--model` 覆盖，再按键派发，不继承主会话模型

#### Scenario: 提示缺路由行时子代理按 yaml 兜底

- **WHEN** 规划子代理提示中未含路由行
- **THEN** 子代理按提示中的路由键读取映射文件对应路由，比对自身模型并报告，不静默执行
