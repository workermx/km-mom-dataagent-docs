# MOM智能问数-MVP全量文档终稿对齐报告

日期：2026-06-24

## 1. 对齐结论

本轮已完成 `docs/` 目录下正式文档的终稿口径对齐，并同步更新 `archive/imports/2026-06-25-agent-reference/Agent参考文档/CONTEXT.md（最终包未提供，保留为来源说明）`。

当前文档可以作为 MOM 智能问数 MVP 开发终稿基线使用。需求、接口、数据库、Redis、方案和统一术语之间未发现 P0/P1 级方向冲突；剩余扫描命中均为明确的参考来源、否定说明或统一术语中的 `_Avoid_` 禁用词说明，不影响开发落地。

## 2. 扫描范围

本轮纳入对齐的正式文档如下：

| 类型 | 文档 |
| --- | --- |
| 项目方案 | `docs/design/MOM智能问数项目方案.md` |
| 接口设计 | `docs/design/MOM智能问数-MVP接口设计文档.md` |
| 数据库设计 | `docs/database/MOM智能问数-MVP数据库设计文档.md` |
| Redis Key 规范 | `docs/database/redis-key-spec.md` |
| 管理侧需求 | `docs/requirements/MOM智能问数-MVP管理侧需求规格文档.md` |
| 用户侧需求 | `docs/requirements/MOM智能问数-MVP用户侧需求规格文档.md` |
| 开发 Agent 约束 | `docs/design/MOM智能问数-MVP开发Agent执行约束文档.md` |
| 统一术语 | `archive/imports/2026-06-25-agent-reference/Agent参考文档/CONTEXT.md（最终包未提供，保留为来源说明）` |

已跳过路径或文件名包含 `backup`、`备份`、`archive`、`old`、`历史版本`、`临时`、`草稿` 的内容。

## 2.1 开发 Agent 阅读顺序

本目录可以作为 Agent 辅助开发参考基准，但不能无差别交给 Agent 自由发挥。开发 Agent 必须按以下优先级读取和执行：

| 优先级 | 文档 | 使用方式 |
| --- | --- | --- |
| 0 | `MOM智能问数-MVP开发Agent执行约束文档.md` | 先读取本约束文档，确认禁止事项、执行规则和防幻觉边界。 |
| 1 | `MOM智能问数-MVP全量文档终稿对齐报告.md` | 读取本报告，确认 MVP 边界、后置项和终稿口径。 |
| 2 | `docs/requirements/MOM智能问数-MVP管理侧需求规格文档.md`、`docs/requirements/MOM智能问数-MVP用户侧需求规格文档.md` | 作为功能范围、页面动作和验收口径来源。 |
| 3 | `数据库&接口\MOM智能问数-MVP接口设计文档.md`、`数据库&接口\MOM智能问数-MVP数据库设计文档.md`、`数据库&接口\redis-key-spec.md` | 作为接口契约、落库设计、状态枚举、Redis Key 和联调规则来源。 |
| 4 | `MOM智能问数项目方案.md` | 只作为项目背景和阶段演进方向，不作为 MVP 实现清单。 |

若不同文档出现口径冲突，先按本报告和接口设计文档判断 MVP 边界，再回到需求文档确认功能范围；项目方案中的长期能力不得直接进入 MVP 实现。

## 3. 备份位置

修改前已备份本轮涉及的正式文档，备份目录为：

`archive/imports/2026-06-25-agent-reference/`

备份内容包含项目方案、接口设计、数据库设计、Redis Key 规范、管理侧需求、用户侧需求和统一术语文档。

## 4. 本轮统一后的核心口径

| 主题 | 终稿口径 |
| --- | --- |
| MVP 范围 | MVP 只验证默认 Agent 的 MOM 问数主链路。 |
| 默认 Agent | 默认 Agent 固定存在，`agentId=default`。 |
| 数据源 | MVP 阶段默认 Agent 只绑定一个生效 MOM 数据源。 |
| 产品库范围 | MVP 只服务 MOM 库指标问数，不扩展 ERP、APS 等其他产品库。 |
| 用户体系 | MVP 不建设登录、注册、权限、租户体系。 |
| 用户侧入口 | 保留输入框、发送按钮、语音识别按钮、暂停会话按钮、会话列表和结果展示。 |
| Agent 运行模式 | 不实现人工审核、人工反馈、拒绝计划、只 NL2SQL 等 DataAgent 运行选项。 |
| 访问 API | `X-API-Key`、外部调用、API Key 管理统一为后置，不进入 MVP 开发和联调。 |
| 语音问数 | 采用后端 ASR 代理；前端上传 WAV，后端返回识别文本，用户手动发送。 |
| 结果保存 | 问数结果保存在 Agent 回复消息 `metadata.resultPayload` / `metadata_json.resultPayload`。 |
| 结果结构 | `resultPayload` 使用 `table`、`indicators`、`chart`、`notice`，其中 `chart` 为单数。 |
| Redis | Redis 只保存短期运行态、幂等、锁、SSE 缓冲、暂停信号、语音限流和内部任务状态，不作为事实源。 |
| 任务查询 | Schema 初始化和向量化任务记录为后端内部状态，MVP 不提供前端任务查询接口。 |
| 状态枚举 | 测试状态统一为 `UNTESTED/SUCCESS/FAILED`；消息和结果状态支持 `PROCESSING/SUCCESS/FAILED/STOPPED`。 |
| 同义词 | 业务知识和语义模型同义词入库统一为 JSON 数组字符串。 |

## 5. 文档修改摘要

### 5.1 统一术语文档

已更新 `archive/imports/2026-06-25-agent-reference/Agent参考文档/CONTEXT.md（最终包未提供，保留为来源说明）`：

- 明确 `默认 Agent`、`管理侧`、`用户侧`、`用户侧运行页` 等基础术语。
- 明确 `配置完整可用（配置生效）` 只阻断文本问数必要项：LLM、嵌入模型、生效数据源、Schema 初始化。
- 将 `模型资源配置` 收敛为 LLM 和嵌入模型配置。
- 将语音相关术语统一为 `语音输入配置`、`语音问数`、`后端 ASR 代理`。
- 增加并规范 `结果 Payload`、`Redis 运行态`、`请求台账`、`后置` 等术语。
- 将 `暂缓`、`一期不做`、`预留` 放入 `后置` 的 `_Avoid_` 中，表示正式文档应优先使用 `后置`。

### 5.2 项目方案文档

已更新 `docs/design/MOM智能问数项目方案.md`：

- 明确方案文档包含项目整体愿景，但 MVP 基线为一个默认 Agent、一个生效 MOM 数据源和工单/库存/设备三类主题。
- 将权限、报表、复杂归因、多数据源扩展等内容收敛为后续阶段能力，不作为 MVP 基线。
- 将第一阶段 MVP 表述调整为一个生效 MOM 数据源和三类核心主题。
- 将 MVP 预期结果收敛为基础图表和问数结果展示，报表输出作为后续增强能力。

### 5.3 接口设计文档

已更新 `docs/design/MOM智能问数-MVP接口设计文档.md`：

- 将外部 API 相关范围、路径策略、请求头、API Key 管理和外部调用章节统一为 `后置`。
- 保留 `X-API-Key` 和 `POST /api/v1/agent/invoke` 设计说明，但明确不进入 MVP 开发和联调。
- 明确 SSE 问数由后端创建 Agent 回复消息，并按 `sessionId + userMessageId` 幂等。
- 明确 `complete` 事件返回展示级完整 `resultPayload`，最终结果落库后再发送终态事件。
- 将 Redis Stream 描述收敛为短期 SSE 事件缓冲和短期断线恢复，不再使用容易误导的“恢复预留”表述。
- 保持 `resultPayload.chart` 单数结构，与数据库文档一致。

### 5.4 数据库设计文档

已更新 `docs/database/MOM智能问数-MVP数据库设计文档.md`：

- 将 `da_` 表前缀说明修正为智能问数系统表前缀，不再解释为 DataAgent 系统表。
- 将 Redis 配置摘要示例从旧默认 Agent 口径收敛为 `default`。
- 将鉴权缓存、用户/租户限流、外部 API Key 数据统一标记为后置能力。
- 将 `一期` 表述改为 `MVP 阶段`。
- 明确 `da_query_result`、`da_table_result`、`da_indicator_result`、`da_chart_result`、`da_runtime_notice` 均为后置独立结果表；MVP 结果随 Agent 回复消息保存。
- 明确 `metadata_json.resultPayload.chart` 使用单数 `chart`。
- 明确同义词统一按 JSON 数组字符串落库。
- 明确 `request_status` 是后端内部请求台账状态，不直接等同前端 `messageStatus/resultStatus`。

### 5.5 Redis Key 规范

已更新 `docs/database/redis-key-spec.md`：

- 明确 Redis 不保存模型 API Key、ASR 密钥、数据源密码、完整连接串、外部 API Key。
- 将独立结果相关描述收敛为 `MVP 不建设独立结果中心`。
- 将 `da:stream:events:{threadId}` 用途收敛为短期断线恢复。
- 明确 `da:api-docs:{agentId}`、`da:voice:{voiceRecordId}`、`da:result:{resultId}`、`da:rate:user:{userId}`、`da:rate:tenant:{tenantId}` 等为 MVP 后置 Key，不应在 MVP Redis 中出现。

### 5.6 管理侧需求文档

已更新 `docs/requirements/MOM智能问数-MVP管理侧需求规格文档.md`：

- 将数据对象表和配置归属中的 `默认智能体` 收敛为 `默认 Agent`。
- 将结果结构相关表述统一为 `Payload`。
- 将多 Agent 扩展字段表述改为“保留默认 Agent 归属字段”，避免与 `后置` 口径混用。
- 保留 DataAgent 源码作为参考来源，但不作为 MVP 功能范围依据。

### 5.7 用户侧需求文档

已更新 `docs/requirements/MOM智能问数-MVP用户侧需求规格文档.md`：

- 将用户侧页面称呼从 `MOM-DataAgent` 收敛为 `用户侧运行页` / `MOM 智能问数`。
- 将 `一期支持工单、库存、设备三类主题` 收敛为 `MVP 阶段支持工单、库存、设备三类主题`。
- 保持用户侧只通过文本发送入口进入问数链路，语音输入仅作为输入辅助。

## 6. 已关闭问题

| 编号 | 问题 | 处理结果 |
| --- | --- | --- |
| P1-01 | `UNTESTED` / `NOT_TESTED` 不一致 | 已统一为 `UNTESTED`。 |
| P1-02 | `resultPayload.chart` / `charts` 不一致 | 已统一为单数 `chart`。 |
| P1-03 | 外部 API、API Key 是否进入 MVP 不清晰 | 已统一为后置，管理侧隐藏，不进入开发和联调。 |
| P1-04 | ASR 是否前端直连不清晰 | 已统一为后端 ASR 代理，密钥不下发前端。 |
| P1-05 | SSE 回复消息创建方和落库时机不清晰 | 已明确由后端创建 Agent 回复消息，终态事件前落库。 |
| P1-06 | SSE 重试可能重复创建任务 | 已明确 `sessionId + userMessageId` 幂等。 |
| P1-07 | Redis 与 MySQL 事实源边界不清晰 | 已明确 MySQL 为事实源，Redis 只保存短期运行态。 |
| P1-08 | Schema/向量任务是否需要前端查询 | 已明确任务状态为后端内部记录，MVP 不提供任务查询接口。 |
| P2-01 | `暂缓`、`一期不做`、`预留` 混用 | 正式文档已收敛为 `后置` 或 `MVP 阶段`；禁用词仅保留在统一术语 `_Avoid_`。 |
| P2-02 | 同义词入库形态不固定 | 已统一为 JSON 数组字符串。 |
| P2-03 | `request_status` 与前端消息状态混淆 | 已明确请求台账状态为内部执行状态。 |

## 7. 验证结果

已对本轮对齐目标 Markdown 文档执行旧口径搜索，并排除备份、历史、草稿、临时文件和本报告文件。报告正文会列出搜索项本身，因此不纳入残留判断。

### 7.1 硬残留搜索

搜索项：

```text
NOT_TESTED
resultPayload.charts
/api/agent/{id}
embeddingStatus
MARK_DOWN
COMPLETED
独立问数结果中心
暂缓
一期
预留
```

结果：未发现正式文档中的活跃旧口径残留。唯一命中为 `统一术语\CONTEXT.md` 中 `_Avoid_: 暂缓、一期不做、预留`，该命中用于标识禁用说法，属于预期结果。

### 7.2 DataAgent 与 ASR 安全搜索

搜索项：

```text
MOM-DataAgent
默认智能体
humanFeedback
nl2sqlOnly
rejectedPlan
前端.*ASR.*Key
ASR.*Key.*前端
```

结果：

- 未发现 `MOM-DataAgent`、`默认智能体`、`humanFeedback`、`nl2sqlOnly`、`rejectedPlan` 作为接口字段或 MVP 能力残留。
- `DataAgent` 仅作为参考来源、对照说明或历史文档名称出现，不作为本项目 MVP 契约。
- `前端持有 ASR Key` 仅出现在统一术语 `_Avoid_` 禁用词中；接口文档明确 ASR 长期密钥只在后端加密保存和使用，不向前端下发。

## 8. 需人工确认问题

本轮未发现必须暂停开发的 P0/P1 级需人工确认问题。

后续若团队决定开放外部 API、多 Agent、多数据源、多产品库、用户鉴权、独立结果中心、过程日志回看等能力，应作为后置需求重新评审，不应直接在 MVP 开发中顺手实现。

## 9. 给后续 Coding Agent 的执行约束

1. 以接口设计文档作为前后端契约优先来源，以数据库设计文档和 Redis Key 规范作为技术落库与运行态约束。
2. 不从 DataAgent 直接搬运 `humanFeedback`、`nl2sqlOnly`、`rejectedPlan`、多 Agent、多数据源路由等能力。
3. MVP 固定 `agentId=default`，固定默认用户，固定一个生效 MOM 数据源。
4. 用户侧发送链路必须先保存用户消息，再用 `userMessageId` 发起 SSE 问数。
5. SSE 由后端创建 Agent 回复消息；终态事件前必须完成消息状态和最终 `resultPayload` 落库。
6. `complete.resultPayload` 返回展示级完整结果，图表字段使用单数 `chart`。
7. Redis 不保存事实结果、不保存密钥、不保存独立语音记录；最终事实以 MySQL 为准。
8. ASR 只能走后端代理，前端不得持有供应方密钥。
9. 外部 API、API Key、用户/租户限流、独立结果表均为后置，不进入 MVP 联调。
10. 接口路径和动作名按接口文档实现，不得自动改造成纯 RESTful 风格；`/add`、`/query/page`、`/activate/{id}` 等动作接口保持契约优先。
11. 生成 OpenAPI、Pydantic、SQLAlchemy 或迁移脚本时，必须将泛化 `{id}` 映射为具体业务标识，例如 `modelConfigId`、`datasourceId`、`sessionId`、`messageId`。
12. 技术栈中出现 Neo4j、LangGraph、LlamaIndex 等内容时，只按当前接口和数据库契约实现；不得把它们推导为 MVP 必须建设 GraphRAG、知识图谱能力或额外编排平台。
13. 项目方案中的报告中心、智能归因、评测反馈、权限规则等长期能力只能作为背景理解，不得在 MVP 中顺手实现。

## 10. 最终判断

当前文档已经达到 MOM 智能问数 MVP 开发终稿基线，可以交给后续 Agent 或研发人员据此生成 SQL 脚本、OpenAPI 契约、后端接口、前端联调任务和测试用例。

后续开发阶段如出现实现差异，应优先回写接口设计文档、数据库设计文档和统一术语文档，再进入代码实现，避免口径漂移。
