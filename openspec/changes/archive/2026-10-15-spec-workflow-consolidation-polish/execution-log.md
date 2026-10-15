# 执行记录：spec-workflow-consolidation-polish

**变更名**：spec-workflow-consolidation-polish（优化评估第一类无损修缮 + 第二类行为澄清）
**目标**：把上一轮评估报告的第一类 5 项与第二类 2 项落进 `agent/skills/spec-workflow/`，并把 `auto` 中途恢复语义与主规格措辞同步到 `openspec/specs/spec-workflow/spec.md`。
**执行方式**（用户批准的计划）：轻量 OpenSpec 变更（含 2 个 MODIFIED Requirement，无 `skip_specs`）；主会话串行执行，无子代理派发；不自举 `spec-workflow` 六阶段（勘察与方案枚举已在上轮评估完成）。
**提交链**：
1. `57a2d4d` 落档（`.openspec.yaml` + proposal.md + design.md + tasks.md + specs delta）
2. `8a77a04` 实现（6 个 skill 文件 + `dsh/README.md` + tasks.md 勾选）
3. 本文件与变更目录的归档提交
**工作区纪律**：三次提交均显式 `git add` 指定路径，`dsh/profiles/web/cordis.patch.yml`（宿主侧会话模型切换产生的脏改动，非本变更）始终排除。

## 1. 触达面与改动实绩

| 文件 | 改前 | 改后 | 说明 |
| --- | --- | --- | --- |
| `agent/skills/spec-workflow/SKILL.md` | 7816 | **7796** | §七 第 3 步补「以现存 diff 为准」（+65）＋删 §四 冗余指针（−60）＋§七 第 1 步注记收紧（−20）＋去「（唯一源）」（−5） |
| `refs/convergence.md` | 2864 | **2080** | 删与六步展开内第 4 步逐字一致的 801 码点重复块及其空行（−802）＋头注改写 |
| `refs/planning.md` | 6279 | **6375** | 头注补齐 §二/§四/§六/§十 与 1.7（+90）＋补父级 H2（+30）−删「入口指引」残段（−62）＋①④⑤ 标号与说明（+38） |
| `refs/routing.md` | 3900 | **4113** | yaml 依赖候选探测＋降级（+180）＋脚本去重复路径前缀（改用 `d+"../opencode/…"`，−29）＋自检说明补「跳过 ≠ 通过」（+62） |
| `refs/execution.md` | 3092 | **3235** | 头注补 §九（+40）＋三模式节补「中途恢复以现存 diff 为准」条目（+103） |
| `refs/failure-modes.md` | 2238 | **2304** | 「勾选态与证据矛盾」行改为与执行纪律同口径（+66） |
| `dsh/README.md` | 15079 | **15228** | 文件表 planning/execution 行补齐来源 ＋ 三模式段补中途恢复口径 |
| **六 skill 文件合计** | 26189 | **25903** | 净 −286 |

改后六文件码点：7796 / 6375 / 2080 / 3235 / 4113 / 2304 —— 全部 ≤8192（最紧的 `SKILL.md` 余量 396）。
未触及：`SKILL.md` frontmatter（逐字节一致）、12 个 `## ` 节标题、红线表、恢复协议既有语义、中转协议、「绝不做」段；`dsh/spec-workflow.yaml`、命令薄壳、宿主 profile 零改动。

## 2. 验证证据

| 门 | 内容 | 结果 |
| --- | --- | --- |
| G1 结构 | `SKILL.md` `## ` 标题 **12**；frontmatter 门禁（`git diff \| grep '^[-+]name:\|^[-+]description:'` 为空）退出码 0；15 个 href 经**仓库路径与聚合层**（`/home/docker/.agents/skills/spec-workflow/`）双路 `test -f` 全部命中、零坏链；`refs/` 内互链同样全部命中 | **PASS** |
| G2 去重 | `convergence.md` 八个 `grill-me` 方法要点计数 `[1,1,1,1,1,1,1,1]`；六步判据 1–6 齐备；801 码点重复块删除前以 `assert a==b` 校验逐字一致 | **PASS** |
| G3 码点 | 六文件 7796/6375/2080/3235/4113/2304 全部 ≤8192；`SKILL.md` 7796 ≤7816（净 −20 ≤0） | **PASS** |
| G4 渲染与加载 | 渲染上界 = 7796 + 343 = **8139 ≤8192**（余量 53）；实际加载响应确认 frontmatter 被宿主剥离（197 码点），实测口径 7796−197+343 = **7941**（余量 251）。会话内按名加载 `spec-workflow` 成功，返回**改后版本**（§七「以现存 diff 为准」、§一「权威进度 = 工件」、无 §四 冗余指针、§七 第 1 步 `--all --json`），base directory 解析为 `/home/docker/.agents/skills/spec-workflow`（symlink 直指仓库目录），`refs/` 五文件可见 | **PASS** |
| G5 路由自检三例 | ①正例（routing.md 内嵌脚本原样执行）退出码 **0**，打印「OK 全部路由 ⊆ 白名单」（9 条映射全部命中 5 条白名单）；②负例（`/tmp/routing-fixture` 夹具含 `bogus=nope/nope`）退出码 **1**，打印「不在白名单: bogus=nope/nope」；③降级例（候选路径全不存在）退出码 **0**，打印「缺 yaml 依赖：路由自检跳过（未校验，不等于通过）」且未输出 OK | **PASS** |
| G6 变更校验 | `openspec validate spec-workflow-consolidation-polish --strict` → valid，退出码 0；`openspec validate --all` → 2 passed / 0 failed，退出码 0 | **PASS** |
| G7 项目声明回归 | `tools/skctl`：`pnpm test`（`node --test 'test/*.test.ts'`，经 docker pnpm 包装）→ **tests 47 / pass 47 / fail 0**，退出码 0 | **PASS** |

## 3. 偏差与裁定

- **D-1（tasks.md 2.2 门限估算偏紧，已修正并留痕）**：原估 `refs/routing.md` ≤4100 码点，实测 4113——候选探测段是抗依赖缺失的必要增长，硬线 8192 余量充足。处置：①把脚本里第三条候选由绝对路径改为复用已有变量（`d+"../opencode/node_modules/yaml"`），去掉重复路径前缀（真改进，−29）；②门限按 ≤4200 判定，并在 tasks.md 该条验证句内注明「见执行日志 D-1」。属计划工件估算修正，非交付缺陷。
- **D-2（编号写法对齐）**：`planning.md` 前置检查展开最初写成「**① 确认 OpenSpec 根**」带空格，与入口 §二「**①OpenSpec 根**」不同形；已改为无空格写法，使两处标号可机械比对。
- **D-3（`auto` 规则三处同口径）**：`SKILL.md` §七（红线级一句）／`refs/execution.md`（展开理由）／`refs/failure-modes.md`（矛盾行）三处表述互查一致：先跑验证句 → 通过即保持勾选不重派 → 不通过才回退并报告。
- **D-4（渲染信封口径）**：沿用上轮标定的 343 码点信封结构；本轮以加载响应再次确认 frontmatter 被剥离（197 码点），故同时记录「上界 8139（保守，未剥 frontmatter）」与「实测 7941」两数。
- **自举观察**：本变更按用户批准的轻量过程执行，**无子代理派发**，故不产生「派发前是否读 refs/routing.md」的新数据点；如实记录，不冒充流程执行。

## 4. 宿主操作清单

1. **无需任何宿主操作**：skill 为目录级 symlink（`~/.agents/skills/spec-workflow → agent/skills/spec-workflow`），refs 改动即时生效——无需重登记、无需 `/commands-reload`、无需重启 dsh。
2. `dsh/spec-workflow.yaml`、命令薄壳、宿主 profile 白名单均未改动。
3. 待办：`git push`（本流程不代劳）；`dsh/profiles/web/cordis.patch.yml` 的宿主侧脏改动仍待自行决定提交或还原。
