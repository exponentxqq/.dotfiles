# Tasks

> 执行批次契约：`## N.` 编号即执行顺序，组间严格串行；组内任务互不依赖可并行。每任务引用 design.md「触达面清单」条目编号（触达#N）。writing-skills TDD 执行序：组 1 RED → 组 2 GREEN → 组 3–5 格式/发现/加载层 → 组 6–8 行为层 GREEN/REFACTOR。

## 1. 素材提炼与 RED 基线压测

- [x] 1.1 产出静态素材清单（共性字段清单 + host-only 软插件/双端软插件/multi-root 特例三模板路线差异表 + 反例 F1–F12 逐条 file:line，只读提炼触达#9/#10 素材源）落 `/tmp/spec-flow/add-dsh-plugin-writer-skill/materials.md`；验证：`test -f /tmp/spec-flow/add-dsh-plugin-writer-skill/materials.md` 且清单内引用的每个路径逐一 `test -e` 通过（抽查脚本退出码 0）
- [x] 1.2 RED 基线压测：起一个未加载本 skill 的子代理在 dsh-plugins 仓执行「从零搭最小 host-only 插件并让它可安装」，观察至首个构建/装载失败点即止，逐字记录踩坑与合理化借口（压测产物用临时目录随后清理；若基线零失败，上浮待决不硬写 skill）；验证：记录文件含 ≥1 条逐字 agent 借口引用，且 `git -C /home/xuqinqin/develop/person/dsh-plugins status --short` 输出为空

## 2. SKILL.md 与分册撰写（GREEN）

- [x] 2.1 撰写 `agent/skills/dsh-plugin-writer/SKILL.md`（触达#1，按 design「接口与数据形状」2/4 节契约：frontmatter 两键、正文七节骨架）；验证：`wc -l agent/skills/dsh-plugin-writer/SKILL.md` ≤150 且 `grep -nE '0\.2\.[0-9]|rc\.[0-9]' agent/skills/dsh-plugin-writer/SKILL.md` 零命中
- [x] 2.2 撰写 `references/structure.md` 与 `references/build.md`（触达#2/#3，只指路+增量不复述源码注释、零版本数字）；验证：`grep -nE '0\.2\.[0-9]|rc\.[0-9]' agent/skills/dsh-plugin-writer/references/structure.md agent/skills/dsh-plugin-writer/references/build.md` 零命中，且两册引用的仓库路径逐一 `test -e` 通过
- [x] 2.3 撰写 `references/dual-client.md` 与 `references/verify-install.md`（触达#4/#5，生命周期止于安装验证、发布一句指路 AGENTS.md）；验证：`grep -nE '0\.2\.[0-9]|rc\.[0-9]' agent/skills/dsh-plugin-writer/references/dual-client.md agent/skills/dsh-plugin-writer/references/verify-install.md` 零命中，且 `grep -c 'release' agent/skills/dsh-plugin-writer/references/verify-install.md` 仅命中最多一处指路性提及

## 3. frontmatter 结构校验

- [x] 3.1 对 `agent/skills/dsh-plugin-writer/SKILL.md`（触达#1）执行四项结构断言：键集恰 `{name, description}`、name 为 `dsh-plugin-writer`、description 原始字符数 ≤300、YAML 可解析且必填键为 string（命令见 design「逐任务组实现要点」组 3）；验证：四条断言命令退出码全 0（任一不过回组 2 修正后重跑）

## 4. skctl 登记与 README 补行

- [x] 4.1 `agent/skills/README.md`（触达#6）「当前清单」表末追加独立行 `` | `dsh-plugin-writer` | 自写（本目录 local symlink） | ``；验证：`grep -n 'dsh-plugin-writer' agent/skills/README.md` 恰命中 1 行且位于清单表内
- [x] 4.2 宿主执行 `SKCTL=~/develop/dotfiles/tools/skctl/src/cli.ts; node $SKCTL install ~/develop/dotfiles/agent/skills/dsh-plugin-writer`（触达#8 机器态，node 走 docker 包装）；验证：`node $SKCTL list --all --desc | grep dsh-plugin-writer` 命中 enabled/local 行、`readlink ~/.local/share/agent-skills/skills/dsh-plugin-writer` 输出实体目录、`ls -d /home/docker/.agents/skills/dsh-plugin-writer` 存在

## 5. 发现与加载验证

- [x] 5.1 三路发现验证：新开会话目录消息含 `dsh-plugin-writer` 条目、`/inventory` 输出含之、`skill dsh-plugin-writer` 实际加载返回正文，反向 `skill dsh-plugin-writter` 报不可用（目录不可见先查 session-tool-toggle `skill:` 开关状态）；验证：四条可观察输出逐条记录（新会话目录截图或消息引用 + 三条命令输出）
- [x] 5.2 触发三语句路由测试各 1 轮（「在本仓新写一个插件」→命中本 skill；「给当前 profile 加个一次性功能」→让位官方 `cordis-plugin-development`；「设计新插件的行为规格」→走 `openspec-propose`），摇摆结果升级 5 轮微测；验证：三条路由结论各附 1 份子代理回执记录

## 6. dsh-plugins 侧 host-only 全链演练（GREEN）

- [x] 6.1 在 `plugins/demo-echo/`（触达#9，包名 `dsh-plugin-demo-echo`，devDeps 集合逐字段对照 zcode-plan、version `0.0.0`）搭最小 host-only 插件并走通全链：`pnpm install` → `pnpm --filter dsh-plugin-demo-echo verify:all` → `pnpm dsh:check` → `docker exec dsh dsh plugin --profile web add /home/xuqinqin/develop/person/dsh-plugins/plugins/demo-echo` → `docker exec dsh dsh --profile web --dump-config-schema`；验证：五条命令退出码全 0 且 `docker exec dsh dsh --profile web --dump-config | grep demo-echo` 出现注册行（执行记录：命令 1–4 exit 0；命令 5 exit 1 与 add 前基线逐字节一致——既有 preset-* 噪音，按 R3 坑 3 基线对照口径判定通过，详见 diff-matrix.md R10）

## 7. 双端分支抽验

- [x] 7.1 **执行前询问用户选择验证强度**（a：硬断言止于 `--dump-config` 注册行 + Web UI 入口人工目检；b：追加浏览器半加载图证据——design「Open Questions」分1）；随后给 demo-echo 追加 `dsh.client` 声明与 `exports "./client"`（触达#9）重跑构建与安装链，核对 Web client-module scan 识别；验证：按用户所选强度断言（a：`--dump-config | grep demo-echo` 出现 client 注册行 + 目检记录；b：另附加载图证据）（执行记录：双端改造完成、verify:all/dsh:check 全绿；实测推翻原口径——dump-config 不运行 client-module scan（R11），按等价证据链收案（裸包名行+四处声明+静态 scan 回放 EXIT=0+产物壳）；Web UI 目检经用户决议跳过（2026-11-05，重启 dsh 将中断本会话），详见 R13）

## 8. REFACTOR 回填与复验

- [x] 8.1 把组 6/7 演练中 agent 实际踩到的坑回填 skill（必改清单/反例速查增补，触达#1–#5），重跑组 3 结构断言与受影响的演练步骤（此步需 demo 包仍在位）；验证：组 3 四条断言重跑退出码全 0

## 9. 终态清理

- [x] 9.1 演练清理四步：`docker exec dsh dsh plugin --profile web remove dsh-plugin-demo-echo` → `rm -rf /home/xuqinqin/develop/person/dsh-plugins/plugins/demo-echo` → `pnpm install`（回写 lockfile）→ 终态断言；验证：`git -C /home/xuqinqin/develop/person/dsh-plugins status --short` 输出为空（触达#10 零入库改动）

## Workflow follow-up

- 全部任务完成后按 spec-done 流程验证并归档本变更（归档前复验组 5 发现层）。
- AGENTS.md 基线漂移修正（rc.2→rc.5）为已拍板的独立小任务，在 dsh-plugins 仓另行提交，不属本变更。

## 附录 · 沉淀回流清单（spec-apply 组收尾工件化，spec-done 汇报数据源）

- **执行期改动的工作流仓文件**：无（除本变更工件本身）。R1（路由自检脚本正则漂移）与 R5/R8/R9 的平台层事实均**只留痕未改工作流文件**，供后续变更候选：①routing.md 自检脚本正则适配多行 YAML；②dsh-tool-skill 目录消息发布实例门（R9，file:line 已定位）；③`dsh web --help` 本机挂起现象（R11-5）。
- **本变更最终产物去向**（已提交/待提交）：`agent/skills/dsh-plugin-writer/`（5 文件，待本批次提交）＋ `agent/skills/README.md` 补行（同批次）＋ skctl 登记态（机器态，不入库）＋ 变更工件执行期更新（同批次）。dsh-plugins 仓零改动（触达#10 达成，外部并发提交 `e11b656` 属他变更）。
- **留痕索引**：R1–R13 见 diff-matrix.md 第七/八节，R14 见其末尾；证据原件 /tmp/spec-flow/add-dsh-plugin-writer-skill/（materials.md、red-baseline.md、group6/7-drill.md、assert-group3.mjs），易失不入库。
