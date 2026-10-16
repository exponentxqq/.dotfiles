> 本文件为 SKILL.md §十的外移正文，回入口引用写『SKILL.md 第 X 节』

## 十、边界与失败（处置表主体）
| 情形 | 处置 |
| --- | --- |
| `/spec-flow` 命令或 `spec-workflow` skill（或被委托的 `spec-plan`）不可见 | **通常无需重启**——聚合层（宿主 `/home/xuqinqin/.local/share/agent-skills/skills`）是容器内 `/home/docker/.agents/skills` 的**只读 bind mount 实时视图**，宿主侧新增/更新条目立即可见，运行中的会话即可按名加载 skill；命令侧由插件热加载（监听用户级命令目录 + 事件防抖重扫）。处置顺序：①**核对登记**：命令 symlink 应为 `~/.dsh/commands/spec-flow.md`（与 `~/.dsh/commands/spec-plan.md`）指向 `dsh/commands/` 下源本，缺失则容器内 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/<name>.md ~/.dsh/commands/<name>.md`；skctl 登记则须确认聚合层含该条目——**skctl 聚合层在 dsh 容器内不可见**，`node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install <skill 目录>` 须在宿主或经 node 容器执行（宿主操作，由用户执行）；②在会话内执行内置 **`/commands-reload`** 手动重扫；③仍不可见才兜底 `cd ~/develop/docker && docker compose restart dsh`（宿主操作，由用户执行） |
| `spec-plan` 或 `openspec-archive-change` skill 加载失败 | 同上核对聚合层；先 `/commands-reload`，重启兜底；规划方法论（双线/收敛/设计契约）以 spec-plan 为唯一权威源，本 skill 不代替其行为，也不复述 |
| 用户中断（说停、切换话题、新指令） | 立即停在安全检查点；未提交改动保持原状并汇报位置（改了哪些文件、勾选到哪），不擅自 stash / revert / 补提交 |
| 审核被拒（step 模式或用户否决产出） | 按意见修正后**重审**：**不勾选 checkbox、不提交**；修正范围超出本变更 → 回到用户确认 scope |
| 任务失败（重试一次仍失败） | 暂停本批次并报告（任务号、错误、进度、建议），不中断流程其余部分 |
| 勾选态与证据矛盾 | 以证据为准：**先对现存 diff 跑该任务验证句**（收尾经用户确认才提交，未提交**属预期**），通过即保持勾选、不重派子代理；不通过才回退该勾选并报告 |
| 显式模型路由不在**白名单**（报 `is not allowed for this Session`） | 按第九节**三档回退**：先 `fallback` 重派一次 → 再无则回退继承会话模型 → 仍失败报告并暂停（**不反复重试**） |
| 子代理需读图而阶段路由不支持图片（报 `does not declare image input`） | 改用 `vision` 路由重新派发（第九节）；该错误是能力事实，**不重试原路由** |
| 旧会话报 `child model selection is disabled for this tool instance` | 该会话在**组合期**未读到开关与白名单（配置改动只对新会话生效）：**新建会话**重试，必要时重启 dsh 兜底；**不要判定工具损坏** |
| team 成员创建失败 / 长时间无进展 / **成员上限达限**（`Team member limit 8 reached`） | `interrupt_agent` 中断或重建；无法恢复则**降级 subagent** 完成该任务，并把降级与原因写入留痕 |
| 验证需真实密钥而凭据缺失 | 以明确报错失败（如提示缺少参数），**不静默跳过、不伪造结果**；密钥只经参数/环境变量传入进程（第十节红线） |
| 需要宿主操作（重启容器兜底、skctl、推送、装依赖） | 给出确切命令交给用户执行，**本 skill 不代劳** |

> 注：红线级条目（绝不副作用创建 `openspec/`、不在用户审核确认前提交实现改动、不静默把待决项变假设、不提交未过验证内容、`DELEGATED_CALLER` 是平台设计不是故障、`auto` 硬停四条件、真实密钥只经参数、分仓提交）留在 SKILL.md 第十节，不在此文件。
