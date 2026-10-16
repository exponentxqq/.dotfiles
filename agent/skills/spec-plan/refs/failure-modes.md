> 本文件为 SKILL.md §九「边界与失败」的外移正文，回入口引用写『SKILL.md 第 X 节』

## 九、边界与失败（处置表主体）
| 情形 | 处置 |
| --- | --- |
| `/spec-plan` 命令或 `spec-plan` skill 不可见 | **通常无需重启**——聚合层（宿主 `/home/xuqinqin/.local/share/agent-skills/skills`）是容器内 `/home/docker/.agents/skills` 的**只读 bind mount 实时视图**，宿主侧新增/更新条目立即可见，运行中的会话即可按名加载 skill；命令侧由插件热加载（监听用户级命令目录 + 事件防抖重扫）。处置顺序：①**核对登记**：命令 symlink 应为 `~/.dsh/commands/spec-plan.md` 指向 `dsh/commands/spec-plan.md`，缺失则容器内 `mkdir -p ~/.dsh/commands && ln -sfn /home/xuqinqin/develop/dotfiles/dsh/commands/spec-plan.md ~/.dsh/commands/spec-plan.md`；skctl 登记则须确认聚合层含该条目——**skctl 聚合层在 dsh 容器内不可见**，`node /home/xuqinqin/develop/dotfiles/tools/skctl/src/cli.ts install /home/xuqinqin/develop/dotfiles/agent/skills/spec-plan` 须在宿主或经 node 容器执行（宿主操作，由用户执行）；②在会话内执行内置 **`/commands-reload`** 手动重扫；③仍不可见才兜底 `cd ~/develop/docker && docker compose restart dsh`（宿主操作，由用户执行） |
| `openspec-propose` skill 加载失败 | 同上核对聚合层；先 `/commands-reload`，重启兜底；本 skill 不代替 `openspec-propose` 的落档行为 |
| `grill-me` skill 不可加载（阶段 1.5 问答环节） | 报告并**降级为普通按轮提问**（仍守「只问前置已定项、每轮 ≤5 问、每题附推荐答案、事实自行查证」），同时**如实告知用户已降级**；随后按上一行**先核对聚合层与 `/commands-reload`，重启兜底** |
| 某条规划线失败（产物缺失 / 为空 / 答非所问 / 与另一线雷同） | **重派一次**；仍失败**如实报告**，由**用户决定**是否降级为串行重做该线（第四节），**不得静默降级**；**设计线（阶段 1.7）同构处置**：产物缺失 / 字段残缺 / 答非所问 → **重派一次** → 仍失败**如实报告**由用户裁决 |
| 栈识别未命中 writer skill（阶段 1.7 派发前） | **问用户三选一**：①指认现有 writer skill（可点名任一聚合层 skill）／②明确豁免本次加载并**如实标注**（仅本次有效）／③终止流程；**不静默跳过**、不自行假设 |
| 栈对应 writer skill 加载失败（派发前核对或子代理回执） | 按 `openspec-propose` 加载失败同款顺序修复（核对聚合层与登记 → `/commands-reload` → 重启兜底），仍失败则**报告问用户**；**不静默降级**（「必须」级，区别于 `grill-me` 降级） |
| 显式模型路由不在**白名单**（报 `is not allowed for this Session`） | 按第八节**三档回退**：先 `fallback` 重派一次 → 再无则回退继承会话模型 → 仍失败报告并暂停（**不反复重试**） |
| 子代理需读图而阶段路由不支持图片（报 `does not declare image input`） | 改用 `vision` 路由重新派发（第八节）；该错误是能力事实，**不重试原路由** |
| 旧会话报 `child model selection is disabled for this tool instance` | 该会话在**组合期**未读到开关与白名单（配置改动只对新会话生效）：**新建会话**重试，必要时重启 dsh 兜底；**不要判定工具损坏** |
| 用户中断（说停、切换话题、新指令） | 立即停在安全检查点；未落盘材料与未提交工件保持原状并汇报位置（`/tmp/spec-flow/<change>/` 有哪些、四件套到哪一步），不擅自 stash / revert / 补提交；重进按入口「压缩后恢复速查」重建 |
| 需要宿主操作（重启容器兜底、skctl、推送） | 给出确切命令交给用户执行，**本 skill 不代劳** |

> 注：红线级条目（绝不副作用创建 `openspec/`、不静默把待决项变假设、`DELEGATED_CALLER` 是平台设计不是故障、工件未过 `--strict` 校验不提交）留在 SKILL.md 第九节，不在此文件。
