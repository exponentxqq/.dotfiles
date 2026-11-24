# Spec Delta

## ADDED Requirements

### Requirement: 终末验证的路由显式化

终末半程派发 `verify-<n>` 验证子代理时 SHALL 显式传 `provider`/`model`（优先取路由快照 `verify` 行，缺失时取映射文件 `verify` 键），提示 SHALL 含路由键 `verify` 与快照路径；快照缺失 SHALL 先按映射文件解析并写回再派发。验证子代理 SHALL 按同一自证规则比对系统提示模型名与 `verify` 路由：一致以 `ROUTE-ACK` 自证，不一致 SHALL 停手报告，且 SHALL NOT 以该次验证结果归档。`verify` 覆盖不可辨 SHALL 报告并按映射文件执行。

#### Scenario: 验证子代理显式路由

- **WHEN** 归档链或收尾复验派发 `verify-<n>`
- **THEN** 派发参数显式携带 `provider`/`model`，提示含 `路由键 verify` 与快照路径

#### Scenario: 自证失配不归档

- **WHEN** 验证子代理系统提示模型名与 `verify` 路由不一致
- **THEN** 子代理停手报告，主会话不据此验证结果归档，先修正路由后重派

#### Scenario: 直接进入终末且快照缺失

- **WHEN** 用户直接 `/spec-done` 且路由快照不存在
- **THEN** 按映射文件 + 登记簿笔记解析 `verify` 路由并写回快照后再派发
