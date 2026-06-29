# MOM智能问数-MVP开发Agent执行约束文档

## 1. 文档定位

本文档面向后续参与 MOM 智能问数 MVP 开发的 Coding Agent、研发人员和测试人员使用。

本文档不是新的需求文档，也不是新的接口设计文档。它的作用是把已确认的 MVP 边界、开发读取顺序、禁止推导事项和实现约束集中写清楚，避免开发 Agent 在生成代码、接口、数据库脚本、前端页面或测试用例时产生歧义、幻觉和范围扩张。

开发 Agent 执行任何任务前，必须先读取本文档，再读取正式需求、接口、数据库和 Redis 文档。若本文档与其他文档出现理解差异，以本文档约束开发行为，并回到终稿对齐报告和接口设计文档确认。

## 2. 适用范围

本文档适用于以下开发活动：

| 开发活动 | 是否适用 |
| --- | --- |
| FastAPI 后端接口开发 | 是 |
| Pydantic 请求/响应模型生成 | 是 |
| SQLAlchemy 模型与 Alembic 迁移脚本生成 | 是 |
| Redis Key、锁、幂等、限流和 SSE 运行态实现 | 是 |
| 前端接口调用、页面状态和联调任务拆分 | 是 |
| Pytest、接口测试、端到端联调用例生成 | 是 |
| Agent 问数运行链路代码实现 | 是 |
| DataAgent 源码能力迁移 | 仅可参考，不可照搬 |
| 外部 API、API Key、用户鉴权、多 Agent、多数据源路由 | 不适用，均为后置 |

## 3. 开发 Agent 读取顺序

开发 Agent 必须按以下顺序读取文档：

| 顺序 | 文档 | 使用方式 |
| --- | --- | --- |
| 0 | `MOM智能问数-MVP开发Agent执行约束文档.md` | 先确认开发边界、禁止事项和任务执行规则。 |
| 1 | `MOM智能问数-MVP全量文档终稿对齐报告.md` | 确认终稿口径、后置项、已关闭问题和 Coding Agent 约束。 |
| 2 | `../requirements/MOM智能问数-MVP管理侧需求规格文档.md` | 确认管理侧功能范围、页面动作、验收标准。 |
| 3 | `../requirements/MOM智能问数-MVP用户侧需求规格文档.md` | 确认用户侧运行页、会话、语音、问数和结果展示。 |
| 4 | `数据库&接口/MOM智能问数-MVP接口设计文档.md` | 作为接口路径、请求、响应、状态枚举和联调流程的直接契约。 |
| 5 | `数据库&接口/MOM智能问数-MVP数据库设计文档.md` | 作为 MySQL 表、字段、索引、状态和落库职责的直接契约。 |
| 6 | `数据库&接口/redis-key-spec.md` | 作为 Redis Key、TTL、锁、幂等、SSE 缓冲和安全边界的直接契约。 |
| 7 | `MOM智能问数项目方案.md` | 只作为业务背景和阶段演进方向，不作为 MVP 实现清单。 |

禁止开发 Agent 只读取项目方案后直接开发。项目方案中的长期能力不得绕过需求、接口和数据库文档直接进入 MVP 实现。

## 4. 总体执行原则

1. 只实现文档明确标记为 MVP、确认实现、P0、P1 且未被后置排除的内容。
2. 不因为技术栈、项目方案或 DataAgent 源码中存在某能力，就推导本项目 MVP 必须实现该能力。
3. 不自动补充接口、表、Redis Key、页面入口、菜单、按钮、字段和运行模式。
4. 不把“后置”“仅保留设计说明”“不进入 MVP 开发和联调”的内容生成代码。
5. 不把接口改造成自己认为更标准的 RESTful 风格；接口路径、动作名和字段名以接口设计文档为准。
6. 不把数据库 P1 理解为后置。数据库表只要在总览中标记“是否进入 MVP=是”，无论 P0/P1，均属于 MVP 范围。
7. 遇到文档未定义的业务行为，必须停止推导并标记为待确认，不得自行设计。

## 5. MVP 固定口径

| 主题 | 固定口径 |
| --- | --- |
| Agent | MVP 只存在一个默认 Agent，固定 `agentId=default`。 |
| 用户 | MVP 固定默认用户，不建设登录、注册、用户鉴权、租户和权限体系。 |
| 数据源 | 默认 Agent 只绑定一个生效 MOM 数据源，不做多数据源路由。 |
| 产品库 | MVP 只服务 MOM 库中已确认的工单、库存、设备主题，不接 ERP、APS 等其他产品库。 |
| 系统提示词 | 系统提示词内置，不开放用户编辑，不建设提示词配置页或提示词版本管理接口。 |
| 访问 API | 外部 API、API Key、`X-API-Key`、调用统计和访问 API 页面均为后置，不进入 MVP 开发和联调。 |
| 语音问数 | 语音只作为输入辅助；前端上传 WAV，后端 ASR 代理返回文本，用户手动发送。 |
| 问数入口 | 发送按钮或回车发送是唯一进入问数链路的用户提交动作。 |
| 暂停会话 | 只中止当前流式问数任务，不删除会话，不阻止后续继续提问。 |
| 结果保存 | 最终结果保存在 Agent 回复消息 `metadata.resultPayload` / `metadata_json.resultPayload`。 |
| 结果结构 | `resultPayload` 使用 `table`、`indicators`、`chart`、`notice`，其中 `chart` 为单数。 |
| Redis | Redis 只做短期运行态、锁、幂等、限流、SSE 缓冲、暂停信号和任务状态缓存，不做事实源。 |
| MySQL | MySQL 是配置、会话、消息、幂等台账、最终结果和任务最终状态的事实来源。 |

## 6. 允许实现清单

### 6.1 管理侧允许实现

| 模块 | 允许实现内容 |
| --- | --- |
| 默认 Agent | 查询默认 Agent、展示运行状态和配置完整性。 |
| 模型配置 | LLM、Embedding 配置保存、修改、测试、切换生效。 |
| 数据源配置 | MOM 数据源保存、修改、连接测试、绑定当前生效数据源、Schema 初始化、表范围配置。 |
| Skill 管理 | ZIP 导入、安装状态、删除、启用、停用、测试，默认 Agent 仅调用已启用 Skill。 |
| 智能体知识 | 文档、问答对、FAQ 管理，召回开关、重试向量化、召回测试。 |
| 业务知识 | 业务术语、描述、同义词管理，启停、召回开关、重试向量化、召回测试。 |
| 语义模型 | 表字段业务映射，新增、编辑、删除、启停、Excel 导入。 |
| 预设问题 | 新增、编辑、排序、启停，用户侧展示为推荐问题。 |
| 语音输入配置 | ASR 供应商、地址、模型、密钥、语言、文件大小、录音时长、超时、支持格式配置；敏感字段加密保存、脱敏回显。 |

### 6.2 用户侧允许实现

| 模块 | 允许实现内容 |
| --- | --- |
| 运行页 | 默认 Agent 状态、历史会话区、推荐问题区、输入区和结果展示区。 |
| 会话管理 | 会话列表、新建会话、修改标题、置顶、删除、切换历史会话。 |
| 会话展示 | 展示用户消息、Agent 回复、处理中、成功、失败、已暂停状态。 |
| 推荐问题 | 读取管理侧启用的预设问题，点击后进入普通问数流程。 |
| 文本问数 | 先保存用户消息，再通过 `userMessageId` 发起 SSE 问数。 |
| 暂停问数 | 调用 `POST /api/stream/stop` 停止当前 `threadId` 对应任务。 |
| 语音输入 | 调用 `GET /api/voice/config` 获取非敏感配置；上传 WAV 到 `POST /api/voice/asr`；识别文本填入输入框；用户手动发送。 |
| 结果展示 | 展示文本、Markdown、安全结构化结果、表格、指标卡、饼图、折线图、柱状图和运行提示。 |

### 6.3 数据库允许实现

只实现数据库设计文档中“是否进入 MVP=是”的表。

P0 必须优先实现，P1 跟随主链路补齐。P1 不是后置。

| 类型 | 允许实现 |
| --- | --- |
| 管理侧配置表 | `da_agent`、`da_model_config`、`da_datasource_config`、`da_schema_table`、`da_schema_column`、`da_table_scope`、`da_skill_config`、`da_metric_definition`、`da_agent_knowledge`、`da_business_term`、`da_semantic_field`、`da_preset_question`、`da_voice_config` |
| 用户侧运行表 | `da_session`、`da_chat_request_ledger`、`da_message` |
| 任务与审计表 | `da_schema_init_task`、`da_vector_task`、`da_audit_log` |

### 6.4 Redis 允许实现

只实现 Redis Key 规范中的 P0、P1 Key。

| 优先级 | 允许实现 |
| --- | --- |
| P0 | `da:runtime:config:{agentId}`、`da:chat:idempotent:{sessionId}:{userMessageId}`、`da:chat:lock:{sessionId}`、`da:stream:active:{threadId}`、`da:stream:stop:{threadId}`、`da:stream:events:{threadId}` |
| P1 | `da:rate:voice:{sessionId}:{clientIp}`、`da:schema-task:{taskId}`、`da:vector-task:{taskId}`、`da:agent:availability:{agentId}` |

## 7. 禁止实现清单

以下内容不得在 MVP 中生成代码、接口、表、页面入口、菜单、按钮、Redis Key 或测试用例：

| 禁止项 | 说明 |
| --- | --- |
| 多 Agent | 不做 Agent 创建、复制、删除、切换、发布、市场化管理。 |
| 多数据源路由 | 不做多个生效数据源，不做跨数据源 Join，不做 ERP/APS 等其他产品库。 |
| 用户鉴权 | 不做登录、注册、用户管理、角色权限、租户、用户级限流。 |
| 外部 API | 不实现 `POST /api/v1/agent/invoke`，不实现 API Key 生成、重置、删除、启停、鉴权和调用统计。 |
| 访问 API 页面 | MVP 完全隐藏，不做灰态展示。 |
| 系统提示词编辑 | 不做提示词配置页、提示词版本表、提示词编辑接口。 |
| 独立结果中心 | 不实现 `da_query_result`、`da_table_result`、`da_indicator_result`、`da_chart_result`、`da_runtime_notice`。 |
| 独立语音记录 | 不实现 `da_voice_record`，不保存原始音频，不保存独立语音识别记录。 |
| DataAgent 运行选项 | 不实现 `humanFeedback`、`humanFeedbackContent`、`rejectedPlan`、`nl2sqlOnly`、人工审核、人工反馈、拒绝计划。 |
| GraphRAG/知识图谱 | 技术栈中出现 Neo4j 不代表 MVP 要建设 GraphRAG、知识图谱能力或图查询接口。 |
| 报告中心 | 不做报告中心、报告发布、报告订阅、报告管理。 |
| 智能归因 | 不做复杂归因、原因候选、证据链、影响范围、建议动作闭环。 |
| 评测平台 | 不做完整评测平台、客户场景覆盖矩阵、人工反馈闭环。 |
| 前端任务查询 | Schema 初始化和向量化任务状态为后端内部状态，MVP 不提供前端任务查询接口。 |
| 调试信息外显 | 用户侧默认不展示 SQL、Python、原始 HTML，不直接执行或原样渲染。 |

## 8. 接口实现约束

### 8.1 接口状态约束

开发 Agent 只能实现接口设计文档中状态为“确认实现”的接口。

状态为“MVP 不实现，仅保留设计说明”“后置”“不进入 MVP 开发和联调”的接口不得生成路由、服务、测试或前端调用。

### 8.2 路径和命名约束

1. 接口路径按接口设计文档实现，不得自动改造成纯 RESTful 风格。
2. `/add`、`/query/page`、`/activate/{id}` 等动作接口保持契约优先。
3. 生成 OpenAPI、Pydantic、前端类型或路由代码时，泛化 `{id}` 必须映射为具体业务标识，例如 `modelConfigId`、`datasourceId`、`sessionId`、`messageId`。
4. 响应结构统一使用 `code/message/data`。
5. 分页接口在 `code/message/data` 基础上扩展分页字段。

### 8.3 会话和问数链路约束

用户侧问数必须按以下顺序实现：

1. 前端调用 `POST /api/sessions/{sessionId}/messages` 保存用户消息。
2. 后端返回 `userMessageId`。
3. 前端调用 `GET /api/stream/search?agentId=default&sessionId={sessionId}&threadId={sessionId}&userMessageId={userMessageId}` 发起 SSE。
4. 后端创建 Agent 回复消息，状态为 `PROCESSING`。
5. SSE 返回 `start`、`message`、`complete`、`stopped`、`error` 事件。
6. `complete/stopped/error` 终态事件发送前，后端必须先完成 MySQL 消息状态和最终结果落库。
7. 历史会话回显以 MySQL 中的消息和 `metadata_json.resultPayload` 为准。

禁止在 `GET /api/stream/search` 中直接传 `query` 作为正式问题来源。

### 8.4 幂等约束

1. 问数幂等键为 `sessionId + userMessageId`。
2. 同一用户消息只能对应一条 Agent 回复消息和一个问数任务。
3. 浏览器重试、SSE 断线重连、用户重复点击不得重复创建 Agent 回复消息。
4. 若 MySQL 已有 `SUCCESS`、`FAILED`、`STOPPED` 终态，不得重复执行问数。
5. Redis 幂等缓存只做性能优化，不能替代 MySQL 请求台账。

### 8.5 暂停约束

1. 暂停接口为 `POST /api/stream/stop`。
2. 暂停只影响当前 `threadId` 对应的流式任务。
3. 暂停不删除会话，不清空消息，不阻止用户继续发送新问题。
4. 后端通过 Redis Stop Flag 通知 Agent 执行链路停止。
5. 最终 `STOPPED` 状态必须落到 MySQL 的消息和请求台账中。

## 9. 语音实现约束

1. 语音输入是 MVP 必做能力，但只作为输入辅助。
2. 前端负责录音并转换为 WAV 后上传。
3. 后端通过 `POST /api/voice/asr` 接收 WAV，代理调用 ASR 服务。
4. ASR `apiKey`、`secretKey` 等长期密钥只在后端加密保存和使用，不下发前端。
5. `POST /api/voice/asr` 只返回识别文本，不创建会话消息，不调用问数接口。
6. 用户必须手动点击发送按钮或回车发送，才能进入问数链路。
7. 发送后的用户消息 `inputType=VOICE`。
8. 后端不保存原始音频，不保存独立语音识别记录。
9. 语音失败、超时、超限、识别为空、配置不可用时，不进入问数链路。
10. 语音识别限流按 `sessionId + clientIp` 处理，`clientIp` 不得直接信任客户端伪造请求头。

## 10. 结果 Payload 约束

### 10.1 结构约束

最终结果统一保存到 Agent 回复消息：

```json
{
  "resultPayload": {
    "resultType": "TABLE",
    "resultStatus": "SUCCESS",
    "textAnswer": "查询结果说明",
    "table": {},
    "indicators": [],
    "chart": null,
    "notice": null
  }
}
```

### 10.2 字段约束

| 字段 | 约束 |
| --- | --- |
| `table` | 单个表格结果对象，可为空。 |
| `indicators` | 指标卡数组，可为空。 |
| `chart` | 单个图表对象，可为空；字段名必须是单数 `chart`。 |
| `notice` | 运行提示对象，可为空。 |
| `total/limit/truncated` | 大表格结果必须返回展示上限信息。 |

禁止使用 `charts` 作为正式结果字段。

## 11. 数据库实现约束

1. 表前缀 `da_` 表示智能问数系统表，不表示 DataAgent 系统表。
2. MySQL 是事实来源，Redis 不是事实来源。
3. 敏感字段必须加密保存，接口只允许脱敏回显或返回是否已配置。
4. `metadata_json` 保存 JSON 时必须由应用层校验结构。
5. Agent 回复消息中的 `metadata_json.resultPayload` 必须与 SSE `complete.resultPayload` 保持同一份业务结构。
6. `da_chat_request_ledger` 是问答幂等事实来源。
7. `da_schema_init_task`、`da_vector_task` 只是后端内部任务状态，不代表前端有任务查询接口。
8. `da_metric_definition` 是后端内置运行校验表，由初始化脚本维护，MVP 不提供指标口径管理接口。
9. `agent_id` 字段只用于默认 Agent 归属和后续扩展预留，不代表 MVP 支持多 Agent。
10. 不创建后置表，除非后续评审重新确认。

## 12. Redis 实现约束

1. Redis 中缓存的数据必须能从 MySQL 或外部服务恢复。
2. Redis 不保存模型 API Key、ASR 密钥、数据源密码、完整连接串、外部 API Key。
3. Redis 不保存原始音频、独立语音识别记录、独立结果中心数据。
4. Redis Stream 只用于短期 SSE 事件缓冲和短期断线恢复。
5. Redis Active Task 只保存运行中任务状态。
6. Redis Stop Flag 只表达暂停信号。
7. Redis 任务状态缓存只用于后端内部观测、日志排查和失败恢复。
8. Redis 后置 Key 不得在 MVP 中出现。

## 13. DataAgent 使用边界

DataAgent 只能作为流程经验参考，不作为本项目接口、数据库、页面或功能范围的确认依据。

允许参考：

| 参考内容 | 使用方式 |
| --- | --- |
| 问数链路编排思路 | 可用于理解 Agent 运行过程。 |
| Schema 初始化流程 | 可参考库表字段拉取和统计返回方式。 |
| 知识向量化流程 | 可参考文档解析、分块、向量化状态管理。 |
| SSE/暂停/断线处理经验 | 可参考工程处理思路。 |

禁止照搬：

| 禁止内容 | 原因 |
| --- | --- |
| DataAgent Controller 路径 | 本项目接口按 FastAPI 契约设计。 |
| DataAgent 响应结构 | 本项目统一 `code/message/data`。 |
| DataAgent 运行参数 | `humanFeedback`、`nl2sqlOnly`、`rejectedPlan` 等不进入 MVP。 |
| DataAgent 多 Agent 能力 | MVP 固定默认 Agent。 |
| DataAgent 前端保存结果方式 | 本项目由后端在终态事件前兜底落库。 |

## 14. 技术栈理解边界

文档中出现 FastAPI、Starlette、Uvicorn、SQLAlchemy、Alembic、Pytest、PyMilvus、Redis、RustFS、Neo4j、LangGraph、LlamaIndex 等技术栈时，只能按当前需求、接口和数据库契约实现。

禁止根据技术栈自行推导：

1. Neo4j 不等于 MVP 必须建设知识图谱。
2. Neo4j 不等于 MVP 必须建设 GraphRAG。
3. LangGraph 不等于 MVP 必须建设额外编排管理平台。
4. LlamaIndex 不等于 MVP 必须开放通用数据接入平台。
5. PyMilvus 不等于所有语义配置都要进向量库；语义模型是结构化字段映射。

## 15. 不确定信息处理规则

开发 Agent 遇到以下情况时，不得自行发挥：

| 情况 | 正确处理 |
| --- | --- |
| 文档没有定义某接口 | 不生成接口，标记待确认。 |
| 文档没有定义某字段 | 不补字段，先查接口和数据库文档；仍无定义则标记待确认。 |
| 需求文档和接口文档看起来不一致 | 先按终稿对齐报告和接口设计文档判断，再列出冲突点，不直接实现。 |
| 项目方案提到能力但接口/数据库未确认 | 视为后续演进，不进入 MVP。 |
| 技术实现需要额外表或 Redis Key | 先确认是否已有对应表或 Key；没有则标记设计缺口，不自行创建。 |
| 想优化为更标准架构 | 不做。MVP 优先契约一致、范围稳定和可联调。 |
| 想补安全、权限、审计增强能力 | 只做文档明确的安全约束；权限、租户、外部 API 鉴权均后置。 |

## 16. 开发任务固定提示词模板

后续把任务交给开发 Agent 时，建议统一使用以下开头：

```text
你是 MOM 智能问数 MVP 开发 Agent。执行本任务前，必须先读取：
1. docs/design/MOM智能问数-MVP开发Agent执行约束文档.md
2. docs/design/MOM智能问数-MVP全量文档终稿对齐报告.md
3. 与当前任务直接相关的需求、接口、数据库或 Redis 文档。

只实现接口文档中状态为“确认实现”的内容。
所有标记为“后置”“MVP 不实现”“仅保留设计说明”“不进入 MVP 开发和联调”的内容不得生成代码。
不得从 DataAgent 直接搬运接口、字段、运行参数或多 Agent 能力。
不得自行新增接口、表、Redis Key、页面入口或运行模式。
如果遇到文档未定义或互相冲突的内容，先列出待确认问题，不要自行补全。
```

## 17. 生成代码前检查清单

开发 Agent 生成代码前必须确认：

| 检查项 | 通过标准 |
| --- | --- |
| 是否读取本文档 | 已读取并遵守禁止清单。 |
| 是否读取终稿对齐报告 | 已确认 MVP 边界和后置项。 |
| 是否只实现确认范围 | 接口状态为“确认实现”，数据库表进入 MVP，Redis Key 属于 P0/P1。 |
| 是否避开后置能力 | 未实现外部 API、API Key、用户鉴权、多 Agent、多数据源、独立结果中心。 |
| 是否遵守问数链路 | 先保存用户消息，再用 `userMessageId` 发起 SSE。 |
| 是否遵守落库时机 | 终态 SSE 事件前完成 MySQL 状态和最终结果落库。 |
| 是否遵守语音边界 | 语音只返回文本，不自动问数，不保存原始音频。 |
| 是否遵守 Redis 边界 | Redis 不保存密钥和事实结果。 |
| 是否遵守字段名 | 使用正式字段，不使用未确认别名。 |
| 是否遇到不确定点 | 如有，已列为待确认，未自行实现。 |

## 18. 生成结果验收清单

开发 Agent 完成任务后，必须在交付说明中明确：

1. 本次实现对应哪些正式文档章节。
2. 本次实现的接口、表、Redis Key 是否均属于确认实现范围。
3. 是否触碰后置能力；如果触碰，必须说明并回退。
4. 是否新增了文档外字段、接口、表或 Key；默认不得新增。
5. 是否完成对应测试或最小验证。
6. 是否存在待人工确认问题。

## 19. 最终约束

MOM 智能问数 MVP 当前目标不是做一个完整智能数据平台，而是跑通一个默认 Agent 在一个生效 MOM 数据源上的管理配置、用户问数、语音输入、会话留痕和结果展示闭环。

开发 Agent 的任务是按已确认契约稳定落地，不是扩展产品范围。

任何看起来“顺手可以做”的增强能力，只要文档没有明确纳入 MVP，都必须按后置处理。
