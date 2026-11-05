# diff-matrix — add-dsh-plugin-writer-skill（阶段 1.5 收敛留痕）

编排：并行双线 · team 驱动（成员 `spec-plan-add-dsh-plugin-writer-skill-line-a/b`，无回退；team 编排下 lineA/lineB 模型路由不应用）。
输入：`line-a.md`（A 线：需求与价值、范围与边界）+ `line-b.md`（B 线：实现与约束、反例与风险）。
本文为阶段 2 落档输入之一，落档时随 `code-design.md` 复制入变更目录。

## 一、三分类矩阵（7 字段逐一对齐）

### 共识（两线一致，直接采信）

| # | 共识项 | 备注 |
| --- | --- | --- |
| C1 | 产出一个名为 `dsh-plugin-writer` 的 skill，把本仓 6 插件沉淀的非显然工程知识固化为 agent 可复用指令 | 两线目标一致 |
| C2 | 内容策略=「指路真源 + 流程骨架 + 决策树 + 反例清单」，版本号等易变事实一律指向源头（`scripts/dsh-baseline.mjs` 等）不复述 | 双源漂移实证支撑（AGENTS.md rc.2 vs 真源 rc.5） |
| C3 | 范围限定本仓风格（非通用 DSH 插件教程）；覆盖 host-only / 双端 / multi-root 特例三种形态 | A 待决2 与 B 假设 A3 趋同 |
| C4 | 模板路线=「以最接近的现有插件为活体样本复制再改」，不做从零脚手架生成器 | A/B 均排除代码生成器 |
| C5 | 验证核心=实战演练：子代理/agent 仅凭 skill 从零搭最小 host-only 插件，走通 `verify:all` → `dsh:check` → `link:` 安装 → `--dump-config-schema` | 两线验证思路一致 |
| C6 | 非目标：不改现有插件源码、不做多语言、不覆盖 DSH 0.3.x、不动 DSH 本体 | 一致 |
| C7 | description 需写清触发条件并与官方 skill/openspec-* 触发词错开，控制篇幅（≤500 上限留余量） | 一致 |
| C8 | skill 维护挂靠：随 `pnpm dsh:upgrade` 复验 skill 有效性（轻量，一行建议写入升级流程/skill 维护说明） | A「维护性检查」+ B R5 合并 |

### 分歧（两线结论不同）

| # | 分歧点 | A 线 | B 线 | 处置 |
| --- | --- | --- | --- | --- |
| D1 | 宿放位置 | 入库源目录 `skills/` + 同步脚本至 `.dsh/skills/`（不知 `.agents/skills` 可用时提出） | `.agents/skills/`（rank 200、DSH 原生默认扫描根、入库零同步） | 事实已裁定（见二/F1）：`.agents/skills` 机制成立、`skills/`+同步方案前提被推翻；剩余为用户决策（第 5 步问） |
| D2 | 内容形态 | SKILL.md 精炼路由 + references/ 分主题分册 | 单文件 SKILL.md ~150–250 行 | 无法查证的方案走向分歧 → 派 panel 复算线（见三） |
| D3 | 是否内置 templates/ 静态模板 | 倾向含（软插件+双端各一套，官方 skill 同构先例） | 明确不做（复制现有插件更抗漂） | 无法查证的方案走向分歧 → 派 panel 复算线（见三）；依赖 D2 答案 |

### 单边遗漏（仅一条线提出 → 逐项核验）

| # | 单边项 | 来源 | 核验结论 |
| --- | --- | --- | --- |
| S1 | 与官方 `cordis-plugin-development` skill 的显式分工声明（profile 内一次性 bundle ↔ 本仓可发布组合包） | A | **成立，纳入**：已查证官方 skill 确实存在且面向 `install_bundle`/workspace 文件、明确禁止手写 profile package.json（`dsh-agent-preset/skills/cordis-plugin-development/SKILL.md`） |
| S2 | AGENTS.md 基线漂移（rc.2→rc.5）顺带修正与否 | A（B 提供实证） | **事实成立**（`scripts/dsh-baseline.mjs` L13 = `0.2.1-rc.5`，AGENTS.md L37 写 rc.2）；是否纳入本变更为用户决策（第 5 步问） |
| S3 | 调用面取舍（默认双开不写布尔键 vs 显式收窄；写错拼写=整条静默丢弃） | B | **成立，纳入**：dsh-skill-filesystem README 确认布尔键严格语法与整条丢弃行为；推荐默认双开 |
| S4 | 反例清单 F1–F12（裸包名行、build 自包含两坑、lib/ 入库、基线派生、allowBuilds、目录层级、无效键、500 上限、发布红线、skill 隐身排障、验证姿势） | B | **抽查 F1/F3/F9 成立**（session-tool-toggle patch 注释、zcode-plan build.mjs 头注释、dsh-tool-skill `catalogDescriptionMaxLength=500`），整组采信为 skill 素材 |
| S5 | 流程覆盖终点（到安装验证 / 到发布红线 / 全覆盖含 dsh:upgrade） | B | 成立；取舍为用户决策（第 5 步问） |
| S6 | 触发有效性测试用例（「新增插件」命中 / 「profile 一次性功能」让位官方 / 「行为规格」走 OpenSpec） | A | **成立，纳入**验证思路 |
| S7 | 格式层/发现层/回归层验证（frontmatter 键集校验、目录可见+实际加载双验证、digest 稳定） | B | **成立，纳入**任务拆分与验证思路 |
| S8 | 演练环境依赖风险（docker exec dsh 不可用则降级只读评审） | A | 成立；本会话实证 `docker exec dsh` 命令可用性高，保留为执行期注意项 |
| S9 | 知识覆盖边界声明（原生依赖 koffi 特例、纯 client 插件未覆盖 → 回退官方文档） | A | **成立，纳入** skill 正文边界声明 |

## 二、自行裁定（能查证的自己查证，记录依据）

| # | 裁定 | 依据 |
| --- | --- | --- |
| F1 | `.agents/skills/`（rank 200）为 DSH 默认扫描根、`includeDefaultRoots: true` 默认含之；本仓 `.agents/` 不存在且**未**被 gitignore → 可入库零同步。A 线「`skills/` 源目录+同步脚本」方案的前提（需要同步才能生效）被推翻 | dsh-skill-filesystem README.zh.md rank 表（100 project-dsh / 200 project-agents / 400 user-dsh / 500 user-agents）+ `.gitignore` 无 `.agents` 条目 |
| F2 | AGENTS.md 基线漂移实证成立：真源 rc.5、文档 rc.2 | `scripts/dsh-baseline.mjs` L13 vs AGENTS.md L37 |
| F3 | B 线机制事实组全部成立：frontmatter 必填 `name`(kebab-case)+`description`、可选 `whenToUse/metadata/disable-model-invocation/user-invocable`、布尔拼写错整条随警告丢弃、发现深度 1 层、目录描述上限 `catalogDescriptionMaxLength=500`（最小 3）、正文加载无大小上限 | dsh-skill-filesystem / dsh-tool-skill README.zh.md 原文核对 |
| F4 | B 待决 2（是否走 OpenSpec）已由用户行动裁定：本次即以 spec-plan 规划并落档 OpenSpec 变更；剩余「落档是否建 specs/」作为落档分歧点（见五） | 用户调用参数与 spec-plan 流程事实 |
| F5 | `.dsh/skills/` 现有 6 个 openspec-* skill，无 `dsh-plugin-writer` 同名，触发词域不重叠 | `ls .dsh/skills/` |
| F6 | `openspec/specs/` 已有 10 个能力 spec，均为插件类（有运行时行为的）软件产物；skill 为文档型产物，先例不等同 | `ls openspec/specs/` |

## 三、分歧复算（第三条 fresh 线，panel 路由）

- 路由留痕：panel 主路由 `deepseek-official/deepseek-flash` 与 fallback `zcode-plan/glm-5.3` 经路由自检**均不在**本 profile 白名单（实际白名单=zai/* 与 zai-coding-cn/*；自检脚本正则亦与 profile 现格式不符，已人工核对）→ 按 routing.md 三档回退第②档**回退继承会话模型**派发（回退原因留痕）。
- 复算范围：D2（形态）、D3（模板）——不以任何既有草案为输入，只给分歧点陈述+需求原文。
- 复算结论（子代理 8c9f3785，实测 dsh-tool-skill/dsh-skill-filesystem README 与五插件 package.json）：
  - **D2 形态：判 b（精炼路由 + references/ 分册）**。依据：①目录描述常驻每会话、SKILL.md 正文加载无大小上限且作为工具结果在后续每步重发直到压缩（持续性 token 成本），references 按需加载、其编辑不触发目录重发；②内容天然分册（同构约定/双端分化/验证/发布基线各自独立），build.mjs 与 cordis.patch.yml 头注释已是高密度活真源，分册只需指路+增量；③漂移佐证：五插件 package.json 已是 `>=0.2.1-rc.5 <0.3.0`，全量复述必过期。代价：agent 只读 SKILL.md 不拉分册会缺细节（路由处强提示）；分册不得复述源码注释（防第二真源）。
  - **D3 模板：判不内置 templates/，指引复制最接近的现有插件**。依据：二代五插件近同构即活模板、按形态自然分化（host-only 三例/双端两例）；复制天然继承现行基线（dsh:upgrade 重指范围，静态模板必过期）；静态模板覆盖不了中间形态（web-ux 宿主 RPC 通道、zcode-plan profile 路由注册）。代价：复制带杂质（multi-root 的 koffi/allowBuilds 属上一代），skill 须以「复制后必改清单」（包名/patch id 与注册行/inject 列表/头注释逐一重写）为核心章节。
  - 复算线额外指出：落位与分发决策直接影响 frontmatter 与相对指路路径写法（已列为第 5 步 Q1，承重最大）。
  - **三线对照**：D2 = A(b) : B(a) : panel(b) → 2:1 采 b；D3 = A(内置) : B(不内置) : panel(不内置) → 2:1 采不内置。B 线单文件动机（反例装不下/维护点翻倍）由「分册按需加载+指路增量不复述」化解；A 线模板动机（拷贝改造抗错）由「活插件即模板+必改清单」达成。

## 四、探索审视（补双边盲区，openspec-explore 姿态）

| # | 发现 | 类型 | 处置 |
| --- | --- | --- | --- |
| E1 | skill 附属资源机制：skill 目录可携带附属资源（references/templates 子文件），加载正文时提供 base directory 供相对路径引用——官方 `spec-plan` skill 自身即「SKILL.md + mode/ + refs/ 分册」活例；官方 `cordis-plugin-development` 亦有 references/templates 表 | 双边盲区（两线均未实证此机制） | 降级为事实：**分册与模板在机制上均可行**，D2/D3 纯为取舍决策，交复算+用户 |
| E2 | 演练产物处置：两线均要求演练但未明确演练插件目录的清理与入库边界 | 双边盲区 | 纳入落档 tasks：演练组明确「验证后清理演练目录，不入库」 |
| E3 | 演练环境可用性：`docker exec dsh dsh …` 为仓库日常命令，可用性高 | 降级 A 线风险 S8 | 保留为执行期注意项，不阻塞 |
| E4 | 落档语言约束：config.yaml 要求全部产物 zh-CN、结构标题与 SHALL/MUST 保留英文 | 流程事实 | 落档时遵守（记此处防遗漏） |

## 五、设计树与前沿分轮（grill-me 缺失，降级普通按轮提问，每轮 ≤5 问）

设计树（节点=决策，边=依赖）：

```
[Q1 宿放位置]──┬─> [Q7 演练/README 收尾细节（弱依赖）]
[Q2 形态]──────┴─> [Q6' 模板内置与否（依赖 Q2）]
[Q3 范围]（独立）
[Q4 调用面]（独立）
[Q5 流程覆盖终点]（独立）
[Q8 AGENTS.md 漂移修正]（独立）
[Q9 落档是否建 specs/]（弱依赖 Q1-Q6 落定，并入落档分歧点提问）
```

（grill-me 修正留痕：前置检查报「grill-me 缺失」为**自检路径漏查误报**——实际位于 `/home/docker/.agents/skills/grill-me`（user-agents 根，skctl 聚合层挂载）；经用户指正后已加载并遵循其方法，未降级。）

第 1 轮（前沿 5 问，承重排序）：

| # | 问题 | 用户答复 | 状态 |
| --- | --- | --- | --- |
| Q1 | 宿放位置：.agents/skills/（本仓，推荐）/.dsh/skills/~/.dsh/skills | **自定义：放 `/home/xuqinqin/develop/dotfiles/agent/skills/` 下** | 已定（自定义） |
| Q2 | 形态：路由+分册（推荐）/ 单文件 | 同意推荐 | 已定 |
| Q3 | 模板：不内置+必改清单（推荐）/ 内置 templates/ | 同意推荐 | 已定 |
| Q4 | 覆盖终点：到发布（推荐）/ 仅安装验证 / 全覆盖 | **自定义：仅到安装验证**（不含发布红线） | 已定（自定义） |
| Q5 | 调用面：默认双开（推荐）/ 仅模型 / 仅用户 | 同意推荐 | 已定 |

Q1 自定义答案的查证与推论（主会话自行裁定）：
- 机制：`dotfiles/agent/skills/` = 自写 skill 实体（git 管理）；消费经 skctl 聚合层（`~/.local/share/agent-skills`，自写=symlink 回 dotfiles）→ 容器 `/home/docker/.agents/skills` 只读挂载（compose SKCTL_STORE_PATH）→ dsh 用户级 rank 500（user-agents）可见；**未经 `skctl install` 登记的 skill 不可见**（dotfiles `agent/skills/README.md`）。
- 推论 1：skill 为用户级（跨项目可见）→ 正文需写适用判定（任务/工作目录涉及 dsh-plugins 仓时使用），指路需锚定本仓绝对路径——交阶段 1.7 设计契约处理。
- 推论 2：分发链含 dotfiles 落位 + skctl 登记 + dotfiles `agent/skills/README.md` 当前清单补行——是否纳入本变更 tasks 为第 2 轮决策项。
- 推论 3：`.agents/skills/`（本仓）方案作废；`.dsh/skills/`、`~/.dsh/skills/` 方案作废。

第 2 轮（前沿重算后 4 问）：

| # | 问题 | 用户答复 | 状态 |
| --- | --- | --- | --- |
| Q6 | 跨仓任务范围 | 同意推荐：**全链入 tasks**（dotfiles 实体 + skctl 登记 + README 补行 + dsh-plugins 侧验证演练） | 已定 |
| Q7 | 落档结构 | **自定义：可以不建 specs，但 OpenSpec 产物落档到 dotfiles 仓下；用户将在 dotfiles 工作区执行 `/spec-flow continue` 接续** | 已定（自定义） |
| Q8 | 变更名 | 同意：`add-dsh-plugin-writer-skill` | 已定 |
| Q9 | AGENTS.md 漂移修正 | 同意推荐：独立小任务，不混入本变更 | 已定 |

Q7 自定义答案的查证与推论（主会话自行裁定）：
- 查证：dotfiles 仓**有** OpenSpec 根（`openspec list --json` → root=/home/xuqinqin/develop/dotfiles，source=nearest，无活跃变更，有 archive）→ 落档 dotfiles 可行，不触发「无根红线」。
- 推论 1：落档目录 = `/home/xuqinqin/develop/dotfiles/openspec/changes/add-dsh-plugin-writer-skill/`；工件单独提交在 **dotfiles 仓**。
- 推论 2：dotfiles 仓现存无关脏改动（`dsh/profiles/web/cordis.patch.yml` 已修改）——不 stash 不 revert，落档提交只 `git add` 工件文件。
- 推论 3：收尾告知语指明接续工作区：在 **dotfiles 工作区**执行 `/spec-flow continue add-dsh-plugin-writer-skill`。
- 推论 4：本仓（dsh-plugins）无落档产物；验证演练在其侧执行但产物清理不入库（E2）。

## 六、收敛结论（前沿为空，收敛结束）

| 决策 | 结论 | 来源 |
| --- | --- | --- |
| 宿放 | skill 实体 = `dotfiles/agent/skills/dsh-plugin-writer/`（git 管理），经 skctl install 登记聚合层 → 容器挂载 → dsh 用户级 rank 500 可见 | Q1 自定义 + 查证 |
| 形态 | SKILL.md 精炼路由（触发判定+选型决策树+真源指路表）+ references/ 分主题分册（只指路不复述源码注释） | Q2 + 复算 2:1 |
| 模板 | 不内置静态模板；核心章节=「复制后必改清单」（包名/patch id/注册行/inject/头注释逐项） | Q3 + 复算 2:1 |
| 覆盖终点 | 生命周期讲到「构建 + profile 安装验证」（link: 安装 + --dump-config-schema）为止；发布红线与 dsh:upgrade 不入正文（可一句指路 AGENTS.md） | Q4 自定义 |
| 调用面 | 默认双开，不写任何布尔键 | Q5 |
| 跨仓 tasks | 全链入 tasks：dotfiles 实体 + skctl install + dotfiles agent/skills/README.md 清单补行 + dsh-plugins 侧验证演练（演练产物清理不入库） | Q6 |
| 落档 | 不建 specs/（文档型产物，proposal 承载需求）；产物落 **dotfiles 仓** openspec/changes/add-dsh-plugin-writer-skill/；接续在 dotfiles 工作区 | Q7 自定义 + 查证 |
| 变更名 | `add-dsh-plugin-writer-skill` | Q8 |
| 漂移修正 | AGENTS.md rc.2→rc.5 修正为独立小任务，不混入本变更 | Q9 |
| 共识项 | C1–C8 全部采信（含范围仅本仓、指路真源策略、演练验证、维护挂靠 dsh:upgrade 复验） | 三分类 + 单边核验 |

未决项：无（前沿为空）。单边遗留事实 U1（.agents/skills 全 profile 组合扫描）随 Q1 落定为 dotfiles 方案而失效；U2（openspec update 对 .dsh/skills 非 openspec 文件行为）随宿放位置变更而失效；U3（500 规范化算法）以描述留余量规避；U4（0.3.x 兼容）超出基线，写入 skill 边界声明。

## 七、执行期留痕（R 条目，组收尾追加）

> 条目自包含：规则/事实 + 依据 + 适用范围 + 连锁面（联动需同步的工件/代码/任务）。证据原件在 `/tmp/spec-flow/add-dsh-plugin-writer-skill/`（materials.md / red-baseline.md），易失不入库，结论以本节为准。

**R1 · 模型路由自检脚本正则漂移**（组 1 实测）
- 事实：`dsh/profiles/web/cordis.patch.yml` 的 `subagent-model-selection-settings.allowedModels` 已改为**多行 YAML**（`- provider: x` 换行 `model: y`），spec-apply refs/routing.md 的路由自检脚本正则仍假设单行 flow 格式 → 白名单解析为空、全部映射误报「不在白名单」。
- 处置：人工核对——映射文件 12 条路由（含 fallback）⊆ 白名单 9 条（zai×2 / zai-coding-cn×2 / zcode-plan×2 / opencode-go/deepseek-v4.1-flash / deepseek-official/deepseek-flash），全部合法，路由可用。
- 连锁面：后续变更可修自检脚本正则（非本变更范围）；本变更执行期以人工核对口径为准。

**R2 · multi-root 无 build.mjs（任务 1.1 原文结构性偏差）**（组 1 实测）
- 事实：三模板中仅 zcode-plan / session-tool-toggle 有 `build.mjs`（esbuild）；multi-root 构建入口为 `tsdown.config.ts`（`package.json` build = tsc 类型 + tsdown 打包）。
- 处置：materials.md §1.4 以「build.mjs 共有契约 + multi-root tsdown 对位行号」呈现，未虚构。
- 连锁面：组 2 `structure.md`/`build.md` 撰写时按「两模板 build.mjs 为主、multi-root 特例小节注明 tsdown」口径；design.md 触达#2/#3 的「build.mjs」表述按此口径理解；主会话裁定不改 D1 分册切分（素材量够塞小节，见 R4）。

**R3 · RED 压测结论：命令级零失败 + 三个真实坑**（组 1 实测，491 行日志）
- 事实：未加载任何 skill 的子代理在 dsh-plugins 仓从零搭 `plugins/host-beacon`（host-only）全链命令级全绿（pnpm install / verify:all / dsh:check / plugin add / dump-config 均 exit 0），终态仓零残留。动态素材却极丰富：数十条逐字决策理由与合理化判断。
- 代理自发现的三个坑（AGENTS.md 未覆盖、skill 增量价值点）：
  1. `--dump-config` 只证明注册行进合成树、**不证明代码可加载**（它不 import 模块）；深验证 = `--dump-config-schema`（host-only 无 Config 时 `status:"absent"` 是正常态）+ 容器内直接 import + apply。
  2. profile `plugin remove` 后 **pnpm 留悬空 symlink**（`node_modules/<包名>` 指向已删目录）；remove 只改清单不清 link: 依赖链接，须手工按 readlink 确认后删除。
  3. `--dump-config-schema` exit 1 可能来自 profile **既有 agent-preset 行的 schema 噪音**（与插件无关）；排障必须先跑一次基线对照 stdout 条目清单。
- 过程另有：版本号选择推理（统一版本=tag 约定 vs dsh:check 不查版本）、pnpm store 复用判断、MCP 措辞歧义消解。
- 连锁面：组 2 `build.md`（验证深度语义）/`verify-install.md`（卸载残留、schema 噪音排障、先跑基线）应收录三条坑；组 8 REFACTOR 以演练实测对照；「基线零失败是否继续组 2」已按任务条款上浮用户（见组 1 呈证）。

**R4 · 组 1 待决项主会话裁定**（依据 materials.md §6 建议 + design 既有决策，未超出规划）
1. 「宿主侧 MCP 插件」措辞歧义 → **按 host-only 插件正解**（design 触达#9 原文即「最小 host-only 插件」；MCP server 由 profile 配置驱动无插件侧注册 API，压测代理判断正确）。
2. F7 最终形态 → 采纳 materials §3.7 建议：改写为「插件包内 `.agent/` ≠ DSH 扫描根」+「skill 必须 `<name>/SKILL.md` 深度 1」，不照搬 `.agents/skills` 宿放说法（该口径已被收敛 Q1 取代）。
3. F8 实样指路 → 采纳建议：只描述现象、不写 `.dsh/skills/` 具体路径（实样是 gitignore 的本机 openspec 生成物，不入库不可依赖）。
4. multi-root 特例归属 → 维持 D1 四册切分不改（素材量够塞 structure/build 小节）；不改分册结构属规划内裁量。
- 连锁面：组 2 派发提示按上述四条口径传递。

**R5 · 沙箱 workspace 根与 cwd 不一致（平台行为）**（组 1 实测）
- 事实：子代理 cwd 指向 `person/dsh-plugins` 不改变文件沙箱根（仍按会话 workspace roots 判定）；用户把该仓加为会话附加根后**即时生效**（新轮次 runtime 快照刷新），无需重启会话。压测代理全程未用 docker exec 绕过 policy denial（纪律正确）。
- 连锁面：本变更后续组 6/7/9 派发提示无需再附沙箱说明；如遇同类阻塞，处置路径 = 上浮主会话 → 用户加根，不走 docker exec 写仓通道。

## 八、组 1 呈证与待决

- 组 1 两任务核对通过（2026-11-05）：1.1 验证句复跑 PASS（materials.md 375 行、39 路径索引全过、主会话绝对路径抽查全过）；1.2 验证句 PASS（red-baseline.md 491 行含数十条逐字借口、主会话复跑 `git status --short` 空 + profile 无 host-beacon 残留）。
- 待决（任务 1.2 条款触发）：压测命令级零失败 → 按条款「上浮待决不硬写 skill」，用户裁定是否继续组 2（结论见 R3 与组 1 呈证汇报）。
- **用户裁定（2026-11-05）：继续组 2（推荐案）**——F1–F12 静态失败面 + 491 行动态素材已构成充分基线；压测三坑（R3）直接进组 2 撰写内容。RED 基线判定就此关闭。

**R6 · frontmatter YAML 序列化口径（design ③-2 示例的落地修正）**（组 2 / 任务 2.1 实测）
- 事实：design ③-2 的 description 原文含 `link: 装入`（冒号+空格）——作为 YAML **plain scalar 非法**，DSH 实测用 `yaml.parse` 解析 frontmatter，不加引号抛 `incomplete explicit mapping pair` → 整条 skill 被 `invalid YAML frontmatter` **静默丢弃**（正是 design 风险表「静默失效」面）。
- 处置：SKILL.md 用 `description: >-` 折叠块标量承载，**文案一字未改**；DSH 同款 `yaml` 包 + skctl 同款 gray-matter 双解析验证，解析值 === 设计原文（278 字符 ≤300）。
- 连锁面：组 3 断言按 **YAML 解析口径**执行（键集/name/字符数/可解析四项都从解析后对象断言，不得用行首 grep 朴素断言——`>-` 形式下 description 不在行首）；design.md ③-2 示例为语义呈现，落地序列化以本条为准；后续任何人手改 description 时必须保持可解析（含引号或块标量）。

**R7 · 组 2 内容级裁定**（主会话，依据官方实现与指路真源策略，未越 design 契约）
1. `dsh.client.inject` 措辞 → 采纳 2.3 有意偏差：按官方类型注释（`dsh-package-manifest` types:75-89）与 client-modules 实现写「包名依赖 / 启动图到达顺序」，不用 materials §1.2「client 服务列表」旧口径。
2. `/inventory` 前置依赖 → 接受册内处理：明示由 `dsh-plugin-user-commands` 提供、未装则降级插件自有面（F11 假故障排障已含 `skill:` 开关检查）。
3. `dsh.client.external` → 接受只给语义与官方指路不写示例（本仓无使用先例，编示例违背「真源指路」原则）。
- 连锁面：组 5 发现层验证时注意 `/inventory` 依赖 user-commands 在位（本机 profile 有，不构成阻塞）；组 8 REFACTOR 时上述三条口径不动。

**R8 · 组 4 执行环境事实**（任务 4.2 实测，后续组核对口径）
1. dsh 会话容器（HOME=/home/docker）**无法直读宿主 `~/.local`**（未挂载，仅 skills 只读视图挂到 `/home/docker/.agents/skills`）——宿主态断言（readlink / registry.json）须经 `/home/xuqinqin/develop/docker/run.sh node '<cmd>'` 在 node 容器（rw 挂载宿主 home）执行。
2. registry.json 实际结构为 `{"skills": {"<name>": {...}}}`（design ⑤ 写的顶层形状是语义简写，取值须经 `skills` 键）；skctl 条目字段名 `installedAt`（非 design 示例的 `installed_at`）。
3. `~/develop/docker/bin/` 无 node 包装，等价形式 = `run.sh node '<cmd>'`（node 22.18.0 原生跑 .ts）；skctl `USER_HOME` 硬编码 `/home/xuqinqin`（paths.ts:4）。
4. skctl install 固有产物：`/home/xuqinqin/.cache/agent-skills/tmp` 空目录（工具行为，非本变更写入，收尾不清理）。
- 连锁面：组 5 无依赖；spec-done 收尾复验发现层时按本条口径核对容器视图即可。

**R9 · 组 5 环境级发现与判据调整**（实测 + 用户确认 2026-11-05）
1. **目录消息缺失（平台层既定现象）**：dsh-tool-skill 的 `<available_skills>` 目录消息在本环境**从未发布过**（父会话日志 630 条跨安装点 + 全新子会话 + 62 个历史会话抽样，`<available_skills>` 零命中；`skill:` 开关未关 disabled=[]，非 F11）。门槛代码 `dsh-tool-skill/lib/index.js:931-960`（精确实例门 + snapshot.complete）从未满足。→ **description 自动触发链路在本环境缺失**；skill 显式调用正常（#3 正向加载出正文 / #4 反向报错双 PASS）。
2. **用户确认口径 + 诊断收敛**：skill 经 skctl 安装即为正确安装（本变更 4.2 四断言已证）；目录消息属 dsh 平台层现象，非本变更产物缺陷，不追修、不调 description（改了模型也看不到）。
   - **诊断补强（用户实测 2026-11-05）**：Web 主会话 `/inventory` 的 skill 段**可见 `dsh-plugin-writer`**——`/inventory` 与目录消息共用同一快照 API（`ctx.skills.snapshot`），快照含本条目 → **排除候选 (b) snapshot.complete=false / 快照残缺**；根因高度收敛于候选 (a)：dsh-tool-skill 发布门槛中的**精确实例门**（`dsh-tool-skill/lib/index.js:931-960` 的 `ctx.tools.get('skill', agent) === skillTool` 判定不成立——工具实例被遮蔽/包装/多实例化）。修复属 DSH 平台任务，遗留观察项随 spec-done 汇报。
3. **5.2A 判据调整（原「新写一个插件→命中本 skill」不成立）**：在「触发链路缺失 + dsh-plugins AGENTS.md 工作流约定（新功能先走 openspec-propose）」双重作用下，实测路由 openspec-propose 先行属该环境**合理行为**；两 skill 实为接力关系（规格→实现）。dsh-plugin-writer 的实际使用入口 = 用户显式 `/dsh-plugin-writer` 或指名加载。B 语句让位达成（本 skill 正确自分流至官方 skill，探针实证）；C 语句命中 openspec-propose 达成。
4. **cordis-plugin-development 不可加载 = 预期**：它是 DSH 包内 preset 资产（`dsh-agent-preset/skills/`），未经 skctl 登记聚合层，仅带该 preset 的会话注入——与 5.2B 代理观察一致，非缺陷。
- 连锁面：组 8 REFACTOR 不因 A 偏差改 description/触发词；spec-done 汇报含「目录消息平台层遗留观察」；后续任何触发类问题先查本条再动手。

**R10 · 组 6 演练结论与验收口径终态**（任务 6.1 实测，过程记录 /tmp/spec-flow/add-dsh-plugin-writer-skill/group6-drill.md）
1. **全链实质通过**：`pnpm install` / `verify:all` / `dsh:check` / `plugin add` 四条 exit 0；`--dump-config-schema` exit 1 与 add 前基线**逐字节一致**（既有 preset-* 行噪音），`x-cordis.entries` 223→224 恰新增本包（`status:"absent"` = host-only 无 Config 正常态）；`--dump-config | grep demo-echo` 注册行三行在位（diff 恰 +3 行）。**验收口径终态**：原「五条命令全 0」在本机不可达（环境噪音），以「4 条 0 + schema 基线对照无新增 error + 注册行在位」为准（与 build.md §9 / verify-install.md §4.1 文档口径一致）。
2. **skill 文档问题清单 7 条（组 8 REFACTOR 回填输入，已实测坐实）**：
   - ① SKILL.md:67 主册「schema 退出 0 = 通过」与分册矛盾 → 改「退出 0 **或** 基线对照无新增 error」（必改）
   - ② SKILL.md:61 件套漏 `vitest.config.ts`、「三个文件」指代不明 → 补全（必改）
   - ③ SKILL.md §4 必改清单缺 `src/index.ts` 入口形状（inject 空值写法/Config 可省/无需 src/host 转发层，三个决策全靠读源码）→ structure.md 增节
   - ④ SKILL.md:51 version 缺「演练/未发布包 `0.0.0`」例外 → 主册补括号
   - ⑤ structure.md §1 缺 `tsconfig.host.json` include 目录改写提示（静默通过但留脏配置）
   - ⑥ verify-install.md §4 缺「Unsupported engine 既有 WARN（node 22.18.0 vs engines 下限 22.19.0，全 importer 刷）」假故障条目
   - ⑦ verify-install.md §2.1 缺「新增 importer 致 lockfile peer-context 哈希整体迁移（362+/5- 中仅 33 行为新 importer），**整份保留勿局部还原**」——**组 7/9 直接相关**：还原 lockfile 必须整份 git restore，不得手工局部回滚
3. **正向印证**：structure.md §2/§3 行号锚全准、§5 0.0.0 判定成立、build.md §9「恰四条 preset error」与容器 import 自检命令逐字吻合、verify-install §2.3 两处核对点命中——文档主体可执行性成立，7 条均为增量修正。
4. **现场保留**（组 7/8/9 接力）：`plugins/demo-echo/` 11 文件在位、lockfile 已改未还原、profile link: 安装未移除（容器内 `live`）。
- 连锁面：组 7 双端抽验基于本现场；组 8 按第 2 条清单回填后重跑组 3 断言；组 9 清理四步按第 2-⑦条整份 restore lockfile；验收口径如上终态。

**R11 · 组 7 双端抽验结论：A7 假设被推翻 + 等价验收链**（任务 7.1 实测，强度 a 用户已选；过程记录 /tmp/spec-flow/add-dsh-plugin-writer-skill/group7-drill.md）
1. **双端改造完成且全绿**：`src/client/index.ts` + `lib/client.js` ModuleLoader 壳 + `dsh.client` + `exports["./client"]` + 双段 build.mjs + tsconfig 拆分 + `.oxlintrc.json`；verify:all（5 tests）/ dsh:check / link: 幂等刷新 add 全部 exit 0。
2. **design A7 假设被实测推翻（重要）**：`--dump-config` 只打印 patch 层合成树、**不运行 client-module scan**——双端改造前后输出逐字节相同，「dump-config 出现 client 注册行」口径技术上不成立。scan 证据层 = **启动图**（重启后 `__DSH_BOOT__` 含本包 entry / Web 设置→插件列表），必须重启 profile。
3. **等价硬证据链（技术验收完成态）**：裸包名行在位（F1 前提）+ 四处声明成对 + 容器内 scan 判定链静态回放 EXIT=0（parseDshClient / clientExportOf / 壳 id 全通过）+ `lib/client.js` 壳形状正确 + verify:all / dsh:check 绿。**7.1 勾选待目检决议后一并处理**。
4. **skill 文档问题 +7 条（组 8 素材，累计 14 条）**：react peer 是条件非形态属性（①）；件套漏 `.oxlintrc.json`（②，缺它 oxlint 扫生成壳报 2 条）；缺 `exports "./package.json"` 提示（③，scan 回退分支需要）；双端验收口径须改「dump-config 只证载体行，scan 识别重启后看插件列表」（④）；link: 幂等刷新指引（⑤，改源码重跑 add 即可无需 remove→add）；无 UI 座位包的目检入口说明（⑥）；files 写法 `lib/**/*.js` 通配统一（⑦）。
5. **事故记录（已完全恢复，主会话复核现场完好）**：`dsh web --help` 在本机挂起（prepareProfile teardown timeout EXIT=124，两次复现，**本机既有行为，不可当验证命令用**——已记平台层现象）；代理 pkill 清理时误杀自身 shell（node 容器内，仅剩 PID 1，工具容器无损失），产物由备份还原 + verify:all 复绿；主会话复核：lib 双产物在位、profile 2 处登记、注册行在位、dsh:check all agree。
6. **现场**：双端 demo-echo 在位、profile link: live、运行中 dsh 未重启（其 boot 图不含本包属预期——dsh 启动早于装入）。
- 连锁面：组 8 回填清单累计 14 条（R10 的 7 条 + 本条 7 条）；7.1 勾选与组 9 清理均待「重启目检时机」决议（重启 dsh = 中断本会话，恢复协议可续）。

**R12 · 组 8 回填终态**（任务 8.1 实测，14/14 条全部回填、0 条不回填）
- 五文件终态行数：SKILL.md 100（+3，含新反例 F13「双端验收错位」）、structure.md 121（+11，含 §1.1 src/index.ts 入口形状节）、dual-client.md 121（+7，含 §4 双端验收口径专段）、verify-install.md 194（+6，含 §4.4 engine WARN 假故障、lockfile 整份保留）、build.md 114（不变）；frontmatter 未动。
- 复验四项全过（主会话复跑确认）：组 3 断言 4/4 PASS、五文件版本数字 grep 零命中、SKILL.md ≤150、受影响演练抽查（容器 import `apply,inject,name` / dsh:check all agree / 注册行三行）全过。
- 处置明细（14 条 → 终版 file:line）见执行代理回执；要点：①schema 判据 SKILL.md:69 与 verify-install.md §4.1 一致化 ④验收口径 dual-client.md:103 + SKILL.md:99（F13）⑦lockfile 整份保留 verify-install.md:31（组 9 直接相关）。
- 连锁面：组 9 清理按 verify-install.md:31 口径整份 git restore lockfile；skill 产物终态 = 本组输出，收尾审核以此为准。

**R13 · 双端目检决议（组 7 收口）**
- 用户决议（2026-11-05）：**跳过 Web UI 目检，按等价证据链收案**（重启 dsh 将中断本会话，代价大于增量证据价值；等价链 = 裸包名行 + 四处声明成对 + 静态 scan 回放 EXIT=0 + `lib/client.js` 壳正确 + verify:all/dsh:check 绿）。
- 7.1 就此勾选收口；skill 文档中的目检指引（dual-client.md:109 / verify-install.md:99）对未来真实插件仍有效。
- 连锁面：组 9 清理不受影响（remove demo-echo 时 profile 内本就未产生 scan 态）；spec-done 汇报提一句「双端 scan 的启动图层证据未取（目检跳过），文档口径已按 R11-④ 修正」。

**R14 · 组 9 终态清理结论与执行期收口**（任务 9.1 实测）
1. **五项终态断言全绿**（主会话复核确认）：dsh-plugins 仓 `git status --short` 空（lockfile 经 `pnpm install` **精确回 HEAD**，无 peer-context churn，未触发 restore 兜底）；`--dump-config` demo-echo 零命中；容器内无悬空链接（R3 坑 2 实操命中并按文档 §3 处置）；dotfiles `dsh/profiles/web/{package.json,pnpm-lock.yaml}` diff 空（remove 恢复原状）；skill 产物与登记态不受影响（`skctl list` 命中 `enabled/local`）。**触达#10「dsh-plugins 仓零入库改动」达成**，`pnpm dsh:check` 复跑 exit 0。
2. **外部并发提交知会（非本变更）**：13:49:56 他变更 `project-mcp-primary-root-priority` 落档提交 `e11b656`（7 个 openspec 文件，不涉 lockfile/demo-echo，无冲突）；其文档中 3 处「demo-echo 残留」描述已随本次清理过时，订正归该变更负责代理。
3. **skctl 调用姿势精化（补 R8）**：经 `run.sh node` 执行时整条命令须引号包裹（`run.sh node "node $SKCTL list …"`），直接拼接会 126。
4. **9.1 代理环境视角误判澄清**：其称「`~/.local/share/agent-skills` 宿主上不存在」系 dsh 容器视角（HOME=/home/docker 未挂宿主 `.local`）；宿主侧登记态真实存在且有效（4.2 创建、主会话复核 skctl enabled/local），A5 结论不受影响。
- 连锁面：全部 14 任务完成 → auto 模式收口：停留呈证 → 用户审核确认 → dotfiles 单仓提交（多仓分立：dsh-plugins 零改动无提交）→ 委托 spec-done。
