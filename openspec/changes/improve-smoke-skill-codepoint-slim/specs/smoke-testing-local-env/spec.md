# Spec Delta

## ADDED Requirements

### Requirement: 多字节字符口径

测试数据含中文、emoji 或生僻字时，skill SHALL 在数据准备阶段先确认 DB 字符集与各校验层计数单位：字符集为 `utf8`（utf8mb3）时，4 字节字符的报错或截断 SHALL 判为环境限制并记观察项，不得判为功能缺陷；长度边界用例 SHALL 按被测校验层单位（前端/Java 为 UTF-16 code unit，DB `VARCHAR`/`char_length` 为码点）取上限与上限+1，MUST NOT 跨层换算；落库断言 SHALL 查回多字节原值逐字符比对。

#### Scenario: utf8mb3 表写入 emoji

- **WHEN** 目标表字符集为 `utf8`（utf8mb3）而用例需写入 emoji 或生僻字
- **THEN** 插入报错或值被静默截断时判为环境限制，记观察项并写明影响面，不记为功能缺陷；确需覆盖该能力时向用户确认改表或换库

#### Scenario: 长度边界负例全不生效

- **WHEN** 「限 50 字」的边界负例误按字节构造（51 字节 ≈ 17 个汉字）而全部提交成功
- **THEN** 先确认校验层计数单位（前端/Java `length` 为 UTF-16 code unit），按该单位重构造上限+1（51 个汉字）再断言业务错误码，不得直接判为校验缺失
