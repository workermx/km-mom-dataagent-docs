# MOM智能问数-日志与链路追踪

## 1. 目标

让每一次问数、工具调用、RAG 召回和任务执行都能被追踪。

## 2. 必须记录的标识

- `traceId`
- `sessionId`
- `userMessageId`
- `agentMessageId`
- `toolName`
- `metricVersion`
- `requestStatus`

## 3. 日志原则

1. 不打明文密钥。
2. 不打原始 SQL。
3. 不打原始音频。
4. 不打大段中间思考链。
5. 错误信息要可定位但不过度泄露内部细节。

## 4. 推荐技术

- Python `logging`
- 可选 `structlog`
- 联调/试运行阶段再接 `OpenTelemetry`

## 5. 追踪粒度

- 接口级
- 工具级
- 任务级
- 语音级
- RAG 级

