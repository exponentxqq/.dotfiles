# unify-spec-plan-questioning 收敛留痕（串行，阶段 1.5）

## 设计树

```
Q1 工具名写法 ──→ 契约措辞/接线句/spec delta 措辞/验证断言（全局依赖）
Q2 grill-me 范围 ─┬─ 选「连带改」→ Q7 grill-me 修改形态 ─→ Q8 grill-me spec capability
                  └─ （若「只改 spec-plan」则 Q7/Q8 消解）
Q6 边缘落点（触达 6→7 文件）
Q3 契约位置（独立新节）
Q5 变更名
Q4 spec-plan 侧 delta 形态（独立；ADDED 为主 vs 全量 MODIFIED）
```

## 第一轮（2026-11-12，前沿 = Q1/Q2/Q6/Q3/Q5；Q4 及 Q2 衍生的 Q7/Q8 留后续轮）

| 问 | 问题 | 推荐 | 用户答复 | 结论 |
| --- | --- | --- | --- | --- |
| Q1 | 契约中结构化提问工具名写法？ | 抽象定义+实名注记 | **抽象定义+实名注记** | 契约写「宿主结构化提问工具（DSH 为 `ask_user_question`）」；grep 断言以实名注记为锚 |
| Q2 | grill-me skill 是否连带修改？ | 只改 spec-plan | **连带改 grill-me** | grill-me 进入触达面；spec-plan 侧不再需要「承载覆盖声明」压迫性措辞（承载进 grill-me 权威源）；衍生 Q7（修改形态）/Q8（spec capability） |
| Q6 | 边缘追问落点（纠错/异常通道）是否纳入工具强制？ | 全部纳入 | **全部纳入** | 契约适用范围 = 本 skill 全部向用户提问（含 L9：routing 参数纠错、failure-modes 三选一/用户裁决、§九红线三选一）；触达 7 文件 |
| Q3 | 契约在 SKILL.md 的位置？ | 独立新节 | **独立新节** | SKILL.md 新增「追问契约」节（3–5 行：工具强制/背景与解释/选项区别与举例 + grill-me 承载接线）；7 文件接线句统一指向该节 |
| Q5 | 变更名？ | unify-spec-plan-questioning | **unify-spec-plan-questioning** | 变更名定为 `unify-spec-plan-questioning` |

## 查证事实（第一轮后，供 Q7/Q8 背景）

- `grep -rn "grill"` 全仓：grill-me 仅被 **spec-plan**（SKILL.md/convergence.md/serial.md/planning.md/failure-modes.md）引用；spec-apply、spec-done、spec-workflow **零引用**；README.md 仅表格归类行。连带修改的影响面 = spec-plan 流程 + grill-me 独立使用场景，不波及其他 spec-flow skill。
- `openspec/specs/` 现有 capability：spec-apply、spec-done、spec-plan、spec-workflow——**无 grill-me**。若为其行为变化立 spec 需新建 capability（先例：add-ui-demo-gate 为当时新建的 ui-demo skill 立 specs/ui-demo/spec.md delta）。
- grill-me 正文为英文（32 行），markdown 轮格式（❓Q1 标题+正文+➡️推荐）。

## 第二轮（2026-11-12，前沿 = Q7/Q8/Q4）

| 问 | 问题 | 推荐 | 用户答复 | 结论 |
| --- | --- | --- | --- | --- |
| Q7 | grill-me 修改形态？ | 双轨自适应 | **双轨自适应** | grill-me（英文正文）新增「承载形式（宿主自适应）」段：有结构化提问工具的宿主 → 轮次经工具承载（每题 question 含背景与解释、options 各附区别、推荐项置首标注），轮次=一次工具调用；无工具宿主 → 保持 ❓Q/➡️ markdown 轮格式不变；方法论（设计树/前沿/≤5 问/推荐措辞/答完重算）两轨共用 |
| Q8 | grill-me 是否新建 spec capability？ | 新建 | **新建** | 本次 spec delta = `specs/spec-plan/spec.md` + `specs/grill-me/spec.md`（两者均 ADDED 为主）；归档后 grill-me 承载行为有正式 Requirement |
| Q4 | spec-plan 侧 delta 形态？ | ADDED 为主 | **ADDED 为主** | 只 ADDED 新 Requirement「追问交互契约」全局叠加；既有 12 条 Requirement 仅在与契约**硬冲突**处 MODIFIED（预计 0–2 条，阶段 1.7 设计线逐条核对，如 1.75 问法句若写死文本格式） |

## 裁定依据与衍生事实

- Q2「连带改」+ Q7「双轨自适应」共同消解双源张力：承载细节进 grill-me 权威源（自适应段），spec-plan 契约节只写三要求 + 接线（指向 grill-me 承载段），无重复复述。
- Q6「全部纳入」→ 触达面定稿为 spec-plan 全部 7 文件（含 routing.md 参数纠错处接线）+ grill-me SKILL.md + 两个 spec delta。
- Q1 抽象+实名注记 → 验证断言锚点 = `ask_user_question`（DSH 实名），契约正文用「宿主结构化提问工具」语义表述。
- Q8 先例依据：add-ui-demo-gate 为当时新建的 ui-demo skill 立过 specs/ui-demo/spec.md delta。
- grill-me 新增段语言：保持英文正文一致性（实现细节，设计线定，非决策项）。
- 栈识别（阶段 1.7 派发前置）：dotfiles 无 pom.xml/build.gradle/nuxt.config——皆未命中，按流程问用户三选一（见流程记录；先例 add-ui-demo-gate 指认过 writing-skills）。
  - **用户答复（2026-11-12）：指认 writing-skills**——设计子代理先加载 `writing-skills`，其规范为设计硬约束；结论写入落档 design.md 决策记录。

## 收敛结束

**前沿为空**：Q1–Q8 全部落定，无静默假设项；用户两轮答复均已留痕。待决项清空，转入阶段 1.7 代码设计线。

## 阶段摘要

- 变更名：`unify-spec-plan-questioning`；仓库：dotfiles（单仓）；编排：**串行单线**（用户 2026-11-12 确认）。
- 引擎：串行无规划线派发（lineA/lineB 不消费）；阶段 1.7 设计线 = fresh subagent（design 路由）。
- 模型覆盖：用户未给 `--model`；design 键读映射文件（见路由自检记录）。
