# Codebase Memory MCP 使用规则

当需要理解、搜索或探索代码库时，优先使用 codebase-memory-mcp 工具，而不是 grep/find/glob/ls 等传统命令。

## 使用场景

| 场景 | 优先使用 | 代替 |
|------|---------|------|
| 搜索函数/类/符号定义 | `search_graph` (query / name_pattern) | grep |
| 全文代码搜索 | `search_code`（图谱增强搜索） | grep |
| 理解项目架构 | `get_architecture` | ls / find |
| 追踪调用链/依赖关系 | `trace_path` | grep 递归 |
| 复杂多跳查询 | `query_graph`（Cypher） | 手动追踪 |
| 读取函数/类源码 | `get_code_snippet` | Read 整个文件 |
| 检测变更影响范围 | `detect_changes` | git diff |

## 步骤

1. 首次使用时，先调用 `list_projects` 查看已索引的项目
2. 如果目标项目未索引，调用 `index_repository` 进行索引
3. 根据具体需求选择合适的工具进行查询
4. 优先使用图谱工具而非传统的 grep/find 命令

## 注意事项

- `search_graph` 支持自然语言查询（query）、正则名称匹配（name_pattern）、语义搜索（semantic_query）三种模式
- 跨项目分析时使用 `index_repository` 的 `cross-repo-intelligence` 模式
- `search_code` 返回图谱增强的结果，比纯 grep 更能定位到关键函数
