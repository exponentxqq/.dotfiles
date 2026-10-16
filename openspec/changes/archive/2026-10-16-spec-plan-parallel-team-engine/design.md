# Design

> 规划与实施分离：本文件承载决策与门槛；`tasks.md` 承载可核对批次。全部路径相对仓库根 `/home/xuqinqin/develop/dotfiles`。

## 已核实事实

1. `agent/skills/spec-plan/SKILL.md` 当前 116 行 / 5133 码点；refs 四文件 102 / 28 / 68 / 18 行——入口与各资源文件均在渲染预算内（文件 ≤7849、渲染 ≤8192）。
2. spec-workflow 执行侧 team 引擎先例（`refs/execution.md`）：`spawn_teammate` 无模型参数（「该引擎忽略 apply 路由键，阶段级模型路由整体不适用（teammate 创建工具无模型参数，fork teammate 锁定 Lead 模型）」）；成员上限 `Team member limit 8 reached`；成员卡死 `interrupt_agent` 后重建，无法恢复降级 subagent；待决回送 `send_message` 同一成员。
3. spec-workflow 主规范（`openspec/specs/spec-workflow/spec.md` L249）本就将 `code-design.md` 称为「变更工件」（组段终形态化同步对象），无 /tmp 表述——落档材料入库不与其主规范冲突，无需 spec-workflow delta。
4. `openspec-explore`（OpenSpec skill 族，dsh-plugins `.dsh/skills/`）为 stance 型：无固定步骤与产物、写作需确认、结尾导向 `/openspec-propose` 交接；`grill-me`（dotfiles 自写）自含设计树/前沿/≤5 问/答完重算方法全文。
5. 主规范 `openspec/specs/spec-plan/spec.md` 的 Requirement「阶段 1 独立双线规划」含串行双线 Scenario（「串行模式依次独立完成两遍」）；「双线差异收敛与分歧复算」为六步口径。
6. `openspec validate --strict` 对 >500 字符 Requirement 正文告警（writer-skill 变更先例）；本变更各 MODIFIED/ADDED 正文已按 ≤500 字符撰写，validate 复核。
7. 变更目录内附加材料（`code-design.md` 等）是否触发 validate 报错：落档后即验（任务 2.2），实测为准。

## 触达面

| # | 文件 | 动作 | 要点 |
| --- | --- | --- | --- |
| T1 | `agent/skills/spec-plan/SKILL.md` | 改写 | §一 参数表（`--parallel`=team+回退；串行=单线）与状态载体句（两材料落档）；§四 重构「阶段 1 规划编排」骨架（并行双线铁律保留、串行单线骨架、中转协议适用范围）；§五 七步/直收概述；§六/§七 输入分支与落档材料扩充；§二 ④ 自检加 openspec-explore；§八 路由适用性；路由表加 mode/ 两行 |
| T2 | `agent/skills/spec-plan/mode/parallel.md` | 新建 | 并行手册：team 派发流程与成员规约（命名 `spec-plan-<change>-line-a|b`、context fresh）、5 条不可行判据与按线回退、subagent 并行模板（自 planning.md 迁移改造）、双引擎回执核对与 team 同成员补正重派、成员生命周期（闲置不复用、不 interrupt） |
| T3 | `agent/skills/spec-plan/mode/serial.md` | 新建 | 串行手册：openspec-explore 探索契约（explore.md 7 字段 + 待决节；产物契约由本 skill 规定；忽略交接段与写前确认护栏）、问答节奏（零星即问、系统待决汇 1.5）、grill-me 收敛接线与 decisions.md 留痕契约 |
| T4 | `agent/skills/spec-plan/refs/convergence.md` | 改写 | 并行专属七步（导语注明仅并行；插入第 4 步探索审视契约：范围约束、留痕节、与 grill-me 接线）；串行收敛放 mode/serial.md 不在此 |
| T5 | `agent/skills/spec-plan/refs/planning.md` | 瘦身改写 | 删双线派发节（迁 mode/parallel.md、serial.md）；保留前置检查展开（④ 自检加 openspec-explore）、阶段 1.7 全量契约（输入材料按编排分支）、落档细节（第 1 步扩「四件套 + 复制两份规划材料」、第 7 步提交范围措辞、第 6 步摘要列两材料） |
| T6 | `agent/skills/spec-plan/refs/routing.md` | 修改 | 键表 lineA/lineB 应用点注「仅 subagent 派发时应用」；硬约束补 teammate 无模型选择、显式覆盖该两键→该线 subagent、team/串行下键适用性矩阵 |
| T7 | `agent/skills/spec-plan/refs/failure-modes.md` | 修改 | 新增：Agent Teams 未挂载/spawn 失败或 provisioning failed/达 8 上限 → 按线回退 subagent 留痕不重试；成员卡死 → interrupt 重建一次仍失败回退；openspec-explore 不可载（串行阶段 1 与并行 1.5 审视段共用）→ 修复后问用户不静默降级；恢复条目按现存文件名辨编排、落档后从变更目录取两材料 |
| T8 | `agent/skills/spec-workflow/SKILL.md` | 微改 | §一 工件跨界所有权句改为「由 spec-plan 产出并随落档提交至变更目录，执行期由本 skill 维护落档副本」 |
| T9 | `agent/skills/spec-workflow/refs/execution.md` | 微改 | 组段终形态化与 R<n> 留痕两条注记维护 `openspec/changes/<change>/` 落档副本、更新随批次提交 |
| T10 | `openspec/specs/spec-plan/spec.md` | 归档同步 | 经本变更 delta 同步，不手改；归档后逐 Requirement 复核 |

## 决策记录

- **D1 回退粒度 = 按线独立，非整体回退**：team 派发是逐成员动作，已成功创建的成员无销毁工具（durable），整体回退会造成「已运行成员 + 重派子代理」双轨写同一产物；按线回退让部分失败只影响该线，混合引擎（A 线成员 + B 线子代理）对独立性无影响。被否方案：整体回退（任一判据命中两线皆 subagent）——无法处置已运行成员，且浪费可用路径。
- **D2 显式 `--model lineA|lineB` 覆盖 → 该线强制 subagent**：teammate 无模型参数，team 下唯一选择是静默忽略用户显式参数——违反本 skill「绝不静默假设/降级」红线；映射文件默认值不阻止 team（同执行侧忽略 apply 键先例，留痕告知即可）。被否方案：team 忽略覆盖继续派发——显式参数被静默丢弃。
- **D3 team 编排下 lineA/lineB 不应用**：与 spec-workflow team 引擎「忽略 apply 路由键」同构；panel/design 恒为 subagent 不受编排影响。被否方案：为 teammate 引入模型参数——平台工具无此能力，不做包装假设。
- **D4 串行改单线（openspec-explore + grill-me）**：串行双线的「独立性弱于并行」是自认缺陷；小需求双线成本不必要。openspec-explore 是 stance 无产物契约 → **产物契约由本 skill 规定**（explore.md 7 字段 + 待决节），方法借用、产物自定；grill-me 方法全文在其 skill 内，各文件只写接线防双源漂移。串行专属文件名（explore.md/decisions.md，不用 line-a/b、diff-matrix）→ 恢复时按文件名辨编排，避免把「缺失 line-b.md」误判为该线失败。被否方案：串行保留双线仅降深度——保留自认缺陷；串行也写 line-a.md——恢复语义歧义。
- **D5 并行 1.5 七步（插入探索审视）**：交叉比对只能发现单边遗漏、发现不了双边遗漏；openspec-explore 自由审视可补双边盲区，其「事实自己查」纪律把可查证待决降级为事实裁定，grill-me 只问纯决策——题量更少更准。范围约束：不重开双线调研、不推翻已收敛共识（矛盾按待决上浮，同设计线「不推翻收敛」原则）。被否方案：维持六步——盲区与提问浪费持续存在；审视段前置到比对之前——尚无合并视图，无从审视。
- **D6 落档材料扩充（code-design.md + diff-matrix.md/decisions.md 入变更目录）**：spec-workflow 主规范本就称 code-design.md 为「变更工件」（组段终形态化对象），滞留 /tmp 使执行期维护与接续恢复在会话重启后失据，与三方对齐矛盾；落档副本为权威后执行期更新随批次提交入库。`explore.md`/`line-a.md`/`line-b.md` 不落档——原始探索材料，结论已由 design.md/specs/收敛留痕承载，入库徒增噪音。被否方案：全材料落档——噪音；维持 /tmp——易失矛盾不解决。
- **D7 mode/ 目录编排手册**：串行/并行细节互斥消费（串行会话无需 team 派发与回退判据，反之亦然），按消费时机外移原则的自然延伸；refs/ 只留跨编排公共参考。被否方案：全部塞 planning.md——单文件膨胀且串行会话加载无关 team 细节。
- **D8 openspec-explore 定为「必须」级依赖**（区别于 grill-me 缺失的提问降级）：用户点名其为串行模式与审视段组件，其探索纪律（先查证后提问、跟随依赖、grounded）是方法主体而非锦上添花；不可载按处置顺序修复后问用户三选一。被否方案：同 grill-me 静默降级裸调研——违背点名意图。
- **D9 已知双源维护点**：中转协议在 SKILL.md §四（红线级摘要）与 spec-workflow 侧各有适配文本；「按线回退判据」在 mode/parallel.md 为主、failure-modes.md 处置行为从简——沿用先例纪律，主源留痕于此。

## 风险与回退

- 入口码点超预算 → 编排细节全下放 mode/，入口骨架 + 铁律 + 红线 + 指针；实测任务 1.1 验证句把关。
- team 派发在 Agent Teams 未挂载会话报工具不存在 → 判据①按线回退 subagent，留痕，不判工具故障（同执行侧先例）。
- openspec validate 对变更目录附加材料报错（事实 7 未证实前）→ 若报错则材料改放 `openspec/changes/<change>/attachments/` 或回退为落档摘要引用（保留决策：材料必须入库，路径服从 validate）。
- 主规格归档漂移 → 归档后逐 Requirement 复核（先例纪律）。
