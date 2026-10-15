# Design

## 触达面

| # | 文件 | 改动意图 | 关键改动点 |
| --- | --- | --- | --- |
| T1 | `agent/skills/spec-workflow/refs/convergence.md` | 去重 + 头注校正 | 删 L3–10（与六步展开内第 4 步块逐字一致，801 码点）；L1 改为 §五外移正文 |
| T2 | `agent/skills/spec-workflow/refs/planning.md` | 编号/结构/头注校正 | L1 补 §二/§四/§六/§十/1.7；补父级 H2；删 L32 残段；§二 展开改标 ①④⑤ 并注明 ②③ 留入口 |
| T3 | `agent/skills/spec-workflow/refs/execution.md` | 头注补齐 + 中途恢复要点 | L1 补 §九；三模式节增「以现存 diff 为准」条目 |
| T4 | `agent/skills/spec-workflow/refs/routing.md` | 自检脚本健壮化 | yaml 依赖候选探测 + 全缺时降级（退出码 0、明示「跳过 ≠ 通过」）；判定逻辑与正例输出不变 |
| T5 | `agent/skills/spec-workflow/refs/failure-modes.md` | 与执行纪律同口径 | 「勾选态与证据矛盾」行改为先跑验证句、通过即保持勾选 |
| T6 | `agent/skills/spec-workflow/SKILL.md` | §七 恢复协议澄清 + 等量收紧 | 第 3 步补「以现存 diff 为准」；删 §四 冗余指针、收紧 §七 第 1 步注记、去「（唯一源）」 |
| T7 | `dsh/README.md` | 文档同步 | 文件表 planning/execution 行；三模式段补中途恢复口径 |
| T8 | `openspec/specs/spec-workflow/spec.md` | 经 delta 同步（不手改） | MODIFIED 两个 Requirement |

## 决策记录

**D1：`auto` 恢复规则放哪里。** 入口 §七 是红线级恢复协议，压缩后必须可见，故规则本体（一句）留在 `SKILL.md`；展开理由（auto 收尾才提交、未提交属预期、不重派）落在 `refs/execution.md` 与 `refs/failure-modes.md`，三处同口径。被否方案：只写 `refs/execution.md`——恢复可能发生在任何人未读该文件的时刻，§七 字面会误判回退；被否方案二：把完整展开写进入口——入口净增预算仅 33 码点，且与「入口只留骨架与红线」的既有 Requirement 冲突。

**D2：入口净增以删 §四 冗余指针置换。** 候选池（按优先级）：①删 §四 末行「派发前先读 planning.md；两线除「方向」外逐字等形」（59 码点）——指针已由 §一 消费时机路由表承载、等形铁律已由 §四 独立性铁律承载；②§七 第 1 步注记收紧（约 −20）；③§一「工件（唯一源）」→「工件」（约 −5）。备用池：§一 L19 三分类提示、§十二 表内措辞。硬约束：净增量 ≤0，且不碰 frontmatter、12 节标题、红线表、恢复协议语义、中转协议与「绝不做」段。被否方案：把 7 字段清单从入口删除换空间——属行为语义边界，风险高于收益。

**D3：自检脚本不换成自研 YAML 解析。** 正则解析映射文件会引入新的脆弱面；改为候选探测（cwd、dsh 内置、dotfiles/opencode）＋全缺时显式降级。降级输出必须写明「未校验，不等于通过」，避免退出码 0 被误读为通过。

**D4：`planning.md` ②③ 不补展开。** 入口 §二 已含 ②参数 与 ③工作目录事实 的正文；在 refs 复制正文会形成双源。故以标号 ①④⑤ 对齐入口并注明「②③ 正文留在入口」。

**D5：主规格只在归档时由 delta 同步。** 实施阶段不手改 `openspec/specs/`，保证「工件 → 归档 → 主规格」链路可审计（与历次归档一致）。归档后须逐字复核主规格 diff——`openspec archive` 会对文本做规整，防误改其他 Requirement。

## 门禁

| 门 | 判据 |
| --- | --- |
| G1 结构 | `SKILL.md` `## ` 标题数 = 12；frontmatter 逐字节不变；全部 href 目标 `test -f` 通过 |
| G2 去重 | `convergence.md` 八个方法要点各恰好出现 1 次；六步判据 1–6 齐备 |
| G3 码点 | 六文件 ≤8192；`SKILL.md` ≤7816（净 ≤0），渲染上界 = 码点+343 ≤8192 |
| G4 运行时 | 会话内按名加载 `spec-workflow` 返回改后版本；`refs/` 五文件可见 |
| G5 自检脚本 | 正例退出码 0 且打印「OK 全部路由 ⊆ 白名单」；负例（越白名单）退出码 1；降级例打印「跳过」且退出码 0 |
| G6 规格 | `openspec validate spec-workflow-consolidation-polish --strict` 退出码 0；归档后 `--all` 退出码 0 |
| G7 回归 | `tools/skctl`：`node --test 'test/*.test.ts'` 47/47 通过 |

## 风险与处置

- 若 `convergence.md` 两块实测不再逐字一致 → 停手复核，绝不删非重复内容。
- 若等量收紧不足 → 启用备用候选池；仍不足则回到用户，不牺牲红线区。
- 若 strict 校验拒绝 delta 格式 → 按主规格逐字复制重写，而非改主规格。
- 若渲染信封 343 无法复现 → 沿用双证据法（结构分解 + 会话内加载实测）并记入执行日志「偏差」节。
- 回滚：`git revert` 三次提交即可完全还原（改动全部集中在 6 个 skill 文件 + README + 变更目录）。
