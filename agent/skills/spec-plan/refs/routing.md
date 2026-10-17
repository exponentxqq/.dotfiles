> 本文件为 SKILL.md §八「模型路由」的外移正文，回入口引用写「SKILL.md 第八节」。

## 八、模型路由（规划键）

映射文件：**`/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml`**（宿主与容器同形的**绝对**路径；dsh 容器内 `~` 解析为 `/home/docker`，**不要**写 `~/develop/...`），schema：

```yaml
models:                       # 规划键：lineA | lineB | panel | design；能力键：vision
  lineA: { provider: zai-coding-cn, model: glm-5.3 }        # 值：{ provider, model }
  design: { provider: zai-coding-cn, model: glm-5.3 }       # 设计线（阶段 1.7 代码设计子代理）
  vision: { provider: zai-coding-cn, model: glm-5.3-flash } # 读图覆盖路由（能力键，非阶段键）
engine: subagent    # 由 spec-apply 消费，本 skill 不读
parallelism: 8      # 落档分组上限（SKILL.md 第七节②）消费此键
```

**优先级：命令行 `--model <阶段>=<provider>/<模型>` > 映射文件 `models` > 继承会话模型。** `--model` 只覆盖主路由，`fallback` 只能写在文件里。

| 键 | 应用点 |
| --- | --- |
| `lineA` | 阶段 1 A 线规划派发——**仅 subagent 派发时应用**（team 编排下不应用；串行单线不消费） |
| `lineB` | 阶段 1 B 线规划派发——适用范围同 `lineA` |
| `panel` | 阶段 1.5 分歧复算子代理（第三条线，仅存在需复算的分歧时派发；恒为 subagent，不受编排影响） |
| `design` | 阶段 1.7 代码设计子代理（恒派 fresh 子代理，深度契约见 [planning.md](planning.md)；恒为 subagent，不受编排影响） |
| `vision` | **读图覆盖（能力键，不改变阶段划分）**：某阶段子代理需要图片输入（截图、设计稿、渲染结果、fixture 图片）而**该阶段路由不支持图片**时，忽略阶段路由、改用本键派发；阶段路由本身支持图片时保持阶段路由 |

**编排适用性速查**：路由**仅适用于 subagent 派发**——并行 team 成员无模型参数（`lineA`/`lineB` 不应用，映射值忽略并留痕告知）；串行单线无派发（规划键不消费）；`panel`/`design` 恒为 subagent 派发，不受编排影响；显式 `--model lineA|lineB` 覆盖 → 该线以 subagent 派发兑现路由（不静默丢弃显式覆盖）。

> 执行键 `apply`、`engine`/`parallelism` 由 **spec-apply** 消费，`verify` 由 **spec-done** 复用；本 skill 只读规划键、`vision` 与 `parallelism`（分组上限）。四段共用同一映射文件与白名单。

**图片输入能力**（出处：dsh 内置 pi-ai provider 数据 `…/pi-ai/dist/providers/data/{zai,opencode-go,deepseek}.json` 的 `input` 字段；改白名单时同步核对）：

| 路由 | 图片输入 | 说明 |
| --- | --- | --- |
| `zai-coding-cn/glm-5.3` | **不支持**（`input: ["text"]`） | 规划三线与设计线默认路由；**读图任务必须改走 `vision`** |
| `zai-coding-cn/glm-5.3-flash` | 支持（`["text","image"]`） | `vision` 键 |
| `opencode-go/deepseek-v4.1-flash` | 支持 | 执行侧主路由（spec-apply 消费） |
| `opencode-go/deepseek-v4-pro` | 不支持 | 备用（未启用） |
| `deepseek-official/deepseek-flash` | 支持 | 执行侧备用路由（spec-apply 消费） |

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
- **只有 fresh 子代理支持模型选择**（`subagent` 的 `provider` / `model` 字段）；`subagent_fork` 与 `spawn_teammate` 均不支持模型选择（fork 保持与父会话一致以复用 KV cache；team 成员锁定 Lead 模型）——需要阶段路由时**不要用 fork**；team 编排下 `lineA`/`lineB` 不应用（同 spec-apply team 引擎忽略 `apply` 键先例），显式 `--model lineA|lineB` 覆盖的线改以 subagent 派发兑现路由。
- **开关与白名单在会话创建时读取**：改动 profile 配置后**新建会话**即生效（实测无需重启 dsh）；**既有会话不会中途获得该能力**——在旧会话里派发会报 `child model selection is disabled for this tool instance`，那是「该会话未生效」而非工具损坏，换新会话即可。
- **主会话阶段（落档）的模型由用户自行切换**，本 skill 只提示；本 skill 无法修改主会话模型。
- 映射文件缺失、读不到或 YAML 非法 → 视为空映射（全部继承），报告一次后继续。
- 参数语法错误（阶段名非法、缺 `provider/model`）→ 报错并列出合法键（含 `vision`），要求更正后重发，不猜。

> 注：入口 SKILL.md 第八节保留摘要段（规划键 + 三档回退顺序 + vision 要点）；展开细节以本文件为唯一权威源（防双源漂移）。
