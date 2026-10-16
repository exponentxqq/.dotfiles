# spec-workflow-execution-hardening —— 收敛留痕（阶段 1.5，串行 grill-me）

> 输入：explore.md 待决节 6 问。两轮前沿问答，全部落定；设计树无剩余分支，前沿为空。

## 设计树

```
Q1 范围取舍（根）
├─ Q4 F2 入主规格方式 ──→ delta 表达（事实裁定，非用户决策）
├─ Q2 F1 恢复防线形态
├─ Q3 F9 verify-change 定位
├─ Q5 变更名
└─ Q6 两处脏改动处置（依赖 Q1 的轻量确认）
```

## 第一轮（前沿 5 问：Q1/Q2/Q3/Q4/Q5，均按推荐接受）

| # | 问题 | 裁定 |
| --- | --- | --- |
| Q1 | 六项发现范围取舍 | **全做：F1~F5 + F7**（均为实证缺口、单项改动小、同批落档成本低） |
| Q2 | F1 恢复防线形态 | **缺失时自动补复制**：恢复协议加一步——落档副本缺失且 /tmp 原件在 → 补复制入变更目录并留痕、随下次批次提交；两者皆无 → 报告问用户，不以 /tmp 幸存为默认 |
| Q3 | F9 verify-change 定位 | **归档前必经标准环节**：阶段 4 在 archive 前加载 openspec-verify-change 校验（任务全勾 + spec 覆盖映射 + design 一致性），通过才归档 |
| Q4 | F2 主规格改法 | **改名扩义**「嵌套子仓提交」→「多仓分立提交」（N 仓各归其仓 + 外部独立仓参与口径） |
| Q5 | 变更名 | **`spec-workflow-execution-hardening`**（内容导向，仓惯例） |

## 第二轮（前沿 1 问：Q6）

| # | 问题 | 裁定 |
| --- | --- | --- |
| Q6 | 两处 T3.1 沉淀脏改动处置 | **落档提交后由执行方单独提交一次**（「T3.1 执行期沉淀」主题：spring-writer/SKILL.md +2 条规则、spec-workflow.yaml parallelism 3→8）——用户明示授权的任务边界扩展；落档提交本身仍严格限定 openspec/changes/<change>/ 工件 |

## 事实裁定（自行查证，未转提问）

- **delta 表达**：仓内 10 个归档变更 delta 头仅用过 `## ADDED` / `## MODIFIED` / `## REMOVED Requirements`，无 RENAMED 先例 → Q4 改名扩义以 **REMOVED（嵌套子仓提交）+ ADDED（多仓分立提交）成对表达**实现（split-spec-plan-skill 已验证该格式过 `--strict`）。
- **码点合规（F6）**：python 核算 11 文件全部 ≤7849（最大 7125），证伪丢弃。
- **routing 双源漂移面**：仅 F7 一处 provider 名漂移（执行侧 `zai` → 应为 `zai-coding-cn`），其余对称一致。

## 落档分歧点记录（阶段 2 第 3 步，含设计线上浮并入）

| # | 问题 | 裁定 |
| --- | --- | --- |
| Q-A | spec-plan 侧 refs/routing.md:9-11 schema 示例三处 `provider: zai` 简写与自身图片能力表（`zai-coding-cn`）漂移、与 F7 执行侧同构，是否随本变更修正？ | **随本变更同改**（设计线实测上浮；explore F7 原改法即「两侧一并统一」）——触达面 +T5b、组 1 +任务 1.4 |
| Q-B | 汇报五要素第⑤「沉淀回流清单」口径 | **已提交与未提交都列**（已提交标注去向一行；delta 措辞已按此预写，无需改动） |

## 收敛结论（全部已定，无未答项）

范围 = F1（落档材料校验 + 恢复防线，含自动补复制）+ F2（多仓分立提交 + 外部仓外溢口径，主规格 REMOVED+ADDED 成对）+ F3（组收尾勾选核对）+ F9（verify-change 归档前必经）+ F4（R<n> 模板加连锁面）+ F5（汇报五要素：沉淀回流清单，含已提交与未提交全貌）+ F7（**两侧** routing provider 名修正，Q-A 扩展）；变更名 `spec-workflow-execution-hardening`；Q6 授权落档后单独提交两处沉淀。
