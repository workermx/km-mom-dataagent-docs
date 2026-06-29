# MOM 智能问数数据库交付物

## 当前状态

- 系统自身库目标数据库：MySQL 8.0。
- MVP 数据库事实来源以 `docs/database/MOM智能问数-MVP数据库设计文档.md` 为准。
- 非 MySQL 历史脚本已归档保留，不作为当前 MVP 开发、验证和联调入口。

## MySQL 8.0 交付文件

- schema: `001_mvp_schema.sql`
- seed: `002_mvp_seed_data.sql`
- verify: `003_mvp_verify.sql`
- runner: `run-mysql-verification.ps1`
- docker compose: `docker-compose.mysql.yml`
- docker runner: `run-mysql-verification-in-docker.ps1`

## MySQL 本地 Docker 连接信息

- host: `127.0.0.1`
- port: `3306`
- user: `root`
- password: set `MYSQL_ROOT_PASSWORD` locally before starting MySQL
- database: `mom_data_agent`
- charset: `utf8mb4`
- collation: `utf8mb4_unicode_ci`

## 本地验证命令

```powershell
docker compose -f .\docs\database\docker-compose.mysql.yml down -v
docker compose -f .\docs\database\docker-compose.mysql.yml up -d
.\docs\database\run-mysql-verification-in-docker.ps1
```

如使用本机 MySQL 客户端：

```powershell
.\docs\database\run-mysql-verification.ps1 -HostName 127.0.0.1 -Port 3306 -User root -Password $env:MYSQL_ROOT_PASSWORD -Database mom_data_agent -MysqlPath mysql
```

## DataGrip 连接建议

1. 新建 MySQL 数据源。
2. 填写 host、port、user、password。
3. 默认 database 选择 `mom_data_agent`。
4. 连接后手工执行脚本时，按顺序执行：
   - `001_mvp_schema.sql`
   - `002_mvp_seed_data.sql`
   - `003_mvp_verify.sql`

## 安全说明

- 本地 seed 只保存占位密文和脱敏值，不保存真实密钥、密码或完整连接串。
- 生产环境不要直接使用本地 seed 中的占位模型、数据源和语音配置。
- Redis 只做短期缓存、锁和运行态，MySQL 是事实来源。
