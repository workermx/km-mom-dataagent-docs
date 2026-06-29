# MOM智能问数-MVP Redis Key 使用规范

## 1. 定位

Redis 只用于短期运行态、缓存、锁、幂等、限流、SSE 事件缓冲和任务进度，不作为事实来源。所有关键数据必须能从 MySQL 或外部服务恢复。

对齐口径：

- 问数幂等键以接口文档为准：`sessionId + userMessageId`。
- MySQL 是会话、消息、幂等台账、最终结果载荷和任务最终状态的事实来源。
- Redis 不保存模型 API Key、ASR 密钥、数据源密码、完整连接串、外部 API Key。
- MVP 不建设独立结果中心，不保存独立语音识别记录，不缓存访问 API 说明入口。

## 2. Key 命名

统一格式：

```text
da:{module}:{purpose}:{id}
```

示例：

```text
da:runtime:config:default
da:chat:idempotent:session_xxx:msg_user_xxx
da:chat:lock:session_xxx
da:stream:active:thread_xxx
da:stream:stop:thread_xxx
```

## 3. P0 Key

| Key | 类型 | TTL | 写入时机 | 读取时机 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `da:runtime:config:{agentId}` | String JSON | 5-10 分钟 | 管理配置保存、生效或首次读取后 | 问答前加载运行配置 | 缓存默认 Agent、模型、数据源、Skill、预设问题和语义配置摘要；不缓存敏感密钥 |
| `da:chat:idempotent:{sessionId}:{userMessageId}` | String JSON | 24 小时 | Agent 回复消息进入终态并落库后 | SSE 重连、浏览器重试、重复点击发送时 | 防止同一用户消息重复创建 Agent 回复和重复调用模型/工具 |
| `da:chat:lock:{sessionId}` | String | 90 秒 | 开始处理问答前 | 处理问答前 | 防止同一会话并发问答，长耗时请求需要续期 |
| `da:stream:active:{threadId}` | String JSON | 90 秒 | SSE 问数任务启动后 | 暂停会话、断线恢复、运行态检查时 | 当前运行中的 SSE/Agent 任务状态，长耗时请求需要续期 |
| `da:stream:stop:{threadId}` | String JSON | 10 分钟 | 用户点击暂停会话后 | Agent 执行链路检查暂停信号时 | 只表达暂停信号，最终 `STOPPED` 状态以 MySQL 为准 |
| `da:stream:events:{threadId}` | Stream 或 List | 10 分钟 | SSE 事件发送前后 | 短期断线恢复 | 只缓存可下发给前端的安全事件，不缓存 SQL、Python、原始 HTML 等内部过程 |

## 4. P1 Key

| Key | 类型 | TTL | 写入时机 | 读取时机 | 说明 |
| --- | --- | --- | --- | --- | --- |
| `da:rate:voice:{sessionId}:{clientIp}` | String/Counter | 1 分钟 | 调用 `POST /api/voice/asr` 前 | 语音识别限流判断时 | 语音识别成本控制；命中阈值后不调用 ASR 供应方 |
| `da:schema-task:{taskId}` | Hash 或 String JSON | 24 小时 | Schema 初始化任务状态变化时 | 后端内部观测、日志排查和失败恢复 | MySQL `da_schema_init_task` 保存最终状态；MVP 不提供前端任务查询接口 |
| `da:vector-task:{taskId}` | Hash 或 String JSON | 24 小时 | 知识向量化任务状态变化时 | 后端内部观测、日志排查和失败恢复 | MySQL `da_vector_task` 保存最终状态；MVP 不提供前端任务查询接口 |

`clientIp` 来源规则：

- 无可信代理时取请求 `remote address`。
- 存在可信网关或反向代理时，仅从可信代理透传头解析真实 IP。
- 未配置可信代理时不得直接信任 `X-Forwarded-For`、`X-Real-IP` 等客户端可伪造请求头。

## 5. 后置 Key

以下 Key 不纳入 MVP 开发和联调范围：

| Key | 后置原因 |
| --- | --- |
| `da:api-docs:{agentId}` | 访问 API、`X-API-Key` 和外部调用说明在 MVP 阶段完全隐藏 |
| `da:api-key:{apiKeyHash}` | 外部 API Key 生成、鉴权、启停和调用后置 |
| `da:voice:{voiceRecordId}` | MVP 不保存独立语音识别记录，不保存原始音频 |
| `da:result:{resultId}` | MVP 不建设独立结果中心，最终结果随 Agent 回复消息保存 |
| `da:rate:user:{userId}` | MVP 不建设用户登录、注册和权限体系，用户级限流后置 |
| `da:rate:tenant:{tenantId}` | MVP 不建设租户体系，租户级限流后置 |

## 6. Value 建议

### 6.1 运行配置缓存

```json
{
  "agentId": "default",
  "configVersion": "2026-06-24T14:00:00.000+08:00",
  "llmModelConfigId": "model-llm-default",
  "embeddingModelConfigId": "model-embedding-default",
  "datasourceId": "ds-mom-default",
  "enabledSkillCodes": ["WORK_ORDER_STATUS_STAT", "LOW_STOCK_QUERY", "EQUIPMENT_DOWNTIME_STAT"],
  "semanticModelReady": true,
  "maxReturnRows": 1000,
  "queryTimeoutMs": 6000
}
```

说明：

- 本 Key 不保存模型 API Key、ASR 密钥、数据库密码和完整连接串。
- 语音配置如需缓存，只能缓存 `enabled`、`language`、`maxDurationSeconds`、`maxFileSizeMb` 等非敏感摘要。

### 6.2 问答幂等缓存

```json
{
  "sessionId": "session_xxx",
  "userMessageId": "msg_user_xxx",
  "agentMessageId": "msg_agent_xxx",
  "threadId": "thread_xxx",
  "traceId": "trace_xxx",
  "messageStatus": "SUCCESS",
  "resultPayloadStored": true,
  "createdTime": "2026-06-24T14:00:00.000+08:00"
}
```

说明：

- 本 Key 只保存重试恢复所需的轻量索引，不保存完整大结果。
- 完整最终结果以 MySQL 中 Agent 回复消息 `metadata_json.resultPayload` 为准。
- `messageStatus` 可为 `SUCCESS`、`FAILED`、`STOPPED`。

### 6.3 会话锁

锁 value 必须是本次请求生成的随机 token：

```text
trace_xxx:random_token_xxx
```

释放锁时必须校验 value 一致，避免误删其他请求持有的锁。

### 6.4 当前运行任务

```json
{
  "sessionId": "session_xxx",
  "userMessageId": "msg_user_xxx",
  "agentMessageId": "msg_agent_xxx",
  "threadId": "thread_xxx",
  "traceId": "trace_xxx",
  "status": "PROCESSING",
  "startedTime": "2026-06-24T14:00:00.000+08:00",
  "lastHeartbeatTime": "2026-06-24T14:00:30.000+08:00"
}
```

说明：

- 任务运行期间需要续期。
- 任务进入 `SUCCESS`、`FAILED`、`STOPPED` 终态并完成 MySQL 落库后，应删除或等待 TTL 过期。

### 6.5 暂停信号

```json
{
  "threadId": "thread_xxx",
  "sessionId": "session_xxx",
  "userMessageId": "msg_user_xxx",
  "agentMessageId": "msg_agent_xxx",
  "reason": "USER_STOP",
  "createdTime": "2026-06-24T14:01:00.000+08:00"
}
```

说明：

- 暂停信号只要求 Agent 执行链路尽快中止当前任务。
- 后端必须将 Agent 回复消息更新为 `STOPPED` 并保存已输出内容后，再向前端推送 `stopped` 事件。

### 6.6 SSE 事件缓冲

建议仅缓存短期可下发事件：

```json
{
  "event": "message",
  "sequence": 12,
  "data": {
    "agentMessageId": "msg_agent_xxx",
    "textType": "MARKDOWN",
    "content": "正在统计工单状态..."
  },
  "createdTime": "2026-06-24T14:00:10.000+08:00"
}
```

约束：

- 只缓存前端允许接收的 `message`、`complete`、`stopped`、`error` 等事件。
- MVP 用户侧默认不缓存和回放 SQL、Python、原始 HTML 等内部过程。
- `complete` 事件中的完整 `resultPayload` 可以短期缓存，但最终仍以 MySQL `metadata_json.resultPayload` 为准。

### 6.7 任务状态缓存

```json
{
  "taskId": "task_xxx",
  "taskStatus": "PROCESSING",
  "progress": 60,
  "message": "正在解析数据表字段",
  "updatedTime": "2026-06-24T14:00:00.000+08:00"
}
```

## 7. 幂等处理流程

1. 用户点击发送后，后端先保存用户消息，返回 `userMessageId`。
2. 前端使用同一个 `sessionId + userMessageId` 发起 `GET /api/stream/search`。
3. 后端先读取 `da:chat:idempotent:{sessionId}:{userMessageId}`。
4. 如果 Redis 命中，返回或复用缓存中的 `agentMessageId/threadId`，再按需从 MySQL 查询完整消息和最终结果。
5. 如果 Redis 未命中，查询 MySQL `da_chat_request_ledger` 是否已有同一 `session_id + user_message_id`。
6. 如果 MySQL 已有 `PROCESSING` 任务，复用已有 `agentMessageId/threadId`，不得重复创建 Agent 回复消息。
7. 如果 MySQL 已有 `SUCCESS`、`FAILED`、`STOPPED` 终态，前端通过会话消息接口读取已落库结果，不重复执行问数。
8. 如果 Redis 和 MySQL 都未命中，尝试获取 `da:chat:lock:{sessionId}`。
9. 获取锁失败时，返回“当前会话正在处理中”，不调用 LLM、RAG 或 MOM 查询工具。
10. 获取锁成功后，写入 `da_chat_request_ledger`，创建 Agent 回复消息，写入 `da:stream:active:{threadId}`，再执行问数链路。
11. `complete/stopped/error` 终态事件发送前，后端必须先完成 MySQL 消息状态和最终结果落库。
12. MySQL 落库成功后，再写入或刷新 `da:chat:idempotent:{sessionId}:{userMessageId}`。
13. 请求结束时用 value 校验释放会话锁，并清理或等待运行态 Key 过期。

## 8. 锁实现要求

加锁建议：

```text
SET da:chat:lock:{sessionId} {lockValue} NX PX 90000
```

释放锁必须使用 Lua 校验：

```lua
if redis.call("get", KEYS[1]) == ARGV[1] then
  return redis.call("del", KEYS[1])
else
  return 0
end
```

长耗时请求应支持锁续期。续期也必须校验 value 一致：

```lua
if redis.call("get", KEYS[1]) == ARGV[1] then
  return redis.call("pexpire", KEYS[1], ARGV[2])
else
  return 0
end
```

建议约束：

- 单次锁 TTL 默认 90 秒。
- 后端问答总超时不应超过接口文档约定的问数超时。
- 如果执行超过 60 秒仍未结束，可续期一次或按后端任务策略持续续期。
- 续期失败时应停止继续调用下游工具，并返回服务繁忙或超时提示。

## 9. 缓存一致性

- 管理配置保存、生效、启停或删除后，应删除 `da:runtime:config:{agentId}`。
- 删除缓存失败时不影响配置保存，但必须记录日志。
- 问答链路读取配置时，如果缓存未命中，应从 MySQL 重新构建。
- Redis 中任务状态只用于后端内部观测、日志排查和失败恢复，任务最终状态以 MySQL 为准。
- Redis 幂等缓存写入失败不应导致 MySQL 已落库结果丢失；后续重试可从 MySQL 重建缓存。

## 10. 安全要求

- Redis 不保存模型 API Key 明文。
- Redis 不保存 ASR API Key、Secret Key、原始音频或独立识别记录。
- Redis 不保存数据源密码、完整连接串、完整外部 API Key。
- 外部 API Key 鉴权缓存后置；MVP Redis 不保存外部 API Key 摘要、脱敏值或鉴权结果。
- 用户级、租户级限流 Key 后置；MVP 仅确认语音识别限流 `da:rate:voice:{sessionId}:{clientIp}`。
- 问题原文原则上不进入审计类 Redis Key；如确需缓存，应先脱敏。
- SSE 事件缓冲不得缓存后端堆栈、数据库密码、密钥、原始 SQL 执行细节和不可下发的内部过程。

## 11. 开发验收清单

- 同一 `sessionId + userMessageId` 重试不会重复创建 Agent 回复消息。
- 同一 `sessionId + userMessageId` 终态后不会重复调用 LLM、RAG 或 MOM 查询工具。
- 同一会话并发提交时，只有一个请求进入问数主链路。
- 暂停会话会写入 `da:stream:stop:{threadId}`，并最终落库为 `STOPPED`。
- `complete/stopped/error` 终态事件发送前，MySQL 已保存消息状态和最终结果载荷。
- 删除运行配置缓存后，下一次问答能从 MySQL 重建配置。
- 任务状态 Redis 过期后，不影响 Schema 初始化或向量化任务的最终状态落库。
- 锁释放逻辑不会删除其他请求持有的锁。
- Redis 中不存在 `da:api-docs:{agentId}`、`da:voice:{voiceRecordId}`、`da:result:{resultId}`、`da:rate:user:{userId}`、`da:rate:tenant:{tenantId}` 等 MVP 后置 Key。


