# 验证与 profile 安装（止于安装验证）

## 适用时机

包内构建已经过了（`pnpm build` / `verify:all`），要把插件装进 profile、验证它**真的能加载、真的出现在会话里**时读本册。起点是包内自检，终点是安装验证；发布（版本、tag、push、发布红线）不在本册展开，见仓库根 `AGENTS.md`「发布与版本」。路径一律相对 `/home/xuqinqin/develop/person/dsh-plugins`。

## 1. 证明强度阶梯

越往下越硬，但每一级只证明它自己那一列；任一级绿都不能跳过下一级。

| 步骤 | 证明了什么 | 没证明什么 |
|---|---|---|
| `pnpm build` | 产物能生成 | 产物可装载 |
| `pnpm --filter <包名> verify:all` | lint / typecheck / build / test 包内自洽 | 宿主组合能装载它 |
| `pnpm dsh:check` | 基线、pin、软范围、安装树、豁免清单互相一致 | 插件可装载 |
| `dsh plugin … add` | profile 清单 + bundle 列表 + patch 解析通过 | 代码可 import |
| `--dump-config` | 注册行进了合成树（双端包的裸包名载体行在位） | 不 import、不跑 client-module scan；双端的 scan 识别要重启后看启动图 |
| `--dump-config-schema` | 每个组合模块真实 import、schema 可读 | 不 mount / 不执行 `apply`，不证明运行时行为 |
| 重启 + 会话面（命令 / 面板 / `/inventory`） | 运行时真实可见 | 不证明可发布；这是本册终点 |

## 2. 命令链（按序）

### 2.1 装齐与包内自检

```bash
pnpm install
pnpm --filter dsh-plugin-<name> verify:all
```

- `pnpm install`：新包进 workspace、写 lockfile；带原生依赖时还要在根 `pnpm-workspace.yaml` 的 `allowBuilds` 表态一次（机制见 `plugins/multi-root-workspace/docs/troubleshooting/install-stops-at-build-approval.md`）。
- **lockfile 的 churn 大于新增 importer 属预期**：新包进 workspace 会让 pnpm 重解析，既有 importer 的 peer-context 哈希被整体重写（新增 importer 可能只占 diff 的零头）。交接 / 回滚时**整份保留或整份 `git restore`**，不要按「只该多一个 importer」局部还原——`dsh:check` 断言 6 要求豁免清单与 lockfile 精确相等（`scripts/check-dsh-baseline.mjs:228-238`）。
- `verify:all` 的组成是 lint → typecheck → build → test（`plugins/zcode-plan/package.json:52`、`plugins/session-tool-toggle/package.json:90`）；multi-root 追加 `kernel:probe` 与 `smoke`，需要运行中的 dsh（`plugins/multi-root-workspace/package.json:87`）。
- 这一级失败就在包内修，不要带着红去装 profile。

### 2.2 仓库级门禁

```bash
pnpm dsh:check
```

脚本动态枚举 `plugins/*`，**新插件立刻进入断言面**；七条断言见 `scripts/check-dsh-baseline.mjs:1-18`，失败会一次列全而不是遇错即停（`:16`）。

新插件最常见的首轮失败与处置：

| 报错关键词 | 原因与处置 |
|---|---|
| `declares no DSH devDependency` / `devDependencies[...] is ..., expected ...` | 从模板复制 devDeps 集合；版本由基线派生，不手写（`scripts/dsh-baseline.mjs:12-32`） |
| `dsh.engines.dsh is missing` / `is "...", expected "..."` | 软插件必须声明派生范围，同源派生见构建分册 |
| `peerDependencies does not declare @deepseek-ai/dsh` / `peerDependencies[...] is ...` | 同上，peer 与 engines 用同一个范围 |
| `expected exactly one exact-contract plugin` | 你的插件目录带了 `src/compat/dsh-version.ts`；普通插件不要复制 multi-root 的 compat 目录 |
| `is declared but not installed` | `pnpm install` 没跑或没装全 |
| `allowlist is missing / has stale ...` | 新增 `@deepseek-ai/dsh-*` 依赖时，`pnpm-workspace.yaml` 的 `minimumReleaseAgeExclude` 要与 lockfile 精确相等 |

`dsh:check` 绿只说明事实一致，不说明插件能装载——下一级才算。

### 2.3 link: 装进 profile

```bash
docker exec dsh dsh plugin --profile web add /home/xuqinqin/develop/person/dsh-plugins/plugins/<name>
```

- 绝对本地路径 = `link:` 依赖：改源码后重启 profile 即生效，不需要发布。tag / git 安装是发布姿势，不属本册。
- **刷新安装 = 重跑 `add`，不需要 remove→add**：`link:` 安装指向源码目录，改源码 / `package.json` 声明 / 重建产物后，重跑一次上面的 `add`（幂等）即可让 profile 侧同步；运行中的进程仍要按 §2.5 重启才看得到。`remove` 只在卸载与悬空链接（§3）时用。
- `add` 会解析该包的 `dsh.bundle.patch`，并把包追加进 `dsh.profile.bundles`；包没有 `dsh.bundle` 时会打 warn「installed as a plain dependency, not a profile layer」——**装了但不激活**（F2）。patch 解析失败则 `add` 直接失败，按报错修 `cordis.patch.yml`。
- 核对清单（宿主机上 profile 位于 dotfiles）：

```bash
grep -n '"dsh-plugin-<name>"' /home/xuqinqin/develop/dotfiles/dsh/profiles/web/package.json
```

`dependencies` 与 `dsh.profile.bundles` 两处都应命中；容器内同一份文件的路径是 `/home/docker/.dsh/profiles/web/package.json`（bind mount 的另一端）。

- **不要在宿主侧判断 `node_modules` 里的链接是否有效**：链接是按容器布局写的相对路径，宿主侧 `readlink -f` 会误报悬空。链接检查一律进容器做（§4）。

### 2.4 合成树与装载性

```bash
docker exec dsh dsh --profile web --dump-config | grep -A 2 'id: <id>'
docker exec dsh dsh --profile web --dump-config-schema > /tmp/schema.json 2> /tmp/schema.err; echo "exit=$?"
```

- `--dump-config`：只报告「配置出的组合」。注册行在合成树里出现，说明 patch 层已应用；它**不 import 模块、也不跑 client-module scan**——双端包看不到「client 注册行」，只能证明裸包名载体行在位。
- `--dump-config-schema`：真实 import 组合里每个模块并读 schema（`/usr/local/lib/node_modules/@deepseek-ai/dsh/README.zh.md:48`），`exit=0` 是 CLI 级装载性证据。stdout 是 JSON Schema，其中 `x-cordis.entries[]` 每项带 `path` / `id` / `name` / `status`：
  - `status: "absent"` = 该行没有 Config schema（host-only 插件常见），**正常态**，不是加载失败；
  - `x-cordis.complete: false` = 有模块失败，配合 stderr 的 `[/<path>]` 与 entries 的 `path` 定位是哪一行。
- `--dump-config-schema` 只 import、不 mount，`apply()` 的运行时行为仍要靠 §2.5。

### 2.5 重启与运行时可见性

```bash
cd ~/develop/docker && docker compose restart dsh
```

浏览器半的 bundle 由宿主在启动图里提供，`dsh plugin add` 不会热替换；宿主半同样以 profile 装配当刻的构建运行（`plugins/session-tool-toggle/README.md:71`、dotfiles `dsh/README.md:40-43`）。重启后按插件贡献的面验证：

| 插件贡献 | 验证方式 |
|---|---|
| 命令 | 会话里执行该命令，看注册与参数解析 |
| Web 面板 / 入口 / 无座位的双端包 | Web UI 目检；无面板时看「设置 → 插件 → 插件列表」与页面控制台（排查见 `dual-client.md` §4） |
| MCP 服务器 / skill | `/inventory`（见下） |
| 服务型、无会话面 | 只能靠启动日志与消费者验证；`/inventory` 证明不了它 |

`/inventory` 是 `dsh-plugin-user-commands` 提供的宿主侧只读清单命令：不提交用户消息、不产生模型请求、零 token（`plugins/user-commands/README.md:83-89`）。口径是「此刻本会话实际可用」而不是配置台账：

- MCP 段取 `tools.schemas(agent)` 的可见工具名，因此天然反映 `mcp:<server>` 开关与工作区隔离之后的真实可见面（`:105`）。
- Skill 段取 skill 注册表的会话目录，保留「模型可调用或 `/name` 可调用至少其一」的条目，并标出调用方式（`:106`）。

profile 里没装 user-commands 时该命令不存在，改用插件自己的命令 / 面板。

## 3. 卸载与重装

```bash
docker exec dsh dsh plugin --profile web remove dsh-plugin-<name>
```

`remove` 会同时校对 profile 清单与 `dsh.profile.bundles`（不再依赖的 bundle 名会被摘掉），不需要手改清单。但 **`link:` 安装的 `node_modules/<包名>` 是指向源码目录的符号链接，`remove` 只改清单，不保证清掉链接**：先删源码目录、后看链接，就会留下悬空链接，下一次安装或启动按名字解析到死路径。

顺序建议：**先 remove，再删源码目录**；然后进容器核对：

```bash
docker exec dsh bash -lc 'p=/home/docker/.dsh/profiles/web/node_modules/dsh-plugin-<name>; [ -L "$p" ] || { echo no-entry; exit 0; }; readlink "$p"; test -e "$p" && echo live || echo dangling'
```

- 输出 `dangling`：只删这一条链接（`rm "$p"`），再 `docker exec dsh dsh plugin --profile web install` 让 pnpm 收敛 `node_modules` 与 lockfile，之后才重新 `add`。
- 输出 `no-entry` 或 `live`：无需处理。
- 重装后仍要按 §2.4 / §2.5 复验，不能只看 `add` 的退出码。

## 4. 排障：先排除假故障

### 4.1 `--dump-config-schema` exit 1：先跑基线对照

退出码单独不能当证据：profile 里**既有**的行也会让 schema dump 失败，与你的插件无关。例如本机 profile web 当前就有一组 `preset-*` 行（`@deepseek-ai/dsh-agent-preset`）先报 `unrecognized Loader tree carrier`，另有一批 schema 警告。正确姿势是先留基线、再对照：

```bash
# 装插件之前（或已知良好状态）留一份基线
docker exec dsh dsh --profile web --dump-config-schema > /tmp/schema-before.json 2> /tmp/schema-before.err
# 装之后
docker exec dsh dsh --profile web --dump-config-schema > /tmp/schema-after.json 2> /tmp/schema-after.err
diff /tmp/schema-before.err /tmp/schema-after.err
```

只有 diff 出来、且 `[/<path>]` 指向你新插件行的 error 才是你的；基线里已有的行照旧归 profile。stdout 即使 exit 非 0 也会产出，可用 `x-cordis.entries` 反查失败行的 `id` / `name`。若你的插件已装、拿不到基线，先 `remove` 后重跑基线，或换一个未装它的 profile 对照。

### 4.2 `--dump-config` 绿 ≠ 可加载

`--dump-config` 报告的是配置出的组合，被拒绝的插件行仍会出现在里面；只有 `--dump-config-schema` 会 import 每个组合模块（`/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-app-boot/README.zh.md:54`）。合成树有行但 schema dump 在你的行上报 import 失败时，按顺序查：

1. `exports` 指向的产物在包里吗（`lib/index.js`、双端的 `lib/client.js`）；
2. `files` 带上了产物与 `cordis.patch.yml` 吗（F2）；
3. 产物是当前源码构建的吗（`lib/` 未重建是最常见的「本地看着有、装上就旧」）。

`status: "absent"` 不要当失败处理；没有 Config 的插件本来就没有 schema。

### 4.3 会话里看不到 skill / 工具 / MCP

先查 session-tool-toggle 的会话状态，再怀疑文件：

1. `/tools status`（装了 `dsh-plugin-session-tool-toggle` 时）看本会话关闭集与技能段。「技能：不可用」说明组合里没有 `skills` 服务；「意图 N」大于 0 表示有已关但当前未遮蔽（无该技能）的条目。
2. `/inventory` 看**实际可见面**：被 `skill:<name>` 关掉的技能仍会以「仅 /name」出现；完全看不到才是没注册。
3. 以上都正常，再去查文件位置、frontmatter、注册路径。

`skill:<name>` 的语义要记准：只让技能对**模型**隐身（目录行消失、`skill` 工具拒调），`/<技能名>` 手动调用完整保留；它不是权限边界，也不改磁盘上的 `SKILL.md`（`plugins/session-tool-toggle/README.md:40`）。`mcp:<server>` 则连服务器指令段一起去掉。开关在下一次模型步骤生效；默认档只在会话创建时拍快照，改档不追溯（`:59`、`:61`）。

### 4.4 `Unsupported engine` 警告是既有噪音

`pnpm install` / `verify:all` / `dsh:check` 常刷形如 `[WARN] Unsupported engine: wanted: {"node":"…"} (current: …)` 的警告，`current` 低于模板 `engines.node` 下限，且对**全部 importer**（含既有插件）都出现——这是容器 Node 与模板下限的既有落差，不是新插件失败。判据：警告覆盖既有 importer 全体 → 忽略；只在你新加的包上出现 → 再查 `engines.node` 是否抄错。

## 5. 终点：止于安装验证

安装验证的完成态：

- [ ] `verify:all` 绿；
- [ ] `pnpm dsh:check` 绿；
- [ ] `dsh plugin … add` 成功，profile 的 `dependencies` 与 `dsh.profile.bundles` 都有它；
- [ ] `--dump-config` 看得到注册行（双端包只能证明裸包名载体行在位，scan 识别要重启后看启动图 / 插件列表，见 `dual-client.md` §4）；
- [ ] `--dump-config-schema` 在基线对照下没有新增 error；
- [ ] 重启后会话面可见（命令 / 面板 / `/inventory`，按插件贡献选）。

到此为止。发布（release）流程见仓库根 `AGENTS.md`「发布与版本」——版本统一、tag、push 与发布红线都在那里，基线升级也不属本册。

## 6. 指路真源

| 要查什么 | 真源 |
|---|---|
| 仓库级命令与发布边界 | `AGENTS.md:42-77`（开发与验证命令、装入 profile）、`:78-80`（发布与版本） |
| 安装 / 构建授权 / `link:` 姿势 | `README.md:36-56` |
| 七条基线断言与 hard/soft 分流 | `scripts/check-dsh-baseline.mjs:1-18`（断言说明）、`:149-154`（hard/soft 分流）、`:153`（hard 恰一个） |
| 基线唯一常量与软范围派生 | `scripts/dsh-baseline.mjs:12-32` |
| `--dump-config` 与 `--dump-config-schema` 的语义差别 | `/usr/local/lib/node_modules/@deepseek-ai/dsh/README.zh.md:48`；`/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-app-boot/README.zh.md:54` |
| `/inventory` 的口径与降级 | `plugins/user-commands/README.md:83-110`；实现 `plugins/user-commands/src/host/inventory-command.ts`、`plugins/user-commands/src/host/index.ts:215-222` |
| `skill:` 开关语义 | `plugins/session-tool-toggle/README.md:39-45`；`plugins/session-tool-toggle/src/host/skills-plan.ts:1-16`、`:92-99`；`plugins/session-tool-toggle/src/host/address.ts:106` |
| 双端重启与入口排查 | `plugins/session-tool-toggle/README.md:71`、`:150-151` |
| profile 挂载与重启 | dotfiles `dsh/README.md:14-43` |
| 构建授权卡点 | `plugins/multi-root-workspace/docs/troubleshooting/install-stops-at-build-approval.md` |
