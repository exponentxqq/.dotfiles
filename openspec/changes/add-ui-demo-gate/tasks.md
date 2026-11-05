# Tasks

## 1. 素材提炼与 RED 基线压测

- [x] 1.1 提炼写作素材清单（只读，触达#1/#2/#4 的素材源）：产出 `/tmp/spec-flow/add-ui-demo-gate/materials.md`，含①降级表体例与容器内浏览器事实（`agent/skills/smoke-testing-local-env/SKILL.md:30-34`、`reference.md:19`）②planning.md「附节体例」（`:16-52`）③L1/L2/L3 元素词表；验证：`test -f /tmp/spec-flow/add-ui-demo-gate/materials.md` 退出码 0，且清单内引用的每个仓库路径逐一 `test -e` 通过
- [x] 1.2 RED 基线压测（writing-skills Iron Law，触达#1 前置）：派**未加载 ui-demo** 的子代理，喂「给用户列表页加一个筛选面板，我没设计稿，你看着办」，逐字记录其行为（是否直接写实现/跳过演示确认）与合理化借口；零失败（自发画演示）则上浮待决不硬写判定表；验证：`test -f /tmp/spec-flow/add-ui-demo-gate/red-baseline.md` 且 `grep -c '^> ' /tmp/spec-flow/add-ui-demo-gate/red-baseline.md` ≥1，且演练零落库 `git -C /home/xuqinqin/develop/dotfiles status --short -- openspec agent` 输出为空

## 2. ui-demo skill 撰写（GREEN）

- [x] 2.1 写 `agent/skills/ui-demo/SKILL.md`（触达#1）：frontmatter 恰 `{name, description}`（description ≤400 码点、`Use when` 开头、含中文场景词与三入口名、不含流程概述）+ 8 节正文（判定表置于前 2000 码点内；三处入口接线表进第 6 节；L3 为 tab 主 + 并排可选；/plan 场景 `/tmp/ui-demos/` 即确认即弃）；验证：code-design.md ⑤附断言脚本退出码 0（键集、name、desc 长度与首词、全文 ≤6000、`C1` 位置 <2000）
- [x] 2.2 写 `agent/skills/ui-demo/refs/html-recipe.md`（触达#2）：自包含 HTML 骨架（`<style>` 变量、演示约束条、L1/L2/L3 三套 section 模板、示意数据标注位）+ 零外链清单 + 窄屏适配片段 + 自检四步命令卡；验证：`grep -c 'src="http\|href="http\|@import' agent/skills/ui-demo/refs/html-recipe.md` 输出 0，且 `python3 -c "print(len(open('agent/skills/ui-demo/refs/html-recipe.md',encoding='utf-8').read()))"` ≤7000

## 3. 手册接线（逐字照抄 code-design.md ③3.7/3.8/3.9）

- [x] 3.1 改 `agent/skills/spec-plan/SKILL.md`（触达#3）：仅四处——流水线三行整块替换（③3.7-A）、§六标题（3.7-B）、`### 阶段 1.75 界面演示 gate` 子节（3.7-C）、消费时机行（3.7-D）；验证：`grep -n '阶段1.75 界面演示（条件）' agent/skills/spec-plan/SKILL.md` 命中 1 行、`grep -c '^## ' agent/skills/spec-plan/SKILL.md` 输出 9、`grep -nE '^## (七|八|九)、' agent/skills/spec-plan/SKILL.md` 三行原样命中、全文码点 ≤7800
- [x] 3.2 改 `agent/skills/spec-plan/refs/planning.md`（触达#4）：四处——文件头（③3.8-A）、`## 附：阶段 1.75 界面演示 gate` 插入两附节之间（3.8-B，含判定留痕/双路径/确认问法三选一/落档接线）、复制句（3.8-C）、条件断言（3.8-D）；验证：`grep -n '^## 附：阶段 1.75 界面演示 gate' agent/skills/spec-plan/refs/planning.md` 命中、`grep -c 'demos/' agent/skills/spec-plan/refs/planning.md` ≥3、`grep -n 'test -d openspec/changes/<change>/demos' agent/skills/spec-plan/refs/planning.md` 命中、全文码点 ≤7800
- [x] 3.3 改 `agent/skills/spec-workflow/SKILL.md`（触达#5）：仅两处——流水线两行（③3.9-A）、状态载体段末句（3.9-B）；`:55`/`:66` 不动；验证：`grep -n '阶段1.75 界面演示（条件）' agent/skills/spec-workflow/SKILL.md` 命中 1 行、`grep -c '界面演示产物' agent/skills/spec-workflow/SKILL.md` 输出 1、全文码点 ≤6600、`git diff --stat agent/skills/spec-workflow/SKILL.md` 恰一个文件且改动块为 2 处

## 4. openspec 工件校验与 skill 登记

- [x] 4.1 delta 形状断言（触达#8/#9/#10）：写 `/tmp/spec-flow/add-ui-demo-gate/assert-delta.py` 并运行——逐文件断言 ADDED requirement 正文 ≤500 字符、MODIFIED 的 scenario 名集合 ⊇ 主规格同名 requirement（`落档工件与执行批次契约` ⊇9、`固定工作流入口` ⊇3）、每 scenario 含 WHEN 与 THEN、每 requirement 含 SHALL 或 MUST、新能力 delta 含 `## Purpose` ≥50 字符；验证：`python3 /tmp/spec-flow/add-ui-demo-gate/assert-delta.py` 退出码 0
- [x] 4.2 严格校验（触达#7-#11）：在 dotfiles 根跑 `openspec validate add-ui-demo-gate --strict`；验证：退出码 0 且输出无 WARNING（不得以 `--all --strict` 替代——主规格 2 条既存超长告警必红）
- [x] 4.3 README 登记与机器态（触达#6/#16）：`agent/skills/README.md` :35 后补 `| ui-demo | 自写（本目录 local symlink） |` 行；宿主执行 `SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts; node $SKCTL install ~/develop/dotfiles/agent/skills/ui-demo`；验证：`grep -c 'ui-demo' agent/skills/README.md` 输出 1、`readlink ~/.local/share/agent-skills/skills/ui-demo` 输出实体目录、`node $SKCTL list --all --desc | grep ui-demo` 命中 enabled/local、`ls -d /home/docker/.agents/skills/ui-demo` 存在

## 5. 验证（发现 / 触发 / 行为演练）

- [x] 5.1 发现与加载（口径按 R5 勘误：聚合层 symlink 存在 + 按名加载完整 + 可经磁盘枚举发现）：新开会话（或本会话重扫）后目录含 `ui-demo` 条目且 `skill ui-demo` 返回完整正文；验证：目录消息含 `ui-demo` 一行、加载正文首部含 `# 界面演示` 且尾部含 `## 按需读取`（无 `[... pruned ...]` 裁剪标记）
- [x] 5.2 触发路由三句（软接线唯一可测面）：①「给订单列表页加个筛选面板，我没设计稿」→ 命中；②「给后端加一个导出接口」→ 不命中；③「走 /plan 规划一个新的仪表盘页面，没有 UI 图」→ 命中；各附 1 份子代理回执（结论 + 引用的 description 命中词）；验证：三条回执记录落 `/tmp/spec-flow/add-ui-demo-gate/trigger-routes.md` 且结论与预期一致，任一摇摆加测 5 轮微测并记录
- [ ] 5.3 行为演练至 1.75（需用户在场）：在本仓对一个小界面需求跑 spec-plan 至 1.75，核对加载 ui-demo、产出 `demos/<slug>.html`、chrome-shared 自检执行、三选一确认问法出现、`code-design.md` 有「阶段 1.75」附录、未确认前未落档；验证：该演练变更 `/tmp/spec-flow/<演练change>/demos/` 非空且 `code-design.md` 含 `## 附：阶段 1.75 界面演示`，演练产物与回执零落库（`git status --short -- openspec agent` 干净或仅含预期演示入库文件）

## 附录：执行期运行规则留痕（R<n>）

- **R1 路径域断言口径**（2026-11-05 组 1 实证）：形如 `git status --short -- openspec agent` 的「零落库」断言，允许且仅允许出现 `openspec/changes/add-ui-demo-gate/` 内的工件改动（衔接执行环境块、tasks.md 勾选、组段工件维护——均为 spec-apply/spec-workflow 明文职责，随批次提交入库）；该路径域内任何**其他**条目 = 演练/实现污染，判失败。依据：execution.md「勾选与工件维护为组收尾必做」+ worktree.md「执行环境块随衔接写入」，与「零落库全空」字面无法同时成立。连锁面：tasks.md 1.2 / 5.3 同类断言按本口径解释；组 5 演练断言同口径。
- **R2 验证句口径以逐字稿为锚**（2026-11-05 组 3 实证）：tasks.md 验证句的 grep pattern 与 code-design 逐字稿冲突时（3.1 `阶段 1.75` 带空格 vs 逐字稿无空格），以逐字稿为准、修正 tasks.md 验证句，不扭曲实现；裁定依据=逐字稿是唯一权威源 + 码点数学闭合 + 同文档风格旁证 + 已通过的同款句（3.3）。连锁面：后续组验证若再现 pattern 冲突，同口径处理并在组段终形态留痕。
- **R3 skctl 写操作环境**（2026-11-05 组 4 实证）：dsh 容器内**无法执行 skctl 写操作**——宿主 `~/.local/share/agent-skills` 未挂载进 dsh（容器内 `/home/xuqinqin/.local/share` 为 root 属主 stub），直跑 install 报 `EACCES ... mkdir`；写操作须经 **node 容器**（`${HOST_HOME}:${HOST_HOME}` identity 挂载、uid 1000）或宿主执行；dsh 内 `skctl list` 对缺失 store **静默空表（exit 0）不报错**，不得据此判定未安装。聚合层 `skills/` 子目录以 ro 挂到 dsh `/home/docker/.agents/skills`，宿主写入**实时可见**（无需重启）。连锁面：组 5.1 发现验证、未来变更的登记任务、spec-done 收尾复验同口径。
- **R4 delta 正文口径**（2026-11-05 组 4 实证）：「ADDED requirement 正文 ≤500 字符」按 **openspec 1.16.0 `extractRequirementBody`（陈述段，不含 `#### Scenario:` 块）**量取——与 `validate --strict` 权威实现一致（`validator.js:272` + `constants.js:9`）；MODIFIED 不受 500 限制（源码注释：its text is the existing requirement）；主规格 2 条既存超长（518/502）只影响 `--all --strict`。连锁面：`assert-delta.py` 口径、未来 delta 撰写与断言、spec-done 归档前校验。
- **R5 skills 目录信封不下发（部署级事实）**（2026-11-05 组 5 实证）：当前 profile/部署下 `<available_skills>` 目录信封**对全部 26 个 skill 均不下发**（25-skill 时代即如此，父会话 984 条记录 0 特征串命中）——非本变更引入。**实际发现通道 = 子代理自发磁盘枚举** `~/.agents/skills/*/SKILL.md` 的 description 逐条比对（5.2②③ 实证有效）；按名加载完整无损。tasks.md 5.1 验证句「目录消息含 ui-demo 一行」按 R2 口径勘误为可测三项（symlink 存在 / 加载完整 / 枚举可发现），全过。子代理机制假设待排查：tool-skill pre-step 在 skill 工具被包裹或 snapshot 不完整时静默跳过（lib/index.js:931-941）或渲染裁剪线；修复涉及 dsh 行为，属本变更 scope 外（已上报用户）。连带实操注记：共享浏览器被占用时 `resize_page` 可能不改变 innerWidth，窄屏自检可用 `emulate` viewport 替代（5.2① 实证）。连锁面：5.3 演练、ui-demo 软接线的实际命中通道、未来 skill 类变更的发现/加载验证同口径。

## 附录：沉淀回流清单（执行期改动的工作流仓文件；spec-done 六要素汇报从本清单读）

**已提交去向（随本批次提交入库，dotfiles 根仓）**：

| 文件 | 动作 | 内容 |
| --- | --- | --- |
| `agent/skills/ui-demo/SKILL.md` | 新建 | 判定/分级/产物/自检唯一权威源（123 行 / 5397 码点） |
| `agent/skills/ui-demo/refs/html-recipe.md` | 新建 | 重参考：骨架 + 三档模板 + 元素表 + 自检卡（179 行 / 6998 码点） |
| `agent/skills/spec-plan/SKILL.md` | 修改 | 四处（③3.7-A/B/C/D）：7338→7687 码点 |
| `agent/skills/spec-plan/refs/planning.md` | 修改 | 四处（③3.8-A/B/C/D）：6111→7372 码点 |
| `agent/skills/spec-workflow/SKILL.md` | 修改 | 两处（③3.9-A/B）：6314→6388 码点；:55/:66 内容未动 |
| `agent/skills/README.md` | 修改 | :36 后补 ui-demo 一行 |
| `openspec/changes/add-ui-demo-gate/{design,code-design,tasks}.md` | 修改 | 执行环境块、组段终形态化（组 1–5）、R1–R5 留痕、勾选态 12/13 |

**机器态（不入库；实例级）**：skctl registry 新增 `ui-demo`（local 源）+ 宿主聚合层 symlink `~/.local/share/agent-skills/skills/ui-demo`（dsh 内只读视图 `/home/docker/.agents/skills/ui-demo` 实时可见）。

**易失（/tmp，不入库不提交）**：`/tmp/spec-flow/add-ui-demo-gate/` 下 materials.md、red-baseline.md、trigger-routes.md、discovery.md、assert-delta.py、progress.md、red-sandbox/、sandbox-order/、sandbox-backend/、sandbox-empty/。

**未决移交**：任务 5.3 行为演练——用户裁定新开会话真实场景演练（见 code-design.md ⑤ 组 5 终形态）；归档链（spec-done）待 5.3 完成后发起。
