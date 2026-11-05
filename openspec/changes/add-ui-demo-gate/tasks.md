# Tasks

## 1. 素材提炼与 RED 基线压测

- [ ] 1.1 提炼写作素材清单（只读，触达#1/#2/#4 的素材源）：产出 `/tmp/spec-flow/add-ui-demo-gate/materials.md`，含①降级表体例与容器内浏览器事实（`agent/skills/smoke-testing-local-env/SKILL.md:30-34`、`reference.md:19`）②planning.md「附节体例」（`:16-52`）③L1/L2/L3 元素词表；验证：`test -f /tmp/spec-flow/add-ui-demo-gate/materials.md` 退出码 0，且清单内引用的每个仓库路径逐一 `test -e` 通过
- [ ] 1.2 RED 基线压测（writing-skills Iron Law，触达#1 前置）：派**未加载 ui-demo** 的子代理，喂「给用户列表页加一个筛选面板，我没设计稿，你看着办」，逐字记录其行为（是否直接写实现/跳过演示确认）与合理化借口；零失败（自发画演示）则上浮待决不硬写判定表；验证：`test -f /tmp/spec-flow/add-ui-demo-gate/red-baseline.md` 且 `grep -c '^> ' /tmp/spec-flow/add-ui-demo-gate/red-baseline.md` ≥1，且演练零落库 `git -C /home/xuqinqin/develop/dotfiles status --short -- openspec agent` 输出为空

## 2. ui-demo skill 撰写（GREEN）

- [ ] 2.1 写 `agent/skills/ui-demo/SKILL.md`（触达#1）：frontmatter 恰 `{name, description}`（description ≤400 码点、`Use when` 开头、含中文场景词与三入口名、不含流程概述）+ 8 节正文（判定表置于前 2000 码点内；三处入口接线表进第 6 节；L3 为 tab 主 + 并排可选；/plan 场景 `/tmp/ui-demos/` 即确认即弃）；验证：code-design.md ⑤附断言脚本退出码 0（键集、name、desc 长度与首词、全文 ≤6000、`C1` 位置 <2000）
- [ ] 2.2 写 `agent/skills/ui-demo/refs/html-recipe.md`（触达#2）：自包含 HTML 骨架（`<style>` 变量、演示约束条、L1/L2/L3 三套 section 模板、示意数据标注位）+ 零外链清单 + 窄屏适配片段 + 自检四步命令卡；验证：`grep -c 'src="http\|href="http\|@import' agent/skills/ui-demo/refs/html-recipe.md` 输出 0，且 `python3 -c "print(len(open('agent/skills/ui-demo/refs/html-recipe.md',encoding='utf-8').read()))"` ≤7000

## 3. 手册接线（逐字照抄 code-design.md ③3.7/3.8/3.9）

- [ ] 3.1 改 `agent/skills/spec-plan/SKILL.md`（触达#3）：仅四处——流水线三行整块替换（③3.7-A）、§六标题（3.7-B）、`### 阶段 1.75 界面演示 gate` 子节（3.7-C）、消费时机行（3.7-D）；验证：`grep -n '阶段 1.75 界面演示（条件）' agent/skills/spec-plan/SKILL.md` 命中 1 行、`grep -c '^## ' agent/skills/spec-plan/SKILL.md` 输出 9、`grep -nE '^## (七|八|九)、' agent/skills/spec-plan/SKILL.md` 三行原样命中、全文码点 ≤7800
- [ ] 3.2 改 `agent/skills/spec-plan/refs/planning.md`（触达#4）：四处——文件头（③3.8-A）、`## 附：阶段 1.75 界面演示 gate` 插入两附节之间（3.8-B，含判定留痕/双路径/确认问法三选一/落档接线）、复制句（3.8-C）、条件断言（3.8-D）；验证：`grep -n '^## 附：阶段 1.75 界面演示 gate' agent/skills/spec-plan/refs/planning.md` 命中、`grep -c 'demos/' agent/skills/spec-plan/refs/planning.md` ≥3、`grep -n 'test -d openspec/changes/<change>/demos' agent/skills/spec-plan/refs/planning.md` 命中、全文码点 ≤7800
- [ ] 3.3 改 `agent/skills/spec-workflow/SKILL.md`（触达#5）：仅两处——流水线两行（③3.9-A）、状态载体段末句（3.9-B）；`:55`/`:66` 不动；验证：`grep -n '阶段1.75 界面演示（条件）' agent/skills/spec-workflow/SKILL.md` 命中 1 行、`grep -c '界面演示产物' agent/skills/spec-workflow/SKILL.md` 输出 1、全文码点 ≤6600、`git diff --stat agent/skills/spec-workflow/SKILL.md` 恰一个文件且改动块为 2 处

## 4. openspec 工件校验与 skill 登记

- [ ] 4.1 delta 形状断言（触达#8/#9/#10）：写 `/tmp/spec-flow/add-ui-demo-gate/assert-delta.py` 并运行——逐文件断言 ADDED requirement 正文 ≤500 字符、MODIFIED 的 scenario 名集合 ⊇ 主规格同名 requirement（`落档工件与执行批次契约` ⊇9、`固定工作流入口` ⊇3）、每 scenario 含 WHEN 与 THEN、每 requirement 含 SHALL 或 MUST、新能力 delta 含 `## Purpose` ≥50 字符；验证：`python3 /tmp/spec-flow/add-ui-demo-gate/assert-delta.py` 退出码 0
- [ ] 4.2 严格校验（触达#7-#11）：在 dotfiles 根跑 `openspec validate add-ui-demo-gate --strict`；验证：退出码 0 且输出无 WARNING（不得以 `--all --strict` 替代——主规格 2 条既存超长告警必红）
- [ ] 4.3 README 登记与机器态（触达#6/#16）：`agent/skills/README.md` :35 后补 `| ui-demo | 自写（本目录 local symlink） |` 行；宿主执行 `SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts; node $SKCTL install ~/develop/dotfiles/agent/skills/ui-demo`；验证：`grep -c 'ui-demo' agent/skills/README.md` 输出 1、`readlink ~/.local/share/agent-skills/skills/ui-demo` 输出实体目录、`node $SKCTL list --all --desc | grep ui-demo` 命中 enabled/local、`ls -d /home/docker/.agents/skills/ui-demo` 存在

## 5. 验证（发现 / 触发 / 行为演练）

- [ ] 5.1 发现与加载：新开会话（或本会话重扫）后目录含 `ui-demo` 条目且 `skill ui-demo` 返回完整正文；验证：目录消息含 `ui-demo` 一行、加载正文首部含 `# 界面演示` 且尾部含 `## 按需读取`（无 `[... pruned ...]` 裁剪标记）
- [ ] 5.2 触发路由三句（软接线唯一可测面）：①「给订单列表页加个筛选面板，我没设计稿」→ 命中；②「给后端加一个导出接口」→ 不命中；③「走 /plan 规划一个新的仪表盘页面，没有 UI 图」→ 命中；各附 1 份子代理回执（结论 + 引用的 description 命中词）；验证：三条回执记录落 `/tmp/spec-flow/add-ui-demo-gate/trigger-routes.md` 且结论与预期一致，任一摇摆加测 5 轮微测并记录
- [ ] 5.3 行为演练至 1.75（需用户在场）：在本仓对一个小界面需求跑 spec-plan 至 1.75，核对加载 ui-demo、产出 `demos/<slug>.html`、chrome-shared 自检执行、三选一确认问法出现、`code-design.md` 有「阶段 1.75」附录、未确认前未落档；验证：该演练变更 `/tmp/spec-flow/<演练change>/demos/` 非空且 `code-design.md` 含 `## 附：阶段 1.75 界面演示`，演练产物与回执零落库（`git status --short -- openspec agent` 干净或仅含预期演示入库文件）
