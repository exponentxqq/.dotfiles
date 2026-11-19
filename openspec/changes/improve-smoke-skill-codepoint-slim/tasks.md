# Tasks

> 执行纪律：组间严格串行（1→5），组内任务可并行；实现一律**锚点字符串编辑**（禁按行号 sed -i）；每完成一处编辑立即跑 V1/V2 冻结断言；断言基线 pin `BASE=fdddebd91b7f9751bedf3a77d599719308d68a4b`（验证命令全文见 [code-design.md](code-design.md) ⑤验证映射 V1–V15）。
> 同文件多处编辑已合并为单任务（组 1/组 2 内三文件/两文件互斥，满足组内并行契约）；组 4/组 5 为互为前置的 git/openspec 动作，各拆单任务组。

## 1. 码点补全（三文件并行，定稿块见 code-design.md ③3.3/③3.4/③3.2）

- [ ] 1.1 reference.md 码点三处：锚点 `## 4. 浏览器操作配方` 前插入 §3.7 四行检查表（触达面·reference.md 条目①）；`| 边界值 |` 行后插长度边界行（条目②）；`| 23 |` 行后追加 #24/#25（条目③）；验证：`test "$(grep -c '^### 3\.7 多字节字符与码点口径$' agent/skills/smoke-testing-local-env/reference.md)" = 1 && test "$(grep -c '^| 长度边界 ' agent/skills/smoke-testing-local-env/reference.md)" = 1 && test "$(grep -c '^| 24 |' agent/skills/smoke-testing-local-env/reference.md)" = 1 && test "$(grep -c '^| 25 |' agent/skills/smoke-testing-local-env/reference.md)" = 1` 退出码 0，且 V2b（`diff <(git show $BASE:agent/skills/smoke-testing-local-env/reference.md | sed -n '1,174p') <(sed -n '1,174p' agent/skills/smoke-testing-local-env/reference.md)`）为空
- [ ] 1.2 SKILL.md 阶段 4 指路句：锚点 `- 数据带可检索前缀（如 \`冒烟\`），记录全部主键与外部对象 key` 后插 1 条（触达面·SKILL.md 条目①）；验证：`sed -n '/^### 阶段 4　数据准备/,/^### 阶段 5/p' agent/skills/smoke-testing-local-env/SKILL.md | grep -c '^- '` = 6 且 `grep -qF 'reference §3.7' agent/skills/smoke-testing-local-env/SKILL.md`，且 V1a'（`diff <(git show $BASE:agent/skills/smoke-testing-local-env/SKILL.md | sed -n '1,60p') <(sed -n '1,60p' agent/skills/smoke-testing-local-env/SKILL.md)`）为空
- [ ] 1.3 project-profile-template.md §3 字符集行：锚点 `` | 库名 | 例：`opc` | `` 后插 1 行（触达面·模板条目）；验证：`test "$(grep -c '^| 字符集 / 排序规则 ' agent/skills/smoke-testing-local-env/project-profile-template.md)" = 1` 退出码 0，且 `diff <(git show $BASE:agent/skills/smoke-testing-local-env/project-profile-template.md | grep -E '^## [0-9]') <(grep -E '^## [0-9]' agent/skills/smoke-testing-local-env/project-profile-template.md)` 无输出（§0–§9 标题零漂移）

## 2. 保守瘦身（两文件并行，自下而上，定稿块见 code-design.md ③3.2/③3.3）

- [ ] 2.1 reference.md 瘦身：S5 锚点 `## 9. 项目画像字段` 整段替换为 3 行指路（触达面·reference.md 条目④）；S6-a §6.4「入库与忽略」4→2 条 + 清多余空行（条目⑤前半）；S6-b §7.2 三条并两条（条目⑤后半）；验证：`test "$(sed -n '/^## 9\./,$p' agent/skills/smoke-testing-local-env/reference.md | wc -l)" = 3 && test "$(sed -n '/^### 7\.2 /,/^### 7\.3 /p' agent/skills/smoke-testing-local-env/reference.md | grep -c '^- ')" = 2 && test "$(sed -n '/^入库与忽略：/,/^### 6\.5 /p' agent/skills/smoke-testing-local-env/reference.md | grep -c '^- ')" = 2` 退出码 0，且节号断言（V3 的 comm -23）无缺失
- [ ] 2.2 SKILL.md 瘦身（顺序：S4→S3→S2→S1 自下而上）：S4 锚点 `- 冒烟通过 = ` 行尾追加 ` + （单任务）新用例已回写`、删 `- 单任务新增/修订用例未回写` 整行（触达面·SKILL.md 条目⑤）；S3 三层证据表整块并 1 行（条目④）；S2 执行纪律 4→2 条（条目③）；S1 模式表整块替换为 9 行形态（条目②）；验证：`test "$(grep -cF '| 用例库缺失 |' agent/skills/smoke-testing-local-env/SKILL.md)" = 0 && test "$(grep -cF '| 层 | 证据 |' agent/skills/smoke-testing-local-env/SKILL.md)" = 0 && grep -qF '三层证据缺一不可' agent/skills/smoke-testing-local-env/SKILL.md && grep -qF '（单任务）新用例已回写' agent/skills/smoke-testing-local-env/SKILL.md && test "$(grep -cF '未回写不算完成' agent/skills/smoke-testing-local-env/SKILL.md)" = 0 && test "$(grep -n '^## 两种冒烟模式' agent/skills/smoke-testing-local-env/SKILL.md | cut -d: -f1)" = 61` 退出码 0

## 3. 全量断言（只读，可并行，命令全文 = code-design.md V1–V15）

- [ ] 3.1 冻结区与活引用：V1（SKILL L1–60 逐字节 + 60 行 + L30-34 + L61 边界）+ V2（reference L1–18 + L1–174 上扩 + L19 单点），全部 pin `$BASE`；验证：V1a'/V1b/V1c/V1d/V2a'/V2b/V2c 七条 diff/test 均通过（命令照抄 code-design.md ⑤）
- [ ] 3.2 结构与行为零变更：V3（§3.7 恰 1 处、节号集合旧⊆新且新增仅 `### 3.7`）+ V4（§8 数据行 = 25）+ V5（模板）+ V6（SKILL 五处）+ V7/V8（S5/S6）+ V9（脚本 `git diff --quiet $BASE -- agent/skills/smoke-testing-local-env/scripts/` + Top 12 逐字节）+ V10（七列契约/编号续接/4 值域/白名单/话术歧义等关键字全在）+ V11（表格 pipe 与基线比不新增坏行）+ V12（SKILL 每个 §N 引用在 reference/模板有同名标题）；验证：各断言逐条通过且 `wc -l` 记录 SKILL/reference/模板 = 188/583/95（偏差 >2 行须留痕回查）
- [ ] 3.3 validate 与工作区范围：`openspec validate improve-smoke-skill-codepoint-slim --strict` 退出码 0（**不得用 `--all --strict`**，基线已知 spec-plan 长文本警告致 exit 1）+ V15（`git status --short` 除 `dsh/profiles/web/`、本 skill 目录、本变更目录、specs 目录、archive 外无越界输出）；验证：两命令退出码 0

## 4. 实现提交（单任务组，依赖组 3 全绿）

- [ ] 4.1 提交三文档 + tasks.md 勾选与执行留痕：`git add agent/skills/smoke-testing-local-env openspec/changes/improve-smoke-skill-codepoint-slim/tasks.md && git commit -m "feat(skills): 冒烟 skill 补齐码点口径并保守去重"`；验证：`git show --stat HEAD | head -8` 显示 4 文件（SKILL/reference/template/tasks），`git status --short` 无本变更相关未提交项

## 5. 归档（单任务组，依赖组 4）

- [ ] 5.1 归档与归档提交：核对 delta 与最终文档一致、tasks 无 `- [ ]` → `openspec archive improve-smoke-skill-codepoint-slim --yes`（自动 sync 主规格第 8 条 + 日期前缀移动）→ V14 断言（`grep -c '^### Requirement:' openspec/specs/smoke-testing-local-env/spec.md` = 8、`grep -c '^#### Scenario:'` = 14、`git diff --numstat $BASE -- openspec/specs/smoke-testing-local-env/spec.md` 删除列 = 0、archive 目录在且活跃目录已移走）→ `git add -A openspec && git commit -m "docs(openspec): 归档 improve-smoke-skill-codepoint-slim"`；验证：`openspec validate smoke-testing-local-env --type spec --strict` 退出码 0 且 V14 各断言通过、`git log --oneline -2` 含归档提交

---

## 附录：执行留痕区（执行侧填写，勿删除）

- R<n> 留痕：执行中发现的偏差、验证句自误与重跑、行数对账，逐条记录于此
- 沉淀回流：执行结束后把「验证句改进/断言口径细化」按 code-design.md 既有格式追加
