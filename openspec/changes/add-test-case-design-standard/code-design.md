# add-test-case-design-standard · 代码级设计（阶段 1.7）

- 角色：代码设计线（阶段 1.7）。输入：`line-a.md` / `line-b.md` / `diff-matrix.md`（已逐字读全）；仓库基线 `BASE=a3412d793b3bb3db5e9a5e9b4f08928a4ce3d870`（= 当前 HEAD）。
- 结论先行：**不推翻收敛留痕**。落点 = 1 个新文件 + 文档子目录化（git mv ×2 + 冻结区授权三行）+ 3 处指路 + 1 处 D6 自检修复 + 2 条 ADDED Requirement + 1 条 MODIFIED「文档结构兼容约束」（子目录化为落档后用户裁决并入，见 ④D15；ADDED 由 1 条拆分系 validate >500 字符警告，见 ④D10）；tasks 4 组（组 1 新文件+子目录化 / 组 2 接线+断言 / 组 3 D6 修复 / 组 4 归档），组间串行；验证 V1–V9。
- `writing-skills` 已加载（技能名 `writing-skills`，加载成功）。其「重参考外移为独立文件」「交叉引用不用 `@`」「description 只写触发条件」「结构模板优先于禁令」作为本次设计硬约束；测试形态按 reference/technique 文档的「检索 + 应用」执行（见 D12），不按 discipline skill 跑压力场景。
- 本文件是设计期工件，路径 `/tmp/spec-flow/add-test-case-design-standard/code-design.md`，**不入仓**；阶段 2 是否按先例复制为 `openspec/changes/add-test-case-design-standard/code-design.md` 见 A12。

---

## ① 触达面清单

### 1.1 写集（全部位于 dotfiles 根仓）

| # | 路径（仓） | 动作 | 改动意图 | 关键改动点 |
| --- | --- | --- | --- | --- |
| 1 | `agent/skills/smoke-testing-local-env/refs/test-case-design.md`（dotfiles 根仓） | **新建** | 独立承载「需求→测试点→11 列用例设计稿→七列入库」设计期方法论，不混入 SKILL.md | 六节定稿：§1 三时机与边界 / §2 五步 / §3 测试点清单 / §4 11 列用例表 / §5 覆盖说明与风险 / §6 11→7 映射；≤160 行；头部链接 `../SKILL.md` 与同级 `reference.md`；表头逐字见 ③3.2 |
| 2 | `agent/skills/smoke-testing-local-env/SKILL.md`（dotfiles 根仓） | 编辑 | 冻结区授权三行（L19/L20/L57）链接目标更新 + 阶段 3 建库动作点接入设计方法入口 | L19/L20/L57 三行锚点编辑：仅链接目标加 `refs/` 前缀，链接文本与用途描述逐字不变（old/new 见 ③3.3.0）；L108 **行尾同行追加半句**（188 行不变、L109+ 零位移）；old/new 见 ③3.3.1 |
| 3 | `agent/skills/smoke-testing-local-env/refs/reference.md`（dotfiles 根仓） | **git mv**（根 → refs/）+ 编辑 | 子目录化纯移动（内容零改动）后在「能力组建库」与「七列用例库」接缝处接入设计方法 | 迁移 = `git mv` R100 纯移动；§6.2 代码块闭合 fence（迁移后仍为该文件 L385）后插 1 行 blockquote 指路；**净 +1 行**（583→584）；节号零新增；old/new 见 ③3.3.2 |
| 4 | `agent/skills/smoke-testing-local-env/refs/project-profile-template.md`（dotfiles 根仓） | **git mv** + 编辑 | 子目录化纯移动后在画像 §7「用例入口→用例库」转写点接入设计方法 | 迁移 = `git mv` R100 纯移动；L79 尾注扩写；行数不变（95）；old/new 见 ③3.3.3；**用纯文本文件名，不用相对链接**（模板会被复制到项目仓） |
| 5 | `agent/skills/spec-plan/refs/routing.md`（dotfiles 根仓） | 编辑 | D6 顺带修：自检脚本白名单解析兼容 flow/block 两形态 | L49 单行 flow 正则 → 4 行（`src` / `flow` / `block` / `wl`），行首锚定排除注释；67→70 行；old/new 见 ③3.4 |
| 6 | `openspec/changes/add-test-case-design-standard/.openspec.yaml` + `proposal.md` + `design.md` + `tasks.md` + `specs/smoke-testing-local-env/spec.md`（dotfiles 根仓） | 新建（阶段 2 落档，**不占任务组**） | 轻量变更四件套 + 脚手架标记 | 先 `openspec new change add-test-case-design-standard` 产 `.openspec.yaml`；spec delta 仅 `## ADDED Requirements` 2 条 + 4 Scenario（定稿见 ③3.5）；tasks 从组 1 起（③3.6） |
| 7 | `openspec/specs/smoke-testing-local-env/spec.md`（dotfiles 根仓） | 归档 sync | 主规格 8→10 条 Requirement、14→18 Scenario | 只追加、删除列 = 0；既有 8 条逐字不动；归档命令自动完成（⑤5.4） |
| 8 | `openspec/changes/archive/<归档日>-add-test-case-design-standard/**`（dotfiles 根仓） | rename | 归档（主体 R100；`tasks.md` 因归档后勾 4.1 可能为 R0xx） | `openspec archive ... --yes` 自动日期前缀；提交用 `git add -u` 暂存旧目录删除 + 精确 add 新目录/主规格（见 ③3.8） |

### 1.2 负面清单（禁碰）

- `SKILL.md` L1–60 冻结区**除 MODIFIED 授权的 L19/L20/L57 三行链接目标更新外**零字节改动（含 L3 description）；配套文件表不增行（新文件登记缺口以 L108 指路补偿）；D1 已裁触发词不改。
- `refs/reference.md` L1–18 逐字节冻结（迁移为纯移动，内容不变）；既有 §1–§9 全部子节一个不少、**不新增子节**；`refs/reference.md:19` 活行号引用（add-ui-demo-gate，迁移前路径 `reference.md:19`）保持有效——add-ui-demo-gate 工件本身**不改**，其引用按新路径解析（proposal Impact 留痕）。
- `scripts/` 保持 skill 根、零触碰（SKILL.md L21–22 链接与 L99 命令路径因此全部不变）。
- 任何项目仓的 `smoke/cases.md`：本变更只定标准与映射，不代任何项目建库/改库。
- `dsh/profiles/web/` 3 个在途脏文件（`cordis.patch.yml` / `package.json` / `pnpm-lock.yaml`）——**只读** `cordis.patch.yml` 作 V8 证据，不写。
- `openspec/changes/add-subagent-control-and-coordination/` 3 个在途脏文件；另实测 `?? agent/skills/spec-apply/refs/coordination.md`（Q1 已裁按外部在途）——均不触碰、不暂存、不清理；`add-ui-demo-gate/` 目录零写入。
- `openspec/specs/spec-plan/spec.md`（13 条 Requirement 零管辖自检，D6 不需 spec delta）；`dsh/spec-workflow.yaml`（只读，V8 输入）；`agent/skills/README.md`（仅 skill 级清单，无文件级登记）。
- 不推送远程；不改 `.gitignore`；不跑 `openspec validate --all --strict`。

### 1.3 事实基线（本设计复测，2026-11-19）

| 项 | 实测 |
| --- | --- |
| HEAD / 分支 | `a3412d7`，master |
| 行数 | SKILL.md 188 / reference.md 583 / project-profile-template.md 95 / routing.md 67 |
| reference 节号 | `## [0-9]+.` = 9，`### [0-9]+\.[0-9]+` = 38（§1–§9 子节全在；L465/L473 码块伪标题无编号后缀，被该模式天然排除） |
| 主规格 | 8 Requirement / 14 Scenario / 109 行 |
| 白名单 / 路由 | `cordis.patch.yml` L226–242 block-style 8 项；`spec-workflow.yaml` 7 键 + 6 fallback = 13 条路由 |
| 当前自检 | 旧脚本白名单解析为 0 项、13 条路由全部误报、exit 1（实测） |
| 外部脏项 | 落档期动态台账（6→7→8 漂移）：dsh/profiles/web 3 + add-subagent 3 + 未跟踪 `agent/skills/spec-apply/refs/coordination.md` + `agent/skills/spec-apply/refs/execution.md`；组 4 现场复核（Q1 已裁处置口径） |
| refs/ 目录 | BASE 时点不存在（skill 根平铺 3 文档 + scripts/）；本变更新建并收敛 3 文档入内（D15） |

---

## ② 证据锚

| 模块 | file:line 代码事实 | 对本设计的约束 |
| --- | --- | --- |
| 新文件 `test-case-design.md` | **新建**；结构由本文件 ③3.1/③3.2 定义 | 无既有行号可锚；写入用整文件创建，不用 sed |
| `SKILL.md` | `:108` = `2. 读库或建库：有 \`smoke/cases.md\` 直接读在用条目；无则按 reference §6.2 的能力组 A–G 建库，表头七列固定（reference §6.3）`；`:19` = `\| [reference.md](reference.md) \| 完整操作手册：命令模板、浏览器配方、陷阱全表 \|`；`:20` = `\| [project-profile-template.md](project-profile-template.md) \| 项目画像模板（复制到各项目仓填写） \|`；`:57` = `- 无 → 用 \`scripts/recon.sh\` 采集事实现场补齐，并建议落盘到项目仓（模板见 [project-profile-template.md](project-profile-template.md)）`；`:21-22` = scripts 两行（不动）；`:69` = 「话术有歧义…问用户一句，不自行猜」 | L108 是唯一建库动作点；L19/L20/L57 是 MODIFIED 授权的三个链接行（仅目标加 refs/ 前缀）；L21–22 与 scripts 相关行零改动；L69 是两域问询边界的执行期锚 |
| `reference.md` | `:385` = §6.2 代码块闭合 fence；`:386` = 空行；`:387` = `### 6.3 用例库：smoke/cases.md`；`:300-307` = §5.1 三层证据表；`:373-385` = §6.2 能力组 A–G；`:399-414` = §6.3 七列语义与取值约束；`:499-506` = §6.5 逐项执行纪律 | 插入点必须在 L385 之后、L387 之前；净 +1 行只能占「fence 后原空行」与「标题前」之一；七列契约只引用不改写；执行顺序口径引 §6.5 |
| `project-profile-template.md` | `:79` = `> 本表是用例库的输入：编写 / 补充 \`smoke/cases.md\` 时，按「功能 → 入口路径 → 前置数据」逐行转成用例（格式见技能 reference §6.3）。`；`:91` 也引 §6.3（不改） | L79 是用例入口→用例库的转写点；L91 是归档约定，再加即第四处指路（V4 口径破坏），不加 |
| `routing.md` | `:49` = `const wl=[...fs.readFileSync(d+"profiles/web/cordis.patch.yml","utf8").matchAll(/-\s*\{\s*provider:\s*([\w.\-]+),\s*model:\s*([\w.\-]+)\s*\}/g)].map(x=>x[1]+"/"+x[2]);`；`:39-55` 自检脚本块；`:59` 白名单硬约束；全仓唯一 `routing.md:15` 引用在 `add-ui-demo-gate/code-design.md:400` 的备选方案描述中（在插入点 L49 之前） | 只替换 L49；脚本仍在同一 `node -e '…'` 单引号内，新增行不得含单引号；改后 67→70 行，L15 引用不受影响 |
| `dsh/profiles/web/cordis.patch.yml`（只读） | `:223-242` = `subagent-model-selection-settings.config.allowedModels`，block-style 8 项；`:204` = `leasePath: !!js dshHomePath(...)`（自定义 tag）；`:16` 为当前在途 diff（`agent-default-model`，与白名单无关） | 证明旧正则 flow-only 必然空；证明 YAML 结构化解析会遇 `!!js` 警告；证明白名单 8 项基线在当前工作区稳定 |
| `dsh/spec-workflow.yaml`（只读） | 7 个 models 键 + 6 个 fallback = 13 条路由；全部 ⊆ 8 项白名单 | V8 的映射侧基数 13；不得为 14 |
| `openspec/specs/smoke-testing-local-env/spec.md` | `:9` 起 8 条 Requirement、14 Scenario；`:88-95` = 「文档结构兼容约束」；`:109` 文件末 | 冻结区/节号 Requirement 是 V1/V2 的规格级依据；归档后 9/16、删除列 0 |
| `openspec/changes/add-test-case-design-standard/` | **新建**（阶段 2）；体例锚 = `openspec/changes/archive/2026-11-19-improve-smoke-skill-codepoint-slim/{.openspec.yaml,proposal.md,design.md,tasks.md,specs/smoke-testing-local-env/spec.md}` | 先 `openspec new change` 产 `.openspec.yaml`；四件套体例照抄先例；tasks 从组 1 起（③3.6） |
| `openspec/changes/archive/2026-11-19-improve-smoke-skill-codepoint-slim/` | `.openspec.yaml` + 四件套 + `specs/smoke-testing-local-env/spec.md`（仅 `## ADDED Requirements`）；`git show --name-status a3412d7` = R100×6 + R099 + M | 落档体例、spec delta 体例、归档 rename 体例的可照抄先例 |
| `agent/skills/README.md` | `:20-27` 仅列 skill 名与来源，无 skill 内文件级清单 | 新文件不需要在此登记；不要为此改 README |
| 分发 | `~/.agents/skills/smoke-testing-local-env` → dotfiles 实体 symlink；`~/.agents/skills/spec-plan` 同 | 新文件/指路改完即时生效，无构建；V4 只需仓内文件存在 |

---

## ③ 接口与数据形状

本变更是「文档 + 断言」工程：没有运行时代码接口，数据形状 = **新文件节结构 / 表头 / 指路锚串 / 正则 / spec delta / tasks 结构 / 验证命令**。

### 3.1 新文件 `refs/test-case-design.md` 节结构（硬上限 160 行）

| 节 | 精确标题 | 内容槽位 | 预算 |
| --- | --- | --- | --- |
| 头部 | `# 测试用例设计标准` | 1 行定位 + 链 `SKILL.md` / `reference.md` §6.4、§6.5；声明「设计期方法论」 | 4 |
| §1 | `## 1. 适用时机与输出分级` | `### 1.1 三个时机` 三行表（建库 / 单任务补新用例 / 直接交付）；`### 1.2 与执行期的边界` 5 条（设计期假设继续 / 执行期必问 / 执行期不回补设计稿 / 假设被否原地修订 / P0 仅设计期） | 20 |
| §2 | `## 2. 工作步骤（五步）` | 五步逐条；第 4 步逐字含「需要确认的问题」「我做出的假设」；第 5 步含「不臆造需求」「待确认」 | 11 |
| §3 | `## 3. 输出格式一：测试点清单` | 5 列表头 + 1 行示例 + 2 条规则（TP-001 递增 / 对应需求可追溯） | 8 |
| §4 | `## 4. 输出格式二：测试用例表（11 列）` | 11 列表头 + 1 行示例；`### 4.1 列口径与硬规则` 7 条（TC-001、P0–P2 定义、步骤与预期同号、数据具体、禁笼统、四列不迁移、待确认不入库）；`### 4.2 必覆盖测试类型（7 类）`；`### 4.3 接口型附加覆盖（8 项）`；`### 4.4 页面 / App 型附加覆盖（6 项）` | 30 |
| §5 | `## 5. 输出格式三：覆盖说明与风险` | `### 5.1 需求覆盖情况`、`### 5.2 仍需确认的问题`、`### 5.3 主要测试风险与建议补充的测试类型`，各 1–2 行骨架 | 9 |
| §6 | `## 6. 与用例库衔接：11 列 → 七列` | 12 行映射表（11 列去向 + 1 行「证据要求」派生）；4 条规则（组归属 / 七列与编号契约不变 / 追溯粒度 / 假设被否） | 22 |
| 合计 | | | 目标 100–140；**硬上限 160** |

定稿骨架（执行侧按此展开，不增删节）：

```markdown
# 测试用例设计标准

> 本文件是 [SKILL.md](../SKILL.md) 阶段 3「准备测试用例」的设计期方法论：需求 → 测试点 → 11 列用例设计稿 → 收敛为 `smoke/cases.md` 七列用例库。执行期纪律仍见 [reference.md](reference.md) §6.4/§6.5。

## 1. 适用时机与输出分级

### 1.1 三个时机

| 时机 | 何时触发 | 输出形态与去向 |
| --- | --- | --- |
| 建库 | 阶段 3 无 `smoke/cases.md`，需按 A–G 首建 | 完整三段式设计稿；按 §6 收敛七列入库；TC 编号不入库 |
| 单任务补新用例 | 已有用例库，本任务新增 1–N 条 | 增量：新增用例行（11 列）+ 一句话覆盖说明；按组续接入库 |
| 直接交付用例 | 用户直接索要测试用例（被测项目/冒烟语境，或点名本文件） | 完整三段式即最终交付物；不建库、不入库、不执行 |

### 1.2 与执行期的边界

- 设计期信息不足：先列「需要确认的问题」与「我做出的假设」，在假设下继续；用户在场确认一次，不在场按假设继续并在交付物标注。
- 执行期话术/判定歧义：必问不猜（SKILL.md L69 / reference §6.1、§6.5），不把设计期的「假设继续」带进执行判定。
- 执行期不回补设计稿：完整三段式只在 §1.1 三个时机产出；常规冒烟按库执行，不重跑设计流程。
- 假设事后被否：按既有「原地修订、编号不变」改库内行，不新增编号（reference §6.3）。
- P0/P1/P2 仅设计期口径：不改变执行期按 `record.md` 编号集升序执行（reference §6.5）。

## 2. 工作步骤（五步）

1. **提炼测试点**：从需求提取功能点 / 业务规则 / 输入输出 / 状态流转 / 关键约束，落成 §3 清单。
2. **识别测试类型**：正常 / 异常 / 边界 / 空值与非法值 / 权限 / 并发与重复提交（幂等）/ 兼容性；接口型、页面型再补 §4.3/§4.4 附加项。
3. **设计用例**：按 §4 的 11 列逐条写；步骤编号、数据具体、预期可判定。
4. **信息不足**：先列「需要确认的问题」与「我做出的假设」，再在假设下继续（边界见 §1.2）。
5. **不臆造需求**：需求没有的规则不写进预期；无法确定标「待确认」；未决用例不入库、不执行。

## 3. 输出格式一：测试点清单

| 编号 | 模块 | 测试点 | 对应需求/规则 | 测试类型 |
| --- | --- | --- | --- | --- |
| TP-001 | 登录 | 手机号必填且 11 位 | R1-1 | 异常/空值 |

- 编号 TP-001 递增；测试类型取 §2 第 2 步枚举，可多值（用「/」连接）。
- 「对应需求/规则」写需求条款号或原文短句，保证可追溯。

## 4. 输出格式二：测试用例表（11 列）

| 用例ID | 模块 | 用例标题 | 优先级 | 测试类型 | 前置条件 | 测试数据 | 操作步骤 | 预期结果 | 覆盖需求/规则 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TC-001 | 登录 | 手机号+验证码正常登录 | P0 | 正常 | 画像 §5 已发码账号 | 13800138000 / 123456 | ①打开 `/login` ②填手机号与库中验证码 ③提交 | ①进入 `/account` ②`account_token` 新增 1 行 | R1-1 | — |

### 4.1 列口径与硬规则

- 用例ID：TC-001 起三位递增，同批不跳号；仅设计期使用。
- 优先级：P0=核心主流程/阻断级；P1=重要异常或边界；P2=一般场景/兼容性；仅设计期口径，不改变执行顺序。
- 操作步骤用 ①②③ 编号；预期结果与步骤同号对应，逐步可判定。
- 测试数据写具体值（账号、码值、边界值、超长/特殊字符样例），禁用「合法数据」「若干」。
- 预期结果写可观察、可判定的终态（UI/接口/落库至少一项可判定），禁止「验证功能正常」「页面正常显示」类笼统描述。
- 覆盖需求/规则、备注、优先级、用例ID 仅设计期使用，不迁移入库（§6）。
- 标「待确认」的用例不入库、不执行；需求信息不足时按 §2 第 4 步先列问题与假设。

### 4.2 必覆盖测试类型（7 类）

正常 / 异常 / 边界 / 空值与非法值 / 权限 / 并发与重复提交（幂等）/ 兼容性。

### 4.3 接口型附加覆盖（8 项）

必填校验 / 参数类型 / 边界值 / 鉴权 / 错误码 / 响应结构 / 幂等重复请求 / 依赖服务异常；主要落能力组 C/F。

### 4.4 页面 / App 型附加覆盖（6 项）

交互流程 / 必填校验 / 提示文案 / 返回刷新中断 / 不同角色权限 / 兼容性；主要落能力组 A/B/D/E。

## 5. 输出格式三：覆盖说明与风险

### 5.1 需求覆盖情况

逐条需求标注已覆盖 / 部分覆盖 / 未覆盖 + 对应用例ID。

### 5.2 仍需确认的问题

编号 + 问题 + 影响用例 + 当前假设 + 需谁确认；未决项对应的用例标「待确认」。

### 5.3 主要测试风险与建议补充的测试类型

风险 + 影响面 + 建议补充的类型（如并发、兼容性、依赖异常）。

## 6. 与用例库衔接：11 列 → 七列

| 设计稿列 | 入库去向 |
| --- | --- |
| 用例ID | 不迁移；TC 编号仅设计期递增，入库按 `<组>-<两位序号>` 续接 |
| 模块 | 决定入库组：接口型主要 C/F，页面型主要 A/B/D/E |
| 用例标题 | → 用例列（一句话场景名） |
| 优先级 | 不迁移；P0/P1/P2 仅设计期口径 |
| 测试类型 | → 类型列（正常→正，其余→反），并决定证据口径 |
| 前置条件 | → 前置列（引用画像条目，不复制画像） |
| 测试数据 | 并入前置列/步骤列的具体值，不单列 |
| 操作步骤 | → 步骤列（①②③ 编号子步） |
| 预期结果 | → 期望结果列（可判定终态） |
| 覆盖需求/规则 | 不迁移；需求级追溯止于设计稿 |
| 备注 | 不迁移；「待确认」未决项随用例拦截，不入库 |
| （派生）证据要求 | 无来源列；按测试类型+模块依 reference §5.1 三层证据口径派生（UI 截图 / 端点与状态码 / 表与主键） |

- 组归属：接口型附加主要落能力组 C/F，页面型主要落 A/B/D/E（§4.3/§4.4）。
- 入库契约不变：七列固定、`<组>-<两位序号>` 续接（reference §6.3）；TC 编号与优先级不入库。
- 需求级追溯止于设计稿；库内追溯粒度 = 能力组（reference §6.1）。
- 假设被否 → 原地修订库内行，编号不变（reference §6.3）。
```

### 3.2 表头形状（逐字，V3 按此 grep）

测试点清单（5 列）：

```markdown
| 编号 | 模块 | 测试点 | 对应需求/规则 | 测试类型 |
| --- | --- | --- | --- | --- |
```

测试用例表（11 列，顺序不可变）：

```markdown
| 用例ID | 模块 | 用例标题 | 优先级 | 测试类型 | 前置条件 | 测试数据 | 操作步骤 | 预期结果 | 覆盖需求/规则 | 备注 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
```

七列契约（引用 reference §6.3，零改动）：

```markdown
| 编号 | 用例 | 类型 | 前置 | 步骤 | 期望结果 | 证据要求 |
| --- | --- | --- | --- | --- | --- | --- |
```

### 3.3 锚点编辑：授权三行（3.3.0）+ 三处指路（3.3.1–3.3.3）

编辑纪律：一律锚点字符串替换（禁按行号 `sed -i`）；每次编辑前先 `grep -cF` 验证 old 串唯一。

#### 3.3.0 SKILL.md 冻结区授权三行（L19/L20/L57，仅链接目标加 `refs/` 前缀）

old/new 成对（链接文本与用途描述逐字不变）：

```text
| [reference.md](reference.md) | 完整操作手册：命令模板、浏览器配方、陷阱全表 |
→
| [reference.md](refs/reference.md) | 完整操作手册：命令模板、浏览器配方、陷阱全表 |

| [project-profile-template.md](project-profile-template.md) | 项目画像模板（复制到各项目仓填写） |
→
| [project-profile-template.md](refs/project-profile-template.md) | 项目画像模板（复制到各项目仓填写） |

- 无 → 用 `scripts/recon.sh` 采集事实现场补齐，并建议落盘到项目仓（模板见 [project-profile-template.md](project-profile-template.md)）
→
- 无 → 用 `scripts/recon.sh` 采集事实现场补齐，并建议落盘到项目仓（模板见 [project-profile-template.md](refs/project-profile-template.md)）
```

前提：三个 old 串在 SKILL.md 内各自 `grep -cF` =1；本编辑与 L108 指路（3.3.1）同文件不同行，先做 3.3.0 或先做 3.3.1 均可，行号互不影响（都在 L1–108 内同行替换/追加，行数不变）。

#### 3.3.1 SKILL.md L108（同行追加，188 行不变）

old（整行，唯一）：

```text
2. 读库或建库：有 `smoke/cases.md` 直接读在用条目；无则按 reference §6.2 的能力组 A–G 建库，表头七列固定（reference §6.3）
```

new（整行，仅行尾追加）：

```text
2. 读库或建库：有 `smoke/cases.md` 直接读在用条目；无则按 reference §6.2 的能力组 A–G 建库，表头七列固定（reference §6.3）；测试点提炼与用例设计方法见 [test-case-design.md](refs/test-case-design.md)
```

唯一性检查：`grep -cF '2. 读库或建库：有 `smoke/cases.md` 直接读在用条目' agent/skills/smoke-testing-local-env/SKILL.md` = 1。

#### 3.3.2 `refs/reference.md` §6.2 代码块后（净 +1 行；先 git mv 迁移后编辑）

old（三行：闭合 fence / 空行 / §6.3 标题；组合唯一）：

````text
```

### 6.3 用例库：smoke/cases.md
````

new（四行：闭合 fence / 空行 / 指路 blockquote / §6.3 标题；相对 old **+1 行**）：

````text
```

> 设计期方法论（需求 → 测试点 → 11 列用例设计稿 → 七列入库）见 [test-case-design.md](test-case-design.md)。
### 6.3 用例库：smoke/cases.md
````

说明：指路行与 `### 6.3` 之间不留空行，是为了守住净 +1（583→584）；引用块结束与 ATX 标题起始可相邻，Markdown 块级边界成立。若实施时渲染异常，**不改行数**，把 blockquote 改成同位置普通段落即可。指路链接 `[test-case-design.md](test-case-design.md)` 在 `refs/` 内两文件同级，目标无前缀；本编辑发生在 git mv 之后（迁移时纯移动，此步才改内容）。

#### 3.3.3 `refs/project-profile-template.md` L79（尾注扩写，行数不变；先 git mv 迁移后编辑）

old（整行，唯一）：

```text
> 本表是用例库的输入：编写 / 补充 `smoke/cases.md` 时，按「功能 → 入口路径 → 前置数据」逐行转成用例（格式见技能 reference §6.3）。
```

new（整行）：

```text
> 本表是用例库的输入：编写 / 补充 `smoke/cases.md` 时，按「功能 → 入口路径 → 前置数据」逐行转成用例（格式见技能 reference §6.3；设计方法见技能 `refs/test-case-design.md`）。
```

说明：这里**必须用纯文本文件名**（含 `refs/` 前缀），不能写相对链接——模板会被复制到项目仓，相对链接在项目仓必断；写前缀让读者回到 skill 目录后能直接按路径找到。SKILL.md 用 `refs/` 前缀链接、`refs/reference.md` 用同级链接，各按所在位置取最短正确形态。

### 3.4 routing.md 自检修正（D6）

修正目标：白名单解析兼容两种形态——flow（`- { provider: x, model: y }`）与 block（`- provider: x` 换行 `model: y`）；行首锚定，避免把注释行当白名单；真实文件解析 8 项、13 条路由全部 ⊆ 白名单、exit 0。

**before（`routing.md:49`，唯一一行）：**

```js
const wl=[...fs.readFileSync(d+"profiles/web/cordis.patch.yml","utf8").matchAll(/-\s*\{\s*provider:\s*([\w.\-]+),\s*model:\s*([\w.\-]+)\s*\}/g)].map(x=>x[1]+"/"+x[2]);
```

**after（替换为 4 行；仍在 `node -e '…'` 单引号内，新增行不含单引号）：**

```js
const src=fs.readFileSync(d+"profiles/web/cordis.patch.yml","utf8");
const flow=/^[ \t]*-[ \t]*\{[ \t]*provider:[ \t]*([\w.\-]+)[ \t]*,[ \t]*model:[ \t]*([\w.\-]+)[ \t]*\}/gm;
const block=/^[ \t]*-[ \t]*provider:[ \t]*([\w.\-]+)[ \t]*\r?\n[ \t]*model:[ \t]*([\w.\-]+)/gm;
const wl=[...new Set([...src.matchAll(flow),...src.matchAll(block)].map(x=>x[1]+"/"+x[2]))];
```

解析策略说明：

- `flow` 覆盖 block 序列项 + flow 映射（`- { provider: x, model: y }`），即 D6 所述 flow-style。
- `block` 覆盖 `- provider: x` + 下一行 `model: y`，即当前 `cordis.patch.yml` L226–242 的真实形态。
- 两遍 `matchAll` 取并集 + `Set` 去重；两种形态同时存在也只计一次。
- `^[ \t]*` + `m` 标志把匹配锚到列表项行首，注释行 `# - provider: …` 不入选；不锚定会把注释当白名单，造成「假通过」。
- 不使用 YAML 结构化解析 `cordis.patch.yml`：该文件 L204 含 `leasePath: !!js dshHomePath(...)` 自定义 tag，解析会发 `TAG_RESOLVE_FAILED` 警告；且自检会被无关节的 YAML 合法性绑架（一个不相干条目写错就整体失败）。

### 3.5 spec delta 定稿（`openspec/changes/add-test-case-design-standard/specs/smoke-testing-local-env/spec.md`）

定稿 = **2 条 ADDED Requirement + 4 Scenario**（本节原文为 1 条 + 2 Scenario，落档校验时 `openspec validate --strict` 报「Requirement text >500 characters」警告，按其建议拆分——「用例设计标准」（五步 + 接口 8 项 + 页面 6 项 + 三段式分级）与「设计稿入库收敛契约」（四列不迁移 + 七列续接 + 证据要求派生 + 优先级边界 + 待确认未决不入库）；语义零变化，D10 预留的「入库收敛契约独立演化」方向一致）：

1. `### Requirement: 用例设计标准` + Scenario ×3：建库输出完整三段式 / 直接索要用例按标准交付设计稿（不建库不执行）/ 单任务补新用例输出增量。
2. `### Requirement: 设计稿入库收敛契约` + Scenario ×1：11 列收敛七列时 TC 编号、优先级、覆盖需求/规则、备注四列不迁移；编号按 `<组>-<两位序号>` 续接；「证据要求」按 reference §5.1 三层证据口径派生。

权威全文 = 落档文件本身（specs/smoke-testing-local-env/spec.md，已过 validate --strict 零警告）。

### 3.6 tasks.md 形状（4 组，组间串行）

```markdown
## 1. 新文件与子目录化（2 任务，可并行）

- [ ] 1.1 新建 refs/test-case-design.md（按 code-design ③3.1/③3.2 定稿，≤160 行）；验证：V3 + V5（新文件 ≤160）
- [ ] 1.2 git mv reference.md 与 project-profile-template.md 入 refs/（纯移动）+ SKILL.md L19/L20/L57 授权三行链接更新（③3.3.0）；验证：迁移即纯移动 diff 为空 ×2 + SKILL.md 188 行 + 授权行外 L1–60 逐字节一致

## 2. 三处指路与断言（2 任务，串行）

- [ ] 2.1 三处指路（SKILL.md L108 → refs 链接 / refs/reference.md L385 后 / refs/project-profile-template.md L79；锚点编辑，先 grep -c 唯一性）；验证：V1 + V2 + V4
- [ ] 2.2 V1–V5 + V9 全绿 → 勾 tasks → 提交 ②（skill 整目录 + tasks.md，见 ③3.8）

## 3. D6 自检修复（2 任务，串行）

- [ ] 3.1 routing.md L49 单行 → 4 行双形态正则（锚点编辑）；验证：V8 静态
- [ ] 3.2 真实文件验证 + 混合样例；提交 ③（routing.md + tasks.md，精确路径）

## 4. 归档（单任务，依赖组 2/3 提交后的干净窗口）

- [ ] 4.1 干净窗口 + V6a + `openspec archive add-test-case-design-standard --yes` + V6b/V7 + 提交 ④（`git add -u` 旧目录 + 精确 add 归档目录/主规格）→ 六要素汇报，不推送
```

> 落档（`openspec new change` + 四件套 + commit ①）是 spec-plan 阶段 2 本身，**不写进 tasks.md 任务组**（避免执行侧重复落档，D-2 已裁）。

### 3.7 V1–V9 断言（可照抄）

统一前置：

```bash
cd /home/xuqinqin/develop/dotfiles
BASE=a3412d793b3bb3db5e9a5e9b4f08928a4ce3d870
S=agent/skills/smoke-testing-local-env
```

#### V1 冻结区与活引用（三层：授权行外逐字节 / 授权行逐字 / refs 冻结段）

```bash
# 层1：SKILL.md L1–60 除授权三行（L19/L20/L57）外逐字节一致
diff <(git show $BASE:$S/SKILL.md | sed -n '1,60p' | sed -e '19d' -e '20d' -e '57d') \
     <(sed -n '1,60p' $S/SKILL.md | sed -e '19d' -e '20d' -e '57d') && \
# 层2：授权三行新内容逐字（各恰 1 处）
test "$(grep -cF '| [reference.md](refs/reference.md) | 完整操作手册：命令模板、浏览器配方、陷阱全表 |' $S/SKILL.md)" -eq 1 && \
test "$(grep -cF '| [project-profile-template.md](refs/project-profile-template.md) | 项目画像模板（复制到各项目仓填写） |' $S/SKILL.md)" -eq 1 && \
test "$(grep -cF '（模板见 [project-profile-template.md](refs/project-profile-template.md)）' $S/SKILL.md)" -eq 1 && \
# 层3：refs/reference.md 冻结段（L1–18）与活引用（L19）+ SKILL.md L30–34
diff <(git show $BASE:$S/reference.md | sed -n '1,18p') <(sed -n '1,18p' $S/refs/reference.md) && \
diff <(git show $BASE:$S/reference.md | sed -n '19p') <(sed -n '19p' $S/refs/reference.md) && \
diff <(git show $BASE:$S/SKILL.md | sed -n '30,34p') <(sed -n '30,34p' $S/SKILL.md) && echo V1-OK
```

> 1.2 迁移时点的纯移动断言（2.1 编辑前）：`diff <(git show $BASE:$S/reference.md) $S/refs/reference.md` 为空、模板同法——归入任务 1.2 验证句；2.1 指路插入后由层 3 的取行断言兜底（插入点在 L385 后，不影响 L1–19）。

#### V2 reference 既有节号零缺失、零新增

```bash
diff <(git show $BASE:$S/reference.md | grep -oE '^#{2,3} [0-9]+(\.[0-9]+)?' | sort -u) \
     <(grep -oE '^#{2,3} [0-9]+(\.[0-9]+)?' $S/refs/reference.md | sort -u) && echo V2-OK
test "$(grep -cE '^## [0-9]+\.' $S/refs/reference.md)" -eq 9
test "$(grep -cE '^### [0-9]+\.[0-9]+' $S/refs/reference.md)" -eq 38
```

（`^## [0-9]+\.` / `^### [0-9]+\.[0-9]+` 天然排除 reference L465/L473 的码块伪标题。）

#### V3 新文件内容完整性

```bash
f=$S/refs/test-case-design.md
for s in \
  '| 编号 | 模块 | 测试点 | 对应需求/规则 | 测试类型 |' \
  '| 用例ID | 模块 | 用例标题 | 优先级 | 测试类型 | 前置条件 | 测试数据 | 操作步骤 | 预期结果 | 覆盖需求/规则 | 备注 |' \
  'TC-001' 'P0=核心主流程/阻断级' 'P1=重要异常或边界' 'P2=一般场景/兼容性' \
  '需要确认的问题' '我做出的假设' '待确认' '不臆造需求' '禁止「验证功能正常」' \
  '必填校验' '参数类型' '边界值' '鉴权' '错误码' '响应结构' '幂等重复请求' '依赖服务异常' \
  '交互流程' '提示文案' '返回刷新中断' '不同角色权限' '兼容性' \
  '证据要求' 'reference §5.1' 'C/F' 'A/B/D/E' '原地修订' '编号不变' \
  '需求覆盖情况' '仍需确认的问题' '主要测试风险与建议补充的测试类型' \
  '执行期不回补设计稿' '仅设计期'; do
  grep -qF -- "$s" "$f" || { echo "V3-MISSING: $s"; exit 1; }
done
for t in 正常 异常 边界 空值 权限 幂等 兼容性; do
  grep -qF -- "$t" "$f" || { echo "V3-TYPE-MISSING: $t"; exit 1; }
done
echo V3-OK
```

#### V4 三处指路恰好各 1 行 + 链接目标存在 + 七列/组名对齐

```bash
for p in SKILL.md refs/reference.md refs/project-profile-template.md; do
  n=$(grep -cF 'test-case-design.md' "$S/$p")
  test "$n" -eq 1 || { echo "V4-COUNT $p=$n"; exit 1; }
done
test -f "$S/refs/test-case-design.md"
for s in '编号' '用例' '类型' '前置' '步骤' '期望结果' '证据要求' 'A–G'; do
  grep -qF -- "$s" "$S/refs/test-case-design.md" || { echo "V4-ALIGN-MISSING: $s"; exit 1; }
done
echo V4-OK
```

> 计数用 `grep -c`（按行），不是 `grep -o | wc -l`：SKILL/reference 的链接文本与 URL 在同一行，`-c` 仍为 1；用 `-o` 会数成 2，导致假失败。

#### V5 行数台账

```bash
test "$(wc -l < $S/SKILL.md | tr -d ' ')" -eq 188
test "$(wc -l < $S/refs/reference.md | tr -d ' ')" -eq 584
test "$(wc -l < $S/refs/project-profile-template.md | tr -d ' ')" -eq 95
test "$(wc -l < $S/refs/test-case-design.md | tr -d ' ')" -le 160
wc -l $S/SKILL.md $S/refs/*.md
```

#### V6 validate（定向，禁 `--all --strict`）

```bash
# 落档后 / 归档前
openspec validate add-test-case-design-standard --type change --strict && echo V6a-OK

# 归档后
openspec validate smoke-testing-local-env --type spec --strict && echo V6b-OK
```

#### V7 归档预检 / 后检

```bash
spec=openspec/specs/smoke-testing-local-env/spec.md
test "$(grep -c '^### Requirement:' "$spec")" -eq 10
test "$(grep -c '^#### Scenario:' "$spec")" -eq 18
# 删除行归属断言：主规格 diff 的删除行必须全部属于 BASE 的「文档结构兼容约束」节（MODIFIED 唯一授权条目）
sec=$(git show $BASE:$spec | awk '/^### Requirement: 文档结构兼容约束/{f=1;print;next} f&&/^### Requirement:/{f=0} f{print}')
dels=$(git diff $BASE -- $spec | grep '^-' | grep -v '^---' | sed 's/^-//')
extra=$(printf '%s\n' "$dels" | grep -vFxf <(printf '%s\n' "$sec") || true)
test -z "$extra" && echo V7-DEL-SCOPED-OK || { printf '%s\n' "$extra"; false; }
test ! -d openspec/changes/add-test-case-design-standard
ls -d openspec/changes/archive/*-add-test-case-design-standard
openspec list --json | node -e '
const d=JSON.parse(require("fs").readFileSync(0,"utf8"));
const n=d.changes.map(c=>c.name);
if(n.includes("add-test-case-design-standard")){console.error("V7: 活跃变更仍在");process.exit(1)}
for(const x of ["add-subagent-control-and-coordination","add-ui-demo-gate"]) if(!n.includes(x)){console.error("V7: 丢失",x);process.exit(1)}
console.log("V7-LIST-OK");'
unexpected=$(git show --name-only --format= HEAD | sed '/^$/d' | grep -vE '^openspec/(changes/(archive/[0-9]{4}-[0-9]{2}-[0-9]{2}-add-test-case-design-standard/|add-test-case-design-standard/)|specs/smoke-testing-local-env/spec\.md$)' || true)
test -z "$unexpected" && echo V7-WHITELIST-OK || { printf '%s\n' "$unexpected"; false; }
```

#### V8 D6 自检修复（静态 + 真实文件动态 + 混合形态）

静态：

```bash
R=agent/skills/spec-plan/refs/routing.md
test "$(grep -c 'const flow=' "$R")" -eq 1
test "$(grep -c 'const block=' "$R")" -eq 1
test "$(grep -c 'const wl=' "$R")" -eq 1
test "$(grep -cF 'matchAll(/-\s*\{\s*provider:' "$R")" -eq 0
echo V8-STATIC-OK
```

动态（从 routing.md 抽取脚本原样执行）：

```bash
R=agent/skills/spec-plan/refs/routing.md
JS=$(awk "/^node -e '\$/{f=1;next} /'\$/{f=0} f" "$R")
out=$(node -e "$JS" 2>&1); rc=$?
printf '%s\n' "$out"
test $rc -eq 0
test "$(printf '%s\n' "$out" | awk '/^白名单:/{print NF-1}')" -eq 8
test "$(printf '%s\n' "$out" | awk '/^映射:/{print NF-1}')" -eq 13
printf '%s\n' "$out" | grep -q 'OK 全部路由 ⊆ 白名单'
echo V8-DYNAMIC-OK
```

混合形态样例（证明 flow 分支真能解析；注释行不入选）：

```bash
node -e '
const flow=/^[ \t]*-[ \t]*\{[ \t]*provider:[ \t]*([\w.\-]+)[ \t]*,[ \t]*model:[ \t]*([\w.\-]+)[ \t]*\}/gm;
const block=/^[ \t]*-[ \t]*provider:[ \t]*([\w.\-]+)[ \t]*\r?\n[ \t]*model:[ \t]*([\w.\-]+)/gm;
const src="      - { provider: zai, model: glm-5.3 }\n      - provider: opencode-go\n        model: deepseek-v4.1-flash\n      # - provider: commented\n      #   model: nope\n";
const wl=[...new Set([...src.matchAll(flow),...src.matchAll(block)].map(x=>x[1]+"/"+x[2]))];
if(JSON.stringify(wl)!==JSON.stringify(["zai/glm-5.3","opencode-go/deepseek-v4.1-flash"])){console.error("V8b-BAD",wl);process.exit(1)}
console.log("V8b-OK",wl.join(" "));'
```

#### V9 writing-skills 应用演练（固定样例，产物在 /tmp，不入库）

固定样例（写进 `/tmp/test-case-design-drill-input.md` 或直接作为提示）：

```text
需求 R1：登录页支持手机号 + 验证码登录。
- 手机号必填，11 位数字；验证码 6 位数字，5 分钟内有效。
- 同一手机号连续错误 5 次锁定 10 分钟。
- 登录成功写入 account_token 表并跳转 /account。
- 接口 POST /api/auth/login，请求 { phone, code }，成功 { token }，失败返回业务错误码。
- 账号有 USER / ADMIN 两种角色；管理端入口仅 ADMIN 可见。
- 页面兼容 1366×768 与 1920×1080。
```

执行：按新文件 §2–§5 产出 `/tmp/test-case-design-drill.md`（三段式，不入库），再断言：

```bash
D=/tmp/test-case-design-drill.md
test -f "$D"
test "$(grep -c '^| TP-' "$D")" -ge 6
grep -qF '| 用例ID | 模块 | 用例标题 | 优先级 | 测试类型 | 前置条件 | 测试数据 | 操作步骤 | 预期结果 | 覆盖需求/规则 | 备注 |' "$D"
test "$(grep -oE 'TC-[0-9]{3}' "$D" | sort -u | wc -l | tr -d ' ')" -ge 5
for s in P0 P1 P2 待确认 '我做出的假设' 需求覆盖情况 仍需确认的问题 主要测试风险; do
  grep -qF -- "$s" "$D" || { echo "V9-MISSING: $s"; exit 1; }
done
for t in 正常 异常 边界 空值 权限 幂等 兼容性; do
  grep -qF -- "$t" "$D" || { echo "V9-TYPE-MISSING: $t"; exit 1; }
done
! grep -qE '^\|.*(验证功能正常|页面正常显示)' "$D"
echo V9-OK
```

> V9 是 writing-skills 对 reference/technique 文档的 application 验证（检索由 V3 承担）；建议由未参与写作的子代理执行，避免作者自证；若由执行者本人执行，在 tasks 附录注明「自证局限」。

### 3.8 提交序列（全部精确路径；禁 `git add -A openspec`）

```bash
# ① 落档（阶段 2，不占任务组）
git add openspec/changes/add-test-case-design-standard/.openspec.yaml \
        openspec/changes/add-test-case-design-standard/proposal.md \
        openspec/changes/add-test-case-design-standard/design.md \
        openspec/changes/add-test-case-design-standard/tasks.md \
        openspec/changes/add-test-case-design-standard/specs/smoke-testing-local-env/spec.md
git commit -m "docs(openspec): 落档 add-test-case-design-standard"

# ② 实施（组 2.2）：skill 整目录（新文件 + 两处 git mv 旧删新增 + SKILL.md + 指路）——add 前先核对该目录内无外来改动
git status --short agent/skills/smoke-testing-local-env/
git add agent/skills/smoke-testing-local-env \
        openspec/changes/add-test-case-design-standard/tasks.md
git commit -m "feat(skills): 增补测试用例编写标准并收敛文档入 refs"

# ③ D6（组 3.2）
git add agent/skills/spec-plan/refs/routing.md openspec/changes/add-test-case-design-standard/tasks.md
git commit -m "fix(skills): 修正 spec-plan 路由自检白名单解析"

# ④ 归档（组 4.1；先暂存旧变更目录的删除，再精确 add 归档目录与主规格）
git add -u openspec/changes/add-test-case-design-standard
git add openspec/changes/archive/<归档日>-add-test-case-design-standard openspec/specs/smoke-testing-local-env/spec.md
git commit -m "docs(openspec): 归档 add-test-case-design-standard"
```

> `git add -u <旧目录>` 只暂存该目录下已跟踪文件的删除；`git add -A openspec` 会把 `add-subagent-control-and-coordination` 的 3 个在途修改一起卷入，**禁用**。
>
> 若某些 git 版本对「目录已整体移走」的 `git add -u <旧目录>` 报 `pathspec ... did not match any files`，改用 `git add -A -- openspec/changes/add-test-case-design-standard`（仍精确到该旧目录；同样不得写成 `git add -A openspec`）。两者都以 `git status --short` 核验只暂存了本变更的删除/新增。

---

## ④ 决策记录

> 每条含「被否方案 + 理由 + 反例」。D1–D4 为深度契约点名的四个必答项。

### D1 为什么是「L108 同行追加」而不是新增一行

- 决策：SKILL.md L108 整行行尾追加半句，188 行不变，L109+ 零位移。
- 被否方案 A：新增 L109 列表行（188→189）。理由：这是「阶段 3」五步列表，第 2 步就是读库/建库；设计方法是该步的展开，不是第 6 步。新增行会让后续所有行号 +1，V5 断言、任何按行号引用 L109+ 的后续变更都要重算。
- 被否方案 B：改 L3 description 触发词。理由：L1–60 冻结区 + D1 已裁不改；V1 会直接失败。
- 反例：若新增一行，`add-ui-demo-gate` 现在引用的 L30–34 虽不受影响，但任何未来「SKILL.md:108-110」式引用都要重算；同行追加连这个论证都不需要。若改 L3，V1 的 L1–60 逐字节断言立即炸，且 spec「文档结构兼容约束」的 L3 同行替换授权并没有被本变更使用（D1 明确不改）。

### D2 为什么三处指路是这三个点位

- 决策：SKILL.md L108（阶段 3 建库动作点）+ reference.md §6.2 代码块后（能力组→七列的接缝）+ project-profile-template.md §7 L79（用例入口→用例库的转写点）。
- 被否方案 A：reference 放 §6.3 标题后。理由：§6.3 是「七列资产格式」节，11 列设计稿放在这里会与七列正文混读，增加「cases.md 有 11 列」的误读；放在 §6.2 后、§6.3 前，语义是「先按能力组想清楚，再落七列」。
- 被否方案 B：template 再放 L91（也引 §6.3）。理由：L91 是归档约定，不是用例生成入口；加第四处会让 V4 的「每文件恰 1 行」口径复杂化，且 D5 只裁了 L79。
- 被否方案 C：SKILL.md L15–22 配套文件表登记新文件。理由：表在冻结区，D1/主规格禁止；这是已知缺口（R1），用 L108 指路补偿。
- 反例：只在 SKILL.md 指路——复制画像模板的人看不到；只在 reference 指路——阶段 3 执行时不点开 reference 就漏；只在新文件里写——没人找得到。三处各覆盖一条读者路径，且都不越冻结区。

### D3 为什么正则兼容 flow/block 两形态，而不是只认 block

- 决策：双正则 + 行首锚定 + 并集去重（③3.4）。
- 被否方案 A：只认 block（删掉 flow 分支）。理由：当前文件是 block，但 profile 配置形态可能回摆；只认 block 等于把「当前恰好是 block」写死，下一次回摆再犯同样的误报。D6 明确要求兼容两形态。
- 被否方案 B：只认 flow（现状）。理由：实测白名单 0 项、13 条路由全部误报、exit 1；自检永远失败等于没有自检。
- 被否方案 C：YAML 结构化解析 `cordis.patch.yml`。理由：该文件 L204 有 `!!js` 自定义 tag，解析发 `TAG_RESOLVE_FAILED` 警告；且自检会被无关节的 YAML 合法性绑架。
- 被否方案 D：正则不加行首锚定。理由：注释里的 `# - provider: …` 会被当白名单，造成「假通过」（比误报更危险）。
- 反例（实测）：旧脚本跑真实文件 → `白名单:` 为空、13 条路由全部列入「不在白名单」、exit 1；新脚本 → 白名单 8 项、映射 13 条、`OK 全部路由 ⊆ 白名单`、exit 0。混合样例 → 只解析出 `zai/glm-5.3` 与 `opencode-go/deepseek-v4.1-flash` 两项，注释行不入选。

### D4 tasks 分组为什么是 4 组而不是 3 组 / 5 组

- 决策：组 1 新文件（1.1）/ 组 2 接线+断言（2.1–2.2）/ 组 3 D6 修复（3.1–3.2）/ 组 4 归档（4.1）；组间串行，组内串行。
- 被否方案 A：沿用 3 组，把 D6 塞进组 2。理由：D6 与 skill 文档零文件交集；塞进组 2 会让「V1–V5 全绿」被 routing 修复的临时状态污染，无法归因；提交粒度也混在一起（skill 文档 + spec-plan 工具链）。
- 被否方案 B：把落档单独设组 0。理由：落档是 spec-plan 阶段 2 本身，先于执行存在；写进 tasks 会导致执行侧重复落档（D-2 已裁）。
- 被否方案 C：5 组，把组 3 再拆「改正则 / 验证」。理由：3.1/3.2 本来就是两步且强前置，拆组只增加调度开销；单组 2 任务，远低于 parallelism 8。
- 反例：若 D6 并入组 2，routing.md 改错导致 V8 失败时，组 2 的提交会被卡住，skill 文档的交付与 D6 的修复无法分别回滚；独立成组后 `git revert` 只需撤 `routing.md` 一个文件（tasks.md 除外）。

### D5 为什么新文件独立、六节、≤160 行

- 决策：`test-case-design.md` 独立文件，六节（③3.1），目标 100–140 行，硬上限 160。
- 被否方案 A：并入 SKILL.md。理由：用户原文明确「单独提炼成一个文件，不要直接混入 SKILL.md」；SKILL.md 已 188 行且有 L1–60 冻结区，入口 token 成本也不允许。
- 被否方案 B：拆成「测试点清单 / 用例表 / 映射」三个文件。理由：三段式是一个连续工作流，拆开后导航成本高于单文件；映射表与模板强耦合。
- 被否方案 C：110–130 硬点值。理由：11 列表头单行极长，加 12 行映射表 + 两个附加清单 + 两域边界，130 行装不下；为凑行数砍模板会把「不规范」风险转嫁给消费侧。
- 反例：把 11 列表头放进 SKILL.md，会让触发即读成本 +1 张大表，且与 L108 的「表头七列固定」直接冲突，读者会以为 `cases.md` 有 11 列——这正是本变更要防的双资产漂移。

### D6 三段式为什么分级（完整 / 增量）

- 决策：建库与直接交付 = 完整三段式；单任务补新用例 = 增量（新增用例行 + 一句话覆盖说明）。
- 被否方案 A：全场景完整三段式。理由：单任务只补 1–2 条却要重出测试点清单 + 覆盖说明，agent 会把已有库重抄一遍，正是用户要避免的流程负担。
- 被否方案 B：全场景增量。理由：建库会漏测试点清单与覆盖说明，直接交付会缺风险段。
- 反例：已有 40 条用例的库，单任务补 1 条边界用例，若强制三段式，输出 90% 是重抄旧库；增量只写「新用例行 + 覆盖说明：补 R3 边界」即可，执行期仍按编号续接。

### D7 P0/P1/P2 为什么只做设计期口径

- 决策：P0/P1/P2 仅用于设计期取舍/评审；执行仍按 `record.md` 编号集升序（reference §6.5），库内无优先级列。
- 被否方案：执行期 P0 优先。理由：要改 §6.5 与主规格「逐项执行纪律」，代价不成比例；且两套顺序（编号升序 vs 优先级）会让「所选用例编号集 ⊆ 逐项结果表」核对出现歧义。
- 反例：若 P0 改变执行序，`record.md` 里编号集顺序与 `cases.md` 编号升序打架，收尾核对无法判定「缺哪条」；时间紧时正确做法是人工按 P0 筛子集写入编号集，子集内部仍升序。

### D8 为什么「证据要求」列按三层证据派生

- 决策：入库时按「测试类型 + 模块」依 reference §5.1 三层证据口径派生（UI 截图 / 端点与状态码 / 表与主键）；接口型以网络+持久化为主，页面型三层齐。
- 被否方案 A：给 11 列加第 12 列「证据要求」。理由：改动用户给定的 11 列格式；设计稿与库表列数趋同，失去「设计稿→库」的收敛动作。
- 被否方案 B：留空，执行期再想。理由：入库时没有证据定义，执行期容易只截图不查库，单层证据被判通过。
- 反例：一条「登录成功」用例若入库时只写「截图」，执行期就不会查 `account_token` 新行；按 §5.1 派生后至少要求「截图 + `POST /api/auth/login` 200 + `account_token` 新行」。

### D9 11 列→七列映射为什么是「四列不迁移 + 类型正/反 + 模块定组」

- 决策：用例ID/优先级/覆盖需求/备注不迁移；测试类型→类型列（正/反）；模块→组选择；前置+数据→前置列；步骤/预期一一对应；证据要求派生。
- 被否方案 A：把 11 列全部塞进 `cases.md`。理由：破坏七列契约与 `<组>-<两位序号>` 编号体系，所有存量项目库都要改。
- 被否方案 B：连「覆盖需求/规则」也迁入库。理由：七列没有该列；需求级追溯止于设计稿，库内追溯粒度 = 能力组（reference §6.1）。
- 反例：若把优先级迁入库，七列变八列，主规格「用例库资产契约」与存量 `cases.md` 全部冲突；若把 TC 编号迁入库，会与 `<组>-<两位序号>` 形成第二套编号体系，正是 spec delta 要避免的歧义。

### D10 spec delta 为什么 2 条 ADDED + 4 Scenario（落档期由 1 条拆分）

- 决策：追加「用例设计标准」「设计稿入库收敛契约」2 条 Requirement + 4 Scenario；既有 8 条零改写。
- 演化留痕：收敛期原定 1 条 + 2 Scenario（被否方案 A 即「拆两条」，当时理由=轻量优先）；落档校验 `openspec validate --strict` 报「Requirement text >500 characters」警告（不得带病落档），按警告建议拆分——拆分线正是原被否方案 A 的切法，且与「入库收敛契约未来独立演化」预留一致；语义零变化（五步/8 项/6 项/分级/四列不迁移/证据派生/优先级边界全部保留），故不构成推翻收敛，仅形态合规修正。
- 被否方案 B：MODIFIED 既有「用例先行规程」。理由：动既有 Requirement，违反零改写；V7 的删除列 = 0 会失败。
- 被否方案 C：压缩正文至 <500 字符不拆分。理由：五步与 8/6 项附加覆盖是用户原文核心交付，压缩丢 SHALL 完整性；清单类内容不适合塞进 WHEN/THEN 场景。
- 反例：MODIFIED 会让主规格 diff 出现删除/改写列，V7 的 `git diff --numstat` 删除列断言直接失败；ADDED 只追加在文件末尾，删除列恒 0。

### D11 提交/归档为什么 4 个提交 + 精确路径

- 决策：① 落档 / ② 实施 / ③ D6 / ④ 归档；全部精确路径；归档用 `git add -u 旧目录` + 精确 add 新目录/主规格。
- 被否方案 A：3 个提交（D6 并入实施）。理由：关注点混合，回滚粒度粗。
- 被否方案 B：归档 `git add -A openspec`（先例写法）。理由：现在 `openspec/changes/add-subagent-control-and-coordination/` 有 3 个在途脏文件，`-A` 会把他人半成品卷进本变更归档提交。
- 反例：`git add -A openspec` 会暂存 `add-subagent-control-and-coordination/{code-design,design,tasks}.md` 三个修改；提交信息却是「归档 add-test-case-design-standard」，污染他人工作且难以拆分。精确路径 + `-u` 只动本变更的旧目录删除。

### D12 writing-skills 为什么用「检索 + 应用」而不是压力场景

- 决策：结构合规（独立重参考文件 / 相对链接 / 无 `@` / description 不动）+ 检索验证 V3 + 应用验证 V9 + gap 覆盖（接口 8 项、页面 6 项、spec 2 Scenario）；不跑 discipline pressure scenario。
- 被否方案 A：跑 RED/GREEN 子代理压测。理由：本变更交付物是 reference/technique 文档，失效形态是「遗漏字段/误用模板」，不是「压力下违规」；writing-skills 的「Match the Form to the Failure」明确：遗漏必填元素用结构槽位（表头/模板）而非禁令；压测测不到「接口型 8 项少了一行」。
- 被否方案 B：把标准内联进 SKILL.md 再压测。理由：违反用户「单独文件」要求 + 入口 token 预算；且 SKILL.md L1–60 冻结。
- 反例：假设跑一个「时间紧，只写 3 条用例」的压力场景，agent 可能仍然遵守「先列测试点」但漏掉「接口型 8 项」——压测通过而模板缺项照旧；V3 的逐项 grep 能直接抓到缺项，V9 能抓到「产出的三段式是否可用」。RED 侧基线失败形态已由用户原文给出（遗漏/不规范/「验证功能正常」），无需再跑一次无 skill 基线。

### D13 指路文案为什么 SKILL/reference 用链接、template 用纯文本

- 决策：SKILL.md / reference.md 用 `[test-case-design.md](test-case-design.md)`（同目录相对链接）；template 用 `` `test-case-design.md` ``（纯文本文件名）。
- 被否方案：三处统一用相对链接。理由：`project-profile-template.md` 会被复制到各项目仓的 `docs/smoke-test-profile.md`，相对链接在项目仓指向不存在的文件，必断；纯文本文件名让读者回到 skill 目录找。
- 反例：若 template 用链接，复制后的画像里会出现一个坏链，用户点击 404，反而降低可信度。

### D14 D6 为什么不给 spec-plan 加 spec delta

- 决策：只改 `routing.md`，spec-plan 主规格零改动；在本变更 proposal What Changes / tasks / design 留痕。
- 被否方案：给 spec-plan 加一条「自检脚本 SHALL 兼容两种 YAML 形态」Requirement。理由：spec-plan 主规格 13 条 Requirement 零处提及 routing.md/自检/白名单；凭空加一条没有用户可见行为支撑，超出本变更；另立变更则要再走一轮四件套，收益为零。
- 反例：为脚本正则单开变更，归档后还要再写一份 spec delta，而真正被修复的是内部工具链；用户已裁「本变更顺带修」，顺带修的边界就是「不改主规格」。

### D15 文档子目录化为什么并入本变更、为什么是这个形态（落档后用户裁决）

- 决策：`reference.md`、`project-profile-template.md`、`test-case-design.md` 收敛入 `refs/` 子目录（前两者 `git mv` 纯移动、内容零改动），`SKILL.md` 与 `scripts/` 留根；SKILL.md 冻结区授权 L19/L20/L57 三行仅更新链接目标；spec delta 增 MODIFIED「文档结构兼容约束」承载授权。
- 动因：用户在落档后提出「skill 目录平铺」的结构问题并裁决「本次变更内一并完成」——落档后未执行窗口是结构决策成本最低时点（只改规划工件，无已实施代码返工）。
- 被否方案 A：维持平铺。理由：用户已裁否（3 文档规模本可控，但用户偏好子目录收敛）。
- 被否方案 B：只新文件进 refs/、旧文件留平铺。理由：新旧分裂的混合结构比平铺更不一致；用户要求对 skill 整体子目录化。
- 被否方案 C：另立独立变更。理由：用户明确「本次变更内一并完成」；且另立则本变更三处指路链接要写两遍（先平铺后迁移）。
- 被否方案 D：迁移同时改写两文档内容（顺手编辑）。理由：纯移动与内容编辑分离，git R100 归因清晰、V1 层 3 取行断言简单。
- 代价与缓解：冻结区开口三行（授权范围写死在 MODIFIED Requirement，V1 层 1/层 2 双向断言）；add-ui-demo-gate 的 `reference.md:19` 路径引用失效（行号与内容不变，其工件不动、按新路径解析，proposal Impact 留痕）。
- 反例：若不 MODIFIED 而直接改 L19/L20/L57——主规格「文档结构兼容约束」的「L12–60 逐字节不变」即刻违约，V1 层 1 断言失败；若迁移不走 git mv 而复制后删——丢失 R100 rename 历史，V7 归档白名单出现非预期删除/新增对。

---

## ⑤ 逐任务组实现要点

### 5.0 落档（阶段 2，不占任务组）

1. `openspec new change add-test-case-design-standard`（产 `.openspec.yaml`；沿 E2 事实）。
2. 写 `proposal.md`（Why：阶段 3 只有 cases.md 资产格式、缺设计期方法论；What：新文件 + 子目录化 + 3 指路 + D6 + spec delta；Impact：skill 目录 + spec-plan routing.md + 主规格 sync；非目标：不改七列/授权行外冻结区/不推送/不迁四列）、`design.md`（D1–D8 + D12（writing-skills）+ D14–D15 + ④ 取舍摘要 + 本文件链接）、`tasks.md`（③3.6）、spec delta（③3.5：ADDED 2 + MODIFIED 1）。
3. 提交 ①（③3.8），跑 V6a。若按先例复制 `code-design.md` 入 change 目录，随 commit ① 或 ② 精确路径提交（A12）。

### 5.1 组 1 · 新文件与子目录化（1.1 ∥ 1.2）

- 1.1 按 ③3.1 骨架整文件创建 `refs/test-case-design.md`；六节标题逐字；表头逐字；头部链接 `../SKILL.md` 与同级 `reference.md`；≤160 行；不写 frontmatter（不是 skill 入口）；不新增 §7；不把 `cases.md` 七列写成 11 列。自检：V3 + V5 新文件行数。
- 1.2 先 `git mv` 两文档入 `refs/`（纯移动，迁移即验证 diff 为空 ×2）；再按 ③3.3.0 锚点编辑 SKILL.md 授权三行（每处先 `grep -cF` 唯一）。自检：SKILL.md 仍 188 行 + 授权行外 L1–60 逐字节一致。
- 1.1 与 1.2 无文件交集可并行；本组不提交（提交在 2.2 合并）。

### 5.2 组 2 · 接线 + 断言（2.1 → 2.2）

- 2.1 三处指路，建议顺序：refs/reference.md → SKILL.md → refs/project-profile-template.md（互不依赖；先改 reference 可立即跑 V1/V2）。
  - 每处先 `grep -cF` old 串唯一性（三个 old 串均已实测 =1）。
  - refs/reference.md 用 ③3.3.2 的四行 new；**净 +1**，改完 `wc -l` 应为 584。
  - SKILL 用 ③3.3.1 整行替换；改完仍 188。
  - refs/project-profile-template.md 用 ③3.3.3 整行替换；仍 95；**纯文本文件名含 refs/ 前缀**。
- 2.2 断言：V1–V5 + V9 全绿 → 勾 1.1/1.2/2.1/2.2 → 提交 ②（skill 整目录 + tasks.md；add 前核对目录内无外来改动）。
- 注意：V4 用 `grep -c`（按行），不要用 `-o | wc -l`；链接文本+URL 同行计 1。
- V9 产物在 `/tmp`，不提交；tasks 附录留痕「执行者/是否子代理/断言结果」。

### 5.3 组 3 · D6 自检修复（3.1 → 3.2）

- 3.1 锚点替换 `routing.md:49` 为 4 行（③3.4）；先 `grep -cF` old 整行 =1；新增行不得含单引号（脚本在 `node -e '…'` 内）。
- 3.2 跑 V8 静态 + 动态 + 混合样例；真实文件应为白名单 8、映射 13、exit 0；routing.md 67→70 行；全仓唯一 `routing.md:15` 引用在插入点之前（已核，不受影响）。
- 勾 3.1/3.2 → 提交 ③（routing.md + tasks.md）。
- 失败处理：若白名单不是 8（例如他会话改了 `allowedModels`），停止并复核该文件 diff；不要为凑 8 改断言。

### 5.4 组 4 · 归档（4.1）

1. 干净窗口：`git status --short` 只允许外部在途 7 项（Q1 的 coordination.md 待确认）；出现本变更残留即停。可照抄：

```bash
allowed='^( M|M |A |\?\?) (dsh/profiles/web/(cordis\.patch\.yml|package\.json|pnpm-lock\.yaml)|openspec/changes/add-subagent-control-and-coordination/(code-design\.md|design\.md|tasks\.md)|agent/skills/spec-apply/refs/(coordination\.md|execution\.md))$'
extra=$(git status --short | grep -vE "$allowed" || true)
test -z "$extra" && echo CLEAN-WINDOW-OK || { printf '%s\n' "$extra"; false; }
```

> 外部在途台账是**动态的**（add-subagent 会话持续推进，落档期已见 6→7→8 漂移：coordination.md、execution.md 相继出现）；组 4 执行时先 `git status --short` 现场复核，新出现的外部在途项（能归属他会话的）纳入白名单并在 tasks 附录留痕，出现**无法归属**的新文件即停并上浮。

2. 复跑 V6a；确认 tasks 的 1.1–3.2 已勾（4.1 留到归档后勾），且无其他未勾项。
3. `openspec archive add-test-case-design-standard --yes`（自动 sync 主规格第 9–10 条 + 日期前缀移动）。
4. V6b + V7（10/18、删除列 0、活跃目录已移走、archive 目录在、其余两活跃变更未受损、归档提交白名单）。
5. 在归档目录的 tasks.md 勾 4.1；提交 ④：`git add -u openspec/changes/add-test-case-design-standard` + `git add openspec/changes/archive/<日期>-add-test-case-design-standard openspec/specs/smoke-testing-local-env/spec.md`；commit message 见 ③3.8。
6. 六要素汇报后停留，**不推送**。

### 5.5 组间与并行性

- 组间严格串行（1→2→3→4）；组内 2.1→2.2、3.1→3.2 串行；单组 ≤2 任务，远低于 parallelism 8。
- 组 1 与组 3 文件零交集，但两组都经 `tasks.md` 记账（提交 ② 与提交 ③ 都改同一个 tasks.md），且已裁定组间串行——**不并行**，避免 tasks.md 写冲突与归因混乱。
- 失败即停：锚点唯一性检查失败、V1–V9 任一失败、干净窗口出现未知文件，均停止并上浮，不自行「修断言」。

---

## ⑥ 设计假设与未决项

### 假设

- **A1** 文件名 `test-case-design.md`，位于 `refs/` 子目录（目录既有 lowercase-hyphen 惯例 + 用户裁决子目录化；`refs/` 名随 spec-plan/spec-apply/spec-workflow/ui-demo 主惯例）。
- **A13** `git mv` 迁移被 git 识别为 R100 纯 rename（先例归档 R100×6 已证 git 对纯移动的识别；提交 ② 前用 `git status` 确认显示为 renamed）。
- **A2** 归档日期前缀取归档当日实际日期，tasks/设计不预写死。
- **A3** `openspec archive --yes` 把 ADDED Requirement 追加到主规格末尾，既有 8 条零改写（沿先例）；若工具改为插入中间导致删除列 >0，停止并上浮。
- **A4** skill 经 `~/.agents/skills` symlink 分发，新文件改完即时生效，无构建/无重启。
- **A5** V2 的带编号模式天然排除 reference L465/L473 码块伪标题；不要用裸 `^## `。
- **A6** 外部在途脏项不触碰、不清理、不暂存；精确路径 add 天然排除。
- **A7** V8 依赖脚本里已有的 YAML require 回退；若 YAML 缺失，脚本打印「跳过」并 exit 0，V8 的 8 项断言会失败——**不会静默通过**。
- **A8** spec delta 2 条 ADDED + 4 Scenario（落档期由 1 条拆分，动因见 ④D10），不 MODIFIED 既有 Requirement。
- **A9** D1 已裁 L3 触发词不改；「直接交付用例」限定被测项目/冒烟语境或用户点名 `test-case-design.md`。
- **A10** 新文件不登记进 SKILL.md L15–22 配套文件表（表在冻结区，仅 L19/L20 为授权链接行、不增行），入口只有 L108 + `refs/reference.md` §6.2 后 + `refs/project-profile-template.md` L79 三处；这是已知取舍，不视为遗漏。
- **A11** V9 产物在 `/tmp`，不入库、不进 change 目录。
- **A12** `code-design.md` 是阶段 1.7 工件；阶段 2 可按先例复制入 change 目录（随 commit ①/②），不复制也不影响交付。

### 事实修正（不推翻决议，只更新台账）

- **F1** 工作区外部脏项实测 **7** 个：决议所列 6 个 + 未跟踪 `agent/skills/spec-apply/refs/coordination.md`。见待决 Q1。
- **F2** `dsh/profiles/web/cordis.patch.yml` 当前在途 diff 在 L16（`agent-default-model` 的 model），**不在** `allowedModels` L226–242；V8 的 8 项基线当前稳定。
- **F3** `reference.md:19` 不在 L1–18 字面冻结区，但受主规格「`reference.md:19` 行号引用 SHALL 保持有效」独立保护；本变更插入点 L385 在其后，L19 行号/内容不变（沿 D-1 裁定）。
- **F4** `routing.md` 67 行，改后 70 行；全仓唯一 `routing.md:15` 引用在 `add-ui-demo-gate/code-design.md:400` 的备选方案描述中（插入点 L49 之前），行号推移无外部影响。
- **F5（落档后并入）** 用户裁决文档子目录化并入本变更（D15）：scope 由「新文件 + 指路 + D6」扩为含 `git mv` ×2 与冻结区授权三行；spec delta 增 MODIFIED 1 条；非目标「不动冻结区」修正为「不动授权行外冻结区字节」。

### 未决项

见下节「待决问题」。除此之外无未决；D1–D6 与 D-2 已由收敛留痕裁决，本设计不重开。

---

## 待决问题

### Q1（已决，留痕）：第 7 个外部在途文件如何纳入干净窗口

- **裁决**：落档分歧点提问（2026-11-19）用户选「按外部在途处理」——不触碰、不暂存、不清理；组 4 干净窗口白名单纳入它；精确路径 add 天然排除。

## 附：阶段 1.75 界面演示（判定与确认）

1.75 未触发：C1 不成立——本变更触达面全部为 Markdown 文档（新标准文件、三处指路句）与文档内嵌自检脚本的正则修正，无页面/组件/弹窗/表单/布局/视觉/交互流程产出（命中排除表「纯文档/脚本」形态）。
