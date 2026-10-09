# dsh (DeepSeek Harness) 配置

统一管理 dsh 的 profile 配置与自定义插件。运行时数据（API Key、会话）不在本目录，见下文「挂载机制」。

## 目录结构

| 路径                               | 说明                                                                 |
| ---------------------------------- | -------------------------------------------------------------------- |
| `profiles/<name>/cordis.patch.yml` | 用户配置层（主题、默认模型、provider 等），每个 profile 一份          |
| `profiles/<name>/package.json`     | profile manifest：bundles 列表与树外插件依赖（由 pnpm / dsh plugin 维护） |
| `plugins/<name>/`                  | 自定义插件源码（官方组合包 bundle 形式）                              |
| `install.sh`                       | 安装脚本：纳管旧布局 profile、保障目录，幂等可重复执行                |

## 挂载机制

dsh 容器（`~/develop/docker`）通过 compose volume 把 `profiles/` 挂进容器：

```
~/develop/dotfiles/dsh/profiles  →  /home/docker/.dsh/profiles
        （宿主，版本管理）              （容器，dsh profile 根）
```

- 映射的宿主路径由 docker 仓库 `.env` 的 `DSH_HOST_PROFILES_PATH` 配置
- dsh 在容器内读写的 `~/.dsh/profiles` 实际落盘到本仓库，改动双向即时可见
- `node_modules/`、`.pnpm-store/`、`.plugin-manager/` 等运行产物会被 gitignore 忽略（依赖锁文件入库）
- credentials、sessions、storages 等运行时数据仍在 `/data/dsh`（`DSH_HOST_DATA_PATH`），**不入库**

> **重要**：`/data/dsh/profiles` 是容器内 `~/.dsh/profiles` 的嵌套挂载点，容器运行期间
> 宿主侧**必须保留该目录，切勿删除**——删除会使容器内挂载失效，profile 会回落到宿主目录
> 并被 dsh 按模板重新初始化到宿主机。Docker 仅在容器启动时自动创建，`install.sh` 会主动保障其存在。

## 安装

```bash
sh ~/develop/dotfiles/dsh/install.sh
```

首次纳管：若 `/data/dsh/profiles` 下仍有旧布局的 profile 目录，脚本会将其移入本仓库。

修改 `cordis.patch.yml` 后：dsh 运行中（启用 HMR）会自动重载配置；否则重启容器生效：

```bash
cd ~/develop/docker && docker compose restart dsh
```

### 常用命令

```bash
cd ~/develop/docker

docker exec dsh dsh --profile web --dump-config          # 查看合成后的配置树（含各 patch 层）
docker exec dsh dsh --profile web --dump-config-schema   # 校验配置 schema（会 import 插件，可验证插件可加载）
docker compose logs dsh | grep "dsh web:"                # 取带 token 的启动 URL

# 注：`bin/dsh` 包装脚本已删除（dsh 不经包装脚本）；宿主侧一律 `docker exec dsh dsh …`
# 或 `~/develop/docker/run.sh dsh "dsh …"`，dsh 容器内直接 `dsh …`。
```

## 自定义插件

插件采用官方组合包（bundle）形式，一个插件一个目录：

```
plugins/<name>/
├── package.json       # name 建议 dsh-plugin-<name>；声明 dsh.bundle.patch
├── cordis.patch.yml   # insert 本包注册的插件行（按包名引用）
└── index.js           # 插件实现（纯 ESM，导出 name / apply）
```

安装到 profile（容器内路径与宿主一致，用绝对路径即可）：

```bash
cd ~/develop/docker
docker exec dsh dsh plugin --profile web add /home/xuqinqin/develop/dotfiles/dsh/plugins/hello
```

`dsh plugin add` 会自动完成两件事：

1. 以 `link:` 形式写入 profile 的 `package.json` 依赖（pnpm symlink 指向源码目录，**改源码重启 profile 即生效**，无需重装）
2. 因包声明了 `dsh.bundle`，自动把包名追加进 `dsh.profile.bundles` 列表并激活其 patch 层

移除：

```bash
docker exec dsh dsh plugin --profile web remove dsh-plugin-<name>
```

`plugins/hello/` 是可直接复制的示例包（也可复制为新插件目录后改名）。

### git-graph-multi（单工作区多仓 Git Graph）

`plugins/git-graph-multi/` 是 `@linxin666/dsh-client-ui-git-graph@0.4.5`（Apache-2.0）的本地 fork，把分支芯片从「工作区根那一个仓库」扩展为「工作区内每仓一个平铺分支芯片 + 各仓自己的操作面板 + 跨仓（组）分支操作」，同时把 `/git/*` 的门控从「路径全等」放宽为「工作区内 + git 顶层围栏」，并删除了上游的匿名遥测。行为语义与验收场景见
[`openspec/specs/dsh-multi-repo-git-graph/spec.md`](../openspec/specs/dsh-multi-repo-git-graph/spec.md)（三次变更的规划工件已归档在 [`openspec/changes/archive/`](../openspec/changes/archive/)），插件自身说明见 [`plugins/git-graph-multi/README.md`](plugins/git-graph-multi/README.md)。

与 `plugins/hello/` 这类单文件插件不同，它是**双面插件 + 构建产物**：源码在 `src/`（host / core / client），`lib/` 由 esbuild 按需构建且不入库。

```bash
# 1. 构建（产物自包含：link: 安装不会为被链接包装依赖）
cd ~/develop/dotfiles/dsh/plugins/git-graph-multi
pnpm install && pnpm run typecheck && pnpm test && pnpm run build

# 2. 替换 profile（容器内执行）
cd ~/develop/docker
docker exec dsh dsh plugin --profile web remove @linxin666/dsh-client-ui-git-graph   # 先移除，二者共用 slot id 与 /git/* 前缀
docker exec dsh dsh plugin --profile web add /home/xuqinqin/develop/dotfiles/dsh/plugins/git-graph-multi
docker exec dsh dsh --profile web --dump-config-schema                              # 校验 host 半可被 Loader 加载
```

回滚：`docker exec dsh dsh plugin --profile web remove dsh-plugin-git-graph-multi` 后重新 `add @linxin666/dsh-client-ui-git-graph@0.4.5`。

## OpenSpec 变更管理

本仓库根有 OpenSpec 根目录 `openspec/`（`config.yaml` 声明 `schema: spec-driven`、语言简体中文；结构标题与 SHALL/MUST 关键字保持英文）。规划工件与主规格都在这里版本管理：

```bash
cd ~/develop/dotfiles
openspec list                       # 变更列表
openspec validate <change> --strict # 校验工件
openspec archive <change>           # 评审通过后归档
```

> 仓库内不写项目本地 openspec skills 副本（`openspec init --tools none`）——dsh / opencode 的 `openspec-*` skills 已由 skctl 全局装好，见下节。

### 插件开发文档（官方）

- [第一个插件](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/develop/basic/index.zh.md)
- [开发一个工具](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/develop/basic/tool.zh.md)
- [打包与安装插件](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/develop/basic/publish.zh.md)

## skill 复用（与 opencode 同源，经 skctl 聚合）

dsh 原生支持 Agent Skills 标准（`<dir>/<name>/SKILL.md` + `name`/`description` frontmatter）。
三个 profile 均已启用 skill 工具链（`skill-filesystem` + `tool-skill`），扫描根为容器内
`~/.agents/skills`——由 compose 把 skctl 聚合层只读挂载进来（`.env` 的 `SKCTL_STORE_PATH`）：

- **单一聚合层**：`~/.local/share/agent-skills/skills`（skctl 维护）。自写 skill 实体在
  `dotfiles/agent/skills/`（symlink 登记），外部 skill 为 git 源拷贝（记录 commit，可 update）；
  opencode 经 `~/.agents/skills` 读同一层
- **增删/更新 skill**：一律用 skctl（命令见 `agent/skills/README.md`）。注意 inotify 事件
  不跨容器挂载边界——宿主变更后 opencode 即时生效，**dsh 需 `docker compose restart dsh`**
- **MCP 依赖型 skill**（`codebase-memory`、`analyzing-elastic-logs`、`context7-mcp`）：
  描述可见但对应 `mcp__*` 工具未接入，模型自行降级；后续按「MCP 接入」一节各加一条
  insert patch 即可启用（dbx 已接，见下节）
- skill 的 `name`/`description` 常驻 system prompt，正文由模型按需通过 skill 工具加载

### openspec skills

`openspec-*` 共 7 个（core 6 + verify，选 verify 作交付前校验关口），经 skctl 从
[Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) 的 `skills/<name>` 安装，
升级 `skctl update`。正文驱动 `openspec` CLI：容器内已随镜像预装
（`containers/tools/dsh/Dockerfile`，`ARG OPENSPEC_VERSION` 可 pin）；**宿主机未装**，
opencode 侧触发时 CLI 缺失会降级，需要时 `npm i -g @fission-ai/openspec`。
剩余 5 个扩展 skill（`new`/`continue`/`ff`/`bulk-archive`/`onboard`）需要时用 skctl 补装。

> **环境层边界**：dsh 启动时会读取 cwd 的 `.env` 作为环境层，并禁止其中出现 `DSH_*` 变量
> （只允许来自启动环境）。因此不要在含 `DSH_*` 的 `.env` 目录（如 `~/develop/docker`）下
> 启动应用；`dsh plugin` 管理命令、web 服务（容器 ENTRYPOINT 启动）不受影响。
> `docker exec dsh dsh <app>` 的默认工作目录是 `${HOST_PROJECT_PATH}`（无 `.env`），
> 需要换目录时用 `docker exec -w <dir> dsh dsh <app>`。

## MCP 接入（dbx）

三个 profile 的 `cordis.patch.yml` 各有一条 `- insert:` 条目，把内置的
`@deepseek-ai/dsh-mcp-client` loader 插入树中，stdio 启动 `@dbx-app/mcp-server`
连接 dbx web（dsh 与 dbx 同在 compose `backend` 网络，容器内以 `http://dbx:4224` 直连）。
模型侧工具名为 `mcp__dbx__<tool>`。

- **patch 语法要点**：覆盖已有 loader（如翻转 `disabled`）直接写 `- id: ...` 条目；
  插入全新 loader 必须用 `- insert: [条目]` 包装，裸写新 id 会被静默忽略
- MCP server 包已烘进镜像（`ARG DBX_MCP_VERSION`），`npx` 启动秒起、无网络下载；
  初始连接失败不阻断 dsh 启动（该 server 的工具不出现，日志有错误）
- opencode 侧的同名 MCP 在 `~/.config/opencode/opencode.jsonc`（`DBX_WEB_URL` 为
  `localhost:4224`，走宿主端口映射），两端各自独立配置

## 升级注意

dsh 处于 developer preview，官方声明存在破坏性变更。升级 `DSH_VERSION` 前：

1. 提交本仓库改动（`git status` / `git diff`）
2. 备份 `/data/dsh`（credentials、sessions）
3. 升级后执行 `--dump-config` 与 `--dump-config-schema` 检查 patch 兼容性
