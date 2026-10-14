# Tasks

## 1. 生成新 references 文件（纯剪切外移）

- [x] 1.1 新建 `agent/skills/spec-workflow/convergence.md`：把 SKILL.md §五第 4 步「按 `grill-me` 方法问决策项」的方法展开条目（当前 149–156 行，自 `- **映射为设计树**` 至 `- **不因此改变的部分**` 整块）**逐字剪切**搬入，文首加一行「本文件为 SKILL.md §五第 4 步的外移正文，回入口引用写『SKILL.md 第 X 节』」；本任务不改 SKILL.md；验证：`python3 -c "s=open('agent/skills/spec-workflow/convergence.md',encoding='utf-8').read(); assert s.strip() and len(s)<=8192; print(len(s))"` 退出码 0，且 `sed -n '149,156p' agent/skills/spec-workflow/SKILL.md | diff - <(tail -n +3 agent/skills/spec-workflow/convergence.md)` 无输出（逐字一致）
- [x] 1.2 新建 `agent/skills/spec-workflow/execution.md`：把 SKILL.md §八两个引擎小节（当前 210–227 行，自 `**subagent 引擎（默认）**：` 至 team 引擎最后一条 `- 该引擎**忽略 \`apply\` 路由键…`）**逐字剪切**搬入，文首加同样一行来源说明；本任务不改 SKILL.md；验证：`python3 -c "s=open('agent/skills/spec-workflow/execution.md',encoding='utf-8').read(); assert s.strip() and len(s)<=8192; print(len(s))"` 退出码 0，且 `sed -n '210,227p' agent/skills/spec-workflow/SKILL.md | diff - <(tail -n +3 agent/skills/spec-workflow/execution.md)` 无输出

## 2. 入口骨架化与外部引用同步

- [x] 2.1 改写 `agent/skills/spec-workflow/SKILL.md` 为**完全骨架化期望成品**（Lead 起草，实测 7812 码点、渲染后 8155 ≤ 8192 免裁）：内容 = `/tmp/spec-flow/spec-workflow-slim-entry/expected-SKILL.md`，md5 **`613e3a9c27bfe54c20930930c559440a`**（成员按脚本 `assert` 改前基线 md5 + 期望成品 md5 后落盘，**禁止手改**）；手段 = 去重 + 按消费时机外移（§二/§五/§六/§八 判据 → references，见 2.3）+ 协议骨架化 + 句式收紧；红线：12 节编号与标题逐字节不变、frontmatter 逐字节不变、红线内联最小集（恢复速查 / 绝不做 / §十二红线表 / §七六步恢复协议 / §四①–⑤+两条禁令 / 独立性铁律 / 参数面合并表 / 按需读取路由表）9 项全在；验证：`md5sum agent/skills/spec-workflow/SKILL.md` = `613e3a9c27bfe54c20930930c559440a`；`python3 -c "s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read(); assert 6800<=len(s)<=7830, len(s); assert len(s)+343<=8192; print(len(s), len(s)+343)"` 退出码 0；`grep -c '^## ' agent/skills/spec-workflow/SKILL.md` = 12；`git diff agent/skills/spec-workflow/SKILL.md | grep -E '^[+-](name|description):'` 无输出
- [x] 2.2 同步 `dsh/README.md`：路径表补 `execution.md`、`convergence.md` 两个 references 条目（沿用既有条目格式）；验证：`grep -c 'spec-workflow/\(routing\|failure-modes\|planning\|execution\|convergence\)\.md' dsh/README.md` = 5，且 `grep -n '第十一节' dsh/README.md` 无命中
- [x] 2.3 增补三个 references 承接 2.1 外移的判据（**追加外移，超出 design D1 原始映射，经用户批准**）：从**改前基线**（`git show HEAD:agent/skills/spec-workflow/SKILL.md`）机械剪切指定行区间并追加——`planning.md` ← §二 前置检查展开（59–62、65–66 行）+ §六 落档细节（164–179 行）+ §十 接续细节（255–261 行）；`convergence.md` ← §五 六步判据（137–160 行）；`execution.md` ← §八 三模式与提交纪律/硬停条件（231–242 行）+ §九 验证归档派发要点（246–251 行），每段加一行小标题注明来源节；验证：三文件 `python3 -c "import sys;s=open(p,encoding='utf-8').read();assert len(s)<=8192,len(s);print(p,len(s))"` 均 ≤8192 码点；各追加段与其源行区间 `diff` 无输出（逐字一致）

## 3. 结构化验证与渲染后实测

- [x] 3.1 引用闭合与内容无损核对（只读）：断言 5 个 references 均存在且 ≤8192 码点；对 SKILL.md 与 5 个 references 中每个 `.md` 引用逐一 `test -f`；断言外移内容与**归档基线**（`git show 9048fcf^:agent/skills/spec-workflow/SKILL.md` 的对应区间）逐字 diff 无输出；断言关键词唯一命中所属文件（如 `child LLM route` 仅 routing.md、设计树方法仅 convergence.md、team 引擎细节仅 execution.md）；断言 `第十X节` 旧引用零残留、12 节标题与 frontmatter 与基线逐字节一致；验证：每条断言退出码 0 并逐条记录输出
- [x] 3.2 渲染后实测与码点记录（只读）：会话内按名加载 `spec-workflow` skill，实测 `skill` 工具完整返回的码点数并断言 ≤8192（同时标定包裹开销常量 = 返回码点 − 文件码点）；记录入口与 5 个 references 的码点数字（写入变更执行记录，供后续变更基线）；验证：实测返回 ≤8192 且 6 个码点数字已记录、包裹开销常量已写明

## Workflow follow-up

- 执行本变更期间记录**自举行为观察**：阶段 3 派发前是否按收窄后的路由表读取 `routing.md`、改写任务是否引用 `execution.md` / `convergence.md`——轨迹记入变更执行记录。
- 全部任务完成后走阶段 4：验证门（本变更验证 = 组 3 断言 + 渲染后实测）→ `openspec-archive-change` 归档并同步主规格（新增「入口与资源按单次加载完整交付」Requirement）→ 归档单独提交一次。
- 宿主操作（本流程不代劳）：归档提交后由用户自行 `git push`；无 skctl 重登记需求（bundle 内文件经目录级 symlink 实时可见）。
