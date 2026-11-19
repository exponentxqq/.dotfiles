# Proposal

## Why

smoke-testing-local-env skill 对多字节字符（中文/emoji/生僻字）零覆盖：测试数据落库核验不查 DB 字符集（`utf8`=utf8mb3 遇 4 字节字符报错或静默截断，易误判为功能缺陷），长度边界用例无计数单位口径（前端 UTF-16 code unit / DB 码点 / 字节三套单位错配致负例全不生效）；同时 SKILL.md 与 reference.md 存在 4 处双写（模式表、执行纪律、三层证据表、§9 映射表等），多处维护易漂移、触发即读成本偏高。

## What Changes

- **码点口径补全（最小充分集，五处结构槽位）**：reference 新增 §3.7「多字节字符与码点口径」（DB 字符集 / 计数单位 / 落库完整性 / 截断显示四行检查表）、§5.2 负例矩阵 +「长度边界」行、§8 陷阱全表 +#24/#25；项目画像模板 §3 +「字符集/排序规则」行；SKILL.md 阶段 4 +1 条指路句（码点在入口的唯一可见性，Top 12 表按裁决不动）
- **保守去双写（六处，行为零变更）**：SKILL.md 模式表 4→3 数据行、执行纪律 4→2 条、三层证据表并 1 行、「回写」并入冒烟通过公式（199→188 行）；reference §9 映射表→3 行指路（节号保留）、§6.4/§7.2 入库忽略规则去双写（584→583 行）
- **主规格新增第 8 条 Requirement「多字节字符口径」**（ADDED，+2 Scenario）：字符集受限判环境限制非功能缺陷、长度边界按被测校验层计数单位构造
- 零改动：两个脚本（recon.sh / tcp-bridge.mjs）、Top 12 陷阱表、既有 7 条 Requirements、add-ui-demo-gate 目录

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `smoke-testing-local-env`: 新增「多字节字符口径」Requirement（数据准备阶段先确认 DB 字符集与各校验层计数单位；utf8mb3 的 4 字节字符失败判环境限制；长度边界按被测层单位构造；落库断言逐字符比对多字节原值）。§3.7 为既有 §3 的子节新增，既有节号 §1–§9 零缺失；主规格既有 7 条 Requirement 逐字未动（spec.md「文档结构兼容约束」中「只新增 §6.1–§6.5」按历史时点解释为上次变更的 delta 范围记录，非永久白名单——详见 design.md 决策记录）。

## Impact

- 触达面全部在 dotfiles 根仓：SKILL.md / reference.md / project-profile-template.md 三文档 + 主规格 spec.md（归档 sync 时追加第 8 条），净行数 877→866（−11）；收益为结构性：双写归零单点维护、SKILL 触发即读成本 −11 行、码点误判风险有可判定规程
- 冻结区兼容：SKILL.md L1–60 逐字节不变、reference.md L1–174 逐字节不变（含 add-ui-demo-gate 对 SKILL.md:30-34 与 reference.md:19 的活行号引用）
- 分发：skill 经 symlink 指向 dotfiles 实体，改完即时生效，无构建步骤
- 不安排子代理 RED/GREEN 压测（writing-skills Iron Law 豁免依据见 design.md）：本次为事实补全 + 结构槽位 + 去重，失效形态是「遗漏」而非「压力下违规」，可判定性由 spec 2 Scenario 与真实冒烟复测承担
