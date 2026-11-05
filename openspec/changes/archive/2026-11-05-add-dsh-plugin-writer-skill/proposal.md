# Proposal

## Why

dsh-plugins 仓的 6 个插件沉淀了大量**非显然的工程约定与踩坑经验**（自包含 bundle、CJS `createRequire` banner、DSH 子包经 `ctx.loader.import` 不打包、注册行裸包名 REQUIRED、`lib/` 产物随仓库提交、engines 由基线派生等），目前散落在 AGENTS.md、README、各插件 `build.mjs`/`cordis.patch.yml` 头注释中——每次新增/修改插件都要重新「考古」，且静态文档复述易变事实必漂移（实证：AGENTS.md 写基线 `0.2.1-rc.2`，真源 `scripts/dsh-baseline.mjs` 已是 `0.2.1-rc.5`）。同时 DSH 官方自带的 `cordis-plugin-development` skill 面向「profile 内一次性 bundle」，与本仓「可发布、可版本管理的独立组合包工程」模式互补而存在空档。把本仓约定提炼为一份 agent 可按需加载的 skill，是填补该空档、终止重复考古的最低成本路径。

## What Changes

- 在 dotfiles 仓新建用户级 skill `agent/skills/dsh-plugin-writer/`（`SKILL.md` 精炼路由 + `references/` 四分册：structure / build / dual-client / verify-install），内容策略为「指路真源 + 选型决策树 + 反例清单 + 复制后必改清单」，正文零版本数字、分册不复述源码注释。
- 经 skctl 登记进聚合层（symlink → 容器 `/home/docker/.agents/skills` → dsh 用户级 rank 500 发现），使新会话目录可见、`/dsh-plugin-writer` 手势可用（默认双开，frontmatter 仅 `name`+`description` 两键）。
- `agent/skills/README.md`「当前清单」表补一行独立条目。
- 按 writing-skills 的 TDD 纪律验证：落盘前 RED 基线压测（子代理从零搭插件观察至首败，逐字记录借口）→ 撰写 GREEN 文档 → 结构/发现/加载三层校验 → dsh-plugins 仓全链演练（从零搭最小 host-only 插件走通 `verify:all` → `pnpm dsh:check` → link: 安装 → `--dump-config-schema`，演练产物四步清理不入库）。
- 生命周期指引止于「构建 + profile 安装验证」；发布与 `dsh:upgrade` 一句指路 AGENTS.md 不展开。

## Capabilities

无——本变更为文档型产物（skill 指令文档），无 spec 级系统行为变更，已在 `.openspec.yaml` 声明 `skip_specs: true`。

## Impact

- **dotfiles 仓**：新建 `agent/skills/dsh-plugin-writer/`（5 个文件）；修改 `agent/skills/README.md`（清单表 +1 行）；新建本变更目录工件。
- **机器态（不入库）**：`~/.local/share/agent-skills/`（skctl symlink 与 registry 条目）；容器 `/home/docker/.agents/skills` 经 bind mount 实时可见。
- **dsh-plugins 仓**：零入库改动；仅演练临时目录 `plugins/demo-echo/`（验证后四步清理，终态 `git status --short` 断言无残留）。
- **无破坏性变更**：不修改任何现有插件源码；与官方 `cordis-plugin-development` skill 显式分工（适用判定节声明让位条件）。
