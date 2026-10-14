# dsh (DeepSeek Harness) 配置

统一管理 dsh 的 profile 配置。自定义插件源码已独立成仓（`~/develop/person/dsh-plugins`），本目录只保留 profile 与其插件依赖清单。运行时数据（API Key、会话）不在本目录，见下文「挂载机制」。

## 目录结构

| 路径                               | 说明                                                                 |
| ---------------------------------- | -------------------------------------------------------------------- |
| `profiles/<name>/cordis.patch.yml` | 用户配置层（主题、默认模型、provider 等），每个 profile 一份          |
| `profiles/<name>/package.json`     | profile manifest：bundles 列表与树外插件依赖（按 tag 的 git spec，由 pnpm / dsh plugin 维护） |
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

## 自定义插件（已独立成仓）

自定义插件不再放在本仓库，统一迁到 `~/develop/person/dsh-plugins`（pnpm workspace 单仓多包），并按 **GitHub tag** 安装：

| 插件 | 说明 |
| --- | --- |
| `dsh-plugin-multi-root-workspace` | 多工作区附加根；本 fork 含附加根播种与通用附加根 `commonRoots` |
| `dsh-plugin-git-graph-multi` | 单工作区多仓 Git Graph（上游 `@linxin666/dsh-client-ui-git-graph@0.4.5` 的 fork） |

开发与发布（新仓库 `README.md` 有完整说明，各插件文档在其目录内）：

```bash
cd ~/develop/person/dsh-plugins
pnpm install          # 装齐全部插件依赖（会触发各插件的 prepare 构建）
pnpm verify           # 发布前自检
pnpm release 1.0.0    # 同步版本 + 发布提交 + tag v1.0.0
git push origin main --tags   # 在宿主执行（容器内没有 ssh）
```

装到 profile（`#<tag>&path:` 同时指定版本与单仓子目录）：

```bash
docker exec dsh dsh plugin --profile web add \
  "github:exponentxqq/dsh-plugins#v1.0.0&path:plugins/dsh-plugin-multi-root-workspace"
docker exec dsh dsh --profile web --dump-config-schema   # 校验配置可加载（会 import 插件）
```

`dsh plugin add` 会自动完成两件事：

1. 把 git spec 写进 profile 的 `package.json` 依赖（tag 锁定的源码，安装时由 `prepare` 现场构建）
2. 因包声明了 `dsh.bundle`，自动把包名追加进 `dsh.profile.bundles` 列表并激活其 patch 层

移除：`docker exec dsh dsh plugin --profile web remove dsh-plugin-<name>`。升级 profile：改 spec 里的 tag → 重装 → 重启 profile。

两个常见阻碍：

- **构建授权**：git 来源要在安装现场跑 `prepare`，pnpm ≥10 默认拦下依赖构建脚本，首次 `add` 会以非 0 退出并把待决项写进 `dsh/profiles/web/pnpm-workspace.yaml`（`allowBuilds:` 下 `koffi`、插件包名等占位 `set this to true or false`）；改成 `true` 后重跑。
- **`insteadOf` 陷阱**：宿主 `~/.gitconfig` 的 `url.git@github.com:.insteadOf = https://github.com/` 会随只读挂载进入 dsh 容器，容器内 `git ls-remote` 被改写成 ssh 而容器没有 ssh，安装必败。推荐把该段拆到宿主专属的 `~/.gitconfig-github-ssh` 并用 `[include]` 引回（容器读不到即静默跳过）；临时办法是给命令加 `-e GIT_CONFIG_GLOBAL=/dev/null`。

本地开发调试仍可用 `link:`：`docker exec dsh dsh plugin --profile web add /home/xuqinqin/develop/person/dsh-plugins/plugins/<name>`（改源码重启 profile 即生效，无需发布）。

> `dsh-plugin-git-graph-multi` 与 `@linxin666/dsh-client-ui-git-graph` 共用 slot id（`git-graph`）与 `/git/*` 路由前缀，**不可同时启用**：先 `remove` 再 `add`。

### 附加根配置（profile 侧，仍在本仓库）

多根插件的附加根配置在 `dsh/profiles/web/cordis.patch.yml` 的 `multi-root-registry` 行：`seedRoots` / `seedPrimaryRoots` 是 opc 的跨仓联动根（docker / dotfiles / apigen / skills，主根 `/home/xuqinqin/develop/company/opc`）；`commonRoots` 里的 `~/.cache` 对**所有项目**生效，用于让 post-commit 的 codebase-memory 重建 hook（`cbm-hook-pending`、`cbm-hook.log` 与索引库）在会话沙箱内可写——不加入时该 hook 会因 EACCES 静默失败、索引停在旧版本。（opc 登记表里若还留着早先播种出的同名条目，在面板或 `/workspace-folders remove` 删一次即可，之后只剩通用条目。）

跨进程注意：同一 `$DSH_HOME` 同时只允许一个 DSH 进程持有根登记表，另一个进程显示 `registry-contended` 并 fail-closed（持锁者退出后刷新即接管）。

## OpenSpec 变更管理

本仓库根有 OpenSpec 根目录 `openspec/`（`config.yaml` 声明 `schema: spec-driven`、语言简体中文；结构标题与 SHALL/MUST 关键字保持英文）。规划工件与主规格都在这里版本管理：

```bash
cd ~/develop/dotfiles
openspec list                       # 变更列表
openspec validate <change> --strict # 校验工件
openspec archive <change>           # 评审通过后归档
```

> 与插件相关的规范工件（`dsh-multi-repo-git-graph` 主规格与三次变更的归档）已随插件迁到 `~/develop/person/dsh-plugins/openspec/`；本仓库 `openspec/` 保留空壳，供 dotfiles 自身的变更使用。
> 仓库内不写项目本地 openspec skills 副本（`openspec init --tools none`）——dsh / opencode 的 `openspec-*` skills 已由 skctl 全局装好，见下节。

## spec-workflow 固定工作流

固定 spec 驱动流程：**独立双线规划 → 差异收敛与分歧复算 → 落档 → 子代理执行 → 验证归档提交**；进度载体只有工件（`openspec/changes/<change>/` 与 `tasks.md` 勾选态），压缩上下文或重启会话后可从工件无损恢复。实体文件：

| 文件 | 作用 |
| --- | --- |
| `agent/skills/spec-workflow/SKILL.md` | 工作流本体（执行手册），skill 名 `spec-workflow` |
| `dsh/commands/spec-flow.md` | 命令薄壳，加载 skill 并把 `$ARGUMENTS` 代入正文 |
| `dsh/spec-workflow.yaml` | 阶段模型路由与引擎偏好（见下） |

两个等价入口：skill `spec-workflow`（按描述触发）与用户级斜杠命令 `/spec-flow`——薄壳正文经 `dsh-plugin-user-commands` 从 `~/.dsh/commands/spec-flow.md` 现读，调用参数以 `$ARGUMENTS` 全文代入：

| 参数 | 含义 |
| --- | --- |
| `<需求描述>` | 新建流程的需求原文；为空则先开放式询问 |
| `continue <变更名>` | 接续未完成变更：跳过规划与落档，按任务完成度续跑（执行前重选一次模式与引擎） |
| `--parallel` | 阶段 1 两条规划线以两个 fresh 子代理并行独立完成（缺省串行） |
| `--auto` | 连续执行全部批次，不因进度打断（不可逆/安全敏感/工作区外副作用/计划失效仍硬停） |
| `--step-task` | 每个任务核对后停留审核 |
| `--step-group` | 每个批次（`tasks.md` 编号组）核对后停留审核 |
| `--engine team` | Agent Teams 引擎；缺省读映射文件，再缺省 `subagent` |
| `--model <阶段>=<provider>/<模型>` | 阶段级模型覆盖；缺省读映射文件，再缺省继承会话模型 |

五阶段与阶段边界：1 独立双线规划（**两条方向不同、各自完整的独立规划线，不是分工**：A 线方向 = 需求与价值、范围与边界；B 线方向 = 实现与约束、反例与风险。两线各自产出**同一套 7 字段的完整轻量规划草案**——目标与非目标、范围与边界、方案与取舍、任务拆分草案、验证思路、风险与未知项、假设清单；**互不读取对方产物、不共享中间结论**，独立性用于互相暴露遗漏；**待决问题经「子代理 ↔ 用户交互（中转协议）」上浮**）→ 1.5 差异收敛与分歧复算（**共识 / 分歧 / 单边遗漏**三分类，单边项逐项核验、不因只有一条线提出而丢弃 → 可从代码、规范或只读命令查证的分歧由主会话自行查证裁定并记录依据、**不问用户** → 影响方案走向且无法查证的分歧派**第三条独立子代理复算**（映射键 `panel`，不以任何既有草案为输入）并三线对照形成结论 → 仅剩决策项按 **`grill-me` 的设计树 / 前沿法**提问（该方法只作用于本阶段提问，两条规划线不变）：把待决项映射为设计树，**只问前沿**——前置决策已定才进本轮、依赖未决答案的留到后续轮次，**≤5 问/轮、每题附推荐答案**（措辞使「是 / 同意」即等于接受推荐）；可从环境查证的事实自行查证、**不向你索取**，答完**重算前沿**再给下一轮，**前沿为空或你确认达成共识才算收敛**；三分类、第三线复算与裁定 / 未答项留痕机制不变）→ 2 落档（`openspec-propose` 产四件工件、`openspec validate --strict`；**落档即停**并展示摘要）→ 3 执行 → 4 验证与归档（`openspec-archive-change`）。每阶段结束简短汇报；规划外 scope 变化回到用户。

执行双引擎：`subagent`（默认）每任务派 fresh 子代理（提示自包含：任务原文、工件摘录、验证句、写范围），组内并发（上限 `parallelism`）、组间串行，主会话按验证句 + diff 核对通过才勾选任务；`team`（需 `--engine team` 或映射文件显式启用，依赖实验性 Agent Teams）由 Lead 把批次发到共享任务板、spawn ≤ 任务数的 implementer 认领，审核反馈走消息保留上下文，成员不可用降级 subagent；两种引擎的子代理待决问题统一经「子代理 ↔ 用户交互（中转协议）」中转。

三模式与提交节奏：`auto` 全部完成后提交一次；`step-task` 每任务、`step-group` 每批次停留审核，step 模式**每批次审核通过后提交一次**（提交信息含批次号）。另两次固定提交：落档工件在落档完成时单独提交、归档在验证通过后单独提交——三者互不混提。

### 子代理 ↔ 用户交互（中转协议）

平台约束：子代理与 Agent Teams 的 teammate **都不能直接向用户提问**——其调用提问工具会被 `assertLiveRoot` 以 `DELEGATED_CALLER` 拒绝（官方文档要求「在最终结果中包含尚未解决的决定」）。**中转**是让子代理**事实上能与用户交互**的官方可行路径：子代理把需用户拍板的决策（问题 + 选项 + 推荐 + 影响面）写入产物「待决问题」节并在回执中**上浮**，不自行假设 → 主会话收到后**立即代问用户**（≤5 问/轮，每题附推荐答案）→ 按引擎**两档回送**：

| 引擎 | 回送路径 | 子代理上下文 |
| --- | --- | --- |
| `team` | 经 team 引擎用 `send_message` 把答复回送**同一成员**（仅 `spawn_teammate` 的具名队友可寻址；tool-subagent 的子代理报 `active teammate … not found`） | 保留，可多轮往返 |
| `subagent` | 把上一轮回执摘要 + 用户答复并入新提示**接续重派** | 重建 |

用户明确授权「按假设清单推进」时跳过代问，并在产物中标注已授权假设。

### 阶段模型路由（`dsh/spec-workflow.yaml`）

```yaml
models: {}          # 五键 lineA | lineB | panel | apply | verify；值 { provider, model }，留空=继承
engine: subagent    # subagent | team（--engine 覆盖）
parallelism: 3      # 同组并行上限
```

优先级 `--model` 参数 > 映射文件 > 继承会话模型；五键各自的应用点：

| 键 | 应用点 |
| --- | --- |
| `lineA` / `lineB` | 阶段 1 两条独立规划线的子代理（仅并行编排派子代理时适用，串行编排由主会话自身依次完成） |
| `panel` | 阶段 1.5 的**分歧复算线**：仅在出现无法查证且影响方案走向的分歧时，派第三条独立子代理 |
| `apply` | 阶段 3 执行任务子代理（**team 引擎忽略 apply 键，该引擎下阶段级路由整体不适用**） |
| `verify` | 阶段 4 归档前验证子代理 |

落档与归档在主会话进行，模型由用户自行切换。

> **白名单一致性**：显式路由必须已在 web profile `cordis.patch.yml` 的 `subagent-model-selection-settings.allowedModels` 内，映射文件键值须始终是其子集；不在白名单时调用报错——工作流报告该路由并**回退继承**会话模型。注意：启用只需覆盖 `subagent-model-selection-settings` 一条（`enabled: true` + 五条 `allowedModels`）；`tool-subagent` 的 `modelSelectionSettings` 由各 agent 预设层自带 `true`，profile 补丁再覆盖只会落到被禁用的宿主行、无实际效果。

### 宿主操作（新增命令 / skill 后各一次）

```bash
# 1. 命令薄壳：源本在仓库，容器 ~/.dsh/commands/ 放 symlink（落盘宿主 /data/dsh/commands/）
mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-flow.md ~/.dsh/commands/spec-flow.md

# 2. skill 登记进 skctl 聚合层（机制见下节「skill 复用」）
node ~/develop/dotfiles/tools/skctl/src/cli.ts install ~/develop/dotfiles/agent/skills/spec-workflow

# 3. 无需重启：symlink 建好、skctl 登记后即时可用（已实测，通常无需重启 dsh）
#    命令面板未出现时，先在当前会话执行内置 /commands-reload 手动重扫（插件热加载，见下节）
#    仍不可见再兜底重启容器：
cd ~/develop/docker && docker compose restart dsh
```

校验：命令面板出现 `/spec-flow`、skill 列表出现 `spec-workflow`（已实测，运行中的 dsh 即时可见）；
`subagent` 工具的模型字段需新会话/重启后才出现。

## skill 复用（与 opencode 同源，经 skctl 聚合）

dsh 原生支持 Agent Skills 标准（`<dir>/<name>/SKILL.md` + `name`/`description` frontmatter）。
三个 profile 均已启用 skill 工具链（`skill-filesystem` + `tool-skill`），扫描根为容器内
`~/.agents/skills`——由 compose 把 skctl 聚合层只读挂载进来（`.env` 的 `SKCTL_STORE_PATH`）：

- **单一聚合层**：`~/.local/share/agent-skills/skills`（skctl 维护）。自写 skill 实体在
  `dotfiles/agent/skills/`（symlink 登记），外部 skill 为 git 源拷贝（记录 commit，可 update）；
  opencode 经 `~/.agents/skills` 读同一层
- **增删/更新 skill**：一律用 skctl（命令见 `agent/skills/README.md`）。该挂载是宿主聚合层的
  只读 bind mount **实时视图**（`findmnt` + md5 实测），宿主变更**即时可见**，运行中的 dsh
  **即可加载新 skill，通常无需重启**；命令插件亦带热加载（`watchTargets()` 防抖重扫 + 重新 arm），
  新命令同样即时注册——命令面板未出现时先执行内置 `/commands-reload` 手动重扫，
  仍不可见再兜底 `docker compose restart dsh`
- **MCP 依赖型 skill**（`codebase-memory`、`analyzing-elastic-logs`、`context7-mcp`）：
  描述可见但对应 `mcp__*` 工具未接入，模型自行降级；后续按「MCP 接入」一节各加一条
  insert patch 即可启用（dbx 已接，现为 opc 项目级，见下节）
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

## MCP 接入（dbx：opc 项目级）

dbx MCP 已从**用户级**（三个 profile 的 `cordis.patch.yml` 各一条 `mcp-dbx` insert，对所有
工作区可见）迁到 **opc 项目级**配置 `~/develop/company/opc/.dsh/mcp/dbx.yaml`（opc 仓
`.gitignore` 忽略 `.dsh`，属机器本地配置、不入库）：由 `dsh-plugin-project-mcp` 扫描并按
工作区隔离，**只有 opc 工作区**（主根，或以 opc 为附加根）的会话可见 `mcp__dbx__*`。
三个 profile 均已安装该插件（web 原有；acp/headless 随本次迁移补装）。原 insert 已从三个
profile 删除，并在原位以注释保留——确需恢复全局 dbx 时取消注释即可，但**勿与项目级同名
配置并存**（profile 行先占住 serverName，项目侧那台会被记 error 跳过）。

- **项目级 MCP 机制**：`dsh-plugin-project-mcp` 扫描每个工作区根（含附加根）的 `.dsh/mcp/`，
  每文件一台服务器、`serverName` 默认取文件名，支持 `${VAR}` 环境展开、文件热重载与
  `/mcp-reload` 兜底；隔离为 fail-closed（无归属会话看不到任何项目 MCP 工具）。该插件是
  纯宿主面，web/acp/headless 均可安装。现成参考：`opc/.dsh/mcp/figma.yaml`
- **给其他项目接 dbx**：在该项目根建 `.dsh/mcp/dbx.yaml`（结构同 opc），工具名同为
  `mcp__dbx__<tool>`；同一 `serverName` 全局只有一处胜出，跨项目并存需改名
- **patch 语法要点**：覆盖已有 loader（如翻转 `disabled`）直接写 `- id: ...` 条目；
  插入全新 loader 必须用 `- insert: [条目]` 包装，裸写新 id 会被静默忽略
- MCP server 包已烘进镜像（`ARG DBX_MCP_VERSION`），`npx` 启动秒起、无网络下载；
  初始连接失败不阻断 dsh 启动（该 server 的工具不出现，日志有错误）
- opencode 侧的同名 MCP 在 `~/.config/opencode/opencode.jsonc`（`DBX_WEB_URL` 为
  `localhost:4224`，走宿主端口映射），两端各自独立配置，不受本次迁移影响

## 升级注意

dsh 处于 developer preview，官方声明存在破坏性变更。升级 `DSH_VERSION` 前：

1. 提交本仓库改动（`git status` / `git diff`）
2. 备份 `/data/dsh`（credentials、sessions）
3. 升级后执行 `--dump-config` 与 `--dump-config-schema` 检查 patch 兼容性
