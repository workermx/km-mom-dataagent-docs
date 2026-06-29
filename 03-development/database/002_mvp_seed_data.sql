-- MOM DataAgent MVP seed data.
-- This script is for local development and first-time MVP bootstrapping only.
-- It uses placeholder ciphertext. Real model keys, ASR keys, and datasource
-- passwords must be written through the backend encryption flow.

USE mom_data_agent;

SET @agent_id = 'default';

INSERT INTO da_agent (
  agent_id, agent_name, agent_status, is_default
) VALUES (
  @agent_id, 'MOM智能问数默认Agent', 'ENABLED', 1
) ON DUPLICATE KEY UPDATE
  agent_name = VALUES(agent_name),
  agent_status = VALUES(agent_status),
  is_default = VALUES(is_default),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_model_config (
  model_config_id, agent_id, config_name, model_category, provider, base_url,
  api_key_cipher, api_key_masked, model_name, request_mode, temperature,
  max_tokens, enabled_flag, default_flag, test_status, remark
) VALUES
  (
    'model-llm-default', @agent_id, '默认LLM模型', 'LLM', 'OPENAI_COMPATIBLE',
    'https://api.example.com/v1', 'CIPHER_PLACEHOLDER_REPLACE_ME', 'sk-****',
    'gpt-compatible-chat', 'STREAM', 0.200, 4096, 1, 1, 'UNTESTED',
    'MVP本地占位配置，联调前通过管理接口写入真实加密配置'
  ),
  (
    'model-embedding-default', @agent_id, '默认Embedding模型', 'EMBEDDING', 'OPENAI_COMPATIBLE',
    'https://api.example.com/v1', 'CIPHER_PLACEHOLDER_REPLACE_ME', 'sk-****',
    'text-embedding-compatible', 'NON_STREAM', NULL, NULL, 1, 1, 'UNTESTED',
    'MVP本地占位配置，知识向量化前通过管理接口写入真实加密配置'
  )
ON DUPLICATE KEY UPDATE
  config_name = VALUES(config_name),
  provider = VALUES(provider),
  base_url = VALUES(base_url),
  api_key_masked = VALUES(api_key_masked),
  model_name = VALUES(model_name),
  request_mode = VALUES(request_mode),
  temperature = VALUES(temperature),
  max_tokens = VALUES(max_tokens),
  enabled_flag = VALUES(enabled_flag),
  default_flag = VALUES(default_flag),
  test_status = VALUES(test_status),
  remark = VALUES(remark),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_datasource_config (
  datasource_id, agent_id, datasource_name, datasource_type, host, port,
  database_name, username, password_cipher, password_masked,
  readonly_flag, dangerous_sql_block_flag, max_return_rows, query_timeout_ms,
  enabled_flag, active_flag, connect_status, schema_init_status, remark
) VALUES (
  'ds-mom-default', @agent_id, 'MOM业务只读数据源', 'MYSQL',
  '127.0.0.1', 3306, 'mom_business', 'mom_readonly',
  'CIPHER_PLACEHOLDER_REPLACE_ME', '******',
  1, 1, 1000, 6000,
  1, 1, 'UNTESTED', 'NOT_INITIALIZED',
  'MVP本地占位数据源，必须替换为真实只读账号后再联调'
) ON DUPLICATE KEY UPDATE
  datasource_name = VALUES(datasource_name),
  datasource_type = VALUES(datasource_type),
  host = VALUES(host),
  port = VALUES(port),
  database_name = VALUES(database_name),
  username = VALUES(username),
  password_masked = VALUES(password_masked),
  readonly_flag = VALUES(readonly_flag),
  dangerous_sql_block_flag = VALUES(dangerous_sql_block_flag),
  max_return_rows = VALUES(max_return_rows),
  query_timeout_ms = VALUES(query_timeout_ms),
  enabled_flag = VALUES(enabled_flag),
  active_flag = VALUES(active_flag),
  connect_status = VALUES(connect_status),
  schema_init_status = VALUES(schema_init_status),
  remark = VALUES(remark),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_skill_config (
  skill_id, agent_id, skill_code, tool_name, skill_name, source_type, version,
  enabled_flag, test_status, description, import_time
) VALUES
  (
    'skill-work-order-status', @agent_id, 'WORK_ORDER_STATUS_STAT',
    'workOrderStatusSummary', '工单状态统计', 'BUILT_IN', 'v1.0',
    1, 'UNTESTED', '按工单状态统计当前工单数量', CURRENT_TIMESTAMP(3)
  ),
  (
    'skill-low-stock', @agent_id, 'LOW_STOCK_QUERY',
    'inventoryBelowSafetyStock', '低安全库存查询', 'BUILT_IN', 'v1.0',
    1, 'UNTESTED', '查询低于安全库存的物料', CURRENT_TIMESTAMP(3)
  ),
  (
    'skill-equipment-downtime', @agent_id, 'EQUIPMENT_DOWNTIME_STAT',
    'equipmentDowntimeSummary', '设备停机统计', 'BUILT_IN', 'v1.0',
    1, 'UNTESTED', '分析设备停机时长', CURRENT_TIMESTAMP(3)
  )
ON DUPLICATE KEY UPDATE
  tool_name = VALUES(tool_name),
  skill_name = VALUES(skill_name),
  version = VALUES(version),
  enabled_flag = VALUES(enabled_flag),
  test_status = VALUES(test_status),
  description = VALUES(description),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_metric_definition (
  metric_id, agent_id, metric_key, metric_name, domain, version, status,
  default_flag, tool_name, calculation_rule, effective_time, published_by,
  published_time
) VALUES
  (
    'metric-work-order-status-v1', @agent_id, 'work_order_status_summary',
    '工单状态统计', '工单', 'v1.0', 'PUBLISHED',
    1, 'workOrderStatusSummary', '按工单状态分组统计当前工单数量。',
    CURRENT_TIMESTAMP(3), 'system', CURRENT_TIMESTAMP(3)
  ),
  (
    'metric-inventory-low-stock-v1', @agent_id, 'inventory_below_safety_stock',
    '低于安全库存物料', '库存', 'v1.0', 'PUBLISHED',
    1, 'inventoryBelowSafetyStock', '查询当前库存数量低于安全库存阈值的物料清单。',
    CURRENT_TIMESTAMP(3), 'system', CURRENT_TIMESTAMP(3)
  ),
  (
    'metric-equipment-downtime-v1', @agent_id, 'equipment_downtime_summary',
    '设备停机时长分析', '设备', 'v1.0', 'PUBLISHED',
    1, 'equipmentDowntimeSummary', '按设备统计指定范围内停机时长。',
    CURRENT_TIMESTAMP(3), 'system', CURRENT_TIMESTAMP(3)
  )
ON DUPLICATE KEY UPDATE
  metric_name = VALUES(metric_name),
  domain = VALUES(domain),
  status = VALUES(status),
  default_flag = VALUES(default_flag),
  tool_name = VALUES(tool_name),
  calculation_rule = VALUES(calculation_rule),
  published_time = VALUES(published_time),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_preset_question (
  preset_question_id, agent_id, question_title, question_content,
  question_category, display_scene, sort_order, enabled_flag, home_display_flag
) VALUES
  (
    'preset-work-order-status', @agent_id, '工单状态统计',
    '按工单状态统计当前工单数量', '工单', 'HOME', 10, 1, 1
  ),
  (
    'preset-low-stock', @agent_id, '低安全库存物料',
    '查询低于安全库存的物料', '库存', 'HOME', 20, 1, 1
  ),
  (
    'preset-equipment-downtime', @agent_id, '设备停机分析',
    '分析设备停机时长', '设备', 'HOME', 30, 1, 1
  )
ON DUPLICATE KEY UPDATE
  question_title = VALUES(question_title),
  question_content = VALUES(question_content),
  question_category = VALUES(question_category),
  display_scene = VALUES(display_scene),
  sort_order = VALUES(sort_order),
  enabled_flag = VALUES(enabled_flag),
  home_display_flag = VALUES(home_display_flag),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_voice_config (
  voice_config_id, agent_id, provider, base_url_cipher, base_url_masked,
  app_id, api_key_cipher, api_key_masked, secret_key_cipher, secret_key_masked,
  model_name, language, sample_rate, max_duration_seconds, max_file_size_mb,
  timeout_ms, enabled_flag, test_status, test_message
) VALUES (
  'voice-config-default', @agent_id, 'ASR_COMPATIBLE',
  'CIPHER_PLACEHOLDER_REPLACE_ME', 'https://asr.example.com/**',
  'app-****', 'CIPHER_PLACEHOLDER_REPLACE_ME', 'ak-****',
  'CIPHER_PLACEHOLDER_REPLACE_ME', 'sk-****',
  'speech-to-text-compatible', 'zh-CN', 16000, 60, 10,
  30000, 0, 'UNTESTED', 'MVP占位语音配置，默认禁用；文本问数不依赖该配置'
) ON DUPLICATE KEY UPDATE
  provider = VALUES(provider),
  base_url_masked = VALUES(base_url_masked),
  app_id = VALUES(app_id),
  api_key_masked = VALUES(api_key_masked),
  secret_key_masked = VALUES(secret_key_masked),
  model_name = VALUES(model_name),
  language = VALUES(language),
  sample_rate = VALUES(sample_rate),
  max_duration_seconds = VALUES(max_duration_seconds),
  max_file_size_mb = VALUES(max_file_size_mb),
  timeout_ms = VALUES(timeout_ms),
  enabled_flag = VALUES(enabled_flag),
  test_status = VALUES(test_status),
  test_message = VALUES(test_message),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;
