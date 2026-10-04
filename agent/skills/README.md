# agent skills

本目录是**自写 skill 的实体存放地**（git 版本管理）。对外消费统一经
skctl 聚合层（`~/.local/share/agent-skills`），不经 skctl 登记的 skill
两个 agent 都看不到：

```
~/develop/dotfiles/agent/skills/     自写 skill 实体（本目录）
~/.local/share/agent-skills/skills/  skctl 聚合层（自写=symlink 回本目录，外部=git 拷贝）
~/.agents/skills → 聚合层            opencode 读取
容器 /home/docker/.agents/skills ←聚合层只读挂载（compose SKCTL_STORE_PATH）   dsh 读取
```

## skctl 常用命令

```sh
SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts

node $SKCTL list --all --desc                 # 查看全部（含 disabled）
node $SKCTL install <本地目录>                # 自写 skill 登记（symlink）
node $SKCTL install <git URL> --subdir <路径> # 外部 skill（拷贝，记录 commit）
node $SKCTL update [name...]                  # 更新 git 源 skill（local 源跳过）
node $SKCTL disable <name> / enable <name>    # 临时停用/恢复
node $SKCTL doctor                            # 修复 ~/.agents/skills 链接等
```

## 当前清单

| skill | 来源 |
| ----- | ---- |
| `spring-writer` / `nuxt-writer` / `grill-me` / `reviewing-deliverables` | 自写（本目录 local symlink） |
| `analyzing-elastic-logs` / `codebase-memory` / `context7-mcp` | 自写（依赖各自 MCP，dsh 侧工具未接时模型自行降级） |
| `openspec-*` ×7（core 6 + verify） | [Fission-AI/OpenSpec] `skills/<name>`，git 源（commit `2500d6da`），`skctl update` 升级 |

openspec skill 驱动 `openspec` CLI：dsh 容器已随镜像预装（`containers/tools/dsh/Dockerfile`）；
宿主机未装，opencode 侧触发时 CLI 缺失会降级，需要时 `npm i -g @fission-ai/openspec`。

[Fission-AI/OpenSpec]: https://github.com/Fission-AI/OpenSpec
