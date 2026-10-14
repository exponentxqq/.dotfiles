# Design

## 背景与已核实事实

1. **旧 schema 的表达力不足**：`dsh/spec-workflow.yaml` 原为 `models: {}`，SKILL.md 第十一节只描述「键 lineA|lineB|panel|apply|verify；值 { provider, model }」，没有备用路由与读图覆盖的位置——用户提出的「执行备用模型」与「需要视觉模型时换 flash」两类需求无法表达。
2. **图片输入能力来自 provider 数据（可查证）**：dsh 内置 pi-ai 的 provider 数据 `…/pi-ai/dist/providers/data/{zai,opencode-go,deepseek}.json` 每条模型带 `input` 字段。本变更涉及的五条白名单路由实测取值：

   | 路由 | `input` |
   | --- | --- |
   | `zai/glm-5.3` | `["text"]` |
   | `zai/glm-5.3-flash` | `["text","image"]` |
   | `opencode-go/deepseek-v4.1-flash` | `["text","image"]` |
   | `opencode-go/deepseek-v4-pro` | `["text"]` |
   | `deepseek-official/deepseek-flash` | `["text","image"]` |

   `list_subagent_models` 工具只返回 name/description/reasoning efforts，**不返回图片输入能力**，故能力表必须写进 SKILL.md（出处见上）。
3. **实测：不支持图片的路由读图会硬失败**（新会话，未重启 dsh，工作区 `os`）：向 `zai/glm-5.3` 子代理派发读图任务，返回原文 `Error: cannot read "/tmp/spec-flow/vision-probe/stripes.png" as an image: model "glm-5.3" does not declare image input; switch to an image-capable model to read images`。同一张图（自造 PNG，纯 python 写 zlib+CRC，内容为蓝/白/红三条竖条，`read_image` 人工核对为真值）交给 `zai/glm-5.3-flash` 子代理识别，作答 **`蓝/白/红`**——正确。故「读图换 `vision`」不是猜测，是实测结论。
4. **实测：开关与白名单在会话创建时读取，改配置无需重启**：同一会话（GUI，工作区 `os`，会话名「并行派发4个子代理做只读探测」，15:00–15:02）内并行派发四个显式路由子代理，全部成功：

   | provider/model | 子代理最终回复原文 |
   | --- | --- |
   | `opencode-go` / `deepseek-v4.1-flash` | `EXEC-PRIMARY-run-ok` |
   | `deepseek-official` / `deepseek-flash` | `EXEC-BACKUP-run-ok` |
   | `zai` / `glm-5.3-flash` | `蓝/白/红` |
   | `zai` / `glm-5.3` | 上述 `does not declare image input` 错误原文 |

   对照：本变更所在的长会话（早于白名单补丁创建）派发时报 `Error: child model selection is disabled for this tool instance`——同一进程内，**旧会话不生效、新建会话生效**。源码印证：`dsh-tool-subagent/model-selection-settings.js` 注释写明该服务是「Singleton settings owner read when delegation tools are composed for a Session」，`current()` 返回「selection preference for the next eligible Session composition」。故文档口径是「**新建会话即生效，重启 dsh 仅兜底**」，而不是「改配置必重启」。
5. **白名单已够用**：`dsh/profiles/web/cordis.patch.yml` 的 `allowedModels` 五条已含本变更全部 8 条映射（5 个键 + 2 个 fallback + `vision`），本次**不必**改 profile。
6. **自检命令可跑通**：容器内 node 可 `require` 仓库自带的 `opencode/node_modules/yaml`；patch 文件含 `!!js` 标签（`yaml` 包整体解析会抛 tag 错），故自检用**文本正则**抽取 `- { provider: X, model: Y }` 形态的 `allowedModels` 行，与映射文件（用 YAML 正常解析）比对。实测输出：白名单 5 条、映射 8 条、`OK 全部路由 ⊆ 白名单`、退出码 0。

## 决策

1. **`fallback` 嵌在键内**（`apply.fallback`），不另设顶层 `fallbacks:` 段：一个阶段的主路由与备用路由应当在同一处读、一起改，避免两段配置漂移。
2. **`vision` 是能力键，不是阶段键**：读图需求横切阶段（规划线看设计稿、复算线看截图、验证看渲染结果），若做成阶段键会出现「阶段 × 能力」笛卡尔积（每个阶段都要配 vision 变体）。规则因此表述为——**该阶段路由不支持图片时忽略阶段路由、改用 `vision`；阶段路由本身支持图片（如执行侧 `deepseek-v4.1-flash`）则保持不动**。
3. **`verify` 归执行侧路由**（`opencode-go/deepseek-v4.1-flash` + 同款备用）：用户口径是「规划用强模型、执行用快模型」，而验证子代理在阶段 4 跑项目声明的验证命令、汇报证据，判断由主会话按 `tasks.md` 验证句与 diff 复核，属执行侧。若希望验证改为异构强模型复核，只需把 `verify` 一行改成 `{ provider: zai, model: glm-5.3 }`（同时应改用 `vision` 处理截图类验证）。
4. **三档回退顺序固定且不反复重试**：① 有 `fallback` → 备用路由重派一次；② 无 `fallback` 或备用也失败 → 回退继承会话模型一次；③ 仍失败 → 报告路由与错误原文并暂停。触发条件写成实测错误码：`child LLM route "…" is not allowed for this Session`（不在白名单）、provider 报错、模型不可用/限流。
5. **规划三线不加备用**：用户只指定了执行侧备用；给规划线静默加备用等于偷偷改变规划质量口径。副作用如实写进 proposal 的「风险」。
6. **不加 `reasoningEffort` 字段**：`llm-pi-ai` 已按 provider 设 `reasoningEffort: max`，`--model` 与映射只决定路由，避免多余配置面。

## 交付物与文件布局

| 文件 | 性质 | 说明 |
| --- | --- | --- |
| `dsh/spec-workflow.yaml` | 修改 | 六键路由 + 两个 fallback；注释含白名单约束与错误码 |
| `agent/skills/spec-workflow/SKILL.md` | 修改 | §十一 重写；§二 增「路由自检」；§四 / §八 增读图指针；§十二 增三行处置 |
| `dsh/README.md` | 修改 | 阶段模型路由章节同步 |
| 主规格 `openspec/specs/spec-workflow/spec.md` | 归档同步 | 「阶段级模型路由」Requirement 更新 |

## 验证方式

- 自检命令（映射 ⊆ 白名单）退出码 0，且打印 8 条映射与 5 条白名单
- `dsh --profile web --dump-config` 中 `subagent-model-selection-settings` 仍为 `enabled: true` + 五条 `allowedModels`
- 新会话（无需重启）四个显式路由子代理的可观察结果，与事实 3 / 4 的表逐条一致
- `openspec validate update-spec-workflow-model-routing --strict` 退出码 0
