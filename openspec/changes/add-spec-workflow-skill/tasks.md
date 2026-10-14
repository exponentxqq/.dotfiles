# Tasks

## 1. 文件落地

- [ ] 1.1 新建命令薄壳 `dsh/commands/spec-flow.md`：按 design「命令文件设计」节写入 frontmatter（`description`、`argument-hint` 覆盖需求描述/continue/--parallel/--auto/--step-task/--step-group/--engine/--model）与正文（加载 spec-workflow skill、`$ARGUMENTS` 代入、未预置选项询问规则、空参数开放式询问、continue 语义）；验证：文件存在、frontmatter 为合法 YAML 且仅含 description 与 argument-hint、正文包含 `$ARGUMENTS`
- [ ] 1.2 新建阶段模型路由 `dsh/spec-workflow.yaml`：按 design「映射文件 schema」节写入 `models`（键 explore/grill/apply/verify，默认空对象）、`engine: subagent`、`parallelism: 3`，并保留注释说明（白名单约束、命令行覆盖、四键含义）；验证：`python3 -c "import yaml;d=yaml.safe_load(open('dsh/spec-workflow.yaml'));assert set(d)>= {'models','engine','parallelism'}"` 通过
- [ ] 1.3 新建工作流本体 `agent/skills/spec-workflow/SKILL.md`：按 design「SKILL.md 设计」节写入 frontmatter（name `spec-workflow`、description 含触发词与接续说明）与全部十二个章节（总览、前置检查、模式收集、阶段 1 双线调研、问题收敛、落档、衔接与恢复协议、执行双引擎与三模式、验证与归档、接续、模型路由、边界与失败），正文简体中文；验证：frontmatter `name` 等于目录名、十二节标题齐备、含「恢复协议」「team」「step-task」「白名单」关键词
- [ ] 1.4 修改 `dsh/profiles/web/cordis.patch.yml`：按 design「profile patch 变更」节追加 `tool-subagent`（`modelSelectionSettings: true`）与 `subagent-model-selection-settings`（`enabled: true` + 五条 `allowedModels`）两条同 id 覆盖；验证：`docker exec` 不可用时以 `dsh --profile web --dump-config-schema` 在本容器执行通过，且 YAML 解析通过
- [ ] 1.5 修改 `agent/skills/README.md`：清单表补 `spec-workflow`（自写 local symlink）行；把 `openspec-*` 行描述修正为「已由 skctl 从 Fission-AI/OpenSpec 安装 core 6 + verify（openspec-verify-change）」，与「dsh 需重启生效」备注一致；验证：表格含 `spec-workflow` 与 `openspec-verify-change` 字样
- [ ] 1.6 修改 `dsh/README.md`：新增「spec-workflow 固定工作流」章节，内容含入口（skill 与 `/spec-flow`）、参数面、双引擎与三模式、映射文件与白名单一致性要求、宿主操作（symlink 已建、skctl 登记、`docker compose restart dsh`）；验证：章节标题存在、含 `/spec-flow`、`spec-workflow.yaml`、`restart dsh` 关键词

## 2. 挂载与登记

- [ ] 2.1 建立命令挂载：容器内 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-flow.md ~/.dsh/commands/spec-flow.md`；验证：`ls -l ~/.dsh/commands/spec-flow.md` 显示指向源本，且 `readlink -f` 命中源本
- [ ] 2.2 登记 skill 到聚合层：经 node 容器执行 `node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install /home/xuqinqin/develop/dotfiles/agent/skills/spec-workflow`；验证：`skctl list --all` 输出包含 `spec-workflow`，且宿主聚合层 `ls -l` 出现指向源本的符号链接

## 3. 验证

- [ ] 3.1 变更校验：`openspec validate add-spec-workflow-skill --strict` 输出通过；验证：退出码 0 且输出含 valid/passed 语义（无 error/warning）
- [ ] 3.2 配置校验：`python3` 解析 `dsh/spec-workflow.yaml` 与 `dsh/profiles/web/cordis.patch.yml` 成功；`dsh --profile web --dump-config-schema` 通过（patch 可加载、插件可 import）；验证：三条命令均退出码 0
- [ ] 3.3 交付核对：汇总验证证据——skill frontmatter 与目录一致、命令 symlink 指向源本、聚合层含 `spec-workflow` 与 7 个 `openspec-*`、README 两处更新、patch 白名单覆盖三家 provider；验证：逐项列出命令与输出摘要，缺项如实标注（如「重启后新会话才可见」）
