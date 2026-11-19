# decisions.md · improve-smoke-skill-codepoint-slim（阶段 1.5 收敛留痕）

## 设计树（串行单线，待决源 = explore.md 待决节）

```
根：码点最小充分集 + 保守去双写 + openspec 变更（三轮预裁决，视同已预置参数）
├── Q1 变更名 ──────────→ 已决：improve-smoke-skill-codepoint-slim
├── Q2 spec.md 同步形态 ─→ 已决：独立新 Requirement「多字节字符口径」+ 2 Scenario
└── Q3 Top 12 陷阱表 ───→ 已决：保持 12 条不动，可见性由 SKILL 阶段 4 指路句承担
```

## 轮次记录

### 第 1 轮（前沿 3 问，全部前沿一次问尽）

| # | 问题 | 推荐 | 用户答复 | 仍待决 |
| --- | --- | --- | --- | --- |
| Q1 | 变更名（improve-smoke-skill-codepoint-slim / add-smoke-skill-codepoint-and-slim / 自定） | improve-smoke-skill-codepoint-slim（improve 涵盖补与减；active 列表已核对无重名） | ✅ 采纳推荐 | 否 |
| Q2 | spec.md 码点能力形态（独立 Requirement / 并入「逐项执行纪律」） | 独立 Requirement + 2 Scenario（与既有 7 条正交、复测可单独定位、validate 可判定） | ✅ 采纳推荐 | 否 |
| Q3 | Top 12 是否扩码点条目（不动 / 扩 Top 13） | 不动（保守档精神；阶段 4 指路句已承担可见性；SKILL 净变短最大化） | ✅ 采纳推荐 | 否 |

## 收敛结束判定

第 1 轮答毕后重算前沿：三项裁决均无下游待决解锁（码点落点/瘦身位置/验证断言均为事实与设计细节，属阶段 1.7 设计线职责，非用户决策）。**前沿为空，收敛结束**，可进阶段 1.7 代码设计。

## 裁定依据与结论汇总

- 变更名 `improve-smoke-skill-codepoint-slim`：目录、提交信息、`/spec-flow continue` 参数均用此名；`/tmp/spec-flow/` 工作目录起名时已对齐，无需迁移。
- spec delta = 新增独立 Requirement「多字节字符口径」：测试数据含中文/emoji/生僻字 SHALL 先确认 DB 字符集；长度边界用例 SHALL 按被测校验层计数单位构造；落库断言 SHALL 验证多字节值完整。Scenario ①：utf8mb3 表插 emoji 报错/静默截断 → 判环境限制非功能缺陷并记观察项；Scenario ②：「限 50 字」边界负例全不生效 → 按前端 code unit 口径重构造后命中。
- SKILL.md Top 12 表零改动；码点在 SKILL 的入口 = 阶段 4 数据准备新增 1 条指路句（指向 reference §3.7）。
