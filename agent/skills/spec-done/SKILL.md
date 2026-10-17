---
name: spec-done
description: spec 驱动工作流的收尾半程——已归档变更的分支闭环（rebase→全量复验→推送→合并确认→删 worktree→清分支）与非隔离轻量收尾，从归档工件与 git 事实三方重建进度。Use when 用户要「收尾/闭环/推送合并/删 worktree」或调用 /spec-done <变更名>；变更未归档先回 spec-workflow。
---

# spec-done 收尾半程

本 skill 是**执行手册**：每步按本文执行，未写到的情况回到用户。本文件面向**没有本次对话上下文**的未来会话——一切从归档工件与 git 命令输出重建。

## 一、总览

收尾 = 已归档变更的最后一段：**隔离闭环八步**（rebase→全量复验→推送→合并确认→删 worktree（含入库配置还原+独立库去留询问）→清分支）或**非隔离轻量收尾**（推送+遗留待办复核）。上游：spec-workflow（执行与归档，其归档汇报⑥遗留待办指路到本 skill）。**worktree 前半程（决策/创建/装配/执行期/恢复核对）与执行环境块 schema 以 spec-workflow 的 `refs/worktree.md` 为唯一权威源，本 skill 只引用不复制**；复验子代理模型路由复用 `/home/xuqinqin/develop/dotfiles/dsh/spec-workflow.yaml` 的 `verify` 键（三档回退同 spec-workflow）。

承诺：**不可逆动作（删 worktree/清分支）前必以 git 事实复核并等用户确认**、**阶段边界必汇报**、**不假设未给出的选项**。

参数：`<变更名>`（缺省问用户；恰有一个待收尾变更时可确认推断）。

## 二、前置检查

①**已归档**：`openspec list --json` active 列表无该名 + `openspec/changes/archive/` 下 `*-<变更名>/` 存在（glob 定位归档目录）；未归档 → 提示先走 spec-workflow 阶段 4，本 skill 不代归档。②**读执行环境块**：归档 `design.md` 决策记录——有块（隔离）走第四节、无块按非隔离（第五节）并如实告知。③**git 事实**：各触达仓 `git worktree list`、`git fetch origin` 后分支与合并状态。④**推送能力探测**：fetch 成功或 `ssh -T <host>` 认证通过 = 可代推；失败 → 本轮 push 步给宿主命令并等回告，不绕行换协议硬闯。

## 三、三方重建（先于任何动作）

对照三源输出**每仓收尾进度摘要**：①归档 design.md 执行环境块（仓→worktree 路径→分支）②`git worktree list` 实际 ③fetch 后分支事实——origin 主分支是否已含 `feature/<change>` 提交（`git branch -r --contains <该分支最新提交>` 或 merge-base 判定）、`git branch -d` 能否安全放行。每仓归入四态：**未推送 / 已推送未合并 / 已合并未清理 worktree / 已合并未清分支**，从每仓第一个未完成步继续；**闭环按仓独立推进，不设全体屏障**（一仓合并慢不阻塞他仓）。

## 四、隔离闭环八步（每仓独立）

1. **发起**：用户 `/spec-done <变更名>` 或等价指令；先跑第二节+第三节。
2. **fetch + rebase**：worktree 内 `git fetch origin && git rebase origin/<主分支>`。**冲突 → `git rebase --abort` 回退**，呈证冲突文件清单、双方意图、建议解法，问用户三选一：**授权代解 / 用户自解后继续 / 放弃 rebase** 换策略——不自行解冲突。
3. **全量复验**：rebase 改写全部提交链 → 该仓**全量测试**（项目声明验证方式优先；干净窗口两步法：无并发、真实 executed 无 SKIPPED/FROM-CACHE）。可派 fresh 子代理（`verify` 路由）。失败 → 停下报告，不带病推送。
4. **push**：探测可行 → `git push -u origin feature/<change>`；被拒（远端主分支又前进）→ fetch+rebase 一次后重试，仍拒报告；探测不可行 → 给宿主命令并等回告。
5. **用户 codereview + 平台合并**：人工环节，等回告——不催、不代并、不代做合并决策。
6. **删 worktree（含本地环境处置）**：**硬门槛 = 用户确认已推送+已合并**；动作前以 git 事实复核（fetch 后 origin/<主分支> 含 feature 提交）而非仅凭口述 → **本地环境处置**：入库配置改动按执行环境块清单还原（`git checkout -- <文件>`），独立 database 清单（执行环境块）呈证问用户 **DROP**（给命令或按推送探测口径代跑）还是**保留** → `git status --porcelain` 确认 worktree 干净 → `git worktree remove <路径>` → `git worktree list` 复核未波及其他 worktree。**脏 → 停下呈证，不 force**。
7. **清本地分支**：`git fetch origin && git branch -d feature/<change>`（`-d` 在合并事实可见后安全放行；放行失败 = 未合并，停下呈证，不 `-D`）。
8. **根仓 main 推送 + 闭环汇报**：工件仓主分支推送（探测代推同第 4 步口径）；汇报各仓提交链、rebase 复验证据、合并点、清理结果、独立库处置终态（DROP/保留）、遗留待办终态（临时偏离恢复点、预留编号）。

## 五、非隔离轻量收尾

直用主工作区执行的变更：推送当前分支与根仓 main（探测代推；不可行给宿主命令）+ 遗留待办复核（执行期临时偏离恢复点、预留编号——从归档 tasks/code-design 留痕汇总）呈报。无 worktree 清理步骤。

## 六、边界与失败（红线）

| 情形 | 处置 |
| --- | --- |
| 变更未归档 | 提示先走 spec-workflow 阶段 4，不代归档 |
| 执行环境块缺失 | 按非隔离轻量收尾处理并如实告知，不假设曾隔离 |
| rebase 冲突 | abort 回退 + 呈证三选一（第四节步 2），不自行解冲突 |
| push 凭证/ssh 不可行 | 给宿主命令等回告，不绕行换协议硬闯 |
| worktree 脏 / `branch -d` 放行失败 | 停下呈证：不 force remove、不 `-D`，交用户裁决 |
| 复验失败 | 停下报告证据，不带病推送；修复后从步 2 重走 |
| 入库配置未还原 / 独立库未问 | 删 worktree 前必核对：配置改动已按清单 `git checkout` 还原、库名清单 DROP/保留已问过用户；缺一不删 |

**绝不做**：不 force push；不在用户确认已推送+已合并前删 worktree；删 worktree 前不查干净不删、入库配置未还原或独立库处置未询问不删；不代用户做 codereview 或合并决策；不动与本变更无关的 worktree 与分支；不把「用户口头说已合并」当 git 事实（必 fetch 复核）。
