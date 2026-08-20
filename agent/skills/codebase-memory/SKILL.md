---
name: codebase-memory
description: Use when exploring, searching, or understanding a codebase — finding function definitions, tracing call paths, understanding architecture, or analyzing code dependencies. Activates for code exploration tasks that would otherwise use grep, find, or manual file reading. Also activate before indexing a new repository into the knowledge graph.
---

When the user asks to explore code, search for functions, understand architecture, trace dependencies, or analyze a codebase, use codebase-memory-mcp tools instead of grep/find/glob/ls.

## When to Use This Skill

Activate this skill when the user:

- Searches for a function, class, or symbol definition ("where is X defined?")
- Wants to understand project architecture or structure
- Traces call chains or data flow ("who calls X?", "what does X depend on?")
- Searches for code patterns across a codebase
- Needs to read a specific function or class implementation
- Asks about change impact ("what would break if I change X?")
- Wants to index a new repository for code intelligence

## Tool Mapping

Replace traditional tools with codebase-memory-mcp equivalents:

| Instead of | Use | Why |
|---|---|---|
| `grep` for definitions | `search_graph` (query / name_pattern) | Graph-ranked results with structural context |
| `grep` for patterns | `search_code` | Graph-augmented, deduplicates by function |
| `find` / `ls -R` for structure | `get_architecture` | Packages, services, dependency clusters |
| recursive `grep` for callers | `trace_path` (inbound/outbound) | Direct call graph traversal |
| manual multi-hop tracing | `query_graph` (Cypher) | Complex cross-cutting queries |
| `Read` whole file for one function | `get_code_snippet` | Token-efficient, reads only the target |
| `git diff` analysis | `detect_changes` | Impact analysis with graph context |

## Workflow

### Step 1: Ensure the project is indexed

Check indexing status first:

```
index_status(project="<project-name>")
```

If not yet indexed, index it:

```
index_repository(repo_path="<absolute-path>", mode="full")
```

To see all indexed projects:

```
list_projects()
```

### Step 2: Choose the right tool for the task

**Find a function/class/symbol definition:**
```
search_graph(project="<name>", query="<natural language>", limit=20)
search_graph(project="<name>", name_pattern=".*regex.*", limit=20)
search_graph(project="<name>", semantic_query=["keyword1", "keyword2"])
```
Use `query` for natural language (BM25 with camelCase splitting). Use `name_pattern` for regex. Use `semantic_query` with an array of keywords for vocabulary-bridging vector search.

**Search code text (like grep but smarter):**
```
search_code(project="<name>", pattern="<grep-pattern>", mode="compact")
```
Use `mode="compact"` for signatures (token efficient), `"full"` for source, `"files"` for file paths only.

**Understand architecture:**
```
get_architecture(project="<name>")
```
Returns packages, service clusters (Leiden community detection), and dependency overview.

**Trace callers/callees or data flow:**
```
trace_path(project="<name>", function_name="<qualified_name>", direction="inbound", depth=3, mode="calls")
trace_path(project="<name>", function_name="<qualified_name>", mode="data_flow", parameter_name="<name>")
```
Modes: `calls` (call graph), `data_flow` (value propagation), `cross_service` (HTTP/async boundaries).

**Read a specific function's source:**
```
get_code_snippet(project="<name>", qualified_name="<full.path.Function>")
```

**Complex multi-hop analysis:**
```
query_graph(project="<name>", query="MATCH (f:Function) WHERE f.transitive_loop_depth >= 3 RETURN f.qualified_name")
```

### Step 3: Cross-repo analysis (when needed)

When analyzing interactions between multiple projects:

```
index_repository(repo_path="<path>", mode="cross-repo-intelligence", target_projects=["project-a", "project-b"])
```

### Step 4: Pagination

`search_graph` responses carry `has_more` and `total`. If `has_more` is true, paginate:

```
search_graph(project="<name>", query="<same>", limit=200, offset=200)
```

## Guidelines

- **Index first**: Always check `index_status` before querying. An unindexed project returns empty or incomplete results.
- **Prefer search_graph over grep**: Even for simple symbol lookups, `search_graph` gives ranked, structured results with relationships.
- **trace_path is your call graph**: Don't manually trace callers by grepping — use `trace_path` with appropriate direction and depth.
- **Use compact mode by default**: `search_code` in `compact` mode returns signatures only, saving tokens.
- **Pagination awareness**: Check `has_more` in responses to avoid silent truncation.
- **Cross-repo intelligence**: When traces cross service boundaries, switch to `cross_service` mode in `trace_path`.
