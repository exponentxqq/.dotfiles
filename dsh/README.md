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

## spec-workflow 固定工作流（四段：spec-plan 规划 / spec-workflow 编排衔接 / spec-apply 执行 / spec-done 终末）

固定 spec 驱动流程：**独立双线规划 → 差异收敛与分歧复算 → 代码设计 → 落档 → 子代理执行 → 验证归档提交**；进度载体只有工件（`openspec/changes/<change>/` 与 `tasks.md` 勾选态），压缩上下文或重启会话后可从工件无损恢复。

**拆分结构**：规划半程（阶段 1→2，至落档提交）独立为 skill `spec-plan`——可经 `/spec-plan` 单独使用（只要规划不要实现），也被 `spec-workflow` 委托作为其阶段 1→2；执行半程独立为 skill `spec-apply`（阶段 3 批次执行：双引擎/三模式/核对与审核-提交分离）——可经 `/spec-apply` 单独使用，也被 `spec-workflow` 衔接后委托；终末半程由 `spec-done` 承载（阶段 4 验证归档链 + 收尾闭环），执行完成后编排层自动委托；`spec-workflow` 保留全流程编排、衔接（模式/引擎/执行环境决策）与恢复协议判段路由。规划方法论（双线模板、收敛判据、设计深度契约）以 spec-plan 为唯一权威源。

### 文件

| 文件 | 作用 |
| --- | --- |
| `agent/skills/spec-plan/SKILL.md` | 规划半程本体（执行手册），skill 名 `spec-plan`；阶段 1→1.5→1.7→2，落档提交即收尾 |
| `agent/skills/spec-plan/refs/planning.md` | 双线派发模板与回执核对、前置检查展开、代码设计环节（栈识别与 writer skill 接线、深度契约、三档分降）、落档细节（四件套、批次契约、**组=执行审核批次**）——阶段 1/1.7 派发前与落档时读取 |
| `agent/skills/spec-plan/refs/convergence.md` | 阶段 1.5 六步判据与 `grill-me` 设计树/前沿分轮方法——**阶段 1.5 读取** |
| `agent/skills/spec-plan/refs/routing.md` | 规划键（lineA/lineB/panel/design/vision）路由、图片能力、白名单、三档回退、自检脚本——**派发子代理前读取** |
| `agent/skills/spec-plan/refs/failure-modes.md` | 规划侧失败处置（grill-me 降级、规划线/设计线失败、栈识别三选一、writer 加载失败）——**异常时读取** |
| `agent/skills/spec-workflow/SKILL.md` | 全流程编排与衔接半程本体，skill 名 `spec-workflow`；执行/终末为委托指针 |
| `agent/skills/spec-workflow/refs/failure-modes.md` | 衔接与编排侧失败处置——**异常时读取** |
| `agent/skills/spec-apply/SKILL.md` | 执行半程本体（执行手册），skill 名 `spec-apply`；阶段 3 批次执行：双引擎/三模式/核对与审核-提交分离 |
| `agent/skills/spec-apply/refs/execution.md` | 执行引擎编排与三模式、**审核-提交分离**、干净窗口验收两步法、执行期留痕与工件维护、分仓提交、凭据纪律、提示模板（**含 writer skill 加载指令**）、回执格式、team 任务板——**首次派发前读取** |
| `agent/skills/spec-apply/refs/routing.md` | 执行键（apply/verify/vision）路由、白名单、三档回退、自检脚本——**派发子代理前读取** |
| `agent/skills/spec-apply/refs/failure-modes.md` | 执行侧失败处置（含 team 成员上限降级、凭据缺失明确失败）——**异常时读取** |
| `dsh/commands/spec-flow.md` / `dsh/commands/spec-plan.md` | 两个命令薄壳，加载对应 skill 并把 `$ARGUMENTS` 代入正文 |
| `dsh/commands/spec-apply.md` | 执行半程命令薄壳，加载对应 skill 并把 `$ARGUMENTS` 代入正文 |
| `dsh/spec-workflow.yaml` | 阶段模型路由与引擎偏好（四段共用单一文件，见下） |

### 入口与委托

八个等价入口（四对）：skill `spec-workflow`（全流程，按描述触发）与 `/spec-flow`；skill `spec-plan`（只规划）与 `/spec-plan`；skill `spec-apply`（只执行）与 `/spec-apply <变更名>`；skill `spec-done`（终末）与 `/spec-done`。薄壳正文经 `dsh-plugin-user-commands` 从 `~/.dsh/commands/` 现读，调用参数以 `$ARGUMENTS` 全文代入。`/spec-flow` 遇新需求时委托 spec-plan 完成阶段 1→2（转发 `--parallel` 与规划键 `--model`，已预置不重问），落档提交后由 spec-workflow **衔接（模式/引擎/执行环境）**并委托 spec-apply 执行，全部完成后自动委托 spec-done 收口归档链——全流程体验不变；`/spec-plan` 落档提交即收尾，告知 `/spec-flow continue <变更名>` 接续。

`/spec-flow` 参数：`<需求描述>`｜`continue <变更名>`（接续，跳过已完成规划与落档）｜`--parallel`（转发）｜`--auto`/`--step-task`/`--step-group`｜`--engine team`｜`--model <阶段>=<provider>/<模型>`（执行键 apply/verify 本地消费；规划键转发）。`/spec-plan` 参数为其规划子集（`<需求描述>`、`--parallel`、规划键 `--model`）。

### 规划半程（spec-plan 承载）

1 独立双线规划（**两条方向不同、各自完整的独立规划线，不是分工**：A 线 = 需求与价值、范围与边界；B 线 = 实现与约束、反例与风险；各自产出**同一套 7 字段完整轻量草案**——目标与非目标、范围与边界、方案与取舍、任务拆分草案、验证思路、风险与未知项、假设清单；**互不读取对方产物、不共享中间结论**；待决问题经中转协议上浮）→ 1.5 差异收敛与分歧复算（**共识 / 分歧 / 单边遗漏**三分类，单边项逐项核验不丢弃；可查证分歧自行裁定不问用户；影响走向且无法查证的分歧派第三条独立子代理复算（键 `panel`，不以既有草案为输入）；决策项按 **`grill-me` 设计树/前沿法**提问——只问前沿、≤5 问/轮附推荐、答完重算前沿，前沿为空或用户确认共识才收敛）→ 1.7 代码设计（**恒派 fresh 子代理**（键 `design`），不随阶段 1 编排模式变化；派发前主会话做栈识别（`pom.xml`/`build.gradle*` 含 `spring-boot` 判 Spring、`nuxt.config.*` 或 package.json 依赖含 `nuxt` 判 Nuxt，monorepo 子包一并探测，双命中全加载），设计子代理**先加载栈对应 writer skill**（`spring-writer`/`nuxt-writer`），未命中问用户三选一；产出 `/tmp/spec-flow/<change>/code-design.md` 深度契约六字段（触达面清单 / file:line 证据锚 / 接口与数据形状 / 决策记录附被否反例 / 逐任务组实现要点 / 假设与未决项）+ 二行为约束；**栈识别结论写入落档 design.md 决策记录**——执行侧从工件读取，接续恢复不丢失）→ 2 落档（`openspec-propose` 产四件套、`openspec validate --strict` 零告警、工件单独提交；**tasks 分组 = 执行审核批次**，组内单任务合法、分组兼顾审核节奏；落档即停，不涉及执行模式，告知 `/spec-flow continue` 接续）。

**代码设计三档分降**（阶段 1.7 派发前判定）：**L2 全深度**（默认）六字段与二行为约束全部执行；**L1**（触达面 ≤2 文件且无新接口）字段 ③④⑤ 与验证映射单行简述，①⑥ 与二行为约束恒成立；**L0**（trivial：单文件 + 无接口变更 + 无逻辑分支变化）豁免 fresh 派遣，主会话 inline 一行断言落档并标注「未触 writer 约束」，涉分层/拆分/接口即升档；`code-design.md` 产物 schema 恒在。

### 执行半程（spec-apply 承载）

执行双引擎：`subagent`（默认）每任务派 fresh 子代理（提示自包含：任务原文、design 该组实现要点**逐字引用**、验证句、写范围、**栈对应 writer skill 加载指令**——从落档 design.md 决策记录点名，无从取得则重识别一次），组内并发（上限 `parallelism`）、组间串行，主会话按验证句 + diff 核对通过才勾选任务；`team`（需 `--engine team` 或映射文件显式启用，依赖实验性 Agent Teams）由 Lead 把批次发到共享任务板、spawn ≤ 任务数的 implementer 认领（**任务卡含同款加载指令**），审核反馈走消息保留上下文；**成员上限 8 达限（`Team member limit 8 reached`）或创建失败降级 subagent** 并留痕；**引擎允许批次间切换（含 team↔subagent），切换与原因留痕**。

**执行纪律（component:ai 实证沉淀）**：①**审核点与提交点分离**——任何模式完成后不自动提交，停留呈证（批次号/任务号/改动文件/验证输出摘要/diff stat）等用户审核确认，确认后才提交（用户明确豁免审核时除外；主会话核对通过 ≠ 审核通过）；②**干净窗口验收两步法**——确认无并发构建进程 + 验证任务无 SKIPPED 且真实 executed（如 gradle 口径 `N actionable tasks: N executed`），不以 BUILD SUCCESSFUL 字样判定通过；③**分仓提交**——嵌套独立 git 子仓的代码改动与根仓工件改动分别提交、不跨仓混提；④**真实凭据只经参数/环境变量传入进程**，绝不写入入库文件/日志/提交信息，凭据缺失以明确报错失败；⑤**执行期留痕与工件维护**——组收尾把 `code-design.md` 对应组段更新为终形态、运行规则以 R<n> 编号条目留痕（tasks.md 附录或 diff-matrix 执行期章）、证据落 `/tmp/<项目>-evidence/` 易失目录不入库。

三模式与提交节奏：`auto` 批次间不打断（硬停四条件除外：不可逆/安全敏感/工作区外副作用/计划彻底失效）、**全部完成后停留呈证**；`step-task` 每任务、`step-group` 每批次停留审核——**提交都在用户确认后**（step 每批次一次，auto 收尾一次）。另两次固定提交：落档工件在落档完成时单独提交、归档在验证通过后单独提交——互不混提。**中途恢复（auto 尤甚）**：勾选任务的改动尚未提交属预期——先对现存 diff 跑该任务验证句，通过即保持勾选、不重派子代理，不通过才回退该勾选并报告。

### 子代理 ↔ 用户交互（中转协议）

平台约束：子代理与 Agent Teams 的 teammate **都不能直接向用户提问**——其调用提问工具会被 `DELEGATED_CALLER` 拒绝（官方文档要求「在最终结果中包含尚未解决的决定」）。**中转**是让子代理**事实上能与用户交互**的官方可行路径：子代理把需用户拍板的决策（问题 + 选项 + 推荐 + 影响面）写入产物「待决问题」节并在回执中**上浮**，不自行假设 → 主会话收到后**立即代问用户**（≤5 问/轮，每题附推荐答案）→ 按引擎**两档回送**：

| 引擎 | 回送路径 | 子代理上下文 |
| --- | --- | --- |
| `team` | 经 team 引擎用 `send_message` 把答复回送**同一成员**（仅 `spawn_teammate` 的具名队友可寻址；tool-subagent 的子代理报 `active teammate … not found`） | 保留，可多轮往返 |
| `subagent` | 把上一轮回执摘要 + 用户答复并入新提示**接续重派** | 重建 |

上浮时机按半程分流：规划线上浮**并入阶段 1.5 统一提问**、设计线上浮**并入落档分歧点提问**（spec-plan 承载）；执行期上浮**当批次即时代问**（spec-apply 承载）。用户明确授权「按假设清单推进」时跳过代问，并在产物中标注已授权假设。

### 阶段模型路由（`dsh/spec-workflow.yaml`）

```yaml
models:                       # 规划键（spec-plan 消费）+ 执行键（spec-apply 消费）+ verify（spec-done 复用）+ 能力键 vision（spec-plan/spec-apply 共用）
  lineA:                                                    # 阶段 1 A 线（spec-plan）
    provider: deepseek-official
    model: deepseek-flash
    fallback: { provider: zai-coding-cn, model: glm-5.3 }   # 异家兜底（可选）
  design: { provider: deepseek-official, model: deepseek-flash }  # 阶段 1.7 设计线（spec-plan）
  apply:                                           # 阶段 3 执行（spec-apply）；可选 fallback
    provider: opencode-go
    model: deepseek-v4.1-flash
    fallback: { provider: deepseek-official, model: deepseek-flash }
  verify:                                          # 阶段 4 归档前验证（spec-done）
    provider: zai-coding-cn
    model: glm-5.3-flash
    fallback: { provider: opencode-go, model: deepseek-v4.1-flash }
  vision: { provider: zai-coding-cn, model: glm-5.3-flash }  # 读图覆盖路由（能力键，非阶段键）
engine: subagent    # subagent | team（--engine 覆盖；spec-apply 消费）
parallelism: 8      # 同组并行上限 / 落档分组上限
```

仓库当前配置（2026-10-17 `DeepSeek-V4.1-Flash-1017` 发布后重排：规划/设计用最强且最便宜的 1017，执行用快模型，验证用最低成本，GLM-5.3 降为规划线异家兜底）：
`lineA` / `lineB` / `panel` / `design` → `deepseek-official/deepseek-flash`（官方 `deepseek-flash` 即最新 1017，支持读图），其中 `lineA` / `lineB` 备用 `zai-coding-cn/glm-5.3`（异家兜底）；`apply` → `opencode-go/deepseek-v4.1-flash`，备用 `deepseek-official/deepseek-flash`；`verify` → `zai-coding-cn/glm-5.3-flash`，备用 `opencode-go/deepseek-v4.1-flash`；`vision` → `zai-coding-cn/glm-5.3-flash`（主路由已支持读图，仅低成本读图或落到不支持图片的路由时使用）。

优先级 `--model` 参数 > 映射文件 > 继承会话模型（`--model` 只覆盖主路由，`fallback` 只写在文件里）；各键应用点：

| 键 | 应用点 | 消费方 |
| --- | --- | --- |
| `lineA` / `lineB` | 阶段 1 两条独立规划线的子代理（仅并行编排派子代理时适用，串行由主会话自身依次完成） | spec-plan |
| `panel` | 阶段 1.5 的**分歧复算线**：仅在出现无法查证且影响方案走向的分歧时派第三条独立子代理 | spec-plan |
| `design` | 阶段 1.7 **代码设计子代理**：恒派 fresh，派发前栈识别、先加载栈对应 writer skill，未命中问用户三选一 | spec-plan |
| `apply` | 阶段 3 执行任务子代理（**team 引擎忽略 apply 键，该引擎下阶段级路由整体不适用**） | spec-apply |
| `verify` | 阶段 4 归档前验证子代理 | spec-done |
| `vision` | **读图覆盖路由**（能力键，不改变阶段划分）：子代理需图片输入而该阶段路由不支持图片时忽略阶段路由、改用它 | spec-plan/spec-apply 共用 |

图片输入能力（出处：dsh 内置 pi-ai provider 数据的 `input` 字段）：`zai-coding-cn/glm-5.3` 与 `opencode-go/deepseek-v4-pro` **不支持图片**；`zai-coding-cn/glm-5.3-flash`、`opencode-go/deepseek-v4.1-flash`、`deepseek-official/deepseek-flash` 支持。当前主路由（规划/设计/执行）均支持读图，**无需改道**；仅当显式路由或 `fallback` 落到不支持图片的 `glm-5.3` 且任务需读图时，改走 `vision`；其余不支持图片的路由遇到读图会报 `does not declare image input`（能力事实非故障，不重试、改路由）。

落档与归档在主会话进行，模型由用户自行切换。

> **白名单一致性**：显式路由（含 `fallback`）必须已在 web profile `cordis.patch.yml` 的 `subagent-model-selection-settings.allowedModels` 内，映射文件键值须始终是其子集；不在白名单时调用报 `child LLM route "…" is not allowed for this Session`。按**三档回退**处置：`fallback` 重派一次 → 回退继承会话模型 → 报告并暂停（不反复重试）。启用只需覆盖 `subagent-model-selection-settings` 一条（`enabled: true` + `allowedModels`）；`tool-subagent` 的 `modelSelectionSettings` 由各 agent 预设层自带 `true`，profile 补丁再覆盖只会落到被禁用的宿主行、无实际效果。
>
> **生效时机**：开关与白名单在**会话创建时**读取——改完配置**新建会话**即生效（实测无需重启 dsh）；**既有会话不会中途获得该能力**（旧会话里派发报 `child model selection is disabled for this tool instance`，换新会话即可）。映射路由 ⊆ 白名单的自检命令见两 skill 各自的 `refs/routing.md`。

### 宿主操作（新增命令 / skill 后各一次）

```bash
# 1. 命令薄壳：源本在仓库，容器 ~/.dsh/commands/ 放 symlink（落盘宿主 /data/dsh/commands/）
mkdir -p ~/.dsh/commands
ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-flow.md ~/.dsh/commands/spec-flow.md
ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-plan.md ~/.dsh/commands/spec-plan.md
ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md ~/.dsh/commands/spec-apply.md
ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-done.md ~/.dsh/commands/spec-done.md

# 2. skill 登记进 skctl 聚合层（机制见下节「skill 复用」）
node ~/develop/dotfiles/tools/skctl/src/cli.ts install ~/develop/dotfiles/agent/skills/spec-workflow
node ~/develop/dotfiles/tools/skctl/src/cli.ts install ~/develop/dotfiles/agent/skills/spec-plan
node ~/develop/dotfiles/tools/skctl/src/cli.ts install ~/develop/dotfiles/agent/skills/spec-apply
node ~/develop/dotfiles/tools/skctl/src/cli.ts install ~/develop/dotfiles/agent/skills/spec-done

# 3. 无需重启：symlink 建好、skctl 登记后即时可用（已实测，通常无需重启 dsh）
#    命令面板未出现时，先在当前会话执行内置 /commands-reload 手动重扫（插件热加载，见下节）
#    仍不可见再兜底重启容器：
cd ~/develop/docker && docker compose restart dsh
```

校验：命令面板出现 `/spec-flow`、`/spec-plan`、`/spec-apply`、`/spec-done`，skill 列表出现 `spec-workflow`、`spec-plan`、`spec-apply`、`spec-done`（已实测，运行中的 dsh 即时可见）；`subagent` 工具的模型字段需新会话/重启后才出现。

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
