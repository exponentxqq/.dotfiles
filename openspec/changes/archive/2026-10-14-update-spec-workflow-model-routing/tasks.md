# Tasks

## 1. 配置与语义落地

- [x] 1.1 改写 `dsh/spec-workflow.yaml`：`models` 配成六键实际路由（`lineA`/`lineB`/`panel` → `zai/glm-5.3`；`apply`/`verify` → `opencode-go/deepseek-v4.1-flash` 且 `fallback` → `deepseek-official/deepseek-flash`；`vision` → `zai/glm-5.3-flash`），保留 `engine: subagent` 与 `parallelism: 3`，注释写明白名单约束、`fallback` 语义与未在白名单时的错误码；验证：第十一节自检命令退出码 0，输出「映射(8)」且末行为 `OK 全部路由 ⊆ 白名单`
- [x] 1.2 重写 SKILL.md 第十一节并补指针：schema 示例含 `fallback` 与 `vision`、优先级、六键应用点表、**图片输入能力表（含 pi-ai provider 数据出处）**、`does not declare image input` 错误码、**三档回退**（fallback → 会话继承 → 报告暂停）、**会话创建期生效**（`child model selection is disabled for this tool instance` 的处置）、白名单自检命令；§二 增「5. 路由自检」；§四 A/B 线派发句与 §八 `apply` 派发句补「需读图时改用 `vision`」；§十二 边界表增「不在白名单三档回退」「读图能力错误改路由」「旧会话未生效新建会话」三行；验证：`grep -c` 命中 `fallback`、`vision`、`三档回退`、`does not declare image input`、`child model selection is disabled for this tool instance`、`路由自检` 六个关键词且 §十二 表含对应三行
- [x] 1.3 同步 `dsh/README.md` 阶段模型路由章节：schema 示例、仓库现状配置、六键表（含 `vision` 行）、图片能力表与错误码、三档回退、白名单一致性与**生效时机**；验证：章节内 `grep` 命中 `vision`、`fallback`、`deepseek-v4.1-flash`、`does not declare image input`、`会话创建时` 五个关键词

## 2. 校验与实测

- [x] 2.1 变更校验：`openspec validate update-spec-workflow-model-routing --strict` 退出码 0（无 error/warning）；验证：命令退出码 0 且输出含 valid 语义
- [x] 2.2 配置层核对：`dsh --profile web --dump-config` 中 `subagent-model-selection-settings` 行为 `enabled: true` + 五条 `allowedModels`（含 `zai/glm-5.3-flash` 与 `deepseek-official/deepseek-flash`）；验证：`grep -A 14` 输出含五个 `provider:` 行且无新增 error/warning（`--dump-config-schema` 与开工前基线逐条一致）
- [x] 2.3 端到端实测（**新会话，不重启 dsh**）：并行派发四个显式路由子代理并逐个核对回复原文——`opencode-go/deepseek-v4.1-flash` → `EXEC-PRIMARY-run-ok`；`deepseek-official/deepseek-flash` → `EXEC-BACKUP-run-ok`；`zai/glm-5.3-flash` 读图 → `蓝/白/红`（真值由主会话 `read_image` 核对）；`zai/glm-5.3` 读图 → 原样返回 `does not declare image input` 错误；验证：四项结果与本文件记录逐字一致，会话名与时间戳记入 design 事实 4

## 3. 归档

- [x] 3.1 归档本变更并同步主规格（`openspec-archive-change`）：归档目录落在 `openspec/changes/archive/2026-10-14-update-spec-workflow-model-routing/`（`archivedAs` 同名、`specsUpdated: true`、modified 1），主规格「阶段级模型路由」Requirement 更新为含 `fallback` 与 `vision` 的版本——**归档后 strict 校验暴露需求段 >500 字符 warning，已按 design 决策 7 拆为「阶段级模型路由」与「读图覆盖与路由回退」两条并同步修正归档 delta**；验证：`openspec list --json` 活跃变更为 0 ✓；`grep -c 'fallback\|vision' openspec/specs/spec-workflow/spec.md` = 6 ≥ 4 ✓；`openspec validate --specs --strict` = 1 passed / 0 failed ✓；归档 delta 临时移回后 `openspec validate <name> --strict` = valid ✓
