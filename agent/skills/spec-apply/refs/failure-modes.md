> 本文件为 spec-apply SKILL.md 第七节的外移正文；回入口引用写「SKILL.md 第七节」。

## 边界与失败（执行侧处置表）

| 情形 | 处置 |
| --- | --- |
| `spec-apply` skill 或 `/spec-apply` 命令不可见 | 核对容器 symlink `~/.dsh/commands/spec-apply.md` 指向 `dsh/commands/` 源本，缺失则 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-apply.md ~/.dsh/commands/spec-apply.md`；再 `/commands-reload`；仍不可见兜底重启 dsh（宿主操作） |
| writer skill 加载失败 | 按失败处置顺序（登记核对 → `/commands-reload` → 重启兜底）修复，仍失败报告问用户，不静默降级 |
| 用户中断 | 立即停在安全检查点；未提交改动保持原状并汇报位置，不擅自 stash / revert / 补提交 |
| 审核被拒 | 按意见修正后**重审**：不勾选、不提交；修正范围超出本变更 → 回用户确认 scope |
| 任务失败（重试一次仍失败） | 暂停本批次并报告（任务号、错误、进度、建议），不中断其余批次 |
| 勾选态与证据矛盾 | 以证据为准：先对现存 diff 跑该任务验证句（未提交属预期），通过保持勾选不重派；不通过才回退并报告 |
| 显式路由不在白名单（`is not allowed for this Session`） | 按三档回退：fallback 重派一次 → 继承会话模型 → 仍失败报告暂停，不反复重试（routing.md）；白名单是 DSH 会话级授权而非本工作流自设（见 dsh/README.md） |
| 需读图而路由不支持（`does not declare image input`） | 改用 `vision` 路由重新派发；能力事实，不重试原路由 |
| 旧会话报 `child model selection is disabled` | 配置只对新会话生效：新建会话重试；不判定工具损坏 |
| 压缩后派发漏路由 / 子代理报 `ROUTE-MISMATCH` | 停派；按 `/tmp/spec-flow/<change>/routing.md` 重建/核对路由后显式重派；已停手任务重派，不重跑已合格任务（routing.md） |
| `routing.md` 缺失或与阶段不符 | 按映射文件 + 登记簿笔记覆盖重建并写回，**重建前不派发**；旧路径子代理走 `ROUTE-LEGACY` 不阻断（routing.md） |
| `ROUTE-MISSING` / 回执无自证行 | 键缺失 → 停手，补快照键后重派；无自证行 → 记 `ACK-MISSING`，后续要求自证；不因此重跑已合格任务 |
| 系统提示无模型声明 | 跳过自证，回执注明；照常按验证句核对 |
| 假失配（同一模型不同显示名） | lead 判定同一模型后放行，登记行 `reason=ACK-ADJUDICATED`；判不准则按失配处置 |
| 快照值与映射文件不一致（非覆盖/回退） | 以映射文件为准重建快照并在呈证报告；不按错快照继续派发 |
| team 成员创建失败 / Team 模式未开启 | Team 模式未开启 → 提示用户在根会话菜单开启后重试，否则回退 subagent 并留痕；成员创建失败同样回退并留痕；**无成员上限概念**（受 `maxActiveSubagents` 与映射 `parallelism` 约束）；控制手段 = 软废止令（登记簿该条目改 `state=void` + `reason`，仅检查点生效）+ `send_message` 下行通知，本配置无硬中断 |
| `send_message` 到 subagent/成员（下行）与子代理直报主会话（上行） | 按方向分别处置：**下行**（lead→subagent/成员）**可达**——`send_message(agent="<name>")`：运行中目标在下一步骤边界收 steer、闲置目标起一轮新轮次、冷目标恢复；**上行**（subagent→lead）用 `send_message(agent="lead")` 直报根会话，单发不候复，事件限**两类（决/异）**；派发事实以 `/tmp/spec-flow/<change>/progress.md` 登记簿为准，不因此重复派发 |
| 上下文压缩丢失派发记录/回执 | 按 spec-workflow 恢复协议 + 登记簿：以登记簿条目状态 + 写范围落盘事实判定——`state=active` 且写范围内预期文件已出现=在途（等回执，不重派、不轮询）；零落盘且无上行无回执=stalled（先对现存 diff 跑验证句：过则补勾 `done`，未过才重派 `@r2`，原行留存，恢复后不新建重复行）。`job_list` 不得作为在途判据（不含 subagent，真实运行中实测为空），防误判「已丢」造成双写 |
| 验证需真实密钥而凭据缺失 | 明确报错失败，不静默跳过、不伪造结果；密钥只经参数/环境变量传入 |
| 需要宿主操作（装依赖、重启兜底） | 给确切命令交用户执行，不代劳 |
| 执行环境块缺失或 worktree 异常 | 按 spec-workflow 恢复协议与其 refs/worktree.md「恢复核对」处置；脏 → 呈证问处置，不擅自清理 |
| 检查点读到自己的条目 `state=void`/`stalled` | 停手：不再改动、不 `git` 操作（`git status --porcelain` 只读核对）；回执首行写 `VOIDED`（停滞写 `STALLED`）并列已改文件，产出交主会话裁决 |
| 上行发送失败（`send_message` 报错 / 父名不可解析 `AGENT_NAME_NOT_FOUND`） | 不重试、不阻塞：事件改写进回执并注明降级原因，主会话据回执代问或重派 |

> 注：红线级条目（审核确认前不提交、不提交未过验证内容、auto 硬停四条件、真实密钥只经参数、分仓提交、不静默假设待决项）留在 SKILL.md 第七节。
