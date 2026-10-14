# Tasks

## 1. 生成新 references 文件（纯剪切外移）

- [x] 1.1 新建 `agent/skills/spec-workflow/convergence.md`：把 SKILL.md §五第 4 步「按 `grill-me` 方法问决策项」的方法展开条目（当前 149–156 行，自 `- **映射为设计树**` 至 `- **不因此改变的部分**` 整块）**逐字剪切**搬入，文首加一行「本文件为 SKILL.md §五第 4 步的外移正文，回入口引用写『SKILL.md 第 X 节』」；本任务不改 SKILL.md；验证：`python3 -c "s=open('agent/skills/spec-workflow/convergence.md',encoding='utf-8').read(); assert s.strip() and len(s)<=8192; print(len(s))"` 退出码 0，且 `sed -n '149,156p' agent/skills/spec-workflow/SKILL.md | diff - <(tail -n +3 agent/skills/spec-workflow/convergence.md)` 无输出（逐字一致）
- [x] 1.2 新建 `agent/skills/spec-workflow/execution.md`：把 SKILL.md §八两个引擎小节（当前 210–227 行，自 `**subagent 引擎（默认）**：` 至 team 引擎最后一条 `- 该引擎**忽略 \`apply\` 路由键…`）**逐字剪切**搬入，文首加同样一行来源说明；本任务不改 SKILL.md；验证：`python3 -c "s=open('agent/skills/spec-workflow/execution.md',encoding='utf-8').read(); assert s.strip() and len(s)<=8192; print(len(s))"` 退出码 0，且 `sed -n '210,227p' agent/skills/spec-workflow/SKILL.md | diff - <(tail -n +3 agent/skills/spec-workflow/execution.md)` 无输出

## 2. 入口骨架化与外部引用同步

- [ ] 2.1 改写 `agent/skills/spec-workflow/SKILL.md` 至 [6800, 7830] 码点：designed by Lead 起草的确定性替换（去重四项、外移四处、协议骨架化、句式收紧），成员按脚本执行替换并以 `assert md5` 门校验期望成品（禁止手改）；红线下限：12 节编号与标题逐字节不变、frontmatter 逐字节不变、红线内联最小集（恢复速查 / 绝不做 / §十二红线表 / §七恢复协议 / §四①–⑤+两条禁令 / 独立性铁律 / 参数面合并表 / 按需读取路由表）全部在入口；验证：`md5sum agent/skills/spec-workflow/SKILL.md` 与期望成品一致；`python3 -c "s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read(); assert 6800<=len(s)<=7830, len(s); print(len(s))"` 退出码 0；`grep -c '^## ' agent/skills/spec-workflow/SKILL.md` = 12；`git diff agent/skills/spec-workflow/SKILL.md | grep -E '^[+-](name|description):'` 无输出
- [ ] 2.2 同步 `dsh/README.md`：路径表补 `execution.md`、`convergence.md` 两个 references 条目（沿用既有条目格式）；验证：`grep -c 'spec-workflow/\(routing\|failure-modes\|planning\|execution\|convergence\)\.md' dsh/README.md` = 5，且 `grep -n '第十一节' dsh/README.md` 无命中

## 3. 结构化验证与渲染后实测

- [ ] 3.1 引用闭合与内容无损核对（只读）：断言 5 个 references 均存在且 ≤8192 码点；对 SKILL.md 与 5 个 references 中每个 `.md` 引用逐一 `test -f`；断言外移内容与**归档基线**（`git show 9048fcf^:agent/skills/spec-workflow/SKILL.md` 的对应区间）逐字 diff 无输出；断言关键词唯一命中所属文件（如 `child LLM route` 仅 routing.md、设计树方法仅 convergence.md、team 引擎细节仅 execution.md）；断言 `第十X节` 旧引用零残留、12 节标题与 frontmatter 与基线逐字节一致；验证：每条断言退出码 0 并逐条记录输出
- [ ] 3.2 渲染后实测与码点记录（只读）：会话内按名加载 `spec-workflow` skill，实测 `skill` 工具完整返回的码点数并断言 ≤8192（同时标定包裹开销常量 = 返回码点 − 文件码点）；记录入口与 5 个 references 的码点数字（写入变更执行记录，供后续变更基线）；验证：实测返回 ≤8192 且 6 个码点数字已记录、包裹开销常量已写明

## Workflow follow-up

- 执行本变更期间记录**自举行为观察**：阶段 3 派发前是否按收窄后的路由表读取 `routing.md`、改写任务是否引用 `execution.md` / `convergence.md`——轨迹记入变更执行记录。
- 全部任务完成后走阶段 4：验证门（本变更验证 = 组 3 断言 + 渲染后实测）→ `openspec-archive-change` 归档并同步主规格（新增「入口与资源按单次加载完整交付」Requirement）→ 归档单独提交一次。
- 宿主操作（本流程不代劳）：归档提交后由用户自行 `git push`；无 skctl 重登记需求（bundle 内文件经目录级 symlink 实时可见）。
