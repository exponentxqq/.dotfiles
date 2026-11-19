# Design

## Context

spec-apply subagent 引擎现状为「派发后等回执」开环（`agent/skills/spec-apply/refs/execution.md:3-11`）；spec-plan 规划子代理上浮走回执（`agent/skills/spec-plan/SKILL.md:74-80`）。平台事实基线（双探针实证 2026-11-19，dsh 0.2.2-rc.1，web profile）：lead→subagent 下行 ✗（team 版 `send_message` 报 `active teammate not found`；`tool-subagent-control` 被 agent-team-profile 禁用且工具重名互斥、包无配置不可改名共存）｜subagent→lead 上行 ✓（subagent 面有 `send_message`，父 session id 在其 runtime context，`"lead"` 名不可寻址）｜sibling 互达 ✗｜硬中断 ✗（`interrupt_agent` 仅 teammate；`job_list` 不含 subagent，探针 2 运行中实测为空）。完整实证矩阵与逐字协议文案见本目录 `code-design.md`（深度契约权威副本），规划决策链见 `decisions.md`。

## Goals / Non-Goals

**Goals:**

- 在平台约束内把 subagent 引擎的控制与协调做到协议极限：租约冲突发现（开工即知）、软废止（检查点生效）、上行直报（三类事件）、引擎升级判据（派发前提示）。
- spec-plan 规划线/复算线/设计线同步接入上行（仅待决+异常两类），两侧提问节奏不变。
- 修正与平台事实矛盾的既有文本（spec-apply failure-modes 两行、spec-workflow:65 `job_list` 判据）。

**Non-Goals:**

- 平台层改造（re-enable 互斥工具 / DSH 插件 / 上游 PR）——工具重名互斥且包不收配置，无可行路径。
- team 引擎接入登记簿/上行（P2=a：已有 `send_message`/`interrupt_agent`/`wait_agent`，接入属重复建设）。
- 实时双向通信与硬中断——平台不可达，协议目标为「软通知 + 检查点生效 + 判据升级」。
- 登记簿可执行校验脚本（P3=a：避免与 markdown 协议并存的第二权威源）。

## Decisions

栈识别结论（执行侧接线依据）：**writer skill = `writing-skills`**（用户指认；spring/nuxt 判据实测零命中，触达面 13 条零应用代码；证据与被否方案见 `code-design.md` ④D0）。阶段 1.75 界面演示**未触发**（C1 不成立：零用户可见界面产出，判定留痕见 `code-design.md` 附录）。

| # | 决策 | 被否方案（摘要） |
| --- | --- | --- |
| D1 | 协议权威源 = 新建 `spec-apply/refs/coordination.md`（10 节），spec-plan 只指路 | 全塞 execution.md（两引擎共用文件混淆）；spec-plan 自建副本（双源漂移） |
| D2 | 登记簿单写者 = 主会话，子代理只读 | 子代理写自己的 active 行（markdown 无锁，后写覆盖/整文件 Write 抹条目） |
| D3 | 同批先登记全批条目再一条消息并发派发 | 边派边登记（t=0 冲突窗口，恰是要消灭的场景） |
| D4 | 软废止令 = 登记簿 `state=void`，不另立令文件 | 独立 void-*.md 令文件（双源、检查点两次读） |
| D5 | 停滞由 lead 判定（零落盘+无上行+无回执），不心跳不轮询 | 定时心跳（违反禁令且 `job_list` 无在途信号可查） |
| D6 | 上行三类事件、单发不候复、协议无多轮澄清设计 | 多轮问答（lead 无下行，已结束回合的子代理无法唤醒） |
| D7 | 协调段内联进提示（8 行/574 cp ≤15 行），不让子代理自读 refs | 提示写「先读 coordination.md」（fresh 子代理无 skill 根路径上下文，静默失效） |
| D8 | spec-plan 入口只加 97 cp（渲染 8146/8192），细则走 coordination.md §7；备 58 cp 降级预案 | 178 cp 完整句（实测渲染 8227 超界 35 cp 触发中段裁剪，剪掉 §四 中转协议） |
| D9 | failure-modes 两行拆方向重写（原文加注会让可用能力被误判不可用） | 保留原句加更正行 |
| D10 | delta 形态：spec-apply 2 MODIFIED + 1 ADDED（正文 311/328/429 cp ≤500）；spec-plan 1 MODIFIED（422 cp） | 全塞既有 Requirement（超 500 触发 validator `:745`，归档后绿转红） |
| D11 | 升级判据只提示不自动切；且只在 spec-apply §三 写一份 | 自动切（引擎语义漂移、用户不知情）；§二③§三双份（漂移） |
| D12 | 注入段 = 7 条正向配方（必填槽），非禁令清单 | 禁令式（omission 型失败用禁令实测更差且可协商） |
| D13 | team 引擎不注入协调段；登记簿仅可记 team 条目（1 行说明） | 全量接入（能力重复，模板裂成两套） |
| P1 | spec-workflow:65 `job_list` 判据一并单行改写（≈+60 cp，无 spec delta） | 另立变更（与登记簿单源不同步的窗口期）；不修（恢复协议按空集合误判在途→重派双写） |
| P2 | team 不接入登记簿/上行（用户拍板 a） | 只登记不注入／全量接入 |
| P3 | 登记簿不加可执行校验（用户拍板 a） | 附断言脚本／写进每组验证句 |

## Risks / Trade-offs

- [子代理对检查点遵循度尽力而为] → 检查点少而关键（开工/写前/验证前三处）；回执首行 VOIDED 是唯一可核对信号；组 6 GREEN 配对复测取证。
- [上行消息单发不候复] → 协议只允许「发完继续/停手等接续重派」二态；lead 收到即代问，答复经接续重派携带。
- [spec-plan 入口余量仅 46 cp] → 硬上限 100 cp + 58 cp 降级预案（指路句移入 parallel.md/planning.md，两处余量 ≥4800 cp）。
- [父 session id 获取不稳] → 注入段第 4 条自带降级（改写进回执），协议其余部分不失效；设计线自证其 runtime context 明写父 id。
- [spec-plan 主规格当前已红 2 条 >500（非本次引入）] → 本次门禁口径「不新增 warning」，**禁用 `--all --strict`**；spec-apply 侧必须保持 exit 0。

## Migration Plan

无部署/回滚复杂度（纯文本协议变更）。执行顺序即 tasks 六组：RED 基线 → coordination.md → spec-apply 三文件 → spec-plan 五文件（含 P1 的 spec-workflow 单行）→ delta 只读核对 → GREEN 配对与无裁剪终检。回滚 = revert 本变更高码位提交（无数据迁移、无配置兼容面）。

## 逐断言核对（深度契约承载，逐字文案源 = 本目录 `code-design.md`）

- **① 触达面（13 条全在 dotfiles 根仓）**：#1 新建 `spec-apply/refs/coordination.md`｜#2 `execution.md`（台账 v2 + 协调注入 + team 不注入 + 回执 VOIDED）｜#3 `spec-apply/SKILL.md`（§三 协调纪律含派发前判据、§四 上行句、:39 路由）｜#4 `failure-modes.md`（:17 拆方向、:18 作废 job_list、+2 行）｜#5 `spec-plan/SKILL.md:80` 后 +97 cp｜#6 `mode/parallel.md`｜#7 `refs/planning.md`｜#8 `refs/convergence.md`｜#9 spec-plan `failure-modes.md`｜#10/#11 两份 spec delta｜#12 归档终态（不直接编辑）｜#13 `spec-workflow/SKILL.md:65` 单行改写（P1）。不触达 5 项附理由见 `code-design.md` ①。
- **② 证据锚**：每模块 file:line 事实共 20 条，见 `code-design.md` ②（含长度口径先例 8192/343 与 validator 500 上限锚点）。
- **③ 接口与数据形状**：登记簿条目 schema（8 字段表 + 状态机 + 单写者规则 + 前缀重叠机械判据）、注入段模板（8 行/574 cp，`coord-inject` 标记）、上行消息格式（`[上行][<change>][T<n.m>][决|异|成]` + 三示例）、软废止（= `state=void`，含「令迟到」处置）、冲突矩阵 5 行、升级判据 4 条、spec-plan 精简段（5 行/358 cp）——逐字文案见 `code-design.md` ③3.1–3.9。
- **④ 决策记录**：D0–D13 + P1–P3 见上表与 `code-design.md` ④（每条含被否方案与 ≥1 反例）。
- **⑤ 逐任务组要点**：6 组 15 任务与 tasks.md 分组一一对齐（见 tasks.md；组 1 RED 基线 → 组 6 GREEN 配对为 writing-skills Iron Law 的 RED→GREEN 落地；4.6 = P1 的 spec-workflow:65 单行改写）。
- **⑥ 假设与未决项**：A1–A6 假设 + U1–U3 未决见 `code-design.md` ⑥（含降级路径）；本次无阻塞未决。

## 执行环境

- 执行环境：直用主工作区。布局：dotfiles 根仓主检出 @ master（唯一触达仓 = 工件仓，按 refs/worktree.md「根仓（工件仓）不建 worktree」规则不隔离，用户裁决 2026-11-19）；装配：无（skill 经 `~/.agents/skills` symlink 即时生效，无构建/依赖步骤）；环境错开：无（主检出无关脏改动 `dsh/profiles/web/package.json`、`dsh/profiles/web/pnpm-lock.yaml` 不在本变更触达面，不混入提交面）；创建于 2026-11-19

## Open Questions

无（P1/P2/P3 已由用户拍板：a/a/a；U1 降级预案已在决策 D8/U1 中预置，属执行期按需触发）。
