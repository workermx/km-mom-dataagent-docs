# MOM 智能问数 MVP 归档清理方案

本文档用于控制 MVP 阶段会话、消息、结果载荷、审计日志和任务记录的数据体量。所有 SQL 都是方案模板，不得未经评审直接在生产执行。

## 1. 风险等级和执行原则

| 操作 | 风险等级 | 说明 |
| --- | --- | --- |
| `SELECT` 预览 | 低 | 用于确认影响范围，不修改数据 |
| 逻辑删除会话 | 中 | 更新 `da_session.deleted_flag`，会影响前端会话列表 |
| 物理删除消息、台账、审计、任务 | 高 | 可能造成数据不可恢复，必须先备份 |
| 大批量删除 | 高 | 可能造成锁等待、主从延迟、undo 增长和性能抖动 |

执行原则：

- 删除前必须先执行对应 `SELECT` 预览 SQL。
- 生产环境执行前必须完成 MySQL 备份，并记录备份文件位置、执行人、执行时间和保留期限。
- 生产环境必须在低峰期执行。
- 所有批量操作必须分批执行，建议单批 `500` 到 `2000` 行，根据实例性能调整。
- 不直接清理管理侧配置、模型密钥、数据源配置、Skill、指标口径、预设问题和语音配置。
- Redis Key 按 TTL 自然过期，不做数据库归档。
- 清理完成后必须执行验证 SQL，确认未破坏当前 MVP 表结构和必要初始化数据。

## 2. 推荐保留周期

| 数据类型 | 表 | 建议保留周期 | 清理策略 |
| --- | --- | --- | --- |
| 会话 | `da_session` | 6-12 个月 | 先逻辑删除，后续再物理清理关联数据 |
| 消息 | `da_message` | 跟随会话 | 会话逻辑删除且超过宽限期后物理删除 |
| 结果载荷 | `da_message.metadata_json.resultPayload` | 跟随 Agent 回复消息 | 随消息一起清理，不单独拆分 |
| 请求台账 | `da_chat_request_ledger` | 6-12 个月 | 终态台账可随会话或按时间清理 |
| 审计日志 | `da_audit_log` | 6-12 个月 | 按 `created_time` 分批物理删除 |
| Schema 初始化任务 | `da_schema_init_task` | 90-180 天 | 终态任务按 `created_time` 分批物理删除 |
| 向量化任务 | `da_vector_task` | 90-180 天 | 终态任务按 `created_time` 分批物理删除 |

待确认：

- 企业审计要求是否强制保留 12 个月以上。
- 是否需要把删除前数据导出到离线归档库或对象存储。
- 是否存在监管要求禁止物理删除审计日志。

## 3. 备份与回滚准备

### 3.1 全库备份

用途：生产清理前建立完整恢复点。

```powershell
mysqldump `
  -h 127.0.0.1 `
  -P 3306 `
  -u root `
  -p `
  --single-transaction `
  --routines `
  --triggers `
  --default-character-set=utf8mb4 `
  mom_data_agent `
  > .\backup\mom_data_agent_before_cleanup_YYYYMMDD_HHMMSS.sql
```

风险说明：

- 命令中的账号仅为示例，生产环境应使用具备备份权限的专用账号。
- 不要把数据库密码写入脚本、日志或文档。
- 备份文件可能包含敏感密文、脱敏值、用户问题和结果载荷，必须按敏感文件管理。

### 3.2 关键表临时归档

用途：对即将清理的数据建立同库临时归档表，便于短期回滚。

```sql
CREATE TABLE IF NOT EXISTS archive_da_session_cleanup_YYYYMMDD LIKE da_session;
CREATE TABLE IF NOT EXISTS archive_da_message_cleanup_YYYYMMDD LIKE da_message;
CREATE TABLE IF NOT EXISTS archive_da_chat_request_ledger_cleanup_YYYYMMDD LIKE da_chat_request_ledger;
CREATE TABLE IF NOT EXISTS archive_da_audit_log_cleanup_YYYYMMDD LIKE da_audit_log;
CREATE TABLE IF NOT EXISTS archive_da_schema_init_task_cleanup_YYYYMMDD LIKE da_schema_init_task;
CREATE TABLE IF NOT EXISTS archive_da_vector_task_cleanup_YYYYMMDD LIKE da_vector_task;
```

风险说明：

- `CREATE TABLE ... LIKE` 会复制表结构和索引，但不会复制外键；当前 MVP DDL 本身不使用外键强约束。
- 归档表会占用额外磁盘空间，执行前必须确认空间充足。

## 4. 会话逻辑删除

适用场景：超过保留期且长期未活跃的会话先从前端列表隐藏，但暂不删除消息和台账。

建议阈值：

- `@session_cutoff_time`：当前时间往前 12 个月。
- 单批建议：1000 条，可按实例性能把 SQL 中的 `LIMIT 1000` 调整为 `500` 到 `2000`。

### 4.1 预览影响范围

```sql
SET @session_cutoff_time = TIMESTAMP('2025-06-29 00:00:00');

SELECT COUNT(*) AS candidate_session_count
FROM da_session
WHERE deleted_flag = 0
  AND COALESCE(last_active_time, updated_time, created_time) < @session_cutoff_time;

SELECT session_id, agent_id, session_title, message_count, last_active_time, updated_time, created_time
FROM da_session
WHERE deleted_flag = 0
  AND COALESCE(last_active_time, updated_time, created_time) < @session_cutoff_time
ORDER BY COALESCE(last_active_time, updated_time, created_time)
LIMIT 50;
```

### 4.2 执行逻辑删除

高风险提醒：这是批量 `UPDATE`。执行前必须确认预览结果、备份状态和业务窗口。

```sql
START TRANSACTION;

CREATE TEMPORARY TABLE tmp_cleanup_session_ids (
  session_id VARCHAR(64) PRIMARY KEY
) ENGINE=Memory;

INSERT INTO tmp_cleanup_session_ids (session_id)
SELECT session_id
FROM da_session
WHERE deleted_flag = 0
  AND COALESCE(last_active_time, updated_time, created_time) < @session_cutoff_time
ORDER BY COALESCE(last_active_time, updated_time, created_time)
LIMIT 1000;

INSERT INTO archive_da_session_cleanup_YYYYMMDD
SELECT s.*
FROM da_session s
JOIN tmp_cleanup_session_ids t ON t.session_id = s.session_id;

UPDATE da_session s
JOIN tmp_cleanup_session_ids t ON t.session_id = s.session_id
SET s.deleted_flag = 1,
    s.updated_time = CURRENT_TIMESTAMP(3);

SELECT ROW_COUNT() AS updated_session_count;

COMMIT;
```

### 4.3 回滚逻辑删除

```sql
START TRANSACTION;

UPDATE da_session s
JOIN archive_da_session_cleanup_YYYYMMDD a ON a.session_id = s.session_id
SET s.deleted_flag = a.deleted_flag,
    s.updated_time = CURRENT_TIMESTAMP(3);

COMMIT;
```

## 5. 消息和结果载荷清理

适用场景：会话已逻辑删除并超过宽限期，需要释放 `da_message.message_content`、`display_content` 和 `metadata_json.resultPayload` 占用空间。

建议阈值：

- `@message_cutoff_time`：会话逻辑删除后至少 30 天。
- 单批建议：500 到 1000 条，可按实例性能调整 SQL 中的 `LIMIT 1000`。

### 5.1 预览影响范围

```sql
SET @message_cutoff_time = TIMESTAMP('2025-06-29 00:00:00');

SELECT COUNT(*) AS candidate_message_count
FROM da_message m
JOIN da_session s ON s.session_id = m.session_id
WHERE s.deleted_flag = 1
  AND s.updated_time < @message_cutoff_time;

SELECT m.session_id, m.message_id, m.message_role, m.message_status, m.created_time
FROM da_message m
JOIN da_session s ON s.session_id = m.session_id
WHERE s.deleted_flag = 1
  AND s.updated_time < @message_cutoff_time
ORDER BY m.created_time
LIMIT 50;
```

### 5.2 执行物理删除

高风险提醒：这是批量 `DELETE`。执行前必须确认消息不再需要在线查询，且已备份或归档。

```sql
START TRANSACTION;

CREATE TEMPORARY TABLE tmp_cleanup_message_ids (
  message_id VARCHAR(64) PRIMARY KEY
) ENGINE=Memory;

INSERT INTO tmp_cleanup_message_ids (message_id)
SELECT m.message_id
FROM da_message m
JOIN da_session s ON s.session_id = m.session_id
WHERE s.deleted_flag = 1
  AND s.updated_time < @message_cutoff_time
ORDER BY m.created_time
LIMIT 1000;

INSERT INTO archive_da_message_cleanup_YYYYMMDD
SELECT m.*
FROM da_message m
JOIN tmp_cleanup_message_ids t ON t.message_id = m.message_id;

DELETE m
FROM da_message m
JOIN tmp_cleanup_message_ids t ON t.message_id = m.message_id;

SELECT ROW_COUNT() AS deleted_message_count;

COMMIT;
```

### 5.3 回滚消息

```sql
START TRANSACTION;

INSERT INTO da_message
SELECT a.*
FROM archive_da_message_cleanup_YYYYMMDD a
LEFT JOIN da_message m ON m.message_id = a.message_id
WHERE m.message_id IS NULL;

COMMIT;
```

## 6. 请求台账清理

适用场景：清理超过保留期的终态请求台账，避免幂等台账无限增长。

允许清理状态：

- `SUCCEEDED`
- `FAILED`
- `STOPPED`
- `PERSIST_FAILED`

不建议清理状态：

- `RECEIVED`
- `PROCESSING`

### 6.1 预览影响范围

```sql
SET @ledger_cutoff_time = TIMESTAMP('2025-06-29 00:00:00');

SELECT request_status, COUNT(*) AS candidate_ledger_count
FROM da_chat_request_ledger
WHERE request_status IN ('SUCCEEDED', 'FAILED', 'STOPPED', 'PERSIST_FAILED')
  AND updated_time < @ledger_cutoff_time
GROUP BY request_status;

SELECT ledger_id, session_id, user_message_id, request_status, last_stage, updated_time
FROM da_chat_request_ledger
WHERE request_status IN ('SUCCEEDED', 'FAILED', 'STOPPED', 'PERSIST_FAILED')
  AND updated_time < @ledger_cutoff_time
ORDER BY updated_time
LIMIT 50;
```

### 6.2 执行物理删除

高风险提醒：清理台账会降低老请求的幂等恢复能力。确认对应会话和消息已过保留期后再执行。

```sql
START TRANSACTION;

CREATE TEMPORARY TABLE tmp_cleanup_ledger_ids (
  ledger_id VARCHAR(64) PRIMARY KEY
) ENGINE=Memory;

INSERT INTO tmp_cleanup_ledger_ids (ledger_id)
SELECT ledger_id
FROM da_chat_request_ledger
WHERE request_status IN ('SUCCEEDED', 'FAILED', 'STOPPED', 'PERSIST_FAILED')
  AND updated_time < @ledger_cutoff_time
ORDER BY updated_time
LIMIT 1000;

INSERT INTO archive_da_chat_request_ledger_cleanup_YYYYMMDD
SELECT l.*
FROM da_chat_request_ledger l
JOIN tmp_cleanup_ledger_ids t ON t.ledger_id = l.ledger_id;

DELETE l
FROM da_chat_request_ledger l
JOIN tmp_cleanup_ledger_ids t ON t.ledger_id = l.ledger_id;

SELECT ROW_COUNT() AS deleted_ledger_count;

COMMIT;
```

### 6.3 回滚台账

```sql
START TRANSACTION;

INSERT INTO da_chat_request_ledger
SELECT a.*
FROM archive_da_chat_request_ledger_cleanup_YYYYMMDD a
LEFT JOIN da_chat_request_ledger l ON l.ledger_id = a.ledger_id
WHERE l.ledger_id IS NULL;

COMMIT;
```

## 7. 审计日志清理

适用场景：审计日志超过企业审计保留周期。

执行前待确认：

- 企业是否要求审计日志保留 12 个月、24 个月或更久。
- 是否需要先导出到离线审计归档。
- 是否允许物理删除。

### 7.1 预览影响范围

```sql
SET @audit_cutoff_time = TIMESTAMP('2025-06-29 00:00:00');

SELECT result_status, COUNT(*) AS candidate_audit_count
FROM da_audit_log
WHERE created_time < @audit_cutoff_time
GROUP BY result_status;

SELECT audit_id, trace_id, session_id, user_message_id, result_status, created_time
FROM da_audit_log
WHERE created_time < @audit_cutoff_time
ORDER BY created_time
LIMIT 50;
```

### 7.2 执行物理删除

高风险提醒：审计日志可能用于安全追踪和合规留痕。未确认合规要求前不得执行。

```sql
START TRANSACTION;

CREATE TEMPORARY TABLE tmp_cleanup_audit_ids (
  audit_id VARCHAR(64) PRIMARY KEY
) ENGINE=Memory;

INSERT INTO tmp_cleanup_audit_ids (audit_id)
SELECT audit_id
FROM da_audit_log
WHERE created_time < @audit_cutoff_time
ORDER BY created_time
LIMIT 1000;

INSERT INTO archive_da_audit_log_cleanup_YYYYMMDD
SELECT a.*
FROM da_audit_log a
JOIN tmp_cleanup_audit_ids t ON t.audit_id = a.audit_id;

DELETE a
FROM da_audit_log a
JOIN tmp_cleanup_audit_ids t ON t.audit_id = a.audit_id;

SELECT ROW_COUNT() AS deleted_audit_count;

COMMIT;
```

### 7.3 回滚审计日志

```sql
START TRANSACTION;

INSERT INTO da_audit_log
SELECT a.*
FROM archive_da_audit_log_cleanup_YYYYMMDD a
LEFT JOIN da_audit_log l ON l.audit_id = a.audit_id
WHERE l.audit_id IS NULL;

COMMIT;
```

## 8. 任务记录清理

适用场景：Schema 初始化和向量化任务已经进入终态并超过保留期。

允许清理状态：

- `SUCCESS`
- `FAILED`

不建议清理状态：

- `PENDING`
- `PROCESSING`

### 8.1 Schema 初始化任务预览

```sql
SET @schema_task_cutoff_time = TIMESTAMP('2025-12-31 00:00:00');

SELECT task_status, COUNT(*) AS candidate_schema_task_count
FROM da_schema_init_task
WHERE task_status IN ('SUCCESS', 'FAILED')
  AND created_time < @schema_task_cutoff_time
GROUP BY task_status;

SELECT task_id, datasource_id, task_status, table_count, field_count, created_time, finished_time
FROM da_schema_init_task
WHERE task_status IN ('SUCCESS', 'FAILED')
  AND created_time < @schema_task_cutoff_time
ORDER BY created_time
LIMIT 50;
```

### 8.2 Schema 初始化任务删除

```sql
START TRANSACTION;

CREATE TEMPORARY TABLE tmp_cleanup_schema_task_ids (
  task_id VARCHAR(64) PRIMARY KEY
) ENGINE=Memory;

INSERT INTO tmp_cleanup_schema_task_ids (task_id)
SELECT task_id
FROM da_schema_init_task
WHERE task_status IN ('SUCCESS', 'FAILED')
  AND created_time < @schema_task_cutoff_time
ORDER BY created_time
LIMIT 1000;

INSERT INTO archive_da_schema_init_task_cleanup_YYYYMMDD
SELECT t.*
FROM da_schema_init_task t
JOIN tmp_cleanup_schema_task_ids c ON c.task_id = t.task_id;

DELETE t
FROM da_schema_init_task t
JOIN tmp_cleanup_schema_task_ids c ON c.task_id = t.task_id;

SELECT ROW_COUNT() AS deleted_schema_task_count;

COMMIT;
```

### 8.3 向量化任务预览

```sql
SET @vector_task_cutoff_time = TIMESTAMP('2025-12-31 00:00:00');

SELECT task_status, COUNT(*) AS candidate_vector_task_count
FROM da_vector_task
WHERE task_status IN ('SUCCESS', 'FAILED')
  AND created_time < @vector_task_cutoff_time
GROUP BY task_status;

SELECT task_id, target_type, target_id, task_status, chunk_count, created_time, finished_time
FROM da_vector_task
WHERE task_status IN ('SUCCESS', 'FAILED')
  AND created_time < @vector_task_cutoff_time
ORDER BY created_time
LIMIT 50;
```

### 8.4 向量化任务删除

```sql
START TRANSACTION;

CREATE TEMPORARY TABLE tmp_cleanup_vector_task_ids (
  task_id VARCHAR(64) PRIMARY KEY
) ENGINE=Memory;

INSERT INTO tmp_cleanup_vector_task_ids (task_id)
SELECT task_id
FROM da_vector_task
WHERE task_status IN ('SUCCESS', 'FAILED')
  AND created_time < @vector_task_cutoff_time
ORDER BY created_time
LIMIT 1000;

INSERT INTO archive_da_vector_task_cleanup_YYYYMMDD
SELECT t.*
FROM da_vector_task t
JOIN tmp_cleanup_vector_task_ids c ON c.task_id = t.task_id;

DELETE t
FROM da_vector_task t
JOIN tmp_cleanup_vector_task_ids c ON c.task_id = t.task_id;

SELECT ROW_COUNT() AS deleted_vector_task_count;

COMMIT;
```

### 8.5 回滚任务记录

```sql
START TRANSACTION;

INSERT INTO da_schema_init_task
SELECT a.*
FROM archive_da_schema_init_task_cleanup_YYYYMMDD a
LEFT JOIN da_schema_init_task t ON t.task_id = a.task_id
WHERE t.task_id IS NULL;

INSERT INTO da_vector_task
SELECT a.*
FROM archive_da_vector_task_cleanup_YYYYMMDD a
LEFT JOIN da_vector_task t ON t.task_id = a.task_id
WHERE t.task_id IS NULL;

COMMIT;
```

## 9. 清理后验证

### 9.1 表结构和初始化数据验证

```powershell
.\docs\database\run-mysql-verification-in-docker.ps1
```

期望结果：

- `da_table_count = 19`
- 后置表不存在
- 输出 `MVP database verification passed.`

### 9.2 业务一致性验证

```sql
SELECT COUNT(*) AS active_session_count
FROM da_session
WHERE deleted_flag = 0;

SELECT COUNT(*) AS orphan_message_count
FROM da_message m
LEFT JOIN da_session s ON s.session_id = m.session_id
WHERE s.session_id IS NULL;

SELECT COUNT(*) AS processing_ledger_count
FROM da_chat_request_ledger
WHERE request_status IN ('RECEIVED', 'PROCESSING');

SELECT COUNT(*) AS processing_task_count
FROM da_schema_init_task
WHERE task_status IN ('PENDING', 'PROCESSING')
UNION ALL
SELECT COUNT(*) AS processing_task_count
FROM da_vector_task
WHERE task_status IN ('PENDING', 'PROCESSING');
```

验收标准：

- 活跃会话数量符合预览和业务预期。
- 不应产生新的孤儿消息。
- 清理脚本不得删除进行中的台账和任务。

## 10. 不纳入 MVP 自动清理的内容

- 管理侧配置：`da_agent`、`da_model_config`、`da_datasource_config`、`da_skill_config`、`da_metric_definition`、`da_preset_question`。
- Schema 缓存和语义配置：`da_schema_table`、`da_schema_column`、`da_table_scope`、`da_semantic_field`。这些数据由 Schema 初始化流程刷新，不通过归档清理脚本删除。
- 知识和业务术语：`da_agent_knowledge`、`da_business_term`。删除需走知识管理流程，不能由通用清理脚本处理。
- 语音配置：`da_voice_config`。配置长期保留，敏感字段必须加密保存。
- Redis Key：按 `redis-key-spec.md` 中 TTL 自然过期。

## 11. 人工审核清单

- 已确认清理窗口、执行人、审批单和回滚负责人。
- 已完成全库备份，并验证备份文件可读。
- 已确认每类清理的 `SELECT` 预览数量。
- 已确认单批大小和预计批次数。
- 已确认不会清理 `RECEIVED`、`PROCESSING`、`PENDING` 中间态数据。
- 已确认审计日志保留周期符合企业合规要求。
- 已确认清理完成后运行 MySQL 验证脚本。
- 已记录每批执行时间、影响行数和异常信息。
