# Spec Delta

## Purpose

界面演示能力：当需求涉及界面设计且无 Figma、原型、截图等设计依据、需要 AI 自行设计界面时，先产出静态自包含演示并经用户确认，再进入实现——把界面方向的返工从执行后前移到规划期。本能力是触发判定、产出分级、产物规范与自检序列的唯一权威源，三个开发流程（spec-workflow、openspec explorer、/plan）经接线引用而不复述。

## ADDED Requirements

### Requirement: 界面演示触发判定与产出分级

三条件同时成立且不命中排除表 SHALL 进入界面演示：C1 需求涉及界面产出（页面/组件/弹窗/表单/仪表盘/移动端页面/布局或视觉改版/交互流程可视化）；C2 用户未提供任何设计依据（无 Figma 链接、无截图、无原型图、无可照抄的既有页面，含「你看着办」式授权）；C3 AI 须自行决定视觉与布局方向（非纯后端/数据/配置，非设计体系内零视觉决策的机械改动）。排除表五类 SHALL NOT 进入：纯后端/CLI/迁移/脚本；已有设计稿或 figma MCP 可取；仅文案/token 局部替换；用户明示豁免（须留痕）；需求本身即成品视觉。分级 SHALL 取语义判据最高档：L1 默认静态布局；含关键交互流或多状态升 L2；视觉方向完全开放且用户未给偏好出 2-3 个并列方向。

#### Scenario: 界面需求无设计稿命中判定

- **WHEN** 需求为「给列表页加一个筛选面板，我没有设计稿，你看着办」
- **THEN** 三条件成立且不命中排除表，进入界面演示并默认按 L1 产出

#### Scenario: 命中排除表不进入演示

- **WHEN** 需求附带 Figma 链接或明确说「不用演示，直接做」
- **THEN** 不进入演示；用户豁免情形记录豁免事实留痕

#### Scenario: 含关键交互流升级 L2

- **WHEN** 需求包含提交中、校验失败、空/加载/错误等多状态流转
- **THEN** 按 L2 产出，每个状态一屏（同页多 section 或切换），含禁用/悬停态与错误提示文案位

#### Scenario: 视觉方向开放出多方案 L3

- **WHEN** 无品牌与设计系统可依且用户未给视觉偏好
- **THEN** 单文件内 2-3 个方向并列，以 tab 切换为主（每方向独占视口宽度并附一句设计意图），并排缩略形态仅在用户显式要求一屏对比时提供

### Requirement: 界面演示产物规范

界面演示 SHALL 为静态自包含单 HTML：样式内联、零外部请求（禁 CDN、禁 webfont 外链、禁 http 图片）、禁 base64 大图（>20KB 资产改 CSS/SVG 造型）、单文件 ≤100 000 字节、含 viewport meta、桌面与窄屏均不横向滚动；页面顶部 SHALL 固定演示约束条（变更名、分档、生成时间、「界面演示，非最终实现」）；使用假数据 SHALL 标注「示意数据」。产物路径 SHALL 按场景：openspec 场景落 `openspec/changes/<change>/demos/<slug>.html`（生成期先落易失区，落档整目录复制）；`/plan` 场景落易失区（`/tmp/ui-demos/`，即确认即弃、不入库）。预览 SHALL 支持宿主 file:// 直开并给出容器/宿主双路径映射（容器 `/tmp` ≡ 宿主 `/data/tmp`）；统一服务入口（nginx）不在本能力内实现，仅留扩展位。

#### Scenario: openspec 场景产物路径

- **WHEN** spec-plan 阶段 1.75 或 explore/propose 触发演示
- **THEN** 演示先落易失区，落档时整目录复制入 `openspec/changes/<change>/demos/` 随工件入库

#### Scenario: plan 场景易失即弃

- **WHEN** `/plan` 模式呈交计划前触发演示
- **THEN** 演示落 `/tmp/ui-demos/` 易失区供确认，不写入项目仓

#### Scenario: 自包含与外链禁令

- **WHEN** 演示页生成完毕
- **THEN** 文件内 `src="http`、`href="http`、`@import` 计数为 0，无 base64 大图，总量 ≤100 000 字节

#### Scenario: file:// 直开预览

- **WHEN** 演示产出并交用户
- **THEN** 同时给出容器内自检路径 `file:///tmp/...` 与宿主打开路径 `file:///data/tmp/...`（或落档后三端同路径位置）

### Requirement: 界面演示自检与用户确认

演示交用户前 SHALL 自检：以 chrome-devtools MCP（chrome-shared）新开标签页 file:// 导航、整页截图（约束条在顶、无空白区块、无溢出横向滚动）、控制台零 error 且无 Failed to load resource、用毕关闭标签页；默认视口与窄屏（约 390px 宽）各验一次；多方向/多状态页逐一切换各验一次。共享浏览器 SHALL 用独立标签页防多会话干扰。MCP 不可用 SHALL 降级：如实告知未做渲染自检、给宿主路径请用户自行打开、在确认留痕标注证据缺口。确认 SHALL 以三选一提问（确认/要改/降档或豁免）；未取得确认 SHALL NOT 视为通过；用户豁免 SHALL 留痕。

#### Scenario: 自检通过后交用户确认

- **WHEN** 演示页自检截图与控制台核对均通过
- **THEN** 以宿主可打开的路径交用户，附三选一确认问法

#### Scenario: 自检不可用降级如实标注

- **WHEN** chrome-shared MCP 不可用或导航报错
- **THEN** 告知「未做渲染自检」并给宿主 file:// 路径，留痕标注证据缺口

#### Scenario: 用户否决则改稿重出

- **WHEN** 用户选「要改」并给出修改点
- **THEN** 按反馈改演示并重新自检后再次交确认，不进入落档

#### Scenario: 用户豁免须留痕

- **WHEN** 用户选「降档或豁免」并写明依据
- **THEN** 豁免依据写入该流程的留痕位置，后续可审计

### Requirement: 三个流程的接线与留痕

spec-plan SHALL 在阶段 1.7 之后、落档之前执行界面演示 gate（硬 gate：未确认不得落档；未命中 SHALL 记未触发事实）；openspec explore/propose 与 `/plan` SHALL 经 skill 目录 description 触发词软接线（不宣称强制，命中率依赖触发词覆盖度，属已知情接受的残余风险）。三者留痕位置 SHALL 各自规定：spec-plan 于代码设计草案「阶段 1.75」附录并随落档入 design 决策记录；explore/propose 于会话产出与对话摘要（有 code-design 时同左）；`/plan` 于计划文本「界面演示」行（路径 + 确认状态）。

#### Scenario: spec-plan 阶段 1.75 硬 gate

- **WHEN** spec-plan 规划半程命中判定
- **THEN** 阶段 1.75 产出演示并取得用户确认后才允许落档

#### Scenario: explore 场景接线

- **WHEN** explore/propose 会话的需求描述命中 ui-demo 触发词
- **THEN** 加载 ui-demo 产出演示，变更目录已建则直接落其 demos/，未建则先落易失区后迁入并告知最终位置

#### Scenario: plan 场景接线

- **WHEN** `/plan` 模式探索完成、呈交计划前命中判定
- **THEN** 先产出演示并确认，计划文本含演示路径与确认状态

#### Scenario: 软接线不宣称强制

- **WHEN** 模型在软接线场景未触发 ui-demo
- **THEN** 系统不保证演示发生；该残余风险由 description 触发词（Use when 开头、中文场景词、三入口名）覆盖度缓解

### Requirement: ui-demo 入口与资源预算

ui-demo SHALL 以目录 bundle `agent/skills/ui-demo/` 提供，frontmatter 恰含 `name` 与 `description` 两键；description SHALL ≤400 字符、以 `Use when` 开头、含中文场景词与三个入口名（openspec explore/propose、/plan、spec-plan）、不含流程概述。判定表 SHALL 置于正文前 2 000 字符内；HTML 骨架与分档元素清单 SHALL 外移 `refs/html-recipe.md` 按需读取；入口 ≤6 000 字符、各资源 ≤7 000 字符（硬线 8 192）。

#### Scenario: 入口单次加载完整

- **WHEN** skill 加载进会话
- **THEN** 正文无裁剪标记，判定表完整可见

#### Scenario: 重参考按需读取

- **WHEN** 进入写演示页环节
- **THEN** 读取 refs/html-recipe.md 获得骨架与元素清单，读到的与正文同等权威

#### Scenario: 判定表前置

- **WHEN** 正文生成完毕
- **THEN** C1 首次出现位置 < 2 000 字符（可机械断言）
