---
name: spring-writer
description: Use when writing, modifying, or reviewing any Java/Spring Boot code — controllers, services, repositories, domain objects, async tasks, event-driven patterns.
---

# Spring/Java 开发规范

## 核心原则

1. **写前先读** — 每写一个类前，先 Grep/Read 同模块 2-3 个已有类，模仿其：方法命名、查询方式、异常类型、注解组合、import 风格
2. **声明式优于编程式** — Spring 提供注解/接口就不要手写样板
3. **Domain 是业务核心** — 不依赖 Spring bean 的逻辑全部放入 domain 对象，domain 是其对应领域业务逻辑的核心

## 具体规则

### Domain vs Service

Domain 对象是其所对应领域业务逻辑的核心。理论上，不依赖 Spring bean 的逻辑都要放到 domain 中。

- **放 domain**：一切不依赖 Spring bean 的逻辑——校验、判断、状态转换、计算、业务规则。比如 `canTranscribe()`, `is(RoomStatus)`, `completeRecording()`, `retry()`
- **放 service**：必须依赖 Spring bean 的逻辑——多 repository 协调、事务边界、外部 API 调用、事件发布

### 事务与异步

- 事务方法触发异步任务 → `eventPublisher.publishEvent()` + `@TransactionalEventListener(phase = AFTER_COMMIT)` 接受事件后调用 `@Async` 方法
- 禁止：`TransactionSynchronizationManager.registerSynchronization()` 匿名内部类

### Easy Query

- 单结果查询 → `singleOptional().map(CONVERTER::toDomain)`，不用 `firstOrNull() + Optional.ofNullable()`
- 批次插入 → `insertable(entities).batch().executeRows(true)`
- 注意：`updatable(entity)` 默认跳过 null 列，显式清空某列需用表达式更新
- Repository 命名：`getByXxx` 抛异常，`findByXxx` 返回 Optional

### 代码风格

- 成员变量 → 构造函数注入（`@RequiredArgsConstructor`）
- 静态常量 → 放在成员变量之前
- 日志用 `@Slf4j`，关键节点 log.info，异常 log.error
- Javadoc 只写 `@param` / `@return` 有非显而易见语义时才加描述

## 写完自查

```bash
./gradlew :modules:<module>:<submodule>:compileJava
```

- [ ] 拼写：方法名、变量名无 typo
- [ ] Imports：无 unused import，无 .* wildcard
- [ ] Javadoc：引用正确，不过时
- [ ] 模式一致性：与同模块已有代码风格匹配
- [ ] 逻辑层次：不依赖 bean → domain，跨 repository 协调 → service
