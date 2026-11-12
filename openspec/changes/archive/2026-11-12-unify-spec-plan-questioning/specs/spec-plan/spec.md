# Spec Delta

## ADDED Requirements

### Requirement: 追问交互契约

spec-plan SHALL 把向用户发起的全部追问（含前置检查、参数与模式收集、中转代问、收敛决策、栈识别、界面演示确认、落档分歧及纠错/异常处置）一律经宿主结构化提问工具（DSH 为 `ask_user_question`）承载，SHALL NOT 以裸文本提问；每问 SHALL 附背景说明与详细解释，表述清晰易懂、不含糊；存在多个方案或选项时 SHALL 列出各选项的详细区别，涉代码、配置或结构时 SHALL 举例。子代理/成员 SHALL NOT 直接提问，仍按中转协议上浮。`grill-me` 轮次的承载与问题质量 SHALL 遵循 `grill-me` capability。

#### Scenario: 全部追问经工具发起

- **WHEN** 任一阶段需向用户提问（参数、模式、收敛、栈识别、演示确认、落档分歧或纠错/异常）
- **THEN** 主会话以 `ask_user_question` 发起，不以裸文本提问

#### Scenario: 每问附背景与详细解释

- **WHEN** 发起任一追问
- **THEN** 问题正文含背景（为什么问、答复影响什么）与详细解释，清晰易懂

#### Scenario: 多选项列详细区别并举例

- **WHEN** 追问涉及多个方案/选项，或涉及代码、配置、结构
- **THEN** 各选项附详细区别；涉代码/配置/结构时附具体例子

#### Scenario: 纠错与异常通道同样适用

- **WHEN** 参数语法错误需更正，或异常处置需用户裁决
- **THEN** 同样经工具发起，不以裸文本要求重发或裁决

#### Scenario: 子代理不直接提问

- **WHEN** 被拥有的子代理或团队成员需用户拍板
- **THEN** 不调用提问工具（`DELEGATED_CALLER`），按中转协议上浮，由主会话代问

#### Scenario: grill-me 轮次经工具承载

- **WHEN** 阶段 1.5 按 grill-me 分轮提问
- **THEN** 每轮经工具承载；问题含背景与解释、选项含区别、推荐项置首（细则见 grill-me capability）

#### Scenario: 既有问法语义不变

- **WHEN** 追问改经工具承载
- **THEN** 1.75 三选项语义（确认/要改/降档或豁免）、grill-me ≤5 问/轮与只问前沿、未修改 Requirement 的行为语义均不变
