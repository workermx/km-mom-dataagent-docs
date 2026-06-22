# MOM鏅鸿兘闂暟-MVP鏁版嵁搴撹惤鍦版牎楠屾竻鍗?
## 1. 浣跨敤鍓嶇‘璁?
鍦ㄦ墽琛?DDL 鍓嶅厛纭锛?
- 鐩爣鏁版嵁搴撶増鏈槸 MySQL 5.7+ 鎴?MySQL 8.0+銆?- 瀛楃闆嗕娇鐢?`utf8mb4`锛屾帓搴忚鍒欎娇鐢?`utf8mb4_unicode_ci`銆?- 琛ㄦ牸鍜屽浘琛?JSON 鏁版嵁浠?`LONGTEXT` 淇濆瓨锛岀敱搴旂敤灞傛牎楠?JSON 鏍煎紡銆?- 鏈樁娈典笉寮哄埗鏁版嵁搴撳閿紝瀛樺湪鎬у拰鐘舵€佺敱 Service 灞傛牎楠屻€?- 鍒濆鍖栬剼鏈彧鐢ㄤ簬鏈湴寮€鍙戝拰棣栨寮曞锛屼笉淇濆瓨鐪熷疄瀵嗛挜銆?
## 2. DDL 鎵ц楠屾敹

鎵ц椤哄簭锛?
1. 鎵ц `03-development/database/001_mvp_schema.sql`銆?2. 鎵ц `03-development/database/002_mvp_seed_data.sql` 涓ゆ锛岄獙璇?seed 骞傜瓑鎬с€?3. 鎵ц `03-development/database/003_mvp_verify.sql`銆?4. 鏌ヨ鏍稿績琛ㄦ槸鍚﹀垱寤烘垚鍔熴€?5. 鏌ヨ榛樿 Agent銆佹ā鍨嬨€佹暟鎹簮銆丼kill銆侀璁鹃棶棰樻槸鍚﹀啓鍏ユ垚鍔熴€?
Windows PowerShell 鍙娇鐢ㄥ寘瑁呰剼鏈細

```powershell
.\03-development\database\run-mysql-verification.ps1 -HostName 127.0.0.1 -Port 3306 -User root
```

鑴氭湰榛樿浼氫氦浜掑紡鎻愮ず杈撳叆鏁版嵁搴撳瘑鐮侊紝閬垮厤鎶婂瘑鐮佸啓鍏ュ懡浠ゅ巻鍙层€傛湰鍦?Docker 楠岃瘉搴撲篃鍙互鏄惧紡浼犲叆寮€鍙戝瘑鐮侊細

```powershell
.\03-development\database\run-mysql-verification.ps1 -HostName 127.0.0.1 -Port 3306 -User root -Password root123456
```

濡傛灉鏈満娌℃湁 `mysql` 瀹㈡埛绔紝鍙娇鐢ㄥ鍣ㄥ唴 MySQL 瀹㈡埛绔細

```powershell
.\03-development\database\run-mysql-verification-in-docker.ps1
```

濡傛湰鏈烘病鏈?MySQL锛屽彲鍏堢敤 Docker 鍚姩鏈湴楠岃瘉搴擄細

```powershell
docker compose -f .\03-development\database\docker-compose.mysql.yml up -d
```

璇?Compose 鏂囦欢鍙敤浜庢湰鍦板紑鍙戦獙璇侊紝榛樿 root 瀵嗙爜涓?`root123456`锛屼笉寰楃敤浜庢祴璇曘€侀鐢熶骇鎴栫敓浜х幆澧冦€?
濡傛灉鏈満 Docker daemon 涓嶅彲鐢紝鍙互鍦?CI 涓墽琛?`.github/workflows/database-verify.yml`銆傝 workflow 浼氬惎鍔?MySQL 8.0 鏈嶅姟瀹瑰櫒锛屽苟渚濇鎵ц schema銆乻eed銆乿erify 涓変唤 SQL銆?
濡傛灉 seed 宸茬敱绠＄悊鎺ュ彛鍐欏叆锛屽彲璺宠繃 seed锛?
```powershell
.\03-development\database\run-mysql-verification.ps1 -HostName 127.0.0.1 -Port 3306 -User root -SkipSeed
```

楠屾敹鏈熸湜锛?
- `da_table_count` 绛変簬 22銆?- 蹇呴渶琛ㄦ鏌ョ粨鏋滃潎涓?`OK`銆?- `LLM`銆乣EMBEDDING`銆乣ASR` 鍚勬湁 1 鏉″惎鐢ㄩ粯璁ゆā鍨嬨€?- 榛樿鏁版嵁婧?`readonly_flag=1`銆乣active_flag=1`銆乣enabled_flag=1`銆?- 榛樿 Agent 涓哄惎鐢ㄧ姸鎬併€?- 3 涓唴缃?Skill 鍧囧惎鐢ㄣ€?- 3 涓椤甸璁鹃棶棰樺潎鍚敤銆?- API 璁块棶閰嶇疆瀛樺湪涓?Key 鐘舵€佷负 `NOT_GENERATED`銆?- 绯荤粺鎻愮ず璇?`v1.0` 瀛樺湪涓斿惎鐢ㄣ€?- 瀛樺湪 `uk_active_default_model`銆乣uk_active_datasource`銆乣uk_session_client_role`銆?- `da_message.client_message_id` 涓?`NO` nullable銆?- 缁撴灉 JSON 瀛楁鏁版嵁绫诲瀷涓?`longtext`銆?- `003_mvp_verify.sql` 鏈€鍚庤緭鍑?`MVP database verification passed.`銆?
濡傛灉鍏抽敭琛ㄣ€佺储寮曘€佸垵濮嬪寲鏁版嵁鎴栧瓧娈电被鍨嬩笉婊¤冻瑕佹眰锛宍003_mvp_verify.sql` 浼氶€氳繃 `SIGNAL SQLSTATE '45000'` 璁?MySQL 鍛戒护澶辫触閫€鍑恒€?
榛樿楠岃瘉鑴氭湰鍜?CI workflow 閮戒細閲嶅鎵ц seed 涓ゆ锛岀敤浜庢毚闇插垵濮嬪寲鑴氭湰涓嶅彲閲嶅鎵ц鐨勯棶棰樸€?
寤鸿妫€鏌?SQL锛?
```sql
SHOW TABLES LIKE 'da_%';

SELECT agent_id, agent_name, agent_status
FROM da_agent
WHERE deleted_flag = 0;

SELECT model_category, COUNT(*) AS cnt
FROM da_model_config
WHERE enabled_flag = 1 AND default_flag = 1 AND deleted_flag = 0
GROUP BY model_category;

SELECT datasource_id, active_flag, enabled_flag
FROM da_datasource_config
WHERE deleted_flag = 0;
```

## 3. Service 灞傚繀椤绘牎楠?
### 3.1 閰嶇疆绫?
- 榛樿 Agent 蹇呴』瀛樺湪涓?`agent_status='ENABLED'`銆?- 鍚屼竴 Agent銆佸悓涓€妯″瀷绫诲埆鍙兘鏈変竴涓惎鐢ㄧ殑榛樿妯″瀷銆?- 鍚屼竴 Agent 鍙兘鏈変竴涓惎鐢ㄧ殑 active 鏁版嵁婧愩€?- 鏁版嵁婧愬繀椤绘槸鍙璐﹀彿锛屼笖 `readonly_flag=1`銆?- Skill 蹇呴』鍚敤鍚庢墠鍏佽杩涘叆闂暟閾捐矾銆?- 绠＄悊閰嶇疆鍙戝竷鍚庡繀椤诲垹闄?`da:runtime:config:{agentId}`銆?
### 3.2 闂瓟閾捐矾

- 鍓嶇蹇呴』浼?`sessionId` 鍜?`clientMessageId`銆?- 鍚庣蹇呴』涓烘瘡娆￠棶绛旂敓鎴?`trace_id`銆?- 鍚庣璋冪敤 LLM銆丷AG銆丼kill 鍓嶅繀椤诲厛鍋?Redis + MySQL 鍙屽眰骞傜瓑妫€鏌ャ€?- 鐢ㄦ埛娑堟伅鍜?Agent 鍥炲蹇呴』鍐欏叆鐩稿悓鐨?`client_message_id`銆?- 鍚屼竴浼氳瘽骞跺彂闂瓟蹇呴』閫氳繃 `da:chat:lock:{sessionId}` 鎷︽埅銆?- `NO_DATA` 鏄垚鍔熺┖缁撴灉锛屼笉搴旀寜绯荤粺閿欒澶勭悊銆?
### 3.3 缁撴灉鏁版嵁

- 鍐欏叆 `columns_json`銆乣rows_json`銆乣chart_data_json` 鍓嶅繀椤绘牎楠屼负鍚堟硶 JSON銆?- 澶х粨鏋滈泦蹇呴』鍙?`max_return_rows` 鎺у埗銆?- `metric_version` 鍦ㄩ獙鏀跺拰鍑嗙敓浜у墠搴斾娇鐢?`v1.0`銆?- 琛ㄦ牸銆佹寚鏍囧崱銆佸浘琛ㄦ槑缁嗗繀椤昏兘閫氳繃 `result_id` 鎵惧洖銆?
### 3.4 瀹夊叏

- `api_key_cipher`銆乣password_cipher` 蹇呴』鐢卞簲鐢ㄤ晶鍔犲瘑鍚庡啓鍏ャ€?- 鏃ュ織涓嶅緱鎵撳嵃妯″瀷 API Key銆佹暟鎹簮瀵嗙爜銆佸畬鏁磋繛鎺ヤ覆銆?- 澶栭儴 API Key 鍙繚瀛樻憳瑕侊紝涓嶄繚瀛樻槑鏂囥€?- 瀹¤鏃ュ織榛樿淇濆瓨闂鎽樿鎴栧搱甯岋紝涓嶄繚瀛樻晱鎰熷師鏂囥€?- SQL 鎵ц鍓嶅繀椤绘嫤鎴啓鎿嶄綔鍏抽敭瀛楋紝鍖呮嫭 `INSERT`銆乣UPDATE`銆乣DELETE`銆乣DROP`銆乣ALTER`銆乣TRUNCATE`銆?
## 4. Redis 楠屾敹

- 閲嶅鎻愪氦鍚屼竴 `sessionId + clientMessageId` 涓嶄細閲嶅鍒涘缓娑堟伅銆?- Redis 骞傜瓑缂撳瓨涓㈠け鏃讹紝MySQL 骞傜瓑鏌ヨ浠嶈兘鎷︽埅閲嶅璇锋眰銆?- 浼氳瘽閿侀噴鏀惧繀椤讳娇鐢?Lua 鏍￠獙 value銆?- 闀胯€楁椂璇锋眰闇€瑕侀攣缁湡锛岀画鏈熷け璐ュ簲鍋滄涓嬫父璋冪敤銆?- Redis 浠诲姟鐘舵€佽繃鏈熷悗锛屼粛鍙粠 MySQL 鏌ヨ鏈€缁堜换鍔＄姸鎬併€?
## 5. 鏆備笉鍋氫絾闇€璁板綍

- 澶氱鎴峰畬鏁存潈闄愭ā鍨嬨€?- 澶?Agent 绠＄悊銆?- 鏁版嵁搴撳閿己绾︽潫銆?- 鍚戦噺搴撶墿鐞嗙储寮曠粨鏋勩€?- 瀹¤鍒嗘瀽鎶ヨ〃銆?
