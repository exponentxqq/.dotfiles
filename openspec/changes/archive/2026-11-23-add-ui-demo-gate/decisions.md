# add-ui-demo-gate 收敛留痕（串行，阶段 1.5）

## 设计树

```
Q1 可选项 scope ──┬─ ②AGENTS.md 行 ─→ Q2 落点（随 Q1 消解）
                  ├─ ①/ui-demo 命令薄壳
                  └─ ③dogfood 演示页
Q3 nginx 暴露面（独立）─→ 衍生：预览方式退 file://（事实推导）
Q4 L2/L3 判据粒度（独立）
Q5 spec-workflow.yaml demo 键（独立）
Q6 栈识别三选一（独立，1.7 派发前置）
```

## 第一轮（2026-11-05，前沿 = Q1/Q3/Q4/Q5/Q6，Q2 依赖 Q1 留第二轮）

| 问 | 问题 | 推荐 | 用户答复 | 结论 |
| --- | --- | --- | --- | --- |
| Q1 | 三个可选落地项（/ui-demo 薄壳、AGENTS.md 行、dogfood 演示页）纳入哪些？ | ①③ 纳入 | **全部不做** | 最小 scope：触达面仅 dotfiles 单仓 5 项（ui-demo skill 新建、spec-plan SKILL.md+planning.md、spec-workflow SKILL.md、变更工件）；#6/#7/#8 出局，**docker 仓退出触达** |
| Q3 | ui-demos.localhost alias 范围？ | A 全树 alias | **「先不要nginx了」**（custom） | 本期不加 nginx server；预览方式退为**宿主 file:// 直开**（身份挂载下宿主路径即文件路径；chrome-shared 自检走 file:// 导航，容器内同路径可解析）；skill 备注「nginx 统一入口留待未来独立变更」 |
| Q4 | L2/L3 触发判据粒度？ | A 语义判据 | **A** | 「含关键交互流/多状态 → L2；视觉方向完全开放且用户未给偏好 → L3」一句语义判据入 skill |
| Q5 | spec-workflow.yaml 加 demo 键？ | A 不加 | **A** | 映射文件与 routing 白名单零改动 |
| Q6 | 栈识别三选一（dotfiles 无 pom/nuxt）？ | A 指认 writing-skills | **A** | 阶段 1.7 设计子代理先加载 `writing-skills`，其规范为设计硬约束；结论待写入落档 design.md 决策记录 |

## 裁定依据与衍生事实

- Q1「全部不做」→ Q2（AGENTS.md 落点）**消解**，无需第二轮；explorer/plan 软接线只剩 skill frontmatter 强触发词一条腿（explore.md 风险 #1，用户知情接受；设计侧要求 description 触发词写得足够强）。
- Q3「先不要」语义 = 本期不做（非永久否决）；skill 预览约定写 file:// 直开并留 nginx 扩展位。
- 验证思路随之收缩：去掉 nginx curl 冒烟与 dogfood 演示页，保留 validate --strict / 软链生效 / 手册 grep 断言。
- 演示产物入库位置不变：`openspec/changes/<change>/demos/`（plan 场景 `docs/ui-demos/`）。

## 收敛结束

前沿为空（全部待决项均有用户明确答复，无静默假设）。→ 进入阶段 1.7 代码设计。

## 落档裁定轮（2026-11-05，分歧点提问 = 设计线上浮 Q-A~Q-E + 1.75 形态知会）

| 问 | 用户答复 | 结论 |
| --- | --- | --- |
| 1.75 形态（知会） | 未提异议 | §六 `###` 子节（节标题改「代码设计（1.7）与界面演示 gate（1.75）」），不新增顶级节，避免 6 文件 13 处指针重编号 |
| Q-A RED 压测 | A 本期做 | 5 任务组；组 1 = 素材 + RED 基线压测（writing-skills Iron Law） |
| Q-B L3 形态 | 追问宽页面对比 → 确认「tab 主 + 并排可选」 | 单文件；tab 切换为主（每方向独占整屏宽 + 方向名与一句定位），并排缩略（transform: scale）仅显式要求时；自检逐 tab 各验一次 |
| Q-C plan 场景落点 | C 走 /tmp 不落库 | /plan 场景演示即确认即弃：容器 `/tmp/ui-demos/`（= 宿主 `/data/tmp/ui-demos/`，双写路径）；spec/explore 场景仍入 `openspec/changes/<change>/demos/` 随落档入库 |
| Q-D 落档摘要字段 | B 可选不断言 | 摘要不强制「演示目录」字段；路径由 demos/ 断言 + design.md 决策记录双处留痕 |
| Q-E 示意数据 | A 强制标注 | HTML 契约含「示意数据」强制标注条，断言 `grep -c '示意数据'` 可机械核对 |

设计线关键裁定（主会话核可，证据见 code-design.md ④）：触达面 16 条（含 README 登记行 + skctl 机器态登记 + 3 delta 文件）；openspec 1.16.0 校验硬约束（ADDED ≤500 字符 / MODIFIED 整块照抄 scenario / 任务 ID 前缀=组号）；`/tmp`↔`/data/tmp` 双写路径；`whenToUse` 零触发贡献 → 软接线仅靠 description。
