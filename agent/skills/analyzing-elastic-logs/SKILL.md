---
name: analyzing-elastic-logs
description: Use when 排查线上问题需要查询服务日志或 APM traces——按候选人/用户查请求、按 trace.id 查 span 树与 SQL、慢请求分析、错误日志检索、trace 与日志互查、N+1 SQL 审计。平台为公司共享 Elastic(DBX 连接 company@elastic)。Use when investigating production issues, slow requests, or error logs via Elastic SQL, APM traces, or kubectl.
---

# Analyzing Elastic Logs

## Overview

公司共享 Elastic 观测平台,通过 DBX(`company@elastic` 连接)用 **Elastic SQL** 查询日志与 APM traces。核心心智模型——一条排查链路:

```
用户/候选人 ID → traces(transaction 带 user.id) → trace.id
    → span 树(逐条 SQL 可数) → 日志行(带 trace.id + user.id)
```

所有查询通过 `dbx-mcp_dbx_execute_query`,连接名 `company@elastic`。

## 环境事实

| 项 | 值 |
|---|---|
| DBX 连接 | `company@elastic`(ES 8,NodePort) |
| 日志索引 | `filebeat-8.3.2`(精确别名,以 DBX 实际为准) |
| traces 索引 | `traces-apm-*` |
| 命名空间 | `test` / `prod`(+ `hkprod`、`istiotest`) |
| 时区 | 索引存 **UTC**,本地 **+8**(16:32 本地 = 08:32 UTC) |
| 日志行格式 | `时间 LEVEL logger [thread] trace.id␣␣user.id 消息` |

### 服务全景(近 7 天实测,会增减)

interviewer 系:`interviewer-candidate`、`interviewer-worker`。
其余为 fyzs/sand/城市系老服务:`fyzs-send-center`、`fyzs-center`、`order-center`、`user-center`、`fyzs-trade-personal`、`fyzs-quartz`、`fyzs-trade`、`sand-center-web`、`sand-quartz`、`fyzs-web`、`fyzs-admin`、`cloud-city-center`、`team-activity`、`admin-web`。

**`user.id` 仅 `interviewer-candidate` 写入**(HTTP 认证链绑定;interviewer-worker 与全部老服务为空)。按人查只适用于 interviewer-candidate;对其他服务用 user.id 永远空结果,不是坏了。

### 环境不对称(最重要的坑)

- **日志(test + prod 混装同索引)**:filebeat-8.3.2 同时收 test(约 13.7万/天)与 prod(约 12.4万/天)。**所有日志查询必须带 `kubernetes.namespace` 过滤**,否则静默拿错环境的日志——比查不到更危险。
- **traces(无环境字段)**:`kubernetes.namespace`、`host.name` 在 traces 里均为 NULL。只能靠 `service.name` 隐式推断 + 时间窗对应已知部署情况。traces 语句不要假装能区分环境。

## ES SQL 硬规则

1. **必须带 LIMIT**(行数上限),**不支持 OFFSET**(翻页改用时间窗收窄)
2. **结尾不加分号**
3. `message` 是 text 无 keyword 子字段 → **禁 `LIKE`,用 `MATCH()`**;`MATCH("message", 'a b')` 多词默认 OR,收紧写 `MATCH("message", 'a b', 'operator=AND')`(option 是单个带引号字符串,`operator=AND` 裸写会语法错)
4. 短 token(`'1'`、`'ERROR'` 单字符类)MATCH 误报高 → 按人查走 traces 侧 `WHERE "user.id" = '1'` 拿 trace.id,再 MATCH trace.id 查日志
5. 字段名、索引名用双引号

## 查询速查

占位符:`{user}` 用户/候选人 ID;`{trace}` trace.id;`{ns}` namespace。

### 按人(user → trace,仅 interviewer-candidate)

```sql
SELECT "transaction.name", "url.path", "trace.id", "@timestamp"
FROM "traces-apm-*"
WHERE "user.id" = '{user}' AND "@timestamp" > NOW() - INTERVAL 1 HOUR
ORDER BY "@timestamp" DESC LIMIT 20
```

### 按 trace(span 树 / SQL 审计)

```sql
-- 完整 span 树(时间序)
SELECT "span.name", "transaction.duration.us", "@timestamp"
FROM "traces-apm-*"
WHERE "trace.id" = '{trace}'
ORDER BY "@timestamp" ASC LIMIT 100

-- 只看 SQL(N+1 排查)
SELECT "span.name", "@timestamp" FROM "traces-apm-*"
WHERE "trace.id" = '{trace}' AND "span.name" LIKE 'SELECT FROM%' LIMIT 50

-- 单请求 SQL 条数
SELECT COUNT(*) FROM "traces-apm-*"
WHERE "trace.id" = '{trace}' AND "span.name" LIKE '%FROM%' LIMIT 1
```

### trace ↔ 日志互查(必须带 ns)

```sql
-- trace.id → 日志
SELECT "message" FROM "filebeat-8.3.2"
WHERE MATCH("message", '{trace}') AND "kubernetes.namespace" = '{ns}'
ORDER BY "@timestamp" DESC LIMIT 20

-- 关键词搜日志
SELECT "message" FROM "filebeat-8.3.2"
WHERE MATCH("message", '超时 结束', 'operator=AND')
  AND "kubernetes.namespace" = '{ns}'
  AND "@timestamp" > NOW() - INTERVAL 1 HOUR
ORDER BY "@timestamp" DESC LIMIT 30

-- ERROR/WARN 扫描
SELECT "message", "kubernetes.pod.name", "@timestamp" FROM "filebeat-8.3.2"
WHERE MATCH("message", 'ERROR') AND "kubernetes.namespace" = '{ns}'
  AND "@timestamp" > NOW() - INTERVAL 2 HOUR
ORDER BY "@timestamp" DESC LIMIT 30
```

### 按接口 / 服务

```sql
-- 某接口最近请求(traces 无环境字段,注意推断)
SELECT "user.id", "trace.id", "transaction.duration.us", "@timestamp"
FROM "traces-apm-*"
WHERE "url.path" LIKE '%assessments%'
  AND "@timestamp" > NOW() - INTERVAL 1 HOUR
ORDER BY "@timestamp" DESC LIMIT 20

-- 慢请求排行(>500ms)
SELECT "url.path", "transaction.duration.us", "user.id", "trace.id"
FROM "traces-apm-*"
WHERE "transaction.duration.us" > 500000
  AND "@timestamp" > NOW() - INTERVAL 1 HOUR
ORDER BY "transaction.duration.us" DESC LIMIT 20

-- 某服务日志(pod 前缀匹配,部署后 pod 名会变)
SELECT "message", "@timestamp" FROM "filebeat-8.3.2"
WHERE "kubernetes.pod.name" LIKE 'interviewer-worker%'
  AND "kubernetes.namespace" = '{ns}'
  AND "@timestamp" > NOW() - INTERVAL 30 MINUTE
ORDER BY "@timestamp" DESC LIMIT 30
```

## kubectl 只读四件套

默认 `-n test`;**涉及 prod 一律只读观察,不做任何变更**。pod 名含部署 hash,先查再补全:

```bash
kubectl get pods -n test | grep interviewer          # pod 状态
kubectl logs -n test <pod> --tail=200 -f             # 尾随日志
kubectl logs -n test <pod> --previous --tail=100     # 崩溃重启前的日志
kubectl describe pod -n test <pod>                   # 事件/env/探针
kubectl get events -n test --sort-by=.lastTimestamp | tail -20
```

不使用 `kubectl exec`——诊断入口留在日志与 traces,避免只读排查演变成变更。

## 排障套路(组合拳)

1. 拿到候选人 ID → **按人**查 traces,得 trace.id 列表
2. 挑目标 trace → **span 树**,数 SQL 条数、定位慢点(哪条 SQL 占时)
3. 同一 trace.id → **MATCH 到日志行**,看业务上下文(trace.id 双列交叉一致)
4. 疑似普遍问题 → **慢排行 / ERROR 扫描**(带 ns),抽样 trace 回到第 2 步

## N+1 SQL 审计(方法论)

单个 trace 的 SQL 条数即 N+1 的量化:先 `COUNT(*)`(span 树 LIKE '%FROM%'),再列明细看是否同表重复 SELECT。判断标准:循环体内逐条查同表 = N+1;数量级参考以**实测当下值**为准,不依赖历史快照。任何加载优化(批量 include、投影、拆聚合)落地前后,用同一接口的 trace 对比 SQL 条数与 `transaction.duration.us`。
