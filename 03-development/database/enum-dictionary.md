# MOM 智能问数 MVP 枚举字典

本文档用于统一数据库、后端和前端对 MVP 阶段枚举值的理解。事实来源为 `MOM智能问数-MVP数据库设计文档.md`、`001_mvp_schema.sql` 和 `002_mvp_seed_data.sql`。

## 1. 通用布尔标记

| 字段 | 取值 | 含义 | 使用位置 |
| --- | --- | --- | --- |
| `enabled_flag` | `0` | 禁用 | 模型、数据源、Skill、预设问题、语音配置等 |
| `enabled_flag` | `1` | 启用 | 模型、数据源、Skill、预设问题、语音配置等 |
| `deleted_flag` | `0` | 未删除 | 支持软删除的配置表 |
| `deleted_flag` | `1` | 已删除 | 支持软删除的配置表 |
| `default_flag` | `0` | 非默认 | `da_model_config`、`da_metric_definition` |
| `default_flag` | `1` | 默认 | `da_model_config`、`da_metric_definition` |
| `active_flag` | `0` | 非当前生效数据源 | `da_datasource_config` |
| `active_flag` | `1` | 当前生效数据源 | `da_datasource_config` |
| `readonly_flag` | `0` | 非只读，MVP 不建议用于问数 | `da_datasource_config` |
| `readonly_flag` | `1` | 只读数据源 | `da_datasource_config` |
| `dangerous_sql_block_flag` | `0` | 不拦截危险 SQL，MVP 不建议关闭 | `da_datasource_config` |
| `dangerous_sql_block_flag` | `1` | 拦截写操作和危险 SQL | `da_datasource_config` |
| `in_query_scope` | `0` | 不纳入问数范围 | `da_table_scope` |
| `in_query_scope` | `1` | 纳入问数范围 | `da_table_scope` |
| `is_core_table` | `0` | 非核心表 | `da_table_scope` |
| `is_core_table` | `1` | 核心问数表 | `da_table_scope` |
| `recall_flag` | `0` | 不参与召回 | `da_agent_knowledge`、`da_business_term` |
| `recall_flag` | `1` | 参与召回 | `da_agent_knowledge`、`da_business_term` |
| `pinned_flag` | `0` | 未置顶 | `da_session` |
| `pinned_flag` | `1` | 已置顶 | `da_session` |

## 2. Agent 与配置枚举

| 枚举字段 | 取值 | 含义 | 约束 |
| --- | --- | --- | --- |
| `da_agent.agent_status` | `ENABLED` | Agent 可用 | MVP 默认 Agent 使用该状态 |
| `da_agent.agent_status` | `DISABLED` | Agent 禁用 | 禁用后后端不得进入问数链路 |
| `da_model_config.model_category` | `LLM` | 对话大模型 | 同一 Agent 同一类别只能有一个启用默认配置 |
| `da_model_config.model_category` | `EMBEDDING` | 向量模型 | 用于知识和术语向量化 |
| `da_model_config.provider` | `OPENAI_COMPATIBLE` | OpenAI 兼容模型服务 | seed 使用占位配置，真实密钥必须加密落库 |
| `da_model_config.request_mode` | `STREAM` | 流式调用 | LLM 默认使用 |
| `da_model_config.request_mode` | `NON_STREAM` | 非流式调用 | Embedding 默认使用 |
| `da_model_config.test_status` | `UNTESTED` | 未测试 | seed 默认值 |
| `da_model_config.test_status` | `SUCCESS` | 测试成功 | 由后端测试连接后写入 |
| `da_model_config.test_status` | `FAILED` | 测试失败 | 需写入脱敏失败信息 |

## 3. 数据源与 Schema 枚举

| 枚举字段 | 取值 | 含义 | 约束 |
| --- | --- | --- | --- |
| `da_datasource_config.datasource_type` | `MYSQL` | MySQL 业务数据源 | seed 默认值 |
| `da_datasource_config.datasource_type` | `DM` | 达梦业务数据源 | 仅指外部 MOM 业务库类型，不是系统自身库 |
| `da_datasource_config.datasource_type` | `ORACLE` | Oracle 业务数据源 | 待后端连接器支持 |
| `da_datasource_config.datasource_type` | `SQLSERVER` | SQL Server 业务数据源 | 待后端连接器支持 |
| `da_datasource_config.datasource_type` | `POSTGRESQL` | PostgreSQL 业务数据源 | 待后端连接器支持 |
| `da_datasource_config.connect_status` | `UNTESTED` | 未测试 | seed 默认值 |
| `da_datasource_config.connect_status` | `SUCCESS` | 连接成功 | 不得暴露完整连接串 |
| `da_datasource_config.connect_status` | `FAILED` | 连接失败 | 失败信息必须脱敏 |
| `da_datasource_config.schema_init_status` | `NOT_INITIALIZED` | 未初始化 Schema | seed 默认值 |
| `da_datasource_config.schema_init_status` | `PROCESSING` | 初始化中 | 可配合 `da_schema_init_task` 记录 |
| `da_datasource_config.schema_init_status` | `SUCCESS` | 初始化成功 | Schema 缓存可用于问数 |
| `da_datasource_config.schema_init_status` | `FAILED` | 初始化失败 | 需保留失败信息 |
| `da_schema_table.table_type` | `TABLE` | 物理表 | 从外部业务库同步 |
| `da_schema_table.table_type` | `VIEW` | 视图 | 从外部业务库同步 |

## 4. Skill、指标和预设问题枚举

| 枚举字段 | 取值 | 含义 | 约束 |
| --- | --- | --- | --- |
| `da_skill_config.source_type` | `BUILT_IN` | 内置工具 | MVP 三个 Skill 均为内置 |
| `da_skill_config.source_type` | `IMPORTED` | 导入工具 | 后置能力，MVP 不建议开放 |
| `da_skill_config.test_status` | `UNTESTED` | 未测试 | seed 默认值 |
| `da_skill_config.test_status` | `SUCCESS` | 测试成功 | 工具可被编排调用 |
| `da_skill_config.test_status` | `FAILED` | 测试失败 | 不应进入可调用工具列表 |
| `da_skill_config.skill_code` | `WORK_ORDER_STATUS_STAT` | 工单状态统计 | 对应 `workOrderStatusSummary` |
| `da_skill_config.skill_code` | `LOW_STOCK_QUERY` | 低安全库存查询 | 对应 `inventoryBelowSafetyStock` |
| `da_skill_config.skill_code` | `EQUIPMENT_DOWNTIME_STAT` | 设备停机统计 | 对应 `equipmentDowntimeSummary` |
| `da_skill_config.tool_name` | `workOrderStatusSummary` | 工单状态统计工具 | 启用且未删除时同一 Agent 唯一 |
| `da_skill_config.tool_name` | `inventoryBelowSafetyStock` | 低安全库存工具 | 启用且未删除时同一 Agent 唯一 |
| `da_skill_config.tool_name` | `equipmentDowntimeSummary` | 设备停机统计工具 | 启用且未删除时同一 Agent 唯一 |
| `da_metric_definition.status` | `DRAFT` | 草稿 | 不可作为问数事实口径 |
| `da_metric_definition.status` | `PUBLISHED` | 已发布 | `PUBLISHED + default_flag=1` 才是默认可调用口径 |
| `da_metric_definition.status` | `DISABLED` | 停用 | 不可作为问数事实口径 |
| `da_preset_question.display_scene` | `HOME` | 首页展示 | seed 默认值 |
| `da_preset_question.display_scene` | `INPUT` | 输入框推荐 | 可用于后续扩展 |

## 5. 消息与问答台账枚举

| 枚举字段 | 取值 | 含义 | 约束 |
| --- | --- | --- | --- |
| `da_message.message_role` | `USER` | 用户消息 | 用户主动发送后落库 |
| `da_message.message_role` | `AGENT` | Agent 回复 | 最终结果保存在 `metadata_json.resultPayload` |
| `da_message.message_role` | `SYSTEM` | 系统消息 | MVP 保留，不建议前端直接创建 |
| `da_message.input_type` | `TEXT` | 文本输入 | 普通问数 |
| `da_message.input_type` | `VOICE` | 语音识别文本输入 | ASR 只做辅助，用户发送识别文本后才落库 |
| `da_message.input_type` | `PRESET_QUESTION` | 预设问题输入 | 点击预设问题后落库 |
| `da_message.input_type` | `SYSTEM` | 系统输入 | 仅系统内部使用 |
| `da_message.message_status` | `PROCESSING` | 处理中 | Agent 回复生成中 |
| `da_message.message_status` | `SUCCESS` | 成功 | 最终结果已落库 |
| `da_message.message_status` | `FAILED` | 失败 | 需写入脱敏错误信息 |
| `da_message.message_status` | `STOPPED` | 已暂停 | 用户暂停后最终状态 |
| `da_chat_request_ledger.input_type` | `TEXT` | 文本问数请求 | 与用户消息输入类型一致 |
| `da_chat_request_ledger.input_type` | `VOICE` | 语音文本问数请求 | 不代表保存原始音频 |
| `da_chat_request_ledger.input_type` | `PRESET_QUESTION` | 预设问题问数请求 | 与用户消息输入类型一致 |
| `da_chat_request_ledger.request_status` | `RECEIVED` | 已接收 | 请求台账初始状态 |
| `da_chat_request_ledger.request_status` | `PROCESSING` | 处理中 | 已进入 Agent 编排 |
| `da_chat_request_ledger.request_status` | `SUCCEEDED` | 成功 | 消息和结果载荷已完成落库 |
| `da_chat_request_ledger.request_status` | `PERSIST_FAILED` | 结果已产生但持久化失败 | 重试应优先恢复，不得重复调用工具 |
| `da_chat_request_ledger.request_status` | `FAILED` | 失败 | 模型、工具或系统错误 |
| `da_chat_request_ledger.request_status` | `STOPPED` | 已暂停 | 用户暂停且最终状态已落库 |
| `da_chat_request_ledger.last_stage` | `RECEIVED` | 已接收 | 请求进入台账 |
| `da_chat_request_ledger.last_stage` | `INTENT` | 意图识别 | Agent 编排中 |
| `da_chat_request_ledger.last_stage` | `CALL_TOOL` | 工具调用 | 工具执行中或已执行 |
| `da_chat_request_ledger.last_stage` | `SAVE_MESSAGES` | 消息保存 | 最终持久化阶段 |

## 6. 知识、语音和任务枚举

| 枚举字段 | 取值 | 含义 | 约束 |
| --- | --- | --- | --- |
| `da_agent_knowledge.knowledge_type` | `DOCUMENT` | 文档知识 | 可参与召回和向量化 |
| `da_agent_knowledge.knowledge_type` | `QA` | 问答知识 | 可参与召回和向量化 |
| `da_agent_knowledge.knowledge_type` | `FAQ` | 常见问题 | 可参与召回和向量化 |
| `da_agent_knowledge.vector_status` | `PENDING` | 待向量化 | 默认状态 |
| `da_agent_knowledge.vector_status` | `PROCESSING` | 向量化中 | 可配合 `da_vector_task` |
| `da_agent_knowledge.vector_status` | `SUCCESS` | 向量化成功 | 可参与向量召回 |
| `da_agent_knowledge.vector_status` | `FAILED` | 向量化失败 | 需记录脱敏失败原因 |
| `da_business_term.vector_status` | `PENDING` | 待向量化 | 默认状态 |
| `da_business_term.vector_status` | `PROCESSING` | 向量化中 | 可配合 `da_vector_task` |
| `da_business_term.vector_status` | `SUCCESS` | 向量化成功 | 可参与向量召回 |
| `da_business_term.vector_status` | `FAILED` | 向量化失败 | 需记录脱敏失败原因 |
| `da_voice_config.provider` | `ASR_COMPATIBLE` | 兼容式 ASR 服务 | seed 默认值，默认禁用 |
| `da_voice_config.test_status` | `UNTESTED` | 未测试 | seed 默认值 |
| `da_voice_config.test_status` | `SUCCESS` | 测试成功 | 接口可调用 |
| `da_voice_config.test_status` | `FAILED` | 测试失败 | 不应调用供应方 |
| `da_schema_init_task.task_status` | `PENDING` | 待处理 | 任务创建后未开始 |
| `da_schema_init_task.task_status` | `PROCESSING` | 处理中 | Schema 同步中 |
| `da_schema_init_task.task_status` | `SUCCESS` | 成功 | MySQL 为最终事实来源 |
| `da_schema_init_task.task_status` | `FAILED` | 失败 | Redis 过期不影响该状态 |
| `da_vector_task.target_type` | `AGENT_KNOWLEDGE` | Agent 知识 | 对应 `da_agent_knowledge.knowledge_id` |
| `da_vector_task.target_type` | `BUSINESS_TERM` | 业务术语 | 对应 `da_business_term.term_id` |
| `da_vector_task.task_status` | `PENDING` | 待处理 | 任务创建后未开始 |
| `da_vector_task.task_status` | `PROCESSING` | 处理中 | 向量化中 |
| `da_vector_task.task_status` | `SUCCESS` | 成功 | MySQL 为最终事实来源 |
| `da_vector_task.task_status` | `FAILED` | 失败 | Redis 过期不影响该状态 |

## 7. 审计枚举

| 枚举字段 | 取值 | 含义 | 约束 |
| --- | --- | --- | --- |
| `da_audit_log.input_type` | `TEXT` | 文本问数 | 与请求台账输入类型一致 |
| `da_audit_log.input_type` | `VOICE` | 语音文本问数 | 不保存原始音频 |
| `da_audit_log.input_type` | `PRESET_QUESTION` | 预设问题问数 | 与请求台账输入类型一致 |
| `da_audit_log.result_status` | `SUCCESS` | 问数成功 | 可按 `trace_id` 追踪 |
| `da_audit_log.result_status` | `NO_DATA` | 工具执行成功但无业务数据 | 必须与系统错误区分 |
| `da_audit_log.result_status` | `FAILED` | 问数失败 | 不保存原始 SQL、密钥、密码或堆栈 |
| `da_audit_log.result_status` | `STOPPED` | 用户暂停 | 与消息和台账终态对应 |

## 8. 维护规则

- 新增枚举值必须同步更新数据库设计文档、接口契约、后端校验和本文档。
- MVP 不在数据库层使用 `CHECK` 强约束枚举值，枚举合法性由 Service 层校验。
- 审计、日志和错误信息不得保存原始 SQL、密钥、数据库密码、完整连接串或后端堆栈。
- Redis Key 不在本文档重复定义，统一以 `redis-key-spec.md` 为准。
