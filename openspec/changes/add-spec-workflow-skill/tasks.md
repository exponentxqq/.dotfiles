# Tasks

## 1. 文件落地

- [x] 1.1 新建命令薄壳 `dsh/commands/spec-flow.md`：按 design「命令文件设计」节写入 frontmatter（`description`、`argument-hint` 覆盖需求描述/continue/--parallel/--auto/--step-task/--step-group/--engine/--model）与正文（加载 spec-workflow skill、`$ARGUMENTS` 代入、未预置选项询问规则、空参数开放式询问、continue 语义）；**本次修正**：`description` 改为「固定工作流：独立双线规划→差异收敛→落档→子代理执行→归档提交（spec-workflow）」（原「探索→拷问」为被驳回的分工范式）；验证：文件存在、frontmatter 为合法 YAML 且仅含 description 与 argument-hint、description 含「独立双线规划」、正文包含 `$ARGUMENTS`
- [x] 1.2 新建阶段模型路由 `dsh/spec-workflow.yaml`：按 design「映射文件 schema」节写入 `models`（键 **lineA/lineB/panel/apply/verify**，默认空对象）、`engine: subagent`、`parallelism: 3`，并保留注释说明（白名单约束、命令行覆盖、五键含义）；验证：经 docker python 容器解析（**dsh 会话容器**的 `python3` 无 PyYAML，docker python 容器自带 6.0.3），断言 `models == {}`、`engine == 'subagent'`、`parallelism == 3`，且文件注释含五键名
- [x] 1.3 新建工作流本体 `agent/skills/spec-workflow/SKILL.md`：按 design「SKILL.md 设计」节写入 frontmatter 与全部十二个章节，正文简体中文；**第三轮修正要点（grill-me 接回阶段 1.5）**：两条规划线**不变**（异构方向、各自完整、互不可见），只把**阶段 1.5 的提问环节**改为加载并遵循 `grill-me` skill 的方法——(a) 把待决项（含规划线上浮项与复算后仍存的分歧）映射为**设计树**；(b) **只问前沿**：前置决策已定的问题才进本轮，依赖未决答案的留到后续轮次；(c) 每轮 ≤5 问、每题附推荐答案，措辞使「是 / 同意」即等于接受推荐；(d) 事实自行查证（读代码/规范/只读命令，必要时派只读子代理），**不向用户索取可查证的事实**；(e) 用户答完**重算前沿**再给下一轮；(f) 收敛结束条件 = 前沿为空或用户明确确认达成共识；同时保留本 workflow 既有的三分类（共识/分歧/单边遗漏）、自行裁定、第三线复算与 `diff-matrix.md` 留痕；验证：frontmatter `name` 等于目录名、十二节齐备、含「grill-me」「设计树」「前沿」「独立」「单边遗漏」「复算」「panel」「中转」「待决」「DELEGATED_CALLER」「send_message」「接续重派」「step-task」「白名单」关键词，且正文不把 A/B 写成「探索报告 + 问题清单」分工范式
- [x] 1.4 修改 `dsh/profiles/web/cordis.patch.yml`：按 design「profile patch 变更」节追加**单条**同 id 覆盖 `subagent-model-selection-settings`（`enabled: true` + 五条 `allowedModels`）；不写 `tool-subagent` 覆盖（实测该行已由 agent 预设层自带 `modelSelectionSettings: true`，profile 层只会落到被禁用的宿主行，见 design 已核实事实 10）；验证：`dsh --profile web --dump-config` 中该行显示 `enabled: true` 与五条白名单，且 `dsh --profile web --dump-config-schema` 的 error/warning 与基线逐条一致（不新增），YAML 解析通过
- [x] 1.5 修改 `agent/skills/README.md`：清单表补 `spec-workflow`（自写 local symlink）行；把 `openspec-*` 行描述修正为「已由 skctl 从 Fission-AI/OpenSpec 安装 core 6 + verify（openspec-verify-change）」；生效机制按实测口径写（即时可见、通常无需重启，`/commands-reload` 手动重扫，重启兜底——见 design 事实 14）；验证：表格含 `spec-workflow` 与 `openspec-verify-change` 字样，且无残留「需重启才可见」结论
- [x] 1.6 修改 `dsh/README.md`：新增「spec-workflow 固定工作流」章节，内容含入口（skill 与 `/spec-flow`）、参数面、**阶段 1 为两条方向不同且各自完整的独立规划线（非分工）、阶段 1.5 的共识/分歧/单边遗漏三分类 + 第三线复算 + 按 `grill-me` 设计树/前沿分轮提问**、**子代理↔用户交互中转（两档回送路径）**、双引擎与三模式、映射文件五键（lineA/lineB/panel/apply/verify）与白名单一致性要求、宿主操作（symlink、skctl 登记、`docker compose restart dsh`）；验证：章节标题存在、含 `/spec-flow`、`spec-workflow.yaml`、`restart dsh`、`lineA`、`panel`、`中转`、`grill-me` 关键词

## 2. 挂载与登记

- [x] 2.1 建立命令挂载：容器内 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-flow.md ~/.dsh/commands/spec-flow.md`；验证：`ls -l ~/.dsh/commands/spec-flow.md` 显示指向源本，且 `readlink -f` 命中源本
- [x] 2.2 登记 skill 到聚合层：经 node 容器执行 `node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install /home/xuqinqin/develop/dotfiles/agent/skills/spec-workflow`；验证：`skctl list --all` 输出包含 `spec-workflow`，且宿主聚合层 `ls -l` 出现指向源本的符号链接

## 3. 验证

- [ ] 3.1 变更校验：`openspec validate add-spec-workflow-skill --strict` 输出通过；验证：退出码 0 且输出含 valid/passed 语义（无 error/warning）
- [ ] 3.2 配置校验：经 docker python 容器解析 `dsh/spec-workflow.yaml` 与 `dsh/profiles/web/cordis.patch.yml` 成功（**dsh 会话容器**的 `python3` 无 PyYAML；docker python 容器自带 PyYAML 6.0.3；patch 文件含 `!!js` 标签，须先注册 `tag:yaml.org,2002:js` 多构造器再 `yaml.load`，裸 `safe_load` 必报 ConstructorError）；`dsh --profile web --dump-config` 中 `subagent-model-selection-settings` 行显示 `enabled: true` 与五条白名单；`dsh --profile web --dump-config-schema` 与开工前基线对比不新增 error/warning（基线本身 4 条既有 error、10 条 warning、退出码 1）；验证：YAML 解析脚本退出码 0，schema 输出与基线逐条一致
- [ ] 3.3 交付核对：汇总验证证据——skill frontmatter 与目录一致、命令 symlink 指向源本、聚合层含 `spec-workflow` 与 7 个 `openspec-*`、README 两处更新、patch 白名单覆盖三家 provider、**生效机制已实测（命令面板出现 `/spec-flow`、skill 可加载，无需重启）**；验证：逐项列出命令与输出摘要，缺项如实标注（如「需宿主侧操作」）
