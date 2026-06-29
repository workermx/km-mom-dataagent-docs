-- MOM DataAgent MVP database verification script.
-- Run after 001_mvp_schema.sql and 002_mvp_seed_data.sql.

USE mom_data_agent;

-- 1. Table count: expected 19 MVP da_ tables.
SELECT COUNT(*) AS da_table_count
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name LIKE 'da\_%';

-- 2. Required MVP table existence.
SELECT required.table_name,
       CASE WHEN actual.table_name IS NULL THEN 'MISSING' ELSE 'OK' END AS check_status
FROM (
  SELECT 'da_agent' AS table_name UNION ALL
  SELECT 'da_model_config' UNION ALL
  SELECT 'da_datasource_config' UNION ALL
  SELECT 'da_schema_table' UNION ALL
  SELECT 'da_schema_column' UNION ALL
  SELECT 'da_table_scope' UNION ALL
  SELECT 'da_skill_config' UNION ALL
  SELECT 'da_metric_definition' UNION ALL
  SELECT 'da_agent_knowledge' UNION ALL
  SELECT 'da_business_term' UNION ALL
  SELECT 'da_semantic_field' UNION ALL
  SELECT 'da_preset_question' UNION ALL
  SELECT 'da_voice_config' UNION ALL
  SELECT 'da_session' UNION ALL
  SELECT 'da_chat_request_ledger' UNION ALL
  SELECT 'da_message' UNION ALL
  SELECT 'da_schema_init_task' UNION ALL
  SELECT 'da_vector_task' UNION ALL
  SELECT 'da_audit_log'
) required
LEFT JOIN information_schema.tables actual
  ON actual.table_schema = DATABASE()
 AND actual.table_name = required.table_name
ORDER BY required.table_name;

-- 3. Deferred table check. These must not enter MVP DDL.
SELECT forbidden.table_name,
       CASE WHEN actual.table_name IS NULL THEN 'OK' ELSE 'FORBIDDEN_PRESENT' END AS check_status
FROM (
  SELECT 'da_query_result' AS table_name UNION ALL
  SELECT 'da_table_result' UNION ALL
  SELECT 'da_indicator_result' UNION ALL
  SELECT 'da_chart_result' UNION ALL
  SELECT 'da_runtime_notice' UNION ALL
  SELECT 'da_voice_record' UNION ALL
  SELECT 'da_api_docs' UNION ALL
  SELECT 'da_system_prompt' UNION ALL
  SELECT 'da_api_invoke_log'
) forbidden
LEFT JOIN information_schema.tables actual
  ON actual.table_schema = DATABASE()
 AND actual.table_name = forbidden.table_name
ORDER BY forbidden.table_name;

-- 4. Seed data checks.
SELECT agent_id, agent_name, agent_status, is_default
FROM da_agent
WHERE agent_id = 'default'
  AND deleted_flag = 0;

SELECT model_category, COUNT(*) AS active_default_count
FROM da_model_config
WHERE agent_id = 'default'
  AND enabled_flag = 1
  AND default_flag = 1
  AND deleted_flag = 0
GROUP BY model_category
ORDER BY model_category;

SELECT datasource_id, datasource_name, readonly_flag, active_flag, enabled_flag, schema_init_status
FROM da_datasource_config
WHERE agent_id = 'default'
  AND deleted_flag = 0;

SELECT skill_code, tool_name, skill_name, enabled_flag
FROM da_skill_config
WHERE agent_id = 'default'
  AND deleted_flag = 0
ORDER BY skill_code;

SELECT metric_key, version, status, default_flag, tool_name
FROM da_metric_definition
WHERE agent_id = 'default'
  AND deleted_flag = 0
ORDER BY metric_key;

SELECT preset_question_id, question_category, question_content, enabled_flag, home_display_flag
FROM da_preset_question
WHERE agent_id = 'default'
  AND deleted_flag = 0
ORDER BY sort_order;

SELECT voice_config_id, provider, enabled_flag, test_status
FROM da_voice_config
WHERE agent_id = 'default'
  AND deleted_flag = 0;

-- 5. Constraint and column checks.
SELECT index_name, table_name
FROM information_schema.statistics
WHERE table_schema = DATABASE()
  AND (table_name, index_name) IN (
    ('da_agent', 'uk_default_agent'),
    ('da_model_config', 'uk_active_default_model'),
    ('da_datasource_config', 'uk_active_datasource'),
    ('da_skill_config', 'uk_active_skill_code'),
    ('da_skill_config', 'uk_active_tool_name'),
    ('da_metric_definition', 'uk_metric_version'),
    ('da_metric_definition', 'uk_active_default_metric'),
    ('da_schema_table', 'uk_schema_datasource_table'),
    ('da_schema_column', 'uk_schema_datasource_table_column'),
    ('da_table_scope', 'uk_datasource_table'),
    ('da_semantic_field', 'uk_datasource_table_column'),
    ('da_voice_config', 'uk_agent_voice_config'),
    ('da_message', 'uk_session_user_role'),
    ('da_chat_request_ledger', 'uk_session_user_message')
  )
GROUP BY index_name, table_name
ORDER BY table_name, index_name;

SELECT table_name, column_name, is_nullable, data_type
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND (
    (table_name = 'da_message' AND column_name IN ('user_message_id', 'metadata_json', 'message_status', 'trace_id'))
    OR (table_name = 'da_chat_request_ledger' AND column_name IN ('user_message_id', 'trace_id', 'request_status', 'last_stage', 'result_payload_snapshot'))
  )
ORDER BY table_name, column_name;

-- 6. Hard assertions for CI/local automation.
DROP PROCEDURE IF EXISTS assert_mvp_database_ready;

DELIMITER //

CREATE PROCEDURE assert_mvp_database_ready()
BEGIN
  DECLARE actual_count INT DEFAULT 0;
  DECLARE missing_count INT DEFAULT 0;
  DECLARE forbidden_count INT DEFAULT 0;
  DECLARE default_agent_count INT DEFAULT 0;
  DECLARE bad_model_count INT DEFAULT 0;
  DECLARE asr_model_count INT DEFAULT 0;
  DECLARE active_datasource_count INT DEFAULT 0;
  DECLARE enabled_skill_count INT DEFAULT 0;
  DECLARE published_metric_count INT DEFAULT 0;
  DECLARE enabled_preset_count INT DEFAULT 0;
  DECLARE voice_config_count INT DEFAULT 0;
  DECLARE required_index_count INT DEFAULT 0;
  DECLARE generated_column_count INT DEFAULT 0;
  DECLARE metric_version_index_column_count INT DEFAULT 0;
  DECLARE ledger_required_column_count INT DEFAULT 0;
  DECLARE result_payload_column_count INT DEFAULT 0;
  DECLARE runtime_success_count INT DEFAULT 0;
  DECLARE runtime_stopped_count INT DEFAULT 0;
  DECLARE runtime_persist_failed_count INT DEFAULT 0;

  SELECT COUNT(*) INTO actual_count
  FROM information_schema.tables
  WHERE table_schema = DATABASE()
    AND table_name LIKE 'da\_%';

  IF actual_count <> 19 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: expected 19 da_ tables.';
  END IF;

  SELECT COUNT(*) INTO missing_count
  FROM (
    SELECT 'da_agent' AS table_name UNION ALL
    SELECT 'da_model_config' UNION ALL
    SELECT 'da_datasource_config' UNION ALL
    SELECT 'da_schema_table' UNION ALL
    SELECT 'da_schema_column' UNION ALL
    SELECT 'da_table_scope' UNION ALL
    SELECT 'da_skill_config' UNION ALL
    SELECT 'da_metric_definition' UNION ALL
    SELECT 'da_agent_knowledge' UNION ALL
    SELECT 'da_business_term' UNION ALL
    SELECT 'da_semantic_field' UNION ALL
    SELECT 'da_preset_question' UNION ALL
    SELECT 'da_voice_config' UNION ALL
    SELECT 'da_session' UNION ALL
    SELECT 'da_chat_request_ledger' UNION ALL
    SELECT 'da_message' UNION ALL
    SELECT 'da_schema_init_task' UNION ALL
    SELECT 'da_vector_task' UNION ALL
    SELECT 'da_audit_log'
  ) required
  LEFT JOIN information_schema.tables actual
    ON actual.table_schema = DATABASE()
   AND actual.table_name = required.table_name
  WHERE actual.table_name IS NULL;

  IF missing_count <> 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: required table missing.';
  END IF;

  SELECT COUNT(*) INTO forbidden_count
  FROM (
    SELECT 'da_query_result' AS table_name UNION ALL
    SELECT 'da_table_result' UNION ALL
    SELECT 'da_indicator_result' UNION ALL
    SELECT 'da_chart_result' UNION ALL
    SELECT 'da_runtime_notice' UNION ALL
    SELECT 'da_voice_record' UNION ALL
    SELECT 'da_api_docs' UNION ALL
    SELECT 'da_system_prompt' UNION ALL
    SELECT 'da_api_invoke_log'
  ) forbidden
  JOIN information_schema.tables actual
    ON actual.table_schema = DATABASE()
   AND actual.table_name = forbidden.table_name;

  IF forbidden_count <> 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: deferred table exists.';
  END IF;

  SELECT COUNT(*) INTO default_agent_count
  FROM da_agent
  WHERE agent_id = 'default'
    AND agent_status = 'ENABLED'
    AND is_default = 1
    AND deleted_flag = 0;

  IF default_agent_count <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: default agent invalid.';
  END IF;

  SELECT COUNT(*) INTO bad_model_count
  FROM (
    SELECT 'LLM' AS model_category UNION ALL
    SELECT 'EMBEDDING'
  ) required_model
  LEFT JOIN (
    SELECT model_category, COUNT(*) AS cnt
    FROM da_model_config
    WHERE agent_id = 'default'
      AND enabled_flag = 1
      AND default_flag = 1
      AND deleted_flag = 0
    GROUP BY model_category
  ) actual_model
    ON actual_model.model_category = required_model.model_category
  WHERE COALESCE(actual_model.cnt, 0) <> 1;

  IF bad_model_count <> 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: default model config invalid.';
  END IF;

  SELECT COUNT(*) INTO asr_model_count
  FROM da_model_config
  WHERE model_category = 'ASR'
    AND deleted_flag = 0;

  IF asr_model_count <> 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: ASR must use da_voice_config.';
  END IF;

  SELECT COUNT(*) INTO active_datasource_count
  FROM da_datasource_config
  WHERE agent_id = 'default'
    AND readonly_flag = 1
    AND active_flag = 1
    AND enabled_flag = 1
    AND deleted_flag = 0;

  IF active_datasource_count <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: active datasource invalid.';
  END IF;

  SELECT COUNT(*) INTO enabled_skill_count
  FROM da_skill_config
  WHERE agent_id = 'default'
    AND skill_code IN ('WORK_ORDER_STATUS_STAT', 'LOW_STOCK_QUERY', 'EQUIPMENT_DOWNTIME_STAT')
    AND enabled_flag = 1
    AND deleted_flag = 0;

  IF enabled_skill_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: built-in skills invalid.';
  END IF;

  SELECT COUNT(*) INTO published_metric_count
  FROM da_metric_definition
  WHERE agent_id = 'default'
    AND metric_key IN ('work_order_status_summary', 'inventory_below_safety_stock', 'equipment_downtime_summary')
    AND status = 'PUBLISHED'
    AND default_flag = 1
    AND deleted_flag = 0;

  IF published_metric_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: default metrics invalid.';
  END IF;

  SELECT COUNT(*) INTO enabled_preset_count
  FROM da_preset_question
  WHERE agent_id = 'default'
    AND preset_question_id IN ('preset-work-order-status', 'preset-low-stock', 'preset-equipment-downtime')
    AND enabled_flag = 1
    AND home_display_flag = 1
    AND deleted_flag = 0;

  IF enabled_preset_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: preset questions invalid.';
  END IF;

  SELECT COUNT(*) INTO voice_config_count
  FROM da_voice_config
  WHERE agent_id = 'default'
    AND voice_config_id = 'voice-config-default'
    AND enabled_flag = 0
    AND deleted_flag = 0;

  IF voice_config_count <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: voice config invalid.';
  END IF;

  SELECT COUNT(*) INTO required_index_count
  FROM (
    SELECT 'da_agent' AS table_name, 'uk_default_agent' AS index_name UNION ALL
    SELECT 'da_model_config', 'uk_active_default_model' UNION ALL
    SELECT 'da_datasource_config', 'uk_active_datasource' UNION ALL
    SELECT 'da_skill_config', 'uk_active_skill_code' UNION ALL
    SELECT 'da_skill_config', 'uk_active_tool_name' UNION ALL
    SELECT 'da_metric_definition', 'uk_metric_version' UNION ALL
    SELECT 'da_metric_definition', 'uk_active_default_metric' UNION ALL
    SELECT 'da_schema_table', 'uk_schema_datasource_table' UNION ALL
    SELECT 'da_schema_column', 'uk_schema_datasource_table_column' UNION ALL
    SELECT 'da_table_scope', 'uk_datasource_table' UNION ALL
    SELECT 'da_semantic_field', 'uk_datasource_table_column' UNION ALL
    SELECT 'da_voice_config', 'uk_agent_voice_config' UNION ALL
    SELECT 'da_message', 'uk_session_user_role' UNION ALL
    SELECT 'da_chat_request_ledger', 'uk_session_user_message'
  ) required_index
  LEFT JOIN (
    SELECT DISTINCT table_name, index_name
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
  ) actual_index
    ON actual_index.table_name = required_index.table_name
   AND actual_index.index_name = required_index.index_name
  WHERE actual_index.index_name IS NOT NULL;

  IF required_index_count <> 14 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: required index missing.';
  END IF;

  SELECT COUNT(*) INTO generated_column_count
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND (
      (table_name = 'da_agent' AND column_name = 'default_agent_key')
      OR (table_name = 'da_model_config' AND column_name = 'active_default_key')
      OR (table_name = 'da_datasource_config' AND column_name = 'active_datasource_key')
      OR (table_name = 'da_skill_config' AND column_name IN ('active_skill_code_key', 'active_tool_key'))
      OR (table_name = 'da_metric_definition' AND column_name = 'active_default_key')
    )
    AND extra LIKE '%STORED GENERATED%';

  IF generated_column_count <> 6 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: generated columns missing.';
  END IF;

  SELECT COUNT(*) INTO metric_version_index_column_count
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'da_metric_definition'
    AND index_name = 'uk_metric_version'
    AND column_name IN ('agent_id', 'metric_key', 'version');

  IF metric_version_index_column_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: metric version index invalid.';
  END IF;

  SELECT COUNT(*) INTO ledger_required_column_count
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'da_chat_request_ledger'
    AND column_name IN ('user_message_id', 'trace_id', 'request_status', 'last_stage')
    AND is_nullable = 'NO';

  IF ledger_required_column_count <> 4 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: ledger required columns invalid.';
  END IF;

  SELECT COUNT(*) INTO result_payload_column_count
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND (
      (table_name = 'da_message' AND column_name = 'metadata_json')
      OR (table_name = 'da_chat_request_ledger' AND column_name = 'result_payload_snapshot')
    )
    AND data_type = 'longtext';

  IF result_payload_column_count <> 2 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: result payload columns invalid.';
  END IF;

  START TRANSACTION;

  INSERT INTO da_session (
    session_id, agent_id, session_title, message_count, last_active_time
  ) VALUES (
    'verify-session-runtime', 'default', 'Verify runtime flow', 2, NOW(3)
  );

  INSERT INTO da_chat_request_ledger (
    ledger_id,
    session_id,
    agent_id,
    user_message_id,
    agent_message_id,
    thread_id,
    trace_id,
    input_type,
    question_digest,
    request_status,
    last_stage,
    tool_name,
    tool_result_digest,
    result_payload_snapshot,
    attempt_count,
    heartbeat_time,
    locked_until
  ) VALUES (
    'verify-ledger-success',
    'verify-session-runtime',
    'default',
    'verify-user-message',
    'verify-agent-message',
    'verify-thread-success',
    'verify-trace-success',
    'TEXT',
    'sha256:verify-question',
    'SUCCEEDED',
    'SAVE_MESSAGES',
    'mom_work_order_status_stat',
    'sha256:verify-tool-result',
    '{"type":"TEXT","summary":"verification","resultPayload":{"cards":[]}}',
    1,
    NOW(3),
    DATE_ADD(NOW(3), INTERVAL 90 SECOND)
  );

  INSERT INTO da_message (
    message_id,
    session_id,
    agent_id,
    user_message_id,
    thread_id,
    message_role,
    input_type,
    message_content,
    display_content,
    metadata_json,
    message_status,
    trace_id
  ) VALUES
  (
    'verify-user-message',
    'verify-session-runtime',
    'default',
    'verify-user-message',
    'verify-thread-success',
    'USER',
    'TEXT',
    'Verify question',
    'Verify question',
    NULL,
    'SUCCESS',
    'verify-trace-success'
  ),
  (
    'verify-agent-message',
    'verify-session-runtime',
    'default',
    'verify-user-message',
    'verify-thread-success',
    'AGENT',
    'TEXT',
    'Verify answer',
    'Verify answer',
    '{"resultPayload":{"type":"TEXT","summary":"verification","cards":[]}}',
    'SUCCESS',
    'verify-trace-success'
  );

  INSERT INTO da_chat_request_ledger (
    ledger_id,
    session_id,
    agent_id,
    user_message_id,
    agent_message_id,
    thread_id,
    trace_id,
    input_type,
    question_digest,
    request_status,
    last_stage,
    attempt_count
  ) VALUES (
    'verify-ledger-stopped',
    'verify-session-runtime',
    'default',
    'verify-user-stopped',
    'verify-agent-stopped',
    'verify-thread-stopped',
    'verify-trace-stopped',
    'TEXT',
    'sha256:verify-stopped',
    'STOPPED',
    'CALL_TOOL',
    1
  );

  INSERT INTO da_message (
    message_id,
    session_id,
    agent_id,
    user_message_id,
    thread_id,
    message_role,
    input_type,
    message_content,
    message_status,
    trace_id
  ) VALUES (
    'verify-agent-stopped',
    'verify-session-runtime',
    'default',
    'verify-user-stopped',
    'verify-thread-stopped',
    'AGENT',
    'TEXT',
    'Stopped by user',
    'STOPPED',
    'verify-trace-stopped'
  );

  INSERT INTO da_chat_request_ledger (
    ledger_id,
    session_id,
    agent_id,
    user_message_id,
    thread_id,
    trace_id,
    input_type,
    question_digest,
    request_status,
    last_stage,
    tool_result_digest,
    result_payload_snapshot,
    attempt_count,
    error_code,
    error_message
  ) VALUES (
    'verify-ledger-persist-failed',
    'verify-session-runtime',
    'default',
    'verify-user-persist-failed',
    'verify-thread-persist-failed',
    'verify-trace-persist-failed',
    'TEXT',
    'sha256:verify-persist-failed',
    'PERSIST_FAILED',
    'SAVE_MESSAGES',
    'sha256:verify-recoverable-tool-result',
    '{"type":"TEXT","summary":"recoverable snapshot"}',
    1,
    'PERSIST_ERROR',
    'Persist failed after tool execution'
  );

  SELECT COUNT(*) INTO runtime_success_count
  FROM da_chat_request_ledger ledger
  JOIN da_message user_msg
    ON user_msg.session_id = ledger.session_id
   AND user_msg.message_id = ledger.user_message_id
   AND user_msg.message_role = 'USER'
  JOIN da_message agent_msg
    ON agent_msg.session_id = ledger.session_id
   AND agent_msg.message_id = ledger.agent_message_id
   AND agent_msg.user_message_id = ledger.user_message_id
   AND agent_msg.message_role = 'AGENT'
  WHERE ledger.ledger_id = 'verify-ledger-success'
    AND ledger.request_status = 'SUCCEEDED'
    AND JSON_VALID(agent_msg.metadata_json) = 1
    AND JSON_EXTRACT(agent_msg.metadata_json, '$.resultPayload') IS NOT NULL
    AND JSON_VALID(ledger.result_payload_snapshot) = 1;

  IF runtime_success_count <> 1 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: runtime success flow invalid.';
  END IF;

  SELECT COUNT(*) INTO runtime_stopped_count
  FROM da_chat_request_ledger ledger
  JOIN da_message agent_msg
    ON agent_msg.session_id = ledger.session_id
   AND agent_msg.message_id = ledger.agent_message_id
   AND agent_msg.message_status = 'STOPPED'
  WHERE ledger.ledger_id = 'verify-ledger-stopped'
    AND ledger.request_status = 'STOPPED';

  IF runtime_stopped_count <> 1 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: runtime stopped flow invalid.';
  END IF;

  SELECT COUNT(*) INTO runtime_persist_failed_count
  FROM da_chat_request_ledger
  WHERE ledger_id = 'verify-ledger-persist-failed'
    AND request_status = 'PERSIST_FAILED'
    AND tool_result_digest IS NOT NULL
    AND JSON_VALID(result_payload_snapshot) = 1;

  IF runtime_persist_failed_count <> 1 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP verify failed: runtime persist failed flow invalid.';
  END IF;

  ROLLBACK;
END//

DELIMITER ;

CALL assert_mvp_database_ready();
DROP PROCEDURE IF EXISTS assert_mvp_database_ready;

SELECT 'MVP database verification passed.' AS verification_status;
