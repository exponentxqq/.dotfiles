# Spec Delta

## ADDED Requirements

### Requirement: 入口与资源按单次加载完整交付

工作流 skill 的入口指令 SHALL 在单次按名加载内完整交付，其每个外置资源文件 SHALL 在单次读取内完整交付——交付结果 SHALL NOT 因宿主工具结果的裁剪阈值而丢失指令内容。入口总量与每个资源文件各自 SHALL 控制在该阈值内；骨架化与外移 SHALL NOT 改变既有 Requirement 约束的行为语义与触发条件。

#### Scenario: 单次加载得到完整入口
- **WHEN** 会话按名加载工作流 skill（宿主 `skill` 工具返回入口正文）
- **THEN** 返回内容完整包含红线最小集与按需读取路由指引，没有任何指令内容被宿主裁剪

#### Scenario: 资源文件独立完整交付
- **WHEN** 某阶段按入口路由读取任一资源文件
- **THEN** 该文件内容完整交付、不触发宿主裁剪，获得与外移前等价的指令内容

#### Scenario: 骨架化不改变行为语义
- **WHEN** 入口被改写为骨架、展开内容移入资源文件
- **THEN** 既有 Requirement 约束的行为语义与触发条件保持不变，12 节编号与标题、skill 名称与描述不变
