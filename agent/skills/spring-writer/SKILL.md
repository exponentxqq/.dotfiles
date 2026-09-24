---
name: spring-writer
description: Use when writing, modifying, or reviewing any Java/Spring Boot code — controllers, services, repositories, domain objects, async tasks, event-driven patterns, MQ consumers, migrations, tests.
---

# Spring/Java 开发规范

## 核心原则

1. **写前先读** — 每写一个类前，先读同模块 2-3 个已有类，模仿其方法命名、查询方式、异常类型、注解组合、import 风格
2. **声明式优于编程式** — Spring/官方提供注解、filter、策略就不要手写样板（如真实 IP 用 `server.forward-headers-strategy: framework`，不手写 XFF 解析）
3. **Domain 是业务核心** — 领域规则全部下沉聚合根/领域对象（单实例内可判定）；应用层只做编排与事务边界；repository 只管持久化；controller 只做协议转换
4. **最优改动** — 任务实现选最优方案而非最小 diff；被本次改动波及的存量（调用方、受影响测试、规范收紧涉及的存量）一并改到位；无关文件的问题只报告不擅动；完成后主动报告功能完整性与副作用
5. **优先设计模式** — 写新功能前先考虑是否有成熟设计模式（策略/模板方法/工厂/责任链等）可套用，避免堆叠 if-else 分支
6. **不重复造轮子** — 工具方法优先用 `component/utils` 已有的（`JsonUtil`、`CryptUtil`、`HashUtil`、`RandomUtil`、`UuidGenerator`、`HttpUtil`、`FileTypeUtil`、`@Timed`），其次 Guava（`Strings`、`Lists`、`Maps`、`Joiner`、`Preconditions`）；都没有才自写，自写实现也基于二者拼装，不裸写 JDK 样板
7. **不做无谓判空** — 前提已被契约保证（DDL NOT NULL/唯一约束、校验注解声明、`getByXxx` 查不到即抛、上层守卫、终态 CAS）就不写 `if (x == null)` 类防御分支；判空只留给真正可达 null 的边界（JSON 反序列化恢复对象、外部输入）
8. **任务拆分粒度** — 拆分实施任务时，单任务非测试改动 ≤10 个文件（不含测试、自动生成代码、新建模块的构建接线文件）；超出说明切片过大，继续按垂直切片/阶段拆——是拆任务不是砍改动范围，每任务独立可验证、收尾全绿

## 分层与依赖

四层与依赖方向（严格单向）：

```
boot → controllers(协议层) → 应用层 → 领域层(xxx-api) → 基础设施(repository/component)
```

- **领域层 = `xxx-api`**：限界上下文的**领域模型 + 对外契约**——聚合根/实体/值对象、跨域调用接口、枚举、`XxxErrorCode`。repository 层亦依赖此层，故持久化域类型必须留此。**不建独立 `xxx-domain` 模块**（单库单体下是纯代价：全量挪包/构建重排、零行为收益）
- **基础设施**：repository（`xxx-repository`）只管持久化；`component`（跨项目基建）← `modules`（项目级）← `app`，基础层禁止反向依赖业务模块
- component/基础层不抛 `BusinessException`/引用 `ErrorCode`（依赖方向做不到）——抛基础异常，或定义 protected 钩子方法（如 `notFoundException()`）供业务子类覆盖
- **应用层分两档，命名强制区分**：
  - `XxxService`：**上下文内应用服务**（`modules:<domain>:<domain>-service`）——跨聚合协调、仓储调用、事务边界、跨域防腐；无接口直接 `@Service` class
  - `XxxWebService`：**跨上下文编排服务**（`web.service`，**非版本包**）——多限界上下文的领域对象汇聚与编排（事务边界），只在 web 模块（含独立认证编排模块）出现
- **controllers（协议层）**：只做协议转换（参数解析、domain→VO），不写业务判断、不抛业务异常、不编排多上下文；**web 模块 = 协议层 + 跨上下文聚合层**
- **web 聚合根**：`web.domain.XxxAggregate`（**非版本包**）——跨上下文聚合组装与可判定不变量的收编点（如账号缺失 404 一致性、成员操作越权判定）；不引仓储、无持久化语义
- **WebService 创建门槛**：跨上下文编排**必须**建；上下文内的 web 层 service 可选，一旦存在必须遵守命名 + `web.service` 包；**纯透传禁止**（防每个 web 模块长出纯委托空壳）
- **版本包语义收敛**：`web.v1`（或 console 的 `web`）只放协议三件套——生成的 Api 接口、controller 实现、converter、generated 模型；聚合根/编排服务/领域逻辑**不得进版本包**（协议差异由 controller/converter 隔离，v2 不需要复制编排）
- **跨上下文规则**：一个上下文只依赖对方 `xxx-api`（模型/接口/错误码），不依赖对方 service/repository/web；跨上下文编排只发生在应用层（`XxxWebService`/认证编排模块）；领域层不跨上下文
- service 不 import controller 层对象（尤其带版本号的 `controller.v1.*`）；需要时方法用平铺参数
- 不新建语义重复的类型、无消费方的字段；已有字段能表达就不新增状态
- 请求级上下文收敛为单一 `RequestContext`（filter 一次性装配），业务方直接读取；不维护多套 ThreadLocal/参数解析器机制
- service 接口只在对外（被其他模块依赖）时定义；模块内部使用的直接定义 `@Service` class，不建单一实现的空接口。接口的**方法面**只含跨域消费方所需——域内用例（app 层 web/编排直依的）下沉 impl 具体类（controller 注入 impl），不因接口存在就全量暴露
- 只有 implements interface 的同名 service 才加 `Impl` 后缀（`XxxService` 接口 → `XxxServiceImpl`）；无接口的 service 直接命名 `XxxService`，禁止无接口也带 Impl
- 具体模块路径映射与跨域调用方式按项目，见附录「项目差异」

## 领域建模

- **规则归属判定线**（首要原则）：
  - 单实例内可判定 → 聚合根/领域对象（工厂守卫、行为前置条件、状态迁移不变量）
  - 需跨实例查询/跨聚合协调（唯一性 count、席位占用等）→ 应用层显式编排（`XxxService`；跨上下文 `XxxWebService`），不硬塞聚合根
- **聚合根规范**：命名 `Xxx`（域内）/`XxxAggregate`（web 层跨上下文）；创建入口 `ofXxx`/`createXxx` 静态工厂，不暴露 setter；状态迁移行为方法原地修改自身并返回 this（`enable()`/`disable()`）；不变量在聚合内守卫（非法调用直接抛业务错误码异常——这是错误码的合法首要抛出位置）；不引仓储、不依赖 Spring bean
- **值对象克制**：只在规则需要独立类型承载时出现；不造 `Phone`/`CreditCode` 等装饰性包装（不做值对象海啸）
- **领域事件启用门槛**：单库单体默认不启用（显式同事务编排优于事件间接层）；仅当出现跨进程/异步解耦需求时经评审启用；事件基建可留存并标注未启用（各项目现状见附录）
- 状态/类型字段一律用 enum，不用 String；枚举持久化机制（IEnum/转换器）见「数据持久化与 ORM」对应 ORM 文件
- domain 类与其字段引用的生成枚举同名異包时，改契约枚举名消除冲突（如 `AccountRole`→`Role`），不在 domain 里用全限定名绕行
- 字段映射收敛为 `ofXxx` 静态工厂方法，消灭各处重复 toView；需要后续注入的字段用 `withXxx` 原地修改返回 this，不为领域类开 setter
- 同实体多形态记录用 `type` 判别字段区分，不堆叠可选列；查询方法显式带 type（如 `findByXxxAndType`），删除有歧义的方法
- DB not null/唯一约束已保证的不可能状态，不写防御分支（YAGNI），对应"模拟不可能状态"的测试一并删除
- 由 `getXxx`（查不到即抛 ErrorCode）获得的引用，下游不再判 null；但经 JSON 反序列化恢复的对象字段可能为 null，此类防御分支可达，保留
- 传输载体分离：领域计算 → 持久化的中间结果用独立类型（如 `OverviewDelta` record），不用领域对象兼作「快照」与「增量」两种语义
- **动态查询直传 = CQRS 读路径**：列表搜索端点直传查询协议绕过聚合是合法的**读模型**路径；写路径必须走聚合，读模型不反向承载业务规则

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

- Repository 命名：`getByXxx` 抛异常，`findByXxx` 返回 Optional；查不到抛「资源不存在」错误码（选码按项目惯例，见附录）；业务错误码可在 repository 层承载「存储约束/缺失」语义（唯一键冲突、资源不存在等），不限于应用层
- **聚合仓储以聚合为单位**：写入统一 `save(聚合)`（新建/更新同一入口，子表随聚合根写入）、删除 `delete(id)`；部分列更新方法（`resetPassword` 等）是过渡形态，随域富化收敛进 `save`
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
- `ignore` 仅用于**来源侧不存在**的 target 字段（审计列、DB 生成列、entity 独有承载，如 `@Mapping(target = "xxx", ignore = true)`）；**双方都有的字段一律禁止 `ignore`**——同名可映射而被 ignore 即静默丢数据（id 丢身份、快照缺列），多为压制警告或复制残留；来源不同名用 `@Mapping(source/target)` 改道（先例 `config↔taskConfig`），不靠 ignore 截断。**陷阱：ignore 引用不存在的属性同样是编译错误——删实体字段必须连带删对应 ignore**
- 多态 JSON（`@JsonTypeInfo` type 判别字段）序列化用 `JsonUtil.asLowerCamelJsonString`：参数为 Object（声明类型丢失）时 Jackson 恒写 type 判别字段、roundtrip 保型；勿以具体泛型容器序列化（declared type 具体化会丢 type 字段）
- 调用方统一 `private final XxxConverter CONVERTER = XxxConverter.INSTANCE;` 字段风格（非 Spring 注入）

## Migration（Flyway）

- 已应用/已部署（test/prod）的 migration 绝不修改，变更一律新增版本号；未发布的可直接改原文件或整体删除
- 无历史数据不写数据迁移脚本；仅改注释/无 schema 变更不写 migration
- migration 内多个 ALTER 合并为单条语句；表字段必须加中文 comment
- 多 app 共库：schema 由单一 app 统一管理（其余 app 关 flyway），`validate-on-migrate` 保持 true
- 手动修复 SQL 不放 `db/migration` 目录（会被 Flyway 拾取）
- 版本号时间戳风格 `V{yyyyMMdd}_{HHmmss}__desc.sql`；每域维持单 baseline 覆盖全量 schema，不堆增量碎片文件
- 所有字段必须带 comment（含 `id`/`created_at`/`updated_at`）；枚举列 comment 写简短形式 `enum <EnumName>`（与存量迁移风格一致，不写全限定名/值映射）；表统一 `engine=InnoDB default charset=utf8mb4 collate=utf8mb4_general_ci`
- 未发布环境可原地合并规整为单 baseline（删除过时增量文件，不新增版本号空转文件），规整后需重建库（checksum 变更）；破坏性重写（删列）须与对应实体字段删除同一任务完成，保证任务收尾全绿
- 新增 migration 目录时核对构建聚合 locations 与各 app 运行时 classpath 两个集合一致
- 测试直跑主迁移（flyway `locations: classpath:db/migration`），不建 migration-test 副本

## 异常与错误码

- 业务层统一 `BusinessException` + `ErrorCode`，不建异常子类；仅特殊场景（如作为 `@Transactional(noRollbackFor)` 类型判别载体）可建，须在类 javadoc 登记豁免理由
- 业务 ErrorCode 放各自业务 api 模块，枚举 `implements BaseErrorCode`（component/core 定义接口）；码值全局唯一并分段（通用 1xxx、各业务 2xxx/3xxx/...、组件层 9xxx）
- 新增 ErrorCode 枚举须同步全局撞号守护测试清单 + 各枚举专属测试
- 业务语义判定与 `BusinessException` 抛出在**聚合守卫与应用层编排**（单实例不变量→聚合根；跨实例/跨聚合→应用层 `XxxService`/`XxxWebService`）；controller 只做协议转换（参数解析、domain→VO），不写业务判断、不抛业务异常

## API 设计

- 端点按端分区、统一前缀（各项目路径方案见附录）；角色/权限守卫由契约生成注解承担
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
- 禁止 mock 假象：stub 生产不可能状态（get 风格服务返回 null、NOT NULL 列为 null）构造的"防御路径"用例是假绿——真实实现查不到抛 ErrorCode 而非返回 null，发现即改造为真实状态或删除
- 多用例公共依赖在 `@BeforeEach` 配 lenient 默认 stub，用例只 stub 差异项（最近 stub 覆盖默认）；默认 stub 须带全严格链所需字段（如任务快照必含 configExtra），否则主代码删掉防御后默认路径集体 NPE
- 重构迁移：存量测试=行为锁（不改或仅微调断言即全绿为验收硬标准）；100% 覆盖纪律只作用于新增/改写面，不为覆盖重写存量测试
- e2e 依赖异步回调的断言用轮询收敛（awaitUntil），不用同步 Executor 强行覆盖
- Lombok/MapStruct/Easy Query 引发的 LSP 误报不算错，以 gradle 编译结果为准

## 代码风格

- 成员变量 → 构造函数注入（`@RequiredArgsConstructor`）；静态常量放在成员变量之前；日志 `@Slf4j`
- 时间一律用 `Instant`（domain/entity/DTO/参数统一）；如非必要禁用非 Instant 时间类（`LocalDateTime`/`LocalDate`/`ZonedDateTime`/`Date`）。审计列走 `AuditBaseEntity` 的 Instant 体系，ORM 列转换器见对应 ORM 文件
- 表名前缀与类名对齐（`statistic_*` 表 ↔ `Statistic*` 类）
- Javadoc 只写 `@param` / `@return` 有非显而易见语义时才加描述

## 写完自查

```bash
./gradlew :<目标模块路径>:compileJava && ./gradlew :<目标模块路径>:test && ./gradlew spotlessApply
# 目标模块路径如 :modules:<domain>:<domain>-service、:<app>:controllers:<domain>-web
```

- [ ] 拼写无 typo；无 unused import；无 wildcard import
- [ ] 新改动测试 100% 覆盖（行+分支），DB 测试真实连库
- [ ] 模式一致性：与同模块已有代码风格匹配
- [ ] 逻辑层次：不依赖 bean → 聚合根/领域对象；跨实例/跨上下文编排与事务边界 → 应用层（`XxxService`/`XxxWebService`）；持久化 → repository
- [ ] 涉及 repository/entity/converter 时已阅读项目所用 ORM 的规范文件（见「数据持久化与 ORM」）
- [ ] service 接口/命名符合约定：对外才建接口，有接口才加 Impl；模块内部直接用 class
- [ ] 时序正确：事务提交后才发事件/MQ；消费幂等；终态 CAS
- [ ] 无无谓判空：契约已保证的前提没有重复判空/防御分支
- [ ] converter 无「双方共有字段」的 @Mapping ignore
- [ ] 领域规则在正确层级：单实例不变量→聚合根；跨实例/跨聚合→应用层；跨上下文→`XxxWebService`
- [ ] web 编排服务命名 `XxxWebService`、聚合根命名 `XxxAggregate`，均在非版本包；仅跨上下文建、非纯透传
- [ ] 聚合根未引仓储/未依赖 Spring bean；仓储写入以聚合 `save` 为单位
- [ ] 主动报告功能完整性与副作用；不主动提交

## 附录：项目差异

> 正文为方向性规范；本附录记录两个项目的既有形态与差异，规则冲突时以正文为准，差异项随各项目重构逐步收敛。

### A. interviewer（活跃 monorepo `~/develop/company/interviewer/service`）

- 模块路径：`candidate-app:controllers:<domain>-web`（包名 `com.fyzs.interviewer.<domain>.web.v1`）、console 单模块 `console-app:controllers`、后台消费 `worker-app:consumers`；新 service/repository/api 放 `modules:<domain>:<domain>-<层>`
- 端点路径：candidate `/api/v1/`、console `/api/console/v1/`（角色/权限守卫）
- 跨域（跨模块）调用走 `contract:*` 模块的 Feign client（跨进程），不走同进程 `xxx-api` 依赖
- 领域事件体系使用中（`BaseEvent` + 发布/监听）；`@TransactionalEventListener`/消费幂等等规则适用
- JSON 反序列化恢复对象先例：LangGraph state hydration（字段可能为 null 的防御分支豁免）
- 测试 mock 白名单含 LLM（MockWebServer 真实解析链路）、微信/支付宝/讯飞等外部平台
- repository 缺资源错误码：域内业务码（如 `CandidateErrorCode.CANDIDATE_NOT_EXISTS`）

### B. OPC（`~/develop/company/opc`）

- 模块路径：`portal-app/console-app:controllers:<domain>-web`、`modules:<domain>:<domain>-{api,repository,service}`、`worker-app`、`component:database:query{,-core}`；包名 `com.fyzs.opc.*`（portal-app 无 app 段）
- 端点路径：portal `/api/v1/...`（context `/api` + 契约 `/v1`）、console `/api/...`（无版本号）
- 跨上下文走同进程 `xxx-api` 模块依赖（无 Feign）；领域模型（聚合根/实体/枚举）放 `xxx-api`
- web 编排层：`portal-app:auth` 认证应用层模块 + 各 `*-web` 的 `web.domain.XxxAggregate`/`web.service.XxxWebService`（均非版本包）；协议三件套进 `web.v1`（portal）/`web`（console）
- 领域事件基建（`component:core` 的 `BaseDomain` + `@PublishDomainEvents`）留存未启用；触发条件：worker/MQ 解耦需求出现时评审启用
- repository 缺资源错误码：`GlobalErrorCode.RESOURCE_NOT_FOUND`（1xxx 段）；业务码只表达业务校验失败
- 动态列表查询：`QueryRequest` 直传组件门面（CQRS 读路径），wire 协议经 apigen `existingTypes` 绑定组件类型
- 配置直写 yml（`shared-platform.yml` + `spring.config.import`），零环境变量插值
