# 交互要求

- 请始终使用简体中文回复。所有解释、代码注释、对话都使用中文。

# 代码检索

- 检索代码时优先使用 codebase-memory-mcp 工具（search_graph / search_code / get_code_snippet / trace_path / query_graph 等），而非 grep/glob/手动读文件。
- 仅当 codebase-memory-mcp 未索引目标项目，或查询属于纯文本/文件名匹配时，才回退到 grep/glob。
- codebase-memory-mcp 的 `project` 参数是**绝对路径的归一化形式**（`/home/xuqinqin/develop/` 前缀之后的路径，所有 `/` 替换为 `-`），不是直觉短名。各工作区的「子项目 → 项目名」对照表见对应项目根 `AGENTS.md` 的「Codebase Memory 项目名映射」一节，或用 `list_projects` 核对。

# Docker 开发环境

- 若 docker 已提供某语言/工具的环境（node、python、rust、go、php 等），执行与建议均**必须使用 docker 提供的环境**，不得使用宿主机系统版本：`pnpm`/`cargo`/`go`/`php`/`composer`/`mysql` 等命令实际是 `~/develop/docker/bin/` 下的包装脚本（已加入 PATH，优先于宿主系统版本）；无包装的命令用 `~/develop/docker/run.sh <service> "<command>"`。Node 版本由 Volta 管理（读项目 `package.json` 的 `volta` 字段）。
- 例外：Java 在宿主机运行，不走 docker——JDK 用宿主机版本，构建用项目根的 `./mvnw` / `./gradlew`（wrapper）。
- 容器身份由 `.env` 的 `HOST_UID`/`HOST_GID`/`HOST_USER` 与宿主机对齐，容器内创建的文件宿主机可直接读写。
- 可用服务：mysql、postgres、redis、mongo、rabbitmq、rocketmq（namesrv+broker）、nginx、dbx（web 端口 4224）；hermes 为 manual profile 需显式启动；数据目录统一在宿主 `/data`。
- compose 拆分为 `compose/services.yml`（中间件）、`compose/languages.yml`（语言容器）、`compose/tools.yml`（工具），由根 `docker-compose.yml` include，配置由 `.env` 驱动。
