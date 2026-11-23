# 代码级设计（阶段 1.7）——add-ui-demo-gate：界面演示 gate（1.75）与 skill `ui-demo`

- 变更名：`add-ui-demo-gate`；**触达仓 = dotfiles 根仓（唯一）**（本次变更不触达 docker 仓、dsh-plugins 仓、容器本地文件）
- 产物线：代码设计线。上游 = `explore.md`（阶段 1 串行草案）+ `decisions.md`（阶段 1.5 六项裁定，**硬边界，本文不推翻、不重开**）；发现与留痕矛盾按二行为约束上浮「待决问题」节
- 约束源：**`writing-skills` 已成功加载**（`/home/docker/.agents/skills/writing-skills/SKILL.md`，含 `anthropic-best-practices.md` / `testing-skills-with-subagents.md`）。其硬约束在本设计中的落点：①frontmatter ≤1024 字符、`name`+`description` 必填；②description 只写**触发条件**、**不得概述流程**（SDO，否则 agent 照 description 抄近路跳过正文）；③Iron Law「NO SKILL WITHOUT A FAILING TEST FIRST」→ RED 基线压测前置于写作（触发本文 ⑤ 组 1）；④按消费时机外移重参考、入口保骨架（触发 `refs/html-recipe.md` 拆分）；⑤行为塑形用 recipe/契约、纪律条款用「禁止+合理化表」（触发判定表与反例节形态）；⑥Match the Form to the Failure：本 skill 的基线失败类型是「漏判/跳过确认」= 纪律型 → 用禁止式铁律；「演示页信息缺项」= 形状型 → 用元素清单 recipe，不用禁止清单
- 日期：2026-11-05。所有 file:line 与码点均为本轮实测；openspec CLI 实测版本 `1.16.0`（`openspec --version`）

**实测基线（预算与阈值的事实来源）**

| 载体 | 现状 | 硬阈值 | 来源 |
| --- | --- | --- | --- |
| `agent/skills/spec-plan/SKILL.md` | **7338 码点 / 118 行** | 8192（渲染后 ≈7830 目标线） | `python3 -c "print(len(open(...).read()))"` 实测；阈值见 `openspec/changes/archive/2026-10-14-spec-workflow-externalize-references/execution-log.md:72`（pruner `thresholdChars 8192 / head 4096 / tail 1024`） |
| `agent/skills/spec-plan/refs/planning.md` | **6111 码点 / 72 行** | 同上（单文件单次读取不被裁剪） | 实测 |
| `agent/skills/spec-workflow/SKILL.md` | **6314 码点 / 99 行** | 同上 | 实测 |
| `agent/skills/README.md` | 2805 码点，清单表 `:29-35` | — | 实测 |

---

## ① 触达面清单

> 编号即 `tasks.md` 任务描述要引用的「触达#N」。全部路径相对 `/home/xuqinqin/develop/dotfiles`（除非另注）。**仓 = dotfiles 根仓**。

| # | 路径 | 仓 | 新建/修改 | 改动意图 | 关键改动点（节/行级锚） |
| --- | --- | --- | --- | --- | --- |
| 1 | `agent/skills/ui-demo/SKILL.md` | dotfiles | **新建** | 界面演示的唯一权威源（判定/分级/产物/自检/三处接线） | frontmatter 仅 `name`+`description` 两键，description 载强触发词（本文 ③3.1）；正文 8 节骨架（③3.2）；判定表落在前 2000 码点内；≤6000 码点 |
| 2 | `agent/skills/ui-demo/refs/html-recipe.md` | dotfiles | **新建** | 重参考：自包含 HTML 骨架 + L1/L2/L3 元素清单 + 自检清单 | 只在「写演示页」时按需读；≤7000 码点；零外链、零 base64 大图纪律的施工形态 |
| 3 | `agent/skills/spec-plan/SKILL.md` | dotfiles | 修改 | 硬 gate 接线：总览流水线 + 新节骨架 | `:15-18` 流水线三行改写（③3.7-A）；`:92` §六 标题改「代码设计（1.7）与界面演示 gate（1.75）」（③3.7-B）；`:94` 段后插 `### 阶段 1.75 界面演示 gate` 子节（③3.7-C，逐字，275 码点）；`:41` 消费时机行补「1.75」（③3.7-D）。**不重编号 §七/§八/§九** |
| 4 | `agent/skills/spec-plan/refs/planning.md` | dotfiles | 修改 | 1.75 展开细则外移 + 落档复制清单扩 `demos/` + 机械断言加条件项 | `:1` 文件头外移正文清单加「阶段 1.75」（③3.8-A）；`:52｜53` 之间插入 `## 附：阶段 1.75 界面演示 gate`（③3.8-B，858 码点）；`:58` 复制清单末追加一句（③3.8-C）；`:68` 断言段加条件项（③3.8-D） |
| 5 | `agent/skills/spec-workflow/SKILL.md` | dotfiles | 修改 | 编排侧可见性：流水线含 1.75、状态载体含 `demos/` | `:15-16` 流水线两行改写（③3.9-A）；`:19` 状态载体段末追加一句（③3.9-B，56 码点）。**`:55` 落档后「核对两件事」不动**（保持零扩散，见 ④D11） |
| 6 | `agent/skills/README.md` | dotfiles | 修改 | 自写 skill 清单登记（未登记 = 两个 agent 都看不到） | `:35` 后追加一行 `` \| `ui-demo` \| 自写（本目录 local symlink） \| ``（③3.12） |
| 7 | `openspec/changes/add-ui-demo-gate/proposal.md` | dotfiles | **新建**（阶段 2 落档生成） | 变更动机与范围 | `## Why` **必须 50–1000 字符**（`change.schema.js:19-20` zod `.min/.max`），实测 14 个归档提案有 2 个超限（1094/1073 字符）——**不照抄**；`## What Changes` 非空；`## Capabilities` 三段（New/Modified） |
| 8 | `openspec/changes/add-ui-demo-gate/specs/ui-demo/spec.md` | dotfiles | **新建**（New capability delta） | 新能力 5 条 Requirement | `## Purpose`（≥50 字符，归档时作为新主规格 Purpose）+ `## ADDED Requirements` ×5（③3.10-A） |
| 9 | `openspec/changes/add-ui-demo-gate/specs/spec-plan/spec.md` | dotfiles | **新建**（delta） | ADDED 1.75 gate + MODIFIED 落档契约 | `## ADDED Requirements` ×1 + `## MODIFIED Requirements` ×1（**整块携带主规格 `:130-173` 的 9 个 scenario**，③3.10-B） |
| 10 | `openspec/changes/add-ui-demo-gate/specs/spec-workflow/spec.md` | dotfiles | **新建**（delta） | MODIFIED 固定工作流入口 | `## MODIFIED Requirements` ×1（**整块携带主规格 `:13-26` 的 3 个 scenario**，③3.10-C） |
| 11 | `openspec/changes/add-ui-demo-gate/design.md`、`tasks.md` | dotfiles | **新建**（阶段 2 落档生成） | 设计承载 + 执行批次契约 | `design.md` 逐断言承载本文六字段 + 决策记录含**栈识别结论**（Q6 裁定：`writing-skills`，证据 = 本文件头）与**1.75 判定行**；`tasks.md` 按 ⑤ 五组编号（`## N.` + `- [ ] N.M`，编号与组号必须一致，`task-numbering.js:4-5`） |
| 12 | `openspec/changes/add-ui-demo-gate/code-design.md`、`decisions.md` | dotfiles | **新建**（阶段 2 复制入） | 两份规划材料落档副本 | 由 `planning.md:58` 既有规则复制；**落档副本自此为权威** |
| 13 | （明示非触达）`openspec/specs/spec-plan/spec.md`、`openspec/specs/spec-workflow/spec.md` | dotfiles | **不改** | 主规格只由 `openspec archive` 经 delta 同步 | 归档后 `spec-plan` 仍有 2 条既存超长告警（`requirements[4]`=518 字符、`requirements[5]`=502 字符，实测 `openspec validate --all` 输出）——**本变更不新增、也不承担修复** |
| 14 | （明示非触达）`dsh/spec-workflow.yaml` | dotfiles | **零改动** | Q5 裁定：不加 `demo` 键 | 键集合与 routing 白名单不动；1.75 不派子代理故无路由需求 |
| 15 | （明示非触达）docker 仓 nginx conf / `dsh/commands/ui-demo.md` / `~/.dsh/AGENTS.md` | — | **出局** | Q1「全部不做」+ Q3「先不要 nginx」 | 触达面仅本仓；nginx 只在 skill 内留一句「未来统一入口预留位」 |
| 16 | `~/.local/share/agent-skills/skills/ui-demo`（symlink）与 `registry.json` | **机器态**（dotfiles 仓外，宿主聚合层） | `skctl install` 产生 | 分发登记；不登记则 dsh/opencode 均不可见 | `install.ts:92-93` 本地源走 `symlinkSync`；`registry.json` 追加 `source.type=local`；**不入库** |

---

## ② 证据锚

**A. dotfiles · spec-plan 手册（硬 gate 的插入点）**

- `agent/skills/spec-plan/SKILL.md:15-18`——三行流水线块，阶段列 `阶段1 → 阶段1.5 → 阶段1.7 → 阶段2`，第二行是产物列（`code-design.md` / `四件套+两规划材料`）→ 1.75 必须同时进阶段列与产物列，否则总览与实际节律不符
- 同名 `:22`——「**状态载体 = 工件**：`/tmp/spec-flow/<change>/` 规划材料易失、不入库；**唯一例外——`code-design.md` 与 `diff-matrix.md`（串行 `decisions.md`）随落档复制入 `openspec/changes/<change>/`」→ `demos/` 是**第二个例外**，但归属由本文 ③3.8-C 在 planning.md 一处定义（**不在 SKILL.md 再加一句，保码点**，见 ④D8）
- 同名 `:34-42`——「展开内容按消费时机外移」表，`:41` 行 = `阶段 1.7 / 落档 | [planning.md] —— 前置检查展开、设计契约、落档细节`
- 同名 `:92-94`——`## 六、代码设计（阶段 1.7）` 标题 + 单段正文（恒派 fresh 子代理、六字段、三档分降、栈识别）；`:96-100`——`## 七、落档（阶段 2）`：`:98` 输入三件套、`:100` 八步（④ = 两材料 `test -f` + `openspec validate --strict` 退出码 0）
- 同名 `:116`——§九 红线表「设计草案与收敛结论矛盾 → 上浮待决并入落档分歧点提问，**不重开收敛**（第六节）」→ 本文不重开收敛的落点

**B. dotfiles · planning.md（复制与断言的唯一着力点）**

- `agent/skills/spec-plan/refs/planning.md:1`——外移正文清单「§二、§六（代码设计环节）与 §七（落档细节）」→ 加 1.75 必须同步本行，否则读者按头行找不到 1.75 的正文
- 同名 `:16` `## 附：代码设计环节（阶段 1.7）`、`:54` `## 附：落档细节（自 SKILL.md §七 外移）`——**两附节之间即 1.75 附节的插入位**（体例照抄：「## 附：X（自 SKILL.md §X 外移）」+ `**消费时机**` 开头）
- 同名 `:58`——落档第 1 步逐字：「**随后把 `/tmp/spec-flow/<change>/code-design.md` 与 `diff-matrix.md`（串行 `decisions.md`）复制入 `openspec/changes/<change>/`**——**落档副本自此为权威**……（`explore.md`/`line-a.md`/`line-b.md` 不入库）」→ `demos/` 属**生成物而非规划材料**，必须单独一句，不能塞进这句的括号里
- 同名 `:59-66`——第 2 步 `tasks.md` 执行批次契约（`## N.` 组 = 执行审核批次、组间串行、组内可并行、单组 ≤ `parallelism`、每任务引用触达条目编号）
- 同名 `:68`——第 4 步「**校验（两段式）**：先机械断言两份落档材料已在变更目录——`test -f …code-design.md` 与 `test -f …diff-matrix.md`（串行 `decisions.md`）……；再跑 `openspec validate <change> --strict`，必须退出码 0 且无 error/warning」→ 断言句式照抄此体例，`demos/` 断言必须是**条件项**（未触发时目录不存在）
- 同名 `:70`——第 6 步摘要字段（含「触达仓清单」）→ 1.75 触发时摘要需补演示路径

**C. dotfiles · spec-workflow 手册**

- `agent/skills/spec-workflow/SKILL.md:14-17`——四段流水线块（两行，阶段名 `阶段1 独立双线规划 → … → 阶段2 落档（spec-plan 承载，至落档提交）` / `→ 衔接 … → 阶段3 … → 阶段4 …`）
- 同名 `:19`——「**状态载体 = 工件**：权威进度 = 工件 + `tasks.md` 勾选态 + `git log`（**三方对齐**）…… 工件跨界所有权：`code-design.md`/`diff-matrix.md`（串行 `decisions.md`）由 spec-plan 产出并**随落档提交至变更目录**，执行期由本 skill 维护**落档副本**（组段终形态化，见第六节；`/tmp` 侧原件落档后不再维护）」→ `demos/` 需在此定权属（随落档提交、执行期只读）
- 同名 `:66`——恢复协议第 4 步「落档副本存在性检查」→ **不改**：`demos/` 缺少不构成执行阻塞（只读参考物），改它会扩散到恢复语义（④D11 记录被否方案）

**D. dotfiles · 主规格（delta 的 MODIFIED 基线）**

- `openspec/specs/spec-plan/spec.md:126`——`### Requirement: 落档工件与执行批次契约`（正文 518 字符，**:130-173 共 9 个 scenario**：分组内任务并行执行 / 分组间串行 / 组内单任务合法 / design 继承设计草案深度 / 任务引用触达面条目 / 落档含规划材料 / 落档校验断言材料存在 / 执行期维护落档副本 / 落档摘要含触达仓清单）
- 同名 `:73`——`### Requirement: 阶段 1.7 代码设计线`（388 字符，**本变更不改**：1.75 判定留痕落在 `code-design.md` 附录，属主会话对设计产物的追加，不改变 1.7 的派遣与契约语义）
- `openspec/specs/spec-workflow/spec.md:9`——`### Requirement: 固定工作流入口`（319 字符，**:13-26 共 3 个 scenario**：以需求描述新建流程 / 未预置执行模式 / 规划参数转发）

**E. openspec CLI 1.16.0 校验硬约束（决定 delta 的形状）**

- `dist/core/validation/constants.js:9`——`MAX_REQUIREMENT_TEXT_LENGTH = 500`；`:46`——`REQUIREMENT_TOO_LONG` 文案「Move examples and edge cases into scenarios」
- `dist/core/validation/validator.js:268-277`——**ADDED 的 requirement 正文 >500 字符 → WARNING**（注释原文：「Same limit the main spec enforces after archive (#1976), so `validate <change> --strict` catches a new overlong requirement before it lands. **MODIFIED is left alone**: its text is the existing requirement」）→ ADDED 必须 ≤500，MODIFIED 豁免
- 同名 `:322` + `:611-686`——MODIFIED 块与主规格比对，**漏掉主规格仍有的任一 scenario → ERROR**（`:681` 原文「a MODIFIED requirement replaces the whole block, so archive refuses to drop them」）→ MODIFIED 必须**整块携带**既有 scenario
- 同名 `:898-899`——`const valid = this.strictMode ? errors === 0 && warnings === 0 : errors === 0` → **`--strict` 下任何 WARNING 都算失败**（含 ADDED 超长、scenario 缺 WHEN/THEN、requirement 缺 SHALL/MUST——`:112-114` 注释）
- `dist/core/schemas/change.schema.js:19-20`——`why` zod `.min(50).max(1000)`（proposal `## Why`）
- `dist/core/validation/task-numbering.js:4-5`——`NUMBERED_GROUP_HEADING = /^##[ \t]+(\d+)\./`、`TASK_ID = /^(\d+\.\d+…)/`：**任务 ID 前缀必须等于所属 `## N.` 组号**，跨文件重复 ID 报错
- `dist/core/validation/constants.js:46` 与实测：`openspec validate --all` 当前 **4 passed / 0 failed 但 spec-plan 有 2 条 `⚠ REQUIREMENT_TOO_LONG`**（requirements[4]/[5]）→ **本变更的验收命令必须是 `openspec validate add-ui-demo-gate --strict`（变更级），不能用 `--all --strict`**
- 实测 `openspec validate --archived` → **14 passed / 0 failed**：归档变更目录含 `code-design.md`/`decisions.md`/`execution-log.md`/`diff-matrix.md` 等非工件文件仍全部通过 → **在变更目录下新增 `demos/` 不会被结构校验拦截**（本文 ⑥假设 4 的实证）

**F. DSH · skill 发现与 frontmatter（软接线的能力边界）**

- `@deepseek-ai/dsh-skill-filesystem/README.zh.md:36`——「必填 `name` 与 `description`，另有可选 `whenToUse`、`metadata`、`disable-model-invocation` 与 `user-invocable`」；`:38`——布尔键拼错会让整个 skill 连警告一起被丢弃
- 同名 `:147`——「**发现深度为一层**——只识别 `<root>/<name>/SKILL.md` 与 `<root>/<name>.md`」→ `refs/` 子目录不会被当 skill 发现，安全
- `@deepseek-ai/dsh-tool-skill/README.zh.md:48`——`catalogDescriptionMaxLength` 默认 **500**（目录里渲染的规范化描述上限）；`:244`——「**目录省略 `whenToUse`**、来源和提供方元数据——**路由只基于名称和有长度上限的描述**；`whenToUse` 仍是提供方元数据，加载后的包装层也不渲染它」→ **`whenToUse` 对触发零贡献**（④D3 的关键证据）；`:245`——「已加载指令正文**没有大小上限**」，但 tool result 仍受 pruner 8192 裁剪
- `dotfiles/agent/skills/README.md:3-5`——「自写 skill 的实体存放地……**未经 skctl 登记的 skill 两个 agent 都看不到**」；`:11`——容器 `/home/docker/.agents/skills` ← 聚合层只读挂载；`:16-25`——`SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts`、`install <本地目录>`、`doctor`；`:37-40`——「实时视图……运行中的 dsh 无需重启即可按名加载（实测）」
- `tools/skctl/src/validate.ts:1`——`NAME_RE = /^[a-z0-9]+(-[a-z0-9]+)*$/`（`ui-demo` 合法）；`:15-17`——`parseFrontmatter` 要求 `name`/`description` 均为 string，否则返回 null；`tools/skctl/src/doctor.ts:61-63`——frontmatter 坏或 `fm.name !== 目录名` 均记 invalid
- 全仓 13 个自写 skill 的 frontmatter 键集实测：**13/13 只有 `name`+`description`**（`awk` 提取验证）→ 仓内惯例与 `whenToUse` 无用性一致

**G. docker 仓 · 预览与自检的平台事实（只读引用，不触达）**

- `containers/tools/dsh/entrypoint.d/70-shared-chromium.sh:13`——`--headless --remote-debugging-port=9222 --user-data-dir=$HOME/.dsh/chromium-shared`；`:36`——「[entrypoint] 常驻共享浏览器就绪 :9222」→ **chrome-shared MCP 驱动的 Chromium 跑在 dsh 容器内**，`file:///tmp/...` 在容器内可解析
- `dotfiles/dsh/profiles/web/cordis.patch.yml:139-160`——`serverName: chrome-shared`、`--browser-url http://127.0.0.1:9222`；同名注释「多会话共用一个浏览器，操作同一标签页会互相干扰——不同会话请用不同标签页」→ 自检必须 `new_page` 新标签页 + 用完 `close_page`
- 实测 `findmnt -T /tmp` → `source /dev/nvme0n1p2[/data/tmp], target /tmp` → **容器 `/tmp` = 宿主 `/data/tmp`**；宿主 `/tmp` 是 tmpfs（`docker/CLAUDE.md`）→ skill 必须写「宿主预览路径 = `/data/tmp/...`」
- `agent/skills/smoke-testing-local-env/reference.md:19`——「chrome-devtools-mcp 运行在容器内 → localhost 是容器自己」（同类事实的既有先例）；`agent/skills/smoke-testing-local-env/SKILL.md:30-34`——MCP 缺失时的降级表体例（skill 降级段照抄此形态）

**H. writing-skills（硬约束源，实测路径）**

- `/home/docker/.agents/skills/writing-skills/SKILL.md`——Iron Law / RED-GREEN-REFACTOR / SDO（description 只写触发条件）/ Match the Form to the Failure / 目录结构（`skill-name/SKILL.md` + 按需附属资源）/ 检查表（`name` 仅字母数字连字符、frontmatter ≤1024 字符、`Use when` 开头）
- 同级实存附属资源：`anthropic-best-practices.md`、`testing-skills-with-subagents.md`、`persuasion-principles.md`（按需读，不在本设计消费）

---

## ③ 接口与数据形状

### 3.1 `ui-demo/SKILL.md` frontmatter（键集 + 触发词契约）

```yaml
---
name: ui-demo
description: Use when <触发条件链>；触发词：<中文场景词表>。不适用：<排除词>。
---
```

**键集 = 恰好 `{name, description}`，不加 `whenToUse`**（理由见 ④D3，证据 E-F `tool-skill:244`）。

- `name: ui-demo`（匹配 `NAME_RE`，`validate.ts:1`；`doctor.ts:63` 要求 = 目录名）
- `description` 预算 **≤400 码点**（硬线 500 = `catalogDescriptionMaxLength`；写作规范建议 ≤500 字符）。逐字草案（实测 199 码点，可再加场景词至 ≤400）：

```
Use when 需求涉及界面设计但没有 Figma、截图、原型图或其他设计稿，需要 AI 自行设计界面，且尚未开始写实现代码——要先产出界面演示供用户确认视觉与布局时。触发词：界面演示、UI demo、界面设计、页面设计、没有设计稿、Figma 缺失、原型图、改版、openspec explore/propose 的界面需求、/plan 规划界面。纯后端、CLI、配置或无视觉改动的任务不适用。
```

**自查三条**（SDO 纪律）：①首词 `Use when`；②**不含任何流程概述**（不得写「先产出 HTML 再让用户确认」这类步骤句——那会诱使模型只看目录就动手）；③含中文场景词 + 三个入口名（`openspec explore/propose`、`/plan`、`spec-plan`），因为目录路由**只读名称与这段描述**。

### 3.2 `ui-demo/SKILL.md` 正文骨架（8 节 + 码点分配）

| 节 | 标题 | 内容契约 | 码点预算 |
| --- | --- | --- | --- |
| 0 | H1 `# 界面演示（ui-demo）` | 一句定位：**演示是确认工具，不是交付物**；本 skill 是判定/分级/产物/自检的唯一权威源 | ≤200 |
| 1 | `## 核心原则` | 三条铁律（禁止式，纪律型失败）：**没有图就先给看**；**未确认不得落实现**；**演示 ≠ 最终实现**（页面顶部必须写明） | ≤300 |
| 2 | `## 何时触发（判定）` | C1/C2/C3 三条件 + 排除表（③3.3）——**必须在全文前 2000 码点内** | ≤800 |
| 3 | `## 产出分级` | L1/L2/L3 语义判据 + 各档必须有的元素（③3.4），细节指 `refs/html-recipe.md` | ≤700 |
| 4 | `## 产物规范` | 路径/命名/HTML 契约/体积/预览路径映射/nginx 预留位（③3.5） | ≤900 |
| 5 | `## 自检` | chrome-shared 四步序列 + 标签页纪律 + 降级路径（③3.6） | ≤600 |
| 6 | `## 三处入口接线` | spec-plan 1.75（硬 gate）／openspec explore·propose（软）／`/plan`（软），各自的产物流向与留痕位置（③3.7-E 的表） | ≤700 |
| 7 | `## 常见错误` | 5–6 条「错误做法 → 为什么错 → 正确做法」表（含：先写代码后补演示、把演示当最终实现、把 base64 大图内联、用 `localStorage`/fetch 造数据、不写分档、未确认就落档） | ≤600 |
| 8 | `## 按需读取` | 何时读 `refs/html-recipe.md`（写页前）；read 后与正文同等权威 | ≤150 |

合计 ≈ 4950 码点（上限 6000，硬线 8192）。**判定表前置断言**：`C1` 首次出现位置 < 2000 码点。

### 3.3 判定标准 C1∧C2∧C3 + 排除表（语义条款，逐条可判）

```
C1 需求涉及「界面产出」：页面 / 组件 / 弹窗 / 表单 / 仪表盘 / 移动端页面 / 布局或视觉改版 / 交互流程的可视化。
C2 用户未提供任何设计依据：无 Figma 链接、无截图、无原型图、无既有页面可照抄（含「我没设计稿，你看着办」这类授权）。
C3 AI 必须自行决定视觉与布局方向：不是纯逻辑/后端/数据/配置改动；也不是在既有设计体系内做零视觉决策的机械改动（加一个字段、加一个接口）。
```

**判定式**：`C1 ∧ C2 ∧ C3` 成立 **且** 不命中下表任一行 → 进入演示；否则记录未触发。

| 排除行 | 判据 |
| --- | --- |
| 纯后端 / CLI / 数据迁移 / 配置 / 脚本 | C1 不成立 |
| 已有 Figma 链接、截图、原型图，或 figma MCP 可取到设计 | C2 不成立 |
| 仅文案、字号、颜色 token 的局部替换，或整体沿用既有设计系统且无新布局 | C3 不成立 |
| 用户明确要求「不用演示，直接做」 | 用户豁免（**必须留痕**，见 3.7-E） |
| 需求本身已是可交互原型/静态页（用户在给的就是成品视觉） | C2 不成立 |

### 3.4 产出分级（语义判据，Q4 裁定原话落地）

| 档 | 语义判据（命中即升档，取最高档） | 必须包含 |
| --- | --- | --- |
| **L1**（默认） | 单屏静态布局，无关键交互流转 | 主要区域划分、信息层级、关键控件与其位置、字号/间距/圆角基调、配色方案（≤3 主色 + 中性色阶）、空态占位说明 |
| **L2** | **含关键交互流或多状态**（打开/关闭、提交中、校验失败、空/加载/错误、步骤流转） | L1 全部 + 每个状态一屏（同页多 section 或 tab 切换）、按钮禁用/悬停态、错误提示文案位 |
| **L3** | **视觉方向完全开放且用户未给偏好**（无品牌/设计系统可依，或用户明说「你定」） | 2–3 个**方向不同**的并列方案（同页并排或顶部切换），每方案一句设计意图 + 取舍；用户先选方向再细化到 L1/L2 |

**L2/L3 同时命中 → 按 L3 交付**（多方向并列，各方向按 L2 深度）。**不设数值化 checklist**（Q4 已裁定语义判据）——状态数量等数值只作为「拿不准时向上取档」的提示，不作判据。

### 3.5 产物数据形状（路径 / 命名 / HTML 契约 / 体积 / 预览）

**路径矩阵**

| 场景 | 生成期路径（易失） | 落位路径（入库） |
| --- | --- | --- |
| spec-plan 阶段 1.75 | `/tmp/spec-flow/<change>/demos/<slug>.html` | `openspec/changes/<change>/demos/<slug>.html`（落档复制） |
| openspec explore / propose（变更目录已存在） | 直接写 `<change>/demos/<slug>.html` | 同左（无需二次迁移） |
| openspec explore（变更目录未建） | `/tmp/spec-flow/<change>/demos/<slug>.html` | 建目录后迁入 `<change>/demos/`，并在产出时**告知最终位置** |
| `/plan`（无 openspec 根或不经 openspec） | `/tmp/ui-demos/<change>/<slug>.html`（易失区；Q-C 落档裁定终口径，2026-11-05 组 2 终形态更正，原文 `docs/ui-demos/` 已废） | **不入库：即确认即弃** |

- `slug` = kebab-case、描述场景而非编号（如 `login-captcha-l1.html`、`dashboard-l3-directions.html`）；同一变更多档多文件时用 `-l1/-l2/-l3` 后缀
- 变更名 `<change>` 与 `/tmp/spec-flow/<change>/` 一致（spec-plan 既有命名）

**HTML 契约（可机械核对）**

1. **单文件自包含**：样式内联 `<style>`；**零外部请求**（禁 CDN、禁 webfont 外链、禁 `<img src="http…">`）；图标用 inline SVG 或 Unicode 字符
2. **禁止 base64 大图内联**（单张 >20KB 的资产一律用 CSS 形状/SVG 代替）——单文件 **≤100 000 字节**
3. `<meta name="viewport" content="width=device-width, initial-scale=1">`；桌面（≥1280px）与窄屏（≤480px）各不横向滚动
4. 页面顶部固定**演示约束条**（一个 `<header>`）：`变更名 · 分档 Lx · 生成时间 · 「界面演示，非最终实现」`
5. 交互用按钮 + 纯 CSS `:target`/`:checked`/`details` 或 ≤50 行内联 JS 切换**假状态**；不连后端、不发请求
6. 语义标签（`<header>/<main>/<section>/<button>`）与可读对比度（正文与背景对比 ≥ 4.5:1）

**预览路径（file:// 直开，Q3 裁定）**

- 容器内自检：`file:///tmp/spec-flow/<change>/demos/<slug>.html`
- 宿主给用户：**`file:///data/tmp/spec-flow/<change>/demos/<slug>.html`**（容器 `/tmp` ≡ 宿主 `/data/tmp`，证据 ②G `findmnt`）
- 落档后：`file:///home/xuqinqin/develop/<repo>/openspec/changes/<change>/demos/<slug>.html`（身份挂载三端同路径）
- **nginx 统一入口（如 `ui-demos.localhost`）不在本变更实现**——skill 内只留一句「未来统一入口预留位；届时本路径约定不变」。

### 3.6 自检序列（chrome-shared MCP）与降级

```
1) new_page(url=file:///tmp/spec-flow/<change>/demos/<slug>.html)     # 必须新标签页（共享浏览器多会话隔离）
2) take_screenshot(pageId, fullPage=true)                              # 一屏不足时再分段；核对：约束条在顶、无空白区块、无溢出横向滚动
3) list_console_messages(pageId)                                       # 断言：无 error；无 Failed to load resource（外链残留的硬信号）
4) close_page(pageId)                                                  # 不留标签页给别人
```

- 视口至少验两种：默认（1440×900 级）与 `resize_page(width=390, height=844)`；窄屏只截图核对，不 `emulate` 设备
- `navigate_page` 报错/工具不可用 → **降级**：如实告诉用户「未做渲染自检」，给宿主 `file:///data/tmp/...` 路径请其自行打开，并在确认留痕里标注证据缺口（形态照 `smoke-testing-local-env/SKILL.md:30-34`）
- 截图不落库（属证据，落 `/tmp/spec-flow/<change>/` 或直接丢弃）；**演示 HTML 落库、截图不落库**

### 3.7 spec-plan 手册接线（逐字改动，A–E）

**A. `agent/skills/spec-plan/SKILL.md:15-18` 三行流水线块——整块替换为（实测 180 码点；原块实测 138，净 +42）**

```
阶段1 规划编排 → 阶段1.5 收敛 → 阶段1.7 代码设计 → 阶段1.75 界面演示（条件） → 阶段2 落档（终于落档提交）
并行=双线（team 驱动）  并行=七步（含审视）   code-design.md      演示 HTML+确认      四件套+两材料+demos/
串行=单线（explore）    串行=grill-me 直收
```

（第三行保持原样；`（条件）` 是必须的——避免读者以为是每个变更的固定阶段）

**B. `:92` 节标题——替换为**

```
## 六、代码设计（1.7）与界面演示 gate（1.75）
```

**C. `:94` 单段之后插入（逐字，实测 275 码点，含空行净 +277）**

```

### 阶段 1.75 界面演示 gate（1.7 后、落档前）

加载 skill `ui-demo` 判定（C1∧C2∧C3 且不在排除表）：命中 → 产出演示交用户确认，**未确认不得落档**（改稿至确认，或用户书面豁免并留痕）；未命中 → `code-design.md` 记一行「1.75 未触发：<判据事实>」。演示先落 `/tmp/spec-flow/<change>/demos/`，落档复制入变更目录（第七节④断言）。细则见 [planning.md](refs/planning.md)『附：阶段 1.75 界面演示 gate』。
```

> 为何用 `###` 而非新增顶级 `## 七`：见 ④D7（重编号会连带 5 个 ref 文件 12 处指针，与 Q1「最小 scope」取向冲突）。阅读顺序上它**仍严格位于 §六 与 §七 之间**，即「1.7 之后、落档之前」。

**D. `:41` 消费时机行——替换为**

```
| 阶段 1.7 / 1.75 / 落档 | [planning.md](refs/planning.md) —— 前置检查展开、设计契约、界面演示 gate、落档细节 |
```

**E. 三处入口的接线强度与留痕位置（本表落在 `ui-demo` 第 6 节；spec-plan 侧只保留 3.7-C 那一句，不复制本表——D2 单源纪律）**

| 入口 | 接线强度 | 触发时产物落点 | 留痕位置 |
| --- | --- | --- | --- |
| spec-plan 阶段 1.75 | **硬 gate**（本 skill 手册规定，未确认不得落档） | `/tmp/spec-flow/<change>/demos/` → 落档复制入变更目录 | `code-design.md` 附录 → `design.md` 决策记录 |
| openspec explore / propose | **软**（frontmatter 触发词 + skill 正文接线规则） | 变更目录在则 `<change>/demos/`；否则 `/tmp/spec-flow/<change>/demos/` 再迁入 | 会话产出 + 对话摘要；有 code-design 时同左 |
| `/plan` 规划模式 | **软**（同上；plan 无手册可改） | `/tmp/ui-demos/<change>/<slug>.html`（易失即弃；Q-C 裁定终口径） | 计划文件末「界面演示」一行（路径 + 确认状态） |

### 3.8 `planning.md` 接口（逐字改动，A–D）

**A. `:1` 文件头——外移正文清单加一项**

```
> 本文件为 SKILL.md §二（前置检查展开）、§六（代码设计环节 + 阶段 1.75 界面演示 gate）与 §七（落档细节）的外移正文，……
```

**B. 在 `:52`（「附：代码设计环节（阶段 1.7）」末行）与 `:54`（「附：落档细节」）之间插入——逐字，实测 858 码点**

```markdown
## 附：阶段 1.75 界面演示 gate（自 SKILL.md §六 外移）

**消费时机**：阶段 1.7 回执核对通过之后、阶段 2 落档之前；**由主会话 inline 执行**（不派子代理——本环节要逐轮看图确认，子代理无法直问用户；映射文件不设 `demo` 键）。判定标准、排除表、L1/L2/L3、产物规范与自检序列的**唯一权威源是 skill `ui-demo`**——本文件不复述判据，只写落点、留痕与落档接线。

1. **判定与留痕**：加载 `ui-demo` 按其判定表判 C1∧C2∧C3 与排除表。命中 → 在 `/tmp/spec-flow/<change>/code-design.md` 末尾追加 `## 附：阶段 1.75 界面演示（判定与确认）`，逐行记 C1/C2/C3 事实依据、分档与理由、产物路径、确认结论（确认／改稿轮次／豁免依据）。未命中 → 同处记一行 `1.75 未触发：<哪条不成立或命中哪行排除表>`——**一行也必须有**，供执行侧与接续恢复审计。
2. **产出与预览**：先落 `/tmp/spec-flow/<change>/demos/<slug>.html`（容器内路径），**宿主等价路径 = `/data/tmp/spec-flow/<change>/demos/<slug>.html`**（容器 `/tmp` 即宿主 `/data/tmp`，身份挂载三端同见）。自检按 `ui-demo` 的 chrome-shared 序列对 `file:///tmp/...` 截图并核对控制台；MCP 不可用按该 skill 的降级路径如实标注证据缺口。
3. **确认问法（一次问清）**：`①确认，转入落档　②要改：<具体点>　③降档/豁免（写明依据）`。**未取得确认不得落档**；否决则改稿重出，不进入落档。
4. **落档接线**：复制清单与机械断言分别见『附：落档细节』第 1 步与第 4 步新增的两句（本文件不另立第三处）。
```

**C. `:58`（落档细节第 1 步）句末追加——断言的「复制规则」句式（实测 161 码点）**

```
**界面演示已触发时**（`code-design.md` 含「阶段 1.75 界面演示」附录），把 `/tmp/spec-flow/<change>/demos/` **整目录**复制入 `openspec/changes/<change>/demos/`（保留文件名，空目录视为缺失）；未触发则不建 `demos/`。
```

**D. `:68`（第 4 步两段式校验）追加一条条件断言（实测 216 码点）**

```
- **界面演示产物断言（条件项）**：`code-design.md` 含「阶段 1.75 界面演示」附录时，`test -d openspec/changes/<change>/demos && test -n "$(ls -A openspec/changes/<change>/demos/)"` 退出码 0，且该目录随第 7 步一并 `git add`；未触发则跳过本行并在 `design.md` 决策记录留未触发判定。
```

**预算**：`6111 + (14 + 858 + 161 + 216) ≈ 7360`（上限 8192；断言 ≤7800）。同时 `:70`（摘要字段）若实现方愿意，可在「四件套与两份材料路径」后补「＋演示目录（若触发）」，非必须（不计入断言）。

### 3.9 `spec-workflow/SKILL.md` 接口（逐字改动）

**A. `:15-16` 两行流水线——整块替换为（实测 163 码点；原块实测 145，净 +18）**

```
阶段1 独立双线规划 → 阶段1.5 差异收敛 → 阶段1.7 代码设计 → 阶段1.75 界面演示（条件） → 阶段2 落档（spec-plan 承载，至落档提交）
→ 衔接（本 skill：模式/引擎/执行环境）→ 阶段3 执行（spec-apply 承载）→ 阶段4 验证与归档 + 收尾闭环（spec-done 承载）
```

**B. `:19` 状态载体段末（`（组段终形态化，见第六节；/tmp 侧原件落档后不再维护）。` 之后）追加一句（实测 56 码点）**

```
另：阶段 1.75 触发的界面演示产物 `demos/` 随落档提交入变更目录，执行期只读、不参与组段终形态化。
```

**预算**：`6314 + 18 + 56 ≈ 6388`（断言 ≤6600 且 ≤7800）。

### 3.10 spec delta 形状（3 文件 / 7 个 requirement 块）

**A. `specs/ui-demo/spec.md`（New capability）**

```markdown
# Spec Delta            ← 与归档体例一致（2026-10-15-spec-workflow-add-design-phase/specs/spec-workflow/spec.md:1）
## Purpose              ← ≥50 字符，归档时成为新主规格 Purpose（`constants.js:42-45` 原文：a `## Purpose` in a delta is read only when the capability is created）
## ADDED Requirements
```

| # | Requirement 标题 | 正文要点（≤500 字符） | Scenario 清单（每条带 WHEN/THEN） |
| --- | --- | --- | --- |
| R1 | `界面演示触发判定与产出分级` | C1/C2/C3 三条件同时成立且不命中排除表才进入演示；按语义判据分 L1（默认）/L2（关键交互流或多状态）/L3（视觉方向完全开放且未给偏好 → 2–3 并列方向）；**排除表列出五类不适用** | `界面需求无设计稿命中判定` / `命中排除表不进入演示` / `含关键交互流升级 L2` / `视觉方向开放出多方案 L3` |
| R2 | `界面演示产物规范` | 静态自包含单 HTML（内联样式、零外部请求、≤100KB）；openspec 场景 `openspec/changes/<change>/demos/<slug>.html`（落档前先落易失区）；plan 场景 `/tmp/ui-demos/<change>/<slug>.html`（即确认即弃，与落档 delta R2 同口径）；顶部标注变更名/分档/「非最终实现」；支持宿主 `file://` 直开；**统一服务入口（nginx）不在本能力内实现，只留扩展位** | `openspec 场景产物路径` / `plan 场景产物路径` / `自包含与外链禁令` / `file:// 直开预览` |
| R3 | `界面演示自检与用户确认` | chrome-shared MCP 以 `file://` 新标签页导航 → 截图 → 控制台零 error 后才交用户；MCP 不可用降级为告知用户自行打开并标注证据缺口；确认以「确认／要改／降档或豁免」三选一提问，**未取得确认不得视为通过**；共享浏览器须用独立标签页 | `自检通过后交用户确认` / `自检不可用降级如实标注` / `用户否决则改稿重出` / `用户豁免须留痕` |
| R4 | `三个流程的接线与留痕` | spec-plan 阶段 1.75 为**硬 gate**（未确认不得落档）、openspec explore/propose 与 `/plan` 为**软接线**（依赖 skill 目录描述触发）；三者各自规定产物落点与留痕位置；软接线**不得**宣称强制 | `spec-plan 阶段 1.75 硬 gate` / `explore 场景接线` / `plan 场景接线` / `软接线不宣称强制` |
| R5 | `ui-demo 入口与资源预算` | 目录 bundle `agent/skills/ui-demo/`；入口 SKILL.md 单次加载完整交付且判定表在前 2000 码点内；重参考（HTML 骨架与分档元素清单）外移 `refs/` 按需读取；入口与各资源各自 ≤8192 码点 | `入口单次加载完整` / `重参考按需读取` / `判定表前置` |

**断言**（组 4 执行）：每个 ADDED requirement 正文 ≤500 字符；每个 requirement ≥1 scenario，scenario 均含 `- **WHEN**` 与 `- **THEN**`。

**B. `specs/spec-plan/spec.md`（delta）**

```markdown
# Spec Delta
## ADDED Requirements
### Requirement: 阶段 1.75 界面演示 gate
<≤500 字符，含 SHALL：1.7 回执核对通过后、落档前加载 ui-demo 判定；命中则产出演示并取得明确确认后才落档；未命中记未触发事实；产物先落易失区、落档复制入 demos/；ui-demo 不可加载按失败处置顺序修复，仍失败报告问用户，不静默跳过>
#### Scenario: 命中判定进入演示 gate
#### Scenario: 未确认不得落档
#### Scenario: 未命中记未触发事实
#### Scenario: ui-demo 不可加载不静默跳过
## MODIFIED Requirements
### Requirement: 落档工件与执行批次契约         ← 标题必须与主规格一字不差（spec.md:126）
<正文 = 主规格 :128 原文 + 追加一句：「若阶段 1.75 界面演示已触发，落档 SHALL 同时把演示产物从易失区整目录复制入变更目录 demos/，其存在性断言并入同一机械校验（空目录视为缺失）；未触发 SHALL 在代码设计草案留未触发判定。」>
#### Scenario: 分组内任务并行执行        ← 以下 9 条为 :130-173 原文，**必须逐条照抄**
#### Scenario: 分组间串行
#### Scenario: 组内单任务合法
#### Scenario: design 继承设计草案深度
#### Scenario: 任务引用触达面条目
#### Scenario: 落档含规划材料
#### Scenario: 落档校验断言材料存在
#### Scenario: 执行期维护落档副本
#### Scenario: 落档摘要含触达仓清单
#### Scenario: 落档复制界面演示产物      ← 新增（第 10 条）
```

**C. `specs/spec-workflow/spec.md`（delta）**

```markdown
# Spec Delta
## MODIFIED Requirements
### Requirement: 固定工作流入口          ← 主规格 spec.md:9 标题一字不差
<正文 = :11 原文 + 「规划半程 SHALL 含阶段 1.75 界面演示 gate（条件触发，判定与产物规范以 skill ui-demo 为唯一权威源）；权威进度 SHALL 含 demos/ 工件（随落档提交、执行期只读）。」>
#### Scenario: 以需求描述新建流程      ← 以下 3 条 :13-26 原文，必须逐条照抄
#### Scenario: 未预置执行模式
#### Scenario: 规划参数转发
#### Scenario: 阶段 1.75 条件触发     ← 新增
```

**形状约束汇总**（全部来自 ②E，组 4 逐条断言）：ADDED ≤500 字符／MODIFIED 整块携带既有 scenario／每 scenario 含 WHEN+THEN／requirement 含 SHALL 或 MUST／`## Purpose` ≥50 字符／delta 文件 3 个（≤10）／requirement 块 7 个（≤10）／`skip_specs` 不设（否则报 `CHANGE_SKIP_SPECS_CONFLICT`）。

### 3.11 `tasks.md` 形状

- 五组（见 ⑤），`## N. 组名` + `- [ ] N.M <描述>；验证：<验证句>`；**任务 ID 前缀 = 组号**（`task-numbering.js:4-5`）；单组 ≤3（`parallelism` 默认 3）；每条描述引用触达#N。
- 验证句一律为「命令 + 退出码/可观察输出」，禁止「已实现/工作正常」。

### 3.12 `agent/skills/README.md` 与机器态登记

- `:35` 后追加一行（表格列宽不必强对齐，渲染器不校）：
  `| `ui-demo` | 自写（本目录 local symlink） |`
- 宿主执行（node 走 docker 包装，仓惯例）：`SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts; node $SKCTL install ~/develop/dotfiles/agent/skills/ui-demo`
- 期望机器态：`~/.local/share/agent-skills/skills/ui-demo` 为指向实体目录的 symlink；`registry.json` 含 `source.type=local` 条目；`/home/docker/.agents/skills/ui-demo` 可见（聚合层实时视图，无需重启）

---

## ④ 决策记录

> 每条含被否方案与理由。**D1–D3 为需求级基线复述+代码级落地化（decisions.md 已裁定，本文只做实现层定形，不重开）**；D4–D11 为本次设计新增的代码级决策。

| # | 决策 | 被否方案与理由 |
| --- | --- | --- |
| **D1** | 1.75 落在 **1.7 之后、阶段 2 落档之前**（spec-plan `:92` §六 与 `:96` §七 之间） | ①**执行期（阶段 3）才发现**：落档即契约，执行期改界面要回改工件与任务组，成本最高，且违背「落档即契约」；②**1.5 之后、1.7 之前**：此时方案未收敛（界面方向可能在收敛中变化），演示易白做；③**与 1.7 并行派发**：设计线子代理不能直问用户（`DELEGATED_CALLER`），演示确认必须主会话在场。**反例**：若放在执行期，历史上「做完才发现效果不如人意」的返工完全保留——gate 的唯一价值就是前置确认。 |
| **D2** | 判定标准 / 排除表 / L1–L3 / 产物规范 / 自检 **单源在 `ui-demo`**；spec-plan、planning.md、spec-workflow、delta 一律**只引用不复述** | 三处各写一份 = 三份会漂移的判定表（spec-plan 手册与 ui-demo 一旦分歧，模型会按到达顺序选一份执行）。仓内既有惯例：`spec-plan` 的收敛判据只在 `convergence.md`、路由细则只在 `routing.md`，入口写「唯一权威源」字样。**反例**：`planning.md:1` 头行「回入口引用写『SKILL.md 第 X 节』」的分层纪律——只要出现第二份判据，就必须靠人工同步，本变更无该维护带宽。 |
| **D3** | 软接线**只靠 `description` 触发词**（不加 `whenToUse`、不写 AGENTS.md 行、不改 openspec 生成 skill）；补强**上限**=「description 覆盖中文场景词 + 三入口名 + skill 正文首 2000 码点内给判定表」 | ①**加 `whenToUse`**：`dsh-tool-skill/README.zh.md:244` 明证「目录省略 `whenToUse`……路由只基于名称和有长度上限的描述；加载后的包装层也不渲染它」→ 零触发收益，纯维护负担；且全仓 13/13 skill 均只有两键。②**AGENTS.md 转接行**：Q1 已裁定不做（且 `~/.dsh/AGENTS.md` 不入库）。③**改 `openspec-explore`/`openspec-propose` 生成 skill**：`agent/skills/README.md:36` 等证据表明 openspec-* 为 skctl 从 git 源拷贝的生成物，升级即覆盖。④**命令薄壳 `/ui-demo`**：Q1 已裁定不做。**补强边界（必须写进 skill 与 design.md）**：软接线**不宣称强制**，命中率取决于模型是否把该场景读成「界面设计且无设计稿」——因此 description 首词 `Use when` + 场景词表 + 「不适用」尾巴是唯一杠杆；这是用户知情接受的残余风险（decisions.md「explorer/plan 软接线只剩一条腿」）。 |
| **D4** | 1.75 **由主会话 inline 执行，不派子代理**；映射文件不加键 | ①**复用 `design` 路由派发**：能派但无收益——演示确认是**逐轮看图对话**，子代理不能直问用户（`DELEGATED_CALLER`），每轮都要主会话中转，往返成本远超自己写；②**新增 `demo` 键**：Q5 已裁定不加（无独立派发需求）。**代价与补偿**：主会话承担 HTML 写作成本 → 用 `refs/html-recipe.md` 骨架降低单次写作成本（这也是 D8 外移决策的动机之一）。 |
| **D5** | 演示产物**先落 `/tmp/spec-flow/<change>/demos/`，落档时整目录复制**入变更目录 | ①**1.75 直接写 `openspec/changes/<change>/demos/`**：该目录在阶段 2 才创建；提前建会让 `openspec list` 出现半个变更，且违反「落档才动 openspec 工件」的既有边界。②**直接落 `docs/ui-demos/`**：与 Q3 裁定的 openspec 场景产物位置冲突，且 `docs/` 在本仓不存在（实测）——plan 场景才用它。**收益**：复用 `planning.md:58` 既有「/tmp → 变更目录」机制，只加一句复制规则，不新增生命周期。 |
| **D6** | 预览 = **宿主 `file://` 直开**；skill 内**双写路径映射**（容器 `/tmp` ↔ 宿主 `/data/tmp`），nginx 只留一句扩展位 | ①**nginx server**：Q3 用户裁定「先不要」；②**容器内起静态服务**：违背「agent 容器不当服务宿主」，且有端口/进程治理成本；③**只写容器路径**：用户打不开（宿主 `/tmp` 是 tmpfs，与容器 `/tmp` 不同源）——这是**必然的可用性坑**，`findmnt` 实测 `source=/dev/nvme0n1p2[/data/tmp]` 是硬证据。**反例**：若只写 `file:///tmp/...`，用户在宿主打开会得到「文件不存在」，且会误判为演示坏损。 |
| **D7** | 1.75 作为 **§六 的 `###` 子节**（§六 标题改为「代码设计（1.7）与界面演示 gate（1.75）」） | ①**新增顶级 `## 七、阶段 1.75` 并顺移编号**：会把 §七/§八/§九 变 §八/§九/§十，连带修改 **6 个文件的 13 处指针**（refs 9 处：`refs/planning.md:1,54`、`refs/routing.md:15`、`refs/failure-modes.md:1,15,16,21`、`mode/serial.md:19`、`mode/parallel.md:49`；`SKILL.md` 自身 4 处：`:32,42,104,110`）——与 Q1「最小 scope」取向冲突，且一次性引入 13 处易漏的人工改写。②**只在 §六 末尾加粗段落不升标题**：`spec-plan` 的正文没有裸段先例，且无法被 `第X节` 指针定位。**代价**：§六 标题变长 16 码点、承担两个阶段；由 §一 流水线与 `###` 标题双处消歧。 |
| **D8** | 码点预算按「**入口保 skeleton、细则下沉**」分配：spec-plan SKILL.md 净增 ≈+356（7338→7694，断言 ≤7800）、planning.md 净增 ≈+1250（→ ≤7800）、ui-demo SKILL.md ≤6000 + refs ≤7000 | ①**判定表写进 spec-plan SKILL.md**：7338 现基线只剩 ≈490 到 7830 目标线，判定表（≥800 码点）必然破线；②**ui-demo 单文件不拆 refs**：HTML 骨架 + 三档元素清单 ≈2–3k 码点，与判据混排会让入口长期膨胀，且模板只在「写页」时消费（writing-skills「按消费时机外移」）。**反例（可观测）**：`agent/skills/spring-writer/SKILL.md` 实测 **14964 码点**已超 8192 裁剪线——单文件堆参考正文的既有反证。 |
| **D9** | 演示页硬约束：单文件 ≤100 000 字节、**零外部请求**、禁 base64 大图、顶部约束条 | ①**允许外链字体/CDN**：file:// 下断网即花屏，且截图自检会出 `Failed to load resource` 噪音；②**允许内联 base64 大图**：单页可到 MB 级，随 `openspec/changes/` 一次性入库后永久留在 git 历史（历史不可回收）。**反例**：一次 5MB 的演示图入库 = 之后每次 clone 都付这个成本，而演示本身在归档后几乎不再被打开。 |
| **D10** | 1.75 **未命中也要留一行**「`1.75 未触发：<事实>`」 | ①**未命中不写任何东西**：接续恢复与执行侧无法区分「判定过但未触发」与「根本没人判」——这正是 spec 体系里最容易腐化的静默缺口；②**只在会话摘要说**：压缩后丢失。**代价**：每变更多一行写盘与一次判定阅读（<1 分钟）。 |
| **D11** | spec-workflow **只改 `:15-16` 流水线与 `:19` 状态载体**；`:55`「落档后核对两件事」与 `:66` 恢复协议第 4 步**不动** | ①**把 demos/ 加进 `:55` 核对清单**：会让「缺 demos/ 就要求 spec-plan 补落」成为阻塞条件，而 demos/ 是条件产物（未触发时本就不存在）——需再加条件分支，收益低；②**加进 `:66` 恢复检查**：恢复协议的红线是「绝不重跑已完成任务」，把只读参考物的缺失接进恢复路径，会制造假阻塞。**判据**：`demos/` 是**只读参考物**，不是进度载体。 |

**反例一览（供 design.md 决策记录引用）**：①执行期才做界面确认 → 返工（D1）；②判定表三源 → 漂移（D2）；③`whenToUse` → 零收益（D3，`tool-skill:244`）；④宿主只给 `/tmp` 路径 → 打不开（D6，`findmnt`）；⑤单文件堆参考 → 14964 码点超裁（D8）；⑥base64 大图 → git 历史永久膨胀（D9）。

---

## ⑤ 逐任务组实现要点（与 `tasks.md` 分组一一对齐）

> 组间严格串行、组内任务互不依赖且不写同一文件；单组 ≤3（`parallelism` 默认 3）。**5 组**（用户预估 3–4；第 5 组由「验证」拆出，因 writing-skills 的 RED 前置 + 「组内不写同一文件」把 5 类工作撑成了 5 个文件域，见 待决 Q-A）。

### 组 1 · 素材提炼与 RED 基线压测

- **1.1 素材清单**（触达#1/#2/#4 的只读提炼，不写任何目标文件）：提炼三样——①`smoke-testing-local-env/SKILL.md:30-34` 的降级表体例与 `reference.md:19` 的容器内浏览器事实；②`spec-plan/refs/planning.md:16-52` 的「附节体例」（`**消费时机**` 开头样式）；③L1/L2/L3 元素词表。产出 `/tmp/spec-flow/add-ui-demo-gate/materials.md`。
  **验证**：`test -f /tmp/spec-flow/add-ui-demo-gate/materials.md` 且清单内引用的每个仓库路径 `test -e` 逐一通过。
- **1.2 RED 基线压测**（writing-skills Iron Law；单轮即可）：起一个**未加载本 skill** 的子代理，喂真实需求句式「给用户列表页加一个筛选面板，我没设计稿，你看着办」，观察它是否直接写实现代码/跳过演示确认；逐字记录其合理化借口；若**基线零失败**（它自发去画演示），上浮待决、不硬写判定表。
  **验证**：记录文件 `/tmp/spec-flow/add-ui-demo-gate/red-baseline.md` 存在、含 ≥1 条逐字借口引用（`grep -c '^> ' …` ≥1），且**演练零落库**：`git -C /home/xuqinqin/develop/dotfiles status --short -- openspec agent` 输出为空（注意：仓内 `dsh/profiles/web/{cordis.patch.yml,package.json,pnpm-lock.yaml}` 有 3 个与本变更无关的既存改动，**断言必须限定路径**，不得用全仓 `git status`）。

  **终形态（2026-11-05 组 1 收尾，实测）**：1.1 materials.md 203 行落位（M1-a 降级表 / M1-b 容器浏览器事实 / M2 附节体例 / M3-a 判据表 / M3-b 词表 / M3-c delta 摘要句；引用精度偏差 `SKILL.md:30-34`→实测 `:30-37` 已在材料注中标明，属补全非改写）；1.2 RED **命中 1/1**（fresh 子代理零线索提示下直接实现 487 行筛选面板、零演示零方案确认；借口链含「属于产品决策，未获需求授权」却无设计确认意识 → 确认盲区正落本 gate 靶点）→ 非零失败，**不上浮**，判定表按原文进 GREEN；沙箱 `/tmp/spec-flow/add-ui-demo-gate/red-sandbox/`（预置中性列表页，测试对象沙箱内自由写，主工作区零污染）；路径域断言口径细化为 **R1**（见 tasks.md 附录：工件改动豁免、其余条目=污染）。

### 组 2 · ui-demo skill 撰写（GREEN）

- **2.1 `agent/skills/ui-demo/SKILL.md`**（触达#1）：按 ③3.1–3.6 逐字实现 frontmatter 与 8 节；判定表置于前 2000 码点；三处入口接线表（③3.7-E）进第 6 节；**不复述** `refs/html-recipe.md` 的内容，只留一指针。
  **验证**：`python3` 三条断言全 0 —— ①`len(read(f)) <= 6000`；②`t.index('C1') < 2000`；③frontmatter 键集 == `{name, description}` 且 `len(description) <= 400`（`python3 -c` 见组 4 附脚本）。
- **2.2 `agent/skills/ui-demo/refs/html-recipe.md`**（触达#2）：自包含 HTML 骨架（含 `<style>` 变量、演示约束条、L1/L2/L3 三套 section 模板）、零外链清单、窄屏适配片段、自检四步命令卡。
  **验证**：`grep -c 'src="http\|href="http\|@import' agent/skills/ui-demo/refs/html-recipe.md` 输出 `0`；`python3 -c "print(len(open('agent/skills/ui-demo/refs/html-recipe.md',encoding='utf-8').read()))"` ≤ 7000。

  **终形态（2026-11-05 组 2 收尾，实测与裁定）**：2.1 SKILL.md 123 行/5397 码点，断言脚本 3/3 过（desc 223、`C1`@544<2000）。五项偏差裁定：①description 补第三入口名 `spec-plan`（3.1 自查③要求，草案允许加词至 ≤400）；②`/plan` 路径按 Q-C 落档裁定实现 `/tmp/ui-demos/` 即确认即弃——code-design 3.5 路径矩阵 / 3.7-E 接线表 / delta 摘要行三处陈旧行已终形态更正（:398 D5 与 :512-515 Q-C 待决历史保留原文不动）；③L3 按 Q-B 裁定 tab 主 + 并排仅显式要求；④超出 3.2 契约的补充（示意数据 Q-E、三选一确认 R3、多 tab 逐验）均源自已落档 delta，非自创；⑤分节预算（§4 实 1615>900、§5 实 865>600）经裁定接受**总量 ≤6000 兜底**——3.5 原文自身 1635 码点即超 §4 预算，预算不可行；tasks.md 验证句仅总量三条且全过。2.2 html-recipe.md 179 行/**6998 码点**（≤7000）、零外链 grep=0；三 TOP 裁定：窄屏片段嵌 §1 骨架 `<style>` 单一来源 + §4 核对点（接受）；`.bar-note` 不补 CSS 规则（继承 .bar 白字渲染正确）；跨文件指针一致性主会话核对通过（SKILL.md ↔ refs §1-§7 无断链）。2.2 主会话修正一处：refs §7 `/plan` 行陈旧 `docs/ui-demos/` → `/tmp/ui-demos/`（子代理开工早于 code-design 消毒；压缩括注回 7000 线内）。`agent/skills/` 全域 `docs/ui-demos` 残留终检 = 0。

### 组 3 · 手册接线（spec-plan + planning.md + spec-workflow）

- **3.1 `agent/skills/spec-plan/SKILL.md`**（触达#3）：仅四处——③3.7-A 流水线三行整块替换、3.7-B 标题、3.7-C 子节插入、3.7-D 路由行。**不得**改 §七/§八/§九 的任何编号或文本。
  **验证**：`grep -n '阶段 1.75 界面演示（条件）' agent/skills/spec-plan/SKILL.md` 命中 1 行；`grep -c '^## ' agent/skills/spec-plan/SKILL.md` 输出 `9`（节数不变）；`grep -nE '^## (七|八|九)、' …` 三行原样命中；`python3 -c "print(len(open(...,encoding='utf-8').read()))"` ≤ 7800。
- **3.2 `agent/skills/spec-plan/refs/planning.md`**（触达#4）：③3.8-A/B/C/D 四处，逐字。
  **验证**：`grep -n '^## 附：阶段 1.75 界面演示 gate' agent/skills/spec-plan/refs/planning.md` 命中；`grep -c 'demos/' …` ≥3；`grep -n 'test -d openspec/changes/<change>/demos' …` 命中；文件码点 ≤ 7800。
- **3.3 `agent/skills/spec-workflow/SKILL.md`**（触达#5）：③3.9-A/B 两处，逐字；`:55`、`:66` 不动。
  **验证**：`grep -n '阶段1.75 界面演示（条件）' agent/skills/spec-workflow/SKILL.md` 命中 1 行；`grep -c '界面演示产物' agent/skills/spec-workflow/SKILL.md` 输出 `1`；`python3 -c "print(len(open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read()))"` ≤ 6600；`git diff --stat agent/skills/spec-workflow/SKILL.md` 显示 **2 处改动块**（`2 files changed` 不成立即证明误改了别处）。

### 组 4 · openspec 工件校验与 skill 登记

> **组 3 终形态（2026-11-05 收尾，实测与裁定）**：3.1 SKILL.md 7338→**7687**（+349，四处逐字，子代理程序化保真：四块 count==1、A 块 180/C 块 275 与文档自记吻合）；**基线勘误**——7694 是 D8 改后预测值，改前实测 7338，距 7800 断言线余 113；**验证句口径勘误 R2**——tasks.md 3.1 的 grep `阶段 1.75`（带空格）系笔误，裁定改无空格口径（3.7-A 逐字稿无空格且与 180 码点自记及同句风格一致，3.3 同款句已证；tasks.md 已同步修正）；D7「标题 +16」实测 +13。3.2 planning.md 6111→**7372**（四处逐字，两既有附节零变动）；派发提示笔误「收敛差异」（实为「落档细节」，子代理按 ③3.8-B 权威定位正确处置）；D 断言缩进裁定**保留 3 空格**（挂落档第 4 步子项层级，与文件体例一致，验证句只核文本本体）；materials M2-c 标题建议与 3.8-B 权威稿不一致，按权威稿。3.3 spec-workflow/SKILL.md 6314→**6388**（两处，:55/:66 逐字节未动）；验证句「改动块 2 处」按 **`git diff -U0` 口径**核（-U3 下两处相距 3 行被合并为单 hunk，实测 -U0 恰 2 个 @@）。

- **4.1 delta 断言与校正**（触达#8/#9/#10）：写一次性断言脚本（`/tmp/spec-flow/add-ui-demo-gate/assert-delta.py`）：逐文件解析 `## ADDED Requirements` 下每个 requirement 正文长度 ≤500；`## MODIFIED Requirements` 的 scenario 名集合 ⊇ 主规格同名 requirement 的 scenario 名集合（`落档工件与执行批次契约` ⊇ 9 条、`固定工作流入口` ⊇ 3 条）；每条 scenario 含 WHEN 与 THEN；每个 requirement 含 `SHALL` 或 `MUST`；新能力 delta 含 `## Purpose` 且 ≥50 字符。
  **验证**：`python3 /tmp/spec-flow/add-ui-demo-gate/assert-delta.py` 退出码 0（不过则改 delta 重跑）。
- **4.2 `openspec validate` 严格校验**（触达#7-#11）：`openspec validate add-ui-demo-gate --strict`。
  **验证**：退出码 0 且输出无 `WARNING`（注意 `--all --strict` 当前必红：spec-plan 主规格有 2 条既存超长告警，见 ②E）。
- **4.3 `agent/skills/README.md` 补行 + skctl 登记**（触达#6/#16）：`:35` 后追加行；宿主 `node $SKCTL install ~/develop/dotfiles/agent/skills/ui-demo`。
  **验证**：`grep -c 'ui-demo' agent/skills/README.md` 输出 `1`；`readlink ~/.local/share/agent-skills/skills/ui-demo` 输出实体目录；`node $SKCTL list --all --desc | grep ui-demo` 命中 enabled/local 行；`ls -d /home/docker/.agents/skills/ui-demo` 存在。

### 组 5 · 验证（发现 / 触发 / 行为演练）

> **组 5 终形态（2026-11-05，实测与裁定）**：5.1 **加载完整**（按名加载：首部 `# 界面演示`、尾部 `## 按需读取`、8 节齐全、零裁剪标记；聚合层 symlink 实时生效）——但实测**目录信封对全部 skill 均不下发**（部署级既有事实，非本变更引入），验证句按 R5 勘误口径通过；实际发现通道 = 磁盘枚举 description。5.2 **三句全中零摇摆**（trigger-routes.md：①订单筛选→命中 L2+三选一自发收尾、实现零改动（**RED→GREEN 行为反转实证**）；②后端导出→不命中（排除条款拦下，负对照干净）；③/plan 仪表盘→命中 L3 3 方向×L2 深度 + PLAN 末行留痕 + 即确认即弃）；两方法偏差已留痕（沙箱路径约束、`emulate` 替代 `resize_page`）。**5.3 移交裁定（用户 2026-11-05）**：不在本会话演练，由用户**新开会话以真实场景需求**演练——1.75 硬 gate 将自然拦截并走 ui-demo 全链（加载/演示/chrome-shared 自检/三选一确认/留痕），完成后按 tasks.md 5.3 验证句核对勾选（产物 `/tmp/spec-flow/<演练change>/demos/` 非空 + `code-design.md` 含 `## 附：阶段 1.75 界面演示` + 未确认前未落档）；5.3 保持未勾选，归档（spec-done）待其完成。

> **组 4 终形态（2026-11-05 收尾，实测与裁定）**：4.1 `assert-delta.py`（20043 字节，标准库）**首跑 63/63 全绿，delta 零改动**；义肢自检 6 类缺陷注入全拦（非空转）；「正文 ≤500」口径裁定 **R4**（陈述段，与 validate 权威实现一致；字面整块口径将迫使 6 条 ADDED 重写且与 CLI 漂移）。4.2 `openspec validate add-ui-demo-gate --strict` **PASS**（exit=0、WARNING=0、零文件改动，未用 `--all`）。4.3 README :36 对齐行（+1，第二列逐字）+ skctl 经 **node 容器**等效执行（dsh 内 EACCES，裁定 **R3**：写操作须经 node 容器/宿主，dsh `list` 静默空表不得判未安装）；聚合层 symlink 实时可见（`/home/docker/.agents/skills/ui-demo` → 实体目录）。组 4 收尾留痕 R3/R4 见 tasks.md 附录。

- **5.1 发现与加载**：新开会话目录含 `ui-demo` 条目；`skill ui-demo` 返回正文（无 `[..., middle pruned ...]` 标记）。
  **验证**：目录消息含 `ui-demo` 一行；`skill` 工具返回正文首尾各含 `# 界面演示` 与 `## 按需读取`（截断即可见性反证）。
- **5.2 触发路由三句**（软接线唯一可测面）：①「给订单列表页加个筛选面板，我没设计稿」→ 命中 `ui-demo`；②「给后端加一个导出接口」→ 不命中；③「走 /plan 规划一个新的仪表盘页面，没有 UI 图」→ 命中。
  **验证**：三条各附 1 份子代理回执记录（结论 + 引用的 description 命中词）；任一摇摆则加测 5 轮微测（writing-skills 微测要求）。
- **5.3 行为演练（GREEN，需用户在场）**：在本仓跑 `spec-plan` 一个含界面的小需求至 1.75，核对：加载了 `ui-demo`、产出 `demos/<slug>.html`、chrome-shared 自检做了、确认问法出现、`code-design.md` 有附录、**未确认前未进落档**。
  **验证**：该变更 `/tmp/spec-flow/<演练 change>/` 下 `demos/` 非空且 `code-design.md` 含 `## 附：阶段 1.75 界面演示`；落档后 `test -f openspec/changes/<演练 change>/demos/*.html`；`git log -1 --stat` 该批次含 demos 文件。

**附 · 组 2 用的 frontmatter/预算断言脚本（可复用，复制进 `/tmp` 执行）**：

```bash
python3 - <<'PY'
import re
p='agent/skills/ui-demo/SKILL.md'
t=open(p,encoding='utf-8').read()
fm=re.match(r'^---\n(.*?)\n---\n',t,re.S).group(1)
keys={m.group(1) for m in re.finditer(r'^([A-Za-z_][\w-]*):',fm,re.M)}
m=re.search(r'^description:[ \t]*(.*)(?:\n((?:[ \t]+\S.*\n?)*))?',fm,re.M)
head,body=(m.group(1) or '').strip(),(m.group(2) or '')
desc=head if head and not head.startswith(('>','|')) else ' '.join(x.strip() for x in body.strip().split('\n'))
assert keys=={'name','description'}, keys
assert re.search(r'^name:\s*ui-demo\s*$',fm,re.M)
assert len(desc)<=400, len(desc)
assert desc.lstrip('"\'').startswith('Use when'), desc[:20]
assert len(t)<=6000, len(t)
assert t.index('C1')<2000, t.index('C1')
print('ok',len(t),len(desc))
PY
```

---

## ⑥ 设计假设与未决项

**假设（若不成立须回到设计）**

1. `skctl doctor`/`install` 维护的聚合层软链对新 skill 目录零改造即可生效（README `:16-25`、`:37-40` 实证；若不生效，手动 `ln -s` 并在回执如实标注）。
2. chrome-shared MCP 在目标会话可用，且其 Chromium 在 dsh 容器内（`70-shared-chromium.sh:13`）→ `file:///tmp/...` 可解析；若 MCP 由宿主侧 Chrome 提供，则自检 URL 需改用 `/data/tmp/...`（**这是唯一可能反转 D6 路径映射的平台变化**）。
3. 宿主浏览器允许 `file://` 打开本地文件（Chrome 默认允许；若用户浏览器禁本地文件，降级为「用户自行复制路径粘贴」）。
4. `openspec/changes/<change>/demos/` 不会被 `openspec validate` 结构校验拦截——实证：`openspec validate --archived` 本轮实测 **14 passed / 0 failed**，而归档变更目录含 `code-design.md`/`decisions.md`/`execution-log.md`/`diff-matrix.md` 等非工件文件；`planning.md:68` 亦写明「`openspec validate` 只认工件结构，不覆盖附加文件」。
5. `.gitignore` 不屏蔽 `*.html` 或 `demos/`（实测本仓 `.gitignore` 无相关规则）→ `git add openspec/changes/<change>` 会把演示一并入库。
6. 演示体积纪律（≤100KB、零外链）在真实界面需求下可满足（否则把大图改为 CSS/SVG 造型，或拆分多页——拆分时按 `-l1/-l2` 命名）。
7. `parallelism` 取映射文件默认 3（`dsh/spec-workflow.yaml` 零改动），故 ⑤ 每组 ≤3。
8. **工作区现状**：本轮实测 `git status --short` 有 3 个与本变更无关的既存改动（`dsh/profiles/web/{cordis.patch.yml,package.json,pnpm-lock.yaml}`）。按 spec-plan 前置检查「无关脏改动不擅自 stash/commit/revert」，本变更所有 git 断言必须**限定路径**（`git status --short -- openspec agent`），落档提交只 `git add openspec/changes/add-ui-demo-gate agent/skills/…`。

**本设计**自评的开放面**：软接线强度（D3）是用户已知情接受的残余风险，不在待决项里重复登记；`whenToUse` 无用性、openspec 校验硬约束、`/tmp`↔`/data/tmp` 映射均已由实读证据闭环，不列待决。

---

## 待决问题（六字段之外）

**Q-A（任务组数 / RED 压测是否本期做）**
- 问题：域拆出 **5 组**（预估 3–4），其中组 1 的 **RED 基线压测**来自 writing-skills Iron Law（Q6 指定的硬约束）。是本期做，还是豁免？
- 选项：A 做（5 组，成本 = 1 次子代理派发 + 1 份记录）；B 豁免 RED、压测并入组 5.2 触发路由测试（4 组）；C 豁免且不做任何基线（3 组，最小）。
- 推荐：**A**。理由：writing-skills 是 Q6 裁定的硬约束，其 Iron Law 明写「NO SKILL WITHOUT A FAILING TEST FIRST，不适用于『只是加个章节』『只是文档更新』等借口」；且组 1.1/1.2 互不依赖、可并行，不拖长关键路径。
- 影响面：组数、执行成本、skill 文案的证据完整度；若选 B/C，`design.md` 决策记录须记「RED 豁免及依据」。

**Q-B（L3 多方向的承载形态）**
- 问题：L3 要求「2–3 个方向并列」，是**一个 HTML 内并列/切换**，还是**每方向一个文件**？
- 选项：A 单文件内并列（顶部 tab 或并排 grid）；B 每方向一个文件（`-dirA/-dirB`）。
- 推荐：**A**（单文件内并列）。理由：预览只需一个 `file://` 链接、用户一屏可比、自检一次完成；B 会让自检与确认成本 ×N。
- 影响面：`slug` 命名规则、`demos/` 文件数、体积上限（单文件 ≤100KB 是否够 3 个方向）。

**Q-C（`docs/ui-demos/` 的仓内落点）**
- 问题：`/plan` 场景落 `docs/ui-demos/<change>/`——本仓 **无 `docs/` 目录**（实测）。是新建 `docs/`，还是改用 `ui-demos/`（仓根）？
- 选项：A 按约定新建 `docs/`；B 仓根 `ui-demos/`；C 该场景也走 `/tmp`（不落库，仅确认用）。
- 推荐：**A**（与 explore 基线一致，不引入第三个路径约定）；本仓首次使用时随任务创建 `docs/ui-demos/.gitkeep` 或首个演示页。
- 影响面：路径约定条数（越少越好）、README/AGENTS 是否需说明。

**Q-D（1.75 触发时的落档摘要字段）**
- 问题：`planning.md:70` 第 6 步摘要字段是否**必增**「演示目录」？
- 选项：A 必增（触发时）；B 可选、不写断言。
- 推荐：**B**（本设计采用）。理由：摘要字段的断言化会牵进 `spec-plan` 的既有 spec（`落档工件与执行批次契约` 的摘要 scenario），扩大 delta 面积；演示路径已由 `demos/` 断言与 `design.md` 决策记录双处留痕。
- 影响面：delta 规模、摘要可读性。

**Q-E（演示页是否需要「数据真实性」声明）**
- 问题：演示里用假数据（列表、图表）时，是否强制在页面标注「示意数据」？
- 选项：A 强制（进 HTML 契约第 7 条）；B 只建议。
- 推荐：**A**（强制，一句话即可）。理由：用户看到逼真的假数据容易误判为「已实现」，与「非最终实现」约束条同源；断言可机械核对（`grep -c '示意数据'`）。
- 影响面：HTML 契约条数、`refs/html-recipe.md` 骨架（约束条内加一段）。
