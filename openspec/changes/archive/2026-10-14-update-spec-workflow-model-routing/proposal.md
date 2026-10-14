# Proposal

## Why

`dsh/spec-workflow.yaml` 此前是空映射（`models: {}`，示例全被注释），阶段级模型路由实际未启用；且映射文件的 schema 只支持「一个阶段一条路由」，无法表达用户明确提出的两类需求：

1. **执行阶段要有备用模型**——主用 `opencode-go/deepseek-v4.1-flash`，出问题（provider 报错、模型不可用、限流、路由不在白名单）时换 `deepseek-official/deepseek-flash` 顶上；
2. **读图要用能看图的模型**——规划三线默认的 `zai/glm-5.3` **不支持图片输入**（实测报 `model "glm-5.3" does not declare image input`），一旦规划线要看截图/设计稿/渲染结果就会硬失败。

映射文件没有这些语义，工作流本体（SKILL.md 第十一节）也就不会按它们派发——只改 YAML 等于写了没人读的配置。故本变更同时落地**配置**与**它被工作流遵守的规则**，并同步主规格。

## What Changes

- 把 `dsh/spec-workflow.yaml` 配成实际路由：规划三线（`lineA` / `lineB` / `panel`）→ `zai/glm-5.3`；执行与验证（`apply` / `verify`）→ `opencode-go/deepseek-v4.1-flash`，备用 `deepseek-official/deepseek-flash`；`vision` → `zai/glm-5.3-flash`
- 映射文件 schema 扩展：每条路由支持可选 `fallback: { provider, model }`；新增能力键 `vision`（读图覆盖路由，不改变阶段划分）
- SKILL.md 第十一节重写：优先级（`--model` > 映射 > 会话继承）、六键应用点表、**图片输入能力表**（含出处）、**三档回退**（`fallback` → 会话继承 → 报告暂停，不反复重试）、**会话创建期生效**（改配置后新建会话即生效，旧会话报 `child model selection is disabled for this tool instance`）、白名单自检命令；第二、四、八、十二节补相应指针与处置行
- `dsh/README.md` 阶段模型路由章节同步（现状配置、`fallback`、`vision`、能力表、三档回退、生效时机）
- 主规格 `openspec/specs/spec-workflow/spec.md` 的「阶段级模型路由」Requirement 同步（归档时）
- 不改动 dsh 内核、插件与 profile 白名单（`cordis.patch.yml` 的五条 `allowedModels` 已覆盖本次全部路由，无需新增）

## Capabilities

### New Capabilities

（无）

### Modified Capabilities

- `spec-workflow`: 「阶段级模型路由」Requirement 扩展——路由支持 `fallback`、新增 `vision` 读图覆盖键、显式路由不在白名单或 provider 失败时按固定三档顺序回退

## Impact

- **修改**：`dsh/spec-workflow.yaml`（配置实体）、`agent/skills/spec-workflow/SKILL.md`（§二 / §四 / §八 / §十一 / §十二）、`dsh/README.md`、主规格 `openspec/specs/spec-workflow/spec.md`（归档同步）
- **不改**：`dsh/profiles/web/cordis.patch.yml`（五条白名单已够用：`zai/glm-5.3`、`zai/glm-5.3-flash`、`opencode-go/deepseek-v4.1-flash`、`opencode-go/deepseek-v4-pro`、`deepseek-official/deepseek-flash`）
- **宿主环境**：无需任何宿主操作、无需重启 dsh——模型选择开关与白名单在**会话创建时**读取，新建会话即生效（本次已实测，见 design 事实 4）
- **依赖**：dsh subagent 模型选择（已开启）、pi-ai provider 数据（图片输入能力的判定依据）
- **风险**：规划三线未装备用路由（用户未要求）——`zai` 整家不可用时规划阶段会停住等用户处置；`deepseek-v4.1-flash` 与备用 `deepseek-flash` 同族，属降级而非异构，异构复核仍由主会话与第三线复算承担
