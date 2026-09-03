---
name: spring-writer
description: Use when writing, modifying, or reviewing any Java/Spring Boot code — controllers, services, repositories, domain objects, async tasks, event-driven patterns, MQ consumers, migrations, tests.
---

# Spring/Java 开发规范

## 核心原则

1. **写前先读** — 每写一个类前，先读同模块 2-3 个已有类，模仿其方法命名、查询方式、异常类型、注解组合、import 风格
2. **声明式优于编程式** — Spring/官方提供注解、filter、策略就不要手写样板（如真实 IP 用 `server.forward-headers-strategy: framework`，不手写 XFF 解析）
3. **Domain 是业务核心** — 不依赖 Spring bean 的逻辑全部放 domain；service 纯调度；repository 只管持久化
4. **最优改动** — 任务实现选最优方案而非最小 diff；被本次改动波及的存量（调用方、受影响测试、规范收紧涉及的存量）一并改到位；无关文件的问题只报告不擅动；完成后主动报告功能完整性与副作用
5. **优先设计模式** — 写新功能前先考虑是否有成熟设计模式（策略/模板方法/工厂/责任链等）可套用，避免堆叠 if-else 分支
6. **不重复造轮子** — 工具方法优先用 `component/utils` 已有的（`JsonUtil`、`CryptUtil`、`HashUtil`、`RandomUtil`、`UuidGenerator`、`HttpUtil`、`FileTypeUtil`、`@Timed`），其次 Guava（`Strings`、`Lists`、`Maps`、`Joiner`、`Preconditions`）；都没有才自写，自写实现也基于二者拼装，不裸写 JDK 样板

## 分层与依赖

- 依赖单向：`component`（跨项目基建）← `modules`（项目级）← `app`；基础层禁止反向依赖业务模块
- component/基础层不抛 `BusinessException`/引用 `ErrorCode`（依赖方向做不到）——抛基础异常，或定义 protected 钩子方法（如 `notFoundException()`）供业务子类覆盖
- service 不 import controller 层对象（尤其带版本号的 `controller.v1.*`）；需要时方法用平铺参数
- 不新建语义重复的类型、无消费方的字段；已有字段能表达就不新增状态
- 请求级上下文收敛为单一 `RequestContext`（filter 一次性装配），业务方直接读取；不维护多套 ThreadLocal/参数解析器机制
- service 接口只在对外（被其他模块依赖）时定义；模块内部使用的直接定义 `@Service` class，不建单一实现的空接口
- 只有 implements interface 的同名 service 才加 `Impl` 后缀（`XxxService` 接口 → `XxxServiceImpl`）；无接口的 service 直接命名 `XxxService`，禁止无接口也带 Impl
- 模块内依赖单向：`boot → controllers(web) → service → repository → api`；controller 按域拆 web 模块（candidate-app 下 `candidate-app:controllers:<domain>-web`，包名 `com.fyzs.interviewer.<domain>.web.v1`；console-app 当前单模块 `console-app:controllers`），后台消费逻辑放 `worker-app:consumers`；新 service/repository/api 放 `modules:<domain>:<domain>-<层>`
- 跨域（跨模块）调用走 `contract:*` 模块的 Feign client，不直接依赖对方业务模块

## 领域建模

- 状态/类型字段一律用 enum，不用 String；枚举持久化机制（IEnum/转换器）见「数据持久化与 ORM」对应 ORM 文件
- 字段映射收敛为 `ofXxx` 静态工厂方法，消灭各处重复 toView；需要后续注入的字段用 `withXxx` 原地修改返回 this，不为领域类开 setter
- 同实体多形态记录用 `type` 判别字段区分，不堆叠可选列；查询方法显式带 type（如 `findByXxxAndType`），删除有歧义的方法
- DB not null/唯一约束已保证的不可能状态，不写防御分支（YAGNI），对应"模拟不可能状态"的测试一并删除
- 由 `getXxx`（查不到即抛 ErrorCode）获得的引用，下游不再判 null；但经 JSON 反序列化恢复的对象（如 LangGraph state hydration）字段可能为 null，此类防御分支可达，保留
- 领域事件继承 BaseEvent；行为方法原地修改自身并返回 this
- 传输载体分离：领域计算 → 持久化的中间结果用独立类型（如 `OverviewDelta` record），不用领域对象兼作「快照」与「增量」两种语义

## 事务、事件与 MQ

- 事务方法触发异步 → `eventPublisher.publishEvent()` + `@TransactionalEventListener(phase = AFTER_COMMIT, fallbackExecution = true)` 接 `@Async` 方法（MQ 发送等副作用放在这个提交后的异步方法里）。事件监听器属于次级流程：listener 内 try-catch 吞异常打日志（失败不回滚主流程）。注意 afterCommit 内异常会被吞——重要不变量须有补偿路径
- MQ 发送必须放在事务提交后（AFTER_COMMIT），禁止与落库同事务（幽灵消息/读未提交竞态）
- MQ 消费者必须幂等（写前置守卫或业务唯一键 upsert）；事件只是信号，去重是监听器职责
- MQ 消费者异常分类处理（MQ 有重投机制，与上面吞异常的事件监听器相反）：`BusinessException`（不可恢复）捕获吞掉避免无意义重试；可恢复异常 rethrow 触发重投
- 并发写终态用 CAS 条件更新（`UPDATE ... WHERE status IN (...)`，affectedRows=1 才继续），败者静默放弃且不执行副作用；禁止无锁 finish + save
- 依赖事件/回调保证的重要不变量，配 `@Scheduled` 按数据状态扫描的兜底任务（开关 `app.schedule.*.enabled` + `@ConditionalOnProperty`，多实例部署注意门控）
- 统计/聚合：事件触发**全量重算** + 业务唯一键 upsert（天然幂等），不用增量累加（增量复杂且易不一致）
- 异步事件链路的防重锁由单一入口获取/释放，禁止链路内二次加锁（嵌套加锁遇异常被吞 → 永久阻断）

## Repository 通用约定

- Repository 命名：`getByXxx` 抛异常，`findByXxx` 返回 Optional
- repository 写方法参数直接传 domain 对象，不拆扁平参数列表（部分列更新须 javadoc 明示）
- 数值型统计字段不允许 null，统一 `BigDecimal.ZERO` 兜底
- 不用物理外键，用业务唯一键（如 `uk(biz_id, dimension_code)`）+ 应用层约束
- 聚合/统计查询必须带业务维度过滤条件（week/times 等），防跨期数据污染

## 数据持久化与 ORM

项目可能使用不同 ORM 框架；上节为跨 ORM 通用规则，ORM 专属规则按框架拆分在本目录 `orm/` 下。写/改 repository、entity、converter，或遇到 ORM proxy/转换器相关编译与运行时错误时，先确认项目所用 ORM 并阅读对应文件：

- Easy Query → `orm/easy-query.md`（查询/更新 API、枚举持久化 IEnum、@Navigate 关联加载、ValueConverter/复杂类型映射、审计基类、BaseRepository、与校验注解的 APT 陷阱）

## 校验注解（jakarta.validation）

所有 domain 与 entity 字段必须对照 DDL 逐项评估标注，作为声明式契约让调用方免于手工判空。**以 DDL（数据表定义）为唯一事实源**，多 migration 文件取累计最终 schema；标注仅声明、不主动接 `@Valid/@Validated` 触发点（避免存量空值路径被运行时误伤）。

### A. 字符串列（看 DDL）

| DDL | 注解 |
|---|---|
| `NOT NULL` + 无 `DEFAULT` | `@NotBlank` + `@Size(max=N)`；`char(N)` 定长 → `@Size(min=N, max=N)` |
| `NOT NULL` + 有 `DEFAULT`（任意默认值） | `@NotNull` + `@Size(max=N)` |
| 可空 | 仅 `@Size(max=N)` |
| enum 字段（`EnumConverter`） | `NOT NULL` → `@NotNull`，永不 `@NotBlank`，不加数值注解 |

### B. 数值列

| DDL | 注解 |
|---|---|
| `*_id` + `unsigned` + `NOT NULL` + 包装类型 | `@NotNull` + `@Positive` |
| `*_id` + `unsigned` + `NOT NULL` + primitive | `@Positive`（**仅 domain**，见下） |
| `*_id` + 可空 | 仅 `@Positive` |
| `*_id` + `signed`（DDL 遗留） | 不加——严格以 DDL 为准，不替 DDL 打补丁 |
| 非外键 `unsigned` 数值 | `@Min(0)` |
| `tinyint` 枚举编码（status/type/source…） | 只按 nullability 加 `@NotNull`（枚举合法性由 enum 类型兜底），不加数值注解 |
| `version` / 自增 id / DB 自动填充列（`@InsertIgnore`） | 不加 |
| `signed` 普通数值 | 不加 |

> **关键陷阱**：**entity 的 primitive 字段一律不加注解**——EasyQuery `@EntityProxy` 的 APT 会把字段注解复制到 proxy 泛型类型实参，primitive + 注解编译失败；机制详见 `orm/easy-query.md`「与校验注解的交互」。

### C. json 与集合

- json 列：可空 → 不加；`NOT NULL` → 仅 `@NotNull`，永不 `@Size`
- 集合/Map：业务必填且无默认 → `@NotNull`；**禁用 `@NotEmpty`**；`@Builder.Default = List.of()` 的字段 → 不加（默认空集合意味着空合法）

### D. 表对应 domain（存在 1:1 `XxxConverter`）

- 按对应 entity 的同表 DDL 规则标注
- 留空：`id`、`createdAt`、`version`、终态时间戳（如 `completedAt`，`complete()` 前为 null）、`@Navigate` 关联对象
- 纯语义字段（表已删列的派生值，如 `Interview.tenantId`）：按语义，构造必填的 primitive FK → `@Positive`

### E. 兜底原则

**拿不准 → 留空（不标）。少标优于错标。** 结果/汇总/信封类（`ApiResponse`、`PageResult`、`GameContractResponse` 等）字段可空性由构造路径单点保证，整个类零注解；外部第三方契约（微信/支付宝返回）只标恒返回字段。分页约定从 1 开始：`PageRequest.page`/`size` → `@Positive`。

## Converter（MapStruct）

- 一切交 MapStruct：`@Mapper` 接口声明 `toDomain`/`toEntity` 映射代码全部生成，禁止手写 setter/builder 组装
- 单 JSON 列 ↔ 对象优先用实体层 `ValueConverter`（EasyQuery，见 `orm/easy-query.md`），entity 直接持有对象、MapStruct 同类型直传零注解；MapStruct default 方法仅用于无列承载的内存/拼装转换（先例 `StatisticScoreConverter.parseScoreJson`）
- 自定义类型转换（内存/拼装场景）写成 mapper 接口的 default 方法：同 mapper 内按类型签名唯一匹配自动选用，无需 `qualifiedByName`
- 聚合组装复用其他 converter 用 `@Mapper(uses = {XxxConverter.class})`（被引用的可以是 `INSTANCE` 模式 mapper 接口，List 元素映射自动逐个复用）
- 无来源的 target 字段（审计列等）用 `@Mapping(target = "xxx", ignore = true)`；**陷阱：ignore 引用不存在的属性同样是编译错误——删实体字段必须连带删对应 ignore**
- 多态 JSON（`@JsonTypeInfo` type 判别字段）序列化用 `JsonUtil.asLowerCamelJsonString`：参数为 Object（声明类型丢失）时 Jackson 恒写 type 判别字段、roundtrip 保型；勿以具体泛型容器序列化（declared type 具体化会丢 type 字段）
- 调用方统一 `private final XxxConverter CONVERTER = XxxConverter.INSTANCE;` 字段风格（非 Spring 注入）

## Migration（Flyway）

- 已应用/已部署（test/prod）的 migration 绝不修改，变更一律新增版本号；未发布的可直接改原文件或整体删除
- 无历史数据不写数据迁移脚本；仅改注释/无 schema 变更不写 migration
- migration 内多个 ALTER 合并为单条语句；表字段必须加中文 comment
- 多 app 共库：schema 由单一 app 统一管理（其余 app 关 flyway），`validate-on-migrate` 保持 true
- 手动修复 SQL 不放 `db/migration` 目录（会被 Flyway 拾取）
- 版本号时间戳风格 `V{yyyyMMdd}_{HHmmss}__desc.sql`；每域维持单 baseline 覆盖全量 schema，不堆增量碎片文件
- 所有字段必须带 comment（含 `id`/`created_at`/`updated_at`）；枚举列 comment 写全限定枚举名与取值映射（`com.fyzs.interviewer.<module>.api.enums.<EnumName>: 0=A,1=B`）；表统一 `engine=InnoDB default charset=utf8mb4 collate=utf8mb4_general_ci`
- 未发布环境可原地合并规整为单 baseline（删除过时增量文件，不新增版本号空转文件），规整后需重建库（checksum 变更）；破坏性重写（删列）须与对应实体字段删除同一任务完成，保证任务收尾全绿
- 新增 migration 目录时核对构建聚合 locations 与各 app 运行时 classpath 两个集合一致
- 测试直跑主迁移（flyway `locations: classpath:db/migration`），不建 migration-test 副本

## 异常与错误码

- 业务层统一 `BusinessException` + `ErrorCode`，不建异常子类；仅特殊场景（如作为 `@Transactional(noRollbackFor)` 类型判别载体）可建，须在类 javadoc 登记豁免理由
- 业务 ErrorCode 放各自业务 api 模块，枚举 `implements BaseErrorCode`（component/core 定义接口）；码值全局唯一并分段（通用 1xxx、各业务 2xxx/3xxx/...、组件层 9xxx）
- 新增 ErrorCode 枚举须同步全局撞号守护测试清单 + 各枚举专属测试

## API 设计

- 端点按端分区：候选端 `/api/v1/`、管理端 `/api/console/v1/`（角色/权限守卫）
- 响应统一 `ApiResponse<T>`（success/code/message/data/timestamp），异常由 `GlobalExceptionHandler` 集中处理

## 配置

- 第三方/平台组件用 `@ConditionalOnProperty` + `xxx.enabled` 开关条件装配
- yml 环境变量占位符必须给非空兜底默认值（`${VAR:}` 空兜底会引发 400）；功能相同的多条链路兜底值保持一致
- 业务配置写 `application-{profile}.yml`（Spring 管理），不放部署层（helm/ConfigMap）
- 多 app 共享配置抽到公共模块（`spring.config.import: optional:classpath:` + 多 profile YAML 文档去重）
- 日志按 profile 区分：local 写文件（按天滚动）+ console，非 local 仅 stdout 供采集

## 缓存（component/cache）

- 跨请求临时状态（如 certify_id）用 `CacheService`（DB 表缓存，非 Redis）：`findCache`/`saveCache`/`deleteCache`，读取自动过滤过期条目
- key 定义为业务枚举 `implements CacheKey`（模板 `certify_id:%d` + `with(id)` 参数化，不手拼字符串）
- 写入必须设 `expiredAt`，不依赖后台清理任务

## 安全与外部交互

- token/敏感标识 DB 存 digest（SHA-256），domain 层保持 raw token，转换收敛在 repository（客户端零感知）
- 响应结构已知时用类型安全的 envelope record 反序列化，不用 `Map<?,?>`
- 上传/存储路径确定性（含业务维度，如 `/{业务}/{bizId}/{子类}/{序号}.mp3`），幂等覆盖，不用随机 UUID
- 大数据量导出必须流式（SXSSF + 分页 Consumer 增量追加 + 进度持久化），禁止全量加载内存
- 多路并行子任务部分失败 → 整体失败可重试，禁止静默丢弃缺内容的结果
- 前后端共用的公式/常量必须两端一致，用测试断言（ArgumentCaptor）锁定防回归
- 需取回明文的敏感凭证（如 `session_key`）DB 中 AES-256-CBC 加密存储——与 digest 场景区分：仅比对不需要明文的用 SHA-256 digest
- 日志禁止输出敏感明文（access_token/session_key/手机号/身份证号），必要时打脱敏形态；临时调试打印须在合入前删除

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
- 表名前缀与类名对齐（`statistic_*` 表 ↔ `Statistic*` 类）
- Javadoc 只写 `@param` / `@return` 有非显而易见语义时才加描述

## 写完自查

```bash
./gradlew :<目标模块路径>:compileJava && ./gradlew :<目标模块路径>:test && ./gradlew spotlessApply
# 目标模块路径如 :modules:candidate:candidate-service、:console-app:controllers
```

- [ ] 拼写无 typo；无 unused import；无 wildcard import
- [ ] 新改动测试 100% 覆盖（行+分支），DB 测试真实连库
- [ ] 模式一致性：与同模块已有代码风格匹配
- [ ] 逻辑层次：不依赖 bean → domain；跨 repository 协调/事务边界 → service；持久化 → repository
- [ ] 涉及 repository/entity/converter 时已阅读项目所用 ORM 的规范文件（见「数据持久化与 ORM」）
- [ ] service 接口/命名符合约定：对外才建接口，有接口才加 Impl；模块内部直接用 class
- [ ] 时序正确：事务提交后才发事件/MQ；消费幂等；终态 CAS
- [ ] 主动报告功能完整性与副作用；不主动提交
