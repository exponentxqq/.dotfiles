# Easy Query ORM 规范

> spring-writer 的 ORM 支撑文件。通用 Spring/Java 规范（分层、事务/事件/MQ、校验注解、MapStruct、Flyway、测试纪律等）见 `../SKILL.md`；本文件只收 Easy Query 专属规则，可独立阅读。

## 源码与排障

- 源码：https://github.com/dromara/easy-query ；官方文档：https://www.easy-query.com/easy-query-doc/
- 模块导航：`sql-core`（查询执行/关联回填——include 的 null 语义、orderByProps 排序）、`sql-processor`（APT——@EntityProxy 注解复制到 proxy 泛型实参）、`sql-api-proxy`（proxy API——`XxxEntityProxy.Fields` 引用）
- 版本注意：本文件标注 `3.1.73` 的行为查证时以项目依赖的 `com.easy-query` 实际版本为准；仓库 tag 无 `v` 前缀且非每版都打（3.1.73 无 tag，邻近 3.1.68 / 3.1.82），main 分支行为可能有差异

## 枚举持久化

- 枚举持久化用 tinyint code + 统一 `IEnum` 接口 + 自动转换器（漏 `implements IEnum` 会运行时 ClassCastException）

## 查询与更新 API

- 单结果 → `singleOptional().map(CONVERTER::toDomain)`；批次插入 → `insertable(entities).batch().executeRows(true)`；`updatable(entity)` 默认跳过 null 列，显式清空用表达式更新

## 关联加载（@Navigate）

- 关联加载用 `@Navigate` + 仓储 `.include(a -> a.xxx())` 一次带出，不写手动二次查询/两步 ids 组装；唯一消费方消失的关联仓储一并删除
- `@Navigate` 的 FK 基础属性必须保留在实体上（proxy 是 APT 编译期生成的，删字段后 `XxxEntityProxy.Fields.xxx` 引用直接编译失败；按 FK 过滤的查询也依赖它）。方向选择：FK 在本表 → `ManyToOne`（selfProperty=本表 FK，targetProperty=目标 id）；FK 在对方表的 1:1 → `OneToOne`（selfProperty=本表 id，targetProperty=对方 FK）；经映射表的多对多 → `ManyToMany` + `mappingClass`/`selfMappingProperty`/`targetMappingProperty`
- **OneToMany 带 include 恒为非 null 集合**（EasyQuery 3.1.73：单行走 `singleEntityToManyProcess` 空集合、多行走 `computeIfAbsent(k -> createManyCollection())`，且无 `getter.include()` 提前退出）——repository 里 `== null ? List.of()` 兜底是不可达分支勿写；**ManyToOne/OneToOne 匹配不到才保持 null**（有 `if (!getter.include()) return;` 守卫 + 命中才 set），经查询恢复的对象对 ManyToOne 字段仍要判 null；不带 include 的查询 navigate 字段保持 new 时 null
- toMany 集合排序用 `@Navigate(orderByProps = @OrderByProperty(property = "xxx"))` 声明式表达（3.1.73：orderByProps 编译进 include 子查询 ORDER BY，回填走 ArrayList 保序），不在 repository 手动 sort——实体级声明一处生效所有 include 查询

## 复杂类型映射

- Entity 的 `Instant` 字段必须配 `@Column(conversion = InstantConverter.class)`——datetime 列不会自动转 Instant，运行时 ClassCastException
- 单 JSON 列 ↔ 复杂/多态对象：自定义 `ValueConverter<TProperty, TProvider>` + `@Column(value = "列名", conversion = XxxValueConverter.class)`，entity 直接持有对象（先例 `EnumConverter`/`InstantConverter`/`JsonLongListConverter`）。转换器 `@Component`，由 starter 自动注册进 `QueryConfiguration`——未注册运行时抛 `EasyQueryException("conversion unknown, plz register this component")`；业务类型转换器放业务 repository 的 converter 包，不放 component 层（依赖方向）
- **`@ValueObject` 是"值对象 ↔ 多列扁平展开"语义**（子字段各自成列、select 按子列展开、insert/update set 段整列不可写会抛 IllegalArgumentException），勿用于 JSON 单列；「校验注解」里 `@Navigate`/值对象字段留空适用于此场景
- 与 MapStruct 协作：单 JSON 列 ↔ 对象经 ValueConverter 后 entity 直接持有对象，MapStruct 同类型直传零注解

## 审计与基类

- 审计列（createdAt/updatedAt）由 DB `DEFAULT CURRENT_TIMESTAMP` 维护：需要读取审计时间的实体 `extends AuditBaseEntity`（Instant + InstantConverter）；无读取场景的保持 `BaseEntity` 直接不映射。禁止手写 `LocalDateTime` 审计字段 + `@InsertIgnore/@UpdateIgnore`（与基类 Instant 体系不一致的重复造轮子）

## Repository 基建

- 新 repository 继承 `BaseRepository`（component 层）；聚合根多表场景由子类自行实现；CRUD 路径避免运行期反射

## 与校验注解的交互（APT 陷阱）

- **EasyQuery `@EntityProxy` 注解处理器会把字段注解复制到 proxy 泛型类型实参上，`@Positive long` 这类 primitive + 注解会导致 APT 编译失败。** 因此 **entity 的 primitive 字段一律不加注解**；primitive 上想表达"必填正数"只允许在**非 proxy 的 domain 类**里加 `@Positive`。校验注解总体规则见 `../SKILL.md`「校验注解」
