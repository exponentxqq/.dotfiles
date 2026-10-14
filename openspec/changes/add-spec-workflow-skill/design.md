# Design

## 背景与已核实事实

以下事实在规划阶段逐条核实，是实现的依据：

1. **skill 承载机制**：dsh 只扫描容器内 `~/.agents/skills`（只读挂载宿主 skctl 聚合层 `/home/xuqinqin/.local/share/agent-skills/skills`）。自写 skill 实体放 `dotfiles/agent/skills/<name>/`，经 `skctl install`（local 源 = symlink 登记）进入聚合层；宿主变更后需重启 dsh 容器才能被会话发现（inotify 不跨挂载边界）。
2. **命令承载机制**：`user-commands` 插件三层命令——内置、用户级 `$DSH_HOME/commands/`（容器 `~/.dsh/commands`，落盘宿主 `/data/dsh/commands`）、项目级 `<根>/.dsh/commands/`。命令文件为 `<name>.md`，仅取一层，`.md` 平铺；frontmatter 只认 `description` / `argument-hint`；正文 `$ARGUMENTS` 全部替换为调用参数；注册需重启，正文现读不缓存。
3. **symlink 可用**：命令发现用 `readdir(withFileTypes)`，symlink 条目的 `isDirectory()` 为 false，不会被子目录过滤；`.md` 后缀与 `readFile` 跟随链接均通过，故命令源本可留在 git 仓库、`/data/dsh/commands/` 放 symlink。symlink 目标写成容器与宿主都有效的同一绝对路径（`/home/xuqinqin/develop/dotfiles/...`）。
4. **tasks 分组惯例**：spec-driven 的 `tasks.md` 天然是 `## N. 组名` + `- [ ] N.M 描述 + 验证句` 结构；本仓库与 dsh-plugins 的历史变更均如此。执行批次契约直接沿用。
5. **模型选择机制**：`tool-subagent` 的 `modelSelectionSettings`（默认 false）控制新会话的 subagent 工具是否暴露 provider/model/reasoning_effort 字段；`subagent-model-selection-settings`（服务 `subagentModelSelection`，由 dsh-web-app 的 patch 行挂载、默认 `enabled: false` 且 `allowedModels: []`）提供 enabled 与白名单；开启要求白名单非空；显式选择的路由必须在白名单内，未指定则继承。
6. **fork 不参与模型选择**：`tool-subagent-fork` 明确省略模型选择以保持 provider/model 与父会话一致（KV cache 复用）。故阶段级模型路由只对 fresh 子代理生效。
7. **Agent Teams 限制**：teammate 创建工具无模型参数（`freshProvider`/`forkProvider` 仅决定子代理提供方），fork teammate 锁定 Lead 模型。故 team 引擎下阶段级模型路由不适用。
8. **openspec skills 状态**：仓库文档声称 7 个 `openspec-*` 已装入聚合层，核实为从未登记；本变更已用 skctl 从 `Fission-AI/OpenSpec` 的 `skills/<name>` 补装（apply-change / archive-change / explore / propose / sync-specs / update-change / verify-change），需重启 dsh 后对新会话可见。
9. **可用模型路由**：`zai`（glm-4.7 / glm-5.2 / glm-5.3 / glm-5.3-flash / glm-5.3-highspeed / glm-5-turbo）、`opencode-go`（deepseek-v4.1-flash / deepseek-v4-pro / glm-5.3 / kimi-k3 / grok-4.7 等）、`deepseek-official`（deepseek-flash / deepseek-v4-pro）。

## 交付物与文件布局

| 文件 | 性质 | 说明 |
| --- | --- | --- |
| `agent/skills/spec-workflow/SKILL.md` | 新增 | 工作流本体（章节设计见下） |
| `dsh/commands/spec-flow.md` | 新增 | 命令薄壳（正文见下） |
| `dsh/spec-workflow.yaml` | 新增 | 阶段模型路由与引擎偏好 |
| `dsh/profiles/web/cordis.patch.yml` | 修改 | 开启模型选择与白名单 |
| `agent/skills/README.md` | 修改 | 清单表补 spec-workflow；修正 openspec-* 行描述 |
| `dsh/README.md` | 修改 | 新增「spec-workflow 固定工作流」章节 |
| 宿主 `/data/dsh/commands/spec-flow.md` | 新增 | symlink 指向命令源本 |

## SKILL.md 设计

Frontmatter：

```yaml
---
name: spec-workflow
description: 固定 spec 驱动开发工作流——需求探索与拷问、OpenSpec 落档、子代理执行、验证归档提交一体化。Use when 用户要"走 spec 工作流/固定工作流/spec-flow"，或要求从需求一路做到归档提交且执行交由 subagent；也用于接续未完成的 OpenSpec 变更。
---
```

正文章节（全部简体中文）：

1. **总览**：五阶段流程图与状态载体说明（工件即状态），承诺：阶段边界简短汇报、规划外 scope 变化回到用户。
2. **前置检查**：`openspec list --json` 确认根；无根时按显式/自动两种来源问询（init、store、放弃），绝不副作用创建；解析调用参数（需求 / continue / --parallel / --auto|--step-task|--step-group / --engine / --model）。
3. **模式收集**：未预置选项在对应阶段开始前用问题工具询问；一次只问该阶段需要的。
4. **阶段 1 双线调研**：串行（主会话依次加载 `openspec-explore` 与 `grill-me`）；并行（两个 fresh subagent，提示自包含：项目路径、需求、产物路径 `/tmp/spec-flow/<change>/explore.md` 与 `grill.md`；A 按 explore 立场做只读调研，B 按 grill-me 的设计树方法产出问题清单与推荐答案，均不得写项目文件、不得与用户交互）。
5. **阶段 1.5 问题收敛**：主会话按轮呈现（≤5 问/轮、附推荐答案、答完再下一轮）；串行模式跳过。
6. **阶段 2 落档**：加载 `openspec-propose`；综合双线材料与用户回答生成工件；`tasks.md` 按执行批次契约编写（`## N.` 组内任务独立、组间有序、每任务带验证句，验证句要能被核对）；分歧点提问；`openspec validate <change> --strict`；**规划边界：落档即停**，展示摘要后提交落档工件（提交信息 `docs(openspec): 落档 <change>` 或仓库惯例）。
7. **衔接与恢复协议**：询问执行模式（auto / step-task / step-group / 暂不执行），确认引擎（映射文件或参数，缺省 subagent）；提示「如需切换主会话模型请现在切换，并可 /compact 压缩上下文，然后说继续」；恢复协议：任何时刻（新轮次、压缩后、重启后）先从 `openspec status <change> --json` + `tasks.md` 勾选态重建进度，不重复已完成任务。
8. **阶段 3 执行**：批次循环——取当前未完成的最小编号组；subagent 引擎：为组内每个任务派 fresh subagent（提示含任务原文、相关 spec/design 摘要、验证句、写范围；模型按路由取），组内并行、组间串行；team 引擎：把组内任务发布到共享任务板（含写范围），spawn ≤任务数的 implementer 成员认领，消息传达任务提示，等其完成。两引擎共同：主会话以验证句 + diff 核对后勾选 `tasks.md` checkbox；auto 连续推进（硬停：不可逆操作、安全敏感、工作区外副作用、计划彻底失效）；step-task 每任务、step-group 每组停留，展示变更摘要等用户确认；step 每批次过审提交一次（提交信息含批次号），auto 全部完成后提交一次；任务失败重试一次仍败则暂停报告。
9. **阶段 4 验证与归档**：跑目标项目声明的验证（读目标项目 AGENTS/CLAUDE；可派 subagent 执行并把输出摘要回传）；通过后加载 `openspec-archive-change` 执行归档；归档单独提交一次；最终汇报（变更、验证证据、归档位置、后续宿主操作）。
10. **接续流程**：`continue <change>` 时跳过调研与落档（除非用户要求重跑），从任务完成度续跑，执行模式与引擎重选一次。
11. **模型路由**：读取 `dsh/spec-workflow.yaml`（路径优先级：命令行参数 > 映射文件 > 继承）；映射键 explore / grill / apply / verify；team 引擎忽略 apply 键；白名单外路由报错时应报告并回退继承。
12. **边界与失败**：无 openspec 根、命令未注册、skill 未生效（提示重启与 skctl）、用户中断、审核被拒（修正后重审，不勾选）。

## 命令文件设计

```markdown
---
description: 固定工作流：探索→拷问→落档→子代理执行→归档提交（spec-workflow）
argument-hint: "[需求描述 | continue <变更名>] [--parallel] [--auto|--step-task|--step-group] [--engine team] [--model <阶段>=<provider>/<模型>]"
---
加载 spec-workflow skill，并按其固定工作流执行。

调用参数：$ARGUMENTS

规则：
- 已预置的选项按参数执行；未预置的在对应阶段开始前向我询问，不要自行假设。
- 参数为空或未含需求描述时，先开放式询问我要做什么。
- 参数中 `continue <变更名>` 表示接续该未完成变更。
```

## 映射文件 schema（`dsh/spec-workflow.yaml`）

```yaml
# spec-workflow 阶段级模型路由
# 键：explore（探索线）| grill（拷问线）| apply（执行任务）| verify（归档前验证）
# 值：{ provider, model }；留空或注释掉 = 继承会话模型
# 显式路由必须已在 profile 的 subagent-model-selection 白名单内
# 命令参数 --model <阶段>=<provider>/<模型> 可临时覆盖本文件
models: {}
# models:
#   explore: { provider: zai, model: glm-5.3 }
#   grill:   { provider: zai, model: glm-5.3 }
#   apply:   { provider: opencode-go, model: deepseek-v4.1-flash }
#   verify:  { provider: zai, model: glm-5.3-flash }

# 执行引擎偏好（可被 --engine 覆盖）：subagent | team
engine: subagent

# 同组并行上限
parallelism: 3
```

## profile patch 变更（`dsh/profiles/web/cordis.patch.yml`）

追加两条覆盖（同 id 覆盖既有 loader）：

```yaml
- id: tool-subagent
  config:
    modelSelectionSettings: true
- id: subagent-model-selection-settings
  config:
    enabled: true
    allowedModels:
      - { provider: zai, model: glm-5.3 }
      - { provider: zai, model: glm-5.3-flash }
      - { provider: opencode-go, model: deepseek-v4.1-flash }
      - { provider: opencode-go, model: deepseek-v4-pro }
      - { provider: deepseek-official, model: deepseek-flash }
```

白名单覆盖三家 provider 的常用路由，具体条目在落档摘要中由用户确认；映射文件里的路由必须始终是本列表子集（写入 README 注意事项）。

## 安装与生效

1. 命令 symlink（容器内创建，落盘宿主 `/data/dsh/commands/`）：
   `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-flow.md ~/.dsh/commands/spec-flow.md`
2. 登记新 skill（宿主/经 node 容器）：`node ~/develop/dotfiles/tools/skctl/src/cli.ts install ~/develop/dotfiles/agent/skills/spec-workflow`
3. 重启使命令注册、skill 与新设置生效：`cd ~/develop/docker && docker compose restart dsh`
4. 校验：`dsh --profile web --dump-config-schema`（确认 patch 可加载）；重启后命令菜单出现 `/spec-flow`、skill 列表出现 `spec-workflow`、subagent 工具出现模型字段。

## 验证方式

- `openspec validate add-spec-workflow-skill --strict` 通过
- `dsh --profile web --dump-config-schema` 通过（patch 语法与插件加载）
- YAML 语法：`python3 -c "import yaml,sys;yaml.safe_load(open('dsh/spec-workflow.yaml'))"`
- SKILL.md frontmatter 含 name/description 且 name 与目录名一致
- 命令文件 frontmatter 合法、正文含 `$ARGUMENTS`
- 宿主侧核对：`ls -l /data/dsh/commands/spec-flow.md` 指向源本；聚合层出现 `spec-workflow` 与 7 个 `openspec-*`

## 风险与回退

- team 引擎依赖实验性 Agent Teams：默认关闭，仅 `--engine team` 或映射文件显式启用；成员创建失败降级 subagent。
- 模型白名单与映射文件漂移：两者在同一变更内提交，README 写明一致性要求。
- symlink 命令万一未被识别：改为拷贝文件并在 README 记录同步命令（已知实现为 readdir+readFile，风险低）。
- 重启前新 skill/命令对新会话不可见：README 与汇报中明确列出重启步骤。
