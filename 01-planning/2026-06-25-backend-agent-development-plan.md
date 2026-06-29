# 后端接口与智能体开发计划

> 生成时间：2026-06-25 10:34:04  
> 适用对象：负责后端接口开发、数据库配置、智能体开发的开发者  
> 最高基准：docs/design/MOM智能问数-MVP开发Agent执行约束文档.md

## 1. 计划结论

本阶段不要直接从 LangChain/RAG 开始。正确顺序是：

1. 先修正文档与 SQL 脚本残留冲突，冻结 `default、sessionId + userMessageId、metadata_json.resultPayload`。
2. 建立 FastAPI 后端基础工程、统一响应、错误码、配置、数据库连接、Redis 连接。
3. 落地 MySQL DDL/Seed/Verify，并建立 SQLAlchemy Repository 与 Service 校验。
4. 先跑通用户问数最小闭环：保存用户消息 -> SSE 问数 -> 创建 Agent 回复 -> 终态前落库 -> 历史会话回显。
5. 再补管理侧配置接口：模型、数据源、Schema、表范围、Skill、知识、语义、预设问题、语音配置。
6. 最后接智能体编排：意图识别、受控工具、RAG 辅助、结果 Payload、评测集。

## 2. 当前必须先处理的问题

### P0-1 数据库脚本仍有旧口径

最新文档已统一：

- 默认 Agent：`gentId=default
- 问数幂等：sessionId + userMessageId
- 数据库字段：user_message_id

但当前 SQL 脚本仍存在：

- docs/database/002_mvp_seed_data.sql 默认 Agent 口径需要复核
- docs/database/003_mvp_verify.sql 默认 Agent 口径需要复核
- docs/database/001_mvp_schema.sql 仍有幂等字段残留
- docs/database/database-implementation-checklist.md 仍有废弃幂等字段表述
- docs/vibe-coding/任务卡-后端契约骨架.md 仍需与新问数入口保持一致

处理建议：第一轮任务只做口径修正和验证，不写业务后端。

### P0-2 任务卡需要重写

旧任务卡不能作为后端开发入口。新任务卡必须改为：

- POST /api/agent/default/sessions
- POST /api/sessions/{sessionId}/messages
- GET /api/stream/search
- POST /api/stream/stop
- 幂等键 sessionId + userMessageId

## 3. 开发阶段安排

### 阶段 0：基准修正与冻结

目标：让文档、DDL、Seed、Verify、检查表全部和 2026-06-25 终稿一致。

涉及文件：

- docs/database/001_mvp_schema.sql
- docs/database/002_mvp_seed_data.sql
- docs/database/003_mvp_verify.sql
- docs/database/database-implementation-checklist.md
- docs/vibe-coding/任务卡-后端契约骨架.md

必须完成：

- 把默认 Agent 口径统一为 `default`。
- 把问数链路字段统一为 `user_message_id`。
- da_message 补齐 user_message_id、	hread_id、metadata_json、updated_time。
- da_chat_request_ledger 补齐 user_message_id、`gent_message_id、	hread_id、
esult_payload_snapshot。
- 验证脚本检查 uk_session_user_message、metadata_json、user_message_id。

验收命令：

`powershell
.\docs\database\run-mysql-verification-in-docker.ps1
`

通过标准：输出 MVP database verification passed.，且 SQL 中不再出现旧默认 Agent 口径、废弃幂等字段和旧问数入口作为正式开发口径。

### 阶段 1：后端工程骨架

目标：建立 FastAPI 可运行后端，先不接真实 LLM/RAG/MOM。

建议目录：

`	ext
backend/
  pyproject.toml 或 requirements.txt
  app/
    main.py
    core/config.py
    core/errors.py
    core/response.py
    db/mysql.py
    db/redis.py
    api/router.py
    api/agent.py
    api/session.py
    api/stream.py
    api/voice.py
    schemas/common.py
    schemas/agent.py
    schemas/session.py
    schemas/stream.py
  tests/
    test_health.py
    test_openapi.py
`

接口先实现：

- GET /health
- GET /api/agent/default
- POST /api/agent/default/sessions
- GET /api/agent/default/sessions
- POST /api/sessions/{sessionId}/messages
- GET /api/sessions/{sessionId}/messages

验收：

`powershell
pytest backend/tests
uvicorn backend.app.main:app --reload
`

通过标准：OpenAPI 可访问，统一响应为 code/message/data，所有接口返回字段对齐接口文档。

### 阶段 2：数据库接入与 Repository

目标：让后端能连接 MySQL，完成系统库读写。

优先表：

- da_agent
- da_model_config
- da_datasource_config
- da_skill_config
- da_metric_definition
- da_preset_question
- da_session
- da_message
- da_chat_request_ledger

必须实现：

- SQLAlchemy 模型或 Core 映射。
- 数据库 session 管理。
- Repository 分层，不在 API 路由里直接写 SQL。
- Service 层校验默认 Agent 存在且启用。
- Service 层校验一个 Agent 只有一个 active 数据源。

验收：

- 本地 MySQL 验证环境启动后，后端能读取默认 Agent。
- 创建会话后 da_session 有记录。
- 保存用户消息后 da_message.message_id 返回给前端作为 userMessageId。

### 阶段 3：Redis 基础能力

目标：实现问数运行态，不把 Redis 当事实源。

P0 Key：

- da:runtime:config:{agentId}
- da:chat:idempotent:{sessionId}:{userMessageId}
- da:chat:lock:{sessionId}
- da:stream:active:{threadId}
- da:stream:stop:{threadId}
- da:stream:events:{threadId}

必须实现：

- 会话锁 SET NX PX 90000。
- Lua 校验 value 后释放锁。
- 长耗时任务续期。
- Redis 未命中时回查 MySQL 台账。
- Redis 写失败不能影响 MySQL 已落库事实。

验收：

- 同一 sessionId + userMessageId 重试不重复创建 Agent 回复。
- 删除 Redis 幂等缓存后，MySQL 台账仍能阻止重复执行。
- 暂停接口能写入 stop flag。

### 阶段 4：用户问数最小闭环

目标：跑通文本问数闭环，智能体先用规则/Mock 工具，不接复杂 RAG。

流程：

1. POST /api/agent/default/sessions 创建会话。
2. POST /api/sessions/{sessionId}/messages 保存用户消息，返回 userMessageId。
3. GET /api/stream/search?...userMessageId=... 发起 SSE。
4. 后端写入 da_chat_request_ledger。
5. 后端创建 Agent 回复消息，message_status=PROCESSING。
6. 调用智能体编排服务。
7. 终态事件前更新 Agent 回复消息为 SUCCESS/FAILED/STOPPED，写入 metadata_json.resultPayload。
8. GET /api/sessions/{sessionId}/messages 可回显完整结果。

MVP 首批支持三类问题：

- 工单状态统计
- 低于安全库存物料
- 设备停机时长分析

验收：

- 三个推荐问题均可返回结构化 
esultPayload。
- 未知问题返回澄清/边界提示，不调用 MOM 查询工具。
- complete.resultPayload 与数据库 metadata_json.resultPayload 一致。
- SSE 断线重连不重复执行工具。

### 阶段 5：管理侧配置接口

目标：补齐管理侧配置能力，让问数能力可配置、可测试。

建议顺序：

1. 默认 Agent 查询：GET /api/agent/default
2. 模型配置：列表、添加、更新、测试、生效
3. 数据源配置：保存、更新、测试、绑定、Schema 初始化、Schema 查询、表范围
4. 预设问题：列表、保存
5. Skill：列表、导入、启停、删除、测试
6. 知识：智能体知识、业务知识、召回开关、重试向量化、召回测试
7. 语义模型：查询、新增、编辑、启停、删除、导入
8. 语音配置：用户侧配置、管理侧配置、保存配置、ASR 代理

阶段验收：

- 默认 Agent 可用性判断符合接口文档。
- 数据源测试失败时禁止 Schema 初始化。
- Schema 初始化失败不覆盖上一版成功 Schema。
- 语义字段必须来自已初始化 Schema。
- Skill 停用后智能体不得调用。
- 语音配置不向前端返回密钥明文。

### 阶段 6：智能体编排与工具

目标：实现受控问数，不做开放式通用 Agent。

建议模块：

`	ext
agent/
  orchestrator.py
  prompts/system_prompt.md
  intent/classifier.py
  tools/registry.py
  tools/work_order.py
  tools/inventory.py
  tools/equipment.py
  rag/retriever.py
  guards/sql_guard.py
  result_builder.py
  evals/cases.yaml
`

编排原则：

- LLM 只能做意图识别、参数抽取、解释生成，不直接生成或执行 SQL。
- RAG 只用于口径、字段、规则解释，不作为实时业务事实来源。
- 工具调用必须走注册表，未注册工具禁止调用。
- 工具输入必须是结构化 JSON。
- 工具层二次校验：只读、表范围、最大行数、超时、危险 SQL 拦截。
- NO_DATA 是成功空结果。

首批工具：

- workOrderStatusSummary
- inventoryBelowSafetyStock
- equipmentDowntimeSummary

验收：

- 三类推荐问题命中对应工具。
- 超范围问题不调用工具。
- 停用 Skill 后不调用工具。
- 工具输出可稳定映射为文本、表格、指标卡、图表和运行提示。

### 阶段 7：语音输入

目标：完成后端 ASR 代理，但不自动问数。

接口：

- GET /api/voice/config
- GET /api/voice/config/admin
- PUT /api/voice/config
- POST /api/voice/asr

必须遵守：

- 只接收 WAV。
- 后端代理调用 ASR。
- 密钥加密保存，不下发前端。
- 不保存原始音频。
- 不保存独立语音识别记录。
- 不自动创建消息，不自动调用问数。
- 用户确认发送后，消息 inputType=VOICE。

验收：

- 配置停用时用户侧语音入口不可用。
- 上传非 WAV 返回明确错误。
- 限流 Key da:rate:voice:{sessionId}:{clientIp} 生效。
- ASR 返回空文本时不进入问数链路。

### 阶段 8：测试、评测和联调

测试分层：

- 单元测试：Service 校验、幂等、SQL Guard、工具映射、结果 Payload。
- 接口测试：所有确认实现接口的请求/响应字段。
- 数据库测试：DDL/Seed/Verify、Repository CRUD。
- Redis 测试：锁、幂等、active task、stop flag。
- 智能体评测：三类业务问题、无数据、未知问题、提示词注入、SQL 诱导、停用 Skill。
- 前后端联调：按接口文档第 11 节联调主流程执行。

最低验收命令：

`powershell
.\docs\database\run-mysql-verification-in-docker.ps1
pytest backend/tests
npm run test
npm run build
`

## 4. 建议按周排期

### 第 1 周：基准修正 + 后端骨架

- D1：修正 SQL/检查表/旧任务卡口径。
- D2：建立 FastAPI 工程、统一响应、错误码、OpenAPI。
- D3：接 MySQL，读取默认 Agent、创建会话。
- D4：保存/查询消息接口。
- D5：补接口测试和数据库验证。

### 第 2 周：问数主链路 + Redis

- D1：实现 Redis 客户端、锁、幂等缓存。
- D2：实现请求台账 da_chat_request_ledger。
- D3：实现 SSE start/message/complete/error 基础流。
- D4：实现暂停 stop flag 和 STOPPED 落库。
- D5：三类 Mock 工具返回结构化 resultPayload。

### 第 3 周：管理侧配置

- D1：模型配置接口。
- D2：数据源保存、测试、绑定。
- D3：Schema 初始化、Schema 查询、表范围配置。
- D4：预设问题、Skill 基础接口。
- D5：知识、业务知识、语义模型基础 CRUD。

### 第 4 周：智能体编排

- D1：意图识别和参数抽取。
- D2：工具注册表和三类工具适配。
- D3：SQL 安全、只读、表范围、最大行数、超时。
- D4：RAG 召回接入到口径解释，不返回实时事实。
- D5：结果构造器和智能体评测集。

### 第 5 周：语音 + 回归联调

- D1：语音配置接口。
- D2：ASR 代理和限流。
- D3：前后端语音流程联调。
- D4：全链路异常和安全测试。
- D5：UAT 前修复和验收报告。

## 5. 你的每日开发节奏

每天只做一个可验证闭环：

1. 先写任务卡：目标、范围、涉及文件、验收命令。
2. 先写测试或接口断言。
3. 再写最小实现。
4. 跑验证命令。
5. 更新 progress.md 和必要文档。

## 6. 不要做的事

- 不做外部 API、API Key、POST /api/v1/agent/invoke。
- 不做用户登录、注册、多租户、权限中心。
- 不做多 Agent 管理。
- 不做 GraphRAG、知识图谱、Neo4j 图查询。
- 不做前端任务查询接口。
- 不让 LLM 直接生成并执行 SQL。
- 不把 Redis 当事实源。
- 不保存 ASR 原始音频。

## 7. 下一步第一张任务卡

建议你下一步先做：

**任务卡 001：修正数据库脚本与后端任务卡旧口径**

目标：让 SQL、检查表、任务卡和终稿文档一致。

验收：

`powershell
rg "废弃幂等字段|旧问数入口" docs backend agent
.\docs\database\run-mysql-verification-in-docker.ps1
`

期望：正式开发文档和 SQL 中不再把旧口径作为 MVP 实现依据；数据库验证通过。

