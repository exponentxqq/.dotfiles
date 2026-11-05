# Spec Delta

## MODIFIED Requirements

### Requirement: 固定工作流入口

系统 SHALL 提供全局 skill `spec-workflow` 与命令 `/spec-flow` 作为统一编排入口;命令 SHALL 接受需求描述、接续名、并行开关、模式、引擎与模型覆盖。编排 SHALL 四段委托:规划阶段(1→2)委托 skill `spec-plan` 完成至落档提交;执行半程(衔接完成后)委托 skill `spec-apply`;终末半程(验证归档与收尾闭环)由 skill `spec-done` 承载;本 skill 保留全流程编排、衔接与恢复路由。需求描述、并行开关与规划键模型覆盖 SHALL 原样转发,已预置项不重问,未给选项 SHALL 在对应阶段开始前询问,SHALL NOT 自行假设。规划半程 SHALL 含阶段 1.75 界面演示 gate(条件触发,判定与产物规范以 skill `ui-demo` 为唯一权威源);界面演示产物 `demos/` 随落档提交入变更目录,执行期只读、不参与组段终形态化。

#### Scenario: 以需求描述新建流程

- **WHEN** 用户调用 `/spec-flow 给登录页加验证码`
- **THEN** 以该需求启动,先由 spec-plan 完成规划至落档提交,在需要时询问未给出的选项

#### Scenario: 未预置执行模式

- **WHEN** 调用命令时未携带执行模式参数
- **THEN** 流程在落档完成后的衔接点询问执行模式,而不是自行选择

#### Scenario: 规划参数转发

- **WHEN** 调用携带 `--parallel` 与规划键 `--model`
- **THEN** 参数原样转发给 spec-plan,规划按预置编排与路由执行,不重问

#### Scenario: 阶段 1.75 条件触发

- **WHEN** 规划半程的需求涉及界面设计且无设计依据
- **THEN** spec-plan 在阶段 1.7 后、落档前执行界面演示 gate,演示产物随落档复制入变更目录 demos/;未命中时落档不含 demos/ 且草案留未触发事实
