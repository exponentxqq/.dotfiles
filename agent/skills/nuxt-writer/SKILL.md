---
name: nuxt-writer
description: Use when writing, modifying, or reviewing any Vue/Nuxt frontend code — pages, components, composables, Pinia stores, request/API layers, UnoCSS styles, mobile H5/webview compatibility, or frontend tests.
---

# Nuxt/Vue 前端开发规范

## 核心原则

1. **写前先读** — 每写一个组件前，先读同模块 2-3 个已有组件，模仿其组件命名、样式写法、请求方式、测试写法
2. **复用优先** — 已有 base 组件/composable 必须复用，不新建重复样式；重复 ≥2 处的 UI/逻辑抽公共组件或 composable；组件能力由组件自身 emit 声明，父层不集中维护清单；通用型 composable 先查 VueUse，确认没有才自写
3. **页面只做编排** — 业务逻辑下沉 composables/stores（可单测）；通用型组合函数放 `hooks/`（先查 VueUse）；纯函数放 `app/utils/`
4. **最优改动** — 任务实现选最优方案而非最小 diff；被本次改动波及的存量（调用方、受影响测试、规范收紧涉及的存量）一并改到位；无关文件的问题只报告不擅动；功能被移除时测试断言与死代码一并清理
5. **验证交给用户** — 改完自查副作用；不主动起 dev server 验证；不主动提交
6. **优先设计模式** — 写新功能前先考虑是否有成熟设计模式（策略/适配器/观察者/工厂等）可套用，避免堆叠 if-else 分支

## 组件规范

- 组件使用 kebab-case（`<base-button>`），靠 Nuxt 路径自动导入；标签名与注册名完全对齐（`components/<域>/foo-bar.vue` → `<域-foo-bar>`）；不显式 import（仅 `import type`）；非组件文件名 camelCase（`useXxxApi.ts`、`request.ts`）
- 含播放器/RTC/手势状态、需跨切换保留的组件隐藏用 `v-show` 不用 `v-if`（卸载销毁内部状态）
- 弹窗：子组件对外支持 v-model 语义（props 收 `modelValue` + `emit('update:modelValue')`），但组件**内部**禁止把该 prop 再 `v-model` 绑给下层（prop 只读，关不掉）——内层要用 `:model-value` + emit 透传；全局 layout 已挂载的弹窗页面不再挂（双实例叠层）
- base 表单组件用 `modelValue`/`update:modelValue` 做 v-model，props 全类型化
- SFC 结构：`<script setup lang="ts">` → `<template>` → `<style scoped>`；`interface Props` + `defineProps<Props>()`；import 集中在 script 顶部（mid-script 干扰 SFC 转换）；标签对（script/template/style）之间恰好一个空行
- 图标用 `<nuxt-icon>` + SVG `fill/stroke="currentColor"`（可 CSS 改色），不用 `<img>`+opacity
- 类需求仿已有同构模式新建（如已有的「按场景集合隐藏布局元素」composable → 新场景照同构新建），不改现有引用

## 页面与路由

- `definePageMeta` 自定义属性声明在**顶层**（`definePageMeta({ hideBack: true })`，不包 `meta:{}`），读取时才在 `route.meta.hideBack`；配 `declare module 'vue-router'` RouteMeta 类型增强。单页 UI 差异用这种路由 meta 控制，不动共享布局其他页面
- 自定义 `app.vue` 必须含 `<NuxtLayout><NuxtPage />`，否则 `definePageMeta({ layout })` 不生效
- 导航用 `navigateTo`（已登录跳转加 `replace: true`），不用 `useRouter().push`；测试 mock `#app/composables/router`
- 路由守卫拦截：编程式导航 `cancel` 停留当前页，直接访问/刷新才兜底跳首页；初始加载 `from` 镜像 `to`（`from.matched.length > 0` 不可用）；守卫改动后复查所有到达场景与循环
- 守卫已保证的条件业务层不重复判断；readonly 用权威标志（服务端下发的数据状态字段）不用前端派生状态
- 区分「加载即已提交（查看态）」与「用户刚提交」，只对后者自动跳转

## Composable 分层

- 通用型组合函数（防抖、localStorage、媒体查询等跨项目技术能力，无领域名词/业务规则）放 `hooks/`（与 `composables/` 同级）；业务型（含领域逻辑）放 `composables/`；跨组件共享业务状态进 Pinia store
- `hooks/` 非默认扫描目录，必须配 `imports: { dirs: ['hooks/**'] }` 才自动导入（composables/、utils/ 默认也只扫顶层）

## 状态与数据

- 登录态/业务域状态分 Pinia store（`stores/` 自动导入），API 调用收进 store action；一律 Setup Store 写法，不用 Options Store
- falsy 兜底一律 `??` 不用 `||`（0 会被吞）
- 临时草稿用 sessionStorage（按业务 id 分键），跨会话标志用 localStorage；模块顶层 storage 访问必须 try/catch（Safari 隐私模式崩溃）
- 数据为空隐藏区块，不做假数据兜底；能拿到真实数据不硬编码魔数
- v-for 用稳定 key（对象 id/WeakMap 分配），不用数组下标（删除后复用引发状态泄漏/动画重放）
- 按序渲染的列表本地 computed 按 orderNo 排序，不信任 API 顺序
- 单例 composable（模块级状态）禁止存 per-instance 数据——要用的值用参数传入，并用双实例回归测试锁死
- WS/事件处理器刷新列表时连带刷新门控该列表的标志位；处理器注册覆盖所有登录路径（fresh login 不重跑 onMounted）；监听能局部就局部（页面级注册），不全局扩散
- 计时器/轮询 composable 必须 `onUnmounted` 清理；watch 需要首次触发加 `immediate: true`
- 响应式计时用 VueUse `useNow`，不用非响应式 `Date.now()`
- 跨状态复用的根组件加 `:key`（防 ref 跨轮次泄漏）
- store 状态更新不自动触发守卫，需 `router.replace({ force: true })` 重裁决

## 请求层与 API 契约

- 请求走项目统一封装（`utils/request.ts`），禁止裸 `$fetch`；token 注入、`ApiResponse<T>` 解包、`ApiError(code)` 抛错、401 分流（按端策略，如 web 跳登录/applet 清 token）全部收敛在 request 层，业务层不重复处理；调用方只用封装的 get/post，禁止手动拼 apiBase 或 JSON.stringify
- 后端有 OpenAPI 时用生成 SDK（`composables/generated/` 自动导入，`useXxxApi()` 风格），生成代码**禁止手动编辑**；后端重新生成后删除手写请求函数。手动 `useXxxApi.ts` 仅限组合场景（多 API 组合、数据转换、本地缓存、与 Pinia store 交互），原子 CRUD 直接用生成 API；错误处理统一走 request 层拦截器，不在 composable 重复
- TS 类型映射：decimal→decimal.js、date/datetime→时间戳、枚举→TS enum；前后端共用的拼接/签名规则必须两端一致并用测试锁定
- 前端命名/数据结构与后端契约对齐（后端改名前端组件同步改）；前端不消费的响应字段即死字段，推动后端删除
- 长耗时异步用轮询（间隔+上限常量化），不上 SSE/WebSocket；轮询超时文案诚实（「继续等待」而非「生成超时请重试」）
- 提交成功才跳转（`.then`），失败留在当前页走统一 toast；空数组提交前置校验 + toast（在 `submitting=true` 之前）
- 状态/类型字段用枚举数字 code（后端 tinyint ordinal），不用裸字符串

## 样式（UnoCSS）

- attributify 优先：样式写 DOM 属性（`w="22.625rem"`、`text="1 #666"`）；同一元素同名属性必须合并为单属性空格分隔（重复声明报 TS1117）；attributify 中任意值无需 `[]` 包裹（如 `text="2.625rem"`）
- 颜色用 8 位 hex 含 alpha（`#000000E6`）或纯 hex；尺寸无单位/rem（除 border 不用 px）
- scoped CSS 仅用于伪元素/关键帧/复杂子选择器
- 移动端视口高度用 dvh 兜底（`h-screen h-dvh max-h-screen max-h-dvh`——旧 iOS <15.4 不支持 dvh 需完整降级链）
- 摄像头/视频画面 `object-fit: contain`（cover 会裁切放大）
- 居中一律 `flex items-center justify-center`，不用 absolute+translate
- input 聚焦外发光用 wrapper `:focus-within`，不用 JS；input 本体去原生边框
- flex 列滚动三件套：可滚区 `flex-1 min-h-0 overflow-y-auto`、固定头 `shrink-0`；滚动容器外面不套 flex（stretch+overflow-hidden 钳制高度致永久截断）
- 桌面瀑布流用两栏 flex 贪心分栏，不用 CSS columns（与 overflow-y-auto 冲突）
- iOS WebKit `background-repeat` 大位移有 tile 累积偏移（~1.25px/格）——用独立格子 div + no-repeat + transform 替代
- 换组件/覆盖样式先确认视觉变化，冲突属性用 UnoCSS `!` 前缀

## 移动端与媒体兼容

- 音视频播放必须在用户手势内（autoplay 不可靠）；视频 `playsinline` + `webkit-playsinline` 防自动全屏；设 src 后等 `loadeddata` 再 `play()`，不显式 `load()`
- iOS audio 解锁：手势内静音 data-URI 播一次解锁；被阻塞时按钮变「点击播放」，失败静默放行不卡流程（fail-open）
- `play()` 的 catch 不静默：`console.error(e.name, e.message, e.code)`（vconsole 打不出整个 DOMException）
- 媒体加载失败必须 `@error` fallback（直接进下一流程），不能让用户卡在禁用按钮上；回放用原生控件不自研播放条
- checkbox 不依赖 label 激活 hidden input（移动端不可靠），用 `@click.prevent` JS 驱动；limit 校验只拦「新增超限」、放行「取消降量」
- 验证码输满自动 `blur()`；`onBlur` 在输满时跳过强制 re-focus
- Firefox 全局禁原生图片拖拽（`dragstart` preventDefault + `-webkit-user-drag:none`）
- 录制 MIME 平台自适应（webm 优先、iOS fallback mp4，不信任 `mediaRecorder.mimeType` 空串）；异步媒体操作返回 Promise + `try/finally` 必 resolve，调用方 await 后再切状态
- watch/状态变化后操作模板 ref（设 video src、测量元素、canvas 绘制）前必须 `await nextTick()`
- iframe 内导航用 postMessage 通知父级（iframe 无历史，`history.back()` 无效）；嵌入第三方游戏需桥接 click（只绑 tap 点不动）
- 弹窗/下拉定位测量真实渲染高度（`getBoundingClientRect` + nextTick），不硬编码估算值；上翻时 `top = rect.top - menuHeight`
- vConsole/调试面板由环境变量唯一控制显隐，prod 绝不显示（无 URL 参数后门）；可拖动调试组件用 env 开关

## 输入与交互

- 数字输入统一走 base 组件三道防线：keydown 拦 `- + . e E`、paste 过滤、input 兜底清洗；原生 `<input type="number">` 迁移到组件
- 输入超限用提交按钮 `:disabled` 拦截，不强制改写用户输入（clamp 体验差）；`:max` attribute 拦不住键盘输入，上限靠 watch 钳制值
- 登录输入允许空格、提交前 trim；纯空格=空
- 必填问卷/量表不设默认值（默认值可直接提交）；未答完 `canSubmit` disabled
- 双击交互 300ms 计时判定（单击/双击共存），范围精确限定（不需要双击的分支加守卫）
- 行为边界常量导出复用（如 `MIN_LIMIT = 100`），不散落魔法数字
- 滑块两端标签左对齐/右对齐、中间项居中（整数比较定位，避免浮点边界 bug）

## 测试纪律

- 新改动 100% 覆盖（语句+分支），TDD 先红后绿；不可达防御分支删除而不是 ignore
- 用例名用中文；组件测试 `mountSuspended`（@nuxt/test-utils）；composable 用宿主组件包装 + fake timers；happy-dom 缺 localStorage 需 `test/setup.ts` polyfill
- Pinia 测试 `beforeEach(() => setActivePinia(createPinia()))`；`vi.mock` 必须在 import 前（hoist）；全局类用 `vi.stubGlobal('Audio', Mock)`
- 测试与组件契约同步：语义选择器（aria-label/按钮文本），不用脆弱 class；重构后逐项核对 prop/emit/文案；mock 层对齐真实实现（被测重构后 mock 同步换）
- bug 修复附回归测试锁死场景（可临时回退修复验证用例有效）；随机/规则逻辑严格断言（精确 target，±1 即失败），固定 seed 可复现
- 测试环境宁简单勿复杂（全局 `environment: 'nuxt'`，慢点可接受）

## 工程习惯

- 代码零注释（.vue 同样适用），自解释命名
- Prettier 管格式、ESLint 管质量（eslint-config-prettier 关闭冲突规则）；改完跑 `pnpm format`
- ESLint 质量规则：禁用 `any`；未使用的变量/参数直接删除，不配 `_` 前缀豁免；签名必须保留的参数直接用原名（no-unused-vars 默认 after-used，末位使用参数之前的未用参数不报错）
- 禁用 `v-html`（XSS 攻击面）；确需富文本渲染必须先 sanitize 并在代码中注明理由
- 提交 conventional commits 中文描述（`fix(scope): 描述`）；只在用户指令时提交
- mobile/desktop（或双应用）parity：改动两端同步检查（另一端往往有同样问题）

## 写完自查

- 跑项目自有验证命令（test / format，见各项目 CLAUDE.md/AGENTS.md）
- [ ] 组件 kebab-case 自动导入，无显式 import（仅 type）
- [ ] 样式 attributify + hex + rem；scoped 仅伪元素；同名属性已合并
- [ ] 移动端坑已过：手势播放 / dvh / contain / label 激活 / iOS repeat 背景
- [ ] `??` 兜底、空数据隐藏、稳定 key、nextTick 后操作 ref
- [ ] 测试 100% 覆盖且契约同步，用例名中文
- [ ] 通用逻辑先查 VueUse；通用型在 hooks/、业务型在 composables/
- [ ] 零注释；跑 format；双端同步；不主动提交
