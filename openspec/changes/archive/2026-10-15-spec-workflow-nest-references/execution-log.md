# 执行记录：spec-workflow-nest-references

**变更名**：spec-workflow-nest-references（references 子目录化至 `refs/`）
**目标**：把 `agent/skills/spec-workflow/` 下与入口平铺的 5 个 references 收进 `refs/` 子目录，入口 `SKILL.md` 保持根位置。
**执行方式**（用户批准）：轻量 openspec 变更（无 spec delta）；目录名 `refs/`；主会话串行执行，无子代理派发。
**提交链**：
1. `f873fae` 落档（`.openspec.yaml` + proposal.md + tasks.md）
2. `db83d19` 实现（5×R100 移动 + SKILL.md + dsh/README.md + tasks.md 勾选）
3. 本文件与变更目录的归档提交
**工作区纪律**：两次提交均显式 `git add` 指定路径，`dsh/profiles/web/cordis.patch.yml`（宿主侧会话模型切换产生的脏改动，非本变更）始终排除。

## 1. 触达面与改动实绩

| 文件 | 改前 | 改后 | 说明 |
| --- | --- | --- | --- |
| `agent/skills/spec-workflow/SKILL.md` | 7782 | **7816** | 16 处链接 href 加 `refs/` 前缀（+80）＋「同目录」措辞改指子目录（−2）＋等量收紧（−44） |
| `refs/planning.md` | 6279 | **6279** | `git mv` 至 `refs/`，内容零改动（R100） |
| `refs/convergence.md` | 2864 | **2864** | 同上 |
| `refs/routing.md` | 3900 | **3900** | 同上 |
| `refs/execution.md` | 3092 | **3092** | 同上 |
| `refs/failure-modes.md` | 2238 | **2238** | 同上 |
| `dsh/README.md` | 15016 | **15079** | 7 处路径同步 + 导语补「references 集中于 `refs/` 子目录」（＋63） |

**SKILL.md 逐项增量核算**（合计 +34，与 7782 → 7816 实测一致）：

| 项 | 增量 |
| --- | --- |
| 16 处 href 加 `refs/` 前缀（planning×5 / convergence×2 / routing×4 / execution×2 / failure-modes×3） | **+80** |
| 第一节 流水线输出行对齐空格 4→2 | −10 |
| 第一节「同目录 references」→「**`refs/`** 子目录」 | −2 |
| 第七节 `status` 平台注记（「该 CLI 版本的」→「该版本」、「报缺 `--change`」→「无效」） | −17 |
| 第四节「被以错误码 `DELEGATED_CALLER`」→「被 `DELEGATED_CALLER`」 | −4 |
| 第一节「（工件 + 勾选态 + 提交历史）」→「（工件+勾选态+提交历史）」 | −4 |
| 第一节「入口为用户级斜杠命令」→「入口为用户级命令」 | −2 |
| 第四节「两者产物分别落」→「产物分别落」 | −2 |
| 第一节「决策转达方式＝」→「决策转达＝」 | −2 |
| 第七节「重建进度即可。」→「重建进度。」 | −2 |
| 第十一节「容器内 `~`」→「容器 `~`」 | −1 |

未触及：frontmatter（逐字节一致，门禁断言通过）、12 个 `## ` 节标题、红线表与恢复协议/中转协议/绝不做段语义。

## 2. 验证证据

| 门 | 内容 | 结果 |
| --- | --- | --- |
| G1 结构 | skill 根仅 `SKILL.md` + `refs/`；`refs/` 恰 5 个 `.md`；`git diff --cached -M --name-status` 5 行全 `R100` | **PASS** |
| G2 码点与结构 | SKILL.md **7816** ≤ 7825（自设门 ≤7830）；5 个 references 码点 6279/2864/3900/3092/2238 与基线逐一相等；`grep -c '^## '` = 12；frontmatter 门禁 `test -z "$(git diff … \| grep '^[-+]name:\|^[-+]description:')"` 退出码 0 | **PASS** |
| G3 引用闭合 | SKILL.md 16 个 href 经仓库路径与 `/home/docker/.agents/skills/spec-workflow/` **双路** `test -f` 全通过；`refs/` 内互链目标 5 个双路全通过；全仓（排除 `openspec/changes/`）旧平铺路径 `spec-workflow/(planning\|convergence\|routing\|execution\|failure-modes)\.md` **零残留** | **PASS** |
| G4 渲染预算 | 信封长度实测 **343** 码点（`<skill_content>` + `<skill_resources>` 基目录行 + 说明两行 + `<skill_instructions>`，**不含文件清单**）；渲染上界 = 7816 + 343 = **8159 ≤ 8192**（余量 **33**）；加载响应实际剥离 frontmatter（198 码点），实际渲染 ≤ **7961**（余量 231） | **PASS** |
| G4 运行时冒烟 | 会话内按名加载 `spec-workflow` 成功，返回**改后版本**：「外移到 **`refs/`** 子目录」措辞、16 处 `refs/*.md` 链接、全部收紧生效；base directory 解析为 `/home/docker/.agents/skills/spec-workflow`；`ls …/spec-workflow/refs/` 5 文件可见，symlink 直指仓库目录（改源即生效，无需重登记） | **PASS** |
| G5 项目声明验证 | `tools/skctl`：`pnpm test`（`node --test 'test/*.test.ts'`，经 docker pnpm 包装）→ **tests 47 / pass 47 / fail 0**，退出码 0 | **PASS** |
| G6 变更校验 | `openspec validate spec-workflow-nest-references --strict` → `Change … is valid`，退出码 0（`skip_specs: true`，零 delta 被接受并提示 `change declares no spec-level behavior changes`） | **PASS** |

## 3. 偏差与裁定

- **D-1（tasks.md 验证句笔误，已修正）**：任务 1.1 验证句的期望码点列表顺序把 `routing.md`/`execution.md` 写反（`[6279,2864,3092,3900,2238]`），字面永不可通过。实测确认五文件码点与基线逐一相等、`git` 判定 5×**R100**（内容逐字节未变）后，将期望值改为正确顺序。属卡片措辞缺陷，非交付缺陷，按既往「验证句假阳性」同类处置记录在案、不掩盖。
- **D-2（G6 预案被官方机制取代）**：预案为「若 strict 拒绝无 delta 变更，则追加一个布局中性 Scenario」。实际 `openspec validate` 直接给出官方出路——`.openspec.yaml` 置 `skip_specs: true`（"pure refactor, tooling, docs" 场景），遂改用该键：**主规格零改动**，比追加 Scenario 更干净。主规格 `spec-workflow`（7901 码点 / 16 Requirement / 45 Scenario）保持原样。
- **D-3（渲染实测路径调整）**：原计划从宿主会话轨迹提取注入载荷测长，但轨迹按 zstd 分帧存储且**长工具结果不入帧**（探针仅取到对话文本）。改用两条独立证据：①信封结构分解（env=343，与上轮「343 实测标定」完全吻合；响应实测确认 frontmatter 被剥离）；②会话内实际加载成功并返回改后内容。结论 G4 成立，且因上界 8159 余量 33，无需触发「追加收紧或降级 `r/`」的备选分支。
- **自举观察**：本变更按用户批准的轻量过程执行（无阶段 1 双线与阶段 1.7 设计线），**无子代理派发**，故不产生「派发前是否读 `refs/routing.md`」的自举数据点；如实记录，不冒充流程执行。

## 4. 宿主操作清单

1. **无需任何宿主操作**：skctl 为目录级 symlink（`~/.agents/skills/spec-workflow → agent/skills/spec-workflow`），子目录化透明生效——**无需重登记、无需重启 dsh、无需 `/commands-reload`**（命令薄壳未改动）。
2. `dsh/spec-workflow.yaml` 与阶段模型路由未改动（`refs/routing.md` 内嵌的自检脚本逻辑不依赖自身路径）。
3. 待办：`git push`（本流程不代劳）；`dsh/profiles/web/cordis.patch.yml` 的宿主侧脏改动仍待你自行决定提交或还原。
