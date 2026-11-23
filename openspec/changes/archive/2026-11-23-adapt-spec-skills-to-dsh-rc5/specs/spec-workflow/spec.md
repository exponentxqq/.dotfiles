# Spec Delta

## MODIFIED Requirements

### Requirement: 子代理与用户的交互中转（执行期）

被父代理拥有的子代理 SHALL NOT 直接向用户提问（提问会被以 `DELEGATED_CALLER` 拒绝），工作流 SHALL 提供中转式交互：执行任务的子代理 SHALL 把需拍板的决策（问题、选项、推荐、影响面）写入产物并在回执中上浮，SHALL NOT 自行假设；上浮通道 SHALL 含回执与上行消息两条（`send_message(agent="lead")` 直报主会话）；主会话 SHALL 当批次即时代问（≤5 问/轮、附推荐），SHALL NOT 为等答复阻塞或轮询；回送 SHALL **同实例续话优先**（`send_message` 回同一具名子代理），仅在目标不可寻址时才以上轮回执摘要 + 答复重派一次；用户授权「按假设清单推进」时 SHALL 跳过代问并标注。

#### Scenario: 执行子代理上浮待决问题

- **WHEN** 执行子代理遇到需用户拍板的决策
- **THEN** 它不自行假设，写入产物与回执上浮；主会话当批次即时代问

#### Scenario: subagent 引擎接续重派

- **WHEN** 目标子代理已不可寻址（会话已亡或冷恢复被拒）
- **THEN** 把上轮回执摘要与答复并入新提示重派一次，并留痕重派原因

#### Scenario: team 引擎同实例多轮澄清

- **WHEN** team 引擎下某成员上浮待决策问题
- **THEN** Lead 代问后以消息回送该成员，成员在原上下文中继续，可多轮往返

#### Scenario: 授权假设清单推进

- **WHEN** 用户明确授权「按假设清单推进」
- **THEN** 跳过代问，产物与回执标注「已授权的假设清单」

#### Scenario: 同实例续话优先

- **WHEN** 用户答复执行子代理上浮的问题
- **THEN** 主会话以 `send_message` 回送同一具名子代理，其在原上下文中继续
