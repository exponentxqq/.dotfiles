---
name: spring-writer
description: Use when writing, modifying, or reviewing any Java/Spring Boot code — controllers, services, repositories, domain objects, async tasks, event-driven patterns, MQ consumers, migrations, tests.
---

# Spring/Java 开发规范

## 核心原则

1. **写前先读** — 每写一个类前，先读同模块 2-3 个已有类，模仿其方法命名、查询方式、异常类型、注解组合、import 风格
2. **声明式优于编程式** — Spring/官方提供注解、filter、策略就不要手写样板（如真实 IP 用 `server.forward-headers-strategy: framework`，不手写 XFF 解析）
3. **Domain 是业务核心** — 不依赖 Spring bean 的逻辑全部放 domain；service 纯调度；repository 只管持久化
4. **最小改动** — 只改任务相关文件，不碰无关文件，不做范围外的"锦上添花"；完成后主动报告功能完整性与副作用
5. **先方案后执行** — 复杂改动先给方案（方案A/B/C）供选择，确认后再动手；不主动提交，收到指令才提交

## 分层与依赖

- 依赖单向：`component`（跨项目基建）← `modules`（项目级）← `app`；基础层禁止反向依赖业务模块
- component/基础层不抛 `BusinessException`/引用 `ErrorCode`（依赖方向做不到）——抛基础异常，或定义 protected 钩子方法（如 `notFoundException()`）供业务子类覆盖
- service 不 import controller 层对象（尤其带版本号的 `controller.v1.*`）；需要时方法用平铺参数
- 不新建语义重复的类型、无消费方的字段；已有字段能表达就不新增状态
- 请求级上下文收敛为单一 `RequestContext`（filter 一次性装配），业务方直接读取；不维护多套 ThreadLocal/参数解析器机制

## 领域建模

- 状态/类型字段一律用 enum，不用 String；枚举持久化用 tinyint code + 统一 `IEnum` 接口 + 自动转换器（漏 `implements IEnum` 会运行时 ClassCastException）
- 字段映射收敛为 `ofXxx` 静态工厂方法，消灭各处重复 toView；需要后续注入的字段用 `withXxx` 原地修改返回 this，不为领域类开 setter
- 同实体多形态记录用 `type` 判别字段区分，不堆叠可选列；查询方法显式带 type（如 `findByXxxAndType`），删除有歧义的方法
- DB not null/唯一约束已保证的不可能状态，不写防御分支（YAGNI），对应"模拟不可能状态"的测试一并删除
- 领域事件继承 BaseEvent；行为方法原地修改自身并返回 this

## 事务、事件与 MQ

- 事务方法触发异步 → `eventPublisher.publishEvent()` + `@TransactionalEventListener(phase = AFTER_COMMIT, fallbackExecution = true)` 接 `@Async` 方法（MQ 发送等副作用放在这个提交后的异步方法里）。事件监听器属于次级流程：listener 内 try-catch 吞异常打日志（失败不回滚主流程）。注意 afterCommit 内异常会被吞——重要不变量须有补偿路径
- MQ 发送必须放在事务提交后（AFTER_COMMIT），禁止与落库同事务（幽灵消息/读未提交竞态）
- MQ 消费者必须幂等（写前置守卫或业务唯一键 upsert）；事件只是信号，去重是监听器职责
- MQ 消费者异常分类处理（MQ 有重投机制，与上面吞异常的事件监听器相反）：`BusinessException`（不可恢复）捕获吞掉避免无意义重试；可恢复异常 rethrow 触发重投
- 并发写终态用 CAS 条件更新（`UPDATE ... WHERE status IN (...)`，affectedRows=1 才继续），败者静默放弃且不执行副作用；禁止无锁 finish + save
- 依赖事件/回调保证的重要不变量，配 `@Scheduled` 按数据状态扫描的兜底任务（开关 `app.schedule.*.enabled` + `@ConditionalOnProperty`，多实例部署注意门控）
- 统计/聚合：事件触发**全量重算** + 业务唯一键 upsert（天然幂等），不用增量累加（增量复杂且易不一致）
- 异步事件链路的防重锁由单一入口获取/释放，禁止链路内二次加锁（嵌套加锁遇异常被吞 → 永久阻断）

## 数据与持久化（Easy Query）

- 单结果 → `singleOptional().map(CONVERTER::toDomain)`；批次插入 → `insertable(entities).batch().executeRows(true)`；`updatable(entity)` 默认跳过 null 列，显式清空用表达式更新
- Repository 命名：`getByXxx` 抛异常，`findByXxx` 返回 Optional
- repository 写方法参数直接传 domain 对象，不拆扁平参数列表（部分列更新须 javadoc 明示）
- Entity 的 `Instant` 字段必须配 `@Column(conversion = InstantConverter.class)`——datetime 列不会自动转 Instant，运行时 ClassCastException
- Entity 不重复声明 DB 自动维护的列（createdAt/updatedAt）
- 数值型统计字段不允许 null，统一 `BigDecimal.ZERO` 兜底
- 不用物理外键，用业务唯一键（如 `uk(biz_id, dimension_code)`）+ 应用层约束
- 聚合/统计查询必须带业务维度过滤条件（week/times 等），防跨期数据污染
- 新 repository 继承 `BaseRepository`（component 层）；聚合根多表场景由子类自行实现；CRUD 路径避免运行期反射

## Migration（Flyway）

- 已应用/已部署（test/prod）的 migration 绝不修改，变更一律新增版本号；未发布的可直接改原文件或整体删除
- 无历史数据不写数据迁移脚本；仅改注释/无 schema 变更不写 migration
- migration 内多个 ALTER 合并为单条语句；表字段必须加中文 comment
- 多 app 共库：schema 由单一 app 统一管理（其余 app 关 flyway），`validate-on-migrate` 保持 true
- 手动修复 SQL 不放 `db/migration` 目录（会被 Flyway 拾取）

## 异常与错误码

- 业务层统一 `BusinessException` + `ErrorCode`，不建异常子类
- 业务 ErrorCode 放各自业务 api 模块，枚举 `implements BaseErrorCode`（component/core 定义接口）；码值全局唯一并分段（通用 1xxx、各业务 2xxx/3xxx/...、组件层 9xxx）
- 新增 ErrorCode 枚举须同步全局撞号守护测试清单 + 各枚举专属测试

## 配置

- 第三方/平台组件用 `@ConditionalOnProperty` + `xxx.enabled` 开关条件装配
- yml 环境变量占位符必须给非空兜底默认值（`${VAR:}` 空兜底会引发 400）；功能相同的多条链路兜底值保持一致
- 业务配置写 `application-{profile}.yml`（Spring 管理），不放部署层（helm/ConfigMap）
- 多 app 共享配置抽到公共模块（`spring.config.import: optional:classpath:` + 多 profile YAML 文档去重）
- 日志按 profile 区分：local 写文件（按天滚动）+ console，非 local 仅 stdout 供采集

## 安全与外部交互

- token/敏感标识 DB 存 digest（SHA-256），domain 层保持 raw token，转换收敛在 repository（客户端零感知）
- 响应结构已知时用类型安全的 envelope record 反序列化，不用 `Map<?,?>`
- 上传/存储路径确定性（含业务维度，如 `/{业务}/{bizId}/{子类}/{序号}.mp3`），幂等覆盖，不用随机 UUID
- 大数据量导出必须流式（SXSSF + 分页 Consumer 增量追加 + 进度持久化），禁止全量加载内存
- 多路并行子任务部分失败 → 整体失败可重试，禁止静默丢弃缺内容的结果
- 前后端共用的公式/常量必须两端一致，用测试断言（ArgumentCaptor）锁定防回归

## 测试纪律

- 新改动要求 100% 覆盖（jacoco 行+分支）——含事务双分支；对确需保留的防御分支（如 repository 锁方法）也必须覆盖。但不要为覆盖而新增防御分支（见「领域建模」YAGNI 条）
- 涉及 DB 的测试真实连项目测试库；mock 白名单仅限：外部 API（微信/阿里云/讯飞/LLM）+ 基础设施（OSS/MQ/Redis）
- 枚举/关键词矩阵用 `@ParameterizedTest` + `@ValueSource` 收敛；`ofXxx` 工厂测试须字段对称覆盖
- LLM prompt 要求 JSON 输出时，走真实解析链路（MockWebServer + 真实 model）验证，不 mock chatClient
- 对外契约（类/字段名）重命名：先查消费方，改后用 JSON 序列化契约测试锁定（断言含新名不含旧名）
- e2e 依赖异步回调的断言用轮询收敛（awaitUntil），不用同步 Executor 强行覆盖
- Lombok/MapStruct/Easy Query 引发的 LSP 误报不算错，以 gradle 编译结果为准

## 代码风格

- 成员变量 → 构造函数注入（`@RequiredArgsConstructor`）；静态常量放在成员变量之前；日志 `@Slf4j`
- Converter 用 MapStruct，`INSTANCE` 静态工厂引用（非 Spring 注入）；JSON 字段转换走 JsonUtil default 方法
- 表名前缀与类名对齐（`statistic_*` 表 ↔ `Statistic*` 类）
- Javadoc 只写 `@param` / `@return` 有非显而易见语义时才加描述

## 写完自查

```bash
./gradlew :modules:<module>:<submodule>:compileJava && ./gradlew spotlessApply
```

- [ ] 拼写无 typo；无 unused import；无 wildcard import
- [ ] 新改动测试 100% 覆盖（行+分支），DB 测试真实连库
- [ ] 模式一致性：与同模块已有代码风格匹配
- [ ] 逻辑层次：不依赖 bean → domain；跨 repository 协调/事务边界 → service；持久化 → repository
- [ ] 时序正确：事务提交后才发事件/MQ；消费幂等；终态 CAS
- [ ] 主动报告功能完整性与副作用；不主动提交
