# Tasks

> 组间严格串行、组内可并行；`## N.` 即执行审核批次。`<change>` = `harden-spec-routing-compaction`。所有验证句均可在容器内第三方复跑；涉及长度的用 `python3` 断言 cp（`len(str)`）。

## 1. 工件与取证基线

- [x] 1.1 写 `proposal.md` / `design.md` / `tasks.md` 与 4 份 capability delta（`specs/spec-apply|spec-workflow|spec-done|spec-plan/spec.md`，全部用 `## ADDED Requirements`，Requirement 名不与主规格重名）。
  验证：`openspec validate harden-spec-routing-compaction --strict` 退出码 0；`ls openspec/changes/<change>/specs/*/spec.md | wc -l` = 4。
- [x] 1.2 固化取证与基线：会话日志复算（总派发/显式/缺失、首个缺失任务、子会话实际模型）、12 个触达文件长度基线、4 个既有脏文件基线。
  验证：`test -s /tmp/spec-flow/<change>/drift-audit.txt` 且 `grep -q 'missing route: 30' /tmp/spec-flow/<change>/drift-audit.txt` 且 `grep -q 'first missing.*apply-6-2' /tmp/spec-flow/<change>/drift-audit.txt` 且 `grep -q 'apply-6-2.*actual= zcode-plan/glm-5.3' /tmp/spec-flow/<change>/drift-audit.txt`；`wc -l < /tmp/spec-flow/<change>/length-baseline.txt` = 12；`wc -l < /tmp/spec-flow/<change>/baseline-status.txt` = 4。

## 2. spec-apply 协议内核（路由快照 + 登记簿 v4 + 自证）

- [x] 2.1 `agent/skills/spec-apply/refs/coordination.md`：§2 schema v4（行新增 `route`、`reason` 支持 `ROUTE-DRIFT`、v3 legacy 兼容）、§3 登记序加 route、§4 注入段加自证（≤15 行）、§10 硬界改 3800–6400 与常量清单。
  验证：`python3 -c` 断言该文件 `3800 <= len(s) <= 6400` 且含 `route=`、`ROUTE-ACK`、`ROUTE-MISMATCH`、`ROUTE-LEGACY`、`ROUTE-MISSING`、`v3` legacy 句；注入段（`coord-inject` 标记之间）行数 7–15；`grep -c 'send_message(agent="lead")'` ≥2。
- [x] 2.2 `agent/skills/spec-apply/refs/routing.md`：新增「路由快照与压缩恢复」节（解析优先级、routing.md schema、写入/刷新/回退 history、子代理自证、与映射文件的权威关系、与三档回退衔接）。
  验证：`grep -c 'routing.md'` ≥2 且 `grep -c 'ROUTE-MISMATCH'` ≥1 且 `grep -c '唯一权威\|已解析副本'` ≥1；`python3 -c` 文件 cp ≤8192 且 `'glm-' not in s and 'deepseek-v4' not in s`。
- [x] 2.3 `agent/skills/spec-apply/refs/execution.md`：派发示例带 `provider`/`model`、台账加 route、提示含路由键+快照路径、回执首行 `ROUTE-ACK` 契约、组收尾核对、漂移处置、批末预告写路由、team 卡同款。
  验证：`grep -c 'provider='` ≥2 且 `grep -c 'ROUTE-ACK'` ≥1 且 `grep -c 'ROUTE-MISMATCH'` ≥1 且 `grep -c 'ROUTE-DRIFT'` ≥1 且 `grep -c 'routing.md'` ≥1；旧示形 `subagent(name="apply-<组>-<任务>", description=…, prompt=…)` 命中数 = 0；文件 cp ≤8192。
- [x] 2.4 `agent/skills/spec-apply/refs/failure-modes.md`：新增快照缺失/旧、`ROUTE-MISMATCH`/`ROUTE-MISSING`、`ROUTE-LEGACY`、假失配、快照与 yaml 不一致、回退/继承处置行。
  验证：`grep -c 'routing.md'` ≥1 且 `grep -c 'ROUTE-MISMATCH'` ≥1 且 `grep -c 'ROUTE-LEGACY'` ≥1；文件 cp ≤8192。
- [x] 2.5 `agent/skills/spec-apply/SKILL.md`：§二 压缩恢复速查加路由快照；§三 循环与协调纪律加「登记 route → 派发必传 route」；§五 指路快照；§七 红线加省略路由即违规。
  验证：`grep -c '路由快照'` ≥1 且 `grep -c 'route'` ≥2 且 `grep -c 'routing.md'` ≥1；`python3 -c` 文件 cp ≤8192。

## 3. 编排交接与恢复（spec-workflow）

- [x] 3.1 `agent/skills/spec-workflow/SKILL.md`：§三 笔记记录执行侧覆盖；§五 衔接提示建议批次边界压缩、恢复协议读快照/缺失重建/重建前不派发、恢复摘要含路由；§九 快照只作恢复与审计。
  验证：`grep -c 'routing.md'` ≥1 且 `grep -c '批次边界'` ≥1 且 `grep -c 'ROUTE'` ≥1；`python3 -c` 文件 cp ≤8192。
- [x] 3.2 `agent/skills/spec-workflow/refs/failure-modes.md`：新增「压缩后路由漂移 / 快照缺失」行，处置指路 spec-apply failure-modes。
  验证：`grep -c '路由快照\|ROUTE'` ≥1；文件 cp ≤8192。

## 4. 终末与规划

- [x] 4.1 `agent/skills/spec-done/SKILL.md`：§二'/§四 验证子代理显式传 `verify` 路由 + 提示 `路由键 verify` + 自证 + 失配不归档 + 快照缺失按映射文件解析写回。
  验证：`grep -c 'ROUTE-ACK'` ≥1 且 `grep -c 'ROUTE-MISMATCH'` ≥1 且 `grep -c 'routing.md'` ≥1；文件 cp ≤8192。
- [x] 4.2 `agent/skills/spec-plan/refs/routing.md` + `mode/parallel.md` + `SKILL.md`：派发显式路由、提示首行路由键、子代理自证、缺路由行时读映射文件、压缩后重读；SKILL 只加指路一句。
  验证：`grep -c 'provider=' agent/skills/spec-plan/refs/routing.md` ≥1 且 `grep -c 'ROUTE-MISMATCH'` ≥1 且 `grep -c '路由键'` ≥1；`grep -c 'provider=' agent/skills/spec-plan/mode/parallel.md` ≥1；`python3 -c` 两文件分别 ≤8192/≤4000；`git diff --stat -- agent/skills/spec-plan/refs/planning.md` 输出为空。

## 5. 仓文档

- [x] 5.1 `dsh/README.md`：「阶段模型路由」节新增「压缩后的路由持久性（执行/验证）」段（快照/必传/自证/漂移/旧账兼容）；「白名单一致性」注补「省略路由 = 继承父路由，不走白名单校验」；零具体模型值、零映射/白名单改动。
  验证：`grep -c '路由快照\|ROUTE-ACK\|省略' dsh/README.md` ≥3；`grep -c 'glm-5\|deepseek-v4\|deepseek-flash' dsh/README.md` 与基线相等；`git diff --quiet -- dsh/spec-workflow.yaml` 退出 0；`git status --porcelain` 中 `dsh/profiles/web/*` 与 `opencode/opencode.jsonc` 仍为基线 4 项（未新增、未暂存）。

## 6. 行为验证与收口

- [x] 6.1 静态门全量：长度门（12 文件）、常量门（route/ROUTE-ACK/MISMATCH/LEGACY/MISSING/routing.md）、单源门（skills 内具体模型字面量 = 0）、`openspec validate <change> --strict`、`openspec validate --all --strict`、既有脏文件基线一致。
  验证：门脚本逐项打印 `PASS`，任一 `FAIL` 退出非 0；`git status --porcelain | wc -l` = 4 + 本轮新增/修改文件数（人工比对 1.2 基线）。
- [x] 6.2 行为探针 P0–P3（真实子代理，短提示，`/tmp/spec-flow/route-probe/` 隔离）：P0 只读重建演练、P1 正向 `ROUTE-ACK`、P2 负向 `ROUTE-MISMATCH` 停手、P3 无快照 `ROUTE-LEGACY` 放行。
  验证：P0 回答含快照路由与 `provider/model` 必填；P1 回执首行 `ROUTE-ACK model=<apply 模型>`；P2 回执首行 `ROUTE-MISMATCH` 且探针目录零写入；P3 回执首行 `ROUTE-LEGACY`；探针目录清理后 `ls /tmp/spec-flow/route-probe` 不存在。
- [x] 6.3 回放与最终复核：复算 47/17/30、首个缺失 `apply-6-2`、实际 `zcode-plan/glm-5.3`；审阅 `git diff` 全量；确认 t7-3 会话/worktree 与 4 个既有脏文件零改动；零提交、零归档。
  验证：`grep -q 'missing route: 30'` 等 1.2 同款断言；`git log -1 --oneline` 与基线一致（未提交）；`git -C /home/xuqinqin/develop/company/workstation/benchmark status --porcelain` 与基线一致（不触碰）。
