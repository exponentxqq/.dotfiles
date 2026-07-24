# 交互要求

- 请始终使用简体中文回复。所有解释、代码注释、对话都使用中文。

# 代码检索

- 检索代码时优先使用 codebase-memory-mcp 工具（search_graph / search_code / get_code_snippet / trace_path / query_graph 等），而非 grep/glob/手动读文件。
- 仅当 codebase-memory-mcp 未索引目标项目，或查询属于纯文本/文件名匹配时，才回退到 grep/glob。
- codebase-memory-mcp 的 `project` 参数是**绝对路径的归一化形式**（`/home/xuqinqin/develop/` 前缀之后的路径，所有 `/` 替换为 `-`），不是直觉短名。各工作区的「子项目 → 项目名」对照表见对应项目根 `AGENTS.md` 的「Codebase Memory 项目名映射」一节，或用 `list_projects` 核对。
