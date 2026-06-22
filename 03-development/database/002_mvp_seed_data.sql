-- MOM DataAgent MVP seed data.
-- This script is for local development and first-time MVP bootstrapping only.
-- It intentionally keeps placeholder cipher text. Real model keys and
-- datasource passwords must be configured through the backend encryption
-- flow or management API, not by editing this seed file.

USE mom_data_agent;

SET @agent_id = 'agent-mom-data';

INSERT INTO da_agent (
  agent_id, agent_name, agent_status, is_default
) VALUES (
  @agent_id, 'MOM 鏅鸿兘闂暟鍔╂墜', 'ENABLED', 1
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
  ('model-llm-default', @agent_id, '榛樿 LLM 妯″瀷', 'LLM', 'OPENAI_COMPATIBLE',
   'https://api.example.com/v1', 'CIPHER_PLACEHOLDER_REPLACE_ME', 'sk-****',
   'gpt-compatible-chat', 'STREAM', 0.200, 4096, 1, 1, 'NOT_TESTED',
   'MVP 鍗犱綅閰嶇疆锛岃仈璋冨墠鏇挎崲涓虹湡瀹炴ā鍨嬫湇鍔?),
  ('model-embedding-default', @agent_id, '榛樿 Embedding 妯″瀷', 'EMBEDDING', 'OPENAI_COMPATIBLE',
   'https://api.example.com/v1', 'CIPHER_PLACEHOLDER_REPLACE_ME', 'sk-****',
   'text-embedding-compatible', 'NON_STREAM', NULL, NULL, 1, 1, 'NOT_TESTED',
   'MVP 鍗犱綅閰嶇疆锛岀煡璇嗗悜閲忓寲鍓嶆浛鎹?),
  ('model-asr-default', @agent_id, '榛樿 ASR 妯″瀷', 'ASR', 'OPENAI_COMPATIBLE',
   'https://api.example.com/v1', 'CIPHER_PLACEHOLDER_REPLACE_ME', 'sk-****',
   'speech-to-text-compatible', 'NON_STREAM', NULL, NULL, 0, 0, 'NOT_TESTED',
   'P2 璇煶涓撻」棰勭暀閰嶇疆锛屼竴鏈熼棶绛斾富閾捐矾涓嶅惎鐢?)
ON DUPLICATE KEY UPDATE
  config_name = VALUES(config_name),
  provider = VALUES(provider),
  base_url = VALUES(base_url),
  api_key_masked = VALUES(api_key_masked),
  model_name = VALUES(model_name),
  request_mode = VALUES(request_mode),
  enabled_flag = VALUES(enabled_flag),
  default_flag = VALUES(default_flag),
  remark = VALUES(remark),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_datasource_config (
  datasource_id, agent_id, datasource_name, datasource_type, host, port,
  database_name, username, password_cipher, password_masked,
  readonly_flag, dangerous_sql_block_flag, max_return_rows, query_timeout_ms,
  enabled_flag, active_flag, connect_status, schema_init_status, remark
) VALUES (
  'ds-mom-default', @agent_id, 'MOM 涓氬姟鍙鏁版嵁婧?, 'MYSQL',
  '127.0.0.1', 3306, 'mom_business', 'mom_readonly',
  'CIPHER_PLACEHOLDER_REPLACE_ME', '******',
  1, 1, 1000, 6000,
  1, 1, 'NOT_TESTED', 'NOT_INIT',
  'MVP 鍗犱綅鏁版嵁婧愶紝蹇呴』鏇挎崲涓虹湡瀹炲彧璇昏处鍙峰悗鍐嶈仈璋?
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
  remark = VALUES(remark),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_skill_config (
  skill_id, agent_id, skill_code, tool_name, skill_name, source_type, version,
  enabled_flag, test_status, description, import_time
) VALUES
  ('skill-work-order-status', @agent_id, 'WORK_ORDER_STATUS_STAT', 'workOrderStatusSummary', '宸ュ崟鐘舵€佺粺璁?, 'BUILT_IN', 'v1.0',
   1, 'NOT_TESTED', '鎸夊伐鍗曠姸鎬佺粺璁″綋鍓嶅伐鍗曟暟閲?, CURRENT_TIMESTAMP(3)),
  ('skill-low-stock', @agent_id, 'LOW_STOCK_QUERY', 'inventoryBelowSafetyStock', '浣庡畨鍏ㄥ簱瀛樻煡璇?, 'BUILT_IN', 'v1.0',
   1, 'NOT_TESTED', '鏌ヨ浣庝簬瀹夊叏搴撳瓨鐨勭墿鏂?, CURRENT_TIMESTAMP(3)),
  ('skill-equipment-downtime', @agent_id, 'EQUIPMENT_DOWNTIME_STAT', 'equipmentDowntimeSummary', '璁惧鍋滄満缁熻', 'BUILT_IN', 'v1.0',
   1, 'NOT_TESTED', '鍒嗘瀽璁惧鍋滄満鏃堕暱', CURRENT_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE
  tool_name = VALUES(tool_name),
  skill_name = VALUES(skill_name),
  version = VALUES(version),
  enabled_flag = VALUES(enabled_flag),
  description = VALUES(description),
  updated_time = CURRENT_TIMESTAMP(3),
  deleted_flag = 0;

INSERT INTO da_metric_definition (
  metric_id, agent_id, metric_key, metric_name, domain, version, status,
  default_flag, tool_name, calculation_rule, effective_time, published_by,
  published_time
) VALUES
  ('metric-work-order-status-v1', @agent_id, 'work_order_status_summary', '宸ュ崟鐘舵€佺粺璁?, '宸ュ崟', 'v1.0', 'PUBLISHED',
   1, 'workOrderStatusSummary', '鎸夊伐鍗曠姸鎬佸垎缁勭粺璁″綋鍓嶅伐鍗曟暟閲忋€?, CURRENT_TIMESTAMP(3), 'system', CURRENT_TIMESTAMP(3)),
  ('metric-inventory-low-stock-v1', @agent_id, 'inventory_below_safety_stock', '浣庝簬瀹夊叏搴撳瓨鐗╂枡', '搴撳瓨', 'v1.0', 'PUBLISHED',
   1, 'inventoryBelowSafetyStock', '鏌ヨ褰撳墠搴撳瓨鏁伴噺浣庝簬瀹夊叏搴撳瓨闃堝€肩殑鐗╂枡娓呭崟銆?, CURRENT_TIMESTAMP(3), 'system', CURRENT_TIMESTAMP(3)),
  ('metric-equipment-downtime-v1', @agent_id, 'equipment_downtime_summary', '璁惧鍋滄満鏃堕暱鍒嗘瀽', '璁惧', 'v1.0', 'PUBLISHED',
   1, 'equipmentDowntimeSummary', '鎸夎澶囩粺璁℃寚瀹氳寖鍥村唴鍋滄満鏃堕暱銆?, CURRENT_TIMESTAMP(3), 'system', CURRENT_TIMESTAMP(3))
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
  ('preset-work-order-status', @agent_id, '宸ュ崟鐘舵€佺粺璁?, '鎸夊伐鍗曠姸鎬佺粺璁″綋鍓嶅伐鍗曟暟閲?, '宸ュ崟', 'HOME', 10, 1, 1),
  ('preset-low-stock', @agent_id, '浣庡畨鍏ㄥ簱瀛樼墿鏂?, '鏌ヨ浣庝簬瀹夊叏搴撳瓨鐨勭墿鏂?, '搴撳瓨', 'HOME', 20, 1, 1),
  ('preset-equipment-downtime', @agent_id, '璁惧鍋滄満鍒嗘瀽', '鍒嗘瀽璁惧鍋滄満鏃堕暱', '璁惧', 'HOME', 30, 1, 1)
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

INSERT INTO da_api_access (
  api_access_id, agent_id, api_enabled_flag, key_status,
  invoke_url, request_example, response_example
) VALUES (
  'api-access-default', @agent_id, 0, 'NOT_GENERATED',
  '/api/data-agent/chat',
  '{"sessionId":"session_xxx","clientMessageId":"client_msg_xxx","question":"鎸夊伐鍗曠姸鎬佺粺璁″綋鍓嶅伐鍗曟暟閲?,"inputMode":"text"}',
  '{"traceId":"trace_xxx","status":"SUCCESS","message":"ok"}'
) ON DUPLICATE KEY UPDATE
  api_enabled_flag = VALUES(api_enabled_flag),
  key_status = VALUES(key_status),
  invoke_url = VALUES(invoke_url),
  request_example = VALUES(request_example),
  response_example = VALUES(response_example),
  updated_time = CURRENT_TIMESTAMP(3);

INSERT INTO da_system_prompt (
  prompt_version, prompt_content, enabled_flag
) VALUES (
  'v1.0',
  '浣犳槸 MOM 鏅鸿兘闂暟鍔╂墜銆備綘鍙兘鍩轰簬宸叉巿鏉冪殑鏁版嵁婧愩€丼kill銆佷笟鍔＄煡璇嗗拰璇箟瀛楁鍥炵瓟闂銆備笉寰楃敓鎴愭垨鎵ц鍐欐搷浣?SQL銆傞亣鍒版棤鏁版嵁銆侀厤缃笉鍙敤鎴栭棶棰樹笉鏄庣‘鏃讹紝搴旇繑鍥炵粨鏋勫寲鎻愮ず銆?,
  1
) ON DUPLICATE KEY UPDATE
  prompt_content = VALUES(prompt_content),
  enabled_flag = VALUES(enabled_flag),
  updated_time = CURRENT_TIMESTAMP(3);

