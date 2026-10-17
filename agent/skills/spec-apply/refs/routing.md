> 本文件为 spec-apply SKILL.md 第五节（模型路由·执行侧）的展开正文；仅 subagent 引擎派发前读取。

## 五、模型路由（执行侧）

映射文件：**`/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml`**（宿主与容器同形的**绝对**路径；dsh 容器内 `~` 解析为 `/home/docker`，**不要**写 `~/develop/...`），schema：

```yaml
models:                       # 执行键：apply；verify 由 spec-done 复用；能力键：vision（规划键见下注）
  apply:                                          # 值：{ provider, model }
    provider: opencode-go
    model: deepseek-v4.1-flash
    fallback: { provider: deepseek-official, model: deepseek-flash }
  vision: { provider: zai-coding-cn, model: glm-5.3-flash } # 读图覆盖路由（能力键，非阶段键）
engine: subagent    # subagent | team（--engine 覆盖）
parallelism: 8      # 同组并行上限
```

**优先级：命令行 `--model <阶段>=<provider>/<模型>` > 映射文件 `models` > 继承会话模型。** `--model` 只覆盖主路由，`fallback` 只能写在文件里。

| 键 | 应用点 |
| --- | --- |
| `apply` | 阶段 3 执行任务子代理（仅 subagent 引擎） |
| `verify` | 阶段 4 归档前验证子代理；由 spec-done 复用（终末验证与收尾复验），本文件仅注记执行侧视角 |
| `vision` | **读图覆盖（能力键，不改变阶段划分）**：某阶段子代理需要图片输入（截图、设计稿、渲染结果、fixture 图片）而**该阶段路由不支持图片**时，忽略阶段路由、改用本键派发；阶段路由本身支持图片时保持阶段路由 |

> **规划键归属**：`lineA` / `lineB` / `panel` / `design`（规划三线与设计线）由 **spec-plan** 消费（其 `refs/routing.md` 为该侧唯一权威源）；`--model` 参数中的规划键由编排层 **spec-workflow 原样转发** spec-plan，本 skill 不消费。四段共用同一映射文件与白名单。

**图片输入能力**（出处：dsh 内置 pi-ai provider 数据 `…/pi-ai/dist/providers/data/{zai,opencode-go,deepseek}.json` 的 `input` 字段；改白名单时同步核对）：

| 路由 | 图片输入 | 说明 |
| --- | --- | --- |
| `opencode-go/deepseek-v4.1-flash` | 支持 | `apply` / `verify` 主路由 |
| `opencode-go/deepseek-v4-pro` | 不支持 | 备用（未启用） |
| `deepseek-official/deepseek-flash` | 支持 | `apply` / `verify` 备用路由 |
| `zai-coding-cn/glm-5.3-flash` | 支持（`["text","image"]`） | `vision` 键 |
| `zai-coding-cn/glm-5.3` | **不支持**（`input: ["text"]`） | 规划侧默认路由（spec-plan 消费） |

不支持图片的路由遇到读图会报 `model "<model>" does not declare image input; switch to an image-capable model to read images`——这是**能力事实不是工具故障**：不要重试，改走 `vision` 路由。

**路由自检**（派发前可选；退出码非 0 = 有路由不在白名单；打印「跳过」= 依赖缺失未校验，**不等于通过**）：

```bash
node -e '
const fs=require("fs");
const d="/home/xuqinqin/develop/dotfiles/dsh/";
const cands=["yaml","/usr/local/lib/node_modules/@deepseek-ai/dsh/node_modules/yaml",d+"../opencode/node_modules/yaml"];
let YAML=null;for(const c of cands){try{YAML=require(c);break}catch{}}
if(!YAML){console.log("缺 yaml 依赖：路由自检跳过（未校验，不等于通过）");process.exit(0)}
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
- **主会话阶段的模型由用户自行切换**，衔接点提示由编排层 spec-workflow 承载、终末提示由 spec-done 承载；本 skill 无法修改主会话模型。
- 映射文件缺失、读不到或 YAML 非法 → 视为空映射（全部继承），报告一次后继续。
- 参数语法错误（阶段名非法、缺 `provider/model`）→ 报错并列出合法键（含 `vision`），要求更正后重发，不猜。

> 注：入口 SKILL.md 第五节保留摘要段（执行键表 + 三档回退顺序 + vision 要点）；展开细节以本文件为唯一权威源（防双源漂移）。
