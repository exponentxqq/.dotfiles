# 本地环境冒烟验证 · 操作手册

> 本文件是 [SKILL.md](SKILL.md) 的展开。命令一律以**容器内 agent 视角**书写，`<...>` 为占位符。
> 技能目录统一为 `~/.agents/skills/smoke-testing-local-env/`（容器与宿主同形路径）。

## 1. 拓扑与事实采集

### 1.1 拓扑模型

```
宿主机（服务所在）
├── docker 化工具链    ~/develop/docker/bin/*（pnpm/mysql/node… 包装脚本）、~/develop/docker/run.sh <svc> "<cmd>"
├── 中间件容器         mysql / postgres / redis / mongo / rabbitmq / rocketmq / nginx / dbx
├── 语言容器           node / java / go / python / rust（项目命令经包装脚本进容器）
├── 项目服务           Java 后端走宿主 wrapper；前端 pnpm dev 走 node 容器
└── 数据目录           /data

dsh 容器（agent + 浏览器）
├── 浏览器             chrome-devtools-mcp 运行在容器内 → localhost 是容器自己
├── 项目源码           HOST_PROJECT_PATH 同路径身份挂载（容器内同一绝对路径可见）
├── MCP                dbx（DB 查询）、codebase-memory、chrome-devtools
└── 网络               backend bridge，容器 IP 172.19.0.x
```

四条推论，必须内化：

1. **同路径挂载**：容器里能直接读项目源码、配置、`~/develop/docker/.env`，路径与宿主完全一致。
2. **写权限受会话沙箱约束**：默认只能写会话工作区；要写工作区外须显式申请授权，不得绕过。
3. **浏览器位置最易搞错**：容器内的 `localhost` ≠ 宿主，前端 `apiBase` 指向 `localhost` 时必断。
4. **容器内无 docker CLI**：不能管理宿主容器与宿主服务，"自己起一份"在此环境不可行——这也是 §2.5 红线的根因之一。宿主 `/data` 亦不在容器挂载内（仅 `/data/dsh` → `~/.dsh`）。

### 1.2 必采事实清单

| 事实 | 采集方式 | 影响 |
| --- | --- | --- |
| 宿主 IP | `grep '^DOCKER_HOST_IP=' ~/develop/docker/.env` | 一切跨容器访问的目标地址 |
| 服务端口与就绪 | `scripts/recon.sh <宿主IP> <端口...>` | 能否开始用例 |
| 后端实际端口/profile | 项目配置文件（如 `application-local.yml`） | 实际端口常与默认值不同 |
| 前端 dev 端口与 apiBase | `nuxt.config.ts` / `.env` / 运行配置 | 决定是否需要桥接 |
| CORS / 同源代理策略 | 后端安全配置、前端 devProxy | 决定能否跨源直连 |
| 外部组件真实/MOCK | 共享配置（如 `shared-platform.yml`） | 决定"真机"验收是否成立 |
| DB 连接与库名 | dbx `list_connections` | 落库证据来源 |
| 关键表结构 | dbx `describe_table` | 避免列名猜错 |
| 业务时区 | 项目架构决策 / 契约 desc | 时间类断言基准（§5.5） |

```bash
# 一次性采集（host 可省略：首参为纯数字时自动读 docker/.env 的 DOCKER_HOST_IP）
~/.agents/skills/smoke-testing-local-env/scripts/recon.sh 8080 8090 8091
grep -E '^(DOCKER_HOST_IP|HOST_PROJECT_PATH)=' ~/develop/docker/.env
```

## 2. 可达性与链路

### 2.1 服务可达性三态

```bash
# TCP 层：是否有监听
timeout 3 bash -c 'exec 3<>/dev/tcp/<host>/<port>' 2>/dev/null && echo TCP-OK || echo TCP-FAIL
# HTTP 层：是否有响应（000 = 连不上/被 reset）
curl -s -o /dev/null -w '%{http_code}\n' --connect-timeout 3 --max-time 5 http://<host>:<port><健康路径>
```

| 现象 | 含义 | 处置 |
| --- | --- | --- |
| HTTP 2xx/3xx | 服务就绪 | 继续 |
| TCP 拒绝（Connection refused） | 无监听 | 请服务归属方启动 |
| TCP 通 + HTTP `000` + `Connection reset by peer` | 端口被**残留转发**占用（旧容器 docker-proxy 未清） | 报告归属方，换路径或稍后重试，**勿反复重试、勿改配置** |
| TCP 通 + HTTP `000` + 超时 | 服务挂起或非 HTTP 协议 | 换健康路径；若是 HTTPS 服务改用 `SCHEME=https` |
| HTTP 5xx | 已监听但内部错误 | 先看服务日志，不要进入用例 |

> **服务日志在服务归属方（宿主终端）**，容器内看不到——需要时向用户索取，不要凭空推断。
> `recon.sh` 已内置三态判定（含 `SCHEME` 与 curl 退出码细分），优先直接用它。

### 2.2 浏览器位置判定（关键）

浏览器在容器内，用同一 URL 的两种写法交叉判定：

```
http://127.0.0.1:<端口>/<健康路径>     # 浏览器所在机（容器）
http://<宿主IP>:<端口>/<健康路径>       # 服务所在机（宿主）
```

- 前者失败、后者成功 → **不同机**，按 §2.3 桥接
- 两者都成功 → 同机，可直用 `localhost`

curl 只能证明「容器 → 宿主」网络连通；而**页面代码发起的 URL（apiBase、重定向）由浏览器解析**，所以链路判定必须在浏览器里做：

```js
// evaluate_script
() => fetch('/api/ping').then(r => r.text()).then(t => ({ origin: location.origin, ping: t }))
```

### 2.3 跨容器 TCP 桥接

仅当**前端 apiBase 是绝对 URL 且指向 `localhost`** 时需要（浏览器会直连容器自身的端口）。

```bash
# 容器侧起桥（对宿主零影响；容器重启即消失）
node ~/.agents/skills/smoke-testing-local-env/scripts/tcp-bridge.mjs 8080 <宿主IP> 8080
# 验证
curl -s http://127.0.0.1:8080/<健康路径>
```

注意：

- 桥接进程是**临时进程**，必须在报告里说明，并告知"容器重启即消失"。
- 同一端口只起一个；重复启动会 `EADDRINUSE`（脚本会明确提示，容器内无 `ss`/`netstat`，用 `ps aux | grep tcp-bridge` 排查）。
- 若桥接后浏览器仍报错，回到 §2.1 三态重新判定，不要叠加第二层代理。

### 2.4 CORS 与同源代理

| 前端形态 | 现象 | 处置 |
| --- | --- | --- |
| 开发期 `allowedOriginPatterns("*")` | 跨源可直接联调 | 正常直连 |
| CORS 关闭（如运营后台） | 跨源必失败 | 走其 dev server 的同源 proxy（如 `/api` → 后端），**不要绕过** |
| 前端 apiBase 为绝对 URL | 不受 dev proxy 影响 | 见 §2.3 桥接 |

跨源失败先查该配置，再怀疑代码。

### 2.5 红线（零侵入）

- **不改宿主任何项目配置/入库文件**（`.env`、`application-local.yml`、`nuxt.config.ts`、`.gitignore` 等）
- **不在容器内搭建第二套运行环境**（不下载 JDK/Node 依赖、不跑构建、不起 dev server）——冒烟只消费服务归属方已启动的服务
- **不在容器内执行项目构建**：项目级缓存目录被宿主 daemon 持锁，必然 `Timeout waiting to lock …`，且清理锁会干扰宿主
- 需要临时参数时用**命令行参数覆盖**（如 `--spring.datasource.url=…`），而非改配置
- 需要写工作区外文件时**显式申请授权**，不要用迂回方式绕过沙箱

## 3. 数据准备

### 3.1 先分清 MOCK 与真实组件

```bash
grep -rn "type: MOCK\|type: ALIYUN\|type: REAL" <共享配置目录>
```

| 组件 | 影响 |
| --- | --- |
| 短信/邮件 MOCK | 验证码可预测，但**必须查库取真值** |
| 实名认证 MOCK | 认证类用例可自动通过 |
| 存储真实（如 OSS） | 可做真机直传验证；私有桶存在性判定见 §5.3 |

### 3.2 验证码类：查库核对，禁止心算

MOCK 生成器通常有固定规则（例如"取 target 后 6 位"），但**规则细节（含前导零、目标字段取值）极易算错**：

```sql
select target, code, expires_at, used_at from <验证码表> order by id desc limit 3;
```

**限流**（典型值）：同号 60s 冷却 + 日 10 条；同 IP 10s + 日 50 条。
→ 整轮冒烟只用一个新手机号，重试间隔 >60s，优先查库回捞已发码而不是反复重发。

### 3.3 校验位类字段：算法生成

身份证、统一社会信用代码等前端会按国标校验，**必须生成合法值**。身份证示例：
权重 `[7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2]` → 加权和 mod 11 → 映射 `10X98765432`。
例：`33010619900101123` + 校验位 `X` = `33010619900101123X`。

### 3.4 密码类：先读规则再定值

复杂度规则（长度、大小写、数字、特殊符号）以代码或文案为准，**不要先猜后试**——失败次数多会触发风控或锁号。

### 3.5 数据隔离与可追溯

- 名称/标题带可检索前缀（如 `冒烟`），便于事后清理
- 记录全部主键（企业/账号/业务单 id）与外部对象 key，写入报告"测试数据"节
- 不要为了凑用例硬造前置数据（如"无企业账号"这类无法自然构造的场景，标注"已由单测覆盖"）

### 3.6 dbx 使用纪律

1. **先 `describe_table` 再写 SQL**——业务列名常与直觉不符
2. 只读验证优先；写操作前明确影响面与回滚方式
3. 落库核验要查**状态机字段 + 时间戳**（如 `status`、`published_at`），不要只看行数

## 4. 浏览器操作配方

### 4.1 快照优先，DOM 兜底

`take_snapshot` 拿 uid 做交互；但 **a11y 树可能不展开自定义组件选项**（下拉在快照里是空 listbox，实际 DOM 有 N 项）。断言一律回落 DOM：

```js
() => Array.from(document.querySelectorAll('[role="listbox"]'))
        .filter(p => p.offsetParent !== null)
        .map(p => Array.from(p.querySelectorAll('[role="option"]')).map(o => o.textContent.trim()))
```

### 4.2 自研组件的通用交互模型

若前端不是标准组件库（自研 `form-*` 组件常见），按 ARIA 角色定位：

| 组件 | 结构 | 操作 |
| --- | --- | --- |
| 单选/多选下拉 | `role=listbox` + `role=option` div | `opt.click()` |
| 日期选择 | `role=dialog` + 日期 `button`；有"选择年份"切年视图 | 点日期按钮；用 `disabled` 判定禁选 |
| 级联/字典 | 多级 `role=listbox` 并列 | 逐级点击，取**最后一级面板**的 option |
| 触发器 | `button[aria-haspopup]` + `aria-label` | 用 `aria-label` 定位 |

先探测再断言：

```js
() => Array.from(document.querySelectorAll('button[aria-haspopup]')).map(b => b.getAttribute('aria-label'))
```

### 4.3 一次调用只做一个动作

**连续同步点击同一面板的多个选项只有最后一个生效**（框架响应式异步）。必须一次 `evaluate_script` 点一个，下一次调用再点下一个。

### 4.4 瞬时提示必须预埋监听

`ElMessage`/Toast 默认 3 秒消失，MCP 往返常已错过。**在触发动作前**安装监听，动作后再读取：

```js
() => {
  window.__captured = [];
  new MutationObserver(() => {
    document.querySelectorAll('.el-message, [role="alert"]').forEach(e => {
      const t = e.textContent.trim();
      if (t && !window.__captured.includes(t)) window.__captured.push(t);
    });
  }).observe(document.body, { childList: true, subtree: true });
  return 'observer installed';
}
```

注意：**页面导航会清空该变量**，跨页断言需在目标页重新安装。

### 4.5 文件上传

`upload_file` 可注入容器内文件；隐藏 input 需先 `take_snapshot` 拿 uid（快照里表现为带 `value="No file chosen"` 的 button）。

准备四类文件：合法小文件、超限文件（>上限）、非法扩展名、用于数量上限的多个副本。

```bash
dd if=/dev/urandom of=/tmp/oversize.pdf bs=1M count=21   # 21MB，按上限调整
```

上传后核对：UI 入列 → `presign` 200 → `PUT` 200 → 落库行 → 对象存在（§5.3）。

### 4.6 需要 token 的接口测试

浏览器里拿不到的场景（跨账号、构造非法前置），从凭据存储取 token 后走 curl：

```js
() => JSON.parse(localStorage.getItem('<凭据存储键>'))
// 键名与结构见项目画像 §5（例：{ token, user: { companies: [{ companyId, role }] } }）
```

```bash
curl -s -X POST "http://127.0.0.1:<端口>/api/v1/<资源>/<动作>" \
  -H "<认证头>: <token>" \
  -H 'Content-Type: application/json' -d @/tmp/body.json
```

**认证头名称（如 `Authorization: Bearer` / `X-Token` + `X-Company-Id`）与凭据存储键是项目事实，记在项目画像 §5，不要在本文件硬编码。**

**注意**：用 curl 构造的负例只是补充证据，**核心链路必须由浏览器真机走通**。

### 4.7 缓存造成的"无请求"假象

前端字典/枚举常有内存 + localStorage 缓存（典型 24h TTL），命中即不发请求。
**不要以"没有网络请求"判定加载失败**，直接断言 localStorage 或 DOM 选项：

```js
() => JSON.parse(localStorage.getItem('<缓存键>') || '{}')
```

### 4.8 网络证据导出

- `list_network_requests`：按 URL 过滤，拿端点与状态码
- `get_network_request`：导出**真实请求体**（`requestFilePath`/`responseFilePath` 落盘后读）
- 契约与实现不一致时，**以真实请求体为准**（典型：契约写 `type: date`，实际必须传毫秒时间戳）

### 4.9 控制台零 error

收尾前 `list_console_messages` + `includePreservedMessages: true` 确认零 error；有 error 必须定位根因或明确记为观察项。

### 4.10 等待与稳定

| 场景 | 做法 |
| --- | --- |
| 等待文本/状态出现 | `wait_for`（传文本数组，任一命中即返回），**不要 sleep 轮询** |
| 纯读取 DOM/状态 | `evaluate_script` 传 `waitForStableDom: false`，省去稳定等待 |
| 动作后断言 | 触发与断言拆成两次调用，中间用 `wait_for` 收口 |
| dev 热重载整页刷新 | 快照 uid / `window.__captured` 会突然失效：先 `navigate_page reload` 重新取态，再重装 observer（§4.4），**不要在旧引用上继续断言** |
| 请求发出但 UI 未更新 | 先查 `list_network_requests` 确认响应，再判前端状态问题 |

## 5. 证据与判定

### 5.1 三层证据链（缺一不可）

| 层 | 证据 |
| --- | --- |
| UI | 页面文本/状态、截图 |
| 网络 | 端点、状态码、请求/响应体 |
| 持久化 | 落库行（含状态机字段、时间戳）、外部对象存在性 |

"页面提示成功"不构成通过；"接口 200"也不构成通过。

### 5.2 正例基准先行，再跑负例矩阵

负例全部返回同一错误码（如全 `1003 参数异常`）时，**先怀疑基准 payload 本身不合法**：先用基准跑一次正例，通过后再逐项变更单字段构造负例。

负例矩阵组织（每次只改一个字段）：

| 用例类型 | 变更方式 | 期望 |
| --- | --- | --- |
| 数量超限 | 列表 +1 | 业务错误码 |
| 区间倒置 | min > max | 业务错误码 |
| 边界值 | 截止时间 = 当天 | 业务错误码 |
| 层级/枚举非法 | 传子级码 / 伪码 | 参数错误码 |
| 状态非法 | 重复执行已完成的动作 | 状态错误码 |
| 越权/不存在 | 他方 id / 不存在 id | 权限/不存在错误码 |

### 5.3 外部对象存在性判定

私有桶下**不能用 200 判定存在**：

| 返回 | 含义 |
| --- | --- |
| `403 AccessDenied` | 对象存在，ACL 私有（正常） |
| `404 NoSuchKey` | 对象不存在 |

### 5.4 观察项与阻塞项分开

- **阻塞项**：使验收不成立的问题（必须修复后才能勾选任务）
- **观察项**：与本次任务无关的既有问题，或"比设计更严格"的实现差异（例如越权请求被更前置的权限校验拦截，而非契约设计的错误码）——记录并写明影响面与建议归属，**不动本次结论**

### 5.5 时间与时区断言

- 时间类字段的业务时区**以项目画像 §0 为准**（如 Asia/Shanghai GMT+8），不要按容器本地时区解读。
- 两类高频误判：
  - **UTC 截断**：库/接口存 UTC，前端按业务时区渲染，差值落在跨日边界即显示"早一天/晚一天"。
  - **跨天边界**：断言"当天"相关规则（如截止日期禁选今天）时，先确认"今天"按哪个时区计算。
- 比对顺序：DB 时间戳 → 按业务时区换算 → 与 UI 显示串比对；出现 ±1 天 / ±8h 差异，**先查时区再怀疑业务逻辑**。

## 6. 用例矩阵模板

按"能力组"切分，组内正反例并列，标注结果与证据：

```
A 账号与身份      注册/发码/登录态/资料完善
B 页面与表单      渲染/字典项数/计数/边界禁用/前端校验拦截
C 外部组件链路    正例（签名→上传→入列）+ 超限/类型/数量反例 + 对象存在性
D 本地状态        草稿暂存/恢复/清除、缓存命中
E 提交编排        提交成功→跳转→落库→入口导航
F 状态流转与负例  流转成功 + 错误码矩阵（curl + 落库核验）
G 补充            无法自然构造的场景（单测已覆盖则标注"未浏览器验证"）
```

## 7. 收尾与归档

### 7.1 报告骨架（固定）

```
标题：<任务号> <能力名> —— 全链路冒烟报告
一、测试环境        服务地址/profile/MOCK 组件/测试账号（含桥接说明与 MCP 降级声明）
二、用例结果矩阵    分组表格：用例 | 结果 | 证据
三、观察项          编号 + 影响面 + 建议归属任务
四、外部组件结论    如真机直传的证据链
五、证据文件        截图清单
六、测试数据        产生的主键与对象 key（便于清理）
```

### 7.2 归档位置

- 浏览器冒烟报告 + 截图 → `openspec/changes/<change>/artifacts/`（**gitignore 忽略，不入库**）
- 纯接口/构建类冒烟记录 → `<change>/smoke-record.md`（入库，随 change 归档）
- 无 openspec 的项目：放项目约定的 `docs/` 或 `artifacts/`，并在画像里写明

### 7.3 清理清单

1. 删除容器内临时环境（JDK/Gradle 副本、大文件等）
2. 保留必需的桥接进程并**在报告中说明**（含"容器重启即消失"）
3. 测试数据默认保留作为痕迹，在报告"测试数据"节列明，由用户决定是否清理

### 7.4 工作区洁净核验（必须）

```bash
cd <根仓> && git status --short
cd <子仓1> && git status --short
cd <子仓2> && git status --short
```

各仓只允许出现**预期的**新增文件。冒烟期间禁止产生任何入库文件改动（含格式化、codegen 产物）。

## 8. 陷阱全表

| # | 陷阱 | 根因 | 规避 |
| --- | --- | --- | --- |
| 1 | 端口 TCP 通但 HTTP 被 reset | 残留转发占用 | 报告归属方，勿反复重试 |
| 2 | 浏览器报 `ERR_CONNECTION_REFUSED` 访问 `127.0.0.1` | 浏览器在容器内 | 容器侧 TCP 桥接（§2.3） |
| 3 | MOCK 验证码心算算错 | 规则细节未核对 | 一律查库（§3.2） |
| 4 | 校验位字段被拒 | 号码非法 | 算法生成（§3.3） |
| 5 | 快照里自定义组件选项为空 | a11y 树未展开 | 回落 `role="option"` DOM 查询 |
| 6 | 连续点多个选项只生效一个 | 响应式异步 | 一次调用只点一个 |
| 7 | 字典"没发请求" | 命中缓存 | 断言 localStorage/DOM，非网络 |
| 8 | 提示消息抓不到 | 3 秒消失 | 触发前预埋 MutationObserver |
| 9 | 契约字段格式不符 → 参数异常 | 契约滞后于实现 | 以真实请求体为准 |
| 10 | 负例全返同一错误码 | 基准 payload 非法 | 先跑正例基准 |
| 11 | dbx 报 `Unknown column` | 列名与直觉不符 | 先 `describe_table` |
| 12 | 容器内构建报锁超时 | 宿主 daemon 持锁 | 禁止在容器内构建 |
| 13 | 私有桶 403 误判为失败 | 未区分 403/404 语义 | 403=存在，404=不存在 |
| 14 | 页面导航后 observer 丢失 | 变量随文档销毁 | 目标页重新安装 |
| 15 | 报告/截图污染 git | 归档位置错 | 归档到 gitignore 目录，收尾核验 |
| 16 | 容器内起第二套服务 | 想"自己跑一份" | 只消费宿主已启动的服务 |
| 17 | 改宿主配置以适配测试 | 图省事 | 命令行参数覆盖或桥接 |
| 18 | 写工作区外文件被沙箱拒绝 | 未申请授权 | 显式申请，不绕过 |
| 19 | 时间断言差 1 天 / 8 小时 | 按容器本地时区解读 | 按画像业务时区断言（§5.5） |
| 20 | 断言中途 DOM/快照突然失效 | dev 热重载整页刷新 | reload 重新取态、重装 observer（§4.10） |
| 21 | 端口排查命令 not found | 容器内无 ss/netstat/lsof | 用 `ps aux | grep <进程>` |

## 9. 项目画像字段

见 [project-profile-template.md](project-profile-template.md)。字段与采集方式对应关系：

| 画像字段 | 采集方式（§1.2） |
| --- | --- |
| 业务时区（时间断言基准） | 项目架构决策文档 / 契约 desc |
| 服务清单（端口/启动方式/健康路径/日志归属） | `recon.sh` + 项目 README/AGENTS.md |
| 前端接入（dev 端口/apiBase/CORS） | `nuxt.config.ts`、`.env`、后端安全配置 |
| 数据存储（连接/库/关键表） | dbx `list_connections`、`describe_table` |
| 外部组件（真实/MOCK/开关） | 共享配置 grep |
| 账号与凭据、认证头、凭据存储键 | 项目 AGENTS.md / 前端请求层代码 / 本次准备 |
| 已知坑 | 历次冒烟报告的观察项 |
