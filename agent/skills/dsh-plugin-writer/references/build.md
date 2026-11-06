# 构建与产物（build）

> 本册是 `dsh-plugin-writer` 的分册②。**何时读**：`pnpm build` 报错、产物装载失败、`lib/` 没进包或不新鲜、某个依赖该 bundle 还是 external 拿不准、`allowBuilds` 或 `engines` 被门禁拦下时。声明与字段改写 → `structure.md`；浏览器半产物形状 → `dual-client.md`；装进 profile 与排障 → `verify-install.md`。
>
> **路径约定**：不带前缀的路径相对 `/home/xuqinqin/develop/person/dsh-plugins`；`dsh-*` 开头的官方包位于 `/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/`。行号只作快速落位，源码会漂，**指路以路径与符号名为准**；六个软插件的 `build.mjs` 是薄入口，本册不再给它们行号。
>
> **零版本数字**：本册不写任何版本值。要版本就看 `scripts/dsh-baseline.mjs`（仓内唯一版本常量），要派生范围就看它的 `softDshRange()`。

## 1. 先判形态：自包含（bundle）还是外置（external）

| 位置 | 默认策略 | 为什么 | 锚 |
|---|---|---|---|
| 软插件 host 半 | **默认全内联**，只外置 `node:*`；例外走 `hostExternals` | `link:` 安装不会装被链包的依赖，产物必须自包含才能装载 | 策略在 `tooling/build-kit/src/host.mjs`（`HOST_BASE_EXTERNALS`）；薄入口只追加 `hostExternals` |
| 特例 host 半（multi-root） | **反向**：`dependencies` / `peerDependencies` 里的生产包全部外置 | 宿主对每个服务身份只有一份实例，内联会 fork Service 身份 | `plugins/multi-root-workspace/tsdown.config.ts` 的 `productionPackages` + `deps.neverBundle` |
| 浏览器半 | 只外置 module table 里的运行时模块（react / react-dom / jsx-runtime / client-ui-primitives 等） | 这些由浏览器外壳的 loader 提供给 factory；其余内联，面板不持有需要共享的运行时身份 | 默认清单在 `tooling/build-kit/src/client.mjs`（`DEFAULT_CLIENT_EXTERNALS`）；特例见 `tsdown.config.ts` 的 `CLIENT_EXTERNALS` 与 client 配置 |

- **判据**：新增一个 `dependencies` 项时先问「它是不是宿主已有的服务身份 / 必须与宿主同实例」——是 → 外置（特例策略）；否 → 内联（软插件策略）。
- **反例（F3 坑①）**：`@deepseek-ai/schemastery` 这类只被 loader 读取的库必须内联；漏了它在 `link:` 安装下启动即报「找不到模块」，`pnpm build` 却是绿的。
- 浏览器半的声明与壳细节不在本册，见 `dual-client.md`。

## 2. host 半构建骨架（build-kit）

六个软插件的 `build.mjs` 只有一行 import + 一次 `await buildPlugin({...})`（有效代码 2–3 行）：从 `build-kit` 导入 `buildPlugin`（逐字见 `templates/default/build.mjs`）。esbuild 配置固定在 `tooling/build-kit/src/host.mjs`，不再逐包维护。

| 配置 | 在哪 | 说明 |
|---|---|---|
| 入口 | `tooling/build-kit/src/host.mjs` 的 `buildHostHalf` | `src/index.ts` → `lib/index.js`，宿主半唯一入口 |
| `bundle` / `format` / `platform` | 同左 | 固定 `bundle: true`、`format: 'esm'`、`platform: 'node'` |
| `target` | 同左 | `node22` |
| `external` | `HOST_BASE_EXTERNALS`（`['node:*']`）+ 薄入口 `hostExternals` | 只有「必须与宿主同实例」的包才追加 |
| `sourcemap` | 同左 | 不产（插件由运行时消费，不供别的 TS 引用） |
| `banner` | `CJS_REQUIRE_BANNER`，由薄入口 `cjsRequireShim` 开关 | 内联 CJS 时必需，见 §3 |
| 清空重建 | `tooling/build-kit/src/index.mjs` 的 `clean` | `auto` 由 `dtsOwned`（`exports[*].types`）推导：整目录 `full`，自持 d.ts 时 `js-only` |

- 产物落点由 `package.json` 的 `exports["."]` 决定（`structure.md` §2）；改产物文件名必须同步改 `exports`。
- 特例的清空策略不同：`plugins/multi-root-workspace/scripts/clean-lib.mjs` 只删旧 JS、保留 `lib/types`（类型由 `tsc` 产出），tsdown 侧用 `clean: false`（`plugins/multi-root-workspace/tsdown.config.ts`）。

## 3. CJS 互操作 banner（生成后必查项）

- **现象**：纯 CJS 依赖被内联进 ESM 产物后，模块**求值期**的 `require(...)` 会走 esbuild 的 `__require` shim，抛 `Dynamic require of "…" is not supported`。这是求值期错误，构建期看不出来（F3 坑②）。
- **解法**：薄入口传 `cjsRequireShim: true`，`build-kit` 注入 `CJS_REQUIRE_BANNER`（`tooling/build-kit/src/host.mjs` 的常量，文案与底层原理见该模块 docblock）——绑定到产物自身 URL 的真 `require`。
- **抄的时候**：常量名保持 `__dshCreateRequire`（避免与被内联代码里的局部 `require` 撞名）；banner 是 ESM 语句，必须排在产物最前；只在真有 CJS 内联时才开。
- **守卫会拦**：`tooling/build-kit/src/guards.mjs` 的 `assertNoDynamicRequire` 在产物出现 `__require(` 却没开 shim 时直接让构建失败（同类守卫还有 `assertNoInternalWord` / `assertSelfContained`）。
- **何时不需要**：产物里没有 CJS 内联。multi-root 的 host 面全 external（§1），因此不需要 banner——host-only ≠ 一定需要 banner；`web-ux` / `workspace-config` 的薄入口就没开它。

## 4. dsh 子包：走 `ctx.loader.import`，不进产物

- **适用判据**：这个官方子包必须与宿主/profile 里已有的实例**同实例**（服务身份、模块级单例、可被别人拒绝的同名注册）时，运行期加载而不是内联。
- **活例**：`plugins/project-mcp` 的 MCP 客户端——`plugins/project-mcp/build.mjs` 的头注释（产物里刻意不打进去，旋钮仍交给 build-kit）、`plugins/project-mcp/README.md`（为什么：按 profile 目录解析，因而与 profile 自己的行共用同一个模块实例）。
- **机制**：`ctx.loader.import(specifier, base, attrs)` 的解析基准是 loader 自己的基准；需要尊重传入 base 时用 `ctx.loader.internal.import`（`plugins/project-mcp/src/host/plugin-loader.ts` 的 docblock 写明这两个事实，实现在同文件；`unwrapExports` 也在那里）。
- **依赖声明的增量**：这类包只放 `devDependencies` 拿类型，**不进** `dependencies` / `peerDependencies`（对照 `plugins/project-mcp/package.json` 的 devDependencies）——它不是本包的运行期依赖，运行期由宿主提供。
- **坑**：这不是 esbuild `external` 能解决的事。把某个包写进 `external` 再静态 `import`，会按本包 `node_modules` 解析，而 profile 树里可能根本没有这份拷贝（`plugin-loader.ts` docblock 的另一条事实：profile 树可能一个 `@deepseek-ai/*` 都没有）。
- 反过来的选择：只是想在运行期用官方类型/工具函数、宿主保证有唯一实例 → 抄 multi-root 的 peer + external 策略（§1），不要用 `loader.import`。

## 5. 浏览器半产物（一句指路）

- 形状固定：CJS bundle 包进 `window.__ModuleLoader__.load({ id, factory })` 壳，`id` 必须是**裸包名**。壳由 `tooling/build-kit/src/client.mjs` 的 `moduleLoaderShell` 生成，薄入口不写壳；tsdown 特例用 `outputOptions` 拼出同一形状（`plugins/multi-root-workspace/tsdown.config.ts`）。
- CSS modules 在构建期编译成运行时 `<style>` 注入（`tooling/build-kit/src/css.mjs`），防重护栏固定按「包 + 模块」双维度。
- 声明、裸包名行因果与自检方法见 `dual-client.md`，本册只保证产物形状。

## 6. `lib/` 入库与新鲜度（F4）

- **为什么提交**：git/tag 来源安装按 pack 落盘且不触发 pnpm 的构建脚本授权（无 `prepare`），产物必须已经躺在仓库里（`README.md`「装入 profile」节；`scripts/release.mjs` 头注释的约定）。
- **谁保证新鲜**：`pnpm release` 会递归 `pnpm build`，再把各插件 `lib/` 一并 `git add`（`scripts/release.mjs` 的发布步骤）。也就是说新鲜度由发布流程构造性保证，不靠提交纪律。
- **产物目录不是临时物**：multi-root 的 `.gitignore` 明确写「产物 COMMITTED」，并提醒 `scripts/lib/` 才是源码；清理脚本也刻意保留 `lib/types`（`plugins/multi-root-workspace/scripts/clean-lib.mjs`）。
- **本地自检**：`git ls-files plugins/<name>/lib` 应有内容；改了 `src/` 后跑 `verify:all`（含 build），提交前确认 `lib/` 的字节与源码一致——`release` 会再兜一次。
- **别加 `prepare`**：加了就把构建授权又推回给安装方，等于废掉「lib 入库」的全部收益。

## 7. 依赖安装表态：`allowBuilds` 与发布年龄豁免（F6）

- **触发条件**：`dependencies` 里有带 install 脚本的原生模块 → pnpm 默认拦下构建，`pnpm install` 停在授权或直接失败。
- **必须归根表态**：只能写进根 `pnpm-workspace.yaml` 的 `allowBuilds` 节（嵌套 workspace 会被 pnpm 拒绝，来由见该文件头注释）。
- **代价**：每个安装方（含 profile 侧）都要再表态一次——pnpm 新版写占位后改 `true`，旧版走 `onlyBuiltDependencies`，两条路径见 `README.md`「装入 profile」节。
- **结论**：新插件**默认不带原生依赖**；非带不可才抄 multi-root 的三处（`plugins/multi-root-workspace/package.json` 的 `dependencies` + 根 `allowBuilds` + profile 安装说明）。
- **普通依赖的版本写法**：devDeps 一律 `catalog:` / `catalog:dsh` / `workspace:*`，不写字面量版本（`structure.md` §2 的反例）。
- **另一道门**：`dsh:check` 的基线组比对 `minimumReleaseAgeExclude` 与 lockfile 实际解析集（`scripts/check-dsh-baseline.mjs` 的发布年龄豁免断言）。需要豁免的只有 `@deepseek-ai/dsh*`、cordis、schemastery 与 libreoffice-kit（判定在 `isAllowlisted()`）——加第三方普通依赖不用动它，换 DSH 版本才会。

## 8. `engines` 派生（禁止手写）

- **真源**：`scripts/dsh-baseline.mjs` 的 `DSH_BASELINE`（唯一版本常量）与 `softDshRange()`（从基线派生软插件范围）。
- **落点**：软插件的 `dsh.engines.dsh` 与 DSH peer 必须同值；`dsh:check` 的基线组把 `catalog:dsh` 引用归一化后逐项比对 devDeps、engines、peer 与安装树（`scripts/check-dsh-baseline.mjs` 的对应断言），不直接拿字面量比对。
- **新插件默认走 soft**：`dsh:check` 动态枚举 `plugins/*`，按 `src/compat/dsh-version.ts` 是否存在分 hard/soft；`check-dsh-baseline.mjs` 要求 hard 恰一个，`check-architecture.mjs` 按同一判据只对软插件套 AR3–AR6。造第二个 hard 会让门禁失败，且要自己维护精确 allowlist（`structure.md` §6）。
- **升级**：不手改这些数字，走根 `pnpm dsh:upgrade`（`package.json` 的 `dsh:upgrade` 脚本；`AGENTS.md`「DSH 基线」节）——它会统一重指 devDeps、cordis、软插件范围与豁免。
- 想理解「为什么钉当前次版本线而不是放开整个零主版本」：`scripts/dsh-baseline.mjs` 的头注释就是答案。

## 9. 构建之后：证明强度逐级看

| 命令 | 证明了什么 | **不**证明什么 | 锚 |
|---|---|---|---|
| `pnpm --filter <包名> verify:all` | 产物能生成、类型与单测通过 | 产物能被 dsh 装载 | `plugins/zcode-plan/package.json` 的 `scripts.verify:all` |
| `pnpm dsh:check` | 三组门禁全绿：DSH 基线 / 结构不变式（AR1–AR7）/ 产物契约（B1–B5） | 你的代码可加载 | `scripts/dsh-check.mjs` 及其三个子脚本 |
| `--dump-config` | patch 生效、注册行进了合成树 | 模块可 import（它不 import） | `README.md`「装入 profile」节；`dsh-app-boot/README.zh.md` 的装载说明 |
| `--dump-config-schema` | **真实 import** 每个组合模块并读 schema | `apply` 执行（收集阶段不 apply） | `README.md`「装入 profile」节；`/usr/local/lib/node_modules/@deepseek-ai/dsh/lib/types/dump-config-schema.d.ts`；`dsh-app-boot/README.zh.md` |
| 启动 / 重启 profile | `apply` 真跑、服务注册、命令与面板出现 | 行为正确（要另测） | `README.md`「装入 profile」节 |

- **R3 坑①（必读）**：`--dump-config` 只证明注册行进合成树，**不证明代码可加载**；深验证组合是「`--dump-config-schema` 通过 + 容器内直接 import + 真实启动跑 `apply`」。
  - 容器内 import 自检（在 profile 目录跑，`node_modules` 才解析得到）：
    ```bash
    docker exec -w /home/docker/.dsh/profiles/web dsh \
      node -e "const m = await import('dsh-plugin-<name>'); console.log(Object.keys(m).sort().join(','))"
    ```
    期望看到 `apply,inject,name`（实测 host-only 插件输出就是这三个键）。拿到它们只说明模块可装载；`apply` 是否真能吃住配置，只能靠启动。
  - schema 收集**不 apply**（`dump-config-schema.d.ts` 原话：collection never applies plugins），所以「`--dump-config-schema` 退出 0」仍不等于行为正确。
- **两个正常态，别当失败**：
  - 输出里你那一行的 `status` 可能是 `absent`（`configRef` 指向 unknownConfig 定义）：含义是**该行没有可投影的 Config**，不是装载失败。本机 web profile 实测：host-only 且无 Config 的 `project-mcp` 就是 `absent`；正常态还有 `schema`（有 Config 可投影）与 `partial`（部分投影）。
  - 退出码非 0 也可能与你无关：stderr 里逐条列的是**各条目的**诊断。本机实测四条 `preset-*` 行（`@deepseek-ai/dsh-agent-preset`）报 `unrecognized Loader tree carrier`，退出码因此为 1，而插件本身的 schema 全部正常生成。**先做基线对照**：在未安装你的行（或 `disabled: true`）时跑一次同样命令，比对 stderr 条目差异，再判断是不是你的问题。完整排障见 `verify-install.md`。
- 输出里找不到你的行 → 先查 `dsh.bundle.patch` 是否声明、包是否进了 `dsh.profile.bundles`（`README.md`「装入 profile」节），再回 `structure.md` §3。

## 10. 构建失败速查

| 现象 | 大概率原因 | 去哪 |
|---|---|---|
| 启动/import 报 `Dynamic require of "…" is not supported` | 内联了 CJS 却没有 banner | §3 |
| `link:` / tag 装完 import 报模块找不到 | 依赖没内联，产物不自包含 | §1 |
| 装完行为还是旧的 | `lib/` 没重建或没提交 | §6 |
| `pnpm install` 停在构建授权 / 构建被忽略 | 原生依赖没进根 `allowBuilds` | §7 |
| `dsh:check` 报 engines / peer 不等于派生范围 | 手写了版本数字 | §8 |
| `dsh:check` 报 hard 插件数量不对 | 新插件误加了 `src/compat/dsh-version.ts` | §8 + `structure.md` §6 |
| 构建报 `产物里出现了 __require` / `@dsh-plugins/` / 未覆盖的模块词 | build-kit 产物守卫拦下：shim 没开、内部包没内联、或 externals 漏声明 | §1–§3 + `tooling/build-kit/src/guards.mjs` |
| `--dump-config` 有行但启动即失败 | 行进了树 ≠ 模块能加载 | §9 |
