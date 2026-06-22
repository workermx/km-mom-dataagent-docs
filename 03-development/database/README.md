# MOM鏅鸿兘闂暟-MVP鏁版嵁搴撲氦浠樼墿璇存槑

## 1. 鍏堣浠€涔?
寤鸿鎸変互涓嬮『搴忛槄璇伙細

1. `MOM鏅鸿兘闂暟-MVP鏁版嵁搴撹璁℃枃妗?md`锛氱湅鏁版嵁搴撴€讳綋璁捐鍜岃〃缁撴瀯鍙ｅ緞銆?2. `database-implementation-checklist.md`锛氭寜娓呭崟鎵ц鏈湴鎴?CI 楠岃瘉銆?3. `001_mvp_schema.sql`锛氱郴缁熷簱 DDL銆?4. `002_mvp_seed_data.sql`锛歁VP 榛樿鍒濆鍖栨暟鎹€?5. `003_mvp_verify.sql`锛氭墽琛屽悗楠屾敹 SQL锛屽寘鍚‖鏂█銆?6. `redis-key-spec.md`锛歊edis Key銆佸箓绛夈€侀攣鍜岀紦瀛樹竴鑷存€ц鑼冦€?
## 2. 鏈湴楠岃瘉

鍚姩鏈湴 MySQL 8.0 楠岃瘉搴擄細

```powershell
docker compose -f .\03-development\database\docker-compose.mysql.yml up -d
```

鎵ц鏁版嵁搴撻獙璇侊細

```powershell
.\03-development\database\run-mysql-verification.ps1 -HostName 127.0.0.1 -Port 3306 -User root -Password root123456
```

濡傛灉鏈満娌℃湁 `mysql` 瀹㈡埛绔紝涔熷彲浠ョ洿鎺ヤ娇鐢ㄥ鍣ㄥ唴 MySQL 瀹㈡埛绔獙璇侊細

```powershell
.\03-development\database\run-mysql-verification-in-docker.ps1
```

楠岃瘉鑴氭湰浼氭墽琛岋細

1. `001_mvp_schema.sql`
2. `002_mvp_seed_data.sql`
3. `002_mvp_seed_data.sql`锛岀浜屾鎵ц鐢ㄤ簬楠岃瘉 seed 骞傜瓑鎬?4. `003_mvp_verify.sql`

閫氳繃鏃跺簲鐪嬪埌锛?
```text
MVP database verification passed.
```

## 3. CI 楠岃瘉

濡傛灉鏈満 Docker daemon 涓嶅彲鐢紝鍙娇鐢細

```text
.github/workflows/database-verify.yml
```

璇?workflow 浼氬惎鍔?MySQL 8.0 鏈嶅姟瀹瑰櫒锛屽苟鎵ц schema銆乻eed銆乻eed銆乿erify銆?
## 4. 瀹夊叏杈圭晫

- `002_mvp_seed_data.sql` 鍙厑璁镐繚瀛樺崰浣嶅瘑鏂囷紝涓嶅厑璁稿啓鍏ョ湡瀹炴ā鍨?Key銆佹暟鎹簱瀵嗙爜銆丄PI Key銆?- `docker-compose.mysql.yml` 涓殑 `root123456` 鍙敤浜庢湰鍦板紑鍙戦獙璇併€?- 鐪熷疄鐜蹇呴』閫氳繃鍚庣鍔犲瘑娴佺▼鎴栫鐞?API 鍐欏叆鏁忔劅閰嶇疆銆?- Redis 涓嶆槸浜嬪疄鏉ユ簮锛屾牳蹇冩暟鎹繀椤昏惤 MySQL銆?
## 5. 楠岃瘉鐘舵€?
褰撳墠鏂囨。鍜岃剼鏈凡瀹屾垚闈欐€佽瘎瀹°€佷慨姝ｅ拰鏈湴 MySQL 8.0 Docker 鐪熷疄鎵ц楠岃瘉銆傞獙璇佸凡瑕嗙洊 schema銆乻eed銆乻eed 骞傜瓑鍜?verify 纭柇瑷€銆?
濡傛灉鐩爣閮ㄧ讲鐜涓嶆槸 MySQL 8.0锛屽簲鍦ㄧ洰鏍囨暟鎹簱鐗堟湰涓婂璺戠瓑浠烽獙璇佹祦绋嬨€?
