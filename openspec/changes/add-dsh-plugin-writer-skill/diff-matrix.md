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
