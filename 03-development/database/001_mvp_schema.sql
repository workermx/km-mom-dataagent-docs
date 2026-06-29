-- MOM DataAgent MVP system database schema.
-- Target: MySQL 8.0.
-- Source of truth: docs/database/MOM智能问数-MVP数据库设计文档.md.
-- MVP stores final result payloads in da_message.metadata_json.resultPayload.

CREATE DATABASE IF NOT EXISTS mom_data_agent
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE mom_data_agent;

CREATE TABLE IF NOT EXISTS da_agent (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  agent_id VARCHAR(64) NOT NULL COMMENT 'Agent identifier',
  agent_name VARCHAR(128) NOT NULL COMMENT 'Agent name',
  agent_status VARCHAR(32) NOT NULL COMMENT 'ENABLED, DISABLED',
  is_default TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'Default agent flag',
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  default_agent_key VARCHAR(32)
    GENERATED ALWAYS AS (
      CASE WHEN is_default = 1 AND deleted_flag = 0 THEN 'DEFAULT' ELSE NULL END
    ) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uk_agent_id (agent_id),
  UNIQUE KEY uk_default_agent (default_agent_key),
  KEY idx_default_status (is_default, agent_status, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Default agent';

CREATE TABLE IF NOT EXISTS da_model_config (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  model_config_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  config_name VARCHAR(128) NOT NULL,
  model_category VARCHAR(32) NOT NULL COMMENT 'LLM, EMBEDDING',
  provider VARCHAR(64) NOT NULL,
  base_url VARCHAR(512) NOT NULL,
  api_key_cipher TEXT NOT NULL,
  api_key_masked VARCHAR(128) NOT NULL,
  cipher_version VARCHAR(32) NOT NULL DEFAULT 'v1',
  kms_key_id VARCHAR(128) NULL,
  model_name VARCHAR(128) NOT NULL,
  request_mode VARCHAR(32) NULL COMMENT 'STREAM, NON_STREAM',
  temperature DECIMAL(4,3) NULL,
  max_tokens INT NULL,
  enabled_flag TINYINT(1) NOT NULL DEFAULT 1,
  default_flag TINYINT(1) NOT NULL DEFAULT 0,
  test_status VARCHAR(32) NOT NULL DEFAULT 'UNTESTED',
  test_message VARCHAR(1024) NULL,
  last_test_time DATETIME(3) NULL,
  remark VARCHAR(512) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  active_default_key VARCHAR(160)
    GENERATED ALWAYS AS (
      CASE
        WHEN enabled_flag = 1 AND default_flag = 1 AND deleted_flag = 0
        THEN CONCAT(agent_id, '#', model_category)
        ELSE NULL
      END
    ) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uk_model_config_id (model_config_id),
  UNIQUE KEY uk_active_default_model (active_default_key),
  KEY idx_agent_category (agent_id, model_category, deleted_flag),
  KEY idx_agent_category_default (agent_id, model_category, default_flag, enabled_flag, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='LLM and embedding model config';

CREATE TABLE IF NOT EXISTS da_datasource_config (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  datasource_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  datasource_name VARCHAR(128) NOT NULL,
  datasource_type VARCHAR(32) NOT NULL COMMENT 'MYSQL, DM, ORACLE, SQLSERVER, POSTGRESQL',
  host VARCHAR(256) NOT NULL,
  port INT NOT NULL,
  database_name VARCHAR(128) NOT NULL,
  username VARCHAR(128) NOT NULL,
  password_cipher TEXT NOT NULL,
  password_masked VARCHAR(128) NOT NULL,
  connection_url_cipher TEXT NULL,
  cipher_version VARCHAR(32) NOT NULL DEFAULT 'v1',
  kms_key_id VARCHAR(128) NULL,
  readonly_flag TINYINT(1) NOT NULL DEFAULT 1,
  dangerous_sql_block_flag TINYINT(1) NOT NULL DEFAULT 1,
  max_return_rows INT NOT NULL DEFAULT 1000,
  query_timeout_ms INT NOT NULL DEFAULT 6000,
  enabled_flag TINYINT(1) NOT NULL DEFAULT 1,
  active_flag TINYINT(1) NOT NULL DEFAULT 0,
  connect_status VARCHAR(32) NOT NULL DEFAULT 'UNTESTED',
  connect_message VARCHAR(1024) NULL,
  schema_init_status VARCHAR(32) NOT NULL DEFAULT 'NOT_INITIALIZED',
  last_init_time DATETIME(3) NULL,
  table_count INT NULL,
  field_count INT NULL,
  remark VARCHAR(512) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  active_datasource_key VARCHAR(64)
    GENERATED ALWAYS AS (
      CASE WHEN enabled_flag = 1 AND active_flag = 1 AND deleted_flag = 0 THEN agent_id ELSE NULL END
    ) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uk_datasource_id (datasource_id),
  UNIQUE KEY uk_active_datasource (active_datasource_key),
  KEY idx_agent_active (agent_id, active_flag, enabled_flag, deleted_flag),
  KEY idx_connect_status (connect_status, schema_init_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Datasource config';

CREATE TABLE IF NOT EXISTS da_schema_table (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  schema_table_id VARCHAR(64) NOT NULL,
  datasource_id VARCHAR(64) NOT NULL,
  table_name VARCHAR(128) NOT NULL,
  table_comment VARCHAR(512) NULL,
  table_type VARCHAR(32) NULL COMMENT 'TABLE, VIEW',
  field_count INT NULL,
  last_init_time DATETIME(3) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_schema_table_id (schema_table_id),
  UNIQUE KEY uk_schema_datasource_table (datasource_id, table_name, deleted_flag),
  KEY idx_schema_datasource_time (datasource_id, last_init_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Initialized schema table cache';

CREATE TABLE IF NOT EXISTS da_schema_column (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  schema_column_id VARCHAR(64) NOT NULL,
  datasource_id VARCHAR(64) NOT NULL,
  table_name VARCHAR(128) NOT NULL,
  column_name VARCHAR(128) NOT NULL,
  column_comment VARCHAR(512) NULL,
  data_type VARCHAR(128) NOT NULL,
  nullable_flag TINYINT(1) NULL,
  primary_key_flag TINYINT(1) NOT NULL DEFAULT 0,
  ordinal_position INT NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_schema_column_id (schema_column_id),
  UNIQUE KEY uk_schema_datasource_table_column (datasource_id, table_name, column_name, deleted_flag),
  KEY idx_schema_datasource_table (datasource_id, table_name, ordinal_position)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Initialized schema column cache';

CREATE TABLE IF NOT EXISTS da_table_scope (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  table_scope_id VARCHAR(64) NOT NULL,
  datasource_id VARCHAR(64) NOT NULL,
  table_name VARCHAR(128) NOT NULL,
  table_comment VARCHAR(512) NULL,
  field_count INT NULL,
  in_query_scope TINYINT(1) NOT NULL DEFAULT 0,
  is_core_table TINYINT(1) NOT NULL DEFAULT 0,
  sort_order INT NOT NULL DEFAULT 0,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_table_scope_id (table_scope_id),
  UNIQUE KEY uk_datasource_table (datasource_id, table_name),
  KEY idx_datasource_query_scope (datasource_id, in_query_scope, is_core_table)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Queryable table scope';

CREATE TABLE IF NOT EXISTS da_skill_config (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  skill_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  skill_code VARCHAR(128) NOT NULL,
  tool_name VARCHAR(128) NOT NULL,
  skill_name VARCHAR(128) NOT NULL,
  source_type VARCHAR(32) NOT NULL COMMENT 'BUILT_IN, IMPORTED',
  version VARCHAR(64) NULL,
  enabled_flag TINYINT(1) NOT NULL DEFAULT 1,
  test_status VARCHAR(32) NOT NULL DEFAULT 'UNTESTED',
  description VARCHAR(1024) NULL,
  import_time DATETIME(3) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  active_skill_code_key VARCHAR(256)
    GENERATED ALWAYS AS (
      CASE WHEN enabled_flag = 1 AND deleted_flag = 0 THEN CONCAT(agent_id, '#', skill_code) ELSE NULL END
    ) STORED,
  active_tool_key VARCHAR(256)
    GENERATED ALWAYS AS (
      CASE WHEN enabled_flag = 1 AND deleted_flag = 0 THEN CONCAT(agent_id, '#', tool_name) ELSE NULL END
    ) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uk_skill_id (skill_id),
  UNIQUE KEY uk_active_skill_code (active_skill_code_key),
  UNIQUE KEY uk_active_tool_name (active_tool_key),
  KEY idx_agent_skill_code (agent_id, skill_code, deleted_flag),
  KEY idx_agent_tool_name (agent_id, tool_name, enabled_flag, deleted_flag),
  KEY idx_agent_enabled (agent_id, enabled_flag, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Skill whitelist config';

CREATE TABLE IF NOT EXISTS da_metric_definition (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  metric_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  metric_key VARCHAR(128) NOT NULL,
  metric_name VARCHAR(128) NOT NULL,
  domain VARCHAR(64) NOT NULL,
  version VARCHAR(64) NOT NULL,
  status VARCHAR(32) NOT NULL COMMENT 'DRAFT, PUBLISHED, DISABLED',
  default_flag TINYINT(1) NOT NULL DEFAULT 0,
  tool_name VARCHAR(128) NOT NULL,
  calculation_rule LONGTEXT NOT NULL,
  effective_time DATETIME(3) NULL,
  published_by VARCHAR(64) NULL,
  published_time DATETIME(3) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  active_default_key VARCHAR(256)
    GENERATED ALWAYS AS (
      CASE
        WHEN status = 'PUBLISHED' AND default_flag = 1 AND deleted_flag = 0
        THEN CONCAT(agent_id, '#', metric_key)
        ELSE NULL
      END
    ) STORED,
  PRIMARY KEY (id),
  UNIQUE KEY uk_metric_id (metric_id),
  UNIQUE KEY uk_metric_version (agent_id, metric_key, version),
  UNIQUE KEY uk_active_default_metric (active_default_key),
  KEY idx_agent_status (agent_id, status, deleted_flag),
  KEY idx_agent_tool (agent_id, tool_name, status, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Metric definition';

CREATE TABLE IF NOT EXISTS da_agent_knowledge (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  knowledge_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  knowledge_type VARCHAR(32) NOT NULL COMMENT 'DOCUMENT, QA, FAQ',
  knowledge_title VARCHAR(256) NOT NULL,
  source_file_name VARCHAR(256) NULL,
  source_file_type VARCHAR(64) NULL,
  splitter_type VARCHAR(32) NULL,
  question VARCHAR(1024) NULL,
  answer_content LONGTEXT NULL,
  recall_flag TINYINT(1) NOT NULL DEFAULT 1,
  vector_status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  vector_message VARCHAR(1024) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_knowledge_id (knowledge_id),
  KEY idx_agent_recall (agent_id, recall_flag, vector_status, deleted_flag),
  KEY idx_knowledge_type (agent_id, knowledge_type, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Agent knowledge';

CREATE TABLE IF NOT EXISTS da_business_term (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  term_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  term_name VARCHAR(128) NOT NULL,
  description LONGTEXT NOT NULL,
  synonyms VARCHAR(1024) NULL,
  tag_names VARCHAR(512) NULL,
  enabled_flag TINYINT(1) NOT NULL DEFAULT 1,
  recall_flag TINYINT(1) NOT NULL DEFAULT 1,
  vector_status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  vector_message VARCHAR(1024) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_term_id (term_id),
  KEY idx_agent_term (agent_id, term_name, deleted_flag),
  KEY idx_agent_recall (agent_id, enabled_flag, recall_flag, vector_status, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Business term';

CREATE TABLE IF NOT EXISTS da_semantic_field (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  semantic_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  datasource_id VARCHAR(64) NOT NULL,
  table_name VARCHAR(128) NOT NULL,
  column_name VARCHAR(128) NOT NULL,
  business_name VARCHAR(128) NOT NULL,
  synonyms VARCHAR(1024) NULL,
  business_description TEXT NULL,
  column_comment VARCHAR(512) NULL,
  data_type VARCHAR(128) NOT NULL,
  enabled_flag TINYINT(1) NOT NULL DEFAULT 1,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_semantic_id (semantic_id),
  UNIQUE KEY uk_datasource_table_column (datasource_id, table_name, column_name, deleted_flag),
  KEY idx_agent_business_name (agent_id, business_name, enabled_flag, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Semantic field mapping';

CREATE TABLE IF NOT EXISTS da_preset_question (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  preset_question_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  question_title VARCHAR(128) NULL,
  question_content VARCHAR(1024) NOT NULL,
  question_category VARCHAR(64) NULL,
  display_scene VARCHAR(64) NULL COMMENT 'HOME, INPUT',
  sort_order INT NOT NULL DEFAULT 0,
  enabled_flag TINYINT(1) NOT NULL DEFAULT 1,
  home_display_flag TINYINT(1) NOT NULL DEFAULT 1,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_preset_question_id (preset_question_id),
  KEY idx_agent_home (agent_id, enabled_flag, home_display_flag, sort_order, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Preset question';

CREATE TABLE IF NOT EXISTS da_voice_config (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  voice_config_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  provider VARCHAR(64) NOT NULL,
  base_url_cipher TEXT NULL,
  base_url_masked VARCHAR(512) NULL,
  app_id VARCHAR(128) NULL,
  api_key_cipher TEXT NULL,
  api_key_masked VARCHAR(128) NULL,
  secret_key_cipher TEXT NULL,
  secret_key_masked VARCHAR(128) NULL,
  model_name VARCHAR(128) NULL,
  language VARCHAR(32) NOT NULL DEFAULT 'zh-CN',
  sample_rate INT NULL,
  max_duration_seconds INT NOT NULL DEFAULT 60,
  max_file_size_mb INT NOT NULL DEFAULT 10,
  timeout_ms INT NOT NULL DEFAULT 30000,
  enabled_flag TINYINT(1) NOT NULL DEFAULT 0,
  test_status VARCHAR(32) NOT NULL DEFAULT 'UNTESTED',
  test_message VARCHAR(1024) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_voice_config_id (voice_config_id),
  UNIQUE KEY uk_agent_voice_config (agent_id, deleted_flag),
  KEY idx_enabled (agent_id, enabled_flag, deleted_flag)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='ASR voice input config';

CREATE TABLE IF NOT EXISTS da_session (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  session_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  user_id VARCHAR(64) NULL COMMENT 'Reserved for post-MVP auth',
  tenant_id VARCHAR(64) NULL COMMENT 'Reserved for post-MVP tenant',
  session_title VARCHAR(256) NOT NULL,
  pinned_flag TINYINT(1) NOT NULL DEFAULT 0,
  deleted_flag TINYINT(1) NOT NULL DEFAULT 0,
  last_message_summary VARCHAR(512) NULL,
  message_count INT NOT NULL DEFAULT 0,
  last_active_time DATETIME(3) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_session_id (session_id),
  KEY idx_agent_deleted_active (agent_id, deleted_flag, pinned_flag, last_active_time),
  KEY idx_user_active (user_id, deleted_flag, last_active_time),
  KEY idx_tenant_active (tenant_id, deleted_flag, last_active_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chat session';

CREATE TABLE IF NOT EXISTS da_message (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  message_id VARCHAR(64) NOT NULL,
  session_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  user_message_id VARCHAR(64) NULL COMMENT 'User message id for paired agent replies',
  thread_id VARCHAR(64) NULL,
  message_role VARCHAR(32) NOT NULL COMMENT 'USER, AGENT, SYSTEM',
  input_type VARCHAR(32) NOT NULL COMMENT 'TEXT, VOICE, PRESET_QUESTION, SYSTEM',
  message_content LONGTEXT NOT NULL,
  display_content LONGTEXT NULL,
  metadata_json LONGTEXT NULL COMMENT 'JSON string; agent reply stores resultPayload',
  message_status VARCHAR(32) NOT NULL COMMENT 'PROCESSING, SUCCESS, FAILED, STOPPED',
  error_code VARCHAR(64) NULL,
  error_message VARCHAR(1024) NULL,
  trace_id VARCHAR(64) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_message_id (message_id),
  UNIQUE KEY uk_session_user_role (session_id, user_message_id, message_role),
  KEY idx_session_time (session_id, created_time),
  KEY idx_thread_id (thread_id),
  KEY idx_trace_id (trace_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chat message and result payload';

CREATE TABLE IF NOT EXISTS da_chat_request_ledger (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ledger_id VARCHAR(64) NOT NULL,
  session_id VARCHAR(64) NOT NULL,
  agent_id VARCHAR(64) NOT NULL,
  user_message_id VARCHAR(64) NOT NULL,
  agent_message_id VARCHAR(64) NULL,
  thread_id VARCHAR(64) NULL,
  trace_id VARCHAR(64) NOT NULL,
  input_type VARCHAR(32) NOT NULL COMMENT 'TEXT, VOICE, PRESET_QUESTION',
  question_digest VARCHAR(256) NOT NULL,
  question_snapshot_ref VARCHAR(256) NULL,
  request_status VARCHAR(32) NOT NULL COMMENT 'RECEIVED, PROCESSING, SUCCEEDED, PERSIST_FAILED, FAILED, STOPPED',
  last_stage VARCHAR(64) NOT NULL COMMENT 'RECEIVED, INTENT, CALL_TOOL, SAVE_MESSAGES',
  tool_name VARCHAR(128) NULL,
  tool_result_digest VARCHAR(256) NULL,
  result_payload_snapshot LONGTEXT NULL COMMENT 'JSON result payload snapshot for retry recovery',
  attempt_count INT NOT NULL DEFAULT 0,
  heartbeat_time DATETIME(3) NULL,
  locked_until DATETIME(3) NULL,
  error_code VARCHAR(64) NULL,
  error_message VARCHAR(1024) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ledger_id (ledger_id),
  UNIQUE KEY uk_session_user_message (session_id, user_message_id),
  KEY idx_agent_message (agent_message_id),
  KEY idx_thread_id (thread_id),
  KEY idx_trace_id (trace_id),
  KEY idx_status_locked (request_status, locked_until),
  KEY idx_session_status (session_id, request_status, updated_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Chat request idempotency ledger';

CREATE TABLE IF NOT EXISTS da_schema_init_task (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  task_id VARCHAR(64) NOT NULL,
  datasource_id VARCHAR(64) NOT NULL,
  task_status VARCHAR(32) NOT NULL COMMENT 'PENDING, PROCESSING, SUCCESS, FAILED',
  table_count INT NULL,
  field_count INT NULL,
  error_message VARCHAR(1024) NULL,
  started_time DATETIME(3) NULL,
  finished_time DATETIME(3) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_task_id (task_id),
  KEY idx_datasource_status (datasource_id, task_status, created_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Schema initialization task';

CREATE TABLE IF NOT EXISTS da_vector_task (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  task_id VARCHAR(64) NOT NULL,
  target_type VARCHAR(32) NOT NULL COMMENT 'AGENT_KNOWLEDGE, BUSINESS_TERM',
  target_id VARCHAR(64) NOT NULL,
  task_status VARCHAR(32) NOT NULL COMMENT 'PENDING, PROCESSING, SUCCESS, FAILED',
  chunk_count INT NULL,
  error_message VARCHAR(1024) NULL,
  started_time DATETIME(3) NULL,
  finished_time DATETIME(3) NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_task_id (task_id),
  KEY idx_target (target_type, target_id),
  KEY idx_status_time (task_status, created_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Knowledge vectorization task';

CREATE TABLE IF NOT EXISTS da_audit_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  audit_id VARCHAR(64) NOT NULL,
  trace_id VARCHAR(64) NOT NULL,
  session_id VARCHAR(64) NULL,
  user_message_id VARCHAR(64) NULL,
  agent_message_id VARCHAR(64) NULL,
  question_digest VARCHAR(256) NULL,
  input_type VARCHAR(32) NULL,
  domain VARCHAR(64) NULL,
  intent VARCHAR(128) NULL,
  tool_name VARCHAR(128) NULL,
  metric_version VARCHAR(64) NULL,
  result_status VARCHAR(32) NOT NULL,
  error_code VARCHAR(64) NULL,
  latency_ms INT NULL,
  created_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_audit_id (audit_id),
  KEY idx_trace_id (trace_id),
  KEY idx_session_user_message (session_id, user_message_id),
  KEY idx_agent_message (agent_message_id),
  KEY idx_status_time (result_status, created_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Question answering audit log';
