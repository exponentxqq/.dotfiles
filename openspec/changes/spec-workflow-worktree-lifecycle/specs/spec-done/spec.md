# Spec Delta

## ADDED Requirements

### Requirement: 收尾入口与三方重建

spec-done SHALL 以已归档变更为前提：未归档 SHALL 提示先经 spec-workflow 完成归档，SHALL NOT 代归档。入口后 SHALL 先做三方重建——对照 ①归档 design.md 执行环境块 ②`git worktree list` 实际 ③fetch 后分支与合并事实（origin 主分支是否已含 `feature/<change>` 提交、`git branch -d` 能否安全放行）——输出每仓收尾进度摘要（未推送 / 已推送未合并 / 已合并未清理 worktree / 已合并未清分支），并从每仓第一个未完成步继续；闭环 SHALL 按仓独立推进，SHALL NOT 设全体屏障。执行环境块 schema SHALL 以 spec-workflow 的 worktree 手册为唯一权威源，spec-done SHALL 只引用不复制；块缺失 SHALL 按非隔离轻量收尾处理并如实告知，SHALL NOT 假设曾隔离。

#### Scenario: 未归档拒绝入口

- **WHEN** `/spec-done <变更名>` 指向的变更仍在 active 列表未归档
- **THEN** 提示先经 spec-workflow 阶段 4 完成归档，不代归档不继续

#### Scenario: 三方重建输出进度摘要

- **WHEN** 收尾发起且前置检查通过
- **THEN** 按三源对照输出每仓四态进度摘要（未推送/已推送未合并/已合并未清理 worktree/已合并未清分支），从每仓第一个未完成步继续，按仓独立推进

#### Scenario: 执行环境块缺失按非隔离处理

- **WHEN** 归档 design.md 决策记录无执行环境块
- **THEN** 按非隔离轻量收尾处理并如实告知，不假设曾隔离

### Requirement: 收尾 rebase 与全量复验

隔离收尾每仓 SHALL 先在 worktree 内 fetch+rebase `origin/<主分支>`：冲突 SHALL `git rebase --abort` 回退并呈证（冲突文件清单、双方意图、建议解法），问用户三选一（授权代解/用户自解后继续/放弃 rebase），SHALL NOT 自行解冲突。rebase 改写全部提交链，其后 SHALL 全量复验——该仓全量测试（项目声明验证方式优先、干净窗口真实 executed 无 SKIPPED/FROM-CACHE），失败 SHALL 停下报告不带病推送；复验可派 `verify` 路由子代理。

#### Scenario: rebase 冲突 abort 呈证

- **WHEN** 收尾 rebase 撞冲突
- **THEN** abort 回退到 rebase 前状态，呈证冲突文件清单、双方意图与建议解法，问用户三选一（授权代解/用户自解/放弃 rebase），不自行解冲突

#### Scenario: rebase 后全量复验

- **WHEN** rebase 完成准备推送
- **THEN** 该仓全量测试在干净窗口真实执行（无 SKIPPED/FROM-CACHE），失败停下报告不带病推送

### Requirement: 收尾推送与合并确认

push SHALL 先探测推送能力（fetch 成功/`ssh -T` 认证通过）：可行 SHALL 按用户指示代推 `git push -u origin feature/<change>`；被拒（远端主分支又前进）SHALL fetch+rebase 一次后重试、仍拒报告；不可行 SHALL 给宿主命令并等回告，SHALL NOT 绕行换协议硬闯。平台 codereview 与合并 SHALL 由用户完成，spec-done SHALL 等回告，SHALL NOT 代做合并决策。收尾 SHALL 以根仓主分支推送（探测代推同口径）+ 闭环汇报（各仓提交链、rebase 复验证据、合并点、清理结果、遗留待办终态）结束。

#### Scenario: ssh 不可行回退宿主命令

- **WHEN** 推送能力探测失败（无 ssh/凭证）
- **THEN** 给出确切宿主命令并等用户回告，不绕行换协议硬闯；探测可行则按用户指示代推

### Requirement: worktree 删除与分支清理

删 worktree 的硬门槛 = 用户确认已推送+已合并；动作前 SHALL 以 fetch 后 git 事实复核合并（origin 主分支已含 feature 提交，非仅凭口述），且 `git status --porcelain` 确认 worktree 干净，才 `git worktree remove` 并复核未波及其他 worktree；脏 SHALL 停下呈证，SHALL NOT force。本地分支清理 SHALL 用 `git fetch origin && git branch -d feature/<change>`；`-d` 放行失败即未合并，SHALL 停下呈证不 `-D`。

#### Scenario: 合并确认与 git 复核后才删 worktree

- **WHEN** 用户回告已推送+已合并
- **THEN** 先 fetch 复核 origin 主分支已含 feature 提交，再确认 worktree 干净（status --porcelain 为空）才 `git worktree remove`，并复核未波及其他 worktree

#### Scenario: 脏 worktree 不删

- **WHEN** 删 worktree 前发现工作树有未提交改动
- **THEN** 停下呈证待用户裁决，不 force remove

#### Scenario: 分支安全清理

- **WHEN** worktree 已删、清理本地 feature 分支
- **THEN** `git fetch origin` 后用 `git branch -d`（安全删除）；放行失败即未合并，停下呈证不 `-D`

### Requirement: 本地环境收尾处置

删 worktree 硬门槛通过后、执行 remove 前，spec-done SHALL 处置本地环境：入库配置改动按执行环境块清单还原（`git checkout`）并以 git status 复核；独立 database 清单 SHALL 呈证并询问用户 DROP（给命令或按推送探测口径代跑）或保留，SHALL NOT 不问自删；处置终态 SHALL 记入闭环汇报。

#### Scenario: 入库配置还原后再删

- **WHEN** 执行环境块记录了入库配置改动清单且删 worktree 硬门槛通过
- **THEN** 按清单 `git checkout` 还原改动、git status 复核后进入 remove；未还原不删

#### Scenario: 独立 database 去留询问

- **WHEN** 执行环境块记录了独立库名且进入删 worktree 步骤
- **THEN** 呈证库名清单问用户 DROP 或保留，DROP 按推送探测口径给命令或代跑；处置终态记入闭环汇报

### Requirement: 非隔离轻量收尾

直用主工作区执行的变更，spec-done 收尾 SHALL 为：推送当前分支与根仓主分支（先探测，可行按用户指示代推；不可行给宿主命令等回告）+ 遗留待办复核（执行期临时偏离恢复点、预留编号——从归档 tasks/code-design 留痕汇总）呈报；SHALL 无 worktree 清理步骤。

#### Scenario: 非隔离收尾推送与呈报

- **WHEN** 归档 design.md 执行环境为直用主工作区（或无执行环境块）
- **THEN** 探测代推当前分支与根仓主分支（不可行给宿主命令），并汇总呈报遗留待办（临时偏离恢复点、预留编号）

### Requirement: 收尾红线

spec-done SHALL NOT force push；SHALL NOT 在用户确认已推送+已合并前删 worktree；删 worktree 前 SHALL 查干净，入库配置未还原或独立库处置未询问 SHALL NOT 删；SHALL NOT 代用户做 codereview 或合并决策；SHALL NOT 动与本变更无关的 worktree 与分支；SHALL NOT 把用户口头「已合并」当 git 事实（必 fetch 复核）；推送探测失败 SHALL NOT 绕行换协议硬闯。

#### Scenario: 硬门槛拦截提前删 worktree

- **WHEN** 用户仅确认已推送、合并尚未确认或 git 复核未通过
- **THEN** 拒绝删除 worktree 并呈证当前四态，等待合并确认与复核通过
