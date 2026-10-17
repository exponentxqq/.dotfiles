# Code Design

深度契约六字段 + 附 (a)~(d)。本文件随落档复制入变更目录，落档副本为权威（执行期组段终形态化写它）。标注「未触 writer 约束（用户豁免）」。

## ① 触达面清单

| # | 文件（仓=dotfiles 根） | 改动意图 | 关键改动点 |
| --- | --- | --- | --- |
| T1 | `agent/skills/spec-workflow/refs/worktree.md`（新建） | worktree 前半程权威手册 | 六节：执行环境决策/布局与创建/**本地配置与环境错开**（端口公式+数据库独立库）/执行期使用/执行环境块（交接契约 schema）/恢复核对；全文见 (b).T1 |
| T2 | `agent/skills/spec-workflow/SKILL.md` | 五节联动 | §一两处+参数表行+消费时机表行、§五衔接③+恢复协议插第 5 步并重编号 5/6/7→6/7/8、§六隔离落点句、§七⑦六要素+⑧指路、§十红线追加；(b).T2-1~9 |
| T3 | `agent/skills/spec-workflow/refs/execution.md` | 三处 | 项目根 worktree 注记、多仓分立提交 worktree 变体、汇报六要素（④探测语义）；(b).T3-1~3 |
| T4 | `agent/skills/spec-workflow/refs/failure-modes.md` | 1 改 3 增 | 宿主操作行拆推送例外；worktree 占用/缺失脏/收尾归 spec-done 三新行；(b).T4 |
| T5 | `dsh/commands/spec-flow.md` | hint | argument-hint 插 `[--worktree]`；(b).T5 |
| T6 | `dsh/spec-workflow.yaml` | 注释一行 | 键归属注释补「verify 另由 spec-done 复用」；(b).T6 |
| T7 | `agent/skills/spec-done/SKILL.md`（新建） | 收尾半程全手册 | 六节：总览/前置检查/三方重建/隔离闭环八步（含本地环境处置）/非隔离轻量收尾/边界与失败；全文见 (b).T7 |
| T8 | `dsh/commands/spec-done.md`（新建） | 命令薄壳 | frontmatter+规则三条；(b).T8 |
| T9 | `~/.dsh/commands/spec-done.md`（symlink，不入库） | 容器内命令入口 | `ln -sfn` 指向 T8 源本（failure-modes 先例命令，容器内可做） |
| T10 | 聚合层登记（宿主操作，不入库） | skill 可加载 | `ln -sfn <源本> ~/.local/share/agent-skills/skills/spec-done`（聚合层=宿主侧 symlink 目录的 ro 挂载，容器内不可写） |
| T11 | `agent/skills/spec-plan/refs/planning.md` | 供料两处 | 1.7 模板①触达面注明所属仓；落档摘要加触达仓清单；(b).T11-1~2 |
| T12 | `agent/skills/spec-plan/SKILL.md` | 词组微调 | §六字段①括注「逐条注明所属仓」；(b).T12 |
| T13 | `openspec/changes/spec-workflow-worktree-lifecycle/specs/{spec-workflow,spec-plan,spec-done}/spec.md`（delta×3，随落档生成） | 主规格增量 | 结构见 (d) |

## ② 证据锚

- `agent/skills/spec-workflow/SKILL.md:15-17`（流水线与代码块，T2-1/2 锚点）、`:31`（--engine 行后插参数行）、`:38`（execution.md 行后插时机行）、`:58`（衔接②句尾）、`:65-67`（恢复协议 5/6/7 步，插步与重编号）、`:83`（共同纪律段尾）、`:91`（⑦汇报五要素）、`:113`（绝不做末条）。
- `agent/skills/spec-workflow/refs/execution.md:6`（提示自包含「项目根绝对路径」）、`:36`（多仓分立提交条）、`:67`（最终汇报五要素第 7 条）。
- `agent/skills/spec-workflow/refs/failure-modes.md:17`（需要宿主操作行）。
- `dsh/commands/spec-flow.md:3`（argument-hint）、`dsh/spec-workflow.yaml:3`（键归属注释）。
- `agent/skills/spec-plan/refs/planning.md:31`（模板①行）、`:70`（展示摘要第 6 步）；`agent/skills/spec-plan/SKILL.md:94`（§六六字段括注）。
- `/home/docker/.agents/skills/`（聚合层 symlink 形态，T9/T10 依据）；`~/.dsh/commands/`（命令 symlink 先例）。

## ③ 接口与数据形状

- **执行环境块**（写入落档 design.md 决策记录；schema 唯一权威源 = T1 worktree.md，spec-done 只引用）：
  ```
  - 执行环境：隔离（或：直用主工作区）。布局：<仓> → <worktree 绝对路径> @ feature/<change>；装配：<命令清单>；环境错开：端口 <服务=值，…>、库 <原库→原库_wt<n>，…>、入库配置改动 <文件清单>（未错开省略本段）；创建于 <日期>
  ```
- **命令接口**：`/spec-flow [… --worktree …]`（新参数位）；`/spec-done <变更名>`（新命令）。
- **yaml**：仅注释行变更，键值与 schema 不动。

## ④ 决策记录（实现级；流程级 D1~D13 见 design.md，以彼为权威不重复）

- **锚点计数口径沿 R1 先例**：`grep -c` 数行、同行多锚点用 `grep -o | wc -l`。被否：直接照抄历史验证句形态——1.2 的 `--worktree` 同文件两处不同行，行/次口径均需显式。反例：execution-hardening R1 三实例。
- **逐字文本以 (b) 节为准**（实施照抄，防并行措辞漂移）。被否：只给改动意图让实施自拟——上轮已证明逐字预排可消除漂移。
- **码点压缩顺序（若 T2 超 7849）**：先⑧并入⑥ → 再压 §六句 → 最后压 §一 pipeline 行；红线与恢复协议步序不砍。
- **T10 聚合层登记不静默代做**：容器内只读（挂载事实），呈证宿主命令交用户执行；被否：绕行写聚合层。

## ⑤ 逐任务组实现要点（与 tasks 分组一一对齐）

- **组1（T1~T6，5 任务）**：先建 T1（T2/T3 的链接目标），再 T2 五节联动（重编号一处），T3/T4/T5/T6 相互独立可并行；全部逐字照抄 (b)。
- **组2（T7~T10，3 任务）**：T7 全文照抄；T8+T9 同任务外不可拆（命令+symlink 一体验证）；T10 呈证宿主命令、登记后以 `ls` 补验。
- **组3（T11~T12，2 任务）**：词组级替换，注意 planning.md 模板行在代码块内（缩进两格保留）。
- **组4（只读校验，2 任务）**：python3 单脚本汇总断言（码点+锚点计数）；`openspec validate --strict` + 链接完整性 + `git status` 范围核对。

## ⑥ 设计假设与未决项

- 假设：dotfiles master 可直提（工作区干净实测）；ssh 修复持久（镜像层+挂载入库）；`.dsh/commands` symlink 热加载（先例 spec-flow 同款）。
- 未决项：无（Q1~Q13 全裁定）。

## 附 (a) 定位表

（同 ① 触达面清单，编号一致；行号见 ② 证据锚。）

## 附 (b) 逐字新文本（实施照抄此节）

### (b).T1 `agent/skills/spec-workflow/refs/worktree.md` 全文

```
> 本文件为 SKILL.md 第五节（衔接·执行环境决策、恢复协议·执行环境核对）与第六节（隔离执行的派发根与提交落点）的外移正文；回入口引用写「SKILL.md 第五节/第六节」。归档后的收尾半程（推送/合并/清理闭环）由 skill **spec-done** 承载，本文件只定义 worktree 前半程与交接契约。

## 执行环境决策（衔接点）

- **判据**（命中任一 → 推荐隔离）：主工作区有与本变更无关的未提交改动｜主工作区检出其他进行中分支｜存在并行变更 worktree｜用户明示。
- **整批统一**：一次询问「隔离（全部触达代码仓建 worktree）或直用主工作区」，不按仓拆问；`--worktree` 预置跳过询问。
- 决策与布局写入落档 **design.md 决策记录「执行环境」块**（schema 见下），随衔接后首个批次提交入库；同时记进度笔记。

## 布局与创建

- 布局默认（用户指定时从之）：多仓 `<根仓>/.worktrees/<change>/<子仓目录名>`；单仓 `.worktrees/<change>`；分支恒 `feature/<change>`。
- 创建：各代码仓主检出执行 `git worktree add <路径> -b feature/<change>`（基点 = 该仓主分支当前提交）；**一次性创建全部触达代码仓**；根仓（工件仓）不建 worktree。
- 前置核对：分支未被其他 worktree 检出（git 约束一分支一 worktree；占用 → 换路径或问用户，不强拆）；`.worktrees/` 已被该仓 ignore（缺失补一行 `.gitignore`，随首批次提交）。
- **装配**（创建后、首个派发前，按栈）：node → worktree 内 `pnpm install`（走容器包装，pnpm store 共享）；java → `./gradlew` 即用（gradle 用户缓存共享）；其他栈按项目声明验证方式补装配；**本地配置与环境错开见下节（装配的一部分）**。

## 本地配置与环境错开（装配的一部分）

- worktree 检出不含不入库文件：从各代码仓主检出复制本地配置（`.env`、`application-local.yml` 等项目本地配置文件）进对应 worktree，其余本地项（密钥等）随复制继承，再改写端口与数据库连接。
- **端口公式（自动写入，不询问）**：本地配置中每个端口项 → `默认值 + 100 × n`；n = 创建时根仓 `.worktrees/` 下**其他并行变更目录数**（首个 worktree n=1；主检出占默认端口）——与主检出及其他 worktree 天然错开。
- **数据库隔离（同实例独立库）**：并行 worktree 共库会因 migration 冲突（版本表互相覆盖）静默损坏数据——每变更独立 database：库名 `<原库名>_wt<n>`（同一 n），装配期 `CREATE DATABASE IF NOT EXISTS`，连接串改指新库。新库基线：项目声明（seed/初始化脚本）优先；无声明空库 + 该分支 migration 全量重放（flyway 等启动时自动跑）。redis 等无 schema 冲突的中间件不自动隔离。
- **入库配置**（该类文件入库的仓）：直接改工作副本、不提交（改动不进批次提交）；改动文件清单记入执行环境块，**收尾删 worktree 前还原（归 spec-done）**。
- 端口与库名的实际值写入执行环境块（schema 见下）；恢复/重建按块中值重写副本，不重新分配。

## 执行期使用

- 子代理提示的「项目根（绝对路径）」= worktree 路径；验证句在 worktree 内执行。
- 提交落点：代码批次提交落 worktree（`feature/<change>` 分支）；tasks/code-design 等工件提交落根仓主工作区——多仓分立提交不变，只是代码仓的检出换成 worktree。

## 执行环境块（交接契约 schema；唯一权威源）

写入落档 design.md 决策记录，格式：

```
- 执行环境：隔离（或：直用主工作区）。布局：<仓> → <worktree 绝对路径> @ feature/<change>；装配：<命令清单>；环境错开：端口 <服务=值，…>、库 <原库→原库_wt<n>，…>、入库配置改动 <文件清单>（未错开省略本段）；创建于 <日期>
```

执行期恢复（本 skill）与归档后收尾（spec-done）均从此块读取；**本文件是该 schema 的唯一权威源，spec-done 引用不复制**。

## 恢复核对（恢复协议第 5 步）

从 design.md 决策记录读执行环境块（隔离时）→ `git worktree list` 比对：

- **worktree 在** → 续用（核对依赖装配仍在，缺则补；本地配置端口/库名与执行环境块一致，漂移按块重写）。
- **缺失但分支在** → 按上文布局重建（`git worktree add <路径> feature/<change>`）+ 装配（含按块中端口/库名重写本地配置）+ 按三方对齐核对该仓进度。
- **均无** → 报告问用户，不以主工作区状态自行假设隔离已失效。
```

（注：全文内层代码块以四反引号包裹避免嵌套冲突；实施时文件本体不含本注。）

### (b).T2 `agent/skills/spec-workflow/SKILL.md` 九处

- **T2-1**（§一 首段句尾）：`本 skill 承载衔接、执行与归档：` → `本 skill 承载衔接、执行与归档；**归档后的收尾半程（推送/合并/worktree 清理）委托 skill \`spec-done\`**：`
- **T2-2**（§一 流水线代码块末行）：`→ 阶段3 执行 → 阶段4 验证与归档（本 skill 承载）` → `→ 阶段3 执行 → 阶段4 验证与归档（本 skill 承载）→（归档后）收尾闭环（skill spec-done 承载）`
- **T2-3**（§一 参数表，`--engine team` 行后插）：`| \`--worktree\` | 执行环境预置**隔离**（衔接点跳过询问）；缺省衔接点按判据问（第五节） |`
- **T2-4**（§一 消费时机表，execution.md 行后插）：`| 衔接点执行环境决策与恢复核对 | [worktree.md](refs/worktree.md) —— 隔离判据、布局与创建装配、本地配置与环境错开、执行环境块（交接契约 schema）、恢复核对 |`
- **T2-5**（§五 衔接②句尾）：`被打断的会话按恢复协议重建进度。` → `被打断的会话按恢复协议重建进度；③**执行环境决策**（\`--worktree\` 预置跳过）：按 [worktree.md](refs/worktree.md) 判据推荐**整批隔离**（全部触达代码仓建 worktree）或直用主工作区，一次问清；选定后创建+装配，**执行环境块写入落档 design.md 决策记录**（随衔接后首个批次提交——执行期恢复与收尾 spec-done 的交接契约）。`
- **T2-6**（§五 恢复协议：第 4 步后插新第 5 步，原 5/6/7 → 6/7/8）：插入 `5. **执行环境核对**：design.md 决策记录有执行环境块（隔离）时 → \`git worktree list\` 比对——worktree 在 → 续用（含装配核对，缺则补）；缺失但分支在 → 按 [worktree.md](refs/worktree.md) 重建+装配+三方对齐核对；均无 → 问用户。`；原第 5/6/7 步仅改行首编号为 6/7/8（文字不动）。
- **T2-7**（§六 共同纪律段尾追加）：`（展开见 [execution.md](refs/execution.md)）。` → `（展开见 [execution.md](refs/execution.md)）。隔离执行时（衔接③），子代理提示的**项目根与验证句执行目录均为 worktree 路径**；代码批次提交落 worktree 的 \`feature/<change>\` 分支、根仓工件落主工作区（见 [worktree.md](refs/worktree.md)）。`
- **T2-8**（§七 ⑦整条替换）：`**⑦汇报五要素**（工件路径 / 验证证据 / 归档位置与主规格 / 宿主操作清单 / 沉淀回流清单——执行期改动的工作流仓文件，交用户决定提交与方式）。` → `**⑦汇报六要素**（工件路径 / 验证证据 / 归档位置与主规格 / 宿主操作清单 / 沉淀回流清单——执行期改动的工作流仓文件，交用户决定提交与方式 / 遗留待办——worktree 闭环清单（入口 \`/spec-done <变更名>\`）、临时偏离恢复点、预留编号）→ **⑧收尾指路**：收尾半程由 skill **spec-done** 承载，本 skill 在遗留待办中指路、不代跑。`
- **T2-9**（§十 绝不做末条追加）：`…多仓**分立提交**（代码 / 工件 / 生成物各归其仓、N 仓各自完整提交）、不跨仓混提。` → `…不跨仓混提；不 force push、不在用户确认已推送+已合并前删 worktree（删前必查干净——收尾红线归 spec-done）。`

### (b).T3 `agent/skills/spec-workflow/refs/execution.md` 三处

- **T3-1**（subagent 提示自包含清单首项）：`项目根绝对路径、` → `**项目根绝对路径**（隔离执行时 = worktree 路径，见 [worktree.md](worktree.md)）、`
- **T3-2**（多仓分立提交条尾追加）：`**N 仓各自形成完整提交、不跨仓混提**。` → `**N 仓各自形成完整提交、不跨仓混提**；隔离执行时代码仓的检出即 worktree（\`feature/<change>\` 分支）——代码提交仍在该 worktree 内做、工件提交仍在根仓主工作区，布局与装配见 [worktree.md](worktree.md)。`
- **T3-3**（验证与归档派发要点第 7 条整条替换）：`7. **最终汇报五要素**：…④后续宿主操作清单（需要用户在容器外做的事，如 skctl 登记、推送 \`git push\`、以及命令仍不可见时的 \`docker compose restart dsh\` 兜底——本流程不代劳）；⑤**沉淀回流清单**——…本流程不代提交。` → `7. **最终汇报六要素**：①变更名与工件路径；②验证证据（命令 + 结果摘要）；③归档位置（\`openspec/changes/archive/...\` 与同步后的主规格）；④后续宿主操作清单（需要用户在容器外做的事，如 skctl 登记、推送探测不可行时的 \`git push\`、以及命令仍不可见时的 \`docker compose restart dsh\` 兜底——推送先探测、可行则按用户指示代推，见 [failure-modes.md](failure-modes.md)）；⑤**沉淀回流清单**——执行期改动的工作流仓文件（skill 文本、工作流配置，含未提交项）逐条列明，交用户决定提交与方式，本流程不代提交；⑥**遗留待办**——worktree 闭环清单（入口 \`/spec-done <变更名>\`）、执行期临时偏离恢复点、预留编号，交用户决定收尾时机。`

### (b).T4 `agent/skills/spec-workflow/refs/failure-modes.md` 一改三增

- 末行 `| 需要宿主操作（重启容器兜底、skctl、推送、装依赖） | 给出确切命令交给用户执行，**本 skill 不代劳** |` → `| 需要宿主操作（重启容器兜底、skctl、装依赖） | 给出确切命令交给用户执行，**本 skill 不代劳**；**推送例外**——先探测（fetch 成功 / \`ssh -T\` 可达），可行则按用户指示代推，不可行才给宿主命令 |`
- 其后增三行：`| worktree 分支已被其他 worktree 检出（创建/重建时） | git 约束一分支一 worktree：换 worktree 路径或问用户，**不强拆他人检出**（worktree.md） |`；`| 恢复时 worktree 缺失或脏 | 按 worktree.md「恢复核对」处置：缺失但分支在 → 重建+装配+三方对齐核对；均无 → 问用户；脏 → 呈证问处置，不擅自清理 |`；`| 收尾期 rebase 冲突 / push 被拒 / worktree 脏不能删 | **收尾半程归 skill spec-done**（abort+呈证三选一 / fetch+rebase 一次重试 / 停下不 force），本 skill 只在遗留待办指路 |`

### (b).T5 `dsh/commands/spec-flow.md`

argument-hint：`[--engine team]` 后插 `[--worktree]`：`argument-hint: "[需求描述 | continue <变更名>] [--parallel] [--auto|--step-task|--step-group] [--engine team] [--worktree] [--model <阶段>=<provider>/<模型>]"`

### (b).T6 `dsh/spec-workflow.yaml` 注释

`#         apply/verify、vision·执行侧、engine、parallelism 由 spec-workflow 消费（两半共用本文件与白名单）` → `#         apply/verify、vision·执行侧、engine、parallelism 由 spec-workflow 消费（两半共用本文件与白名单）；verify 另由 spec-done 复用`

### (b).T7 `agent/skills/spec-done/SKILL.md` 全文

```
---
name: spec-done
description: spec 驱动工作流的收尾半程——已归档变更的分支闭环（rebase→全量复验→推送→合并确认→删 worktree→清分支）与非隔离轻量收尾，从归档工件与 git 事实三方重建进度。Use when 用户要「收尾/闭环/推送合并/删 worktree」或调用 /spec-done <变更名>；变更未归档先回 spec-workflow。
---

# spec-done 收尾半程

本 skill 是**执行手册**：每步按本文执行，未写到的情况回到用户。本文件面向**没有本次对话上下文**的未来会话——一切从归档工件与 git 命令输出重建。

## 一、总览

收尾 = 已归档变更的最后一段：**隔离闭环八步**（rebase→全量复验→推送→合并确认→删 worktree（含入库配置还原+独立库去留询问）→清分支）或**非隔离轻量收尾**（推送+遗留待办复核）。上游：spec-workflow（执行与归档，其归档汇报⑥遗留待办指路到本 skill）。**worktree 前半程（决策/创建/装配/执行期/恢复核对）与执行环境块 schema 以 spec-workflow 的 `refs/worktree.md` 为唯一权威源，本 skill 只引用不复制**；复验子代理模型路由复用 `/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml` 的 `verify` 键（三档回退同 spec-workflow）。

承诺：**不可逆动作（删 worktree/清分支）前必以 git 事实复核并等用户确认**、**阶段边界必汇报**、**不假设未给出的选项**。

参数：`<变更名>`（缺省问用户；恰有一个待收尾变更时可确认推断）。

## 二、前置检查

①**已归档**：`openspec list --json` active 列表无该名 + `openspec/changes/archive/` 下 `*-<变更名>/` 存在（glob 定位归档目录）；未归档 → 提示先走 spec-workflow 阶段 4，本 skill 不代归档。②**读执行环境块**：归档 `design.md` 决策记录——有块（隔离）走第四节、无块按非隔离（第五节）并如实告知。③**git 事实**：各触达仓 `git worktree list`、`git fetch origin` 后分支与合并状态。④**推送能力探测**：fetch 成功或 `ssh -T <host>` 认证通过 = 可代推；失败 → 本轮 push 步给宿主命令并等回告，不绕行换协议硬闯。

## 三、三方重建（先于任何动作）

对照三源输出**每仓收尾进度摘要**：①归档 design.md 执行环境块（仓→worktree 路径→分支）②`git worktree list` 实际 ③fetch 后分支事实——origin 主分支是否已含 `feature/<change>` 提交（`git branch -r --contains <该分支最新提交>` 或 merge-base 判定）、`git branch -d` 能否安全放行。每仓归入四态：**未推送 / 已推送未合并 / 已合并未清理 worktree / 已合并未清分支**，从每仓第一个未完成步继续；**闭环按仓独立推进，不设全体屏障**（一仓合并慢不阻塞他仓）。

## 四、隔离闭环八步（每仓独立）

1. **发起**：用户 `/spec-done <变更名>` 或等价指令；先跑第二节+第三节。
2. **fetch + rebase**：worktree 内 `git fetch origin && git rebase origin/<主分支>`。**冲突 → `git rebase --abort` 回退**，呈证冲突文件清单、双方意图、建议解法，问用户三选一：**授权代解 / 用户自解后继续 / 放弃 rebase** 换策略——不自行解冲突。
3. **全量复验**：rebase 改写全部提交链 → 该仓**全量测试**（项目声明验证方式优先；干净窗口两步法：无并发、真实 executed 无 SKIPPED/FROM-CACHE）。可派 fresh 子代理（`verify` 路由）。失败 → 停下报告，不带病推送。
4. **push**：探测可行 → `git push -u origin feature/<change>`；被拒（远端主分支又前进）→ fetch+rebase 一次后重试，仍拒报告；探测不可行 → 给宿主命令并等回告。
5. **用户 codereview + 平台合并**：人工环节，等回告——不催、不代并、不代做合并决策。
6. **删 worktree（含本地环境处置）**：**硬门槛 = 用户确认已推送+已合并**；动作前以 git 事实复核（fetch 后 origin/<主分支> 含 feature 提交）而非仅凭口述 → **本地环境处置**：入库配置改动按执行环境块清单还原（`git checkout -- <文件>`），独立 database 清单（执行环境块）呈证问用户 **DROP**（给命令或按推送探测口径代跑）还是**保留** → `git status --porcelain` 确认 worktree 干净 → `git worktree remove <路径>` → `git worktree list` 复核未波及其他 worktree。**脏 → 停下呈证，不 force**。
7. **清本地分支**：`git fetch origin && git branch -d feature/<change>`（`-d` 在合并事实可见后安全放行；放行失败 = 未合并，停下呈证，不 `-D`）。
8. **根仓 main 推送 + 闭环汇报**：工件仓主分支推送（探测代推同第 4 步口径）；汇报各仓提交链、rebase 复验证据、合并点、清理结果、独立库处置终态（DROP/保留）、遗留待办终态（临时偏离恢复点、预留编号）。

## 五、非隔离轻量收尾

直用主工作区执行的变更：推送当前分支与根仓 main（探测代推；不可行给宿主命令）+ 遗留待办复核（执行期临时偏离恢复点、预留编号——从归档 tasks/code-design 留痕汇总）呈报。无 worktree 清理步骤。

## 六、边界与失败（红线）

| 情形 | 处置 |
| --- | --- |
| 变更未归档 | 提示先走 spec-workflow 阶段 4，不代归档 |
| 执行环境块缺失 | 按非隔离轻量收尾处理并如实告知，不假设曾隔离 |
| rebase 冲突 | abort 回退 + 呈证三选一（第四节步 2），不自行解冲突 |
| push 凭证/ssh 不可行 | 给宿主命令等回告，不绕行换协议硬闯 |
| worktree 脏 / `branch -d` 放行失败 | 停下呈证：不 force remove、不 `-D`，交用户裁决 |
| 复验失败 | 停下报告证据，不带病推送；修复后从步 2 重走 |
| 入库配置未还原 / 独立库未问 | 删 worktree 前必核对：配置改动已按清单 `git checkout` 还原、库名清单 DROP/保留已问过用户；缺一不删 |

**绝不做**：不 force push；不在用户确认已推送+已合并前删 worktree；删 worktree 前不查干净不删、入库配置未还原或独立库处置未询问不删；不代用户做 codereview 或合并决策；不动与本变更无关的 worktree 与分支；不把「用户口头说已合并」当 git 事实（必 fetch 复核）。
```

### (b).T8 `dsh/commands/spec-done.md` 全文

```
---
description: 固定工作流收尾半程：已归档变更 rebase→复验→推送→合并→worktree 清理闭环（spec-done）
argument-hint: "<变更名>"
---
加载 spec-done skill，并按其收尾半程执行。

调用参数：$ARGUMENTS

规则：
- 变更名缺省时先向我确认要收尾哪个变更；未归档的变更提示先经 /spec-flow continue 完成归档。
- 不可逆动作（删 worktree、清分支）前先以 git 事实复核，并在硬门槛处等我确认。
- 归档 design.md 无执行环境块时按非隔离轻量收尾处理并如实告知。
```

### (b).T11 `agent/skills/spec-plan/refs/planning.md` 两处

- **T11-1**（1.7 模板①行）：`  ① 触达面清单：逐文件路径 + 改动意图 + 关键改动点` → `  ① 触达面清单：逐文件路径（**注明所属仓**——根仓/子仓名）+ 改动意图 + 关键改动点`
- **T11-2**（落档细节第 6 步）：`6. **展示摘要**：变更名、四件套与两份材料路径（\`code-design.md\`、\`diff-matrix.md\`/\`decisions.md\`）、任务组数与条数、` → `6. **展示摘要**：变更名、四件套与两份材料路径（\`code-design.md\`、\`diff-matrix.md\`/\`decisions.md\`）、**触达仓清单**（根仓工件/各代码子仓——执行侧执行环境决策与多仓分立提交的输入）、任务组数与条数、`

### (b).T12 `agent/skills/spec-plan/SKILL.md` 一处

（§六）：`深度契约**六字段**（触达面清单 / 证据锚 /` → `深度契约**六字段**（触达面清单——**逐条注明所属仓** / 证据锚 /`

## 附 (c) 验证句核对表（预期计数自 (b) 逐字推得）

| 任务 | 锚点 | 口径 | 预期 |
| --- | --- | --- | --- |
| 1.1 | `## 执行环境块` | grep -c | 1 |
| 1.1 | `git worktree add` | grep -o \| wc -l | 2 |
| 1.1 | `默认值 + 100 × n` | grep -c | 1 |
| 1.1 | `CREATE DATABASE IF NOT EXISTS` | grep -c | 1 |
| 1.1 | `_wt` | grep -o \| wc -l | 2 |
| 1.1 | `本地配置与环境错开` | grep -o \| wc -l | 2 |
| 1.2 | `--worktree` | grep -o -e \| wc -l | 2 |
| 1.2 | `执行环境决策` | grep -c | 2 |
| 1.2 | `执行环境核对` | grep -c | 1 |
| 1.2 | `汇报六要素` | grep -c | 1 |
| 1.2 | `spec-done` | grep -o \| wc -l | 6 |
| 1.2 | `不依赖对话记忆` | grep -c | 1 |
| 1.3 | `汇报六要素` | grep -c | 1 |
| 1.3 | `推送先探测` | grep -c | 1 |
| 1.3 | `/spec-done` | grep -o \| wc -l | 1 |
| 1.4 | `推送例外` | grep -c | 1 |
| 1.4 | `不强拆他人检出` | grep -c | 1 |
| 1.4 | `收尾半程归 skill spec-done` | grep -c | 1 |
| 1.5 | `--worktree` | grep -o -e \| wc -l | 1（spec-flow.md） |
| 1.5 | `spec-done` | grep -c | 1（spec-workflow.yaml） |
| 2.1 | `## 四、隔离闭环八步` | grep -c | 1 |
| 2.1 | `## 三、三方重建` | grep -c | 1 |
| 2.1 | `本地环境处置` | grep -c | 1 |
| 2.1 | `DROP` | grep -o \| wc -l | 3 |
| 2.1 | `git checkout --` | grep -c | 1 |
| 2.2 | `spec-done.md` symlink | readlink 指向源本 | — |
| 3.1 | `注明所属仓` | grep -c | 1（planning.md） |
| 3.1 | `触达仓清单` | grep -c | 1 |
| 3.2 | `逐条注明所属仓` | grep -c | 1（spec-plan SKILL.md） |
| 4.1 | 全部 10 个入库文件 | python3 len | ≤7849 |
| 4.2 | `openspec validate spec-workflow-worktree-lifecycle --strict` | 退出码 | 0 |

## 附 (d) delta 结构（T13）

- `specs/spec-workflow/spec.md`：ADDED×3——「执行环境隔离决策」（2 Scenario）、「worktree 布局与创建装配」（2 Scenario）、「隔离执行落点」（1 Scenario）；MODIFIED×2——「落档到执行的衔接与恢复」（原 4 Scenario 保留 + 新增衔接执行环境决策留痕、恢复重建 worktree 共 2）、「验证门与归档提交」（原 2 Scenario 保留 + 新增归档汇报列遗留待办 1）。Requirement 文本均 <500 字符（validate --strict 零 warning 约束）。
- `specs/spec-plan/spec.md`：MODIFIED「阶段 1.7 代码设计线」（原 4 Scenario 保留 + 新增触达面条目标注仓归属 1）＋ MODIFIED「落档工件与执行批次契约」（原 8 Scenario 保留 + 新增落档摘要含触达仓清单 1）。
- `specs/spec-done/spec.md`（新能力，ADDED 全量）：「收尾入口与三方重建」（3 Scenario）＋「收尾 rebase 与全量复验」（2）＋「收尾推送与合并确认」（1）＋「worktree 删除与分支清理」（3）＋「非隔离轻量收尾」（1）＋「收尾红线」（1）。
