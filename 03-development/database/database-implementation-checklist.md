# MOM 智能问数数据库落地清单

## 1. 使用前确认

- 目标数据库：MySQL 8.0
- 连接参数：
  - host: `127.0.0.1`
  - port: `3306`
  - username: `root`
  - password: set `MYSQL_ROOT_PASSWORD` locally before starting MySQL
  - database: `mom_data_agent`
  - charset: `utf8mb4`
  - collation: `utf8mb4_unicode_ci`
- MVP 最终结果仍保存在 `da_message.metadata_json.resultPayload`
- 后置能力不进入 MVP DDL
- 非 MySQL 历史脚本已归档保留，不作为当前验收入口

## 2. 执行顺序

1. `docs/database/001_mvp_schema.sql`
2. `docs/database/002_mvp_seed_data.sql`
3. `docs/database/003_mvp_verify.sql`
4. 检查 19 张 MVP 表是否创建成功
5. 检查默认数据是否写入成功

## 3. 本地验证

```powershell
docker compose -f .\docs\database\docker-compose.mysql.yml down -v
docker compose -f .\docs\database\docker-compose.mysql.yml up -d
.\docs\database\run-mysql-verification-in-docker.ps1
```

## 4. 期望结果

- 19 张 MVP 表存在
- 后置表不存在
- 默认 Agent 只有 1 条
- `LLM` 与 `EMBEDDING` 各 1 条默认模型
- 1 条默认数据源
- 3 条 Skill
- 3 条指标口径
- 3 条预设问题
- 1 条语音配置占位记录
- `da_message.metadata_json` 与 `da_chat_request_ledger.result_payload_snapshot` 都能承载结果载荷

## 5. 人工审核要点

- 同一 `agent_id + model_category` 只能有 1 条有效默认模型
- 同一 `agent_id` 只能有 1 条有效 active 数据源
- 同一 `session_id + user_message_id` 只能对应 1 条请求台账
- `da_chat_request_ledger` 作为幂等事实来源，`da_message` 保存最终消息
- `da_message.metadata_json.resultPayload` 与 SSE `complete.resultPayload` 结构保持一致
- 语音配置默认禁用
- 结果表、API 文档表、系统提示词表不进入 MVP

## 6. 安全边界

- 不明文落库 API Key、ASR Key、数据源密码
- 不打印完整连接串到日志
- 不把 Redis 当事实来源
- 语音识别只作为输入辅助
