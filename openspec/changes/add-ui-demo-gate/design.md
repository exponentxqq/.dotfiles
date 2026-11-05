# Design

> 逐断言承载 `code-design.md`（落档副本在本变更目录）的深度契约。逐字改动草案（手册接线 A–E 等）以该副本 ③3.7/3.8/3.9 为准，本文件记指针与预算断言，不复制全文（防双源漂移）。

## Context（已核实事实）

- 触达仓 = **dotfiles 根仓（唯一）**；openspec 根在位（`spec-driven` schema，zh-CN，结构标题与 SHALL/MUST 英文）。
- 码点基线（实测，pruner 硬线 8192）：spec-plan SKILL.md 7338 / planning.md 6111 / spec-workflow SKILL.md 6314。
- openspec 1.16.0 校验硬约束：ADDED requirement 正文 >500 字符 → WARNING → `--strict` 失败；MODIFIED 须整块携带主规格仍有的全部 scenario；proposal `## Why` 50–1000 字符；任务 ID 前缀 = `## N.` 组号；`--all --strict` 因主规格 2 条既存超长告警必红——**验收只用 `openspec validate add-ui-demo-gate --strict`**。
- DSH skill 事实：发现深度一层（`refs/` 不被当 skill）；`whenToUse` 对触发**零贡献**（`dsh-tool-skill` README:244，目录与加载包装层均不渲染）→ 软接线只能靠 `description`（`catalogDescriptionMaxLength` 500，写作用 ≤400）；未登记 skctl 的 skill 两个 agent 都看不到（`agent/skills/README.md:3-5`）。
- 平台事实：容器 `/tmp` ≡ 宿主 `/data/tmp`（`findmnt` 实测）；chrome-shared MCP 驱动的共享 Chromium 跑在 dsh 容器内（9222）→ `file:///tmp/...` 自检可解析；共享浏览器多会话须独立标签页。
- 工作区现状：dotfiles 有 3 个与本变更无关的既存脏改动（`dsh/profiles/web/*`）——**所有 git 断言限定路径**（`-- openspec agent`），不 stash/commit/revert。

## 触达面（16 条，逐文件；编号即 tasks 引用的「触达#N」）

| # | 路径（相对 dotfiles 根） | 性质 | 改动意图 |
| --- | --- | --- | --- |
| 1 | `agent/skills/ui-demo/SKILL.md` | 新建 | 唯一权威源入口：frontmatter 两键 + 8 节骨架，≤6000 码点，判定表前置 <2000 |
| 2 | `agent/skills/ui-demo/refs/html-recipe.md` | 新建 | 重参考：HTML 骨架 + L1/L2/L3 元素清单 + 自检命令卡，≤7000 码点 |
| 3 | `agent/skills/spec-plan/SKILL.md` | 修改 | 四处：流水线块（:15-18）、§六标题（:92）、`### 1.75` 子节（:94 后）、消费时机行（:41）；**不重编号** |
| 4 | `agent/skills/spec-plan/refs/planning.md` | 修改 | 四处：文件头（:1）、`## 附：阶段 1.75` 插入（:52-54 间）、复制句（:58 末）、条件断言（:68 后） |
| 5 | `agent/skills/spec-workflow/SKILL.md` | 修改 | 两处：流水线（:15-16）、状态载体句（:19 末）；**:55/:66 不动**（D11） |
| 6 | `agent/skills/README.md` | 修改 | :35 后补 `ui-demo` 登记行 |
| 7-11 | `openspec/changes/add-ui-demo-gate/{proposal.md, specs/ui-demo/spec.md, specs/spec-plan/spec.md, specs/spec-workflow/spec.md, design.md, tasks.md}` | 新建 | 本变更工件（阶段 2 产出） |
| 12 | `openspec/changes/add-ui-demo-gate/{code-design.md, decisions.md}` | 复制入 | 两份规划材料落档副本（既有规则） |
| 13 | （非触达）`openspec/specs/spec-plan|spec-workflow/spec.md` | 不改 | 主规格只由归档经 delta 同步 |
| 14 | （非触达）`dsh/spec-workflow.yaml` | 零改动 | Q5：不加 demo 键（1.75 主会话 inline，无派发） |
| 15 | （非触达）docker nginx / `dsh/commands/ui-demo.md` / `~/.dsh/AGENTS.md` | 出局 | Q1 全部不做 + Q3 先不要 nginx |
| 16 | `~/.local/share/agent-skills/skills/ui-demo`（symlink）+ `registry.json` | 机器态 | `skctl install` 产生，不入库 |

## 接口与数据形状（关键契约断言）

- **frontmatter**（触达#1）：恰 `{name, description}`；`name: ui-demo`；description ≤400 码点、首词 `Use when`、含中文场景词 + 三入口名、不含流程概述（SDO）。逐字草案见 code-design.md ③3.1。
- **判定式**：`C1 ∧ C2 ∧ C3 且不命中排除表五行 → 进入演示；否则记未触发`（C1/C2/C3 与排除表语义条款见 code-design.md ③3.3，抄入 skill 第 2 节）。
- **分级**：L1 默认 / L2 含关键交互流或多状态 / L3 视觉方向完全开放且未给偏好（2-3 方向 **tab 切换为主、每方向独占视口宽**，并排缩略仅显式要求时——Q-B 落档裁定）；L2/L3 同中取 L3。
- **路径矩阵**（Q-C 落档裁定后）：spec-plan 1.75 → `/tmp/spec-flow/<change>/demos/<slug>.html` → 落档复制 `openspec/changes/<change>/demos/`；explore/propose 变更目录在则直接写 `demos/`、不在则易失区后迁入；**`/plan` → `/tmp/ui-demos/<change>/<slug>.html` 即确认即弃不入库**。
- **HTML 契约**（7 条）：单文件自包含零外部请求；禁 base64 大图（>20KB 用 CSS/SVG）；≤100 000 字节；viewport 且双断点不横滚；顶部演示约束条（变更名·分档·时间·「界面演示，非最终实现」）；假状态 ≤50 行内联 JS 或纯 CSS；语义标签 + 对比度 ≥4.5:1；**假数据强制标注「示意数据」（Q-E）**。
- **预览双路径**：容器自检 `file:///tmp/...`；宿主打开 `file:///data/tmp/...`；落档后三端同路径；nginx 统一入口仅留扩展位一句。
- **自检序列**：new_page(file://) → take_screenshot(fullPage) → list_console_messages（零 error、无 Failed to load resource）→ close_page；默认 + 390px 窄屏各一次；多 tab/状态逐一切换各验；MCP 不可用降级如实标注（体例照 `smoke-testing-local-env/SKILL.md:30-34`）。
- **手册接线**：spec-plan SKILL.md 净增 ≈+356（→≤7800 断言）；planning.md 净增 ≈+1250（→≤7800）；spec-workflow 净增 ≈+74（→≤6600）。逐字草案 = code-design.md ③3.7-A~E / ③3.8-A~D / ③3.9-A~B，**执行侧照抄不改写**。
- **delta 形状**：3 文件 / 7 requirement 块（ADDED 5+1、MODIFIED 2）；MODIFIED 整块携带 spec-plan 主规格 9 scenario（+1 新增「落档复制界面演示产物」）与 spec-workflow 3 scenario（+1 新增「阶段 1.75 条件触发」）。

## 决策记录（D1–D11 摘要；全文含被否方案与反例见 code-design.md ④）

| # | 决策（一句） | 关键被否 |
| --- | --- | --- |
| D1 | 1.75 在 1.7 后、落档前 | 执行期才发现（返工保留）/1.5 后（方案未收敛演示白做）/与 1.7 并行（子代理不能直问用户） |
| D2 | 判定/分级/产物/自检单源 ui-demo，触点只引用 | 三源漂移；仓内惯例「唯一权威源」 |
| D3 | 软接线只靠 description 触发词（无 whenToUse/AGENTS 行/改生成 skill） | whenToUse 零触发贡献（tool-skill:244 实证）；生成 skill 升级覆盖 |
| D4 | 1.75 主会话 inline、不派子代理、不加路由键 | 演示确认是逐轮看图对话，中转成本 > 自写 |
| D5 | 产物先落易失区、落档整目录复制 | 直接写变更目录（openspec 边界）/直接 docs/（与 Q3 冲突） |
| D6 | 预览宿主 file:// 直开 + 双路径映射；nginx 仅扩展位 | 只写容器路径（宿主必然打不开，findmnt 硬证据） |
| D7 | 1.75 为 §六 `###` 子节（落档裁定知会通过） | 顶级节顺移致 6 文件 13 处指针重编号 |
| D8 | 入口保 skeleton、细则下沉 refs | 判定表进 spec-plan（破码点线）；ui-demo 单文件堆参考（spring-writer 14964 反例） |
| D9 | 单文件 ≤100KB、零外链、禁 base64 大图 | git 历史永久膨胀；file:// 断网花屏 |
| D10 | 未命中也留一行未触发事实 | 静默缺口：无法区分「判过未触发」与「没人判」 |
| D11 | spec-workflow 只改流水线与状态载体；:55/:66 不动 | demos/ 是只读参考物非进度载体，接进恢复路径造假阻塞 |

**栈识别结论（阶段 1.7 硬契约）**：writer skill = **`writing-skills`**（用户三选一裁定；证据：聚合层 `~/.agents/skills/writing-skills/` 实存可加载，其 Iron Law（RED 前置）/SDO（description 只写触发条件）/Match-the-Form/按消费时机外移为本次 skill 写作的硬约束）。
**阶段 1.75 判定行（本变更自身）**：**未触发**——C1 不成立（本变更是流程/skill 工程，无界面产出）；无 demos/ 目录，落档不含演示产物。
**落档裁定**（分歧点提问已答）：Q-A RED 本期做（5 组）；Q-B L3 = tab 主 + 并排可选；Q-C /plan 场景走 /tmp 即确认即弃；Q-D 摘要不强制演示字段；Q-E 示意数据强制标注；1.75 子节形态知会无异议。

## 逐任务组实现要点（与 tasks.md 一一对应；命令级细节见 code-design.md ⑤）

- **组 1 素材与 RED 基线**：materials.md 只读提炼三样素材；RED 压测 = 未加载 skill 的子代理喂真实需求句式，记录合理化借口（零失败则上浮）；演练零落库断言限定路径。
- **组 2 skill 撰写（GREEN）**：SKILL.md 按 ③3.1-3.6 逐字实现；html-recipe.md 骨架 + 三档模板 + 自检命令卡；断言脚本见 code-design.md ⑤附。
- **组 3 手册接线**：三文件逐字照抄 ③3.7/3.8/3.9，节数不变（`grep -c '^## '` = 9）、§七/§八/§九 原样、码点 ≤ 各断言线。
- **组 4 工件校验与登记**：一次性断言脚本核 delta 形状约束（ADDED ≤500 / MODIFIED ⊇ 既有 scenario / WHEN+THEN / SHALL / Purpose ≥50）；`validate --strict` 退出码 0 无 WARNING；README 补行 + `skctl install` 机器态。
- **组 5 验证**：发现与加载（目录含 ui-demo、正文无裁剪）；触发路由三句（命中/不命中/命中）各附子代理回执，摇摆加测 5 轮；行为演练至 1.75 全链（需用户在场）。

## 设计假设与未决项

假设（不成立回到设计）：①聚合层软链零改造生效（否则手动 ln -s 留痕）；②chrome-shared Chromium 在容器内（否则自检 URL 改 /data/tmp 形态——唯一可反转 D6 的平台变化）；③宿主浏览器允许 file://；④`demos/` 不被 validate 结构校验拦（`--archived` 14 passed 实证）；⑤`.gitignore` 不屏蔽 html/demos（实测）；⑥体积纪律真实需求可满足；⑦parallelism=3；⑧3 个无关脏改动限定路径断言。

未决/后续：软接线强度为已知情接受的残余风险（D3 补强上限 = description 覆盖度）；nginx 统一入口、`/ui-demo` 命令薄壳、AGENTS.md 转接行、`demo` 路由键均留待未来独立变更（Q1/Q3/Q5 裁定）。

## Risks / Trade-offs

- **软接线漏判**（explore/plan 场景）：无强制机制，靠触发词覆盖度；缓解 = description 场景词密度 + skill 正文判定表前置。spec-workflow 场景不受此风险影响（硬 gate）。
- **码点预算紧**：spec-plan SKILL.md 7694/7800 断言线，后续任何增改须先置换；html-recipe ≤7000。
- **L3 单文件体积**：3 方向 × L2 深度可能逼近 100KB 上限——超限时拆 `-l1/-l2` 多文件（skill 已写拆分命名）。
- **RED 基线零失败**：若子代理自发画演示，判定表价值存疑——上浮待决不硬写。
