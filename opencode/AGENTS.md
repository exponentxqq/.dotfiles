# 交互要求

- 请始终使用简体中文回复。所有解释、代码注释、对话都使用中文。

# 代码检索

- 检索代码时优先使用 codebase-memory-mcp 工具（search_graph / search_code / get_code_snippet / trace_path / query_graph 等），而非 grep/glob/手动读文件。
- 仅当 codebase-memory-mcp 未索引目标项目，或查询属于纯文本/文件名匹配时，才回退到 grep/glob。
