# grill-me Specification

## Purpose
追问访谈能力的轮次承载：在提供结构化提问工具的宿主上把每轮追问经工具承载（每题含背景、解释、选项区别与置首推荐），无此工具的宿主保持 ❓Q/➡️ markdown 轮格式；设计树、前沿、每轮 3–5 问、推荐措辞与答完重算等方法论两轨共用。

## Requirements

### Requirement: 轮次承载（宿主自适应）

grill-me SHALL 按宿主能力选择轮次承载：宿主提供结构化提问工具（DSH 为 `ask_user_question`）时，每一轮 SHALL 为一次工具调用、前沿中每题一个条目；条目的 question 文本 SHALL 含问题标题、背景（为何现在问、答复改变什么）与解释，每个 option SHALL 附与其他选项的区别说明，推荐项 SHALL 置首并标注推荐；宿主无该工具时 SHALL 保持 ❓Q/➡️ markdown 轮格式。设计树、前沿、每轮 3–5 问、推荐措辞与答完重算 SHALL 为两轨共用的方法论。

#### Scenario: 有工具宿主一轮一次调用

- **WHEN** 宿主提供结构化提问工具
- **THEN** 每轮为一次工具调用，前沿每题一个条目

#### Scenario: 无工具宿主保持 markdown 轮格式

- **WHEN** 宿主无结构化提问工具
- **THEN** 保持 ❓Q/➡️ markdown 轮格式不变

#### Scenario: 两轨方法共用

- **WHEN** 任一承载轨
- **THEN** 设计树、前沿、每轮 3–5 问、推荐措辞、答完重算一致

### Requirement: 每问的背景、区别与推荐

grill-me 的每个追问 SHALL 附背景说明与详细解释，表述清晰易懂；存在多个方案或选项时 SHALL 列出各选项的详细区别，涉代码、配置或结构时 SHALL 举例；每题 SHALL 给出推荐答案，措辞 SHALL 使「是/同意」等于接受该推荐，工具承载时推荐项 SHALL 置首标注。

#### Scenario: 每问附推荐且「是」等于接受推荐

- **WHEN** grill-me 提问
- **THEN** 每题给出推荐答案，措辞使「是/同意」= 接受推荐

#### Scenario: 多选项列区别并举例

- **WHEN** 问题含多个方案或涉代码/配置/结构
- **THEN** 各选项附区别说明；涉代码/配置/结构时举例

#### Scenario: 每问附背景与解释

- **WHEN** 发起任一追问
- **THEN** 问题正文含背景与详细解释，清晰易懂

#### Scenario: 工具轨推荐置首

- **WHEN** 轮次经结构化提问工具承载
- **THEN** 推荐项置首并标注推荐
