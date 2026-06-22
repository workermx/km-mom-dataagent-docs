# MOM鏅鸿兘闂暟-MVP鏁版嵁搴撹璁℃枃妗?
## 1. 鏂囨。璇存槑

鏈枃妗ｇ敤浜庢寚瀵?MOM 鏅鸿兘闂暟 MVP 闃舵鐨勬暟鎹簱璁捐锛岃鐩栫郴缁熻嚜韬?MySQL 琛ㄣ€丷edis 杩愯鎬佺紦瀛樸€佸叧閿储寮曘€佸敮涓€绾︽潫銆佸畨鍏ㄥ瓨鍌ㄣ€佹暟鎹敓鍛藉懆鏈熷拰鍒濆鍖栧缓璁€?
鏈枃妗ｅ熀浜庝互涓嬮」鐩枃妗ｆ暣鐞嗭細

- 銆奙OM鏅鸿兘闂暟-MVP鏁版嵁妯″瀷鏂囨。锛堝弬鑰冿級銆?- 銆奙OM鏅鸿兘闂暟-MVP鐢ㄦ埛渚ч渶姹傝鏍兼枃妗ｃ€?- 銆奙OM鏅鸿兘闂暟-MVP绠＄悊渚ч渶姹傝鏍兼枃妗ｃ€?- 銆奒M-MOM-DataAgent-鏅鸿兘浣撳紑鍙戜笓椤规柟妗堛€?- 銆奒M-MOM-DataAgent-寮€鍙戜换鍔℃枃妗ｃ€?
鏈枃妗ｉ噸鐐硅В鍐斥€滃璞℃ā鍨嬪浣曡惤鎴愭暟鎹簱璁捐鈥濈殑闂锛屼笉鏇夸唬浜у搧闇€姹傛枃妗ｅ拰鎺ュ彛鏂囨。銆?
## 2. 璁捐杈圭晫

### 2.1 绯荤粺鑷韩搴?
绯荤粺鑷韩搴撳缓璁娇鐢?MySQL锛屼繚瀛?MOM 鏅鸿兘闂暟骞冲彴鑷韩鐨勯厤缃€佷細璇濄€佹秷鎭€佺粨鏋溿€佷换鍔＄姸鎬併€丄PI Key 鎽樿鍜屽璁℃暟鎹€?
绯荤粺鑷韩搴撳寘鍚細

- 绠＄悊渚ч厤缃暟鎹€?- 鐢ㄦ埛渚ц繍琛屾暟鎹€?- 闂暟缁撴灉鏁版嵁銆?- 闂瓟璇锋眰骞傜瓑鍙拌处銆?- 鎸囨爣鍙ｅ緞瀹氫箟涓庡彂甯冪姸鎬併€?- 璇煶璇嗗埆璁板綍棰勭暀銆?- 浠诲姟鐘舵€佷笌瀹¤鏃ュ織銆?
### 2.2 Redis 杩愯鎬佺紦瀛?
Redis 鐢ㄤ簬淇濆瓨鐭湡杩愯鎬併€佸箓绛夈€侀檺娴併€佷换鍔¤繘搴︺€侀厤缃憳瑕佺紦瀛樺拰閴存潈缂撳瓨銆俁edis 涓嶄綔涓烘牳蹇冧笟鍔′簨瀹炵殑鍞竴瀛樺偍銆?
Redis 鍙敤浜庯細

- 杩愯閰嶇疆鎽樿缂撳瓨銆?- 闂瓟鍝嶅簲鐭湡缂撳瓨銆傛寔涔呭箓绛変互 MySQL 璇锋眰鍙拌处涓哄噯銆?- 鍚屼竴浼氳瘽 active 闂瓟閿併€?- 鐢ㄦ埛/绉熸埛闄愭祦銆?- Schema 鍒濆鍖栦换鍔＄姸鎬併€?- 鐭ヨ瘑鍚戦噺鍖栦换鍔＄姸鎬併€?- API Key 閴存潈缂撳瓨銆?- 鐭湡璇煶璇嗗埆鐘舵€併€備粎浣滀负 P2 璇煶鑳藉姏棰勭暀锛屼笉杩涘叆涓€鏈熼棶绛斾富閾捐矾銆?
### 2.3 澶栭儴 MOM 涓氬姟鏁版嵁婧?
澶栭儴 MOM 涓氬姟搴撲笉鏄郴缁熻嚜韬簱鐨勪竴閮ㄥ垎銆傜郴缁熷彧淇濆瓨鏁版嵁婧愯繛鎺ラ厤缃€丼chema 鍒濆鍖栫粨鏋溿€佽〃鑼冨洿鍜岃涔夊瓧娈垫槧灏勶紝涓嶅鍒?MOM 涓氬姟鏁版嵁銆?
澶栭儴涓氬姟鏁版嵁璁块棶鍘熷垯锛?
- 閫氳繃鍙璐﹀彿璁块棶銆?- 浠呰闂撼鍏ラ棶鏁拌寖鍥寸殑琛ㄣ€?- 涓嶅厑璁告ā鍨嬬洿鎺ョ敓鎴愪换鎰?SQL 鎵ц銆?- 鏌ヨ缁撴灉闇€瑕佸彈 Skill銆佽涔夋ā鍨嬨€佹潈闄愯寖鍥村拰瀹夊叏瑙勫垯绾︽潫銆?
## 3. 鍛藉悕瑙勮寖

### 3.1 琛ㄥ懡鍚?
寤鸿缁熶竴浣跨敤 `da_` 鍓嶇紑锛岃〃绀?DataAgent 绯荤粺琛ㄣ€?
| 鍒嗙被 | 鍓嶇紑绀轰緥 | 璇存槑 |
| --- | --- | --- |
| 閰嶇疆琛?| `da_agent`銆乣da_model_config` | 绠＄悊渚ч厤缃?|
| 杩愯琛?| `da_session`銆乣da_message` | 鐢ㄦ埛渚т細璇濆拰娑堟伅 |
| 缁撴灉琛?| `da_query_result`銆乣da_table_result` | 闂暟灞曠ず缁撴灉 |
| 浠诲姟琛?| `da_schema_init_task`銆乣da_vector_task` | 寮傛浠诲姟 |
| 瀹¤琛?| `da_audit_log` | 璋冪敤瀹¤ |

### 3.2 瀛楁鍛藉悕

鏁版嵁搴撳瓧娈靛缓璁娇鐢?`snake_case`锛屼唬鐮佸眰鍙槧灏勪负 camelCase銆?
绀轰緥锛?
| 浠ｇ爜瀛楁 | 鏁版嵁搴撳瓧娈?|
| --- | --- |
| agentId | agent_id |
| createdTime | created_time |
| enabledFlag | enabled_flag |
| clientMessageId | client_message_id |

### 3.3 閫氱敤瀛楁

澶у鏁颁笟鍔¤〃寤鸿鍖呭惈浠ヤ笅瀛楁锛?
| 瀛楁 | 绫诲瀷 | 璇存槑 |
| --- | --- | --- |
| id | bigint unsigned | 鑷涓婚敭 |
| xxx_id | varchar(64) | 涓氬姟鍞竴鏍囪瘑 |
| created_time | datetime(3) | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | 杞垹闄ゆ爣璇嗭紝0 鏈垹闄わ紝1 宸插垹闄?|

閰嶇疆绫昏〃鍙澶栧寘鍚細

| 瀛楁 | 绫诲瀷 | 璇存槑 |
| --- | --- | --- |
| enabled_flag | tinyint(1) | 鏄惁鍚敤 |
| remark | varchar(512) | 澶囨敞 |

## 4. MySQL 琛ㄦ€昏

### 4.1 绠＄悊渚ч厤缃〃

| 琛ㄥ悕 | 鐢ㄩ€?| MVP 蹇呴渶 |
| --- | --- | --- |
| da_agent | 榛樿 Agent | 鏄?|
| da_model_config | LLM銆丒mbedding 妯″瀷閰嶇疆锛孉SR 棰勭暀 | 鏄?|
| da_datasource_config | MOM 涓氬姟鏁版嵁婧愰厤缃?| 鏄?|
| da_table_scope | 鏁版嵁琛ㄩ棶鏁拌寖鍥?| 鏄?|
| da_skill_config | Skill 鐧藉悕鍗曢厤缃?| 鏄?|
| da_metric_definition | 鎸囨爣鍙ｅ緞瀹氫箟涓庡彂甯冪姸鎬?| 鏄?|
| da_agent_knowledge | 鏅鸿兘浣撶煡璇嗘潯鐩?| 鏄?|
| da_business_term | 涓氬姟鐭ヨ瘑鏉＄洰 | 鏄?|
| da_semantic_field | 璇箟瀛楁鏄犲皠 | 鏄?|
| da_preset_question | 棰勮闂 | 鏄?|
| da_api_access | API 璁块棶閰嶇疆 | 鏄?|
| da_system_prompt | 绯荤粺鎻愮ず璇嶇増鏈?| 鏄?|

### 4.2 鐢ㄦ埛渚ц繍琛岃〃

| 琛ㄥ悕 | 鐢ㄩ€?| MVP 蹇呴渶 |
| --- | --- | --- |
| da_session | 鐢ㄦ埛浼氳瘽 | 鏄?|
| da_chat_request_ledger | 闂瓟璇锋眰骞傜瓑鍙拌处 | 鏄?|
| da_message | 浼氳瘽娑堟伅 | 鏄?|
| da_voice_record | 璇煶璇嗗埆璁板綍棰勭暀 | 鍚?|
| da_query_result | 闂暟缁撴灉鎽樿 | 鏄?|
| da_table_result | 琛ㄦ牸缁撴灉 | 鏄?|
| da_indicator_result | 鎸囨爣鍗＄粨鏋?| 鏄?|
| da_chart_result | 鍥捐〃缁撴灉 | 鏄?|
| da_runtime_notice | 杩愯鎻愮ず | 鏄?|

### 4.3 浠诲姟涓庡璁¤〃

| 琛ㄥ悕 | 鐢ㄩ€?| MVP 蹇呴渶 |
| --- | --- | --- |
| da_schema_init_task | Schema 鍒濆鍖栦换鍔?| 寤鸿 |
| da_vector_task | 鐭ヨ瘑鍚戦噺鍖栦换鍔?| 寤鸿 |
| da_audit_log | 闂暟璋冪敤瀹¤ | 寤鸿 |
| da_api_invoke_log | 澶栭儴 API 璋冪敤鏃ュ織 | 鍙€?|

## 5. 绠＄悊渚ч厤缃〃璁捐

### 5.1 da_agent 榛樿 Agent 琛?
鐢ㄩ€旓細淇濆瓨 MVP 闃舵鍞竴榛樿 Agent銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| agent_id | varchar(64) | UK | Agent 鏍囪瘑 |
| agent_name | varchar(128) | NOT NULL | Agent 鍚嶇О |
| agent_status | varchar(32) | NOT NULL | `ENABLED`銆乣DISABLED` |
| is_default | tinyint(1) | NOT NULL | MVP 鍥哄畾涓?1 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_agent_id(agent_id)`
- `idx_default_status(is_default, agent_status, deleted_flag)`

绾︽潫璇存槑锛?
- MVP 闃舵鍙厑璁镐竴鏉?`is_default=1 AND deleted_flag=0` 鐨勮褰曘€?
### 5.2 da_model_config 妯″瀷璧勬簮閰嶇疆琛?
鐢ㄩ€旓細淇濆瓨 LLM銆丒mbedding 妯″瀷閰嶇疆锛屽苟棰勭暀 ASR 妯″瀷鍒嗙被銆侻VP 涓€鏈熼棶绛斾富閾捐矾涓嶄緷璧?ASR銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| model_config_id | varchar(64) | UK | 妯″瀷閰嶇疆鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| config_name | varchar(128) | NOT NULL | 閰嶇疆鍚嶇О |
| model_category | varchar(32) | NOT NULL | `LLM`銆乣EMBEDDING`锛沗ASR` 涓?P2 璇煶棰勭暀 |
| provider | varchar(64) | NOT NULL | 渚涘簲鍟?|
| base_url | varchar(512) | NOT NULL | 鏈嶅姟鍦板潃 |
| api_key_cipher | text | NOT NULL | 鍔犲瘑鍚庣殑 API Key |
| api_key_masked | varchar(128) | NOT NULL | 鑴辨晱灞曠ず鍊?|
| model_name | varchar(128) | NOT NULL | 妯″瀷鍚嶇О |
| request_mode | varchar(32) | NULL | `STREAM`銆乣NON_STREAM` |
| temperature | decimal(4,3) | NULL | 娓╁害 |
| max_tokens | int | NULL | 鏈€澶ц緭鍑洪暱搴?|
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍚敤 |
| default_flag | tinyint(1) | NOT NULL DEFAULT 0 | 鏄惁褰撳墠鐢熸晥 |
| test_status | varchar(32) | NOT NULL DEFAULT 'NOT_TESTED' | 娴嬭瘯鐘舵€?|
| test_message | varchar(1024) | NULL | 娴嬭瘯缁撴灉 |
| last_test_time | datetime(3) | NULL | 鏈€杩戞祴璇曟椂闂?|
| remark | varchar(512) | NULL | 澶囨敞 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_model_config_id(model_config_id)`
- `idx_agent_category(agent_id, model_category, deleted_flag)`
- `idx_agent_category_default(agent_id, model_category, default_flag, enabled_flag, deleted_flag)`

绾︽潫璇存槑锛?
- 鍚屼竴 `agent_id + model_category` 涓嬪彧鍏佽涓€鏉?`default_flag=1 AND enabled_flag=1 AND deleted_flag=0` 鐨勭敓鏁堥厤缃€?- `api_key_cipher` 蹇呴』鍔犲瘑淇濆瓨锛屼笉鍏佽鏄庢枃钀藉簱銆?
### 5.3 da_datasource_config 鏁版嵁婧愰厤缃〃

鐢ㄩ€旓細淇濆瓨澶栭儴 MOM 涓氬姟鏁版嵁搴撹繛鎺ラ厤缃€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| datasource_id | varchar(64) | UK | 鏁版嵁婧愭爣璇?|
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| datasource_name | varchar(128) | NOT NULL | 鏁版嵁婧愬悕绉?|
| datasource_type | varchar(32) | NOT NULL | `MYSQL`銆乣DM`銆乣ORACLE`銆乣SQLSERVER`銆乣POSTGRESQL` |
| host | varchar(256) | NOT NULL | 涓绘満鍦板潃 |
| port | int | NOT NULL | 绔彛 |
| database_name | varchar(128) | NOT NULL | 鏁版嵁搴撳悕绉?|
| username | varchar(128) | NOT NULL | 鐢ㄦ埛鍚?|
| password_cipher | text | NOT NULL | 鍔犲瘑鍚庣殑瀵嗙爜 |
| password_masked | varchar(128) | NOT NULL | 鑴辨晱瀵嗙爜 |
| connection_url_cipher | text | NULL | 鍔犲瘑鍚庣殑杩炴帴涓?|
| readonly_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍙 |
| dangerous_sql_block_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鎷︽埅鍗遍櫓 SQL |
| max_return_rows | int | NOT NULL DEFAULT 1000 | 鏈€澶ц繑鍥炶鏁?|
| query_timeout_ms | int | NOT NULL DEFAULT 6000 | 鏌ヨ瓒呮椂 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍚敤 |
| active_flag | tinyint(1) | NOT NULL DEFAULT 0 | 鏄惁褰撳墠鐢熸晥鏁版嵁婧?|
| connect_status | varchar(32) | NOT NULL DEFAULT 'NOT_TESTED' | 杩炴帴娴嬭瘯鐘舵€?|
| connect_message | varchar(1024) | NULL | 杩炴帴缁撴灉璇存槑 |
| schema_init_status | varchar(32) | NOT NULL DEFAULT 'NOT_INIT' | Schema 鍒濆鍖栫姸鎬?|
| last_init_time | datetime(3) | NULL | 鏈€杩戝垵濮嬪寲鏃堕棿 |
| table_count | int | NULL | 琛ㄦ暟閲?|
| field_count | int | NULL | 瀛楁鏁伴噺 |
| remark | varchar(512) | NULL | 澶囨敞 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_datasource_id(datasource_id)`
- `idx_agent_active(agent_id, active_flag, enabled_flag, deleted_flag)`
- `idx_connect_status(connect_status, schema_init_status)`

绾︽潫璇存槑锛?
- MVP 闃舵鍚屼竴 Agent 浠呭厑璁镐竴涓?`active_flag=1 AND enabled_flag=1 AND deleted_flag=0` 鐨勬暟鎹簮杩涘叆闂暟閾捐矾銆?- 鏁版嵁婧愯处鍙峰缓璁娇鐢ㄥ彧璇昏处鍙枫€?- 瀵嗙爜鍜岃繛鎺ヤ覆蹇呴』鍔犲瘑淇濆瓨銆?
### 5.4 da_table_scope 鏁版嵁琛ㄨ寖鍥磋〃

鐢ㄩ€旓細淇濆瓨鏁版嵁婧愪笅鍝簺琛ㄨ繘鍏ラ棶鏁拌寖鍥淬€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| table_scope_id | varchar(64) | UK | 琛ㄨ寖鍥存爣璇?|
| datasource_id | varchar(64) | NOT NULL | 鎵€灞炴暟鎹簮 |
| table_name | varchar(128) | NOT NULL | 鐗╃悊琛ㄥ悕 |
| table_comment | varchar(512) | NULL | 琛ㄨ鏄?|
| field_count | int | NULL | 瀛楁鏁伴噺 |
| in_query_scope | tinyint(1) | NOT NULL DEFAULT 0 | 鏄惁绾冲叆闂暟 |
| is_core_table | tinyint(1) | NOT NULL DEFAULT 0 | 鏄惁鏍稿績琛?|
| sort_order | int | NOT NULL DEFAULT 0 | 鎺掑簭 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_datasource_table(datasource_id, table_name)`
- `idx_datasource_query_scope(datasource_id, in_query_scope, is_core_table)`

### 5.5 da_skill_config Skill 閰嶇疆琛?
鐢ㄩ€旓細淇濆瓨榛樿 Agent 鍙皟鐢?Skill 鐧藉悕鍗曘€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| skill_id | varchar(64) | UK | Skill 鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| skill_code | varchar(128) | NOT NULL | Skill 缂栫爜 |
| tool_name | varchar(128) | NOT NULL | 鍚庣鍥哄畾宸ュ叿鍚?|
| skill_name | varchar(128) | NOT NULL | Skill 鍚嶇О |
| source_type | varchar(32) | NOT NULL | `BUILT_IN`銆乣IMPORTED` |
| version | varchar(64) | NULL | 鐗堟湰 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍚敤 |
| test_status | varchar(32) | NOT NULL DEFAULT 'NOT_TESTED' | 娴嬭瘯鐘舵€?|
| description | varchar(1024) | NULL | 鎻忚堪 |
| import_time | datetime(3) | NULL | 瀵煎叆鏃堕棿 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_skill_id(skill_id)`
- `uk_agent_skill_code(agent_id, skill_code, deleted_flag)`
- `idx_agent_tool_name(agent_id, tool_name, enabled_flag, deleted_flag)`
- `idx_agent_enabled(agent_id, enabled_flag, deleted_flag)`

璇存槑锛?
- `skill_code` 鐢ㄤ簬绠＄悊渚ч厤缃睍绀哄拰鍏煎鍘嗗彶鍛藉悕銆?- `tool_name` 鏄櫤鑳戒綋瀹為檯鍙皟鐢ㄧ殑鍚庣宸ュ叿鍚嶏紝涓€鏈熷浐瀹氫负 `workOrderStatusSummary`銆乣inventoryBelowSafetyStock`銆乣equipmentDowntimeSummary` 涓変釜鍊间箣涓€銆?
### 5.5.1 da_metric_definition 鎸囨爣鍙ｅ緞瀹氫箟琛?
鐢ㄩ€旓細淇濆瓨鍙鏅鸿兘浣撴寮忚皟鐢ㄧ殑缁撴瀯鍖栨寚鏍囧彛寰勩€佺増鏈€佺敓鏁堢姸鎬佸拰榛樿鐗堟湰銆俁AG銆佺煡璇嗗簱鍜屼笟鍔℃湳璇彧璐熻矗瑙ｉ噴鏂囨湰銆佸悓涔夎瘝鍜岃儗鏅煡璇嗭紝涓嶄綔涓烘寚鏍囨槸鍚﹀彲鏌ョ殑鏉冨▉鏉ユ簮銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| metric_id | varchar(64) | UK | 鎸囨爣鍙ｅ緞鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| metric_key | varchar(128) | NOT NULL | 绋冲畾鎸囨爣缂栫爜 |
| metric_name | varchar(128) | NOT NULL | 鎸囨爣鍚嶇О |
| domain | varchar(64) | NOT NULL | 涓氬姟鍩燂紝濡傚伐鍗曘€佸簱瀛樸€佽澶?|
| version | varchar(64) | NOT NULL | 鍙ｅ緞鐗堟湰 |
| status | varchar(32) | NOT NULL | `DRAFT`銆乣PUBLISHED`銆乣DISABLED` |
| default_flag | tinyint(1) | NOT NULL DEFAULT 0 | 鏄惁榛樿鐗堟湰 |
| tool_name | varchar(128) | NOT NULL | 鍏佽璋冪敤鐨勫伐鍏峰悕 |
| calculation_rule | longtext | NOT NULL | 缁撴瀯鍖栨垨鏂囨湰鍖栬绠楄鍒?|
| effective_time | datetime(3) | NULL | 鐢熸晥鏃堕棿 |
| published_by | varchar(64) | NULL | 鍙戝竷浜?|
| published_time | datetime(3) | NULL | 鍙戝竷鏃堕棿 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_metric_id(metric_id)`
- `uk_metric_version(metric_key, version)`
- `uk_active_default_metric(active_default_key)`
- `idx_agent_status(agent_id, status, deleted_flag)`
- `idx_agent_tool(agent_id, tool_name, status, deleted_flag)`

绾︽潫璇存槑锛?
- CALL_TOOL 鍓嶅繀椤讳粠鏈〃璇诲彇鎸囨爣鍙ｅ緞锛屽苟鏍￠獙 `status='PUBLISHED'`銆?- 鍚屼竴 `metric_key` 浠呭厑璁镐竴涓?`status='PUBLISHED' AND default_flag=1 AND deleted_flag=0` 鐨勯粯璁ょ増鏈€?- 缁撴灉琛ㄥ拰瀹¤琛ㄤ腑鐨?`metric_version` 蹇呴』鏉ヨ嚜鏈〃鐨勫凡鍙戝竷鐗堟湰銆?
### 5.6 da_agent_knowledge 鏅鸿兘浣撶煡璇嗚〃

鐢ㄩ€旓細淇濆瓨鏂囨。銆侀棶绛斿銆丗AQ 绫荤煡璇嗗厓鏁版嵁鍜屽鐞嗙姸鎬併€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| knowledge_id | varchar(64) | UK | 鐭ヨ瘑鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| knowledge_type | varchar(32) | NOT NULL | `DOCUMENT`銆乣QA`銆乣FAQ` |
| knowledge_title | varchar(256) | NOT NULL | 鏍囬 |
| source_file_name | varchar(256) | NULL | 婧愭枃浠跺悕 |
| source_file_type | varchar(64) | NULL | 鏂囦欢绫诲瀷 |
| splitter_type | varchar(32) | NULL | 鍒嗗潡鏂瑰紡 |
| question | varchar(1024) | NULL | 闂 |
| answer_content | longtext | NULL | 绛旀鍐呭 |
| recall_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍙備笌鍙洖 |
| vector_status | varchar(32) | NOT NULL DEFAULT 'PENDING' | 鍚戦噺鐘舵€?|
| vector_message | varchar(1024) | NULL | 鍚戦噺澶勭悊璇存槑 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_knowledge_id(knowledge_id)`
- `idx_agent_recall(agent_id, recall_flag, vector_status, deleted_flag)`
- `idx_knowledge_type(agent_id, knowledge_type, deleted_flag)`

璇存槑锛?
- 鍚戦噺鏈綋涓嶅缓璁洿鎺ュ瓨 MySQL銆侻ySQL 淇濆瓨鍏冩暟鎹拰鐘舵€侊紝鍚戦噺鍐欏叆鍚戦噺搴撴垨妫€绱㈡湇鍔°€?
### 5.7 da_business_term 涓氬姟鐭ヨ瘑琛?
鐢ㄩ€旓細淇濆瓨涓氬姟鏈銆佹弿杩般€佸悓涔夎瘝銆佹爣绛惧拰鍙洖鐘舵€併€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| term_id | varchar(64) | UK | 鏈鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| term_name | varchar(128) | NOT NULL | 涓氬姟鍚嶈瘝 |
| description | longtext | NOT NULL | 涓氬姟鎻忚堪 |
| synonyms | varchar(1024) | NULL | 鍚屼箟璇嶏紝寤鸿 JSON 鎴栧垎闅旂 |
| tag_names | varchar(512) | NULL | 鏍囩 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍚敤 |
| recall_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍙備笌鍙洖 |
| vector_status | varchar(32) | NOT NULL DEFAULT 'PENDING' | 鍚戦噺鐘舵€?|
| vector_message | varchar(1024) | NULL | 鍚戦噺澶勭悊璇存槑 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_term_id(term_id)`
- `idx_agent_term(agent_id, term_name, deleted_flag)`
- `idx_agent_recall(agent_id, enabled_flag, recall_flag, vector_status, deleted_flag)`

### 5.8 da_semantic_field 璇箟瀛楁鏄犲皠琛?
鐢ㄩ€旓細淇濆瓨琛ㄥ瓧娈靛埌涓氬姟瀛楁鐨勭粨鏋勫寲鏄犲皠銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| semantic_id | varchar(64) | UK | 璇箟鏄犲皠鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| datasource_id | varchar(64) | NOT NULL | 鎵€灞炴暟鎹簮 |
| table_name | varchar(128) | NOT NULL | 琛ㄥ悕 |
| column_name | varchar(128) | NOT NULL | 瀛楁鍚?|
| business_name | varchar(128) | NOT NULL | 涓氬姟鍚嶇О |
| synonyms | varchar(1024) | NULL | 鍚屼箟璇?|
| business_description | text | NULL | 涓氬姟鎻忚堪 |
| column_comment | varchar(512) | NULL | 瀛楁娉ㄩ噴 |
| data_type | varchar(128) | NOT NULL | 鏁版嵁绫诲瀷 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍚敤 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_semantic_id(semantic_id)`
- `uk_datasource_table_column(datasource_id, table_name, column_name, deleted_flag)`
- `idx_agent_business_name(agent_id, business_name, enabled_flag, deleted_flag)`

### 5.9 da_preset_question 棰勮闂琛?
鐢ㄩ€旓細淇濆瓨鐢ㄦ埛渚у睍绀虹殑鎺ㄨ崘闂銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| preset_question_id | varchar(64) | UK | 棰勮闂鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| question_title | varchar(128) | NULL | 闂鏍囬 |
| question_content | varchar(1024) | NOT NULL | 闂鍐呭 |
| question_category | varchar(64) | NULL | 宸ュ崟銆佸簱瀛樸€佽澶?|
| display_scene | varchar(64) | NULL | `HOME`銆乣INPUT` |
| sort_order | int | NOT NULL DEFAULT 0 | 鎺掑簭 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍚敤 |
| home_display_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁棣栭〉灞曠ず |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 杞垹闄?|

绱㈠紩寤鸿锛?
- `uk_preset_question_id(preset_question_id)`
- `idx_agent_home(agent_id, enabled_flag, home_display_flag, sort_order, deleted_flag)`

### 5.10 da_api_access API 璁块棶閰嶇疆琛?
鐢ㄩ€旓細淇濆瓨榛樿 Agent 鐨勫閮?API 璁块棶閰嶇疆銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| api_access_id | varchar(64) | UK | API 璁块棶閰嶇疆鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| api_enabled_flag | tinyint(1) | NOT NULL DEFAULT 0 | API 鏄惁鍚敤 |
| key_status | varchar(32) | NOT NULL DEFAULT 'NOT_GENERATED' | Key 鐘舵€?|
| key_digest | varchar(256) | NULL | Key 鎽樿 |
| masked_key | varchar(128) | NULL | 鑴辨晱 Key |
| generated_time | datetime(3) | NULL | 鐢熸垚鏃堕棿 |
| reset_time | datetime(3) | NULL | 閲嶇疆鏃堕棿 |
| deleted_time | datetime(3) | NULL | 鍒犻櫎鏃堕棿 |
| invoke_url | varchar(512) | NOT NULL | 璋冪敤鍦板潃 |
| request_example | text | NULL | 璇锋眰绀轰緥 |
| response_example | text | NULL | 鍝嶅簲绀轰緥 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_api_access_id(api_access_id)`
- `uk_agent_api(agent_id)`
- `idx_key_status(api_enabled_flag, key_status)`

瀹夊叏璇存槑锛?
- 涓嶄繚瀛?API Key 鏄庢枃銆?- 瀹屾暣 Key 浠呯敓鎴愭垨閲嶇疆鏃惰繑鍥炰竴娆°€?- `key_digest` 寤鸿浣跨敤甯︾洂鍝堝笇銆?
### 5.11 da_system_prompt 绯荤粺鎻愮ず璇嶈〃

鐢ㄩ€旓細淇濆瓨鍐呯疆绯荤粺鎻愮ず璇嶇増鏈€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| prompt_version | varchar(64) | UK | 鎻愮ず璇嶇増鏈?|
| prompt_content | longtext | NOT NULL | 鎻愮ず璇嶅唴瀹?|
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 鏄惁鍚敤 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_prompt_version(prompt_version)`
- `idx_enabled(enabled_flag, updated_time)`

## 6. 鐢ㄦ埛渚ц繍琛岃〃璁捐

### 6.1 da_session 鐢ㄦ埛浼氳瘽琛?
鐢ㄩ€旓細淇濆瓨鐢ㄦ埛鍘嗗彶浼氳瘽銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| session_id | varchar(64) | UK | 浼氳瘽鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | 鎵€灞?Agent |
| session_title | varchar(256) | NOT NULL | 浼氳瘽鏍囬 |
| pinned_flag | tinyint(1) | NOT NULL DEFAULT 0 | 鏄惁缃《 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 鏄惁鍒犻櫎 |
| last_message_summary | varchar(512) | NULL | 鏈€杩戞秷鎭憳瑕?|
| message_count | int | NOT NULL DEFAULT 0 | 娑堟伅鏁伴噺 |
| last_active_time | datetime(3) | NULL | 鏈€杩戞椿璺冩椂闂?|
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_session_id(session_id)`
- `idx_agent_deleted_active(agent_id, deleted_flag, pinned_flag, last_active_time)`

璇存槑锛?
- MVP 鏈崟鐙缓璁剧敤鎴烽壌鏉冿紝浣嗗鏋滃悗缁湁鐢ㄦ埛浣撶郴锛屽簲琛ュ厖 `user_id`銆乣tenant_id` 绱㈠紩銆?
### 6.2 da_message 浼氳瘽娑堟伅琛?
鐢ㄩ€旓細淇濆瓨鐢ㄦ埛娑堟伅銆丄gent 鍥炲鍜岀郴缁熸彁绀恒€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| message_id | varchar(64) | UK | 娑堟伅鏍囪瘑 |
| session_id | varchar(64) | NOT NULL | 浼氳瘽鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | Agent 鏍囪瘑 |
| client_message_id | varchar(64) | NOT NULL | 鍓嶇骞傜瓑娑堟伅 ID锛涢棶绛斾富閾捐矾蹇呭～ |
| message_role | varchar(32) | NOT NULL | `USER`銆乣AGENT`銆乣SYSTEM` |
| input_type | varchar(32) | NOT NULL | `TEXT`銆乣VOICE`銆乣PRESET_QUESTION`銆乣SYSTEM` |
| message_content | longtext | NOT NULL | 娑堟伅鍐呭 |
| display_content | longtext | NULL | 灞曠ず鍐呭 |
| message_status | varchar(32) | NOT NULL | `PROCESSING`銆乣SUCCESS`銆乣FAILED` |
| error_code | varchar(64) | NULL | 閿欒鐮?|
| error_message | varchar(1024) | NULL | 閿欒璇存槑 |
| trace_id | varchar(64) | NULL | 璋冪敤閾炬爣璇?|
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_message_id(message_id)`
- `uk_session_client_role(session_id, client_message_id, message_role)`
- `idx_session_time(session_id, created_time)`
- `idx_trace_id(trace_id)`

骞傜瓑璇存槑锛?
- `client_message_id` 鐢ㄤ簬鐢ㄦ埛娑堟伅鍜屽搴?Agent 鍥炲鐨勫箓绛夊叧鑱斻€?- `da_message` 涓嶈兘浣滀负骞傜瓑鎵ц鐘舵€佺殑浜嬪疄鏉ユ簮锛屽彧璐熻矗淇濆瓨鏈€缁堟秷鎭€?- 鍚庣蹇呴』鍏堝啓鍏?`da_chat_request_ledger`锛屽啀杩涘叆 LLM銆丷AG 鍜屽伐鍏疯皟鐢ㄣ€?
### 6.2.1 da_chat_request_ledger 闂瓟璇锋眰骞傜瓑鍙拌处

鐢ㄩ€旓細鍦ㄨ皟鐢?LLM銆丷AG銆丮OM 宸ュ叿涔嬪墠璁板綍涓€娆＄敤鎴疯姹傜殑鎵ц鐘舵€侊紝纭繚鍚屼竴 `session_id + client_message_id` 涓嶉噸澶嶈皟鐢ㄥ伐鍏枫€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| ledger_id | varchar(64) | UK | 鍙拌处鏍囪瘑 |
| session_id | varchar(64) | NOT NULL | 浼氳瘽鏍囪瘑 |
| agent_id | varchar(64) | NOT NULL | Agent 鏍囪瘑 |
| client_message_id | varchar(64) | NOT NULL | 鍓嶇骞傜瓑娑堟伅 ID |
| trace_id | varchar(64) | NOT NULL | 璋冪敤閾炬爣璇?|
| input_mode | varchar(32) | NOT NULL | `text`銆乣preset`锛沗speech` 涓?P2 棰勭暀 |
| question_digest | varchar(256) | NOT NULL | 鐢ㄦ埛闂鎽樿鎴栧搱甯?|
| question_snapshot_ref | varchar(256) | NULL | 鍘熷闂蹇収寮曠敤锛涘師鏂囪惤搴撳墠蹇呴』纭鑴辨晱鍜岀暀瀛樼瓥鐣?|
| request_status | varchar(32) | NOT NULL | `RECEIVED`銆乣PROCESSING`銆乣SUCCEEDED`銆乣PERSIST_FAILED`銆乣FAILED` |
| last_stage | varchar(64) | NOT NULL | 鏈€杩戦樁娈碉紝濡?`RECEIVED`銆乣INTENT`銆乣CALL_TOOL`銆乣SAVE_MESSAGES` |
| tool_name | varchar(128) | NULL | 宸查€夋嫨宸ュ叿鍚?|
| tool_result_digest | varchar(256) | NULL | 宸ュ叿缁撴灉鎽樿 |
| answer_snapshot | longtext | NULL | 宸茬敓鎴愬洖绛斿揩鐓э紝閲嶈瘯鏃跺彲鐩存帴杩斿洖 |
| attempt_count | int | NOT NULL DEFAULT 0 | 灏濊瘯娆℃暟 |
| heartbeat_time | datetime(3) | NULL | 鏈€杩戝績璺虫椂闂?|
| locked_until | datetime(3) | NULL | 閿佸畾鎴鏃堕棿 |
| error_code | varchar(64) | NULL | 閿欒鐮?|
| error_message | varchar(1024) | NULL | 閿欒璇存槑 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_ledger_id(ledger_id)`
- `uk_session_client(session_id, client_message_id)`
- `idx_trace_id(trace_id)`
- `idx_status_locked(request_status, locked_until)`
- `idx_session_status(session_id, request_status, updated_time)`

鐘舵€佽鍒欙細

- 鏂拌姹傚繀椤诲厛鎻掑叆 `RECEIVED`锛屾彃鍏ュけ璐ヤ笖鍛戒腑 `uk_session_client` 鏃朵笉寰楀啀娆¤皟鐢ㄥ伐鍏枫€?- 杩涘叆宸ュ叿璋冪敤鍓嶅繀椤绘洿鏂颁负 `PROCESSING`锛屽苟鍐欏叆 `last_stage='CALL_TOOL'`銆乣heartbeat_time`銆乣locked_until`銆?- 宸ュ叿璋冪敤鍜屾秷鎭繚瀛樺潎鎴愬姛鍚庢洿鏂颁负 `SUCCEEDED`锛屽苟鍐欏叆 `answer_snapshot`銆?- 宸ュ叿宸茶皟鐢ㄤ絾娑堟伅鎴栫粨鏋滄寔涔呭寲澶辫触鏃舵洿鏂颁负 `PERSIST_FAILED`锛岄噸璇曞簲浼樺厛鏍规嵁 `answer_snapshot` 鎴?`tool_result_digest` 鎭㈠锛屼笉寰楅噸澶嶈皟鐢ㄥ伐鍏枫€?- 绯荤粺澶辫触涓旀病鏈夊彲鎭㈠缁撴灉鏃舵洿鏂颁负 `FAILED`銆?
### 6.3 da_voice_record 璇煶璇嗗埆璁板綍琛?
鐢ㄩ€旓細璁板綍璇煶杈撳叆鍜岃瘑鍒粨鏋溿€傝琛ㄤ负 P2 璇煶涓撻」棰勭暀锛屼竴鏈熶粎淇濈暀鍓嶇鍏ュ彛鐘舵€佸拰闄嶇骇鎻愮ず锛屼笉杩涘叆闂瓟涓婚摼璺€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| voice_record_id | varchar(64) | UK | 璇煶璁板綍鏍囪瘑 |
| session_id | varchar(64) | NOT NULL | 浼氳瘽鏍囪瘑 |
| message_id | varchar(64) | NOT NULL | 瀵瑰簲鐢ㄦ埛娑堟伅 |
| audio_file_ref | varchar(512) | NULL | 闊抽鏂囦欢寮曠敤 |
| recognized_text | longtext | NULL | 璇嗗埆鏂囨湰 |
| recognize_status | varchar(32) | NOT NULL | `PROCESSING`銆乣SUCCESS`銆乣FAILED` |
| confidence | decimal(5,4) | NULL | 缃俊搴?|
| duration_seconds | decimal(10,3) | NULL | 闊抽鏃堕暱 |
| error_code | varchar(64) | NULL | 閿欒鐮?|
| error_message | varchar(1024) | NULL | 澶辫触鍘熷洜 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |
| updated_time | datetime(3) | NOT NULL | 鏇存柊鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_voice_record_id(voice_record_id)`
- `idx_session_message(session_id, message_id)`
- `idx_recognize_status(recognize_status, created_time)`

### 6.4 da_query_result 闂暟缁撴灉琛?
鐢ㄩ€旓細淇濆瓨涓€娆￠棶鏁扮粨鏋滄憳瑕併€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| result_id | varchar(64) | UK | 缁撴灉鏍囪瘑 |
| session_id | varchar(64) | NOT NULL | 浼氳瘽鏍囪瘑 |
| message_id | varchar(64) | NOT NULL | 瀵瑰簲 Agent 娑堟伅 |
| result_type | varchar(32) | NOT NULL | `TEXT`銆乣TABLE`銆乣INDICATOR`銆乣CHART`銆乣CLARIFICATION`銆乣ERROR` |
| result_title | varchar(256) | NULL | 缁撴灉鏍囬 |
| result_summary | longtext | NULL | 缁撴灉鎽樿 |
| result_status | varchar(32) | NOT NULL | `PROCESSING`銆乣SUCCESS`銆乣FAILED`銆乣NO_DATA` |
| tool_name | varchar(128) | NULL | 璋冪敤宸ュ叿 |
| metric_version | varchar(64) | NULL | 鍙ｅ緞鐗堟湰 |
| trace_id | varchar(64) | NULL | 璋冪敤閾炬爣璇?|
| error_code | varchar(64) | NULL | 閿欒鐮?|
| error_message | varchar(1024) | NULL | 閿欒璇存槑 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_result_id(result_id)`
- `idx_session_message(session_id, message_id)`
- `idx_trace_id(trace_id)`
- `idx_result_status(result_status, created_time)`

鐘舵€佽鍒欙細

- `SUCCESS` 琛ㄧず鏌ヨ鎴愬姛涓斿瓨鍦ㄥ彲灞曠ず缁撴灉銆?- `NO_DATA` 琛ㄧず宸ュ叿鏌ヨ鎴愬姛浣嗘病鏈夌鍚堟潯浠剁殑鏁版嵁锛屽睘浜庝笟鍔℃垚鍔熺┖缁撴灉锛宍error_code` 蹇呴』涓虹┖锛屽巻鍙蹭細璇濆拰瀹¤鎸夊畬鎴愭€佸鐞嗐€?- `FAILED` 琛ㄧず绯荤粺銆侀厤缃€佹潈闄愩€佸伐鍏锋垨鎸佷箙鍖栧け璐ワ紝蹇呴』鍐欏叆 `error_code`銆?
### 6.5 da_table_result 琛ㄦ牸缁撴灉琛?
鐢ㄩ€旓細淇濆瓨琛ㄦ牸绫荤粨鏋溿€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| table_result_id | varchar(64) | UK | 琛ㄦ牸缁撴灉鏍囪瘑 |
| result_id | varchar(64) | NOT NULL | 鎵€灞為棶鏁扮粨鏋?|
| table_title | varchar(256) | NULL | 琛ㄦ牸鏍囬 |
| columns_json | json | NOT NULL | 琛ㄥご瀹氫箟 |
| rows_json | json | NOT NULL | 琛屾暟鎹?|
| total_count | int | NULL | 鎬昏鏁?|
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_table_result_id(table_result_id)`
- `idx_result_id(result_id)`

璇存槑锛?
- MySQL 5.7+ 鍙娇鐢?JSON 绫诲瀷銆傝嫢鏁版嵁搴撶増鏈笉鏀寔 JSON锛屽彲闄嶇骇涓?`longtext` 骞剁敱搴旂敤灞傛牎楠?JSON 鏍煎紡銆?
### 6.6 da_indicator_result 鎸囨爣鍗＄粨鏋滆〃

鐢ㄩ€旓細淇濆瓨鎸囨爣鍗＄粨鏋溿€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| indicator_result_id | varchar(64) | UK | 鎸囨爣缁撴灉鏍囪瘑 |
| result_id | varchar(64) | NOT NULL | 鎵€灞為棶鏁扮粨鏋?|
| indicator_name | varchar(128) | NOT NULL | 鎸囨爣鍚嶇О |
| indicator_value | varchar(128) | NOT NULL | 鎸囨爣鍊?|
| unit | varchar(32) | NULL | 鍗曚綅 |
| compare_value | varchar(128) | NULL | 瀵规瘮鍊?|
| trend_direction | varchar(32) | NULL | `UP`銆乣DOWN`銆乣FLAT` |
| sort_order | int | NOT NULL DEFAULT 0 | 鎺掑簭 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_indicator_result_id(indicator_result_id)`
- `idx_result_sort(result_id, sort_order)`

### 6.7 da_chart_result 鍥捐〃缁撴灉琛?
鐢ㄩ€旓細淇濆瓨鍥捐〃缁撴灉銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| chart_result_id | varchar(64) | UK | 鍥捐〃缁撴灉鏍囪瘑 |
| result_id | varchar(64) | NOT NULL | 鎵€灞為棶鏁扮粨鏋?|
| chart_type | varchar(32) | NOT NULL | `PIE`銆乣LINE`銆乣BAR` |
| chart_title | varchar(256) | NOT NULL | 鍥捐〃鏍囬 |
| dimension_name | varchar(128) | NOT NULL | 缁村害鍚嶇О |
| metric_name | varchar(128) | NOT NULL | 鎸囨爣鍚嶇О |
| unit | varchar(32) | NULL | 鍗曚綅 |
| chart_data_json | json | NOT NULL | 鍥捐〃鏁版嵁 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_chart_result_id(chart_result_id)`
- `idx_result_id(result_id)`

### 6.8 da_runtime_notice 杩愯鎻愮ず琛?
鐢ㄩ€旓細淇濆瓨鏃犳暟鎹€佹緞娓呫€侀厤缃笉鍙敤銆佽瘑鍒け璐ャ€佹湇鍔″紓甯哥瓑鎻愮ず銆?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| notice_id | varchar(64) | UK | 鎻愮ず鏍囪瘑 |
| session_id | varchar(64) | NOT NULL | 浼氳瘽鏍囪瘑 |
| message_id | varchar(64) | NULL | 瀵瑰簲娑堟伅 |
| notice_type | varchar(64) | NOT NULL | `NO_DATA`銆乣CLARIFICATION`銆乣CONFIG_UNAVAILABLE`銆乣RECOGNIZE_FAILED`銆乣SERVICE_ERROR` |
| notice_content | varchar(1024) | NOT NULL | 鎻愮ず鍐呭 |
| trace_id | varchar(64) | NULL | 璋冪敤閾炬爣璇?|
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_notice_id(notice_id)`
- `idx_session_time(session_id, created_time)`
- `idx_message_id(message_id)`

## 7. 浠诲姟涓庡璁¤〃璁捐

### 7.1 da_schema_init_task Schema 鍒濆鍖栦换鍔¤〃

鐢ㄩ€旓細璁板綍鏁版嵁婧?Schema 鍒濆鍖栦换鍔°€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| task_id | varchar(64) | UK | 浠诲姟鏍囪瘑 |
| datasource_id | varchar(64) | NOT NULL | 鏁版嵁婧愭爣璇?|
| task_status | varchar(32) | NOT NULL | `PENDING`銆乣PROCESSING`銆乣SUCCESS`銆乣FAILED` |
| table_count | int | NULL | 琛ㄦ暟閲?|
| field_count | int | NULL | 瀛楁鏁伴噺 |
| error_message | varchar(1024) | NULL | 閿欒淇℃伅 |
| started_time | datetime(3) | NULL | 寮€濮嬫椂闂?|
| finished_time | datetime(3) | NULL | 瀹屾垚鏃堕棿 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_task_id(task_id)`
- `idx_datasource_status(datasource_id, task_status, created_time)`

### 7.2 da_vector_task 鐭ヨ瘑鍚戦噺鍖栦换鍔¤〃

鐢ㄩ€旓細璁板綍鐭ヨ瘑鍚戦噺鍖栦换鍔＄姸鎬併€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| task_id | varchar(64) | UK | 浠诲姟鏍囪瘑 |
| target_type | varchar(32) | NOT NULL | `AGENT_KNOWLEDGE`銆乣BUSINESS_TERM` |
| target_id | varchar(64) | NOT NULL | 鐭ヨ瘑鎴栨湳璇爣璇?|
| task_status | varchar(32) | NOT NULL | `PENDING`銆乣PROCESSING`銆乣SUCCESS`銆乣FAILED` |
| chunk_count | int | NULL | 鍒嗗潡鏁伴噺 |
| error_message | varchar(1024) | NULL | 閿欒淇℃伅 |
| started_time | datetime(3) | NULL | 寮€濮嬫椂闂?|
| finished_time | datetime(3) | NULL | 瀹屾垚鏃堕棿 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_task_id(task_id)`
- `idx_target(target_type, target_id)`
- `idx_status_time(task_status, created_time)`

### 7.3 da_audit_log 闂暟瀹¤鏃ュ織琛?
鐢ㄩ€旓細璁板綍闂暟璋冪敤閾惧璁°€?
| 瀛楁 | 绫诲瀷 | 绾︽潫 | 璇存槑 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 鑷涓婚敭 |
| audit_id | varchar(64) | UK | 瀹¤鏍囪瘑 |
| trace_id | varchar(64) | NOT NULL | 璋冪敤閾炬爣璇?|
| session_id | varchar(64) | NULL | 浼氳瘽鏍囪瘑 |
| client_message_id | varchar(64) | NULL | 鍓嶇骞傜瓑 ID |
| question_digest | varchar(256) | NULL | 闂鎽樿鎴栧搱甯?|
| input_type | varchar(32) | NULL | 杈撳叆绫诲瀷 |
| domain | varchar(64) | NULL | 涓氬姟鍩?|
| intent | varchar(128) | NULL | 鎰忓浘 |
| tool_name | varchar(128) | NULL | 宸ュ叿 |
| metric_version | varchar(64) | NULL | 鍙ｅ緞鐗堟湰 |
| result_status | varchar(32) | NOT NULL | 缁撴灉鐘舵€?|
| error_code | varchar(64) | NULL | 閿欒鐮?|
| latency_ms | int | NULL | 鎬昏€楁椂 |
| created_time | datetime(3) | NOT NULL | 鍒涘缓鏃堕棿 |

绱㈠紩寤鸿锛?
- `uk_audit_id(audit_id)`
- `idx_trace_id(trace_id)`
- `idx_session_client(session_id, client_message_id)`
- `idx_status_time(result_status, created_time)`

瀹夊叏璇存槑锛?
- 涓嶄繚瀛樺師濮?SQL銆佸瘑閽ャ€佹暟鎹簱瀵嗙爜銆佸悗绔爢鏍堛€?- 鍘熷闂濡傞渶淇濆瓨锛屽簲鍏堝畬鎴愯劚鏁忓拰鐣欏瓨鍛ㄦ湡纭銆?
## 8. Redis 璁捐

### 8.1 Key 鍛藉悕瑙勮寖

寤鸿缁熶竴浣跨敤锛?
```text
da:{module}:{purpose}:{id}
```

绀轰緥锛?
```text
da:runtime:config:agent-mom-data
da:chat:idempotent:{sessionId}:{clientMessageId}
da:chat:lock:{sessionId}
```

### 8.2 Redis Key 娓呭崟

| Key | 绫诲瀷 | TTL | 鐢ㄩ€?|
| --- | --- | --- | --- |
| `da:runtime:config:{agentId}` | String/JSON | 5 鍒嗛挓 | 杩愯閰嶇疆鎽樿缂撳瓨 |
| `da:chat:idempotent:{sessionId}:{clientMessageId}` | String/JSON | 24 灏忔椂 | 闂瓟骞傜瓑鍝嶅簲缂撳瓨 |
| `da:chat:lock:{sessionId}` | String | 30 绉?| 鍚屼竴浼氳瘽 active 闂瓟閿?|
| `da:rate:user:{userId}` | String/Counter | 1 鍒嗛挓 | 鐢ㄦ埛绾ч檺娴?|
| `da:rate:tenant:{tenantId}` | String/Counter | 1 鍒嗛挓 | 绉熸埛绾ч檺娴?|
| `da:schema-task:{taskId}` | Hash/JSON | 24 灏忔椂 | Schema 鍒濆鍖栦换鍔¤繘搴?|
| `da:vector-task:{taskId}` | Hash/JSON | 24 灏忔椂 | 鐭ヨ瘑鍚戦噺鍖栦换鍔¤繘搴?|
| `da:api-key:{keyDigest}` | String/JSON | 10 鍒嗛挓 | API Key 閴存潈缂撳瓨 |
| `da:voice:{voiceRecordId}` | Hash/JSON | 30 鍒嗛挓 | 璇煶璇嗗埆鐭湡鐘舵€?|
| `da:agent:availability:{agentId}` | String/JSON | 1 鍒嗛挓 | Agent 鍙敤鎬у揩鐓?|

### 8.3 Redis 浣跨敤瑙勫垯

- Redis 涓紦瀛樼殑鏁版嵁蹇呴』鍙互浠?MySQL 鎴栧閮ㄦ湇鍔℃仮澶嶃€?- 骞傜瓑缂撳瓨涓嶈兘鏇夸唬 MySQL 娑堟伅鎸佷箙鍖栥€?- 浼氳瘽閿侀噴鏀惧簲浣跨敤 value 鏍￠獙锛岄伩鍏嶈鍒犲叾浠栬姹傞攣銆?- 闄愭祦 Key 杈惧埌闃堝€兼椂锛屼笉搴旂户缁皟鐢?LLM銆丷AG 鎴?MOM 宸ュ叿銆?- API Key 缂撳瓨鍙繚瀛橀壌鏉冪粨鏋滃拰蹇呰鍏冩暟鎹紝涓嶄繚瀛樺畬鏁?Key銆?
## 9. 瀹夊叏璁捐

### 9.1 鏁忔劅瀛楁

| 瀛楁 | 瀛樺偍绛栫暐 |
| --- | --- |
| 妯″瀷 API Key | 鍔犲瘑淇濆瓨锛岃劚鏁忓睍绀?|
| 鏁版嵁婧愬瘑鐮?| 鍔犲瘑淇濆瓨锛岃劚鏁忓睍绀?|
| 鏁版嵁婧愯繛鎺ヤ覆 | 濡傚寘鍚瘑鐮侊紝蹇呴』鍔犲瘑淇濆瓨 |
| 澶栭儴 API Key | 涓嶄繚瀛樻槑鏂囷紝浠呬繚瀛樻憳瑕佸拰鑴辨晱鍊?|
| 鐢ㄦ埛闂鍘熸枃 | 榛樿淇濆瓨鍦ㄦ秷鎭〃锛涘璁¤〃鍙繚瀛樻憳瑕佹垨鍝堝笇 |

### 9.2 鍔犲瘑寤鸿

- 浣跨敤搴旂敤渚?KMS 鎴栫粺涓€瀵嗛挜鏈嶅姟杩涜鍔犲瘑銆?- 鏁版嵁搴撲腑淇濆瓨瀵嗘枃鍜岃劚鏁忓睍绀哄€笺€?- 瀵嗛挜杞崲鏃堕渶鎻愪緵閲嶅姞瀵嗘満鍒躲€?- 绂佹鏃ュ織鎵撳嵃鏄庢枃瀵嗛挜銆佸瘑鐮併€佽繛鎺ヤ覆銆?
### 9.3 SQL 瀹夊叏

- 鏁版嵁婧愯处鍙峰繀椤诲彧璇汇€?- 鏌ヨ蹇呴』缁忚繃 Skill 鐧藉悕鍗曞拰璇箟妯″瀷绾︽潫銆?- 绂佹鎵ц `INSERT`銆乣UPDATE`銆乣DELETE`銆乣DROP`銆乣ALTER`銆乣TRUNCATE` 绛夊啓鎿嶄綔銆?- 鏌ヨ蹇呴』鏈夎秴鏃跺拰鏈€澶ц繑鍥炶鏁般€?- 鏌ヨ鏃ュ織涓嶅緱淇濆瓨鏁忔劅杩炴帴淇℃伅銆?
## 10. 鏁版嵁鐢熷懡鍛ㄦ湡

| 鏁版嵁 | 寤鸿淇濈暀鍛ㄦ湡 | 璇存槑 |
| --- | --- | --- |
| 绠＄悊渚ч厤缃?| 闀挎湡淇濈暀 | 杞垹闄?|
| 浼氳瘽 | 鎸変笟鍔¤姹傦紝寤鸿 6-12 涓湀 | 鏀寔杞垹闄?|
| 娑堟伅 | 璺熼殢浼氳瘽 | 澶ф枃鏈渶鎺у埗闀垮害 |
| 闂暟缁撴灉 | 璺熼殢娑堟伅 | JSON 缁撴灉闇€鎺у埗澶у皬 |
| 璇煶璇嗗埆璁板綍 | 寤鸿 30-90 澶?| 闊抽鏂囦欢鍙崟鐙缃洿鐭懆鏈?|
| 瀹¤鏃ュ織 | 寤鸿 6-12 涓湀 | 鏍规嵁浼佷笟瀹¤瑕佹眰璋冩暣 |
| Redis 骞傜瓑缂撳瓨 | 24 灏忔椂 | 闃叉鐭湡閲嶅鎻愪氦 |
| Redis 杩愯閿?| 30 绉?| 闃叉骞跺彂闂瓟 |
| 浠诲姟鐘舵€佺紦瀛?| 24 灏忔椂 | MySQL 淇濆瓨鏈€缁堢姸鎬?|

## 11. 鍒濆鍖栧缓璁?
MVP 鍒濆鍖栨椂寤鸿鍒涘缓锛?
- 1 鏉￠粯璁?Agent銆?- 1 鏉?LLM 妯″瀷閰嶇疆銆?- 1 鏉?Embedding 妯″瀷閰嶇疆銆?- 1 鏉＄敓鏁堟暟鎹簮閰嶇疆銆?- 3 鏉￠粯璁ら璁鹃棶棰橈細宸ュ崟銆佸簱瀛樸€佽澶囥€?- 3 涓粯璁?Skill锛氬伐鍗曠姸鎬佺粺璁°€佷綆瀹夊叏搴撳瓨鏌ヨ銆佽澶囧仠鏈虹粺璁°€?- 3 鏉￠粯璁ゆ寚鏍囧彛寰勶細宸ュ崟鐘舵€佺粺璁°€佷綆瀹夊叏搴撳瓨銆佽澶囧仠鏈烘椂闀裤€?- 1 鏉＄郴缁熸彁绀鸿瘝鐗堟湰銆?
榛樿棰勮闂锛?
| 鍒嗙被 | 闂 |
| --- | --- |
| 宸ュ崟 | 鎸夊伐鍗曠姸鎬佺粺璁″綋鍓嶅伐鍗曟暟閲?|
| 搴撳瓨 | 鏌ヨ浣庝簬瀹夊叏搴撳瓨鐨勭墿鏂?|
| 璁惧 | 鍒嗘瀽璁惧鍋滄満鏃堕暱 |

## 12. 涓嬩竴闃舵鏁版嵁搴撳紑鍙戝垵绋?
鏈妭鐢ㄤ簬鎶婃暟鎹簱璁捐杞垚鍙墽琛屽紑鍙戜换鍔°€傚缓璁笅涓€闃舵鍏堝仛鈥滆兘鏀拺闂暟涓婚摼璺€濈殑鏈€灏忛棴鐜紝鍐嶈ˉ绠＄悊閰嶇疆銆佸紓姝ヤ换鍔″拰娌荤悊鑳藉姏銆?
### 12.1 寮€鍙戠洰鏍?
涓嬩竴闃舵鏁版嵁搴撳紑鍙戣杈炬垚浠ヤ笅鐩爣锛?
- MySQL 鑳戒繚瀛橀粯璁?Agent銆佹ā鍨嬮厤缃€佹暟鎹簮閰嶇疆銆丼kill銆佹寚鏍囧彛寰勩€侀璁鹃棶棰樸€佷細璇濄€佽姹傚彴璐︺€佹秷鎭拰闂暟缁撴灉銆?- Redis 鑳芥敮鎾戦棶绛斿搷搴旂煭鏈熺紦瀛樸€佷細璇濆苟鍙戦攣銆佽繍琛岄厤缃紦瀛樸€佷换鍔＄姸鎬佺紦瀛樺拰 API Key 閴存潈缂撳瓨銆?- 鍚庣鎺ュ彛鍙互鍩轰簬鏁版嵁搴撹〃鏇挎崲褰撳墠鍓嶇 mock 鏁版嵁銆?- 鏁忔劅瀛楁涓嶆槑鏂囪惤搴擄紝API Key 鍙繚瀛樻憳瑕併€?- 闂瓟閾捐矾鍙互閫氳繃 `trace_id` 涓茶捣娑堟伅銆佺粨鏋滃拰瀹¤鏃ュ織銆?
### 12.2 鎺ㄨ崘寮€鍙戦『搴?
| 闃舵 | 浠诲姟 | 杈撳嚭鐗?| 楠屾敹鏂瑰紡 |
| --- | --- | --- | --- |
| 1 | 寤虹珛 MySQL 鍩虹宸ョ▼ | 寤哄簱鑴氭湰銆佽縼绉荤洰褰曘€佸熀纭€杩炴帴閰嶇疆 | 鏈湴鑳藉惎鍔ㄥ苟杩炴帴鏁版嵁搴?|
| 2 | 鍒涘缓绠＄悊渚ф牳蹇冭〃 | `da_agent`銆乣da_model_config`銆乣da_datasource_config`銆乣da_skill_config`銆乣da_metric_definition`銆乣da_preset_question` | 鑳藉垵濮嬪寲榛樿 Agent銆佹ā鍨嬨€佹暟鎹簮銆丼kill銆佹寚鏍囧彛寰勫拰棰勮闂 |
| 3 | 鍒涘缓闂暟杩愯琛?| `da_session`銆乣da_chat_request_ledger`銆乣da_message`銆乣da_query_result`銆乣da_table_result`銆乣da_indicator_result`銆乣da_chart_result`銆乣da_runtime_notice` | 涓€娆℃枃鏈棶绛旇兘鍏堝啓璇锋眰鍙拌处锛屽啀瀹屾暣钀藉簱 |
| 4 | 鎺ュ叆 Redis 鍩虹鑳藉姏 | 鍝嶅簲缂撳瓨 Key銆佷細璇濋攣銆侀厤缃紦瀛樸€佷换鍔＄姸鎬佺紦瀛?| 閲嶅璇锋眰浼樺厛鍛戒腑 MySQL 鍙拌处锛屽苟鍙敤 Redis 鍔犻€熻繑鍥?|
| 5 | 琛ラ綈浠诲姟鍜岄鐣欒〃 | `da_schema_init_task`銆乣da_vector_task`銆乣da_voice_record` | 寮傛浠诲姟鏈夌姸鎬佽褰曪紝璇煶琛ㄤ粎浣?P2 棰勭暀 |
| 6 | 琛ュ璁′笌瀹夊叏 | `da_audit_log`銆佹晱鎰熷瓧娈靛姞瀵嗐€丼QL 瀹夊叏鎷︽埅鏃ュ織 | 鑳芥寜 `trace_id` 杩借釜涓€娆￠棶鏁拌皟鐢?|

### 12.3 MySQL 寮€鍙戜紭鍏堢骇

P0 蹇呴』浼樺厛瀹屾垚锛?
- `da_agent`
- `da_model_config`
- `da_datasource_config`
- `da_skill_config`
- `da_metric_definition`
- `da_preset_question`
- `da_session`
- `da_chat_request_ledger`
- `da_message`
- `da_query_result`

P1 璺熼殢涓婚摼璺ˉ榻愶細

- `da_table_result`
- `da_indicator_result`
- `da_chart_result`
- `da_runtime_notice`
- `da_audit_log`

P2 鍙湪绠＄悊渚у畬鍠勬椂琛ラ綈锛?
- `da_table_scope`
- `da_agent_knowledge`
- `da_business_term`
- `da_semantic_field`
- `da_system_prompt`
- `da_schema_init_task`
- `da_vector_task`
- `da_voice_record`

### 12.4 Redis 寮€鍙戜紭鍏堢骇

P0 蹇呴』浼樺厛瀹屾垚锛?
| Key | 鐢ㄩ€?| 寤鸿 TTL |
| --- | --- | --- |
| `da:chat:idempotent:{sessionId}:{clientMessageId}` | 闂瓟鍝嶅簲鐭湡缂撳瓨锛涗笉鑳芥浛浠?MySQL 鍙拌处 | 24 灏忔椂 |
| `da:chat:lock:{sessionId}` | 鍚屼竴浼氳瘽骞跺彂閿?| 30 绉?|
| `da:runtime:config:{agentId}` | 杩愯閰嶇疆缂撳瓨 | 5-10 鍒嗛挓 |

P1 璺熼殢鎺ュ彛琛ラ綈锛?
| Key | 鐢ㄩ€?| 寤鸿 TTL |
| --- | --- | --- |
| `da:schema-task:{taskId}` | Schema 鍒濆鍖栦换鍔＄姸鎬?| 24 灏忔椂 |
| `da:vector-task:{taskId}` | 鐭ヨ瘑鍚戦噺鍖栦换鍔＄姸鎬?| 24 灏忔椂 |
| `da:api-key:{keyDigest}` | API Key 閴存潈缂撳瓨 | 5-30 鍒嗛挓 |
| `da:voice:{voiceRecordId}` | 璇煶璇嗗埆鐭湡鐘舵€侊紝P2 棰勭暀 | 30 鍒嗛挓 |

### 12.5 鍏抽敭寮€鍙戠害鏉?
- MySQL 鏄簨瀹炴潵婧愶紝Redis 鍙仛缂撳瓨銆侀攣鍜岀煭鏈熺姸鎬併€?- 闂瓟骞傜瓑浠?`da_chat_request_ledger` 涓轰簨瀹炴潵婧愶紱Redis 骞傜瓑 Key 鍙兘鍋氬搷搴旂紦瀛樺拰鎬ц兘浼樺寲銆?- 鎸囨爣鍙煡鎬т互 `da_metric_definition.status='PUBLISHED'` 涓轰簨瀹炴潵婧愶紱RAG 鍛戒腑涓嶈兘鍐冲畾鍙ｅ緞鍙戝竷鐘舵€併€?- 涓氬姟鏁版嵁搴撳彧鍏佽鍙璁块棶锛岀郴缁熷簱涓嶄繚瀛樺閮?MOM 涓氬姟鏄庣粏鏁版嵁銆?- MVP 闃舵鍙繚鐣欓粯璁?Agent锛屼絾琛ㄧ粨鏋勪繚鐣?`agent_id`锛岄伩鍏嶅悗缁 Agent 鏀硅〃銆?- 鏆備笉寮哄埗鏁版嵁搴撳閿紝浼樺厛鐢ㄥ敮涓€绱㈠紩銆佹櫘閫氱储寮曞拰搴旂敤灞傛牎楠岄檷浣庢棭鏈熻仈璋冩垚鏈€?- 鍏堥鐣?`user_id`銆乣tenant_id` 鐨勫瓧娈典綅缃紝浣?MVP 涓嶅缓璁惧畬鏁寸敤鎴锋潈闄愪綋绯汇€?- JSON 瀛楁蹇呴』鐢卞簲鐢ㄥ眰鍋氱粨鏋勬牎楠岋紝涓嶈兘鎶婁换鎰忓ぇ瀵硅薄鏃犵害鏉熷啓鍏ユ暟鎹簱銆?- 鎵€鏈夐棶绛旇姹傚繀椤荤敓鎴?`trace_id`锛屾墍鏈夊彲杩借釜琛ㄤ紭鍏堝啓鍏ヨ瀛楁銆?- 涓€鏈?`input_mode` 鍙厑璁告枃鏈拰棰勮闂杩涘叆闂瓟涓婚摼璺紱璇煶杈撳叆蹇呴』璧伴檷绾ф彁绀烘垨鍚庣画 P2 涓撻」銆?
### 12.6 闇€瑕?AI 鍗忓悓鐢熸垚鐨勪氦浠樼墿

涓嬩竴姝ュ彲浠ヨ鎴戠户缁崗鍚岀敓鎴愪互涓嬪唴瀹癸細

| 浜や粯鐗?| 鐢ㄩ€?| 寤鸿浼樺厛绾?|
| --- | --- | --- |
| MySQL DDL 鑴氭湰 | 鐩存帴鍒涘缓绯荤粺搴撹〃缁撴瀯 | P0 |
| 鍒濆鍖栨暟鎹剼鏈?| 鍐欏叆榛樿 Agent銆佹ā鍨嬨€丼kill銆佹寚鏍囧彛寰勩€侀璁鹃棶棰?| P0 |
| Redis Key 浣跨敤瑙勮寖 | 缁熶竴鍚庣缂撳瓨鍜岄攣瀹炵幇 | P0 |
| ER 鍥?| 甯姪鐞嗚В琛ㄥ叧绯?| P1 |
| 鏋氫妇瀛楀吀 | 缁熶竴鐘舵€佸€硷紝鍑忓皯鍓嶅悗绔笉涓€鑷?| P1 |
| 鏁版嵁搴撳紑鍙戜换鍔℃媶瑙?| 缁欏垵绾у紑鍙戣€呮寜澶╂墽琛?| P1 |
| 褰掓。娓呯悊鑴氭湰鏂规 | 鎺у埗娑堟伅銆佺粨鏋溿€佽闊宠褰曚綋閲?| P2 |

### 12.7 鏆傜紦浜嬮」

浠ヤ笅鍐呭涓嶅缓璁湪涓嬩竴闃舵涓€寮€濮嬪氨鍋氾紝閬垮厤鑼冨洿杩囧ぇ锛?
- 澶氱鎴峰畬鏁存潈闄愭ā鍨嬨€?- 澶?Agent 甯傚満鍖栫鐞嗐€?- 澶嶆潅鏁版嵁琛€缂樺垎鏋愩€?- 鍚戦噺搴撴渶缁堥€夊瀷鍚庣殑鐗╃悊绱㈠紩缁嗚妭銆?- 澶ц妯″璁″垎鏋愭姤琛ㄣ€?- 璺ㄦ暟鎹簮鑱旈偊鏌ヨ浼樺寲銆?
## 13. 缁撹

MVP 闃舵寤鸿閲囩敤 MySQL 淇濆瓨绯荤粺鏍稿績閰嶇疆銆佹寚鏍囧彛寰勩€佸箓绛夊彴璐﹀拰杩愯鏁版嵁锛孯edis 鍙繚瀛樼煭鏈熻繍琛屾€佸拰鎬ц兘浼樺寲鏁版嵁銆傛暟鎹簱璁捐搴斾紭鍏堜繚璇侀粯璁?Agent 闂幆銆侀厤缃敓鏁堛€佹暟鎹簮瀹夊叏銆佽姹傚箓绛夈€佷細璇濈暀鐥曘€佺粨鏋勫寲缁撴灉灞曠ず鍜屽閮?API 璁块棶鑳藉姏銆?
璇ヨ璁′繚鐣欏悗缁墿灞曞 Agent銆佸绉熸埛銆佸畬鏁存潈闄愩€佸悜閲忓簱銆佸璁″垎鏋愬拰璋冪敤缁熻鐨勭┖闂达紝浣嗕笉鍦?MVP 闃舵杩囧害瀹炵幇銆?
