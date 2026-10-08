# 项目冒烟画像 · <项目名>

> 复制本文件到项目仓（建议 `docs/smoke-test-profile.md`）后按实际填写。
> **通用规程在 `smoke-testing-local-env` 技能里，本文件只放项目专属事实。**
> 采集方式见技能 `reference.md` §1.2。

## 0. 基本信息

| 项 | 值 |
| --- | --- |
| 项目根（宿主绝对路径） | `/home/xuqinqin/develop/<...>` |
| 语言 / 构建 | 例：Java 17 + gradle wrapper（宿主）/ Nuxt 4（node 容器） |
| 被测里程碑 / 任务号 | 例：T2.1 需求发布 |
| 业务时区 | 例：Asia/Shanghai（GMT+8）——时间类断言与显示比对的基准，见技能 reference §5.5 |
| 画像更新日期 | YYYY-MM-DD |

## 1. 服务清单

| 服务 | 宿主端口 | 启动方式（谁启动） | 健康路径 | 日志/归属 | 备注 |
| --- | --- | --- | --- | --- | --- |
| 后端 API | 例 8080 | 宿主 `./gradlew bootRun`（用户自行启动） | `/api/ping` | 宿主终端（向用户索取） | 实际端口以 `application-local.yml` 为准 |
| 用户端前端 | 例 8090 | 宿主 `pnpm dev`（node 容器） | `/` | 宿主终端（向用户索取） | |
| 运营后台前端 | 例 8091 | 宿主 `pnpm dev`（node 容器） | `/` | 宿主终端（向用户索取） | |

> 容器内看不到宿主服务日志；「日志/归属」列写清日志在哪、由谁提供。

## 2. 前端接入

| 项 | 值 |
| --- | --- |
| dev 端口 | |
| apiBase（含是否绝对 URL） | 例：`http://localhost:8080/api`（绝对 URL → 需容器侧桥接） |
| dev proxy 规则 | 例：`/api` → `http://localhost:18091`（同源） |
| 后端 CORS 策略 | 例：开发期 `allowedOriginPatterns("*")` / 关闭（必须同源代理） |

## 3. 数据存储

| 项 | 值 |
| --- | --- |
| dbx 连接名 | 例：`localhost@mysql5.7` |
| 库名 | 例：`opc` |
| 关键表 | 例：`demands`（状态机 `status`、`published_at`）、`demand_attachments` |
| 基线查询 | 例：`select count(*) from demands;` |
| 列名陷阱 | 例：`deadline` 不是 `response_deadline`；附件表是 `size` 不是 `file_size` |

## 4. 外部组件

| 组件 | 真实 / MOCK | 开关位置 | MOCK 产出规律 | 验证方式 |
| --- | --- | --- | --- | --- |
| 短信验证码 | MOCK | `shared-platform.yml` `component.sms.type` | 例：target 后 6 位 | **查库核对**（限流：同号 60s/日 10 条） |
| 实名认证 | MOCK | `component.certification.type` | 自动通过 | 走接口 |
| 对象存储 | 真实（OSS） | 配置中 `aliyun` 段 | — | 私有桶 403=存在 / 404=不存在 |

## 5. 账号与凭据

| 用途 | 账号 | 密码 / 取码方式 | 来源 |
| --- | --- | --- | --- |
| 主流程账号 | 例 13800138000 | 例 `Test123456!`（须含大小写+数字+特殊符号） | 本次冒烟新建 |
| 验证码 | — | 查 `account_verify_codes` | — |

**接口认证**（curl 补充用例所需，技能 §4.6 会引用本项）：

- 认证头：例 `Authorization: Bearer <token>`，或 `X-Token: <token>` + `X-Company-Id: <companyId>`
- 凭据存储键：例 localStorage `auth-store`，结构 `{ token, user: { companies: [{ companyId, role }] } }`

## 6. 字典与枚举

| type | 来源 | 缓存位置 / TTL | 备注 |
| --- | --- | --- | --- |
| 例 DEMAND_TYPE | 表 `dict_items` | localStorage `dict-store` / 24h | 命中缓存时无网络请求属正常 |

## 7. 用例入口

| 功能 | 入口路径 | 前置数据 |
| --- | --- | --- |
| 例：需求发布 | 登录 → `/account` → "去需求广场发布" | 已完善企业资料的账号 |

## 8. 已知坑（项目专属）

| # | 现象 | 说明 |
| --- | --- | --- |
| 1 | | |

## 9. 归档约定

| 项 | 值 |
| --- | --- |
| 报告路径 | 例：`openspec/changes/<change>/artifacts/browser-smoke-<date>.md`（gitignore） |
| 接口冒烟记录 | 例：`<change>/smoke-record.md`（入库） |
| 截图目录 | 例：`openspec/changes/<change>/artifacts/` |
| 测试数据清理 | 默认保留痕迹，报告"测试数据"节列明 |
