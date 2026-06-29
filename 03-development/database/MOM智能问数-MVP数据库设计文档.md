# MOM智能问数-MVP数据库设计文档

## 1. 文档说明

本文档用于指导 MOM 智能问数 MVP 阶段的数据库设计，覆盖系统自身 MySQL 表、Redis 运行态缓存、关键索引、唯一约束、安全存储、数据生命周期和初始化建议。

本文档基于以下项目文档整理：

- 《MOM智能问数-MVP开发Agent执行约束文档》
- 《MOM智能问数-MVP接口设计文档》
- 《MOM智能问数-MVP用户侧需求规格文档》
- 《MOM智能问数-MVP管理侧需求规格文档》

本文档重点解决“对象模型如何落成数据库设计”的问题，不替代产品需求文档和接口文档。

对齐原则：

- 需求概念、业务对象、接口字段和 MVP 范围以《MOM智能问数-MVP接口设计文档》为准。
- 数据库设计允许使用技术实现概念，但必须能映射到接口文档中的业务字段。
- 数据库字段统一使用 `snake_case`，接口字段统一使用 `camelCase`。
- MVP 问数结果不建设独立结果中心，最终结果随 Agent 回复消息保存为 `metadata.resultPayload`。

## 2. 设计边界

### 2.1 系统自身库

系统自身库使用 MySQL 8.0，保存 MOM 智能问数平台自身的配置、会话、消息、最终问数结果载荷、任务状态、模型密钥密文、语音配置密钥密文和审计数据。

系统自身库包含：

- 管理侧配置数据。
- 用户侧运行数据。
- Agent 回复消息及最终 `metadata.resultPayload`。
- 问答请求幂等台账。
- 指标口径定义与发布状态。
- 语音输入配置，不保存原始音频，不保存独立语音识别记录。
- 任务状态与审计日志。

### 2.2 Redis 运行态缓存

Redis 用于保存短期运行态、幂等、限流、任务进度、配置摘要缓存；鉴权缓存属于后置能力。Redis 不作为核心业务事实的唯一存储。

Redis 可用于：

- 运行配置摘要缓存。
- 问答响应短期缓存。持久幂等以 MySQL 请求台账为准。
- 同一会话 active 问答锁。
- 语音识别和问答限流。
- Schema 初始化任务状态。
- 知识向量化任务状态。
- SSE 当前任务状态、暂停信号和短期事件缓冲。
- 外部 API Key 鉴权缓存后置，不进入 MVP 开发和联调范围。

### 2.3 外部 MOM 业务数据源

外部 MOM 业务库不是系统自身库的一部分。系统只保存数据源连接配置、Schema 初始化结果、表范围和语义字段映射，不复制 MOM 业务数据。

外部业务数据访问原则：

- 通过只读账号访问。
- 仅访问纳入问数范围的表。
- 不允许模型直接生成任意 SQL 执行。
- 查询结果需要受 Skill、语义模型、权限范围和安全规则约束。

## 3. 命名规范

### 3.1 表命名

建议统一使用 `da_` 前缀，表示智能问数系统表。

| 分类 | 前缀示例 | 说明 |
| --- | --- | --- |
| 配置表 | `da_agent`、`da_model_config` | 管理侧配置 |
| 运行表 | `da_session`、`da_message`、`da_chat_request_ledger` | 用户侧会话、消息和问答幂等台账 |
| 结果载荷 | `da_message.metadata_json` | Agent 回复消息中的最终展示结果 |
| 任务表 | `da_schema_init_task`、`da_vector_task` | 任务状态/内部任务记录 |
| 审计表 | `da_audit_log` | 调用审计 |

### 3.2 字段命名

数据库字段建议使用 `snake_case`，代码层可映射为 camelCase。

示例：

| 代码字段 | 数据库字段 |
| --- | --- |
| agentId | agent_id |
| createdTime | created_time |
| enabledFlag | enabled_flag |
| userMessageId | user_message_id |
| 废弃幂等字段 | 不再作为正式契约 |
| resultPayload | metadata_json.resultPayload |

### 3.3 通用字段

大多数业务表建议包含以下字段：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| id | bigint unsigned | 自增主键 |
| xxx_id | varchar(64) | 业务唯一标识 |
| created_time | datetime(3) | 创建时间 |
| updated_time | datetime(3) | 更新时间 |
| deleted_flag | tinyint(1) | 软删除标识，0 未删除，1 已删除 |

配置类表可额外包含：

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| enabled_flag | tinyint(1) | 是否启用 |
| remark | varchar(512) | 备注 |

## 4. MySQL 表总览

### 4.1 管理侧配置表

本节表示 MVP DDL 建表范围。业务接入优先级以第 12.3 节为准。后置能力不进入 MVP 开发和联调范围，除非后续评审重新确认。

| 表名 | 用途 | DDL 是否包含 | 业务接入优先级 |
| --- | --- | --- | --- |
| da_agent | 默认 Agent | 是 | P0 |
| da_model_config | LLM、Embedding 模型配置 | 是 | P0 |
| da_datasource_config | MOM 业务数据源配置 | 是 | P0 |
| da_schema_table | 已初始化 Schema 表缓存 | 是 | P1 |
| da_schema_column | 已初始化 Schema 字段缓存 | 是 | P1 |
| da_table_scope | 数据表问数范围 | 是 | P1 |
| da_skill_config | Skill 白名单配置 | 是 | P0 |
| da_metric_definition | 内置指标口径运行校验表 | 是 | P0 |
| da_agent_knowledge | 智能体知识条目 | 是 | P1 |
| da_business_term | 业务知识条目 | 是 | P1 |
| da_semantic_field | 语义字段映射 | 是 | P1 |
| da_preset_question | 预设问题 | 是 | P0 |
| da_voice_config | 语音输入 ASR 配置 | 是 | P1 |
| da_api_docs | API 访问说明 | 否 | 后置 |
| da_system_prompt | 系统提示词版本 | 否 | 后置 |

### 4.2 用户侧运行表

| 表名 | 用途 | DDL 是否包含 | 业务接入优先级 |
| --- | --- | --- | --- |
| da_session | 用户会话 | 是 | P0 |
| da_chat_request_ledger | 问答请求幂等台账 | 是 | P0 |
| da_message | 会话消息、Agent 回复和最终结果载荷 | 是 | P0 |
| da_voice_record | 语音识别记录 | 否 | 后置 |
| da_query_result | 独立问数结果摘要 | 否 | 后置 |
| da_table_result | 独立表格结果 | 否 | 后置 |
| da_indicator_result | 独立指标卡结果 | 否 | 后置 |
| da_chart_result | 独立图表结果 | 否 | 后置 |
| da_runtime_notice | 独立运行提示 | 否 | 后置 |

### 4.3 任务与审计表

| 表名 | 用途 | DDL 是否包含 | 业务接入优先级 |
| --- | --- | --- | --- |
| da_schema_init_task | Schema 初始化任务 | 是 | P1 |
| da_vector_task | 知识向量化任务 | 是 | P1 |
| da_audit_log | 问数调用审计 | 是 | P1 |
| da_api_invoke_log | 外部 API 调用日志 | 否 | 后置 |

## 5. 管理侧配置表设计

### 5.1 da_agent 默认 Agent 表

用途：保存 MVP 阶段唯一默认 Agent。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| agent_id | varchar(64) | UK | Agent 标识 |
| agent_name | varchar(128) | NOT NULL | Agent 名称 |
| agent_status | varchar(32) | NOT NULL | `ENABLED`、`DISABLED` |
| is_default | tinyint(1) | NOT NULL | MVP 固定为 1 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |
| default_agent_key | varchar(32) | GENERATED | 条件唯一键，仅默认且未删除 Agent 生效 |

索引建议：

- `uk_agent_id(agent_id)`
- `uk_default_agent(default_agent_key)`
- `idx_default_status(is_default, agent_status, deleted_flag)`

约束说明：

- MVP 阶段只允许一条 `is_default=1 AND deleted_flag=0` 的记录。通过 `default_agent_key` 生成列和 `uk_default_agent` 唯一索引约束。

### 5.2 da_model_config 模型资源配置表

用途：保存 LLM、Embedding 模型配置。ASR 使用独立 `da_voice_config`，不混入问数模型配置。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| model_config_id | varchar(64) | UK | 模型配置标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| config_name | varchar(128) | NOT NULL | 配置名称 |
| model_category | varchar(32) | NOT NULL | `LLM`、`EMBEDDING` |
| provider | varchar(64) | NOT NULL | 供应商 |
| base_url | varchar(512) | NOT NULL | 服务地址 |
| api_key_cipher | text | NOT NULL | 加密后的 API Key |
| api_key_masked | varchar(128) | NOT NULL | 脱敏展示值 |
| model_name | varchar(128) | NOT NULL | 模型名称 |
| request_mode | varchar(32) | NULL | `STREAM`、`NON_STREAM` |
| temperature | decimal(4,3) | NULL | 温度 |
| max_tokens | int | NULL | 最大输出长度 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否启用 |
| default_flag | tinyint(1) | NOT NULL DEFAULT 0 | 是否当前生效 |
| test_status | varchar(32) | NOT NULL DEFAULT 'UNTESTED' | 测试状态：`UNTESTED`、`SUCCESS`、`FAILED` |
| test_message | varchar(1024) | NULL | 测试结果 |
| last_test_time | datetime(3) | NULL | 最近测试时间 |
| remark | varchar(512) | NULL | 备注 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_model_config_id(model_config_id)`
- `idx_agent_category(agent_id, model_category, deleted_flag)`
- `idx_agent_category_default(agent_id, model_category, default_flag, enabled_flag, deleted_flag)`

约束说明：

- 同一 `agent_id + model_category` 下只允许一条 `default_flag=1 AND enabled_flag=1 AND deleted_flag=0` 的生效配置。
- `api_key_cipher` 必须加密保存，不允许明文落库。

### 5.3 da_datasource_config 数据源配置表

用途：保存外部 MOM 业务数据库连接配置。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| datasource_id | varchar(64) | UK | 数据源标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| datasource_name | varchar(128) | NOT NULL | 数据源名称 |
| datasource_type | varchar(32) | NOT NULL | `MYSQL`、`DM`、`ORACLE`、`SQLSERVER`、`POSTGRESQL` |
| host | varchar(256) | NOT NULL | 主机地址 |
| port | int | NOT NULL | 端口 |
| database_name | varchar(128) | NOT NULL | 数据库名称 |
| username | varchar(128) | NOT NULL | 用户名 |
| password_cipher | text | NOT NULL | 加密后的密码 |
| password_masked | varchar(128) | NOT NULL | 脱敏密码 |
| connection_url_cipher | text | NULL | 加密后的连接串 |
| readonly_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否只读 |
| dangerous_sql_block_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否拦截危险 SQL |
| max_return_rows | int | NOT NULL DEFAULT 1000 | 最大返回行数 |
| query_timeout_ms | int | NOT NULL DEFAULT 6000 | 查询超时 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否启用 |
| active_flag | tinyint(1) | NOT NULL DEFAULT 0 | 是否当前生效数据源 |
| connect_status | varchar(32) | NOT NULL DEFAULT 'UNTESTED' | 连接测试状态：`UNTESTED`、`SUCCESS`、`FAILED` |
| connect_message | varchar(1024) | NULL | 连接结果说明 |
| schema_init_status | varchar(32) | NOT NULL DEFAULT 'NOT_INITIALIZED' | Schema 初始化状态：`NOT_INITIALIZED`、`INITIALIZING`、`SUCCESS`、`FAILED` |
| last_init_time | datetime(3) | NULL | 最近初始化时间 |
| table_count | int | NULL | 表数量 |
| field_count | int | NULL | 字段数量 |
| remark | varchar(512) | NULL | 备注 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_datasource_id(datasource_id)`
- `idx_agent_active(agent_id, active_flag, enabled_flag, deleted_flag)`
- `idx_connect_status(connect_status, schema_init_status)`

约束说明：

- MVP 阶段同一 Agent 仅允许一个 `active_flag=1 AND enabled_flag=1 AND deleted_flag=0` 的数据源进入问数链路。
- 数据源账号建议使用只读账号。
- 密码和连接串必须加密保存。

### 5.4 da_schema_table 已初始化 Schema 表缓存

用途：保存 Schema 初始化后读取到的物理表信息，支撑 `GET /api/datasources/{datasourceId}/schema`、表范围配置和语义模型字段选择。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| schema_table_id | varchar(64) | UK | Schema 表标识 |
| datasource_id | varchar(64) | NOT NULL | 所属数据源 |
| table_name | varchar(128) | NOT NULL | 物理表名 |
| table_comment | varchar(512) | NULL | 表注释 |
| table_type | varchar(32) | NULL | `TABLE`、`VIEW` |
| field_count | int | NULL | 字段数量 |
| last_init_time | datetime(3) | NULL | 最近初始化时间 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_schema_table_id(schema_table_id)`
- `uk_datasource_table(datasource_id, table_name, deleted_flag)`
- `idx_datasource_time(datasource_id, last_init_time)`

说明：

- 本表保存物理 Schema 缓存，不表示该表一定纳入问数范围。
- 是否纳入问数由 `da_table_scope.in_query_scope` 决定。

### 5.5 da_schema_column 已初始化 Schema 字段缓存

用途：保存 Schema 初始化后读取到的物理字段信息，支撑语义模型字段来源校验。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| schema_column_id | varchar(64) | UK | Schema 字段标识 |
| datasource_id | varchar(64) | NOT NULL | 所属数据源 |
| table_name | varchar(128) | NOT NULL | 物理表名 |
| column_name | varchar(128) | NOT NULL | 物理字段名 |
| column_comment | varchar(512) | NULL | 字段注释 |
| data_type | varchar(128) | NOT NULL | 数据类型 |
| nullable_flag | tinyint(1) | NULL | 是否可为空 |
| primary_key_flag | tinyint(1) | NOT NULL DEFAULT 0 | 是否主键 |
| ordinal_position | int | NULL | 字段顺序 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_schema_column_id(schema_column_id)`
- `uk_datasource_table_column(datasource_id, table_name, column_name, deleted_flag)`
- `idx_datasource_table(datasource_id, table_name, ordinal_position)`

说明：

- `da_semantic_field.table_name + column_name` 必须能在本表找到有效字段。
- 本表不保存 MOM 业务数据，只保存表字段元数据。

### 5.6 da_table_scope 数据表范围表

用途：保存数据源下哪些表进入问数范围。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| table_scope_id | varchar(64) | UK | 表范围标识 |
| datasource_id | varchar(64) | NOT NULL | 所属数据源 |
| table_name | varchar(128) | NOT NULL | 物理表名 |
| table_comment | varchar(512) | NULL | 表说明 |
| field_count | int | NULL | 字段数量 |
| in_query_scope | tinyint(1) | NOT NULL DEFAULT 0 | 是否纳入问数 |
| is_core_table | tinyint(1) | NOT NULL DEFAULT 0 | 是否核心表 |
| sort_order | int | NOT NULL DEFAULT 0 | 排序 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |

索引建议：

- `uk_datasource_table(datasource_id, table_name)`
- `idx_datasource_query_scope(datasource_id, in_query_scope, is_core_table)`

说明：

- `table_name` 必须来自 `da_schema_table`。

### 5.7 da_skill_config Skill 配置表

用途：保存默认 Agent 可调用 Skill 白名单。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| skill_id | varchar(64) | UK | Skill 标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| skill_code | varchar(128) | NOT NULL | Skill 编码 |
| tool_name | varchar(128) | NOT NULL | 后端固定工具名 |
| skill_name | varchar(128) | NOT NULL | Skill 名称 |
| source_type | varchar(32) | NOT NULL | `BUILT_IN`、`IMPORTED` |
| version | varchar(64) | NULL | 版本 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否启用 |
| test_status | varchar(32) | NOT NULL DEFAULT 'UNTESTED' | 测试状态：`UNTESTED`、`SUCCESS`、`FAILED` |
| description | varchar(1024) | NULL | 描述 |
| import_time | datetime(3) | NULL | 导入时间 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |
| active_skill_code_key | varchar(256) | GENERATED | 条件唯一键，仅启用且未删除 Skill 生效 |
| active_tool_key | varchar(256) | GENERATED | 条件唯一键，仅启用且未删除工具名生效 |

索引建议：

- `uk_skill_id(skill_id)`
- `uk_active_skill_code(active_skill_code_key)`：约束同一 Agent 下启用且未删除的 `skill_code` 唯一
- `idx_agent_skill_code(agent_id, skill_code, deleted_flag)`
- `uk_active_tool_name(active_tool_key)`：约束同一 Agent 下启用且未删除的 `tool_name` 唯一
- `idx_agent_tool_name(agent_id, tool_name, enabled_flag, deleted_flag)`
- `idx_agent_enabled(agent_id, enabled_flag, deleted_flag)`

说明：

- `skill_code` 用于管理侧配置展示和兼容历史命名。
- `tool_name` 是智能体实际可调用的后端工具名，MVP 阶段固定为 `workOrderStatusSummary`、`inventoryBelowSafetyStock`、`equipmentDowntimeSummary` 三个值之一。

### 5.8 da_metric_definition 内置指标口径运行校验表

用途：保存可被智能体正式调用的内置结构化指标口径、版本、生效状态和默认版本。该表是 MVP 后端运行校验表，由初始化脚本和后端内置配置维护，不提供管理侧增删改查接口。RAG、知识库和业务术语只负责解释文本、同义词和背景知识，不作为指标是否可查的权威来源。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| metric_id | varchar(64) | UK | 指标口径标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| metric_key | varchar(128) | NOT NULL | 稳定指标编码 |
| metric_name | varchar(128) | NOT NULL | 指标名称 |
| domain | varchar(64) | NOT NULL | 业务域，如工单、库存、设备 |
| version | varchar(64) | NOT NULL | 口径版本 |
| status | varchar(32) | NOT NULL | `DRAFT`、`PUBLISHED`、`DISABLED` |
| default_flag | tinyint(1) | NOT NULL DEFAULT 0 | 是否默认版本 |
| tool_name | varchar(128) | NOT NULL | 允许调用的工具名 |
| calculation_rule | longtext | NOT NULL | 结构化或文本化计算规则 |
| effective_time | datetime(3) | NULL | 生效时间 |
| published_by | varchar(64) | NULL | 发布人 |
| published_time | datetime(3) | NULL | 发布时间 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |
| active_default_key | varchar(256) | GENERATED | 条件唯一键，仅已发布默认版本生效 |

索引建议：

- `uk_metric_id(metric_id)`
- `uk_metric_version(agent_id, metric_key, version)`
- `uk_active_default_metric(active_default_key)`
- `idx_agent_status(agent_id, status, deleted_flag)`
- `idx_agent_tool(agent_id, tool_name, status, deleted_flag)`

约束说明：

- CALL_TOOL 前必须从本表读取指标口径，并校验 `status='PUBLISHED'`。
- MVP 不提供指标口径管理接口，默认指标口径通过初始化数据写入。
- 同一 Agent 下的同一 `metric_key + version` 只能存在一条记录，为后续多 Agent 扩展保留命名空间。
- 同一 `agent_id + metric_key` 仅允许一个 `status='PUBLISHED' AND default_flag=1 AND deleted_flag=0` 的默认版本。
- Agent 回复消息 `metadata.resultPayload` 和审计表中的 `metric_version` 必须来自本表的已发布版本。

### 5.9 da_agent_knowledge 智能体知识表

用途：保存文档、问答对、FAQ 类知识元数据和处理状态。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| knowledge_id | varchar(64) | UK | 知识标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| knowledge_type | varchar(32) | NOT NULL | `DOCUMENT`、`QA`、`FAQ` |
| knowledge_title | varchar(256) | NOT NULL | 标题 |
| source_file_name | varchar(256) | NULL | 源文件名 |
| source_file_type | varchar(64) | NULL | 文件类型 |
| splitter_type | varchar(32) | NULL | 分块方式 |
| question | varchar(1024) | NULL | 问题 |
| answer_content | longtext | NULL | 答案内容 |
| recall_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否参与召回 |
| vector_status | varchar(32) | NOT NULL DEFAULT 'PENDING' | 向量状态 |
| vector_message | varchar(1024) | NULL | 向量处理说明 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_knowledge_id(knowledge_id)`
- `idx_agent_recall(agent_id, recall_flag, vector_status, deleted_flag)`
- `idx_knowledge_type(agent_id, knowledge_type, deleted_flag)`

说明：

- 向量本体不建议直接存 MySQL。MySQL 保存元数据和状态，向量写入向量库或检索服务。

### 5.10 da_business_term 业务知识表

用途：保存业务术语、描述、同义词、标签和召回状态。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| term_id | varchar(64) | UK | 术语标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| term_name | varchar(128) | NOT NULL | 业务名词 |
| description | longtext | NOT NULL | 业务描述 |
| synonyms | varchar(1024) | NULL | 同义词，按 JSON 数组字符串保存 |
| tag_names | varchar(512) | NULL | 标签 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否启用 |
| recall_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否参与召回 |
| vector_status | varchar(32) | NOT NULL DEFAULT 'PENDING' | 向量状态 |
| vector_message | varchar(1024) | NULL | 向量处理说明 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_term_id(term_id)`
- `idx_agent_term(agent_id, term_name, deleted_flag)`
- `idx_agent_recall(agent_id, enabled_flag, recall_flag, vector_status, deleted_flag)`

说明：

- 业务知识接口中的 `synonyms` 为数组，入库前统一序列化为 JSON 数组字符串。

### 5.11 da_semantic_field 语义字段映射表

用途：保存表字段到业务字段的结构化映射。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| semantic_id | varchar(64) | UK | 语义映射标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| datasource_id | varchar(64) | NOT NULL | 所属数据源 |
| table_name | varchar(128) | NOT NULL | 表名 |
| column_name | varchar(128) | NOT NULL | 字段名 |
| business_name | varchar(128) | NOT NULL | 业务名称 |
| synonyms | varchar(1024) | NULL | 同义词，按 JSON 数组字符串保存 |
| business_description | text | NULL | 业务描述 |
| column_comment | varchar(512) | NULL | 字段注释 |
| data_type | varchar(128) | NOT NULL | 数据类型 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否启用 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_semantic_id(semantic_id)`
- `uk_datasource_table_column(datasource_id, table_name, column_name, deleted_flag)`
- `idx_agent_business_name(agent_id, business_name, enabled_flag, deleted_flag)`

说明：

- `table_name + column_name` 必须来自 `da_schema_column`。
- 本表保存业务语义映射，不替代物理 Schema 缓存。
- 语义模型接口中的 `synonyms` 支持逗号分隔字符串，入库前由后端解析、去空、去重，并统一序列化为 JSON 数组字符串。

### 5.12 da_preset_question 预设问题表

用途：保存用户侧展示的推荐问题。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| preset_question_id | varchar(64) | UK | 预设问题标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| question_title | varchar(128) | NULL | 问题标题 |
| question_content | varchar(1024) | NOT NULL | 问题内容 |
| question_category | varchar(64) | NULL | 工单、库存、设备 |
| display_scene | varchar(64) | NULL | `HOME`、`INPUT` |
| sort_order | int | NOT NULL DEFAULT 0 | 排序 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否启用 |
| home_display_flag | tinyint(1) | NOT NULL DEFAULT 1 | 是否首页展示 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_preset_question_id(preset_question_id)`
- `idx_agent_home(agent_id, enabled_flag, home_display_flag, sort_order, deleted_flag)`

### 5.13 da_voice_config 语音输入配置表

用途：保存管理侧配置的 ASR 供应方参数和敏感密钥密文，支撑用户侧 `GET /api/voice/config`、管理侧 `GET /api/voice/config/admin` 和后端代理 `POST /api/voice/asr`。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| voice_config_id | varchar(64) | UK | 语音配置标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent，MVP 固定默认 Agent |
| provider | varchar(64) | NOT NULL | ASR 供应方 |
| base_url_cipher | text | NULL | 加密后的 ASR 服务地址；如不含敏感参数也可明文配置 |
| base_url_masked | varchar(512) | NULL | 脱敏展示地址 |
| app_id | varchar(128) | NULL | 供应方应用标识 |
| api_key_cipher | text | NULL | 加密后的 API Key |
| api_key_masked | varchar(128) | NULL | 脱敏 API Key |
| secret_key_cipher | text | NULL | 加密后的 Secret Key |
| secret_key_masked | varchar(128) | NULL | 脱敏 Secret Key |
| model_name | varchar(128) | NULL | ASR 模型名称 |
| language | varchar(32) | NOT NULL DEFAULT 'zh-CN' | 默认识别语言 |
| sample_rate | int | NULL | 推荐采样率 |
| max_duration_seconds | int | NOT NULL DEFAULT 60 | 最大音频时长 |
| max_file_size_mb | int | NOT NULL DEFAULT 10 | 最大文件大小 |
| timeout_ms | int | NOT NULL DEFAULT 30000 | 后端调用 ASR 超时 |
| enabled_flag | tinyint(1) | NOT NULL DEFAULT 0 | 是否启用 |
| test_status | varchar(32) | NOT NULL DEFAULT 'UNTESTED' | 测试状态：`UNTESTED`、`SUCCESS`、`FAILED` |
| test_message | varchar(1024) | NULL | 测试结果 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 软删除 |

索引建议：

- `uk_voice_config_id(voice_config_id)`
- `uk_agent_voice_config(agent_id, deleted_flag)`
- `idx_enabled(agent_id, enabled_flag, deleted_flag)`

安全说明：

- 用户侧配置接口不得返回 `api_key_cipher`、`secret_key_cipher`、完整密钥或未脱敏敏感地址。
- 管理侧回显只返回 `apiKeyConfigured`、`apiKeyMask`、`secretKeyConfigured`、`secretKeyMask` 和非敏感配置。
- 语音识别请求不保存原始音频，不保存独立语音识别记录；识别成功后由前端填入输入框，用户手动发送后按普通消息落入 `da_message`。

接口字段映射说明：

| 接口字段 | 数据库字段或来源 |
| --- | --- |
| `configId` | `voice_config_id` |
| `enabled` | `enabled_flag` |
| `mode` | 后端固定返回 `BACKEND_PROXY`，不单独落库 |
| `provider` | `provider` |
| `baseUrl` | 写入时加密保存到 `base_url_cipher` |
| `baseUrlMask` | `base_url_masked` |
| `modelName` | `model_name` |
| `language` | `language` |
| `maxDurationSeconds` | `max_duration_seconds` |
| `maxFileSizeMb` | `max_file_size_mb` |
| `asrTimeoutSeconds` | 由 `timeout_ms / 1000` 派生 |
| `supportedFormats` | 后端固定返回 `["WAV"]`，不单独落库 |
| `allowedMimeTypes` | 后端固定返回 `["audio/wav", "audio/x-wav"]`，不单独落库 |
| `tips` | 后端固定提示或配置文件派生，MVP 不单独落库 |
| `apiKeyConfigured` | 根据 `api_key_cipher` 是否存在派生 |
| `apiKeyMask` | `api_key_masked` |
| `secretKeyConfigured` | 根据 `secret_key_cipher` 是否存在派生 |
| `secretKeyMask` | `secret_key_masked` |

### 5.14 后置配置表说明

以下表不纳入 MVP 建表和联调范围：

| 后置表 | 后置原因 |
| --- | --- |
| da_api_docs | 访问 API、`X-API-Key`、外部调用说明在 MVP 阶段完全隐藏，仅保留设计说明 |
| da_system_prompt | 系统提示词是后端内置运行能力，MVP 不提供页面编辑和版本配置 |

## 6. 用户侧运行表设计

### 6.1 da_session 用户会话表

用途：保存用户历史会话。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| session_id | varchar(64) | UK | 会话标识 |
| agent_id | varchar(64) | NOT NULL | 所属 Agent |
| session_title | varchar(256) | NOT NULL | 会话标题 |
| pinned_flag | tinyint(1) | NOT NULL DEFAULT 0 | 是否置顶 |
| deleted_flag | tinyint(1) | NOT NULL DEFAULT 0 | 是否删除 |
| last_message_summary | varchar(512) | NULL | 最近消息摘要 |
| message_count | int | NOT NULL DEFAULT 0 | 消息数量 |
| last_active_time | datetime(3) | NULL | 最近活跃时间 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |

索引建议：

- `uk_session_id(session_id)`
- `idx_agent_deleted_active(agent_id, deleted_flag, pinned_flag, last_active_time)`

说明：

- MVP 未单独建设用户鉴权，但如果后续有用户体系，应补充 `user_id`、`tenant_id` 索引。

### 6.2 da_message 会话消息表

用途：保存用户消息、Agent 回复和系统提示。Agent 回复消息必须保存最终展示级结果载荷，对应接口中的 `metadata.resultPayload`。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| message_id | varchar(64) | UK | 消息标识 |
| session_id | varchar(64) | NOT NULL | 会话标识 |
| agent_id | varchar(64) | NOT NULL | Agent 标识 |
| user_message_id | varchar(64) | NULL | 问数链路中的用户消息 ID；Agent 回复消息用于关联用户消息 |
| thread_id | varchar(64) | NULL | Agent/SSE 运行线程标识 |
| message_role | varchar(32) | NOT NULL | `USER`、`AGENT`、`SYSTEM` |
| input_type | varchar(32) | NOT NULL | `TEXT`、`VOICE`、`PRESET_QUESTION`、`SYSTEM` |
| message_content | longtext | NOT NULL | 消息内容 |
| display_content | longtext | NULL | 展示内容 |
| metadata_json | longtext | NULL | 消息扩展 JSON；Agent 回复消息保存 `resultPayload` |
| message_status | varchar(32) | NOT NULL | `PROCESSING`、`SUCCESS`、`FAILED`、`STOPPED` |
| error_code | varchar(64) | NULL | 错误码 |
| error_message | varchar(1024) | NULL | 错误说明 |
| trace_id | varchar(64) | NULL | 调用链标识 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |

索引建议：

- `uk_message_id(message_id)`
- `uk_session_user_role(session_id, user_message_id, message_role)`
- `idx_session_time(session_id, created_time)`
- `idx_thread_id(thread_id)`
- `idx_trace_id(trace_id)`

幂等说明：

- `user_message_id` 对应接口字段 `userMessageId`，用于用户消息和对应 Agent 回复的幂等关联。
- 用户消息本身的 `message_id` 即接口返回的 `userMessageId`；Agent 回复消息的 `user_message_id` 保存该用户消息 ID。
- `da_message` 不能作为幂等执行状态的事实来源，只负责保存最终消息。
- 后端必须先写入 `da_chat_request_ledger`，再进入 LLM、RAG 和工具调用。
- `metadata_json` 必须由应用层校验 JSON 结构，Agent 回复消息中的 `metadata_json.resultPayload` 与 SSE `complete.resultPayload` 保持同一份业务结构。

### 6.2.1 da_chat_request_ledger 问答请求幂等台账

用途：在调用 LLM、RAG、MOM 工具之前记录一次用户请求的执行状态，确保同一 `session_id + user_message_id` 不重复创建 Agent 回复消息、不重复调用工具。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| ledger_id | varchar(64) | UK | 台账标识 |
| session_id | varchar(64) | NOT NULL | 会话标识 |
| agent_id | varchar(64) | NOT NULL | Agent 标识 |
| user_message_id | varchar(64) | NOT NULL | 已保存的用户消息 ID，对应接口 `userMessageId` |
| agent_message_id | varchar(64) | NULL | 后端创建的 Agent 回复消息 ID |
| thread_id | varchar(64) | NULL | Agent/SSE 运行线程标识 |
| trace_id | varchar(64) | NOT NULL | 调用链标识 |
| input_type | varchar(32) | NOT NULL | `TEXT`、`VOICE`、`PRESET_QUESTION` |
| question_digest | varchar(256) | NOT NULL | 用户问题摘要或哈希 |
| question_snapshot_ref | varchar(256) | NULL | 原始问题快照引用；原文落库前必须确认脱敏和留存策略 |
| request_status | varchar(32) | NOT NULL | `RECEIVED`、`PROCESSING`、`SUCCEEDED`、`PERSIST_FAILED`、`FAILED`、`STOPPED` |
| last_stage | varchar(64) | NOT NULL | 最近阶段，如 `RECEIVED`、`INTENT`、`CALL_TOOL`、`SAVE_MESSAGES` |
| tool_name | varchar(128) | NULL | 已选择工具名 |
| tool_result_digest | varchar(256) | NULL | 工具结果摘要 |
| result_payload_snapshot | longtext | NULL | 已生成展示结果快照，重试时可直接返回 |
| attempt_count | int | NOT NULL DEFAULT 0 | 尝试次数 |
| heartbeat_time | datetime(3) | NULL | 最近心跳时间 |
| locked_until | datetime(3) | NULL | 锁定截止时间 |
| error_code | varchar(64) | NULL | 错误码 |
| error_message | varchar(1024) | NULL | 错误说明 |
| created_time | datetime(3) | NOT NULL | 创建时间 |
| updated_time | datetime(3) | NOT NULL | 更新时间 |

索引建议：

- `uk_ledger_id(ledger_id)`
- `uk_session_user_message(session_id, user_message_id)`
- `idx_agent_message(agent_message_id)`
- `idx_thread_id(thread_id)`
- `idx_trace_id(trace_id)`
- `idx_status_locked(request_status, locked_until)`
- `idx_session_status(session_id, request_status, updated_time)`

状态与幂等规则：

- `request_status` 是后端内部执行台账状态，不直接等同接口返回的 `messageStatus` 或 `resultStatus`。
- 新请求必须先插入 `RECEIVED`，插入失败且命中 `uk_session_user_message` 时不得再次创建 Agent 回复消息或调用工具。
- 进入工具调用前必须更新为 `PROCESSING`，并写入 `last_stage='CALL_TOOL'`、`heartbeat_time`、`locked_until`。
- 工具调用和消息保存均成功后更新为 `SUCCEEDED`，并写入 `result_payload_snapshot`。
- 用户暂停当前流式任务后更新为 `STOPPED`，对应 Agent 回复消息 `message_status=STOPPED`。
- 工具已调用但消息或结果持久化失败时更新为 `PERSIST_FAILED`，重试应优先根据 `result_payload_snapshot` 或 `tool_result_digest` 恢复，不得重复调用工具。
- 系统失败且没有可恢复结果时更新为 `FAILED`。

状态映射说明：

| 台账 `request_status` | 消息 `message_status` / 接口状态 |
| --- | --- |
| `RECEIVED` | 内部接收态，前端不直接感知 |
| `PROCESSING` | `PROCESSING` |
| `SUCCEEDED` | `SUCCESS` |
| `PERSIST_FAILED` | 内部持久化异常态；对外通常返回 `FAILED`，并记录 `error_code` |
| `FAILED` | `FAILED` |
| `STOPPED` | `STOPPED` |

### 6.3 后置运行表说明

以下运行表不纳入 MVP 建表和联调范围。MVP 的语音识别、结果展示和异常提示均通过现有主链路承载。

| 后置表 | 后置原因 | MVP 替代落点 |
| --- | --- | --- |
| da_voice_record | MVP 不保存原始音频，不保存独立语音识别记录 | `POST /api/voice/asr` 返回文本；用户手动发送后保存为 `da_message.input_type=VOICE` |
| da_query_result | MVP 不建设独立结果中心 | Agent 回复消息 `da_message.metadata_json.resultPayload` |
| da_table_result | MVP 表格结果随最终结果载荷返回 | `metadata_json.resultPayload.table` |
| da_indicator_result | MVP 指标卡结果随最终结果载荷返回 | `metadata_json.resultPayload.indicators` |
| da_chart_result | MVP 图表结果随最终结果载荷返回 | `metadata_json.resultPayload.chart` |
| da_runtime_notice | MVP 异常提示随消息状态和结果载荷返回 | `da_message.message_status/error_code/error_message/metadata_json` |

## 7. 任务与审计表设计

### 7.1 da_schema_init_task Schema 初始化任务表

用途：记录数据源 Schema 初始化任务。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| task_id | varchar(64) | UK | 任务标识 |
| datasource_id | varchar(64) | NOT NULL | 数据源标识 |
| task_status | varchar(32) | NOT NULL | `PENDING`、`PROCESSING`、`SUCCESS`、`FAILED` |
| table_count | int | NULL | 表数量 |
| field_count | int | NULL | 字段数量 |
| error_message | varchar(1024) | NULL | 错误信息 |
| started_time | datetime(3) | NULL | 开始时间 |
| finished_time | datetime(3) | NULL | 完成时间 |
| created_time | datetime(3) | NOT NULL | 创建时间 |

索引建议：

- `uk_task_id(task_id)`
- `idx_datasource_status(datasource_id, task_status, created_time)`

### 7.2 da_vector_task 知识向量化任务表

用途：记录知识向量化任务状态。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| task_id | varchar(64) | UK | 任务标识 |
| target_type | varchar(32) | NOT NULL | `AGENT_KNOWLEDGE`、`BUSINESS_TERM` |
| target_id | varchar(64) | NOT NULL | 知识或术语标识 |
| task_status | varchar(32) | NOT NULL | `PENDING`、`PROCESSING`、`SUCCESS`、`FAILED` |
| chunk_count | int | NULL | 分块数量 |
| error_message | varchar(1024) | NULL | 错误信息 |
| started_time | datetime(3) | NULL | 开始时间 |
| finished_time | datetime(3) | NULL | 完成时间 |
| created_time | datetime(3) | NOT NULL | 创建时间 |

索引建议：

- `uk_task_id(task_id)`
- `idx_target(target_type, target_id)`
- `idx_status_time(task_status, created_time)`

### 7.3 da_audit_log 问数审计日志表

用途：记录问数调用链审计。

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| id | bigint unsigned | PK | 自增主键 |
| audit_id | varchar(64) | UK | 审计标识 |
| trace_id | varchar(64) | NOT NULL | 调用链标识 |
| session_id | varchar(64) | NULL | 会话标识 |
| user_message_id | varchar(64) | NULL | 用户消息 ID |
| agent_message_id | varchar(64) | NULL | Agent 回复消息 ID |
| question_digest | varchar(256) | NULL | 问题摘要或哈希 |
| input_type | varchar(32) | NULL | 输入类型 |
| domain | varchar(64) | NULL | 业务域 |
| intent | varchar(128) | NULL | 意图 |
| tool_name | varchar(128) | NULL | 工具 |
| metric_version | varchar(64) | NULL | 口径版本 |
| result_status | varchar(32) | NOT NULL | 结果状态 |
| error_code | varchar(64) | NULL | 错误码 |
| latency_ms | int | NULL | 总耗时 |
| created_time | datetime(3) | NOT NULL | 创建时间 |

索引建议：

- `uk_audit_id(audit_id)`
- `idx_trace_id(trace_id)`
- `idx_session_user_message(session_id, user_message_id)`
- `idx_agent_message(agent_message_id)`
- `idx_status_time(result_status, created_time)`

安全说明：

- 不保存原始 SQL、密钥、数据库密码、后端堆栈。
- 原始问题如需保存，应先完成脱敏和留存周期确认。
- MVP 阶段 `da_audit_log` 仅用于后端内部追踪、问题排查和审计留痕，不提供前端或管理侧审计查询接口。

## 8. Redis 设计

### 8.1 Key 命名规范

建议统一使用：

```text
da:{module}:{purpose}:{id}
```

示例：

```text
da:runtime:config:default
da:chat:idempotent:{sessionId}:{userMessageId}
da:chat:lock:{sessionId}
```

### 8.2 Redis Key 清单

| Key | 类型 | TTL | 用途 |
| --- | --- | --- | --- |
| `da:runtime:config:{agentId}` | String/JSON | 5 分钟 | 运行配置摘要缓存 |
| `da:chat:idempotent:{sessionId}:{userMessageId}` | String/JSON | 24 小时 | 问答幂等响应缓存 |
| `da:chat:lock:{sessionId}` | String | 90 秒 | 同一会话 active 问答锁，长耗时请求需要续期 |
| `da:stream:active:{threadId}` | String/JSON | 90 秒 | 当前 SSE/Agent 运行任务状态，长耗时请求需要续期 |
| `da:stream:stop:{threadId}` | String | 10 分钟 | 用户暂停信号 |
| `da:stream:events:{threadId}` | Stream/List | 10 分钟 | 短期 SSE 事件缓冲，供断线恢复使用 |
| `da:rate:voice:{sessionId}:{clientIp}` | String/Counter | 1 分钟 | 语音识别限流 |
| `da:schema-task:{taskId}` | Hash/JSON | 24 小时 | Schema 初始化后端内部任务状态 |
| `da:vector-task:{taskId}` | Hash/JSON | 24 小时 | 知识向量化后端内部任务状态 |

### 8.3 Redis 使用规则

- Redis 中缓存的数据必须可以从 MySQL 或外部服务恢复。
- 幂等缓存不能替代 MySQL 消息持久化。
- 会话锁释放应使用 value 校验，避免误删其他请求锁。
- 限流 Key 达到阈值时，不应继续调用 LLM、RAG 或 MOM 工具。
- `da:stream:stop:{threadId}` 只表达暂停信号，最终状态仍以 MySQL `da_message.message_status` 和 `da_chat_request_ledger.request_status` 为准。
- MVP 不建设用户登录、注册、权限和租户体系，`da:rate:user:{userId}`、`da:rate:tenant:{tenantId}` 属于后置能力，不参与 MVP 联调。
- 外部 API Key 鉴权缓存后置，MVP 阶段 Redis 不保存外部 API Key 相关数据。

## 9. 安全设计

### 9.1 敏感字段

| 字段 | 存储策略 |
| --- | --- |
| 模型 API Key | 加密保存，脱敏展示 |
| ASR API Key/Secret Key | 加密保存，脱敏展示 |
| 数据源密码 | 加密保存，脱敏展示 |
| 数据源连接串 | 如包含密码，必须加密保存 |
| 外部 API Key | MVP 阶段不生成、不保存、不鉴权 |
| 用户问题原文 | 默认保存在消息表；审计表只保存摘要或哈希 |

### 9.2 加密建议

- 使用应用侧 KMS 或统一密钥服务进行加密。
- 数据库中保存密文和脱敏展示值。
- 密钥轮换时需提供重加密机制。
- 禁止日志打印明文密钥、密码、连接串。

### 9.3 SQL 安全

- 数据源账号必须只读。
- 查询必须经过 Skill 白名单和语义模型约束。
- 禁止执行 `INSERT`、`UPDATE`、`DELETE`、`DROP`、`ALTER`、`TRUNCATE` 等写操作。
- 查询必须有超时和最大返回行数。
- 查询日志不得保存敏感连接信息。

## 10. 数据生命周期

| 数据 | 建议保留周期 | 说明 |
| --- | --- | --- |
| 管理侧配置 | 长期保留 | 软删除 |
| 会话 | 按业务要求，建议 6-12 个月 | 支持软删除 |
| 消息 | 跟随会话 | 大文本需控制长度 |
| 问数结果载荷 | 跟随 Agent 回复消息 | 保存于 `metadata_json.resultPayload`，JSON 结果需控制大小 |
| 语音配置 | 长期保留 | 软删除；密钥加密保存 |
| 语音音频和独立识别记录 | 不保存 | MVP 只返回识别文本 |
| 审计日志 | 建议 6-12 个月 | 根据企业审计要求调整 |
| Redis 幂等缓存 | 24 小时 | 防止短期重复提交 |
| Redis 运行锁 | 90 秒 | 防止并发问答，长耗时请求需要续期 |
| Redis SSE 事件缓冲 | 10 分钟 | 仅用于短期断线恢复 |
| 任务状态缓存 | 24 小时 | MySQL 保存最终状态 |

## 11. 初始化建议

MVP 初始化时建议创建：

- 1 条默认 Agent。
- 1 条 LLM 模型配置。
- 1 条 Embedding 模型配置。
- 1 条语音输入配置，可未启用；语音配置缺失不阻断文本问数。
- 1 条生效数据源配置。
- 3 条默认预设问题：工单、库存、设备。
- 3 个默认 Skill：工单状态统计、低安全库存查询、设备停机统计。
- 3 条默认指标口径：工单状态统计、低安全库存、设备停机时长。

默认预设问题：

| 分类 | 问题 |
| --- | --- |
| 工单 | 按工单状态统计当前工单数量 |
| 库存 | 查询低于安全库存的物料 |
| 设备 | 分析设备停机时长 |

## 12. 下一阶段数据库开发初稿

本节用于把数据库设计转成可执行开发任务。建议下一阶段先做“能支撑问数主链路”的最小闭环，再补管理配置、任务状态记录和治理能力。

### 12.1 开发目标

下一阶段数据库开发要达成以下目标：

- MySQL 能保存默认 Agent、模型配置、数据源配置、Schema 缓存、Skill、指标口径、预设问题、会话、请求台账、消息和最终问数结果载荷。
- Redis 能支撑问答响应短期缓存、会话并发锁、SSE 运行态、暂停信号、运行配置缓存和任务状态缓存。
- 后端接口可以基于数据库表替换当前前端 mock 数据。
- 敏感字段不明文落库；模型 API Key、ASR 密钥、数据源密码加密保存并脱敏展示，外部 API Key 能力后置。
- 问答链路可以通过 `trace_id` 串起请求台账、消息和审计日志。

### 12.2 推荐开发顺序

| 阶段 | 任务 | 输出物 | 验收方式 |
| --- | --- | --- | --- |
| 1 | 建立 MySQL 基础工程 | 建库脚本、迁移目录、基础连接配置、MySQL 验证脚本 | 本地能启动并连接 MySQL，验证脚本从空库可执行 |
| 2 | 创建管理侧核心表 | `da_agent`、`da_model_config`、`da_datasource_config`、`da_skill_config`、`da_metric_definition`、`da_preset_question` | 能初始化默认 Agent、模型、数据源、Skill、指标口径和预设问题 |
| 3 | 创建 Schema 与语义支撑表 | `da_schema_table`、`da_schema_column`、`da_table_scope`、`da_semantic_field` | Schema 初始化同步返回后可查询表字段，语义字段能校验来源 |
| 4 | 创建问数运行表 | `da_session`、`da_chat_request_ledger`、`da_message` | 一次文本问答能先写请求台账，再保存用户消息、Agent 回复和最终 `resultPayload` |
| 5 | 接入 Redis 基础能力 | 幂等缓存、会话锁、SSE active task、暂停信号、事件缓冲、配置缓存、任务状态缓存 | 重复请求优先命中 MySQL 台账，暂停任务能落到最终 `STOPPED` 状态 |
| 6 | 补齐知识、语音和任务表 | `da_agent_knowledge`、`da_business_term`、`da_voice_config`、`da_schema_init_task`、`da_vector_task` | 知识管理、语音配置、Schema 初始化和向量化任务均有状态记录 |
| 7 | 补审计与安全 | `da_audit_log`、敏感字段加密、SQL 安全拦截日志 | 能按 `trace_id` 追踪一次问数调用 |

### 12.3 MySQL 开发优先级

P0 必须优先完成：

- `da_agent`
- `da_model_config`
- `da_datasource_config`
- `da_skill_config`
- `da_metric_definition`
- `da_preset_question`
- `da_session`
- `da_chat_request_ledger`
- `da_message`

P1 跟随主链路补齐：

- `da_schema_table`
- `da_schema_column`
- `da_table_scope`
- `da_agent_knowledge`
- `da_business_term`
- `da_semantic_field`
- `da_voice_config`
- `da_schema_init_task`
- `da_vector_task`
- `da_audit_log`

后置，不纳入 MVP：

- `da_query_result`
- `da_table_result`
- `da_indicator_result`
- `da_chart_result`
- `da_runtime_notice`
- `da_voice_record`
- `da_api_docs`
- `da_system_prompt`

### 12.4 Redis 开发优先级

P0 必须优先完成：

| Key | 用途 | 建议 TTL |
| --- | --- | --- |
| `da:chat:idempotent:{sessionId}:{userMessageId}` | 问答响应短期缓存；不能替代 MySQL 台账 | 24 小时 |
| `da:chat:lock:{sessionId}` | 同一会话并发锁 | 90 秒 |
| `da:stream:active:{threadId}` | SSE/Agent 当前运行任务状态 | 90 秒，需续期 |
| `da:stream:stop:{threadId}` | 暂停信号 | 10 分钟 |
| `da:stream:events:{threadId}` | SSE 短期事件缓冲 | 10 分钟 |
| `da:runtime:config:{agentId}` | 运行配置缓存 | 5-10 分钟 |

P1 跟随接口补齐：

| Key | 用途 | 建议 TTL |
| --- | --- | --- |
| `da:rate:voice:{sessionId}:{clientIp}` | 语音识别限流 | 1 分钟 |
| `da:schema-task:{taskId}` | Schema 初始化后端内部任务状态；MVP 不提供前端任务查询接口 | 24 小时 |
| `da:vector-task:{taskId}` | 知识向量化后端内部任务状态；MVP 不提供前端任务查询接口 | 24 小时 |

### 12.5 关键开发约束

- MySQL 是事实来源，Redis 只做缓存、锁和短期状态。
- 问答幂等以 `da_chat_request_ledger` 为事实来源；Redis 幂等 Key 只能做响应缓存和性能优化。
- 指标可查性以内置运行表 `da_metric_definition.status='PUBLISHED'` 为事实来源；RAG 命中不能决定口径发布状态；MVP 不提供指标口径管理接口。
- 业务数据库只允许只读访问，系统库不保存外部 MOM 业务明细数据。
- MVP 阶段只保留默认 Agent，但表结构保留 `agent_id`，避免后续多 Agent 改表。
- 暂不强制数据库外键，优先用唯一索引、普通索引和应用层校验降低早期联调成本。
- 表结构保留 `user_id`、`tenant_id` 的字段位置，但 MVP 不建设完整用户权限体系。
- JSON 字段必须由应用层做结构校验，不能把任意大对象无约束写入数据库。
- 所有问答请求必须生成 `trace_id`，所有可追踪表优先写入该字段。
- `GET /api/stream/search` 的幂等键固定为 `session_id + user_message_id`，不得另建废弃幂等字段口径。
- MVP 的 Schema 初始化接口按同步返回设计；`da_schema_init_task`、`da_vector_task` 和对应 Redis Key 只作为后端内部状态记录，不代表前端存在任务查询接口。
- 语音识别只作为输入辅助；`POST /api/voice/asr` 不创建会话消息，用户手动发送后才保存为 `da_message.input_type=VOICE`。
- 访问 API、API Key、系统提示词编辑、独立结果中心和独立语音记录均不纳入 MVP。

### 12.6 需要 AI 协同生成的交付物

下一步可以让我继续协同生成以下内容：

| 交付物 | 用途 | 建议优先级 |
| --- | --- | --- |
| MySQL DDL 脚本 | 直接创建系统库表结构 | P0 |
| 初始化数据脚本 | 写入默认 Agent、模型、Skill、指标口径、预设问题 | P0 |
| Redis Key 使用规范 | 统一后端缓存和锁实现 | P0 |
| ER 图 | 帮助理解表关系 | P1 |
| 枚举字典 | 统一状态值，减少前后端不一致 | P1 |
| 数据库开发任务拆解 | 给初级开发者按天执行 | P1 |
| 归档清理脚本方案 | 控制消息、结果载荷和审计日志体量 | P2 |

### 12.7 后置事项

以下内容不建议在下一阶段一开始就做，避免范围过大：

- 多租户完整权限模型。
- 多 Agent 市场化管理。
- 复杂数据血缘分析。
- 向量库最终选型后的物理索引细节。
- 大规模审计分析报表。
- 跨数据源联邦查询优化。

## 13. 结论

MVP 阶段采用 MySQL 保存系统核心配置、指标口径、幂等台账、消息和最终结果载荷，Redis 只保存短期运行态和性能优化数据。数据库设计应优先保证默认 Agent 闭环、配置生效、数据源安全、请求幂等、会话留痕、结构化结果展示和语音输入配置能力。

该设计保留后续扩展多 Agent、多租户、完整权限、向量库、审计分析和调用统计的空间，但不在 MVP 阶段过度实现。


