# MOM智能问数后端与智能体 VibeCoding 任务安排

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or executing-plans when implementing this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 用 100% Codex/VibeCoding 的方式，完成 MOM 智能问数 MVP 的后端接口、数据库/Redis 运行态、受控智能体编排、语音 ASR 代理和后端测试评测闭环。

**Architecture:** 主窗口作为“高级架构师”负责拆任务、审查和验收；每张任务卡交给 Codex 独立实现，完成后由主窗口复审。后端以 FastAPI 为接口层，MySQL 为事实源，Redis 只保存短期运行态，智能体通过受控工具访问 MOM 数据，不允许 LLM 直接生成并执行 SQL。

**Tech Stack:** Python、FastAPI、Pydantic、Pytest、MySQL、Redis、SQLAlchemy/Alembic、SSE、受控 Agent 工具、RAG 辅助知识召回。

---

## 1. 适用边界

本安排只覆盖后端和智能体部分，不安排前端页面开发。

默认假设：

- MVP 固定 `agentId=default`，固定默认用户，不做登录、租户、多 Agent、多数据源路由。
- 问数链路固定为：先保存用户消息，拿到 `userMessageId`，再通过 SSE 发起问数。
- 幂等键固定为 `sessionId + userMessageId`。
- 最终结果固定保存到 Agent 回复消息 `metadata_json.resultPayload`。
- Redis 只做锁、幂等缓存、SSE 缓冲、运行态、暂停信号、语音限流，不做事实源。
- 外部 API、API Key、`X-API-Key`、`POST /api/v1/agent/invoke` 均为后置，不进入 MVP 实现。
- 语音只做 ASR 输入辅助：上传 WAV，后端返回文本，用户手动发送后才进入问数。
- RAG 只用于口径、字段、术语、规则解释，不作为实时业务事实来源。
- 前端不由当前计划负责；如接口联调发现前端口径差异，只记录对接问题，不在本计划中改前端。

## 2. 每轮 Codex 固定读取顺序

每次开新任务卡前，Codex 必须先读取：

1. `docs/design/MOM智能问数-MVP开发Agent执行约束文档.md`
2. `docs/design/MOM智能问数-MVP全量文档终稿对齐报告.md`
3. `docs/design/MOM智能问数-MVP接口设计文档.md`
4. `docs/database/MOM智能问数-MVP数据库设计文档.md`
5. `docs/database/redis-key-spec.md`
6. 当前任务相关的 `docs/requirements/` 或 `docs/vibe-coding/` 文档
7. 当前要改的代码文件和测试文件

禁止只读项目方案后直接开发。项目方案只能作为背景，不能覆盖接口、数据库、Redis 和执行约束文档。

## 3. VibeCoding 执行机制

推荐每轮只做一张任务卡：

1. 高级架构师窗口定义任务卡：目标、范围、不做事项、涉及文件、验收命令。
2. Codex 实现任务卡：先读文档和当前代码，再写测试或接口断言，再做最小实现。
3. Codex 运行验证：至少运行任务卡列出的后端测试或数据库验证。
4. 高级架构师窗口复审：查范围扩张、旧口径、后置能力误入、测试缺口。
5. 复审发现问题后，单独开修复任务卡，不和下一阶段混做。

你本人主要负责三件事：

- 确认业务事实：工单、库存、设备三类主题的表、字段、状态、指标口径。
- 确认环境事实：MySQL、Redis、MOM 数据源、ASR 服务、模型服务是否可连接。
- 审批范围变化：凡是文档未定义、需要新增表/接口/Redis Key/业务规则的内容，先确认再开发。

## 4. 总优先级

| 优先级 | 阶段 | 目标 | 是否阻塞后续 |
| --- | --- | --- | --- |
| P0 | 任务卡 001-004 | 清理旧口径，打牢后端契约、数据库和 Redis 基础 | 是 |
| P0 | 任务卡 005-007 | 跑通用户问数最小闭环和三类 Mock 工具 | 是 |
| P1 | 任务卡 008-010 | 管理侧配置、Schema、语义/知识基础能力 | 部分阻塞真实 MOM 查询 |
| P1 | 任务卡 011-013 | 真实 MOM 只读工具、智能体编排、安全 Guard | 是 |
| P1 | 任务卡 014 | 语音 ASR 代理 | 不阻塞文本问数 |
| P1 | 任务卡 015 | ZHGC 整体需求下的智能问数范围扩展 | 阻塞最终评测 |
| P1 | 任务卡 016 | 评测、回归、联调门禁 | 上线前阻塞 |

## 5. 任务卡 001：基准冲突复扫与旧口径清理

### 目标

清理活动文档、数据库 SQL 和后端任务卡中仍残留的旧口径，冻结后端正式契约。

### 范围

做：

- 修正 `docs/database/*.sql` 中的默认 Agent、幂等字段和问数入口示例。
- 修正 `docs/database/database-implementation-checklist.md` 中废弃幂等字段检查项。
- 修正 `docs/Vibe-Coding-落地手册.md` 中旧口径示例，避免后续 Codex 误读。
- 复扫 `docs/`、`backend/`、`agent/`。

不做：

- 不改前端。
- 不实现新业务接口。
- 不引入真实数据库连接。

### 涉及文件

- `docs/database/001_mvp_schema.sql`
- `docs/database/002_mvp_seed_data.sql`
- `docs/database/003_mvp_verify.sql`
- `docs/database/database-implementation-checklist.md`
- `docs/Vibe-Coding-落地手册.md`
- `docs/vibe-coding/任务卡-后端契约骨架.md`

### 验收命令

```powershell
rg -n "废弃幂等字段|旧问数入口|da_api_access|da:api-key" docs backend agent
python -m pytest backend/tests -q
.\docs\database\run-mysql-verification-in-docker.ps1
```

### 通过标准

- 正式开发口径不再使用废弃幂等字段作为后端幂等字段。
- SQL seed 默认 Agent 为 `default`。
- DDL 和 verify SQL 使用 `user_message_id`、`uk_session_user_role`、`uk_session_user_message` 等终稿口径。
- 数据库验证通过并输出 `MVP database verification passed.`。

## 6. 任务卡 002：后端契约骨架复审与补齐

### 目标

将现有 FastAPI 内存骨架补齐到接口文档确认实现的用户侧基础契约，不接 MySQL、Redis、LLM、RAG、ASR。

### 范围

做：

- 复审 `GET /health`、`GET /api/agent/default`。
- 复审会话创建、会话列表、消息保存、消息列表。
- 补齐会话改名、置顶、删除的内存契约骨架。
- 确认统一响应 `code/message/data`。
- 确认 OpenAPI 可生成。

不做：

- 不做管理侧配置接口。
- 不接真实数据库。
- 不做 SSE 真流式。

### 涉及文件

- `backend/app/api/*.py`
- `backend/app/schemas/*.py`
- `backend/app/services/*.py`
- `backend/tests/test_contract.py`
- `backend/tests/test_health.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 所有已实现接口字段与接口设计文档一致。
- `POST /api/sessions/{sessionId}/messages` 返回 `userMessageId`。
- 代码中不新增旧 DataAgent 问数入口。
- 后端 README 明确当前仍是内存契约骨架。

## 7. 任务卡 003：MySQL 连接、模型与 Repository

### 目标

把后端从内存服务推进到 MySQL Repository，但仍不接真实 MOM 查询。

### 范围

做：

- 增加后端配置项：系统库连接串、连接池、环境变量读取。
- 增加 MySQL session 管理。
- 建立 P0 表的 SQLAlchemy 模型或 Core 映射。
- 建立 Repository：Agent、Session、Message、ChatRequestLedger、ModelConfig、DatasourceConfig、SkillConfig、PresetQuestion。
- Service 层从 Repository 读取默认 Agent、创建会话、保存消息。

不做：

- 不改数据库设计文档外的表结构。
- 不做 Alembic 复杂迁移体系，除非先确认。
- 不连接 MOM 业务库。

### 涉及文件

- `backend/pyproject.toml`
- `backend/app/core/config.py`
- `backend/app/db/mysql.py`
- `backend/app/models/*.py`
- `backend/app/repositories/*.py`
- `backend/app/services/session_service.py`
- `backend/app/services/agent_service.py`
- `backend/tests/*`

### 验收命令

```powershell
.\docs\database\run-mysql-verification-in-docker.ps1
python -m pytest backend/tests -q
```

### 通过标准

- 后端能读取 MySQL seed 中的默认 Agent。
- 创建会话写入 `da_session`。
- 保存用户消息写入 `da_message`，用户消息的 `message_id` 即 `userMessageId`。
- Repository 层隔离数据库访问，API 路由不直接写 SQL。

## 8. 任务卡 004：Redis 运行态基础能力

### 目标

实现问数运行链路所需的 Redis 锁、幂等缓存、运行任务、暂停信号和 SSE 事件缓冲基础能力。

### 范围

做：

- 增加 Redis 客户端配置。
- 实现 `da:chat:lock:{sessionId}` 获取、续期、Lua 校验释放。
- 实现 `da:chat:idempotent:{sessionId}:{userMessageId}` 读写。
- 实现 `da:stream:active:{threadId}`。
- 实现 `da:stream:stop:{threadId}`。
- 实现 `da:stream:events:{threadId}` 的最小写入/读取封装。

不做：

- 不把 Redis 当最终事实源。
- 不在 Redis 保存密钥、原始 SQL、原始音频。
- 不实现后置 Key。

### 涉及文件

- `backend/app/db/redis.py`
- `backend/app/services/runtime_state_service.py`
- `backend/app/services/stream_service.py`
- `backend/tests/test_redis_runtime.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 同一 `sessionId + userMessageId` 重试不重复进入执行链路。
- Redis 幂等缓存丢失后，可回查 MySQL `da_chat_request_ledger`。
- 锁释放必须校验 value，不能误删别的请求锁。
- 暂停接口能写入 stop flag。

## 9. 任务卡 005：SSE 问数最小闭环

### 目标

跑通用户文本问数闭环：保存用户消息、SSE 启动、创建 Agent 回复、终态前落库、历史消息回显。

### 范围

做：

- `GET /api/stream/search` 返回真实 `text/event-stream`。
- 首次问数写入 `da_chat_request_ledger`。
- 创建 Agent 回复消息，初始状态 `PROCESSING`。
- 发出 `start`、`message`、`complete`、`error`、`stopped` 事件。
- `complete/stopped/error` 终态事件发送前更新 MySQL 消息状态和 `metadata_json.resultPayload`。
- `GET /api/sessions/{sessionId}/messages` 能回显最终结果。

不做：

- 不接真实 MOM 查询。
- 不让前端传 `query` 作为正式问题来源。
- 不保存中间思考链。

### 涉及文件

- `backend/app/api/stream.py`
- `backend/app/services/stream_service.py`
- `backend/app/services/chat_orchestration_service.py`
- `backend/app/schemas/stream.py`
- `backend/tests/test_stream_sse.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- `complete.resultPayload` 与 Agent 回复消息 `metadata_json.resultPayload` 一致。
- 同一 `sessionId + userMessageId` 断线重连不重复创建 Agent 回复。
- 已终态请求不重复调用后续工具。
- 暂停后最终状态为 `STOPPED`。

## 10. 任务卡 006：结果 Payload 构造器

### 目标

建立统一的 `resultPayload` 构造与校验模块，支撑文本、表格、指标卡、图表和运行提示。

### 范围

做：

- 定义 `resultType`、`resultStatus`、`textAnswer`、`table`、`indicators`、`chart`、`notice` 的 Pydantic 模型。
- 实现 JSON 序列化和反序列化校验。
- 实现 `SUCCESS`、`NO_DATA`、`NEED_CLARIFICATION`、`CONFIG_UNAVAILABLE`、`FAILED` 等常见结果构造函数。
- 控制大表格 `total/limit/truncated`。

不做：

- 不新增独立结果表。
- 不使用 `charts` 复数字段。

### 涉及文件

- `backend/app/schemas/result_payload.py`
- `backend/app/services/result_builder.py`
- `backend/tests/test_result_payload.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 所有 Agent 回复最终结果都能通过模型校验。
- `chart` 为单数。
- `NO_DATA` 是成功空结果，不按系统错误处理。

## 11. 任务卡 007：三类 Mock 工具闭环

### 目标

在不接真实 MOM 数据源前，用受控 Mock 工具跑通三类问数主题。

### 范围

做：

- 建立工具注册表。
- 建立三类工具：工单状态统计、低于安全库存物料、设备停机时长分析。
- 建立简单意图分类规则，让三个预设问题命中对应工具。
- 工具输出统一交给 `resultPayload` 构造器。

不做：

- 不执行真实 SQL。
- 不让 LLM 自行选择未注册工具。
- 不支持三类主题外的自由查询。

### 涉及文件

- `agent/tools/registry.py`
- `agent/tools/work_order.py`
- `agent/tools/inventory.py`
- `agent/tools/equipment.py`
- `agent/orchestrator.py`
- `backend/app/services/chat_orchestration_service.py`
- `backend/tests/test_agent_mock_tools.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 三个推荐问题分别命中三类工具。
- 未知问题返回澄清或边界提示，不调用工具。
- 停用 Skill 后不得调用对应工具。

## 12. 任务卡 008：管理侧模型与数据源配置接口

### 目标

实现问数运行所需的管理侧核心配置接口。

### 范围

做：

- 模型配置：列表、新增、更新、测试、生效。
- 数据源配置：新增、更新、测试、绑定默认 Agent。
- 敏感字段加密保存、脱敏回显。
- 生效规则：同一 Agent 同一模型分类只允许一个生效配置；默认 Agent 只绑定一个生效 MOM 数据源。

不做：

- 不做外部 API Key。
- 不做多数据源路由。
- 不连接非 MOM 产品库。

### 涉及文件

- `backend/app/api/model_config.py`
- `backend/app/api/datasource.py`
- `backend/app/services/model_config_service.py`
- `backend/app/services/datasource_service.py`
- `backend/app/repositories/*.py`
- `backend/tests/test_admin_model_datasource.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 测试失败的数据源禁止 Schema 初始化。
- 生效切换满足唯一约束。
- API 不返回密钥明文。

## 13. 任务卡 009：Schema 初始化、表范围与语义模型

### 目标

让默认 Agent 知道当前 MOM 数据源可问哪些表、字段和业务语义。

### 范围

做：

- Schema 初始化任务写入 `da_schema_init_task`。
- 保存表缓存 `da_schema_table` 和字段缓存 `da_schema_column`。
- 表范围配置写入 `da_table_scope`。
- 语义字段映射写入 `da_semantic_field`。
- 语义字段必须来自已初始化 Schema。

不做：

- 不提供前端任务查询接口。
- 不覆盖上一版成功 Schema，除非新初始化成功。
- 不做跨数据源 Join。

### 涉及文件

- `backend/app/api/datasource.py`
- `backend/app/api/semantic_model.py`
- `backend/app/services/schema_service.py`
- `backend/app/services/semantic_model_service.py`
- `backend/tests/test_schema_semantic.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 未通过连接测试的数据源不能初始化 Schema。
- 语义字段引用不存在的表/字段时返回校验错误。
- 失败任务状态落 MySQL，Redis 只是内部观测。

## 14. 任务卡 010：Skill、知识、业务术语与预设问题

### 目标

补齐智能体运行所需的 Skill 启停、知识召回配置、业务术语和推荐问题配置。

### 范围

做：

- Skill 列表、导入、启停、删除、测试的基础能力。
- 智能体知识、业务知识 CRUD、召回开关、重试向量化、召回测试。
- 预设问题查询和保存。
- 向量化任务最终状态写入 `da_vector_task`。

不做：

- 不建设完整评测平台。
- 不做 GraphRAG/知识图谱。
- 不让停用 Skill 被智能体调用。

### 涉及文件

- `backend/app/api/skills.py`
- `backend/app/api/knowledge.py`
- `backend/app/api/business_knowledge.py`
- `backend/app/api/preset_questions.py`
- `backend/app/services/*.py`
- `backend/tests/test_skill_knowledge_preset.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 用户侧推荐问题只返回启用项。
- 知识召回测试不返回实时业务事实。
- 停用 Skill 后工具注册表不可调用对应能力。

## 15. 任务卡 011：真实 MOM 只读查询工具

### 目标

在业务事实确认后，把 Mock 工具替换为受控只读 MOM 查询工具。

### 业务事实确认门槛

本任务开始前，你需要确认：

- 工单主题：工单表、状态字段、状态枚举、时间字段、组织/产线过滤字段、统计口径。
- 库存主题：物料表、库存表、安全库存字段、仓库字段、批次/冻结库存处理规则。
- 设备主题：设备表、停机事件表、开始/结束时间、未结束停机处理、停机类型过滤。
- 通用规则：默认时间范围、最大返回行数、无数据提示、权限/组织过滤是否由 MOM 数据源字段体现。

### 范围

做：

- 真实工具只读连接当前生效 MOM 数据源。
- 工具输入为结构化参数。
- 工具内部使用预定义 SQL 模板或 Query Builder。
- 工具层校验表范围、字段范围、最大行数、超时。

不做：

- 不让 LLM 直接写 SQL。
- 不执行 INSERT/UPDATE/DELETE/DDL。
- 不查询未授权表。

### 涉及文件

- `agent/tools/work_order.py`
- `agent/tools/inventory.py`
- `agent/tools/equipment.py`
- `agent/guards/sql_guard.py`
- `backend/app/services/mom_datasource_service.py`
- `backend/tests/test_mom_tools.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 三类工具只执行只读查询。
- 超范围字段、危险 SQL、超行数、超时都有明确失败结果。
- `NO_DATA` 返回成功空结果。

## 16. 任务卡 012：智能体编排核心

### 目标

实现受控智能体主链路：意图识别、参数抽取、工具选择、工具调用、结果解释。

### 范围

做：

- 系统提示词内置。
- 意图分类限定为工单、库存、设备、未知。
- 参数抽取输出结构化 JSON。
- 工具调用必须走注册表。
- RAG 结果只作为口径解释，不作为事实数据。
- 每次执行生成 `traceId`、`toolName`、`metricVersion`。

不做：

- 不做人工审核、人工反馈、拒绝计划、只 NL2SQL。
- 不做多轮复杂计划器。
- 不开放系统提示词编辑。

### 涉及文件

- `agent/orchestrator.py`
- `agent/intent/classifier.py`
- `agent/prompts/system_prompt.md`
- `agent/tools/registry.py`
- `agent/result_builder.py`
- `backend/app/services/chat_orchestration_service.py`
- `backend/tests/test_agent_orchestrator.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 三类主题命中正确工具。
- 未知/越界/提示词注入问题不调用工具。
- 输出可稳定映射到 `resultPayload`。

## 17. 任务卡 013：安全 Guard 与审计日志

### 目标

为真实问数链路加上 SQL、工具、输出和审计安全边界。

### 范围

做：

- SQL Guard：只读、禁止危险关键字、禁止多语句、表范围校验。
- 工具 Guard：启用状态、输入 schema、超时、最大行数。
- 输出 Guard：不返回 SQL、密钥、堆栈、原始 HTML。
- 审计日志写入 `da_audit_log`。

不做：

- 不建设用户权限中心。
- 不做租户隔离。
- 不做完整审计报表页面。

### 涉及文件

- `agent/guards/sql_guard.py`
- `agent/guards/output_guard.py`
- `backend/app/services/audit_service.py`
- `backend/tests/test_security_guards.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- SQL 注入和提示词诱导测试不触发真实工具执行。
- 用户侧结果不包含敏感内部信息。
- 每次工具调用有审计记录。

## 18. 任务卡 014：语音 ASR 代理

### 目标

完成后端语音输入配置和 ASR 代理能力。

### 范围

做：

- `GET /api/voice/config`
- `GET /api/voice/config/admin`
- `PUT /api/voice/config`
- `POST /api/voice/asr`
- WAV 格式、大小、时长、MIME/header 校验。
- `da:rate:voice:{sessionId}:{clientIp}` 限流。
- ASR 密钥加密保存、脱敏回显。

不做：

- 不保存原始音频。
- 不保存独立语音识别记录。
- 不自动创建消息。
- 不自动进入问数链路。

### 涉及文件

- `backend/app/api/voice.py`
- `backend/app/services/voice_config_service.py`
- `backend/app/services/asr_proxy_service.py`
- `backend/tests/test_voice.py`

### 验收命令

```powershell
python -m pytest backend/tests -q
```

### 通过标准

- 配置停用时用户侧语音不可用。
- 非 WAV 上传返回明确错误。
- 识别为空不进入问数链路。
- 不向前端返回供应商密钥明文。

## 19. 任务卡 015：ZHGC 整体需求下的智能问数范围扩展

### 目标

把 `C:\Users\Administrator\Desktop\ZHGC_AI整体需求.md` 中属于“智能问数”的内容纳入后端与智能体规划，形成可实现、可评测、可确认的业务范围扩展。此任务只扩展智能问数，不实现完整知识库平台、语音报工报警或周边系统全量集成。

### 来源判断

可进入当前智能问数规划：

- 制造订单准时开工率、准时完工率。
- 合格率、废品率。
- 今日未处理异常数量。
- 工序任务 SOP 操作指导文件查询。
- 表格、柱状图、饼图、仪表盘类结果展示的后端数据结构支持。
- 结果来源标识和推导过程的可配置返回。
- 语音问数响应性能、并发和冲突处理的后端验收项。

不进入当前智能问数 MVP，作为后置专项：

- 文档智慧萃取平台：PDF、Word、Excel、TXT、图片 OCR、扫描件解析和自动填表。
- 知识图谱或 GraphRAG 平台。
- ERP、EDS、CRM、SRM、PLM、DMS 全量周边系统集成。
- 语音报工、语音报警、二次确认、报警通知推送。
- 用户、角色、权限体系的完整建设。
- Excel/PDF 导出如果要做，只能作为“当前问数结果导出”单独评审，不并入报告中心。

### 范围

做：

- 新增 ZHGC 智能问数业务主题清单。
- 新增制造订单、质量、异常、SOP 查询的业务事实确认表。
- 扩展 Agent 意图分类设计：`work_order`、`inventory`、`equipment`、`production_order`、`quality_metric`、`exception_stat`、`sop_lookup`、`unknown`。
- 扩展工具注册规划，但真实查询工具仍需业务事实确认后实现。
- 扩展 `resultPayload` 规划，加入来源标识和推导过程配置字段。
- 新增评测用例草案，覆盖整体需求中的典型问句。
- 更新任务卡 011、012、016 的验收口径引用。

不做：

- 不直接写业务代码。
- 不改前端。
- 不连接 ERP/EDS/CRM/SRM/PLM/DMS。
- 不实现语音报工报警。
- 不实现文档 OCR/扫描件解析。
- 不新增权限体系。

### 涉及文件

- `docs/planning/2026-06-25-vibecoding-backend-agent-task-arrangement.md`
- `agent/evals/cases.yaml`
- `backend/tests/test_agent_evals.py`

如果需要修改接口、数据库或执行约束文档，必须先提出契约变更建议，不直接改成扩大版 MVP。

### 验收命令

```powershell
python -m pytest backend/tests -q
```

如果本任务只产生文档和评测样例草案，至少运行：

```powershell
rg -n "production_order|quality_metric|exception_stat|sop_lookup|sourceLabel|derivation" docs agent backend
```

### 通过标准

- 整体需求中的“智能问数”内容被映射为清晰的后端/智能体任务。
- 明确哪些能力进入当前智能问数规划，哪些能力后置。
- 新增业务事实确认项覆盖制造订单、质量、异常、SOP。
- 评测集至少包含以下样例：
  - 查询时间段内制造订单准时开工率。
  - 查询时间段内制造订单准时完工率。
  - 查询合格率。
  - 查询废品率。
  - 今天有多少没有处理完的异常。
  - 查询工序任务 XXX 的 SOP 操作指导文件。
  - 查询车间周计划达成率。
  - 查询车间周异常分类统计。
- 不改变当前“先保存用户消息，再用 `userMessageId` 发起 SSE”的链路。
- 不把语音报工报警误并入智能问数。

## 20. 任务卡 016：评测、回归与联调门禁

### 目标

建立后端和智能体上线前的最低质量门禁。

### 范围

做：

- 建立 `agent/evals/cases.yaml`。
- 覆盖工单、库存、设备、制造订单、质量指标、异常统计、SOP 查询、无数据、未知问题、越界问题、提示词注入、SQL 诱导、Skill 停用、数据源不可用、语音失败。
- 建立一键测试命令或脚本。
- 输出阶段验收报告。

不做：

- 不建设完整可视化评测平台。
- 不做人工反馈闭环。

### 涉及文件

- `agent/evals/cases.yaml`
- `backend/tests/test_agent_evals.py`
- `docs/testing/backend-agent-acceptance-report.md`

### 验收命令

```powershell
.\docs\database\run-mysql-verification-in-docker.ps1
python -m pytest backend/tests -q
```

### 通过标准

- 数据库验证通过。
- 后端测试通过。
- 已确认范围内的业务问题稳定返回结构化结果。
- 越界、安全攻击、配置不可用场景不误调用真实工具。

## 21. 业务事实确认清单

这些信息不用你手写代码，但需要你推动业务或架构师确认。未确认前，Codex 只能做 Mock 工具和接口闭环，不能声明真实 MOM 查询完成。

### 工单主题

- 工单主表名称。
- 工单号字段。
- 工单状态字段和状态枚举。
- 创建时间、计划时间、完工时间字段。
- 组织、车间、产线、工位过滤字段。
- 统计“当前工单数量”的默认时间范围。
- 取消、关闭、作废工单是否纳入统计。

### 库存主题

- 物料主数据表名称。
- 库存余额表名称。
- 安全库存字段来源。
- 可用库存、现存量、冻结库存、在途库存的口径。
- 仓库、库位、批次是否需要展示。
- 低于安全库存判断公式。
- 默认返回上限和排序规则。

### 设备主题

- 设备主表名称。
- 停机事件表名称。
- 停机开始时间、结束时间字段。
- 未结束停机如何计算。
- 停机类型、原因字段。
- 设备编码、设备名称、产线字段。
- 默认统计时间范围。

### 通用运行规则

- MOM 数据源只读账号是否可用。
- 默认最大返回行数。
- 单次查询超时时间。
- 是否需要组织/产线级数据过滤。
- 无数据时展示文案。
- 指标版本号 `metricVersion` 初始值。

### 制造订单主题

- 制造订单主表名称。
- 计划开工时间、实际开工时间字段。
- 计划完工时间、实际完工时间字段。
- 准时开工率计算公式。
- 准时完工率计算公式。
- 订单取消、关闭、暂停状态是否纳入。
- 统计维度：车间、产线、工位、产品、班组。
- 默认时间范围。

### 质量指标主题

- 质量检验记录表名称。
- 合格数量、不合格数量、废品数量字段。
- 合格率计算公式。
- 废品率计算公式。
- 返工、让步接收、报废是否计入废品。
- 统计维度：产品、工序、产线、班组、时间。
- 是否按首检、巡检、终检区分。

### 异常统计主题

- 异常记录主表名称。
- 异常状态字段和未处理状态枚举。
- 异常分类字段。
- 异常发生时间、处理完成时间字段。
- “今天未处理完”的时间边界。
- 重复异常或合并异常是否去重。
- 统计维度：车间、设备、工序、异常类型、责任部门。

### SOP 查询主题

- SOP 文档来源：MOM 附件、知识库、DMS、PLM 或文件服务器。
- 工序任务与 SOP 的关联字段。
- SOP 文件版本规则。
- 是否只返回文档摘要，还是返回文档链接。
- 没有 SOP 时的提示文案。
- SOP 是否按角色、工位或产品过滤。

## 22. 立即下一步

下一张任务卡应执行：

**任务卡 001：基准冲突复扫与旧口径清理**

原因：

- 当前后端骨架已经使用 `userMessageId`，但数据库 SQL 和部分 VibeCoding 文档仍有旧口径残留。
- 如果不先清理，后续 Codex 很容易按旧 SQL 生成 Repository 和 Service，返工成本高。

建议直接对 Codex 下发：

```text
按 docs/planning/2026-06-25-vibecoding-backend-agent-task-arrangement.md 的任务卡 001 执行。
只清理后端和数据库文档旧口径，不改前端，不实现业务接口。
完成后运行 rg 复扫、backend pytest 和数据库验证脚本。
```

## 23. 后期投入使用方式

这份文档后期按“主计划 + 任务卡库 + 验收门禁”使用。

### 23.1 每天开工顺序

每天只推进一张任务卡：

1. 打开本文件，确认当前任务卡编号。
2. 打开 `docs/design/MOM智能问数-MVP开发Agent执行约束文档.md`，复核禁止事项。
3. 打开任务卡涉及的接口、数据库或 Redis 文档。
4. 复制第 23 节对应提示词给 Codex。
5. Codex 完成后，用第 24 节验收门禁复审。
6. 复审通过后，再进入下一张任务卡。

### 23.2 任务卡状态

| 状态 | 含义 | 谁来判断 |
| --- | --- | --- |
| `DRAFT` | 任务目标和边界还没定清楚 | 高级架构师窗口 |
| `READY` | 可交给 Codex 执行 | 高级架构师窗口 |
| `IN_PROGRESS` | Codex 正在实现 | 执行窗口 |
| `REVIEW` | 已实现，等待审查 | 高级架构师窗口 |
| `FIXING` | 审查发现问题，正在修复 | 执行窗口 |
| `DONE` | 验收命令通过，范围无扩张 | 高级架构师窗口 |
| `BLOCKED` | 缺业务事实、环境或权限，无法继续 | 高级架构师窗口 + 你本人 |

### 23.3 任务流转规则

- 只有 `READY` 状态的任务卡可以交给 Codex 实现。
- 任务卡从 `IN_PROGRESS` 到 `REVIEW` 前，必须至少跑一次指定验证命令。
- 任务卡进入 `DONE` 前，必须确认没有误做后置能力。
- 如果出现业务事实不明确，任务卡改为 `BLOCKED`，不能让 Codex 猜。
- 如果出现测试失败，先修当前任务，不进入下一任务。

## 24. 可直接复制的 Codex 提示词

### 24.1 开新任务卡

```text
你是 MOM 智能问数 MVP 后端与智能体开发执行 Agent。

本轮执行 docs/planning/2026-06-25-vibecoding-backend-agent-task-arrangement.md 中的【任务卡 XXX】。

执行前必须先读取：
1. docs/design/MOM智能问数-MVP开发Agent执行约束文档.md
2. docs/design/MOM智能问数-MVP全量文档终稿对齐报告.md
3. docs/design/MOM智能问数-MVP接口设计文档.md
4. docs/database/MOM智能问数-MVP数据库设计文档.md
5. docs/database/redis-key-spec.md
6. 当前任务涉及的代码和测试

只做任务卡范围内的后端/智能体内容，不改前端，不实现后置能力。
先列出本轮会改哪些文件和验证命令，再开始改代码。
完成后运行任务卡指定验证命令，并说明实际修改、验证结果、遗留问题。
```

### 24.2 让 Codex 只做方案

```text
先不要改代码。
请按 docs/planning/2026-06-25-vibecoding-backend-agent-task-arrangement.md 的【任务卡 XXX】，
结合当前代码，输出最小实现方案。

必须说明：
1. 本任务对应哪些正式文档章节。
2. 会新增或修改哪些文件。
3. 不做哪些内容。
4. 需要哪些测试。
5. 存在哪些待我确认的问题。
```

### 24.3 让 Codex 直接实现

```text
按 docs/planning/2026-06-25-vibecoding-backend-agent-task-arrangement.md 的【任务卡 XXX】直接实现。

要求：
- 保持最小修改。
- 不改前端。
- 不新增文档外接口、表、Redis Key。
- 不实现外部 API、API Key、多 Agent、用户鉴权、独立结果中心。
- 如果发现文档冲突，先暂停并列出冲突，不要自行发挥。
- 完成后运行任务卡验收命令。
```

### 24.4 让 Codex 做审查

```text
请审查刚完成的【任务卡 XXX】改动。

按以下顺序输出问题：
1. P0：会导致契约错误、数据错误、安全风险或任务无法验收的问题。
2. P1：会导致后续返工、测试缺口或边界不清的问题。
3. P2：命名、文档、可维护性问题。

审查重点：
- 是否误用旧口径、默认 Agent 或问数入口。
- 是否违反 sessionId + userMessageId 幂等。
- 是否在终态 SSE 前完成 MySQL 落库。
- 是否误实现后置能力。
- 是否让 LLM 直接生成或执行 SQL。
- 是否缺少测试。

请给出文件路径和具体行号。
```

### 24.5 让 Codex 修复审查问题

```text
按审查结果修复【任务卡 XXX】。

只修 P0/P1 问题，不做无关重构。
修复后重新运行任务卡验收命令。
如果某个问题需要业务确认，标记为 BLOCKED，不要自行假设。
```

### 24.6 让 Codex 辅助确认业务事实

```text
请基于 docs/planning/2026-06-25-vibecoding-backend-agent-task-arrangement.md 第 21 节，
把【工单 / 库存 / 设备 / 制造订单 / 质量指标 / 异常统计 / SOP 查询】主题需要业务确认的问题整理成可发给业务架构师的确认表。

要求：
- 每个问题都说明为什么要确认。
- 每个问题给出推荐默认口径。
- 标出哪些问题会阻塞真实 MOM 查询工具开发。
- 不写代码。
```

## 25. 验收门禁

每张任务卡完成后，按以下门禁检查。任一 P0 门禁不通过，不允许进入下一张任务卡。

### 25.1 P0 门禁

- [ ] 是否仍遵守 `agentId=default`。
- [ ] 是否仍遵守 `sessionId + userMessageId` 幂等。
- [ ] 是否没有新增旧 DataAgent 问数入口。
- [ ] 是否没有把废弃幂等字段作为正式后端契约。
- [ ] 是否没有实现 `POST /api/v1/agent/invoke`。
- [ ] 是否没有实现 API Key 生成、鉴权、调用统计。
- [ ] 是否没有让 LLM 直接生成并执行 SQL。
- [ ] 是否没有把 Redis 当事实源。
- [ ] 是否没有新增独立结果中心表或接口。
- [ ] 是否通过任务卡指定测试。

### 25.2 P1 门禁

- [ ] API 响应是否统一为 `code/message/data`。
- [ ] 数据库写入是否通过 Repository 或 Service，不在路由中散写 SQL。
- [ ] Agent 回复消息是否保存 `metadata_json.resultPayload`。
- [ ] `resultPayload.chart` 是否为单数。
- [ ] `NO_DATA` 是否作为成功空结果处理。
- [ ] 敏感字段是否加密保存、脱敏回显。
- [ ] Redis Key 是否属于 P0/P1 范围。
- [ ] 语音 ASR 是否不保存原始音频、不自动问数。

### 25.3 最低验证命令

后端任务默认至少运行：

```powershell
python -m pytest backend/tests -q
```

数据库相关任务必须运行：

```powershell
.\docs\database\run-mysql-verification-in-docker.ps1
```

文档口径相关任务必须运行：

```powershell
rg -n "废弃幂等字段|旧问数入口|da_api_access|da:api-key" docs backend agent
```

## 26. 任务交接模板

每次 Codex 完成任务后，要求它按这个格式交接：

```markdown
## 任务交接：任务卡 XXX

### 实际修改

- 文件 1：修改了什么。
- 文件 2：修改了什么。

### 验证结果

- 命令：`...`
- 结果：通过 / 失败
- 关键输出：...

### 契约确认

- agentId=default：是 / 否
- sessionId + userMessageId：是 / 否
- metadata_json.resultPayload：是 / 否
- 未实现后置能力：是 / 否

### 遗留问题

- 无

### 下一步建议

- 建议进入任务卡 XXX。
```

如果存在失败或阻塞，交接必须改为：

```markdown
## BLOCKED

阻塞点：

已尝试：

需要你确认：

不能继续的原因：
```

## 27. 失败处理规则

### 27.1 测试失败

处理顺序：

1. 先读失败输出，不猜。
2. 定位到具体测试和文件。
3. 判断是实现错、测试旧、文档冲突还是环境问题。
4. 只修当前任务范围内的问题。
5. 复跑同一命令。

如果同一错误连续三次失败，停止并交给高级架构师窗口复审。

### 27.2 文档冲突

优先级：

1. `docs/design/MOM智能问数-MVP开发Agent执行约束文档.md`
2. `docs/design/MOM智能问数-MVP全量文档终稿对齐报告.md`
3. `docs/design/MOM智能问数-MVP接口设计文档.md`
4. `docs/database/MOM智能问数-MVP数据库设计文档.md`
5. `docs/database/redis-key-spec.md`
6. `docs/requirements/`
7. `docs/design/MOM智能问数项目方案.md`

如果接口文档和 SQL 脚本冲突，先按执行约束和接口/数据库设计文档判断，再修 SQL 或任务卡，不让代码迁就旧脚本。

### 27.3 环境不可用

如果 MySQL、Redis、模型服务、ASR 服务或 MOM 数据源不可用：

- 能用 Mock 验证的任务继续。
- 需要真实环境的任务标记 `BLOCKED`。
- 不把“环境不可用”包装成代码完成。
- 不用假数据冒充真实 MOM 查询完成。

## 28. 业务事实确认表模板

把下面表格复制给业务架构师或数据负责人即可。

### 28.1 工单状态统计

| 问题 | 推荐默认口径 | 是否阻塞真实查询 |
| --- | --- | --- |
| 工单主表是哪张表？ | 使用 MOM 工单主表 | 是 |
| 工单状态字段是哪一个？ | 使用业务侧展示状态字段 | 是 |
| 状态枚举有哪些？ | 运行、完工、暂停、关闭、取消等以业务确认为准 | 是 |
| 统计“当前工单”是否限制时间范围？ | 默认不限制时间，只统计未完结有效工单 | 是 |
| 取消/作废工单是否纳入？ | 默认不纳入 | 是 |
| 是否按组织/车间/产线过滤？ | 默认按当前用户可见组织过滤；MVP 无用户体系时先按默认组织或不过滤 | 是 |
| 返回是否需要明细？ | 默认返回状态汇总，必要时返回 Top 明细 | 否 |

### 28.2 低于安全库存物料

| 问题 | 推荐默认口径 | 是否阻塞真实查询 |
| --- | --- | --- |
| 库存余额表是哪张？ | 使用 MOM 实时库存或库存余额表 | 是 |
| 安全库存字段来自哪里？ | 优先物料-仓库维度安全库存 | 是 |
| 低库存判断公式是什么？ | 可用库存 < 安全库存 | 是 |
| 可用库存是否扣除冻结库存？ | 默认扣除冻结库存 | 是 |
| 是否包含在途库存？ | 默认不包含，除非业务确认 | 是 |
| 是否按仓库/库位/批次展示？ | 默认按物料 + 仓库汇总 | 否 |
| 返回排序规则？ | 默认按缺口数量倒序 | 否 |

### 28.3 设备停机时长分析

| 问题 | 推荐默认口径 | 是否阻塞真实查询 |
| --- | --- | --- |
| 设备主表是哪张？ | 使用 MOM 设备主数据表 | 是 |
| 停机事件表是哪张？ | 使用设备停机/故障事件表 | 是 |
| 停机开始和结束字段是什么？ | 使用事件开始/结束时间 | 是 |
| 未结束停机如何计算？ | 默认结束时间为空时按当前时间计算 | 是 |
| 默认统计时间范围？ | 默认最近 7 天或当天，需要业务确认 | 是 |
| 停机类型是否过滤？ | 默认统计全部非计划停机，需要业务确认 | 是 |
| 是否按设备、产线、原因分组？ | 默认设备维度汇总，支持原因 Top | 否 |

### 28.4 制造订单准时率

| 问题 | 推荐默认口径 | 是否阻塞真实查询 |
| --- | --- | --- |
| 制造订单主表是哪张？ | 使用 MOM 制造订单或生产订单主表 | 是 |
| 计划/实际开工字段是什么？ | 使用计划开始时间、实际开始时间 | 是 |
| 计划/实际完工字段是什么？ | 使用计划完成时间、实际完成时间 | 是 |
| 准时开工率公式？ | 实际开工时间 <= 计划开工时间 的订单数 / 应开工订单数 | 是 |
| 准时完工率公式？ | 实际完工时间 <= 计划完工时间 的订单数 / 应完工订单数 | 是 |
| 取消/关闭订单是否纳入？ | 默认不纳入 | 是 |
| 默认统计维度？ | 车间 + 周期 | 否 |

### 28.5 质量指标

| 问题 | 推荐默认口径 | 是否阻塞真实查询 |
| --- | --- | --- |
| 质量检验记录表是哪张？ | 使用 MOM 质检结果表 | 是 |
| 合格数量字段是什么？ | 使用合格数量或 OK 数量 | 是 |
| 不合格/废品数量字段是什么？ | 使用 NG 数量和报废数量，以业务确认为准 | 是 |
| 合格率公式？ | 合格数量 / 检验总数量 | 是 |
| 废品率公式？ | 废品数量 / 生产或检验总数量 | 是 |
| 返工是否计入不合格？ | 默认不计入废品，需要业务确认 | 是 |
| 默认统计维度？ | 车间、产线、产品、时间 | 否 |

### 28.6 异常统计

| 问题 | 推荐默认口径 | 是否阻塞真实查询 |
| --- | --- | --- |
| 异常主表是哪张？ | 使用 MOM 异常/报警/问题记录表 | 是 |
| 未处理状态有哪些？ | 新建、处理中、待确认等以业务确认为准 | 是 |
| 今天的时间边界？ | 服务器本地日期 00:00:00 到当前时间 | 是 |
| 异常分类字段是什么？ | 使用业务侧异常类型字段 | 是 |
| 重复异常是否去重？ | 默认不去重，按记录数统计 | 是 |
| 默认展示方式？ | 数量指标 + 分类饼图/柱状图 | 否 |

### 28.7 SOP 查询

| 问题 | 推荐默认口径 | 是否阻塞真实查询 |
| --- | --- | --- |
| SOP 数据源在哪里？ | 优先当前系统知识库；若来自 DMS/PLM 则后置集成 | 是 |
| 工序任务如何关联 SOP？ | 工序编码/产品编码/版本号关联 | 是 |
| 返回内容形式？ | 默认返回摘要 + 文档链接，不直接返回完整文档 | 是 |
| SOP 版本选择规则？ | 默认返回当前生效版本 | 是 |
| 没有 SOP 时如何提示？ | 返回 `NO_DATA` 成功空结果和可操作提示 | 否 |
| 是否按角色/工位过滤？ | MVP 默认不做权限体系，正式落地前需确认 | 是 |

## 29. 建议的实际推进顺序

最稳妥的推进顺序如下：

1. 先执行任务卡 001，清掉旧口径。
2. 执行任务卡 002，确认后端契约骨架完整。
3. 执行任务卡 003 和 004，把 MySQL/Redis 基础打通。
4. 执行任务卡 005、006、007，先用 Mock 跑通完整问数闭环。
5. 并行推动第 28 节业务事实确认。
6. 业务事实确认后，再执行任务卡 011、012、013。
7. 语音任务卡 014 可在文本闭环稳定后单独推进。
8. 执行任务卡 015，把 ZHGC 整体需求中的智能问数范围扩展为评测和业务事实确认项。
9. 最后执行任务卡 016，形成上线前门禁。

不要跳过任务卡 001。当前项目最容易返工的点不是代码难，而是旧文档和旧 SQL 残留会把 Codex 带回旧契约。
