# MOM智能问数-MVP接口设计文档

版本：v1.2  
日期：2026-06-24  
阶段：第十二版接口确认文档，用于评审与联调前对齐  
范围：MVP 管理侧配置、用户侧问数运行、外部 API 访问后置

修订说明：v1.2 在 v1.1 基础上补齐总览接口对应的正文契约，新增模型修改/生效、数据源修改、Schema 表字段查询、知识编辑/删除/召回开关/重试向量化、语义模型编辑/启停/删除等接口详情；统一知识向量状态为 `vectorStatus=SUCCESS`，统一会话消息字段为 `messageRole/inputType/messageContent`，统一 Markdown 枚举为 `MARKDOWN`；语音配置管理侧回显改为独立 `GET /api/voice/config/admin`。

## 1. 设计依据

本接口文档是智能问数 MVP 的接口确认文档，优先依据需求文档、数据模型、原型和已确认技术栈设计。DataAgent 只作为问数链路、Schema 初始化和历史设计经验的参考来源，不作为本项目接口路径、响应结构或实现方式的约束。

| 类型 | 文档/代码 | 用途 |
|---|---|---|
| 管理侧需求 | `..\requirements\MOM智能问数-MVP管理侧需求规格文档.md` | 明确模型、数据源、知识、语义、Skill、预设问题、语音输入配置，以及访问 API 后置隐藏口径 |
| 用户侧需求 | `..\requirements\MOM智能问数-MVP用户侧需求规格文档.md` | 明确会话、推荐问题、文本问数、语音问数、结果展示和异常提示 |
| 数据模型/数据库设计 | `..\database\MOM智能问数-MVP数据库设计文档.md` | 明确字段口径、对象关系、状态、枚举和落库设计 |
| 原型 | `原型设计\admin.html`、`原型设计\user.html` | 补充页面动作和按钮入口 |
| 技术栈选型 | 智能问数技术栈选型图 | 明确 FastAPI、Starlette、Uvicorn、SQLAlchemy、Alembic、Pytest、PyMilvus、Redis、RustFS、Neo4j、LangGraph、LlamaIndex 等技术边界 |
| DataAgent 既有链路 | 当前 DataAgent 问数链路与 Schema 初始化实现 | 仅用于流程经验校验，不作为接口确认依据 |

## 2. MVP边界

### 2.1 必须遵守

- MVP 阶段仅支持一个默认 Agent，默认 Agent 固定存在，`agentId` 固定为 `default`，用户侧不提供 Agent 选择入口。
- 管理侧负责配置默认 Agent 能力，用户侧只消费已生效的默认 Agent 能力。
- MVP 阶段默认 Agent 仅绑定一个生效数据源进行问数，不做多数据源路由、跨数据源 Join 或跨数据源联合分析。
- 用户登录、注册、用户权限管理不纳入 MVP；MVP 只验证问数链路，历史会话按一个默认用户处理。
- 系统提示词为内置运行能力，不作为 MVP 页面可编辑配置。
- 访问 API 属于管理侧后置能力，用户侧不维护 API Key 或调用说明；MVP 不实现外部调用入口和 API Key 管理。
- 语音输入属于 MVP 能力，但只作为输入辅助；前端采集音频并转换为 WAV 后上传后端，后端代理调用 ASR 并返回识别文本，前端将文本填入输入框，用户确认后按普通文本问数发送。
- 用户侧输入区包含输入框、发送按钮、语音识别按钮和暂停会话按钮；发送动作是唯一进入问数链路的用户提交入口，暂停会话只中止当前流式问数任务。
- MVP 不提供人工审核、人工反馈、拒绝计划、只 NL2SQL 等 Agent 运行模式或接口参数。
- 模型 API Key、ASR 访问密钥、外部访问 API Key、数据库密码不允许明文回显；若后续开放外部 API Key，完整 Key 仅生成/重置成功时展示一次。
- 语义模型是结构化字段映射与口径约束，不按向量知识库/RAG 接口设计。

### 2.2 接口策略

| 策略项 | 设计结论 |
|---|---|
| 路径前缀 | 内部管理侧、用户侧接口采用项目统一 `/api/...`；外部调用后置方案采用 `/api/v1/...` |
| 版本控制 | 内部接口优先减少现有改造成本；外部调用方案若评估通过，从开放之日起使用 `/api/v1/...`，后续破坏性变更新增 `/api/v2/...` |
| 默认 Agent | `agentId` 在 MVP 阶段固定为 `default`；接口可保留 `agentId` 字段，但前端不提供选择 |
| 默认用户 | MVP 阶段固定一个默认用户，历史会话用于验证问数链路，不做多用户隔离 |
| 数据源范围 | 默认 Agent 仅允许一个生效数据源参与问数；切换数据源时需重新绑定、初始化 Schema，并按新数据源维护语义模型 |
| 内部用户侧问数 | 确认采用 SSE，接口为 `GET /api/stream/search`，返回 `text/event-stream` |
| 外部系统调用 | MVP 不实现外部调用接口；`POST /api/v1/agent/invoke` 和 `X-API-Key` 仅保留在设计说明中，不进入开发 |
| 语音问数 | 前端采集音频并转换为 WAV 后调用 `POST /api/voice/asr`；后端代理调用 ASR 并返回识别文本，前端填入输入框，用户确认后通过发送按钮提交 |
| 暂停会话 | 暂停按钮中止当前 `threadId` 对应的流式问数任务，不删除会话、不影响后续继续提问 |
| Agent 运行模式 | MVP 不暴露人工审核、拒绝计划、只 NL2SQL 等运行选项 |
| 响应结构 | 采用 FastAPI 项目统一 `code/message/data` 结构；分页响应在此基础上扩展分页字段 |

## 3. 通用接口规范

### 3.1 通用响应

```json
{
  "code": 0,
  "message": "操作成功",
  "data": {}
}
```

### 3.2 分页响应

```json
{
  "code": 0,
  "message": "查询成功",
  "data": [],
  "total": 100,
  "pageNum": 1,
  "pageSize": 10,
  "totalPages": 10
}
```

### 3.3 接口命名风格

本项目采用“资源接口 + 明确动作接口”的混合风格。

- 普通新增、查询、修改、删除优先采用资源式路径。
- 测试连接、启停、导入、初始化、召回测试、暂停流式任务等命令型动作允许使用动作式路径。
- 动作式路径应表达明确业务动作，避免同一动作出现多种命名。

### 3.4 通用请求头

| Header | 适用范围 | 必填 | 说明 |
|---|---|---|---|
| `Content-Type: application/json` | JSON 请求 | 是 | 普通新增、修改、查询类接口 |
| `Content-Type: multipart/form-data` | 文件上传 | 是 | 知识文件、Skill ZIP、WAV 音频等上传 |
| `Accept: text/event-stream` | SSE 问数 | 是 | 用户侧流式问数 |
| `X-API-Key` | 外部系统调用后置 | 是 | 仅在外部 API 评估通过并开放后使用 |

### 3.5 通用失败规则

| 场景 | 返回建议 |
|---|---|
| 参数缺失/格式错误 | `code!=0`，`message` 说明具体字段 |
| 资源不存在 | `code!=0`，`message=资源不存在` |
| 状态不允许 | `code!=0`，`message` 说明当前状态与允许动作 |
| 配置不可用 | `code!=0`，`message=默认 Agent 配置不可用`，`data` 可返回缺失项 |
| 外部 API Key 无效 | 外部 API 开放后返回 HTTP 401 或 `code!=0`，不进入问数链路 |
| 服务异常 | HTTP 500 或 `code!=0`，保留明确错误提示，不生成误导性业务结论 |

## 4. 接口总览与需求映射

状态说明：`确认实现` 表示纳入 MVP 接口范围并按本项目 FastAPI 技术栈实现；`后置` 表示不纳入 MVP 开发和联调，仅保留设计说明。

| 模块 | 需求功能 | 拟定接口 | 项目实现结论 | 状态 | 说明 |
|---|---|---|---|---|---|
| 默认 Agent | 获取默认 Agent 与运行状态 | `GET /api/agent/default` | 固定 Agent，`agentId=default` | 确认实现 | 默认 Agent 系统固定拥有，不做创建入口 |
| 模型配置 | 保存/修改模型配置 | `POST /api/model-config/add`、`PUT /api/model-config/update` | FastAPI + Pydantic 实现 | 确认实现 | 覆盖 LLM、Embedding |
| 模型配置 | 测试模型可用性 | `POST /api/model-config/test` | 后端统一模型调用 | 确认实现 | 返回测试状态、耗时、失败原因 |
| 模型配置 | 切换生效模型 | `POST /api/model-config/activate/{id}` | 后端控制同类单生效 | 确认实现 | 同一模型分类仅允许一条生效 |
| 数据源配置 | 保存数据源 | `POST /api/datasource`、`PUT /api/datasource/{id}` | SQLAlchemy 持久化 | 确认实现 | 密码必须脱敏回显 |
| 数据源配置 | 测试连接 | `POST /api/datasource/{datasourceId}/test` | 后端连接测试 | 确认实现 | 失败时禁止 Schema 初始化 |
| 数据源配置 | 绑定当前生效数据源 | `POST /api/agent/{agentId}/datasources/bind` | 默认 Agent 仅绑定一个生效数据源 | 确认实现 | 问数固定使用该数据源，不做数据源路由 |
| 数据源配置 | 初始化 Schema | `POST /api/agent/{agentId}/datasources/init` | 参考 DataAgent 初始化流程 | 确认实现 | 返回表数量、字段数量、初始化状态 |
| 数据源配置 | 查询 Schema 表字段 | `GET /api/datasources/{datasourceId}/schema` | 读取已初始化 Schema 缓存 | 确认实现 | 支撑表范围选择和语义模型字段选择 |
| 数据源配置 | 表范围配置 | `POST /api/agent/{agentId}/datasources/tables` | 当前绑定数据源的表范围维护 | 确认实现 | 与默认 Agent 当前数据源绑定 |
| Skill 管理 | 列表、导入、删除、启停、测试 | `/api/skills...` | FastAPI 新增 Skill 管理接口 | 确认实现 | MVP 明确纳入 |
| 智能体知识 | 查询/保存/上传/编辑/删除/召回开关/重试向量化/召回测试 | `/api/agent-knowledge...` | 后端知识处理 + PyMilvus | 确认实现 | 需提供 recall-test |
| 业务知识 | 查询/保存/编辑/删除/启停/重试向量化/召回测试 | `/api/business-knowledge...` | 后端知识处理 + PyMilvus | 确认实现 | 需提供 recall-test |
| 语义模型 | 查询/新增/编辑/删除/导入/启停 | `/api/semantic-model...` | 结构化字段映射 | 确认实现 | 语义模型不是知识召回；导出不纳入 MVP |
| 预设问题 | 管理侧维护、用户侧展示 | `/api/agent/{agentId}/preset-questions` | 后端配置表维护 | 确认实现 | 用户侧展示为推荐问题 |
| API 访问 | 后置生成/重置/删除/启停 API Key | `/api/agent/{agentId}/api-key...` | MVP 不实现 | 后置 | 仅保留设计说明，不进入开发和联调 |
| 外部调用 | 外部系统调用默认 Agent | `POST /api/v1/agent/invoke` | MVP 不实现 | 后置 | 仅保留设计说明，不进入开发和联调 |
| 会话管理 | 会话列表、新建、改名、置顶、删除 | `/api/agent/{agentId}/sessions`、`/api/sessions/{sessionId}...` | 固定默认用户 | 确认实现 | 只验证问数链路，不做多用户隔离 |
| 用户问数 | 文本问数流式返回 | `GET /api/stream/search` | FastAPI SSE | 确认实现 | `text/event-stream` |
| 用户问数 | 暂停当前问数 | `POST /api/stream/stop` | 中止当前流式任务 | 确认实现 | 暂停当前 `threadId`，保留会话和已输出内容 |
| 用户问数 | 语音输入配置 | `GET /api/voice/config`、`GET /api/voice/config/admin`、`PUT /api/voice/config` | 后端保存 ASR 配置，用户侧只读取非敏感配置，管理侧回显脱敏配置 | 确认实现 | ASR 长期密钥不下发前端 |
| 用户问数 | 语音识别代理 | `POST /api/voice/asr` | 后端代理调用 ASR | 确认实现 | 前端上传 WAV，后端返回识别文本；不自动提交问数 |
| 结果展示 | 文本/表格/指标卡/图表/提示 | 随 SSE 结果或会话消息返回 | 通用结果结构 | 确认实现 | 前端组装图表 |

## 5. 管理侧接口设计

### 5.1 默认 Agent

#### GET /api/agent/default

用途：获取 MVP 固定默认 Agent，供管理侧和用户侧统一取得运行状态。  
状态：确认实现。

规则：

- MVP 阶段默认 Agent 固定存在，不提供创建、切换或删除入口。
- `agentId` 固定为 `default`，前端不得提供 Agent 选择。
- 若后端数据库使用内部主键，可在服务层映射，不暴露给前端作为选择项。

响应：

```json
{
  "code": 0,
  "message": "查询成功",
  "data": {
    "agentId": "default",
    "agentName": "MOM智能问数默认Agent",
    "agentStatus": "ENABLED",
    "isDefault": true,
    "ready": true,
    "missingItems": [],
    "warningItems": [
      {
        "code": "SEMANTIC_MODEL_NOT_READY",
        "message": "语义模型未就绪，问数结果准确性和指标口径一致性可能受影响"
      }
    ]
  }
}
```

阻断项响应示例：

```json
{
  "code": 0,
  "message": "查询成功",
  "data": {
    "agentId": "default",
    "agentName": "MOM智能问数默认Agent",
    "agentStatus": "ENABLED",
    "isDefault": true,
    "ready": false,
    "missingItems": [
      {
        "code": "LLM_MODEL_UNAVAILABLE",
        "message": "LLM 模型未配置或不可用"
      },
      {
        "code": "SCHEMA_NOT_READY",
        "message": "Schema 未初始化或初始化失败"
      }
    ],
    "warningItems": []
  }
}
```

默认 Agent 可用性规则：

| 检查项 | 是否阻断问数 | 缺失项编码 |
|---|---|---|
| LLM 模型未配置或不可用 | 是 | `LLM_MODEL_UNAVAILABLE` |
| 嵌入模型未配置或不可用 | 是 | `EMBEDDING_MODEL_UNAVAILABLE` |
| 当前生效数据源不存在 | 是 | `DATASOURCE_MISSING` |
| 数据源连接测试失败 | 是 | `DATASOURCE_TEST_FAILED` |
| Schema 未初始化或初始化失败 | 是 | `SCHEMA_NOT_READY` |
| 语义模型为空或未就绪 | 否 | `SEMANTIC_MODEL_NOT_READY` |
| Skill 无可用配置 | 否 | `SKILL_UNAVAILABLE` |
| 知识配置为空或未向量化 | 否 | `KNOWLEDGE_NOT_READY` |
| 预设问题为空 | 否 | `PRESET_QUESTION_EMPTY` |
| 语音配置停用或未配置 | 否 | `VOICE_CONFIG_UNAVAILABLE` |

规则：

- `missingItems` 只返回阻断正式问数的配置项；存在阻断项时 `ready=false`。
- `warningItems` 返回不阻断文本问数但可能影响问数效果或局部功能的配置项；仅存在风险项时 `ready=true`。
- `missingItems` 和 `warningItems` 均使用 `{ code, message }` 对象数组，不使用纯字符串数组。
- 语义模型未就绪不阻断问数，但结果准确性和指标口径一致性不做强保障。
- 语音配置未启用或未配置不阻断文本问数；用户点击语音识别按钮时返回语音输入不可用提示。

失败场景：

| 场景 | 处理 |
|---|---|
| 默认 Agent 初始化失败 | 返回 `code!=0`，提示联系管理员初始化默认 Agent |
| 默认 Agent 阻断项配置不完整 | `ready=false`，`missingItems` 返回缺失项 |

### 5.2 模型配置

#### GET /api/model-config/list

用途：查询模型配置列表，覆盖 LLM、EMBEDDING。  
状态：确认实现。

查询参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `modelCategory` | 否 | `LLM`、`EMBEDDING` |
| `enabledFlag` | 否 | 是否启用 |

#### POST /api/model-config/add

用途：新增模型配置。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "modelCategory": "LLM",
  "provider": "OpenAI-Compatible",
  "baseUrl": "https://example.com/v1",
  "apiKey": "sk-xxx",
  "modelName": "qwen-plus",
  "temperature": 0.7,
  "maxTokens": 4096,
  "enabledFlag": true,
  "defaultFlag": false
}
```

规则：

- `apiKey` 只保存，不在详情接口明文返回。
- 同一模型分类仅允许一条 `defaultFlag=true`。

#### PUT /api/model-config/update

用途：修改模型配置。  
状态：确认实现。

请求体：

```json
{
  "modelConfigId": "MODEL001",
  "agentId": "default",
  "modelCategory": "LLM",
  "provider": "OpenAI-Compatible",
  "baseUrl": "https://example.com/v1",
  "apiKey": "sk-xxx",
  "modelName": "qwen-plus",
  "temperature": 0.7,
  "maxTokens": 4096,
  "enabledFlag": true
}
```

规则：

- `modelConfigId` 必填。
- `apiKey` 为空或不传时，保留原密钥；传入新值时覆盖保存。
- 修改 `baseUrl`、`apiKey`、`modelName` 等调用字段后，建议将 `testStatus` 重置为 `UNTESTED`。
- 修改已生效模型时，不自动切换其他模型；生效关系仍由 `POST /api/model-config/activate/{id}` 控制。

#### POST /api/model-config/test

用途：测试模型连接。  
状态：确认实现。

请求体同模型配置，可附带 `testContent`。

响应：

```json
{
  "code": 0,
  "message": "连接测试成功",
  "data": {
    "testStatus": "SUCCESS",
    "durationMs": 1200,
    "errorMessage": null,
    "testTime": "2026-06-23 10:00:00"
  }
}
```

#### POST /api/model-config/activate/{id}

用途：切换指定模型配置为当前生效模型。  
状态：确认实现。

路径参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `id` | 是 | 模型配置标识 |

请求体：

```json
{
  "agentId": "default"
}
```

规则：

- 同一 `agentId + modelCategory` 下仅允许一条模型配置生效。
- 待生效模型必须处于启用状态，建议要求最近一次 `testStatus=SUCCESS`。
- 切换 LLM 或嵌入模型后，默认 Agent 可用性需重新计算；嵌入模型切换后，知识向量和 Schema/语义相关处理是否重建按后端实现提示。

响应：

```json
{
  "code": 0,
  "message": "生效成功",
  "data": {
    "modelConfigId": "MODEL001",
    "modelCategory": "LLM",
    "defaultFlag": true
  }
}
```

### 5.3 数据源配置

#### POST /api/datasource

用途：新增数据源。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "datasourceName": "MOM业务库",
  "datasourceType": "MYSQL",
  "host": "127.0.0.1",
  "port": 3306,
  "databaseName": "mom",
  "username": "readonly_user",
  "password": "******",
  "enabledFlag": true
}
```

规则：

- 数据源建议只读账号。
- 密码只保存，不明文回显。
- 创建后 `connectStatus=UNTESTED`，`schemaInitStatus=NOT_INITIALIZED`。

#### PUT /api/datasource/{id}

用途：修改数据源配置。  
状态：确认实现。

路径参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `id` | 是 | 数据源标识 |

请求体：

```json
{
  "agentId": "default",
  "datasourceName": "MOM业务库",
  "datasourceType": "MYSQL",
  "host": "127.0.0.1",
  "port": 3306,
  "databaseName": "mom",
  "username": "readonly_user",
  "password": "******",
  "enabledFlag": true
}
```

规则：

- `password` 为空或不传时，保留原密码；传入新值时覆盖保存。
- 修改连接关键字段后，`connectStatus` 建议重置为 `UNTESTED`，`schemaInitStatus` 建议重置为 `NOT_INITIALIZED` 或提示需要重新初始化。
- 若该数据源为当前生效数据源，修改后问数可用性需重新计算。

#### POST /api/datasource/{datasourceId}/test

用途：测试数据源连接。  
状态：确认实现。

响应：

```json
{
  "code": 0,
  "message": "连接测试成功",
  "data": {
    "connectStatus": "SUCCESS",
    "durationMs": 800,
    "errorMessage": null
  }
}
```

#### POST /api/agent/{agentId}/datasources/bind

用途：将一个数据源绑定为默认 Agent 的当前生效数据源。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "datasourceId": "DS001",
  "enabledFlag": true
}
```

规则：

- MVP 阶段默认 Agent 仅允许一个生效数据源。
- 重新绑定数据源时，旧数据源不再参与问数；是否保留旧配置记录由后端实现决定，但问数链路只读取当前绑定数据源。
- 问数时固定使用当前绑定数据源，不做数据源路由。
- MVP 不在用户侧展示数据源选择入口。

#### POST /api/agent/{agentId}/datasources/init

用途：初始化已绑定数据源的 Schema。  
状态：确认实现。

前置：

- 数据源连接测试成功。
- 数据源已绑定默认 Agent。
- Schema 初始化流程参考 DataAgent：后端拉取库表字段并返回表数量、字段数量、初始化状态。MVP 按同步返回设计；如实际库表较多，可后续扩展任务进度查询。

请求体：

```json
{
  "datasourceId": "DS001"
}
```

响应：

```json
{
  "code": 0,
  "message": "Schema初始化成功",
  "data": {
    "datasourceId": "DS001",
    "schemaInitStatus": "SUCCESS",
    "tableCount": 32,
    "fieldCount": 420,
    "durationMs": 3000
  }
}
```

#### GET /api/datasources/{datasourceId}/schema

用途：查询已初始化 Schema 的表和字段，用于表范围配置、语义模型字段选择和字段来源校验。  
状态：确认实现。

路径参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `datasourceId` | 是 | 数据源标识 |

查询参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `keyword` | 否 | 表名、表说明、字段名、字段说明搜索 |
| `tableName` | 否 | 指定表名 |
| `inQueryScope` | 否 | 是否只返回纳入问数范围的表 |

响应：

```json
{
  "code": 0,
  "message": "查询成功",
  "data": {
    "datasourceId": "DS001",
    "schemaInitStatus": "SUCCESS",
    "tables": [
      {
        "tableName": "work_order",
        "tableComment": "工单表",
        "fieldCount": 24,
        "inQueryScope": true,
        "isCoreTable": true,
        "fields": [
          {
            "columnName": "status",
            "columnComment": "工单状态",
            "dataType": "varchar",
            "nullable": false,
            "primaryKey": false
          }
        ]
      }
    ]
  }
}
```

规则：

- 本接口读取 Schema 初始化后的缓存结果，不直接实时扫描业务库。
- `schemaInitStatus` 非 `SUCCESS` 时返回空表字段并提示先初始化 Schema。
- 表范围配置和语义模型保存时，均应以本接口返回的表字段作为合法来源。

#### POST /api/agent/{agentId}/datasources/tables

用途：保存问数表范围。  
状态：确认实现。

请求体：

```json
{
  "datasourceId": "DS001",
  "tables": [
    {
      "tableName": "work_order",
      "inQueryScope": true,
      "isCoreTable": true,
      "sortOrder": 1
    }
  ]
}
```

规则：

- `tableName` 必须来自已初始化 Schema。
- 未纳入问数范围的表不进入默认 Agent 的表选择和语义约束。

### 5.4 Skill 管理

Skill 管理纳入 MVP，支持导入、删除、启用、停用和测试。默认 Agent 仅可调用已启用 Skill。

#### GET /api/skills

用途：查询默认 Agent 可用 Skill 列表。  
状态：确认实现。

查询参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `agentId` | 是 | 默认 Agent 标识 |
| `enabledFlag` | 否 | 是否启用 |

#### POST /api/skills/import

用途：导入 Skill ZIP 包并自动安装。  
状态：确认实现。

请求格式：`multipart/form-data`

| Part | 必填 | 说明 |
|---|---|---|
| `agentId` | 是 | 固定传 `default` |
| `skillPackage` | 是 | Skill ZIP 包，大小不超过 100MB |
| `overwriteFlag` | 否 | 是否覆盖同编码 Skill，默认 `false` |

响应：

```json
{
  "code": 0,
  "message": "导入成功",
  "data": {
    "skillId": "SKILL001",
    "skillCode": "inventory_query",
    "skillName": "库存查询 Skill",
    "enabledFlag": false
  }
}
```

规则：

- 仅支持 `.zip` 格式。
- 单个 Skill ZIP 包大小限制 100MB。
- 上传后后端自动解压、校验、安装并登记 Skill 信息。
- 导入安装成功后默认停用，由管理员确认后启用。
- Skill 编码重复且未允许覆盖时返回失败。
- 导入、解压、校验或安装失败不得影响已有 Skill。

#### PUT /api/skills/{skillId}/enable

用途：启用/停用 Skill。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "enabledFlag": true
}
```

#### DELETE /api/skills/{skillId}

用途：删除 Skill。  
状态：确认实现。

请求参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `agentId` | 是 | 固定传 `default` |

规则：

- 删除后默认 Agent 不再调用该 Skill。
- 如 Skill 正在被任务调用，后端应返回状态不允许或延后删除。

#### POST /api/skills/{skillId}/test

用途：测试 Skill 是否可调用。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "testParams": {}
}
```

#### Skill 存储与 Agent 调用规则

Skill 内容不建议整体写入数据库。MVP 采用“文件/对象存储 + 关系数据库元数据 + Agent 运行时渐进式读取”的方式。

存储分工：

| 内容 | 存储位置 | 说明 |
|---|---|---|
| Skill ZIP 原包 | 文件/对象存储 | 用于审计、重装、版本追溯 |
| 解压安装目录 | 文件/对象存储 | 保存 `SKILL.md`、`references/`、`scripts/`、`templates/`、`assets/` 等文件 |
| Skill 元数据 | 关系数据库 | 保存编码、名称、版本、安装路径、入口文件、启停状态、安装状态、测试状态、hash |
| Skill 运行过程状态 | 内存/Redis 可选 | 保存本次 Agent 调用的临时状态，不作为业务事实来源 |

安装目录建议：

```text
/storage/agents/default/skills/
  {skillCode}/
    {version}/
      skill.json
      SKILL.md
      references/
      scripts/
      templates/
      assets/
```

渐进式披露规则：

1. Agent 运行时只先读取已启用 Skill 的摘要信息，例如 `skillCode`、`skillName`、`description`、`tags`。
2. 命中候选 Skill 后，再读取该 Skill 的 `SKILL.md`。
3. 只有 `SKILL.md` 明确需要时，才继续读取 `references/`、`scripts/`、`templates/` 或 `assets/`。
4. 不允许在每次问数开始时把所有 Skill 文件一次性注入上下文。
5. Skill 调用由后端 Agent 运行时执行，用户侧和前端不直接调用 Skill。

LangGraph 编排建议：

```text
SkillRouterNode
  -> SkillLoaderNode
  -> ToolExecutorNode
  -> ResultMergeNode
```

安全规则：

- ZIP 解压必须防路径穿越。
- 不允许覆盖安装目录外文件。
- 导入失败不得影响已安装 Skill。
- 运行脚本类 Skill 时，后端必须做权限、超时和资源限制。
- MVP 可先不做 Skill 向量召回；当 Skill 数量变多后，再考虑把 Skill 摘要写入向量库辅助选择。

### 5.5 智能体知识

#### POST /api/agent-knowledge/query/page

用途：分页查询智能体知识。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "knowledgeType": "DOCUMENT",
  "vectorStatus": "SUCCESS",
  "pageNum": 1,
  "pageSize": 10
}
```

#### POST /api/agent-knowledge/create

用途：新增文档、问答对、FAQ 知识。  
状态：确认实现。

请求格式：`multipart/form-data`

| Part | 必填 | 说明 |
|---|---|---|
| `agentId` | 是 | 默认 Agent 标识 |
| `title` | 是 | 知识标题 |
| `type` | 是 | `DOCUMENT`、`QA`、`FAQ` |
| `content` | 否 | 非文件类知识内容 |
| `file` | 否 | 文档类知识文件 |
| `recallFlag` | 否 | 是否参与召回 |

#### PUT /api/agent-knowledge/{knowledgeId}

用途：编辑智能体知识。  
状态：确认实现。

路径参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `knowledgeId` | 是 | 知识标识 |

请求体：

```json
{
  "agentId": "default",
  "knowledgeTitle": "库存查询FAQ",
  "knowledgeType": "FAQ",
  "question": "如何查询低于安全库存的物料？",
  "answerContent": "可按物料库存与安全库存阈值比较查询。",
  "recallFlag": true
}
```

规则：

- 文档类知识如需替换文件，仍使用新增/上传类 multipart 能力，或后续单独扩展文件替换接口。
- 修改知识正文、问答内容或文件后，`vectorStatus` 应重置为 `PENDING` 或进入 `PROCESSING`，由后端重新向量化。

#### DELETE /api/agent-knowledge/{knowledgeId}

用途：删除智能体知识。  
状态：确认实现。

规则：

- 删除知识条目时，应同步删除或标记失效对应向量索引。
- 删除后不再参与召回。

#### PUT /api/agent-knowledge/{knowledgeId}/recall

用途：设置智能体知识是否参与召回。  
状态：确认实现。

请求体：

```json
{
  "recallFlag": true
}
```

#### POST /api/agent-knowledge/{knowledgeId}/vectorize/retry

用途：重试智能体知识向量化。  
状态：确认实现。

规则：

- 仅 `vectorStatus=FAILED` 或需要重新处理的知识允许重试。
- 重试后状态进入 `PROCESSING`，完成后更新为 `SUCCESS` 或 `FAILED`。

#### POST /api/agent-knowledge/{knowledgeId}/recall-test

用途：测试智能体知识是否可召回。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "query": "如何查询低于安全库存的物料？",
  "topK": 5
}
```

响应：

```json
{
  "code": 0,
  "message": "召回测试完成",
  "data": {
    "hits": [
      {
        "knowledgeId": "K001",
        "title": "库存查询FAQ",
        "similarity": 0.86,
        "snippet": "低于安全库存的物料可通过库存预警查询..."
      }
    ]
  }
}
```

### 5.6 业务知识

#### GET /api/business-knowledge

用途：查询业务知识列表。  
状态：确认实现。

查询参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `agentId` | 否 | 默认 Agent 标识 |
| `keyword` | 否 | 术语/描述搜索 |
| `enabledFlag` | 否 | 是否启用 |
| `recallFlag` | 否 | 是否参与召回 |

#### POST /api/business-knowledge

用途：新增业务术语、业务描述、同义词。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "termName": "安全库存",
  "description": "物料库存低于该阈值时需要预警",
  "synonyms": ["库存下限", "最低库存"],
  "tagNames": ["库存"],
  "enabledFlag": true,
  "recallFlag": true
}
```

#### PUT /api/business-knowledge/{termId}

用途：编辑业务知识。  
状态：确认实现。

路径参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `termId` | 是 | 业务知识标识 |

请求体：

```json
{
  "agentId": "default",
  "termName": "安全库存",
  "description": "物料库存低于该阈值时需要预警",
  "synonyms": ["库存下限", "最低库存"],
  "tagNames": ["库存"],
  "enabledFlag": true,
  "recallFlag": true
}
```

规则：

- 修改 `termName`、`description`、`synonyms` 后，`vectorStatus` 应重置为 `PENDING` 或进入 `PROCESSING`，由后端重新向量化。
- 业务知识接口中的 `synonyms` 使用数组；后端入库时统一序列化为 JSON 数组字符串。

#### DELETE /api/business-knowledge/{termId}

用途：删除业务知识。  
状态：确认实现。

规则：

- 删除业务知识时，应同步删除或标记失效对应向量索引。

#### PUT /api/business-knowledge/{termId}/enable

用途：启用或停用业务知识。  
状态：确认实现。

请求体：

```json
{
  "enabledFlag": true
}
```

#### PUT /api/business-knowledge/{termId}/recall

用途：设置业务知识是否参与召回。  
状态：确认实现。

请求体：

```json
{
  "recallFlag": true
}
```

#### POST /api/business-knowledge/{termId}/vectorize/retry

用途：重试业务知识向量化。  
状态：确认实现。

规则：

- 仅 `vectorStatus=FAILED` 或需要重新处理的业务知识允许重试。

#### POST /api/business-knowledge/recall-test

用途：测试业务知识召回。  
状态：确认实现。

### 5.7 语义模型

#### GET /api/semantic-model

用途：查询语义字段映射。  
状态：确认实现。

查询参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `agentId` | 是 | 默认 Agent 标识 |
| `datasourceId` | 否 | 数据源标识 |
| `tableName` | 否 | 表名 |
| `keyword` | 否 | 字段名、业务名、同义词搜索 |
| `enabledFlag` | 否 | 是否启用 |

#### POST /api/semantic-model

用途：新增语义字段映射。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "datasourceId": "1",
  "tableName": "work_order",
  "columnName": "status",
  "businessName": "工单状态",
  "synonyms": "状态,工单进度",
  "businessDescription": "用于区分工单当前执行状态",
  "columnComment": "状态",
  "dataType": "varchar",
  "enabledFlag": true
}
```

规则：

- 保存前校验表和字段来自已初始化 Schema。
- 语义字段映射不进入知识召回接口。
- 启用状态决定是否参与问数语义约束。
- 语义模型接口中的 `synonyms` 支持逗号分隔字符串；后端入库时应解析、去空、去重，并统一序列化为 JSON 数组字符串。

#### PUT /api/semantic-model/{semanticId}

用途：编辑语义字段映射。  
状态：确认实现。

路径参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `semanticId` | 是 | 语义字段映射标识 |

请求体：

```json
{
  "agentId": "default",
  "datasourceId": "DS001",
  "tableName": "work_order",
  "columnName": "status",
  "businessName": "工单状态",
  "synonyms": "状态,工单进度",
  "businessDescription": "用于区分工单当前执行状态",
  "columnComment": "状态",
  "dataType": "varchar",
  "enabledFlag": true
}
```

规则：

- `tableName + columnName` 必须来自 `GET /api/datasources/{datasourceId}/schema` 返回的已初始化 Schema。
- 若修改表名或字段名，需要重新校验字段来源。

#### PUT /api/semantic-model/{semanticId}/enable

用途：启用或停用语义字段映射。  
状态：确认实现。

请求体：

```json
{
  "enabledFlag": true
}
```

#### DELETE /api/semantic-model/{semanticId}

用途：删除语义字段映射。  
状态：确认实现。

规则：

- 删除后该字段映射不再参与问数语义约束。
- 不影响已初始化 Schema 缓存。

#### POST /api/semantic-model/import/excel

用途：Excel 导入语义模型。  
状态：确认实现。

请求格式：`multipart/form-data`

| Part | 必填 | 说明 |
|---|---|---|
| `agentId` | 是 | 默认 Agent 标识 |
| `datasourceId` | 是 | 数据源标识 |
| `file` | 是 | 语义模型 Excel |

导入模板：

语义模型导入模板是前后端约定的 Excel 表头和填写规则，用来保证用户批量导入的字段映射可以被后端稳定解析。MVP 模板建议至少包含以下列：

| 列名 | 必填 | 说明 |
|---|---|---|
| `tableName` | 是 | 数据库表名，必须来自已初始化 Schema |
| `columnName` | 是 | 数据库字段名，必须属于对应表 |
| `businessName` | 是 | 字段业务名称，例如“工单状态” |
| `synonyms` | 否 | 同义词，多个用逗号分隔 |
| `businessDescription` | 否 | 字段业务含义、口径说明 |
| `enabledFlag` | 否 | 是否启用，默认启用 |

导入规则：

- 表和字段必须能在当前绑定数据源的 Schema 中找到。
- 同一 `tableName + columnName` 重复时，默认按更新处理；如后端实现需要区分，可增加 `overwriteFlag`。
- 单行校验失败时应返回失败行号和原因，不应影响其他可导入行。

### 5.8 预设问题

#### GET /api/agent/{agentId}/preset-questions

用途：查询预设问题；用户侧展示时称为推荐问题。  
状态：确认实现。

查询参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `enabledOnly` | 否 | 用户侧调用时传 `true` |

#### POST /api/agent/{agentId}/preset-questions

用途：新增或保存预设问题。  
状态：确认实现。

请求体：

```json
{
  "questionContent": "按工单状态统计当前工单数量",
  "questionCategory": "工单",
  "sortOrder": 1,
  "enabledFlag": true
}
```

#### PUT /api/agent/{agentId}/preset-questions/{presetQuestionId}/enable

用途：启用或停用预设问题。  
状态：确认实现。

请求体：

```json
{
  "enabledFlag": true
}
```

#### PUT /api/agent/{agentId}/preset-questions/{presetQuestionId}/sort

用途：修改预设问题排序。  
状态：确认实现。

请求体：

```json
{
  "sortOrder": 1
}
```

#### DELETE /api/agent/{agentId}/preset-questions/{presetQuestionId}

用途：删除预设问题。  
状态：确认实现。

### 5.9 访问 API

本节为后置设计，不纳入 MVP 开发和联调范围。`X-API-Key`、API Key 管理和外部调用方法仅保留接口说明，MVP 不实现。MVP 阶段管理侧页面完全隐藏访问 API 入口，不做灰态展示。

#### GET /api/agent/{agentId}/api-key

用途：查询外部 API 访问后置设计状态和脱敏 Key。  
状态：MVP 不实现，仅保留设计说明。

响应：

```json
{
  "code": 0,
  "message": "查询成功",
  "data": {
    "apiOpenStatus": "NOT_OPEN",
    "apiEnabledFlag": false,
    "keyStatus": "NOT_GENERATED",
    "maskedKey": null,
    "generatedTime": null,
    "invokeUrl": "/api/v1/agent/invoke",
    "evaluationStatus": "PENDING"
  }
}
```

#### POST /api/agent/{agentId}/api-key/generate

用途：评估通过并开放外部 API 后，首次生成 API Key。  
状态：MVP 不实现，仅保留设计说明。

规则：

- 默认 MVP 不生成外部 API Key。
- 若后续开放，完整 Key 仅本次响应返回。
- 若后续开放，后端只保存摘要和脱敏值。
- 若后续开放，MVP 阶段只允许一个有效 Key。

#### POST /api/agent/{agentId}/api-key/reset

用途：评估通过并开放外部 API 后，重置 API Key。  
状态：MVP 不实现，仅保留设计说明。

规则：功能开放后，旧 Key 立即失效，新 Key 完整值仅本次响应返回。

#### POST /api/agent/{agentId}/api-key/enable

用途：评估通过并开放外部 API 后，启用/停用 API 访问。  
状态：MVP 不实现，仅保留设计说明。

请求参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `enabled` | 是 | `true` 启用，`false` 停用 |

#### DELETE /api/agent/{agentId}/api-key

用途：评估通过并开放外部 API 后，删除 API Key。  
状态：MVP 不实现，仅保留设计说明。

## 6. 用户侧接口设计

### 6.1 会话管理

#### GET /api/agent/{agentId}/sessions

用途：查询默认 Agent 下的历史会话。  
状态：确认实现。

#### POST /api/agent/{agentId}/sessions

用途：创建新会话。  
状态：确认实现。

请求体：

```json
{
  "title": "新会话",
  "userId": null
}
```

#### GET /api/sessions/{sessionId}/messages

用途：查询会话消息。  
状态：确认实现。

#### POST /api/sessions/{sessionId}/messages

用途：保存用户消息、Agent 回复或系统提示。  
状态：确认实现。

请求体：

```json
{
  "messageRole": "USER",
  "inputType": "TEXT",
  "messageContent": "按工单状态统计当前工单数量",
  "titleNeeded": true
}
```

响应：

```json
{
  "code": 0,
  "message": "保存成功",
  "data": {
    "messageId": "msg-user-001",
    "sessionId": "session-001",
    "messageRole": "USER",
    "inputType": "TEXT",
    "messageStatus": "SUCCESS"
  }
}
```

规则：

- 用户点击发送时，前端先调用本接口保存用户消息，并将返回的 `messageId` 作为 `userMessageId` 传给 SSE 问数接口。
- 用户侧前端不通过本接口创建 Agent 回复消息；Agent 回复消息由 `GET /api/stream/search` 后端创建并维护状态。
- 语音输入识别后的文本也按普通用户消息保存，`inputType=VOICE`。
- `messageRole`、`inputType`、`messageContent` 与数据模型字段保持一致；不再使用 `role`、`messageType`、`content` 作为正式接口字段。

#### PUT /api/sessions/{sessionId}/rename

用途：修改会话标题。  
状态：确认实现。

请求参数：`title`

#### PUT /api/sessions/{sessionId}/pin

用途：置顶/取消置顶会话。  
状态：确认实现。

请求参数：`isPinned`

#### DELETE /api/sessions/{sessionId}

用途：删除会话。  
状态：确认实现。

### 6.2 文本问数

#### GET /api/stream/search

用途：用户侧基于已保存的用户消息发起自然语言问数，服务端以 SSE 返回过程和结果。  
状态：确认实现。

查询参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `agentId` | 是 | 默认 Agent 标识 |
| `sessionId` | 是 | 当前历史会话标识 |
| `threadId` | 是 | 多轮上下文线程标识；MVP 阶段使用当前 `sessionId` |
| `userMessageId` | 是 | 已保存的用户消息标识；后端从该消息读取问题文本 |

规则：

- 用户侧输入区包含输入框、发送按钮、语音识别按钮和暂停会话按钮。
- 语音识别按钮只负责调用 `POST /api/voice/asr` 获取识别文本并填入输入框，不直接调用本接口。
- 发送按钮或回车发送是唯一进入问数链路的用户提交动作；发起 SSE 前必须已创建用户消息。
- 本接口不直接接收 `query`，避免 URL 参数、会话消息和历史记录之间出现内容不一致。
- 后端收到 SSE 请求后创建 Agent 回复消息，状态为 `PROCESSING`，并返回 `start` 事件。
- 暂停会话按钮只中止当前 `threadId` 对应的流式问数任务，不删除会话、不影响后续继续提问。
- 本接口不接收人工审核、人工反馈、拒绝计划、只 NL2SQL 等运行选项。
- 同一个 `sessionId/threadId` 同一时间只允许一个运行中的问数任务。
- 幂等键为 `sessionId + userMessageId`：同一用户消息只能对应一条 Agent 回复消息和一个问数任务，后端不得因浏览器重试、SSE 断线重连或用户重复点击而重复创建 Agent 回复消息。
- 若 `sessionId + userMessageId` 已有 `PROCESSING` 任务，后端应返回或复用已有 `agentMessageId` 和运行任务；若已处于 `SUCCESS`、`FAILED`、`STOPPED` 终态，后端不重复执行问数，前端应通过 `GET /api/sessions/{sessionId}/messages` 读取已落库结果。
- 数据库是消息和最终结果的事实来源；Redis 用于运行中任务状态、暂停信号和短期 SSE 事件缓冲。
- 流式过程不逐块写数据库；`complete/stopped/error` 终态前由后端先完成消息状态和结果落库。

运行时存储职责：

| 存储 | 职责 |
|---|---|
| 数据库 | 用户消息、Agent 回复消息、消息状态、最终 `metadata.resultPayload`、历史会话回显 |
| Redis Active Task | 当前运行中的任务状态，包含 `sessionId`、`threadId`、`userMessageId`、`agentMessageId`、任务状态和开始时间 |
| Redis Stop Flag | 暂停信号，供 Agent 执行链路检查并中止当前任务 |
| Redis Stream | 短期 SSE 事件缓冲，用于流式转发和短期断线恢复 |

与数据库设计的技术映射：

| 接口字段/职责 | 数据库技术落点 |
|---|---|
| `userMessageId` | `da_message.message_id`；Agent 回复消息通过 `da_message.user_message_id` 关联该用户消息 |
| `agentMessageId` | `da_message.message_id`，且 `messageRole=AGENT` |
| `sessionId + userMessageId` 幂等 | `da_chat_request_ledger.uk_session_user_message(session_id, user_message_id)` |
| `threadId` | `da_chat_request_ledger.thread_id` 和 `da_message.thread_id` |
| `complete.resultPayload` / `metadata.resultPayload` | Agent 回复消息 `da_message.metadata_json.resultPayload` |
| `STOPPED` | `da_chat_request_ledger.request_status=STOPPED`，Agent 回复消息 `da_message.message_status=STOPPED` |

SSE 响应事件：

| 事件 | 说明 |
|---|---|
| `start` | 后端已创建 Agent 回复消息并开始处理 |
| `message` | 过程消息或流式文本，返回节点输出 |
| `complete` | 问数链路完成，且最终结果已落库 |
| `stopped` | 用户主动暂停当前问数，且已输出内容已落库 |
| `error` | 问数链路异常，且错误状态已落库 |

`start` 事件示例：

```json
{
  "agentId": "default",
  "sessionId": "session-001",
  "threadId": "session-001",
  "userMessageId": "msg-user-001",
  "agentMessageId": "msg-agent-001",
  "messageStatus": "PROCESSING"
}
```

`message` 事件示例：

```json
{
  "agentId": "default",
  "sessionId": "session-001",
  "threadId": "session-001",
  "userMessageId": "msg-user-001",
  "agentMessageId": "msg-agent-001",
  "nodeName": "ReportGeneratorNode",
  "textType": "MARKDOWN",
  "text": "分析结果...",
  "error": false,
  "complete": false
}
```

`complete` 事件示例：

```json
{
  "agentId": "default",
  "sessionId": "session-001",
  "threadId": "session-001",
  "userMessageId": "msg-user-001",
  "agentMessageId": "msg-agent-001",
  "messageStatus": "SUCCESS",
  "resultPayload": {
    "resultType": "TABLE",
    "resultStatus": "SUCCESS",
    "textAnswer": "查询到 120 条工单，其中前 100 条如下。",
    "table": {
      "columns": [
        { "field": "workOrderNo", "title": "工单号" },
        { "field": "status", "title": "状态" }
      ],
      "rows": [],
      "total": 120,
      "limit": 100,
      "truncated": true
    },
    "indicators": [],
    "chart": null,
    "notice": null
  }
}
```

`stopped` 事件示例：

```json
{
  "agentId": "default",
  "sessionId": "session-001",
  "threadId": "session-001",
  "userMessageId": "msg-user-001",
  "agentMessageId": "msg-agent-001",
  "messageStatus": "STOPPED",
  "partialText": "已输出的内容..."
}
```

`textType` 建议枚举：

| 值 | 说明 | 用户侧默认展示 |
|---|---|---|
| `TEXT` | 普通文本 | 是 |
| `MARKDOWN` | Markdown 结果 | 是 |
| `RESULT_SET` | 结构化结果集过程片段 | 是，按安全展示组件渲染 |
| `JSON` | JSON 结构过程片段 | 是，仅用于安全结构化渲染 |
| `HTML` | 报告 HTML 或富文本过程片段 | 否，MVP 用户侧不直接渲染原始 HTML |
| `SQL` | SQL 过程信息 | 否，仅内部调试或问题排查使用 |
| `PYTHON` | Python 过程信息 | 否，仅内部调试或问题排查使用 |

展示边界：

- MVP 用户侧默认只展示文本、Markdown、安全结构化结果和最终 `resultPayload`。
- `SQL`、`PYTHON`、`HTML` 仅作为内部调试或排障事件类型保留，不默认下发给普通用户侧页面。
- 如后续需要展示 SQL、Python 或 HTML 过程信息，必须经过权限控制、脱敏和安全渲染处理。
- 前端不得直接执行或原样渲染 SSE 中的 HTML、SQL、Python 内容。

异常规则：

- 无法识别：返回边界提示，不生成业务结论。
- 条件不足：返回澄清提示。
- 无数据：返回无数据提示并保留会话消息。
- 用户暂停：停止当前流式任务，当前消息标记为 `STOPPED`，保留已输出内容。
- 服务异常：当前消息标记失败，不影响历史会话。

结果与性能规则：

- `complete` 事件必须返回展示级完整 `resultPayload`。
- `complete` 发出前，后端必须已将 Agent 回复消息状态更新为 `SUCCESS`，并保存最终 `metadata.resultPayload`。
- `complete.resultPayload` 与数据库中 Agent 回复消息的 `metadata.resultPayload` 保持同一份业务结构。
- 大结果按展示上限返回，不返回无限量原始数据；表格结果需包含 `total`、`limit`、`truncated`。
- 会话历史回显以数据库中的 Agent 回复消息为准，不依赖 Redis 中的短期事件。
- 普通网络断开不等于用户暂停；后端可继续执行并在完成后落库，用户重新进入会话时读取数据库结果。

#### POST /api/stream/stop

用途：用户点击暂停会话按钮时，中止当前正在流式输出的问数任务。  
状态：确认实现。

请求体：

```json
{
  "agentId": "default",
  "threadId": "session-001",
  "sessionId": "session-001"
}
```

响应：

```json
{
  "code": 0,
  "message": "当前问数已暂停",
  "data": {
    "threadId": "session-001",
    "agentMessageId": "msg-agent-001",
    "messageStatus": "STOPPED"
  }
}
```

规则：

- `threadId` 必填，MVP 阶段使用当前 `sessionId`。
- `sessionId` 必填，用于定位当前历史会话。
- 前端不传 `messageId`；后端根据 Redis Active Task 定位当前运行中的 `agentMessageId`。
- 暂停请求写入 Redis Stop Flag，Agent 执行链路检查到停止信号后中止当前任务。
- 后端将 Agent 回复消息标记为 `STOPPED` 并保存已输出内容后，再推送 `stopped` 事件。
- 暂停只影响当前正在执行的问数任务，不删除会话、不清空消息、不阻止用户继续发送新问题。
- 如果当前 `threadId` 没有运行中的任务，返回 `code!=0` 并提示当前无可暂停任务。

### 6.3 语音输入

MVP 语音能力只作为输入辅助，不作为独立问数链路。用户侧输入区提供输入框、发送按钮、语音识别按钮和暂停会话按钮。前端采集音频并转换为 WAV 后上传后端，后端代理调用 ASR 服务并返回识别文本；前端将识别文本填入输入框，用户可编辑确认，再点击发送按钮或回车发送。发送后仍走普通文本问数接口 `/api/stream/search`；暂停会话按钮只中止当前流式问数任务，不删除会话、不自动发起新问题。

设计结论：

- 前端只上传 WAV 音频，音频格式转换由前端完成。
- 后端作为 ASR 代理接收 WAV，读取管理侧保存的 ASR 配置并调用 ASR 服务。
- ASR `apiKey`、`secretKey` 等长期密钥只在后端加密保存和使用，不向前端下发。
- 后端不保存原始音频，MVP 不保存独立语音识别记录。
- 识别结果只填入输入框，不自动发起问数。
- 保存用户消息时，通过 `inputType=VOICE` 标识输入来源。

#### GET /api/voice/config

用途：查询语音输入配置，供用户侧决定是否展示麦克风入口、支持格式、语言和录音限制。  
状态：确认实现。

响应：

```json
{
  "code": 0,
  "message": "查询成功",
  "data": {
    "enabled": true,
    "mode": "BACKEND_PROXY",
    "provider": "DASHSCOPE",
    "language": "zh-CN",
    "supportedFormats": ["WAV"],
    "maxDurationSeconds": 60,
    "maxFileSizeMb": 10,
    "allowedMimeTypes": ["audio/wav", "audio/x-wav"],
    "asrTimeoutSeconds": 30,
    "tips": "请使用普通话提问，识别后可编辑再发送"
  }
}
```

规则：

- 本接口供用户侧读取时，不返回 `apiKey`、`secretKey`、完整 `baseUrl` 等敏感配置。

#### GET /api/voice/config/admin

用途：管理侧编辑页查询语音输入配置，返回可回填的非敏感字段和敏感字段脱敏状态。  
状态：确认实现。

响应：

```json
{
  "code": 0,
  "message": "查询成功",
  "data": {
    "configId": "VOICE001",
    "enabled": true,
    "mode": "BACKEND_PROXY",
    "provider": "DASHSCOPE",
    "baseUrlMask": "https://asr.example.com",
    "modelName": "paraformer-realtime-v2",
    "language": "zh-CN",
    "supportedFormats": ["WAV"],
    "allowedMimeTypes": ["audio/wav", "audio/x-wav"],
    "maxDurationSeconds": 60,
    "maxFileSizeMb": 10,
    "asrTimeoutSeconds": 30,
    "apiKeyConfigured": true,
    "apiKeyMask": "sk-***abcd",
    "secretKeyConfigured": false,
    "secretKeyMask": null,
    "tips": "请使用普通话提问，识别后可编辑再发送",
    "updatedTime": "2026-06-24 13:30:00"
  }
}
```

规则：

- 管理侧回显也不得返回 `apiKey`、`secretKey` 明文。
- `baseUrl` 如包含租户、Token 或签名参数，应只返回 `baseUrlMask` 或脱敏后的地址。
- 用户侧页面不得调用本接口作为语音配置来源。

#### PUT /api/voice/config

用途：管理侧保存语音输入配置。  
状态：确认实现。

请求体：

```json
{
  "enabled": true,
  "mode": "BACKEND_PROXY",
  "provider": "DASHSCOPE",
  "baseUrl": "https://asr.example.com",
  "modelName": "paraformer-realtime-v2",
  "apiKey": "sk-***",
  "secretKey": "optional-secret",
  "language": "zh-CN",
  "maxDurationSeconds": 60,
  "maxFileSizeMb": 10,
  "allowedMimeTypes": ["audio/wav", "audio/x-wav"],
  "asrTimeoutSeconds": 30
}
```

规则：

- `mode=BACKEND_PROXY` 表示前端上传 WAV，后端代理调用 ASR 服务。
- `apiKey`、`secretKey` 等敏感字段由后端加密保存，查询时只允许脱敏展示或返回是否已配置。
- 即使语音识别完成，也必须由用户点击发送按钮或回车确认发送。
- 若语音配置停用、配置不完整、ASR 调用失败或识别结果为空，前端提示用户重新录入或改用文本输入，不进入后端问数链路。

#### POST /api/voice/asr

用途：前端点击语音识别按钮后，将 WAV 音频上传后端，由后端代理调用 ASR 服务并返回识别文本。  
状态：确认实现。  
请求类型：`multipart/form-data`

表单参数：

| 参数 | 必填 | 说明 |
|---|---|---|
| `sessionId` | 是 | 当前会话标识，用于语音识别限流和前端问题归属；本接口不创建会话消息 |
| `file` | 是 | WAV 音频文件；前端负责录音和格式转换 |
| `language` | 否 | 识别语言，默认使用语音配置中的 `language` |

工程约束：

| 约束项 | 默认口径 |
|---|---|
| 文件格式 | 仅支持 WAV |
| MIME 类型 | 仅允许 `audio/wav`、`audio/x-wav` |
| 文件大小 | 默认不超过 10MB，可由语音配置调整 |
| 音频时长 | 默认不超过 60 秒，可由语音配置调整 |
| ASR 调用超时 | 默认 30 秒，可由语音配置调整 |
| 调用频率 | MVP 无用户鉴权，按 `sessionId` 和客户端 IP 做轻量限频；默认同一 `sessionId` 每分钟不超过 10 次，同一 IP 每分钟不超过 30 次 |
| 前端转换 | 浏览器原始录音格式可能是 WebM/OGG，MVP 要求前端转换为 WAV 后再上传；后端转码不纳入当前接口口径 |

`clientIp` 来源规则：

- 无可信代理时取请求 `remote address`。
- 存在可信网关或反向代理时，仅从可信代理透传头解析真实 IP。
- 未配置可信代理时不得直接信任 `X-Forwarded-For`、`X-Real-IP` 等客户端可伪造请求头。

响应：

```json
{
  "code": 0,
  "message": "识别成功",
  "data": {
    "sessionId": "session-001",
    "text": "查询今天工单完成情况",
    "language": "zh-CN",
    "inputFormat": "WAV"
  }
}
```

规则：

- 本接口只返回识别文本，不创建会话消息，不调用问数接口。
- `sessionId` 仅用于语音识别限流和前端问题归属校验，不代表语音识别结果已进入会话历史。
- 后端必须校验文件扩展名、MIME 类型和 WAV 文件头；收到非 WAV 文件时返回参数错误。
- 超过文件大小、时长或调用频率限制时，直接返回失败，不调用 ASR 供应方。
- ASR 供应方调用必须设置超时时间，超时后返回明确错误，不进入问数链路。
- 后端使用管理侧保存的 ASR 配置调用供应方服务，前端不接触 ASR 长期密钥。
- MVP 不保存原始音频文件，不保存独立语音识别记录。
- 识别失败、识别文本为空、语音配置不可用时，返回明确错误提示，前端不进入问数链路。

错误码建议：

| 错误码 | 触发场景 | 前端提示 |
|---|---|---|
| `VOICE_CONFIG_UNAVAILABLE` | 语音配置停用、缺失或 ASR 密钥未配置 | 语音输入不可用，请改用文本输入 |
| `VOICE_FILE_REQUIRED` | 未上传音频文件 | 请重新录入语音 |
| `VOICE_FORMAT_UNSUPPORTED` | 文件不是 WAV，MIME 或文件头不合法 | 当前仅支持 WAV 格式 |
| `VOICE_FILE_TOO_LARGE` | 文件超过大小限制 | 录音过长，请缩短后重试 |
| `VOICE_DURATION_EXCEEDED` | 音频时长超过限制 | 录音超过时长限制，请缩短后重试 |
| `VOICE_ASR_TIMEOUT` | ASR 调用超时 | 语音识别超时，请重试或改用文本输入 |
| `VOICE_ASR_PROVIDER_FAILED` | ASR 供应方返回失败 | 语音识别失败，请重试或改用文本输入 |
| `VOICE_TEXT_EMPTY` | ASR 成功但识别文本为空 | 未识别到有效内容，请重新录入 |
| `VOICE_RATE_LIMITED` | 超过调用频率限制 | 语音识别过于频繁，请稍后再试 |

前端提交文本消息示例：

```json
{
  "messageRole": "USER",
  "inputType": "VOICE",
  "messageContent": "查询低于安全库存的物料",
  "metadata": {
    "voiceMode": "BACKEND_PROXY"
  },
  "titleNeeded": true
}
```

### 6.4 推荐问题

用户侧复用管理侧预设问题接口：

`GET /api/agent/{agentId}/preset-questions?enabledOnly=true`

规则：

- 用户侧展示名称为“推荐问题”。
- 数据对象仍为“预设问题”。
- 只展示启用状态的问题，按 `sortOrder` 排序。
- 获取失败时展示空状态，不影响文本输入。

## 7. 外部系统接口设计

本章为外部调用后置方案。当前阶段保留 `X-API-Key` 鉴权方式和 API 调用方法，但默认不对外开放，也不纳入默认 MVP 联调范围。

### POST /api/v1/agent/invoke

用途：评估通过并开放外部 API 后，外部系统通过 API Key 调用默认 Agent 问数能力。  
状态：MVP 不实现，仅保留设计说明。  
鉴权：开放后使用请求头 `X-API-Key`。
版本策略：该接口面向外部系统，若开放则从 `/api/v1` 固定契约开始；后续如请求/响应字段发生破坏性变化，应新增 `/api/v2/agent/invoke`，并保留 v1 兼容周期。

请求头：

| Header | 必填 | 说明 |
|---|---|---|
| `Content-Type: application/json` | 是 | JSON 请求 |
| `X-API-Key` | 是 | 外部 API 开放后，由管理侧生成的有效 Key |

请求体：

```json
{
  "sessionId": null,
  "question": "按工单状态统计当前工单数量",
  "inputType": "TEXT",
  "responseMode": "BLOCKING",
  "metadata": {
    "caller": "MOM_BACKEND"
  }
}
```

响应：

```json
{
  "code": 0,
  "message": "调用成功",
  "data": {
    "sessionId": "S001",
    "messageId": "M001",
    "threadId": "T001",
    "resultType": "CHART",
    "resultStatus": "SUCCESS",
    "resultSummary": "当前工单按状态统计如下...",
    "textAnswer": "当前工单共 120 条...",
    "table": null,
    "indicators": [],
    "chart": {
      "chartType": "PIE",
      "chartTitle": "工单状态占比",
      "dimensionName": "工单状态",
      "metricName": "工单数量",
      "unit": "条",
      "chartData": [
        { "name": "执行中", "value": 80 },
        { "name": "已完成", "value": 40 }
      ]
    },
    "notice": null
  }
}
```

失败场景：

| 场景 | 处理 |
|---|---|
| 外部 API 未开放 | 返回访问不可用，不进入问数链路 |
| Key 缺失 | 外部 API 开放后返回鉴权失败，不进入问数链路 |
| Key 错误/已删除/已失效 | 外部 API 开放后返回鉴权失败 |
| API 访问已停用 | 外部 API 开放后返回访问不可用 |
| 默认 Agent 配置不可用 | 返回配置不可用和缺失项 |
| 问题超出范围 | 返回边界提示，不生成业务结论 |

## 8. 结果数据契约

设计结论：

- MVP 不单独设计“问数结果查询中心”或独立结果查询接口。
- 问数结果随 SSE 流返回，并在最终消息中作为 `resultPayload` 或 `metadata.resultPayload` 保存。
- MVP 不照搬 DataAgent “主要由前端在 SSE 过程中调用保存接口”的方式；最终结构化结果应由后端在问数完成时兜底持久化，避免前端刷新、断线或保存失败导致结果丢失。
- MVP 强制保存用户问题和最终回答/最终结构化结果；中间过程节点不强制持久化。
- 不保存中间过程不会导致下次打开会话时最终问数结果消失，因为会话历史回显依赖最终消息和 `metadata.resultPayload`。
- 若后续需要回看 SQL、执行计划、节点过程或排查问题，可再增加可选的过程日志保存，不作为用户侧历史会话的必要条件。
- 会话历史加载时，通过 `GET /api/sessions/{sessionId}/messages` 取回消息及其结果 payload。
- 表格、指标卡、图表均返回通用结构，统一使用 `table`、`indicators`、`chart`、`notice` 字段，前端根据 `chartType` 和数据组装 ECharts 或其他可视化组件。
- `complete` 事件返回展示级完整 `resultPayload`；展示级完整表示前端可直接渲染，不代表返回数据库查询到的全部原始明细。
- 大表格结果按展示上限返回 `rows`，并通过 `total`、`limit`、`truncated` 标识总量和截断状态。

### 8.1 问数结果

```json
{
  "sessionId": "S001",
  "messageId": "M001",
  "agentId": "default",
  "resultType": "TABLE",
  "resultStatus": "SUCCESS",
  "resultSummary": "查询到 5 条低于安全库存的物料",
  "textAnswer": "查询到 5 条低于安全库存的物料",
  "table": {},
  "indicators": [],
  "chart": null,
  "notice": null,
  "createdTime": "2026-06-23 10:00:00"
}
```

### 8.2 表格结果

```json
{
  "columns": [
    { "field": "materialCode", "title": "物料编码" },
    { "field": "materialName", "title": "物料名称" },
    { "field": "stockQty", "title": "当前库存" },
    { "field": "safeStockQty", "title": "安全库存" }
  ],
  "rows": [
    {
      "materialCode": "M001",
      "materialName": "轴承",
      "stockQty": 8,
      "safeStockQty": 20
    }
  ],
  "total": 1,
  "limit": 100,
  "truncated": false
}
```

### 8.3 指标卡结果

```json
{
  "indicatorName": "当前工单总数",
  "indicatorValue": 120,
  "unit": "条"
}
```

### 8.4 图表结果

```json
{
  "chartType": "BAR",
  "chartTitle": "不同设备停机时长对比",
  "dimensionName": "设备",
  "metricName": "停机时长",
  "unit": "小时",
  "chartData": [
    { "name": "设备A", "value": 3.5 },
    { "name": "设备B", "value": 1.2 }
  ]
}
```

规则：

- 后端不返回完整 ECharts option。
- 前端根据 `chartType`、`dimensionName`、`metricName`、`unit`、`chartData` 组装图表。
- MVP 图表类型支持 `PIE`、`LINE`、`BAR`。

### 8.5 运行提示

```json
{
  "noticeId": "N001",
  "sessionId": "S001",
  "messageId": "M001",
  "noticeType": "CLARIFICATION",
  "noticeContent": "请补充查询时间范围或统计口径"
}
```

## 9. 状态与枚举

| 枚举 | 值 | 说明 |
|---|---|---|
| `modelCategory` | `LLM`、`EMBEDDING` | 模型分类 |
| `testStatus` | `UNTESTED`、`SUCCESS`、`FAILED` | 模型/数据源/Skill 测试状态 |
| `schemaInitStatus` | `NOT_INITIALIZED`、`INITIALIZING`、`SUCCESS`、`FAILED` | Schema 初始化状态 |
| `knowledgeType` | `DOCUMENT`、`QA`、`FAQ` | 智能体知识类型 |
| `vectorStatus` | `PENDING`、`PROCESSING`、`SUCCESS`、`FAILED` | 知识向量化状态 |
| `messageRole` | `USER`、`AGENT`、`SYSTEM` | 会话消息角色 |
| `inputType` | `TEXT`、`VOICE`、`PRESET_QUESTION`、`SYSTEM` | 输入来源 |
| `resultType` | `TEXT`、`TABLE`、`INDICATOR`、`CHART`、`CLARIFICATION`、`ERROR` | 问数结果类型 |
| `messageStatus` | `PROCESSING`、`SUCCESS`、`FAILED`、`STOPPED` | 会话消息状态 |
| `resultStatus` | `PROCESSING`、`SUCCESS`、`FAILED`、`NO_DATA`、`STOPPED` | 问数结果状态 |
| `chartType` | `PIE`、`LINE`、`BAR` | 图表类型 |
| `keyStatus` | `NOT_GENERATED`、`VALID`、`DELETED`、`INVALID` | API Key 状态 |
| `noticeType` | `NO_DATA`、`CLARIFICATION`、`CONFIG_UNAVAILABLE`、`VOICE_INPUT_UNAVAILABLE`、`SERVICE_ERROR` | 运行提示类型 |

枚举命名可在后续开发评审时改为中文值或数据库值，但前后端、数据模型和测试用例必须统一。

## 10. 关键缺口与后置评估项

| 缺口/评估项 | 影响 | 建议 |
|---|---|---|
| 默认 Agent 查询接口需要按固定 Agent 落地 | 前端需要统一获取默认 Agent 状态 | 实现 `GET /api/agent/default`，固定返回 `agentId=default` |
| Skill 管理接口需要新建 | 管理侧 Skill 导入、删除、启停、测试需要联调 | 实现 `/api/skills` 系列接口 |
| 外部调用接口 `POST /api/v1/agent/invoke` 不实现 | 外部系统接入能力暂不提供 | MVP 只保留设计说明，不开发、不联调 |
| 语音输入配置和 ASR 代理接口需要新建 | 用户侧需要知道是否展示麦克风和识别参数，管理侧需要脱敏回显配置，并通过后端完成语音识别 | 实现 `GET /api/voice/config`、`GET /api/voice/config/admin`、`PUT /api/voice/config`、`POST /api/voice/asr`；前端上传 WAV，后端代理调用 ASR |
| 知识召回测试接口需要新建 | 管理侧无法验证知识是否可召回 | 实现智能体知识和业务知识 recall-test |
| 当前 API Key 页面示例调用会话接口，不是后置 invoke 接口 | 若后续开放外部 API，对接开发人员会误用接口 | 评估开放后，将示例统一改为 `POST /api/v1/agent/invoke` |
| 统一响应格式需要落地 | 前后端错误处理需要一致 | 统一采用 `code/message/data` |
| 系统提示词不开放配置 | 可能误纳入 MVP 页面 | MVP 接口文档不纳入提示词编辑接口 |

## 11. 联调主流程

### 11.1 管理侧配置联调

1. `GET /api/agent/default` 获取默认 Agent。
2. `POST /api/model-config/add` 保存 LLM、Embedding 配置。
3. `POST /api/model-config/test` 测试模型。
4. `POST /api/model-config/activate/{id}` 设置每类生效模型。
5. `POST /api/datasource` 保存数据源。
6. `POST /api/datasource/{datasourceId}/test` 测试连接。
7. `POST /api/agent/default/datasources/bind` 绑定当前生效数据源。
8. `POST /api/agent/default/datasources/init` 初始化 Schema。
9. `POST /api/semantic-model/import/excel` 或 `POST /api/semantic-model` 维护语义模型。
10. `POST /api/skills/import`、`PUT /api/skills/{skillId}/enable`、`DELETE /api/skills/{skillId}` 维护 Skill。
11. `POST /api/agent-knowledge/create`、`POST /api/business-knowledge` 维护知识。
12. `POST /api/agent-knowledge/{knowledgeId}/recall-test`、`POST /api/business-knowledge/recall-test` 做知识召回测试。
13. `POST /api/agent/default/preset-questions` 维护预设问题。
14. 外部 API 页面完全隐藏；默认 MVP 不实现 API Key 生成和外部调用。

### 11.2 用户侧问数联调

1. `GET /api/agent/default` 获取默认 Agent 和运行状态。
2. `GET /api/agent/default/preset-questions?enabledOnly=true` 展示推荐问题。
3. `POST /api/agent/default/sessions` 创建会话。
4. `POST /api/sessions/{sessionId}/messages` 保存用户问题，后端返回 `userMessageId`。
5. `GET /api/stream/search?agentId=default&sessionId={sessionId}&threadId={sessionId}&userMessageId={userMessageId}` 发起 SSE 问数。
6. 后端创建 Agent 回复消息，返回 `start` 事件并下发 `agentMessageId`。
7. 前端按 SSE `message` 事件展示过程文本、表格、图表、指标卡或提示。
8. 前端默认不展示、不执行、不原样渲染 SSE 中的 SQL、Python 和原始 HTML 调试内容。
9. `complete` 事件返回展示级完整 `resultPayload`；前端可直接渲染最终结果。
10. 问数处理中用户点击暂停会话按钮时，调用 `POST /api/stream/stop` 中止当前流式任务。
11. `GET /api/sessions/{sessionId}/messages` 切换历史会话时加载消息。
12. SSE 断线重连、浏览器自动重试或重复点击发送时，前端继续使用同一个 `userMessageId`；后端按 `sessionId + userMessageId` 幂等处理，不重复创建 Agent 回复消息。

### 11.3 语音输入联调

1. `GET /api/voice/config` 获取语音输入配置。
2. 前端展示麦克风入口，录音并转换为 WAV。
3. 前端调用 `POST /api/voice/asr`，携带 `sessionId` 并上传 WAV。
4. 后端读取 ASR 配置并代理调用 ASR 服务，返回识别文本。
5. 后端对文件格式、MIME、WAV 文件头、文件大小、音频时长、调用频率和 ASR 超时进行校验。
6. 前端将识别文本填入输入框，用户可编辑确认。
7. 用户手动发送后，`POST /api/sessions/{sessionId}/messages` 保存文本消息，`inputType=VOICE`，后端返回 `userMessageId`。
8. `GET /api/stream/search` 使用 `userMessageId` 进入问数链路。

### 11.4 外部 API 调用联调（后置，不执行）

MVP 不实现外部 API 调用，本流程不执行，仅作为后续版本设计参考。

1. 管理侧生成 API Key。
2. 外部系统请求 `POST /api/v1/agent/invoke`，携带 `X-API-Key`。
3. 后端校验 Key 状态、默认 Agent 配置状态。
4. 调用默认 Agent 问数链路。
5. 返回文本、表格、指标卡、图表或边界提示。

## 12. 已确认决策与后置项

| 编号 | 结论/问题 | 状态 |
|---|---|---|
| D1 | 默认 Agent 固定存在，`agentId=default` | 已确认 |
| D2 | 后端技术栈采用 Python + FastAPI，接口文档按本项目确认契约编写，不按 DataAgent Controller 映射 | 已确认 |
| D3 | 响应格式采用 `code/message/data` | 已确认 |
| D4 | 用户侧问数支持 SSE | 已确认 |
| D5 | MVP 固定一个默认用户，只验证问数链路和会话留痕 | 已确认 |
| D6 | MVP 语音输入采用后端 ASR 代理模式：前端上传 WAV，后端调用 ASR 并返回识别文本，前端填入输入框，用户手动发送；ASR 长期密钥不下发前端 | 已确认 |
| D7 | Skill 管理纳入 MVP，支持 ZIP 导入、自动安装、删除、启停；Agent 运行时渐进式披露并由 LangGraph 编排调用 | 已确认 |
| D8 | 智能体知识和业务知识都提供召回测试 | 已确认 |
| D9 | 语义模型导入纳入 MVP，导出不纳入 MVP | 已确认 |
| D10 | 问数结果不单独设计结果查询中心，由后端随会话消息 metadata/resultPayload 兜底保存；中间过程不强制保存 | 已确认 |
| D10-1 | SSE 问数由后端创建 Agent 回复消息；Redis 负责运行态和短期事件缓冲，数据库负责最终消息和结果事实 | 已确认 |
| D10-2 | `complete` 事件必须返回展示级完整 `resultPayload`；大结果按展示上限截断并标记 `total/limit/truncated` | 已确认 |
| D10-3 | 指标口径表属于后端内置运行校验表，由初始化脚本维护；MVP 不提供指标口径管理接口 | 已确认 |
| D11 | 图表返回通用结构，前端组装图表 | 已确认 |
| D12 | MVP 默认 Agent 仅绑定一个生效数据源进行问数 | 已确认 |
| D13 | Schema 初始化流程参考 DataAgent 的库表字段拉取和统计返回方式 | 已确认 |
| D14 | MVP 不实现外部 API 和 API Key 页面，`X-API-Key` 和调用方法仅保留设计说明 | 已确认 |
| D15 | 用户侧输入区包含输入框、发送按钮、语音识别按钮和暂停会话按钮；Agent 不提供人工审核、拒绝计划、只 NL2SQL 等运行选项 | 已确认 |
| D16 | 暂停会话按钮只中止当前流式问数任务，不删除会话、不阻止用户继续提问 | 已确认 |
| D17 | SSE 问数按 `sessionId + userMessageId` 幂等；重复请求不重复创建 Agent 回复消息，不重复执行已终态问数 | 已确认 |
| D18 | `POST /api/voice/asr` 必须携带 `sessionId`，后端按 `sessionId` 和客户端 IP 做轻量限流 | 已确认 |
| D19 | 会话消息正式接口字段统一使用 `messageRole`、`inputType`、`messageContent`，不使用 `role`、`messageType`、`content` 简写 | 已确认 |
| D20 | 语音配置管理侧回显使用独立 `GET /api/voice/config/admin`，用户侧配置读取使用 `GET /api/voice/config` | 已确认 |

## 13. 本版结论

本版已按智能问数技术栈和最新 MVP 决策形成确认口径：后端采用 Python + FastAPI，接口统一 `code/message/data`；默认 Agent 固定为 `default`，MVP 固定默认用户；默认 Agent 仅绑定一个生效数据源进行问数；用户侧输入区包含输入框、发送按钮、语音识别按钮和暂停会话按钮，发送动作是唯一进入问数链路的用户提交入口，暂停会话按钮只中止当前流式问数任务；SSE 问数、后端 ASR 代理语音输入、Skill ZIP 导入与渐进式披露、知识召回测试、语义模型导入均纳入 MVP，语义模型导出不纳入 MVP。Agent 不提供人工审核、拒绝计划、只 NL2SQL 等 DataAgent 运行选项。`X-API-Key` 与外部版本化调用接口 `POST /api/v1/agent/invoke` 仅保留设计，管理侧页面完全隐藏，不作为默认开放能力。

本版作为接口确认文档使用，下一轮根据数据库设计和后端实现边界补充字段类型、错误码编号、OpenAPI YAML 和 curl 示例。


