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
| 显式路由不在白名单（`is not allowed for this Session`） | 按三档回退：fallback 重派一次 → 继承会话模型 → 仍失败报告暂停，不反复重试（routing.md） |
| 需读图而路由不支持（`does not declare image input`） | 改用 `vision` 路由重新派发；能力事实，不重试原路由 |
| 旧会话报 `child model selection is disabled` | 配置只对新会话生效：新建会话重试；不判定工具损坏 |
| team 成员失败 / 上限达限（`Team member limit 8 reached`） | `interrupt_agent` 中断或重建；无法恢复降级 subagent，降级与原因写留痕 |
| 验证需真实密钥而凭据缺失 | 明确报错失败，不静默跳过、不伪造结果；密钥只经参数/环境变量传入 |
| 需要宿主操作（装依赖、重启兜底） | 给确切命令交用户执行，不代劳 |
| 执行环境块缺失或 worktree 异常 | 按 spec-workflow 恢复协议与其 refs/worktree.md「恢复核对」处置；脏 → 呈证问处置，不擅自清理 |

> 注：红线级条目（审核确认前不提交、不提交未过验证内容、auto 硬停四条件、真实密钥只经参数、分仓提交、不静默假设待决项）留在 SKILL.md 第七节。
