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
10. **阶段级模型路由的真实开关（落档后实测修正）**：`tool-subagent.config.modelSelectionSettings` 已由 agent 预设层自带 `true`（`dsh-web-app/presets/cordis.patch.yml`、`standard.patch.yml`、`ptc.patch.yml` 的 `config.plugins` 中 `- id: tool-subagent`），web-app 顶层 patch 把宿主行的 `tool-subagent` 置为 `disabled: true`；用 `dsh --profile web --patch <探针> --dump-config` 实测，profile 层写 `- id: tool-subagent / config.modelSelectionSettings: true` 只落到那条**被禁用的宿主行**（预设行配置原样不变），即无效。故 profile 补丁只需覆盖 `subagent-model-selection-settings`（`enabled: true` + 非空 `allowedModels`；两字段为 schemastery `.volatile()`——volatile 盒子由配置值播种，配置层可写）。当前会话的 `subagent` 工具确实没有模型字段，与 `enabled` 默认 `false` 一致。
11. **`--dump-config-schema` 基线并非通过**：`dsh --profile web --dump-config-schema` 在本变更开工**之前**就以退出码 1 结束，stderr 含 4 条既有 `unrecognized Loader tree carrier`（`[/179]`–`[/182]`）与 10 条既有 warning。故验证门只能取「**不新增 error/warning**（与基线逐条对比）」，不能要求退出码 0。
12. **`--patch` 探针通道**：`dsh --profile web --patch <file> --dump-config` 可在**不改动** `profiles/web/cordis.patch.yml` 的前提下验证补丁合并结果（叠加在 profile 层之后），用于避免运行中 HMR 重载带来的风险。
13. **子代理与用户交互的边界与中转路径（本轮源码核实 + 实测）**：`dsh-user-questions` 的 `assertLiveRoot`（`lib/index.js:531-535`）对归属于其他存活 agent 的子级抛 `DELEGATED_CALLER`；`dsh-tool-ask-user/README.zh.md` 第 12/74/158 行同述「存活的子 agent 不能调用此工具，必须在最终结果中包含尚未解决的决定」。即 **subagent 与 teammate 都不能直接向用户提问**。回送路径实测：`send_message` **无法寻址 tool-subagent 的子代理**——对运行中的子代理与已结束的子代理两种目标均报 `active teammate "…" not found`，它只寻址 `spawn_teammate` 建立的具名队友（web profile 预设的 `tool-subagent` 为 `backgroundMode: continuable`，但其续跑通道不经 `send_message` 暴露）。故中转分两档：**team 引擎**用 `send_message` 回送同一成员（保留上下文、可多轮）；**subagent 引擎**把上一轮回执摘要 + 用户答复并入新提示**接续重派**（上下文重建）。

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
description: 固定 spec 驱动开发工作流——两条方向不同的独立规划线与差异复算、OpenSpec 落档、子代理执行、验证归档提交一体化。Use when 用户要"走 spec 工作流/固定工作流/spec-flow"，或要求从需求一路做到归档提交且执行交由 subagent；也用于接续未完成的 OpenSpec 变更。
---
```

正文章节（全部简体中文）：

1. **总览**：五阶段流程图与状态载体说明（工件即状态），承诺：阶段边界简短汇报、规划外 scope 变化回到用户。
2. **前置检查**：`openspec list --json` 确认根；无根时按显式/自动两种来源问询（init、store、放弃），绝不副作用创建；解析调用参数（需求 / continue / --parallel / --auto|--step-task|--step-group / --engine / --model）；能力自检须覆盖 `openspec-*`（propose/archive 等）与阶段 1.5 问答所需的 `grill-me`。
3. **模式收集**：未预置选项在对应阶段开始前用问题工具询问；一次只问该阶段需要的。
4. **阶段 1 独立双线规划（异构视角，非分工）**：A 线方向 = 需求与价值、范围与边界；B 线方向 = 实现与约束、反例与风险。两线各自产出**同一套字段的完整轻量规划草案**（目标与非目标、范围与边界、方案与取舍、任务拆分草案、验证思路、风险与未知项、假设清单），**互不读取对方产物、不共享中间结论**；并行 = 同批派发两个 fresh subagent，提示自包含（项目路径、需求原文、本条线的方向与字段清单、产物路径 `/tmp/spec-flow/<change>/line-a.md` 与 `line-b.md`、硬约束：只写自己的产物、不写项目文件；**需用户拍板的决策不得自行假设**——写入产物「待决问题」节并在回执中上浮，由主会话代问后接续推进，见「已核实事实」第 13 条）；串行 = 主会话先独立完成并落盘 A 线，再在**不回看 A 线结论**的前提下完成 B 线，并在阶段摘要中标注其独立性弱于并行。
5. **阶段 1.5 差异收敛与分歧复算**：交叉比对两份草案，归类为共识 / 分歧 / 单边遗漏（单边项逐项核验，**不因只有一条线提出而丢弃**）；可从代码、规范、只读命令查证的分歧由主会话自行查证裁定并记录依据（必要时派只读子代理），**不问用户**；影响方案走向且无法查证的分歧派**第三条独立子代理**（`panel` 键；不以任何既有草案为输入，只回传判断与理由）复算，三线对照形成结论与置信说明；规划线上浮的待决问题并入前沿一起处理；**剩余决策项的提问环节加载并遵循 `grill-me` skill 的方法**——把待决项映射为设计树、只问前置已定的**前沿**问题、每轮 ≤5 问且每题附推荐答案（措辞使「是 / 同意」即接受推荐）、事实自行查证不向用户索取、答完**重算前沿**再给下一轮、前沿为空或用户确认达成共识才算收敛结束；裁定依据、复算结论与未答项写入 `/tmp/spec-flow/<change>/diff-matrix.md`（未答项另入 design 未决节）。
6. **阶段 2 落档**：加载 `openspec-propose`；综合双线材料与用户回答生成工件；`tasks.md` 按执行批次契约编写（`## N.` 组内任务独立、组间有序、每任务带验证句，验证句要能被核对）；分歧点提问；`openspec validate <change> --strict`；**规划边界：落档即停**，展示摘要后提交落档工件（提交信息 `docs(openspec): 落档 <change>` 或仓库惯例）。
7. **衔接与恢复协议**：询问执行模式（auto / step-task / step-group / 暂不执行），确认引擎（映射文件或参数，缺省 subagent）；提示「如需切换主会话模型请现在切换，并可 /compact 压缩上下文，然后说继续」；恢复协议：任何时刻（新轮次、压缩后、重启后）先从 `openspec status --change <change> --json`（该 CLI 的 `status` 不接受位置参数，裸 `--json` 报 `Missing required option --change`；兜底 `openspec status --all --json` / `openspec list --json`）+ `tasks.md` 勾选态重建进度，不重复已完成任务。
8. **阶段 3 执行**：批次循环——取当前未完成的最小编号组；subagent 引擎：为组内每个任务派 fresh subagent（提示含任务原文、相关 spec/design 摘要、验证句、写范围；模型按路由取），组内并行、组间串行；team 引擎：把组内任务发布到共享任务板（含写范围），spawn ≤任务数的 implementer 成员认领，消息传达任务提示，等其完成。**两引擎的交互中转**（见「已核实事实」第 13 条）：子代理/成员的待决问题上浮 → 主会话代问用户 → team 引擎用 `send_message` 回送同一成员（上下文保留、可多轮）、subagent 引擎把上一轮回执摘要 + 用户答复并入新提示接续重派。两引擎共同：主会话以验证句 + diff 核对后勾选 `tasks.md` checkbox；auto 连续推进（硬停：不可逆操作、安全敏感、工作区外副作用、计划彻底失效）；step-task 每任务、step-group 每组停留，展示变更摘要等用户确认；step 每批次过审提交一次（提交信息含批次号），auto 全部完成后提交一次；任务失败重试一次仍败则暂停报告。
9. **阶段 4 验证与归档**：跑目标项目声明的验证（读目标项目 AGENTS/CLAUDE；可派 subagent 执行并把输出摘要回传）；通过后加载 `openspec-archive-change` 执行归档；归档单独提交一次；最终汇报（变更、验证证据、归档位置、后续宿主操作）。
10. **接续流程**：`continue <change>` 时跳过调研与落档（除非用户要求重跑），从任务完成度续跑，执行模式与引擎重选一次。
11. **模型路由**：读取 `dsh/spec-workflow.yaml`（路径优先级：命令行参数 > 映射文件 > 继承）；映射键 lineA / lineB / panel / apply / verify（A 线、B 线、分歧复算线、执行任务、归档前验证）；team 引擎忽略 apply 键；白名单外路由报错时应报告并回退继承。
12. **边界与失败**：无 openspec 根、命令未注册、skill 未生效（提示重启与 skctl）、用户中断、审核被拒（修正后重审，不勾选）。

## 命令文件设计

```markdown
---
description: 固定工作流：独立双线规划→差异收敛→落档→子代理执行→归档提交（spec-workflow）
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
# 键：lineA（A 规划线：需求/价值/范围）| lineB（B 规划线：实现/约束/风险）
#     panel（分歧复算线，仅分歧时派发）| apply（执行任务）| verify（归档前验证）
# 值：{ provider, model }；留空或注释掉 = 继承会话模型
# 显式路由必须已在 profile 的 subagent-model-selection 白名单内
# 命令参数 --model <阶段>=<provider>/<模型> 可临时覆盖本文件
models: {}
# models:
#   lineA:  { provider: zai, model: glm-5.3 }
#   lineB:  { provider: zai, model: glm-5.3 }
#   panel:  { provider: zai, model: glm-5.3-flash }
#   apply:  { provider: opencode-go, model: deepseek-v4.1-flash }
#   verify: { provider: zai, model: glm-5.3-flash }

# 执行引擎偏好（可被 --engine 覆盖）：subagent | team
engine: subagent

# 同组并行上限
parallelism: 3
```

## profile patch 变更（`dsh/profiles/web/cordis.patch.yml`）

追加**一条**同 id 覆盖（依据「已核实事实」第 10 条：`tool-subagent` 的 `modelSelectionSettings` 已由预设层自带，profile 层无需也不应再写）：

```yaml
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
4. 校验：`dsh --profile web --dump-config`（确认 `subagent-model-selection-settings` 已 `enabled: true` 且白名单五条齐备）与 `dsh --profile web --dump-config-schema`（对比基线，不新增 error）；重启后命令菜单出现 `/spec-flow`、skill 列表出现 `spec-workflow`、subagent 工具出现模型字段。

## 验证方式

- `openspec validate add-spec-workflow-skill --strict` 通过
- patch 生效核对用 `dsh --profile web --dump-config`：`subagent-model-selection-settings` 行出现 `enabled: true` 与五条 `allowedModels`；`dsh --profile web --dump-config-schema` 的 error/warning **与基线逐条一致（不新增）**——基线本身退出码 1，见「已核实事实」第 11 条
- YAML 语法：容器内 `python3` 无 PyYAML，经 docker python 容器执行 `/home/xuqinqin/develop/docker/run.sh python "python3 -c \"import yaml;yaml.safe_load(open('...'))\""`；**patch 文件例外**——它含 `!!js` 标签，必须注册 `tag:yaml.org,2002:js` 的多构造器后用 `yaml.load`（裸 `safe_load` 会报 `ConstructorError: could not determine a constructor for the tag 'tag:yaml.org,2002:js'`）
- SKILL.md frontmatter 含 name/description 且 name 与目录名一致
- 命令文件 frontmatter 合法、正文含 `$ARGUMENTS`
- 宿主侧核对：`ls -l /data/dsh/commands/spec-flow.md` 指向源本；聚合层出现 `spec-workflow` 与 7 个 `openspec-*`

## 风险与回退

- team 引擎依赖实验性 Agent Teams：默认关闭，仅 `--engine team` 或映射文件显式启用；成员创建失败降级 subagent。
- 模型白名单与映射文件漂移：两者在同一变更内提交，README 写明一致性要求。
- symlink 命令万一未被识别：改为拷贝文件并在 README 记录同步命令（已知实现为 readdir+readFile，风险低）。
- 重启前新 skill/命令对新会话不可见：README 与汇报中明确列出重启步骤。
