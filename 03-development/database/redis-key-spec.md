# MOM鏅鸿兘闂暟-MVP Redis Key 浣跨敤瑙勮寖

## 1. 瀹氫綅

Redis 鍙敤浜庣煭鏈熻繍琛屾€併€佺紦瀛樸€侀攣銆佸箓绛夈€侀檺娴佸拰浠诲姟杩涘害锛屼笉浣滀负浜嬪疄鏉ユ簮銆傛墍鏈夊叧閿暟鎹繀椤昏兘浠?MySQL 鎴栧閮ㄦ湇鍔℃仮澶嶃€?
## 2. Key 鍛藉悕

缁熶竴鏍煎紡锛?
```text
da:{module}:{purpose}:{id}
```

绀轰緥锛?
```text
da:runtime:config:agent-mom-data
da:chat:idempotent:session_xxx:client_msg_xxx
da:chat:lock:session_xxx
```

## 3. P0 Key

| Key | 绫诲瀷 | TTL | 鍐欏叆鏃舵満 | 璇诲彇鏃舵満 | 璇存槑 |
| --- | --- | --- | --- | --- | --- |
| `da:runtime:config:{agentId}` | String JSON | 5-10 鍒嗛挓 | 绠＄悊閰嶇疆鍙戝竷鍚庛€侀娆¤鍙栧悗 | 闂瓟鍓嶅姞杞借繍琛岄厤缃?| 缂撳瓨榛樿 Agent銆佹ā鍨嬨€佹暟鎹簮銆丼kill銆侀璁鹃棶棰樻憳瑕?|
| `da:chat:idempotent:{sessionId}:{clientMessageId}` | String JSON | 24 灏忔椂 | 闂瓟鎴愬姛鎴栧け璐ヨ惤搴撳悗 | 鏀跺埌鍚屼竴 `clientMessageId` 鏃?| 闃叉鍓嶇閲嶈瘯瀵艰嚧閲嶅璋冪敤 |
| `da:chat:lock:{sessionId}` | String | 90 绉?| 寮€濮嬪鐞嗛棶绛斿墠 | 澶勭悊闂瓟鍓?| 闃叉鍚屼竴浼氳瘽骞跺彂闂瓟锛岄暱鑰楁椂璇锋眰闇€瑕佺画鏈?|

## 4. P1 Key

| Key | 绫诲瀷 | TTL | 鍐欏叆鏃舵満 | 璇诲彇鏃舵満 | 璇存槑 |
| --- | --- | --- | --- | --- | --- |
| `da:schema-task:{taskId}` | Hash 鎴?String JSON | 24 灏忔椂 | Schema 鍒濆鍖栦换鍔＄姸鎬佸彉鍖栨椂 | 鍓嶇杞浠诲姟杩涘害 | MySQL `da_schema_init_task` 淇濆瓨鏈€缁堢姸鎬?|
| `da:vector-task:{taskId}` | Hash 鎴?String JSON | 24 灏忔椂 | 鐭ヨ瘑鍚戦噺鍖栦换鍔＄姸鎬佸彉鍖栨椂 | 鍓嶇杞浠诲姟杩涘害 | MySQL `da_vector_task` 淇濆瓨鏈€缁堢姸鎬?|
| `da:api-key:{keyDigest}` | String JSON | 5-30 鍒嗛挓 | API Key 鏍￠獙鎴愬姛鍚?| 澶栭儴 API 閴存潈鏃?| 涓嶄繚瀛樺畬鏁?API Key |
| `da:voice:{voiceRecordId}` | Hash 鎴?String JSON | 30 鍒嗛挓 | ASR 鐘舵€佸彉鍖栨椂 | 鍓嶇鏌ヨ璇煶璇嗗埆鐘舵€?| MySQL `da_voice_record` 淇濆瓨鏈€缁堢姸鎬?|

## 5. Value 寤鸿

### 5.1 杩愯閰嶇疆缂撳瓨

```json
{
  "agentId": "agent-mom-data",
  "configVersion": "2026-06-22T09:00:00.000+08:00",
  "llmModelConfigId": "model-llm-default",
  "embeddingModelConfigId": "model-embedding-default",
  "asrModelConfigId": "model-asr-default",
  "datasourceId": "ds-mom-default",
  "enabledSkillCodes": ["WORK_ORDER_STATUS_STAT", "LOW_STOCK_QUERY", "EQUIPMENT_DOWNTIME_STAT"],
  "maxReturnRows": 1000,
  "queryTimeoutMs": 6000
}
```

### 5.2 闂瓟骞傜瓑缂撳瓨

```json
{
  "sessionId": "session_xxx",
  "clientMessageId": "client_msg_xxx",
  "traceId": "trace_xxx",
  "userMessageId": "msg_user_xxx",
  "agentMessageId": "msg_agent_xxx",
  "resultId": "result_xxx",
  "status": "SUCCESS",
  "createdTime": "2026-06-22T09:00:00.000+08:00"
}
```

### 5.3 浼氳瘽閿?
閿?value 蹇呴』鏄湰娆¤姹傜敓鎴愮殑闅忔満 token锛?
```text
trace_xxx:random_token_xxx
```

閲婃斁閿佹椂蹇呴』鏍￠獙 value 涓€鑷达紝閬垮厤璇垹鍏朵粬璇锋眰鎸佹湁鐨勯攣銆?
### 5.4 浠诲姟鐘舵€佺紦瀛?
```json
{
  "taskId": "task_xxx",
  "taskStatus": "PROCESSING",
  "progress": 60,
  "message": "姝ｅ湪瑙ｆ瀽鏁版嵁琛ㄥ瓧娈?,
  "updatedTime": "2026-06-22T09:00:00.000+08:00"
}
```

## 6. 骞傜瓑澶勭悊娴佺▼

1. 鍚庣鏀跺埌 `sessionId + clientMessageId`锛屼袱鑰呭湪闂瓟涓婚摼璺腑閮藉繀椤诲瓨鍦ㄣ€?2. 鍏堣鍙?`da:chat:idempotent:{sessionId}:{clientMessageId}`銆?3. 濡傛灉 Redis 鍛戒腑锛岃繑鍥炵紦瀛樹腑鐨勬秷鎭拰缁撴灉鏍囪瘑锛屽啀鎸夐渶浠?MySQL 鏌ヨ瀹屾暣鍝嶅簲銆?4. 濡傛灉 Redis 鏈懡涓紝鏌ヨ MySQL 涓槸鍚﹀凡鏈夊悓涓€ `session_id + client_message_id` 鐨勭敤鎴锋秷鎭拰 Agent 鍥炲銆?5. 濡傛灉 MySQL 宸插瓨鍦ㄥ畬鏁寸粨鏋滐紝閲嶅缓 Redis 骞傜瓑缂撳瓨骞惰繑鍥烇紝閬垮厤 Redis 鍐欏け璐ュ悗閲嶈瘯閲嶅璋冪敤妯″瀷銆?6. 濡傛灉 Redis 鍜?MySQL 閮芥湭鍛戒腑锛屽皾璇曡幏鍙?`da:chat:lock:{sessionId}`銆?7. 鑾峰彇閿佸け璐ユ椂锛岃繑鍥炩€滃綋鍓嶄細璇濇鍦ㄥ鐞嗕腑鈥濓紝涓嶈皟鐢?LLM銆丷AG 鎴?MOM 鏌ヨ宸ュ叿銆?8. 鑾峰彇閿佹垚鍔熷悗鎵ц闂暟閾捐矾锛屽苟鍐欏叆 MySQL銆?9. MySQL 鍐欏叆鎴愬姛鍚庯紝鍐嶅啓鍏ュ箓绛夌紦瀛樸€?10. 璇锋眰缁撴潫鏃剁敤 value 鏍￠獙閲婃斁浼氳瘽閿併€?
## 7. 閿佸疄鐜拌姹?
鍔犻攣寤鸿锛?
```text
SET da:chat:lock:{sessionId} {lockValue} NX PX 90000
```

閲婃斁閿佸繀椤讳娇鐢?Lua 鏍￠獙锛?
```lua
if redis.call("get", KEYS[1]) == ARGV[1] then
  return redis.call("del", KEYS[1])
else
  return 0
end
```

闀胯€楁椂璇锋眰搴旀敮鎸侀攣缁湡銆傜画鏈熶篃蹇呴』鏍￠獙 value 涓€鑷达細

```lua
if redis.call("get", KEYS[1]) == ARGV[1] then
  return redis.call("pexpire", KEYS[1], ARGV[2])
else
  return 0
end
```

寤鸿绾︽潫锛?
- 鍗曟閿?TTL 榛樿 90 绉掋€?- 鍚庣闂瓟鎬昏秴鏃朵笉搴旇秴杩?120 绉掋€?- 濡傛灉鎵ц瓒呰繃 60 绉掍粛鏈粨鏉燂紝鍙画鏈熶竴娆°€?- 缁湡澶辫触鏃跺簲鍋滄缁х画璋冪敤涓嬫父宸ュ叿锛屽苟杩斿洖鏈嶅姟绻佸繖鎴栬秴鏃舵彁绀恒€?
## 8. 缂撳瓨涓€鑷存€?
- 绠＄悊閰嶇疆淇濆瓨鎴栧彂甯冨悗锛屽簲鍒犻櫎 `da:runtime:config:{agentId}`銆?- 鍒犻櫎缂撳瓨澶辫触鏃朵笉褰卞搷閰嶇疆淇濆瓨锛屼絾蹇呴』璁板綍鏃ュ織銆?- 闂瓟閾捐矾璇诲彇閰嶇疆鏃讹紝濡傛灉缂撳瓨鏈懡涓紝搴斾粠 MySQL 閲嶆柊鏋勫缓銆?- Redis 涓换鍔＄姸鎬佸彧鐢ㄤ簬蹇€熸煡璇紝浠诲姟鏈€缁堢姸鎬佷互 MySQL 涓哄噯銆?
## 9. 瀹夊叏瑕佹眰

- Redis 涓嶄繚瀛樻ā鍨?API Key 鏄庢枃銆?- Redis 涓嶄繚瀛樻暟鎹簮瀵嗙爜銆佸畬鏁磋繛鎺ヤ覆銆佸畬鏁村閮?API Key銆?- API Key 閴存潈缂撳瓨鍙繚瀛?`keyDigest`銆乣agentId`銆佹潈闄愭憳瑕佸拰鍚敤鐘舵€併€?- 闂鍘熸枃鍘熷垯涓婁笉杩涘叆瀹¤绫?Redis Key锛涘纭渶缂撳瓨锛屽簲鍏堣劚鏁忋€?
## 10. 寮€鍙戦獙鏀舵竻鍗?
- 鍚屼竴 `sessionId + clientMessageId` 閲嶈瘯涓嶄細閲嶅鍒涘缓鐢ㄦ埛娑堟伅鍜?Agent 娑堟伅銆?- 鍚屼竴浼氳瘽骞跺彂鎻愪氦鏃讹紝鍙湁涓€涓姹傝繘鍏ラ棶鏁颁富閾捐矾銆?- 鍒犻櫎杩愯閰嶇疆缂撳瓨鍚庯紝涓嬩竴娆￠棶绛旇兘浠?MySQL 閲嶅缓閰嶇疆銆?- 浠诲姟鐘舵€?Redis 杩囨湡鍚庯紝鍓嶇浠嶅彲浠?MySQL 鏌ヨ鏈€缁堜换鍔＄姸鎬併€?- 閿侀噴鏀鹃€昏緫涓嶄細鍒犻櫎鍏朵粬璇锋眰鎸佹湁鐨勯攣銆?
