# 双端插件：宿主半 + 浏览器半

## 适用时机

插件要动 Web UI——面板、入口按钮、会话头部/侧栏座位，或任何浏览器侧渲染——时读本册。只加宿主命令 / 工具 / 服务、不碰 Web UI 的插件走 host-only，不需要本册。

本册只保证**选型判据、声明形状与浏览器半产物壳**对得上；组件、座位、样式这些 UI 写法按模板与官方文档来，本册不教 React/UI。路径一律相对 `/home/xuqinqin/develop/person/dsh-plugins`。

## 1. 选型判据

| 要加的东西 | 形态 | 模板 | 判据 |
|---|---|---|---|
| 宿主命令 / 工具 / 服务，不动 Web UI | host-only | `plugins/zcode-plan`、`plugins/project-mcp` | 不声明 `dsh.client`；少一个产物就少一个静默失败面 |
| Web 面板、入口、浏览器可见的行为 | 双端 | `plugins/session-tool-toggle`、`plugins/web-ux` | 同一个包两个 exports，宿主半先立住 |
| 替换上游 provider / 精确版本门禁 / 原生依赖 | 特例（可能带浏览器半） | `plugins/multi-root-workspace` | 不要只为「要做双端」选它——会整包继承上一代杂质（见 `build.md`） |
| 只有浏览器侧、没有宿主服务 | 官方文档 | — | 本仓无纯 client 模板，回退 `README.md` 末「插件开发文档（官方）」 |

两条硬判据：

1. **双端 = 一个包两个面，不是一个功能拆两个包。** 宿主半与浏览器半共用同一个 `package.json`、同一个包名、同一个 patch 文件；`dsh plugin add` / `remove` 只有一个安装单位。
2. **浏览器半是可选增强，不是宿主半的前提。** 宿主命令、RPC 通道、服务注册在无 Web 组合的 profile 里必须照常工作；浏览器半加载失败只能影响 UI（软注册、降级），不能拖垮宿主半。模板里 UI 入口的注册被 `try/catch` 吞掉拒绝、只写 warn 就是这个纪律（`plugins/session-tool-toggle/README.md:90`）。

## 2. 声明形状：四处成对，缺一即静默失效

| # | 位置 | 形状 | 漏了会怎样 |
|---|---|---|---|
| 1 | `package.json#exports["./client"]` | `{ "default": "./lib/client.js" }` | 浏览器半没有模块入口 |
| 2 | `package.json#dsh.client` | `{ "platform": "web", "inject": [...] }` | Web 扫描读不到声明，浏览器半不进启动图 |
| 3 | `cordis.patch.yml` | 一行**裸包名**（不带子路径） | 浏览器半静默消失（F1，见 §3） |
| 4 | `package.json#files` | 含 `cordis.patch.yml` 与 `lib/**/*.js` | git / pack 安装缺 patch 或产物（F2） |

模板另暴露 `"./package.json"`（`plugins/session-tool-toggle/package.json:19`、`plugins/web-ux/package.json:19`）：client-module scan 的回退解析分支按 `<包名>/package.json` 读清单，缺它会 `ERR_PACKAGE_PATH_NOT_EXPORTED`；现代 loader 走主路径可不带，双端包建议照模板带上。

模板对照：

- 双端声明：`plugins/session-tool-toggle/package.json:11-20`（`exports`，`./client` 在 `:15-17`）、`:28-38`（`dsh.client`，`inject` 在 `:29-35`、`platform` 在 `:36`）；`plugins/web-ux/package.json:11-20`、`:21-44`。
- 产物与图标进 `files`：`plugins/session-tool-toggle/package.json:39-44`（`icon.svg` 在 `:5`）；`plugins/web-ux/package.json:45-50`。
- 特例路线同一形状：`plugins/multi-root-workspace/package.json:41-44`（`./client`）、`:217-229`（`dsh.client`）。

### 2.1 `dsh.client` 的字段语义

- `platform` 固定 `"web"`：只声明 Web 组合消费浏览器半；宿主半不受影响，仍可装任意 profile。
- `inject` 是**包名依赖**，不是 Cordis 服务注入：列出浏览器半要用、且由组合内其它 client 包提供的包名，让它们在启动图里先于本包到达。别把宿主服务名写进去。字段定义见 `/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-package-manifest/lib/types/types.d.ts:75-89`。
- `external` 只在浏览器半 import 了**基座模块表之外**的模块时才需要精确列出；现有三个双端包（`session-tool-toggle` / `web-ux` / `workspace-config`）都只用到模块表基座，所以没有这个字段。基座与 `external` 语义见 `dsh-client-modules` 包的 `README.zh.md`（完整路径见 §5）。

### 2.2 裸包名行为什么是 REQUIRED

Web 启动时，宿主扫描已启用的 loader 行，取每行的 `name` 去解析包清单，再读 `dsh.client`。解析入口对**子路径 specifier 直接短路**——子路径行永远不是 client 行，只有挂在裸包名上的行才会被读。

于是 patch 必须有一行形如：

```yaml
- insert:
    - id: <本插件 id>
      name: 'dsh-plugin-<包名>'
```

- 不带子路径；模板也不把 `config:` 挂在载体行上——需要配置时在 profile 层按 `id` 覆盖（`plugins/web-ux/cordis.patch.yml:17-20` 明说注册行保持裸包名）。
- 同一个包可以另有子路径行（如 multi-root 的 `<包名>/fs`、`<包名>/compat`），但它们**不能替代**裸包名行。
- 载体行可以什么都不做：multi-root 专门放了一行空实现的 `apply` 作锚点（`plugins/multi-root-workspace/cordis.patch.yml:87-88`）。
- 去掉裸包名行 = 浏览器半静默消失：面板入口不出现、宿主命令一切正常，扫描失败只写 warn。原话与因果见 `plugins/session-tool-toggle/cordis.patch.yml:5-12`、`plugins/multi-root-workspace/cordis.patch.yml:25-29`，完整事故复盘见 `plugins/multi-root-workspace/docs/troubleshooting/client-bundle-not-in-boot-graph.md:3-23`。

## 3. 浏览器半产物：CJS bundle + ModuleLoader 壳

`lib/client.js` 必须是**一份 CJS bundle，包进 `window.__ModuleLoader__.load` 的 closure factory**。这是 Web client 唯一接受的产物形状：外壳只执行注册，模块副作用在 factory 物化时才发生。

```js
window.__ModuleLoader__.load({
  id: 'dsh-plugin-<包名>',        // 必须等于 package.json#name
  factory: (require) => {
    var module = { exports: {} }
    var exports = module.exports
    // 这里是被内联的 CJS bundle；外部请求走同步 require
    return module.exports
  }
})
```

四条纪律：

1. **`id` 必须等于包名。** 启动图按包名索引，bundle 通过 `/plugins/<id>/client.js` 提供；写错或重复注册 = 激活失败。
2. **`factory` 收到的 `require` 只能解析模块表基座**（react / react-dom / jsx-runtime 等，以及组合内 client 包）。基座之外的依赖必须内联进 bundle；反之，基座里的模块不要内联，否则会分叉出第二份运行时身份。
3. **脚本顶层只做注册。** 座位注册、CSS 注入等副作用放在 factory 内，跟随物化时机执行；顶层副作用会在「只注册不加载」的阶段提前跑。
4. **产物必须新鲜且入库。** 漏构建或漏提交 `lib/client.js`，启动图缺 bundle，激活会明确失败并提示构建——这属于构建分册的 `lib/` 入库纪律，不在这里展开。

两份可直接对照的实现：

- esbuild 路线：壳与 CJS 编译都在 `tooling/build-kit/src/client.mjs`（`moduleLoaderShell`；包名由 `manifest.name` 推导，外置清单是 `DEFAULT_CLIENT_EXTERNALS`），薄入口只声明 `cssClassPrefix`（有 CJS 内联的包再加 `cjsRequireShim`）。
- tsdown 路线：`plugins/multi-root-workspace/tsdown.config.ts` 的 client 配置（`banner`/`intro`/`footer` 拼出同一个壳）。

CSS modules 在构建期编译成运行时 `<style>` 注入，不单独产出样式表（`tooling/build-kit/src/css.mjs`）；防重护栏固定按「包 + 模块」双维度（`data-dsh-plugin` + `data-dsh-css`），只按包名查询会让同包第二个 module 的样式永不注入。样式细节归 UI 写法，本册不展开。

**生成产物别进 lint 视野**：唯一 lint 基准是仓库根 `.oxlintrc.json`，它的 `ignorePatterns` 含 `**/lib/**`（软插件目录不再放本地 `.oxlintrc.json`，AR6 会拦）。缺这条时 oxlint 会扫 `lib/client.js`，对壳里的 `factory: (require) => { var exports = … }` 报 `no-unused-vars`——EXIT 仍是 0，但 lint 不再干净。

## 4. 静默失效排查（按成本从低到高）

| 现象 | 先查 | 再看 |
|---|---|---|
| 面板 / 入口不出现，宿主命令正常 | patch 里裸包名行还在吗：`docker exec dsh dsh --profile web --dump-config \| grep -A 2 'id: <id>'` | profile 重启了吗；`exports "./client"` 指向的 `lib/client.js` 在包里吗；`files` 带上了吗 |
| `/plugins/<id>/client.js` 404 | 启动图有没有本包条目（`__DSH_BOOT__` / 直接请求该 URL） | 裸包名行、`dsh.client` 声明、`files` 三处逐项核对（`plugins/multi-root-workspace/docs/troubleshooting/client-bundle-not-in-boot-graph.md:19-23` 给了完整诊断步骤） |
| 入口时有时无，控制台有 `ModuleLoader` / 座位注册 warn | 壳的 `id`、factory 是否抛错、重复注册 | 顶层副作用是否提前执行；profile 是否还跑着旧 bundle（`dsh plugin add` 不热替换浏览器半，必须重启） |

**双端验收口径**：`--dump-config` 只打印 patch 层合成树，**不跑 client-module scan**——双端改造前后输出可能逐字节相同，它只能证明**裸包名载体行**在位（scan 的解析入口）。scan 识别的证据要重启 profile 后取：启动图 `__DSH_BOOT__` 含本包 entry / `/plugins/<id>/client.js` 可服务 / Web「设置 → 插件 → 插件列表」有本包且无同步失败。

四条经验：

- **先怀疑声明，再怀疑 UI。** 双端最常见的坏法是「宿主半正常、浏览器半消失」，而它几乎总落在 §2 的四处声明里，不是组件写错。
- **重启是最低成本的复验。** 浏览器半的 bundle 来自启动图，新增/升级后不重启就看不到新入口是正常的；重启仍无，才按上表继续查。
- **无座位的双端包怎么目检**：没有面板/入口可点时，唯一的 UI 面是 Web「设置 → 插件 → 插件列表」里的本包条目（无同步失败）+ 页面控制台的加载日志；`docker logs` 看不到浏览器侧。
- **控制台日志不进 `docker logs`。** 浏览器侧的座位注册、模块加载失败要看页面控制台（模板在软注册失败处只写一条 warn）。

## 5. 指路真源

| 要查什么 | 真源 |
|---|---|
| 双端声明与产物的活样板 | `plugins/session-tool-toggle`（README 的「双端结构」一节）、`plugins/web-ux` |
| 裸包名行因果与事故复盘 | `plugins/multi-root-workspace/docs/troubleshooting/client-bundle-not-in-boot-graph.md` |
| `dsh.client` 字段定义 | `/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-package-manifest/lib/types/types.d.ts:75-89` |
| 浏览器 bundle 与共享模块表 | `/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/@deepseek-ai/dsh-client-modules/README.zh.md` |
| 浏览器半产物壳 / 默认 externals | `tooling/build-kit/README.md` 与 `tooling/build-kit/src/client.mjs` |
| 构建自包含 / 产物入库 / externals 判定 | 构建分册与 `tooling/build-kit/README.md`；特例看 multi-root 的 `tsdown.config.ts` 头注释 |
| 官方插件开发三篇 | `README.md` 末「插件开发文档（官方）」 |
