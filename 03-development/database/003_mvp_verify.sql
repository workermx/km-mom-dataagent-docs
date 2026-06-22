-- MOM DataAgent MVP database verification script.
-- Run after 001_mvp_schema.sql and 002_mvp_seed_data.sql.

USE mom_data_agent;

-- 1. Table count: expected 22.
SELECT COUNT(*) AS da_table_count
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name LIKE 'da\_%';

-- 2. Required table existence.
SELECT required.table_name,
       CASE WHEN actual.table_name IS NULL THEN 'MISSING' ELSE 'OK' END AS check_status
FROM (
  SELECT 'da_agent' AS table_name UNION ALL
  SELECT 'da_model_config' UNION ALL
  SELECT 'da_datasource_config' UNION ALL
  SELECT 'da_table_scope' UNION ALL
  SELECT 'da_skill_config' UNION ALL
  SELECT 'da_agent_knowledge' UNION ALL
  SELECT 'da_business_term' UNION ALL
  SELECT 'da_semantic_field' UNION ALL
  SELECT 'da_preset_question' UNION ALL
  SELECT 'da_api_access' UNION ALL
  SELECT 'da_system_prompt' UNION ALL
  SELECT 'da_session' UNION ALL
  SELECT 'da_message' UNION ALL
  SELECT 'da_voice_record' UNION ALL
  SELECT 'da_query_result' UNION ALL
  SELECT 'da_table_result' UNION ALL
  SELECT 'da_indicator_result' UNION ALL
  SELECT 'da_chart_result' UNION ALL
  SELECT 'da_runtime_notice' UNION ALL
  SELECT 'da_schema_init_task' UNION ALL
  SELECT 'da_vector_task' UNION ALL
  SELECT 'da_audit_log'
) required
LEFT JOIN information_schema.tables actual
  ON actual.table_schema = DATABASE()
 AND actual.table_name = required.table_name
ORDER BY required.table_name;

-- 3. Seed data checks.
SELECT agent_id, agent_name, agent_status, is_default
FROM da_agent
WHERE agent_id = 'agent-mom-data'
  AND deleted_flag = 0;

SELECT model_category, COUNT(*) AS active_default_count
FROM da_model_config
WHERE agent_id = 'agent-mom-data'
  AND enabled_flag = 1
  AND default_flag = 1
  AND deleted_flag = 0
GROUP BY model_category
ORDER BY model_category;

SELECT datasource_id, datasource_name, readonly_flag, active_flag, enabled_flag
FROM da_datasource_config
WHERE agent_id = 'agent-mom-data'
  AND deleted_flag = 0;

SELECT skill_code, skill_name, enabled_flag
FROM da_skill_config
WHERE agent_id = 'agent-mom-data'
  AND deleted_flag = 0
ORDER BY skill_code;

SELECT preset_question_id, question_category, question_content, enabled_flag, home_display_flag
FROM da_preset_question
WHERE agent_id = 'agent-mom-data'
  AND deleted_flag = 0
ORDER BY sort_order;

-- 4. Constraint and column checks.
SELECT index_name, table_name
FROM information_schema.statistics
WHERE table_schema = DATABASE()
  AND table_name IN ('da_model_config', 'da_datasource_config', 'da_message')
  AND index_name IN ('uk_active_default_model', 'uk_active_datasource', 'uk_session_client_role')
GROUP BY index_name, table_name
ORDER BY table_name, index_name;

SELECT table_name, column_name, is_nullable, data_type
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND (
    (table_name = 'da_message' AND column_name = 'client_message_id')
    OR (table_name = 'da_table_result' AND column_name IN ('columns_json', 'rows_json'))
    OR (table_name = 'da_chart_result' AND column_name = 'chart_data_json')
  )
ORDER BY table_name, column_name;

-- 5. Hard assertions for CI/local automation.
DROP PROCEDURE IF EXISTS assert_mvp_database_ready;

DELIMITER //

CREATE PROCEDURE assert_mvp_database_ready()
BEGIN
  DECLARE actual_count INT DEFAULT 0;
  DECLARE missing_count INT DEFAULT 0;
  DECLARE default_agent_count INT DEFAULT 0;
  DECLARE bad_model_count INT DEFAULT 0;
  DECLARE active_datasource_count INT DEFAULT 0;
  DECLARE enabled_skill_count INT DEFAULT 0;
  DECLARE enabled_preset_count INT DEFAULT 0;
  DECLARE api_access_count INT DEFAULT 0;
  DECLARE system_prompt_count INT DEFAULT 0;
  DECLARE required_index_count INT DEFAULT 0;
  DECLARE client_message_nullable VARCHAR(3) DEFAULT NULL;
  DECLARE longtext_result_column_count INT DEFAULT 0;

  SELECT COUNT(*) INTO actual_count
  FROM information_schema.tables
  WHERE table_schema = DATABASE()
    AND table_name LIKE 'da\_%';

  IF actual_count <> 22 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: expected 22 da_ tables.';
  END IF;

  SELECT COUNT(*) INTO missing_count
  FROM (
    SELECT 'da_agent' AS table_name UNION ALL
    SELECT 'da_model_config' UNION ALL
    SELECT 'da_datasource_config' UNION ALL
    SELECT 'da_table_scope' UNION ALL
    SELECT 'da_skill_config' UNION ALL
    SELECT 'da_agent_knowledge' UNION ALL
    SELECT 'da_business_term' UNION ALL
    SELECT 'da_semantic_field' UNION ALL
    SELECT 'da_preset_question' UNION ALL
    SELECT 'da_api_access' UNION ALL
    SELECT 'da_system_prompt' UNION ALL
    SELECT 'da_session' UNION ALL
    SELECT 'da_message' UNION ALL
    SELECT 'da_voice_record' UNION ALL
    SELECT 'da_query_result' UNION ALL
    SELECT 'da_table_result' UNION ALL
    SELECT 'da_indicator_result' UNION ALL
    SELECT 'da_chart_result' UNION ALL
    SELECT 'da_runtime_notice' UNION ALL
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
      SET MESSAGE_TEXT = 'MVP database verification failed: required table missing.';
  END IF;

  SELECT COUNT(*) INTO default_agent_count
  FROM da_agent
  WHERE agent_id = 'agent-mom-data'
    AND agent_status = 'ENABLED'
    AND is_default = 1
    AND deleted_flag = 0;

  IF default_agent_count <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: expected one enabled default agent.';
  END IF;

  SELECT COUNT(*) INTO bad_model_count
  FROM (
    SELECT 'LLM' AS model_category UNION ALL
    SELECT 'EMBEDDING' UNION ALL
    SELECT 'ASR'
  ) required_model
  LEFT JOIN (
    SELECT model_category, COUNT(*) AS cnt
    FROM da_model_config
    WHERE agent_id = 'agent-mom-data'
      AND enabled_flag = 1
      AND default_flag = 1
      AND deleted_flag = 0
    GROUP BY model_category
  ) actual_model
    ON actual_model.model_category = required_model.model_category
  WHERE COALESCE(actual_model.cnt, 0) <> 1;

  IF bad_model_count <> 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: each model category must have exactly one active default config.';
  END IF;

  SELECT COUNT(*) INTO active_datasource_count
  FROM da_datasource_config
  WHERE agent_id = 'agent-mom-data'
    AND readonly_flag = 1
    AND active_flag = 1
    AND enabled_flag = 1
    AND deleted_flag = 0;

  IF active_datasource_count <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: expected one active readonly datasource.';
  END IF;

  SELECT COUNT(*) INTO enabled_skill_count
  FROM da_skill_config
  WHERE agent_id = 'agent-mom-data'
    AND skill_code IN ('WORK_ORDER_STATUS_STAT', 'LOW_STOCK_QUERY', 'EQUIPMENT_DOWNTIME_STAT')
    AND enabled_flag = 1
    AND deleted_flag = 0;

  IF enabled_skill_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: expected three enabled built-in skills.';
  END IF;

  SELECT COUNT(*) INTO enabled_preset_count
  FROM da_preset_question
  WHERE agent_id = 'agent-mom-data'
    AND preset_question_id IN ('preset-work-order-status', 'preset-low-stock', 'preset-equipment-downtime')
    AND enabled_flag = 1
    AND home_display_flag = 1
    AND deleted_flag = 0;

  IF enabled_preset_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: expected three enabled home preset questions.';
  END IF;

  SELECT COUNT(*) INTO api_access_count
  FROM da_api_access
  WHERE api_access_id = 'api-access-default'
    AND agent_id = 'agent-mom-data'
    AND key_status = 'NOT_GENERATED';

  IF api_access_count <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: expected default API access config.';
  END IF;

  SELECT COUNT(*) INTO system_prompt_count
  FROM da_system_prompt
  WHERE prompt_version = 'v1.0'
    AND enabled_flag = 1;

  IF system_prompt_count <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: expected enabled system prompt v1.0.';
  END IF;

  SELECT COUNT(*) INTO required_index_count
  FROM (
    SELECT 'da_model_config' AS table_name, 'uk_active_default_model' AS index_name UNION ALL
    SELECT 'da_datasource_config', 'uk_active_datasource' UNION ALL
    SELECT 'da_message', 'uk_session_client_role'
  ) required_index
  LEFT JOIN (
    SELECT DISTINCT table_name, index_name
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
  ) actual_index
    ON actual_index.table_name = required_index.table_name
   AND actual_index.index_name = required_index.index_name
  WHERE actual_index.index_name IS NOT NULL;

  IF required_index_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: required unique index missing.';
  END IF;

  SELECT is_nullable INTO client_message_nullable
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'da_message'
    AND column_name = 'client_message_id';

  IF client_message_nullable <> 'NO' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: da_message.client_message_id must be NOT NULL.';
  END IF;

  SELECT COUNT(*) INTO longtext_result_column_count
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND (
      (table_name = 'da_table_result' AND column_name IN ('columns_json', 'rows_json'))
      OR (table_name = 'da_chart_result' AND column_name = 'chart_data_json')
    )
    AND data_type = 'longtext';

  IF longtext_result_column_count <> 3 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'MVP database verification failed: result JSON columns must be LONGTEXT.';
  END IF;
END//

DELIMITER ;

CALL assert_mvp_database_ready();
DROP PROCEDURE IF EXISTS assert_mvp_database_ready;

SELECT 'MVP database verification passed.' AS verification_status;

