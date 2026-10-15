> 本文件为 SKILL.md §十一的外移正文，回入口引用写『SKILL.md 第 X 节』

## 十一、模型路由

映射文件：**`/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml`**（宿主与容器同形的**绝对**路径；dsh 容器内 `~` 解析为 `/home/docker`，**不要**写 `~/develop/...`），schema：

```yaml
models:                       # 键：lineA | lineB | panel | design | apply | verify | vision
  lineA: { provider: zai, model: glm-5.3 }        # 值：{ provider, model }
  design: { provider: zai, model: glm-5.3 }       # 设计线（阶段 1.7 代码设计子代理）
  apply:                                          # 可选：fallback: { provider, model }
    provider: opencode-go
    model: deepseek-v4.1-flash
    fallback: { provider: deepseek-official, model: deepseek-flash }
  vision: { provider: zai, model: glm-5.3-flash } # 读图覆盖路由（能力键，非阶段键）
engine: subagent    # subagent | team
parallelism: 3      # 同组并行上限
```

**优先级：命令行 `--model <阶段>=<provider>/<模型>` > 映射文件 `models` > 继承会话模型。** `--model` 只覆盖主路由，`fallback` 只能写在文件里。

| 键 | 应用点 |
| --- | --- |
| `lineA` | 阶段 1 A 线规划子代理（需求与价值、范围与边界） |
| `lineB` | 阶段 1 B 线规划子代理（实现与约束、反例与风险） |
| `panel` | 阶段 1.5 分歧复算子代理（第三条线，仅存在需复算的分歧时派发） |
| `design` | 阶段 1.7 代码设计子代理（恒派 fresh 子代理，深度契约见 [planning.md](planning.md)） |
| `apply` | 阶段 3 执行任务子代理（仅 subagent 引擎） |
| `verify` | 阶段 4 归档前验证子代理 |
| `vision` | **读图覆盖（能力键，不改变阶段划分）**：某阶段子代理需要图片输入（截图、设计稿、渲染结果、fixture 图片）而**该阶段路由不支持图片**时，忽略阶段路由、改用本键派发；阶段路由本身支持图片时保持阶段路由 |

**图片输入能力**（出处：dsh 内置 pi-ai provider 数据 `…/pi-ai/dist/providers/data/{zai,opencode-go,deepseek}.json` 的 `input` 字段；改白名单时同步核对）：

| 路由 | 图片输入 | 说明 |
| --- | --- | --- |
| `zai/glm-5.3` | **不支持**（`input: ["text"]`） | 规划三线与设计线默认路由；**读图任务必须改走 `vision`** |
| `zai/glm-5.3-flash` | 支持（`["text","image"]`） | `vision` 键 |
| `opencode-go/deepseek-v4.1-flash` | 支持 | `apply` / `verify` 主路由 |
| `opencode-go/deepseek-v4-pro` | 不支持 | 备用（未启用） |
| `deepseek-official/deepseek-flash` | 支持 | `apply` / `verify` 备用路由 |

不支持图片的路由遇到读图会报 `model "<model>" does not declare image input; switch to an image-capable model to read images`——这是**能力事实不是工具故障**：不要重试，改走 `vision` 路由。

**路由自检**（派发前可选；退出码非 0 = 有路由不在白名单）：

```bash
node -e '
const fs=require("fs"),YAML=require("/home/xuqinqin/develop/dotfiles/opencode/node_modules/yaml");
const d="/home/xuqinqin/develop/dotfiles/dsh/";
const m=YAML.parse(fs.readFileSync(d+"spec-workflow.yaml","utf8"));
const wl=[...fs.readFileSync(d+"profiles/web/cordis.patch.yml","utf8").matchAll(/-\s*\{\s*provider:\s*([\w.\-]+),\s*model:\s*([\w.\-]+)\s*\}/g)].map(x=>x[1]+"/"+x[2]);
const rs=Object.entries(m.models||{}).flatMap(([k,v])=>[[k,v.provider+"/"+v.model],...(v.fallback?[[k+".fallback",v.fallback.provider+"/"+v.fallback.model]]:[])]);
const bad=rs.filter(([,r])=>!wl.includes(r));
console.log("白名单:",wl.join(" "));console.log("映射:",rs.map(([k,r])=>k+"="+r).join(" "));
if(bad.length){console.error("不在白名单:",bad.map(([k,r])=>k+"="+r).join(" "));process.exit(1)}
console.log("OK 全部路由 ⊆ 白名单");'
```

硬约束：

- **白名单**：显式路由（含 `fallback`）必须已在 profile 的 `subagent-model-selection-settings`（`dsh/profiles/web/cordis.patch.yml` 中的 `allowedModels`）内；映射文件的键值必须始终是该**白名单**的子集。
- **三档回退（顺序固定，不反复重试同一路由）**：① 有 `fallback` → 用**备用路由重派一次**；② 无 `fallback` 或备用也失败 → **回退继承会话模型**派发一次；③ 仍失败 → 报告该路由与错误原文并暂停。触发条件：`child LLM route "<provider>/<model>" is not allowed for this Session`（不在白名单）、provider 报错、模型不可用或限流。提示用户改映射文件或把该路由加进白名单（后者属于宿主操作）。
- **只有 fresh 子代理支持模型选择**（`subagent` 的 `provider` / `model` 字段）；`subagent_fork` 不支持模型选择（保持与父会话一致以复用 KV cache），需要阶段路由时**不要用 fork**。
- **开关与白名单在会话创建时读取**：改动 profile 配置后**新建会话**即生效（实测无需重启 dsh）；**既有会话不会中途获得该能力**——在旧会话里派发会报 `child model selection is disabled for this tool instance`，那是「该会话未生效」而非工具损坏，换新会话即可。
- `team` 引擎**忽略 `apply` 键，阶段级模型路由整体不适用**（teammate 创建无模型参数）。
- **主会话阶段（落档、归档）的模型由用户自行切换**，本 skill 只在衔接点提示（第七节）；本 skill 无法修改主会话模型。
- 映射文件缺失、读不到或 YAML 非法 → 视为空映射（全部继承），报告一次后继续。
- 参数语法错误（阶段名非法、缺 `provider/model`）→ 报错并列出合法键（含 `vision`），要求更正后重发，不猜。

> 注：入口 SKILL.md 第十一节保留摘要段（路由键表 + 三档回退顺序 + vision 要点）；展开细节以本文件为唯一权威源（防双源漂移）。
