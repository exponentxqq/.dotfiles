# Design

> 规划与实施分离：本文件承载拆分决策与门槛；`tasks.md` 承载可核对批次。全部路径相对仓库根 `/home/xuqinqin/develop/dotfiles`。

## 已核实事实

1. 当前 `agent/skills/spec-workflow/SKILL.md` 7842 码点（渲染硬顶 7849，余量 7）；refs 五文件 2080/3390/2590/7133/4113 码点，全部 ≤8192。
2. 规划三节（§四五六，56–99 行）约 4716 码点——迁出后 spec-workflow 入口预期 3.5–4.5k，spec-plan 入口骨架化后预期 6–7.5k，两者均入预算。
3. 主规格 `openspec/specs/spec-workflow/spec.md` 17 个 Requirement；`openspec validate --strict` 对 >500 字符需求正文告警（writer-skill 变更先例 649 字符拆分处置）。
4. component:ai 执行实证（本变更纪律级吸收与流程级分期的依据）：team 成员上限 8（`Team member limit 8 reached`，slim-entry 变更同证）；`send_message` 寻址不到 subagent id；并发 gradle 下验证任务 SKIP 但 BUILD SUCCESSFUL（R16 两步法）；`-PspotlessFiles` 静默忽略（R19，项目特定，不入 skill）；每执行提示点名 writer skill 而栈识别结论仅在会话内阶段摘要；`code-design.md` 组段在组收尾重写为终形态、`diff-matrix.md` 执行期追加章、R<n> 编号留痕、`/tmp/<项目>-evidence/` 证据目录、root+service 双仓分别提交、真实密钥只经 `-P` 传参。

## 触达面

| # | 文件 | 动作 | 要点 |
| --- | --- | --- | --- |
| T1 | `agent/skills/spec-plan/SKILL.md` | 新建 | 规划四阶段入口骨架（frontmatter name=spec-plan；独立性铁律+中转协议·规划版+红线留入口；细节指针到 refs） |
| T2 | `agent/skills/spec-plan/refs/planning.md` | 新建 | 迁自 spec-workflow：双线派发细节、前置检查展开 ①④⑤、阶段 1.7 全量契约、落档细节（删第 7 步问执行模式、第 9 步改固定收尾、补组=审核批次与栈识别结论落盘两句）；**不迁**接续细节 |
| T3 | `agent/skills/spec-plan/refs/convergence.md` | 新建 | 近逐字迁移（六步判据 + grill-me 设计树/前沿法），头注节号按新入口改写 |
| T4 | `agent/skills/spec-plan/refs/routing.md` | 新建 | 规划键（lineA/lineB/panel/design/vision）+ 共享纪律（三档回退、图片能力表、白名单、自检脚本读共用 yaml） |
| T5 | `agent/skills/spec-plan/refs/failure-modes.md` | 新建 | 规划侧行（grill-me 降级、规划线/设计线失败、栈识别三选一、writer 加载失败、skill/命令不可见含 spec-plan.md symlink 路径、用户中断） |
| T6 | `agent/skills/spec-workflow/SKILL.md` | 改写 | 三规划节合并为 spec-plan 委托节；衔接吸收问执行模式；frontmatter 逐字节不变；节结构重组 |
| T7 | `agent/skills/spec-workflow/refs/execution.md` | 扩充 | 纪律级吸收六条：审核-提交分离、引擎批次间可切换+留痕、干净窗口验收两步法、嵌套子仓分仓提交、真实凭据纪律、执行期留痕与工件维护；writer 加载指令来源改「从落档 design.md 决策记录读取，无从取得则重识别一次」 |
| T8 | `agent/skills/spec-workflow/refs/routing.md` | 裁剪 | 键表裁至 apply/verify/vision；规划键归属注记（spec-plan 消费）；共享纪律与自检脚本保留 |
| T9 | `agent/skills/spec-workflow/refs/failure-modes.md` | 裁剪 | 保留执行侧+共享行；删规划专行（迁 T5）；补「team 成员上限 8 达限 → 降级 subagent」行 |
| T10 | `agent/skills/spec-workflow/refs/planning.md`、`convergence.md` | 删除 | 内容已迁 spec-plan；全仓断链清零 |
| T11 | `dsh/commands/spec-plan.md` + 容器 symlink | 新建 | 薄壳（argument-hint：`[需求描述] [--parallel] [--model <规划阶段>=<provider>/<模型>]`） |
| T12 | `agent/skills/README.md`、`dsh/README.md` | 修改 | 清单表加 spec-plan；dsh/README spec-workflow 节改写（文件表两 skill 分列、双入口、路由表键归属、组=审核批次、宿主操作、委托关系） |
| T13 | `dsh/spec-workflow.yaml` | 仅注释 | 头注释补键归属分工一行；键值零改动 |
| T14 | `openspec/specs/spec-plan/spec.md`、`openspec/specs/spec-workflow/spec.md` | 归档同步 | 经 delta 同步，不手改；归档后逐 Requirement 复核 |

## 决策

**D1 委托而非复制**：spec-workflow 规划内容合并为「加载 spec-plan」委托指针——规划方法论的单一权威源在 spec-plan，防双源漂移；委托在同一会话内完成（落档提交后由 spec-workflow 继续问执行模式），`/spec-flow` 全流程体验不变。

**D2 中转协议双份**：spec-plan 持规划版（上浮并入 1.5 统一提问、设计期并入落档分歧点提问），spec-workflow 持执行版（当批次即时代问、接续重派/`send_message` 回送）。不采用跨 skill 引用（skill 间互引脆弱、加载路径依赖聚合层）——**已知双源维护点**，后续触碰任一侧时同步核对另一侧。

**D3 栈识别结论落盘**：spec-plan 在落档时把结论（writer skill 名 + 识别证据）写入 `design.md` 决策记录——执行侧每个派发提示点名加载、接续恢复后仍可从工件取得；spec-workflow 侧无从取得时重识别一次（兜底，如实标注）。这是本变更唯一的行为增强（拆分前结论无持久落点，拆分后归位）。

**D4 组 = 执行审核批次**：tasks 分组契约补语义——组即审核批次、组内单任务是合法常态（component:ai 9 组 13 任务实证形态）、分组兼顾用户审核节奏。并行/串行、触达面条目编号引用等既有硬约束不变。

**D5 共用配置零迁移**：`dsh/spec-workflow.yaml` 键值不动、路径不动，文件头注释补「规划键 lineA/lineB/panel/design 与能力键 vision·规划侧由 spec-plan 消费；执行键 apply/verify、vision·执行侧、engine、parallelism 由 spec-workflow 消费」——白名单注释与路由自检脚本不失效；后续拆执行侧为独立 skill 时再评估配置文件拆分。

**D6 码点预算**：两入口各 ≤7849（渲染 = 文件 + 343 ≤8192）；refs 各 ≤8192。spec-workflow 入口预期 3.5–4.5k（余量充足，吸收委托节）；execution.md 吸收后预期 ~4.5k。

**D7 纪律级/流程级分期**：本期吸收**纪律级**六条（文本纪律，不改变执行节律）：①审核-提交分离；②引擎批次间可切换+留痕；③干净窗口验收两步法（R16 泛化）；④嵌套子仓分仓提交；⑤真实凭据只经参数；⑥执行期留痕与工件维护（组段终形态化、R<n> 编号、证据目录易失）。**流程级**三项立为紧后独立变更蓝图，不在本次落地：独立对抗性复核分档（L0 Lead 自核 / L1 独立只读复核·禁构建工具独立复现 / L2 复核+假绿检验·换桩验证测试有效性）、Lead 裁定协议（子代理报告的事实须独立复核确认后落笔，发现分类阻断/非阻断）、delta 复核（加固使冻结版本变更后只验增量）——component:ai 实证其价值（0 阻断结论、边界用例补齐）与成本（每组 +1 轮派发），分档判据须按项目门禁水平（覆盖率、框架约束）单独设计评审。

**D8 命名与入口**：命令 `/spec-plan`；spec-plan frontmatter description 含「被 spec-workflow 委托」与「独立使用」双触发；spec-workflow frontmatter（name/description）逐字节不变；`/spec-flow` 薄壳正文不动（参数面不变，规划参数由 spec-workflow 转发）。

**D9 暂存目录名不变**：`/tmp/spec-flow/<change>/` 维持原名——易失材料不入库，两 skill 共用同一 change 作用域，连续性优先于命名纯洁性。

**D10 主会话模型**：落档（spec-plan）与归档（spec-workflow）均在主会话进行，模型由用户切换，两 skill 一致只提示不代劳。

## 门槛（Gates）

| # | 门槛 | 判据 |
| --- | --- | --- |
| G1 | 结构 | spec-workflow frontmatter 逐字节不变（`git diff` 对 name/description 行为零命中）；两入口 ≤7849 且 +343 ≤8192；refs 各 ≤8192；两 skill 内全部 `.md` 互引 `test -f` 通过 |
| G2 | 关键词归属 | `触达面`/`六字段`/`设计树`/`前沿`/`独立性铁律` 定义源唯一在 spec-plan 侧；spec-workflow 入口零残留（execution.md 对 writer 接线的引用性短句 ≤2 处）；执行纪律新关键词（`SKIPPED`、`子仓`、`凭据`、`留痕`）在 spec-workflow 侧 |
| G3 | 规格 | delta：spec-plan ADDED×11、spec-workflow MODIFIED×6 / REMOVED×6 / ADDED×6（交互中转与栈识别因 MODIFIED 不得删既有 Scenario，按 REMOVED+ADDED 重构更名，先例 split-project-mcp）；Requirement 正文各 ≤500 字符；`openspec validate split-spec-plan-skill --strict` 退出码 0 且无告警 |
| G4 | 运行时 | 会话内按名加载 `spec-plan` 与 `spec-workflow` 各返回改后版本；聚合层含 `spec-plan` symlink；`/spec-plan`、`/spec-flow` 命令面板可见 |
| G5 | 配置 | `dsh/spec-workflow.yaml` git diff 仅注释行；路由自检脚本实跑「OK 全部路由 ⊆ 白名单」 |
| G6 | 提交 | 落档/实现/归档三次提交分离；一律显式 `git add`；排除 `dsh/profiles/web/cordis.patch.yml` 与 `nvim/` 无关脏改动 |

## Risks

- **R1** spec-plan 入口超预算 → 规划细节全部下放 refs（派发模板、深度契约在 planning.md），入口只保骨架+铁律+红线+指针；仍超则中转协议移入 refs（红线摘要留入口）。
- **R2** execution.md 吸收后超预算 → 留痕惯例表述精简或移 failure-modes.md，纪律语义不变。
- **R3** 归档规整误伤主规格 → 归档后逐 Requirement 复核 diff（先例：writer-skill 变更复核纪律）。
- **R4** 改动期间旧会话加载到新版本 → 目录级 symlink 实时视图，预期行为，无需处理。
- **R5** 中转协议/回退纪律双源漂移 → D2 已记维护点；G2 关键词断言兜底。
