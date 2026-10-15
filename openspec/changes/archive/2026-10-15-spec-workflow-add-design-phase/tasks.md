# Tasks

> 触达面编号（T1–T9）见 design.md「触达面清单」；组间串行、组内并行（≤3）；每任务验证句第三方可核对。

## 1. skill 资源文件展开

- [x] 1.1 planning.md 新增「附：代码设计环节（阶段 1.7）」节——含派发模板（首行写死与双线分界：双线=需求级轻重与风险、设计线=代码级蓝图）、深度契约（内容六字段：触达面清单/file:line 证据锚/接口与数据形状/决策记录附被否反例/逐任务组实现要点/设计假设与未决项；行为二约束：验证映射落具体命令或断言、不推翻收敛结论矛盾一律上浮）、回执核对清单（存在非空→字段齐备→逐路径点名→覆盖全部任务组→待决项上浮，失败重派一次）、上浮接线句（并入落档分歧点提问）、三档分降（L2 全深度；L1 触达面 ≤2 文件且无新接口→③④⑤与验证映射单行简述、①⑥与二约束恒成立；L0 单文件+无接口变更+无逻辑分支变化→豁免 fresh 派遣、主会话 inline 一行断言落档）——并在「落档细节」节增补：落档输入加第 5 材料 code-design.md、design 深度契约逐断言核对、tasks 每任务引用触达面条目编号（触达面 T2）；验证：`python3 -c "s=open('agent/skills/spec-workflow/planning.md',encoding='utf-8').read(); assert len(s)<=8192; assert s.count('阶段 1.7')>=2; assert '触达面' in s and 'file:line' in s and 'L0' in s"` 退出码 0
- [x] 1.2 execution.md 任务提示模板契约化：第 6 行「相关 spec/design 摘录」升格为「design.md 中该任务所属组的实现要点逐字引用」+ 写范围含其触达文件（触达面 T3）；验证：`python3 -c "s=open('agent/skills/spec-workflow/execution.md',encoding='utf-8').read(); assert len(s)<=8192; assert '逐字引用' in s; assert '相关 spec/design 摘录' not in s"` 退出码 0
- [x] 1.3 failure-modes.md 在「某条规划线失败」处置行并入设计线同构处置一句（缺失/字段残缺/答非所问→重派一次→仍失败如实报告由用户裁决）（触达面 T5）；验证：`python3 -c "s=open('agent/skills/spec-workflow/failure-modes.md',encoding='utf-8').read(); assert len(s)<=8192" ` 退出码 0 且 `grep -c '设计线' agent/skills/spec-workflow/failure-modes.md` ≥1

## 2. 入口与配置

- [x] 2.1 SKILL.md 净零改写：§一流水线图插入 1.7 代码设计、§五与§六之间加骨架句（指向 planning.md 新节）、§六落档输入清单加 code-design.md、§十接续澄清一句（规划含设计线）、§十一路由键枚举加 design；同步等量收紧（§四串行模式细节外移至 planning.md 既有节、§一句式收紧；二者不足时按 D5 Risks 回退「§六落档细节追加外移」，用户已确认），净增 ≤0（触达面 T1）；验证：`python3 -c "s=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read(); assert 6800<=len(s)<=7830; assert '1.7' in s and 'design' in s; import re; assert len(re.findall(r'^## ',s,re.M))==12"` 退出码 0 且 `test -z "$(git diff agent/skills/spec-workflow/SKILL.md | grep '^[-+]name:\|^[-+]description:')"` 退出码 0（frontmatter 逐字节不变）
- [x] 2.2 dsh/spec-workflow.yaml 增 `design: { provider: zai, model: glm-5.3 }` 键（含注释：设计线阶段路由）+ routing.md 键表加 design 行（应用点：阶段 1.7 代码设计子代理）与注释节同步（触达面 T4/T6）；验证：`python3 -c "import yaml; d=yaml.safe_load(open('dsh/spec-workflow.yaml')); assert d['models']['design']=={'provider':'zai','model':'glm-5.3'}"` 退出码 0 且 `grep -c 'design' agent/skills/spec-workflow/routing.md` ≥1 且 `node routing.md 自检脚本逻辑`（映射 ⊆ 白名单）通过
- [x] 2.3 dsh/README.md spec-workflow 节同步：流水线图加 1.7、文件表 planning.md 说明、路由表加 design 行、流程描述含三档分降（触达面 T7）；验证：`grep -c '1.7\|代码设计' dsh/README.md` ≥3 且 `grep -c 'design' dsh/README.md` ≥1

## 3. 结构化验证

- [x] 3.1 码点与结构门：六 skill 文件 + 主规格基线记录与断言（各 ≤8192、SKILL.md ∈ [6800,7830]、frontmatter 逐字节不变、12 节标题不变）；验证：`python3` 断言脚本（逐文件 len + frontmatter diff + 节标题清单比对）退出码 0，数字记入执行记录
- [x] 3.2 契约定义源唯一与引用闭合：深度契约关键词（触达面/六字段/code-design）**定义源唯一在 planning.md**；SKILL.md 仅骨架句（不含 触达面/六字段，code-design.md 仅作产物路径引用）；execution.md、failure-modes.md 的命中皆为引用性短句（各 ≤2 处）；入口与资源互引路径 `test -f` 全通过；`grep -rn '五阶段' dsh/README.md` 与旧表述零冲突；验证：`python3 -c "s=open('agent/skills/spec-workflow/planning.md',encoding='utf-8').read(); k=open('agent/skills/spec-workflow/SKILL.md',encoding='utf-8').read(); assert all(w in s for w in ['触达面','六字段','code-design','阶段 1.7']); assert '触达面' not in k and '六字段' not in k; assert open('agent/skills/spec-workflow/execution.md',encoding='utf-8').read().count('触达面')<=2; assert open('agent/skills/spec-workflow/failure-modes.md',encoding='utf-8').read().count('阶段 1.7')<=2"` 退出码 0，且互引路径 `test -f` 逐条通过、`grep -rn '五阶段' dsh/README.md` 无输出
- [x] 3.3 规范校验：`openspec validate spec-workflow-add-design-phase --strict` 退出码 0 且无 error/warning；新 Requirement 描述 ≤500 字符复核；验证：命令退出码 0 + `python3` 字符断言通过

## 4. 运行时与自举冒烟

- [x] 4.1 会话内按名加载 spec-workflow skill 实测：返回完整（含 1.7 骨架句与 design 键）、渲染后 ≤8192 码点（复核包裹开销常量）；`/spec-flow` 命令面板可见；验证：实测码点数字与加载成功记录入执行日志
- [x] 4.2 自举行为核验：本变更由 /spec-flow 流程执行全程（双线→收敛→设计契约落档即本 design.md 的触达面/证据锚/逐组要点），执行日志含阶段 1.5 六步与 diff-matrix 留痕记录；验证：`test -s /tmp/spec-flow/spec-workflow-add-design-phase/diff-matrix.md` 且执行日志含收敛记录（自举方法先例：externalize-references D4.6）

## Workflow follow-up

- 全部勾选后：执行项目验证（本仓库无 CI/scripts，以组 3/4 断言为准）→ `openspec-archive-change` 归档并同步主规格 → 归档后断言主规格净增 ≤0（`python3 len()` ≤7914+容差 0）且 `openspec validate --specs --strict` 通过 → 归档单独提交 → 四要素汇报。
