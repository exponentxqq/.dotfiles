# Spec Delta

## MODIFIED Requirements

### Requirement: 收尾入口与三方重建

spec-done SHALL 承载终末半程:验证归档与收尾闭环一体化。入口 SHALL 先判归档状态——变更未归档 SHALL 先跑「验证门与归档执行」链再进收尾,已归档 SHALL 直接进入三方重建。三方重建 SHALL 对照三源:①归档 design.md 执行环境块 ②`git worktree list` 实际 ③fetch 后分支与合并事实(origin 主分支是否已含 `feature/<change>` 提交、`git branch -d` 能否安全放行)——输出每仓收尾进度摘要(未推送 / 已推送未合并 / 已合并未清理 worktree / 已合并未清分支),从每仓第一个未完成步继续;闭环 SHALL 按仓独立推进,SHALL NOT 设全体屏障。执行环境块 schema SHALL 以 spec-workflow 的 worktree 手册为唯一权威源,spec-done SHALL 只引用不复制;块缺失 SHALL 按非隔离轻量收尾处理并如实告知,SHALL NOT 假设曾隔离。

#### Scenario: 未归档拒绝入口

- **WHEN** `/spec-done <变更名>` 指向的变更仍在 active 列表且任务未全部完成
- **THEN** 拒绝收尾入口,提示先经 spec-apply 完成执行,不代跑执行不代归档

#### Scenario: 未归档先补归档链

- **WHEN** `/spec-done <变更名>` 指向的变更仍在 active 列表但任务已全部完成
- **THEN** 先跑验证门与归档执行链,归档后再进收尾,不拒绝入口也不跳过归档

#### Scenario: 三方重建输出进度摘要

- **WHEN** 收尾发起且归档状态确认
- **THEN** 按三源对照输出每仓四态进度摘要(未推送/已推送未合并/已合并未清理 worktree/已合并未清分支),从每仓第一个未完成步继续,按仓独立推进

#### Scenario: 执行环境块缺失按非隔离处理

- **WHEN** 归档 design.md 决策记录无执行环境块
- **THEN** 按非隔离轻量收尾处理并如实告知,不假设曾隔离

## ADDED Requirements

### Requirement: 验证门与归档执行

变更全部任务完成后,spec-done SHALL 先执行项目声明的验证(干净窗口);验证通过后、归档前 SHALL 加载 `openspec-verify-change` 做完整性校验(任务全部勾选、spec 覆盖映射、design 一致性),发现缺漏 SHALL 先修复并重新校验;校验通过 SHALL 才归档(`openspec-archive-change` 归档并同步主规格),归档 SHALL 单独提交一次(报错贴原文并停,SHALL NOT 手工搬移目录);验证失败 SHALL NOT 归档(报告证据;问用户修复或显式批准跳过并记已知缺口)。归档链触发 SHALL 两途:编排层在执行半程完成后自动委托,或用户以 `/spec-done <变更名>` 独立发起。

#### Scenario: 验证失败不归档

- **WHEN** 归档前验证失败
- **THEN** 不归档,报告失败并等待用户决定跳过或修复

#### Scenario: verify-change 拦截勾选遗漏

- **WHEN** 归档前校验发现已入库任务存在勾选遗漏或缺漏的 spec 覆盖
- **THEN** 先补核对勾选(或补 delta)并重新校验,通过后才归档,不绕过校验归档

#### Scenario: 归档单独提交一次

- **WHEN** 归档动作完成
- **THEN** 归档变更单独形成一次提交,与实现批次提交分离;archive 报错贴原文并停,不手工搬移目录

#### Scenario: 独立发起补跑归档链

- **WHEN** 执行半程全部完成后用户调用 `/spec-done <变更名>` 而变更尚未归档
- **THEN** spec-done 直接收口归档链,不再回到执行半程

### Requirement: 归档汇报与收尾停留

归档提交完成后,spec-done SHALL 输出六要素汇报——工件路径、验证证据、归档位置与主规格、宿主操作清单、沉淀回流清单(执行期改动的工作流仓文件,已提交项标注去向、未提交项交用户决定)、遗留待办(worktree 闭环清单及 `/spec-done` 入口、执行期临时偏离恢复点、预留编号)——并 SHALL 停留等待用户决定收尾时机,SHALL NOT 自动进入推送、合并或清理;后续收尾(rebase、推送、合并确认、worktree 与分支清理)SHALL 按收尾既有 Requirement 推进。

#### Scenario: 六要素汇报后停留

- **WHEN** 归档提交完成输出汇报
- **THEN** 汇报含六要素,流程停留等待用户决定收尾时机,不自动推送或清理

#### Scenario: 编排层委托归档链

- **WHEN** 执行半程(spec-apply)全部批次完成且经用户审核提交
- **THEN** 编排层自动委托 spec-done 收口归档链,全流程体验不变

#### Scenario: 汇报遗留待办指明收尾入口

- **WHEN** 归档汇报输出遗留待办
- **THEN** 含 worktree 闭环清单(注明 `/spec-done <变更名>` 入口)、临时偏离恢复点、预留编号,交用户决定收尾时机
