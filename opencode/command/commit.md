---
description: 智能提交当前项目变更，自动识别并逐个提交多个独立子仓库（git-commit 全程接管）
agent: git-commit
---

提交当前项目的待提交变更。当前项目可能由**多个相互独立的 Git 仓库**组成
（例如 `~/develop/company/brains` 下的 `service/`、`child/`、`oldman/` 都是各自独立、
被根仓库 `.gitignore` 忽略的仓库）。请按你的 workflow 处理多仓库场景：
自动发现所有独立仓库，对每个有变更的仓库**分别提交**，各写各的提交信息。

## 提交范围（$ARGUMENTS）

- 无参数：提交**所有**有变更的独立仓库；
- 仓库名或相对路径（如 `service`、`child`、`brains`）：只提交匹配的那一个；
- `all`：显式提交所有有变更的仓库。

$ARGUMENTS
