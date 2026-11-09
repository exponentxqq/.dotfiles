# 演示页 HTML 配方（ui-demo · refs）

> **消费时机**：判定命中、动手写演示页之前读；主会话 inline 执行。本文件与 `SKILL.md` 正文同等权威——`SKILL.md` 管判定、分级、接线与纪律，本文件只管页面形状：骨架、模板、清单、卡。
>
> **为何自包含**：chrome-shared 浏览器在 dsh 容器内，容器里的 `localhost` 是容器自己；任何 http 资源在容器自检与宿主 `file://` 预览两头都不可靠，故**单文件、零外部请求**。

## 施工顺序（六步）

1. **定档**：按 `SKILL.md`『产出分级』判 L1/L2/L3；命中取最高档（L2/L3 同中按 L3）。
2. **取骨架**：抄 §1 整页，只改变更名、档位、生成时间与标题。
3. **填模板**：按档接 §2 模板，对照 §3 元素表——**缺项即不合格**。
4. **删冗**：删掉多余的标语、说明文字和次要标签；删完界面就看不懂 = 布局本身有问题，回第 3 步重新设计该区块，而不是把文案加回去（约束条与「示意数据」标注属演示机制，不删）。
5. **窄屏**：保留骨架窄屏片段，390×844 下核对不横向滚动。
6. **自检**：按 §6 四步卡跑一遍，零 error 再交确认。

## 1. 自包含骨架（可抄）

```html
<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>变更名 · L1 · 界面演示</title>
<style>
  :root{
    /* 配色 */
    --brand:#2563eb; --accent:#0d9488; --danger:#dc2626; --ink:#111827; --ink2:#4b5563; --line:#e5e7eb; --bg:#f8fafc; --card:#fff;
    /* 基调 */
    --fs1:22px; --fs2:16px; --fs3:13px; --sp:8px; --sp2:16px; --sp3:24px; --r:10px;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--ink);font:var(--fs2)/1.6 system-ui,"PingFang SC","Microsoft YaHei",sans-serif}
  .bar{position:sticky;top:0;z-index:9;padding:10px var(--sp3);background:#0f172a;color:#fff;font-size:var(--fs3)}
  .bar p{margin:2px 0}
  .wrap{max-width:1200px;margin:0 auto;padding:var(--sp3) var(--sp2)}
  .card{background:var(--card);border:1px solid var(--line);border-radius:var(--r);padding:var(--sp2)}
  .grid,.dirs{display:grid;gap:var(--sp2);grid-template-columns:repeat(auto-fit,minmax(260px,1fr))}
  h1,h2{margin:0 0 var(--sp);line-height:1.3} h1{font-size:var(--fs1)}
  .muted{color:var(--ink2)}
  .row{display:flex;flex-wrap:wrap;gap:var(--sp);align-items:center}
  .btn{padding:8px 14px;border:1px solid var(--brand);border-radius:8px;background:var(--brand);color:#fff;font:inherit;cursor:pointer}
  .btn:hover{filter:brightness(1.08)} .btn:disabled{opacity:.45;cursor:not-allowed}
  .btn.ghost{background:transparent;color:var(--brand)}
  input{width:100%;margin:var(--sp) 0;padding:8px 10px;border:1px solid var(--line);border-radius:8px;font:inherit}
  .err{color:var(--danger);font-size:var(--fs3);margin:4px 0 0}
  .tabs{display:flex;gap:var(--sp);border-bottom:1px solid var(--line);margin-bottom:var(--sp2)}
  .tabs a{padding:8px 12px;color:var(--ink2);text-decoration:none;border-bottom:2px solid transparent}
  .tabs a:target{color:var(--accent);border-color:var(--accent)}
  @media (max-width:480px){
    .wrap{padding:16px 8px} .grid,.dirs{grid-template-columns:1fr}
    .bar{font-size:12px;padding:8px 12px} .tabs{overflow-x:auto}
  }
</style>
</head>
<body>
<!-- 演示约束条 -->
<header class="bar">
  <p>变更名 <b>add-xxx</b> · 分档 <b>L1</b> · 生成 <b>2026-11-05 21:50</b> · <b>界面演示，非最终实现</b></p>
  <p class="bar-note">示意数据：本页条目、数字、图表均为虚构，仅用于确认布局与视觉。</p>
</header>
<main class="wrap">
  <!-- §2 模板 -->
</main>
</body>
</html>
```

## 2. 三档模板（接在 `<main>`）

### L1（默认档）

```html
<section id="l1">
  <h1>页面标题</h1>
  <p class="muted">本页要确认什么（区域/层级/控件）。</p>
  <div class="grid">
    <div class="card"><h2>区域一 · 顶部栏</h2><p class="muted">控件与顺序</p><div class="row"><button class="btn">主操作</button><button class="btn ghost">次操作</button></div></div>
    <div class="card"><h2>区域二 · 主体</h2><p class="muted">层级：标题 → 摘要 → 明细；示意数据在此</p></div>
    <div class="card"><h2>区域三 · 侧栏</h2><p class="muted">辅助信息与筛选位</p></div>
  </div>
  <h2>配色与基调</h2>
  <div class="row">主色 #2563eb · 辅色 #0d9488 · 中性阶 #f8fafc→#111827 · 字号 22/16/13 · 间距 8/16/24 · 圆角 10</div>
  <h2>空态</h2>
  <div class="card"><p class="muted">图标位 + 一句引导 + 主按钮</p></div>
</section>
```

### L2（L1 全部 + 每状态一屏 + 禁用/悬停态 + 错误文案位）

```html
<section id="l2">
  <h1>页面标题 · 状态流</h1>
  <nav class="tabs"><a href="#s-empty">① 空态</a><a href="#s-loading">② 加载</a><a href="#s-submit">③ 提交中</a><a href="#s-error">④ 校验失败</a></nav>
  <section class="card" id="s-empty"><h2>① 空态</h2><p class="muted">引导句 + 主按钮</p></section>
  <section class="card" id="s-loading"><h2>② 加载</h2><p class="muted">骨架屏/占位条，不用转圈图片</p></section>
  <section class="card" id="s-submit"><h2>③ 提交中</h2><input value="示例值"><div class="row"><button class="btn" disabled>提交中…</button><button class="btn ghost" disabled>取消</button></div></section>
  <section class="card" id="s-error"><h2>④ 校验失败</h2><input value="错误示例"><p class="err" role="alert">校验失败：请输入 6–20 位密码</p></section>
</section>
```

### L3（2–3 个方向并列，每方向按 L2 深度）

```html
<section id="l3">
  <h1>方向选择</h1>
  <p class="muted">先选方向，再细化到 L1/L2——每方向按 L2 深度出小样。</p>
  <div class="dirs">
    <article class="card"><h2>方向 A · 数据优先</h2><p class="muted">意图：一屏看尽指标。取舍：首屏密度高，窄屏需折叠。</p></article>
    <article class="card"><h2>方向 B · 流程优先</h2><p class="muted">意图：按步骤引导。取舍：首屏信息少，需多一步。</p></article>
  </div>
</section>
```

## 3. 元素对照表（缺一即不合格）

| 档 | 元素 | 落点 |
| --- | --- | --- |
| L1 | 主要区域划分 | `<main>` 内每区域一张 `.card` |
| L1 | 信息层级 | `h1→h2` + `.muted` 副文案 |
| L1 | 关键控件与其位置 | 按顺序摆 `.btn` / `input` |
| L1 | 字号/间距/圆角基调 | `:root` 的 `--fs*` / `--sp*` / `--r` |
| L1 | 配色 ≤3 主色 + 中性色阶 | `:root` 变量 + 色值清单 |
| L1 | 空态占位说明 | 图标位 + 引导句 + 主按钮 |
| L2 | L1 全部（继承） | 每个状态 section 重做一遍 |
| L2 | 每个状态一屏 | `.tabs` 锚点 + 每状态一个 `<section>` |
| L2 | 按钮禁用/悬停态 | `.btn:disabled` / `.btn:hover` 真按钮 |
| L2 | 错误提示文案位 | `.err[role=alert]` + 真实文案 |
| L3 | 2–3 个方向并列 | `.dirs` 内 2–3 个 `<article>` |
| L3 | 每方向一句意图 + 取舍 | article 首段 |
| L3 | 先选方向再细化 | 顶部说明 + 各方向按 L2 深度 |
| 全档 | 示意数据标注 | `.bar-note` 一句「均为虚构」 |

## 4. 窄屏适配核对点（片段在 §1 `<style>` 末尾）

- 390×844：`.grid/.dirs` 单列、约束条 12px、tabs 可滚。
- 桌面 ≥1280px 与窄屏各截一次，均不得横向滚动；窄屏不 `emulate`。

## 5. 零外链清单（交用户前核对）

- [ ] 无 `src` / `href` 指向 http(s) URL：禁 CDN、webfont、远程图。
- [ ] 无外链 `<link rel="stylesheet">` 与 `<script src=…>`；样式只在页内。
- [ ] 无 CSS 导入语句（`@` + `import` 写法）。
- [ ] 图标用 inline SVG 或 Unicode 字符；装饰用 CSS 形状/SVG。
- [ ] 不内联 base64 大图（>20KB 换 CSS/SVG）。
- [ ] 不连后端：无 fetch/XHR/WebSocket/localStorage；状态切换用 `:target`/`:checked`/`details` 或 ≤50 行 JS。
- [ ] 字体只用系统栈。
- [ ] 语义标签（`header`/`main`/`section`/`button`）齐备，正文对比度 ≥4.5:1。
- [ ] 单文件 ≤100 000 字节（`wc -c`）。

## 6. 自检四步卡（chrome-shared MCP）

```
1) new_page(url="file:///tmp/spec-flow/<change>/demos/<slug>.html")  # 必须新标签页
2) take_screenshot(pageId, fullPage=true)  # 核对约束条在顶、无空白、无横向滚动、无多余标语/说明/次要标签
   resize_page(pageId, width=390, height=844) → take_screenshot(pageId)  # 窄屏只截图核对
3) list_console_messages(pageId)  # 断言无 error、无 Failed to load resource（外链残留的硬信号）
4) close_page(pageId)  # 用完即关
```

给用户一律给宿主路径（`/tmp` ≡ `/data/tmp`）；落档见 §7。MCP 不可用时按降级表并声明缺口：

| 缺失 | 降级方式 | 证据缺口 |
| --- | --- | --- |
| chrome-shared MCP | 把宿主 `file:///data/tmp/...` 路径给用户，请其打开并截图回传 | UI 自检证据缺失 |

降级结论须标注「未做渲染自检」，**不得**称通过。

## 7. 路径与命名

| 场景 | 路径 |
| --- | --- |
| spec-plan 1.75 生成期 | `/tmp/spec-flow/<change>/demos/<slug>.html` |
| 宿主预览 | `file:///data/tmp/spec-flow/<change>/demos/<slug>.html` |
| 落档 | `openspec/changes/<change>/demos/<slug>.html` |
| `/plan` 场景 | `/tmp/ui-demos/<change>/<slug>.html`（易失即弃；宿主 `file:///data/tmp/ui-demos/...`） |

`slug` 用 kebab-case（如 `login-captcha-l1.html`）；多档多文件加 `-l1/-l2/-l3`。截图不落库，HTML 落库。

落档后预览：`file:///home/xuqinqin/develop/<repo>/` + 上表落档路径。
