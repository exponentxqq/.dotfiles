> 本文件为 SKILL.md §十的外移正文（衔接与编排侧）；执行侧见 spec-apply、终末侧见 spec-done 的对应文件。

## 十、边界与失败（衔接与编排侧处置表）
| 情形 | 处置 |
| --- | --- |
| `/spec-flow` 命令或 `spec-workflow` skill（或被委托的 `spec-plan`/`spec-apply`/`spec-done`）不可见 | **通常无需重启**——聚合层（宿主 `/home/xuqinqin/.local/share/agent-skills/skills`）是容器内 `/home/docker/.agents/skills` 的**只读 bind mount 实时视图**，宿主侧新增/更新条目立即可见，运行中的会话即可按名加载 skill；命令侧由插件热加载（监听用户级命令目录 + 事件防抖重扫）。处置顺序：①**核对登记**：命令 symlink 应为 `~/.dsh/commands/spec-flow.md`（与 `spec-plan.md`、`spec-apply.md`、`spec-done.md` 的同式 symlink）指向 `dsh/commands/` 下源本，缺失则容器内 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/<name>.md ~/.dsh/commands/<name>.md`；skctl 登记则须确认聚合层含该条目——**skctl 聚合层在 dsh 容器内不可见**，`node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install <skill 目录>` 须在宿主或经 node 容器执行（宿主操作，由用户执行）；②在会话内执行内置 **`/commands-reload`** 手动重扫；③仍不可见才兜底 `cd ~/develop/docker && docker compose restart dsh`（宿主操作，由用户执行） |
| 用户中断（说停、切换话题、新指令） | 立即停在安全检查点；未提交改动保持原状并汇报位置（改了哪些文件、勾选到哪），不擅自 stash / revert / 补提交 |
| 需要宿主操作（重启容器兜底、skctl、装依赖） | 给出确切命令交给用户执行，**本 skill 不代劳**；**推送例外**——先探测（fetch 成功 / `ssh -T` 可达），可行则按用户指示代推，不可行才给宿主命令 |
| worktree 分支已被其他 worktree 检出（创建/重建时） | git 约束一分支一 worktree：换 worktree 路径或问用户，**不强拆他人检出**（worktree.md） |
| 恢复时 worktree 缺失或脏 | 按 worktree.md「恢复核对」处置：缺失但分支在 → 重建+装配+三方对齐核对；均无 → 问用户；脏 → 呈证问处置，不擅自清理 |
| 执行期失败（任务失败/审核被拒/路由回退/team 降级/凭据缺失） | 处置权威源 = skill spec-apply 的 refs/failure-modes.md，本 skill 不复述 |
| 归档与收尾期失败（验证失败/verify-change 缺漏/rebase 冲突/push 被拒/删 worktree 门槛） | 处置权威源 = skill spec-done 正文红线表，本 skill 只指路 |

> 注：红线级条目（绝不副作用创建 `openspec/`、不在用户审核确认前提交实现改动、不静默把待决项变假设、不提交未过验证内容、`DELEGATED_CALLER` 是平台设计不是故障、`auto` 硬停四条件、真实密钥只经参数、分仓提交）留在 SKILL.md 第十节，不在此文件。
