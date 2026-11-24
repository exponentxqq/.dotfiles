# Spec Delta

## ADDED Requirements

### Requirement: 执行期路由快照

执行半程 SHALL 在阶段开工时解析执行侧路由（`--model` 覆盖 > 共用映射文件 `dsh/spec-workflow.yaml` > 继承会话模型），并写入 `/tmp/spec-flow/<change>/routing.md` 路由快照；快照 SHALL 含 `apply`、`apply_fallback`、`vision`、`verify`、`engine`、`parallelism`、来源与 history，SHALL 声明映射文件为唯一权威、自身为本次运行已解析副本，SHALL NOT 写死任何具体模型值。回退、读图改道或 `--model` 变更 SHALL 先更新快照再重派；快照缺失 SHALL 由当前半程重建后再派发。

#### Scenario: 阶段开工写路由快照

- **WHEN** spec-apply 进入执行且执行侧路由可解析
- **THEN** 先写 `/tmp/spec-flow/<change>/routing.md`，后续派发参数取自该快照

#### Scenario: 回退或读图改道更新快照

- **WHEN** 主路由不可用走 `fallback`、映射为空走继承、或任务需读图改道 `vision`
- **THEN** 先更新快照 `apply`（或对应键）并记 source 与 history，再按新值派发

### Requirement: 执行派发的显式路由与子代理自证

执行任务子代理派发 SHALL 显式传 `provider`/`model`（快照值为 `inherit` 时除外），提示 SHALL 含路由键（`apply`，读图任务 `vision`）与快照路径。子代理 SHALL 在开工检查点读快照本任务键并与系统提示声明的模型名比对：一致或 `inherit` SHALL 继续并以回执首行 `ROUTE-ACK` 自证；不一致 SHALL 停手（不写文件、不 git 操作）并以回执首行 `ROUTE-MISMATCH` 报告、同步上行 `异`；快照缺失 SHALL 以 `ROUTE-LEGACY` 继续且 SHALL NOT 视为故障；快照存在但本键缺失 SHALL 停手并以 `ROUTE-MISSING` 报告。

#### Scenario: 压缩后从快照重建路由

- **WHEN** 执行期压缩上下文后由子代理消息或用户「继续」触发新一轮
- **THEN** 后续派发按快照路由显式传递 `provider`/`model`，不继承主会话模型

#### Scenario: 子代理自证失配停手

- **WHEN** 执行子代理的系统提示模型名与快照本任务路由的模型不一致
- **THEN** 停手不写文件，回执首行写 `ROUTE-MISMATCH` 并上行 `异`，不得静默继续

#### Scenario: 省略路由字段被自证拦截

- **WHEN** 主会话派发执行子代理时遗漏 `provider`/`model` 且快照存在
- **THEN** 子代理按快照比对自身模型并停手报告，不得以继承模型继续执行

#### Scenario: 旧台账与无快照降级

- **WHEN** 登记簿为 v3 或 `routing.md` 不存在
- **THEN** 子代理以 `ROUTE-LEGACY` 放行并在回执注明，不阻断在途变更

### Requirement: 登记簿 v4 路由审计与漂移处置

执行半程登记簿 SHALL 升 v4：每行新增 `route=<provider>/<model>|inherit` 审计字段；`inherit` SHALL 仅用于映射为空或三档回退②并记原因；`reason` SHALL 可承载 `ROUTE-DRIFT actual=<模型>`。主会话 SHALL 在组收尾核对回执首行与登记行 `route`；发生漂移 SHALL 留痕并修正后续派发，SHALL NOT 因此重跑验证句与 diff 已核对通过的任务（用户另有指示除外）。v3 登记簿与无快照路径 SHALL 视为 legacy，SHALL NOT 阻断在途变更。

#### Scenario: 组收尾核对回执自证

- **WHEN** 本批任务回执到达
- **THEN** 主会话比对回执首行 `ROUTE-ACK`/`ROUTE-MISMATCH` 与登记行 `route`，失配按失败模式处置

#### Scenario: 漂移不重跑已合格任务

- **WHEN** 回执显示路由漂移但该任务的验证句与 diff 已独立核对通过
- **THEN** 该行以 `ROUTE-DRIFT actual=<模型>` 留痕后勾选，不重跑；漂移窗口在呈证报告

#### Scenario: inherit 仅限回退②

- **WHEN** 登记行出现 `route=inherit`
- **THEN** 该行原因须为映射为空或三档回退②，否则视为登记违规并修正
