# Spec Delta

## ADDED Requirements

### Requirement: 路由覆盖的交接与压缩恢复

编排层 SHALL 在衔接的进度笔记中逐字记录执行侧 `--model` 覆盖（`apply`、`verify`；无则写「未预置」）与引擎/模式，SHALL NOT 在编排层解析或改写映射文件的模型值。恢复协议（任何时刻生效：新轮次、`/compact` 之后、会话重启、用户说「继续」）SHALL 读取 `/tmp/spec-flow/<change>/routing.md` 路由快照；快照缺失 SHALL 由当前半程按映射文件 + 笔记覆盖解析并写回，重建完成前 SHALL NOT 派发执行或验证子代理。衔接提示 SHALL 建议在批次边界压缩，并说明压缩后按恢复协议继续（含路由重建）。恢复后的进度摘要 SHALL 含执行侧路由（`apply`/`verify`）。编排层 SHALL NOT 修改主会话模型。

#### Scenario: 衔接记录执行侧覆盖

- **WHEN** 用户以 `--model apply=…`（或 `verify=…`）进入衔接
- **THEN** 进度笔记逐字记录覆盖值，spec-apply/spec-done 据此解析并写快照

#### Scenario: 压缩上下文后继续不漂移

- **WHEN** 执行期 `/compact` 后用户说「继续」或由子代理消息触发续轮
- **THEN** 恢复协议先读路由快照，重建后派发显式带 `provider`/`model`，不继承主会话模型

#### Scenario: 快照缺失先重建再派发

- **WHEN** `routing.md` 缺失或与当前阶段不匹配
- **THEN** 按映射文件 + 笔记覆盖重建并写回；重建完成前不派发子代理

#### Scenario: 覆盖不可辨时如实报告

- **WHEN** 笔记无覆盖且上下文中已无法确定 `--model` 值
- **THEN** 按映射文件执行并在当批/呈证报告，不静默猜测
