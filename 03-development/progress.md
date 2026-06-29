# Progress

## 2026-06-29 VibeCoding 后端任务卡状态

| 任务卡 | 状态 | 当前结论 | 主要验收证据 | 下一步 |
| --- | --- | --- | --- | --- |
| 001 基准冲突复扫与旧口径清理 | DONE | 已清理旧接口、旧幂等字段和数据库旧口径；当前正式数据库为 MySQL。 | `rg` 复扫无 `clientMessageId`、`/api/data-agent/chat`、达梦/DM8 正式口径残留；MySQL 验证通过。 | 无 |
| 002 后端契约骨架复审与补齐 | DONE | FastAPI 基础契约、统一响应、默认 Agent、会话、消息和 SSE 入口骨架已落地。 | `python -m pytest backend/tests -q` 通过。 | 无 |
| 003 MySQL 连接、模型与 Repository | DONE | 后端已具备 MySQL 默认配置、SQLAlchemy 模型和 Repository 基础。 | `backend/tests/test_repository_foundation.py` 覆盖 Repository surface 和关键台账字段；后端测试通过。 | 无 |
| 004 Redis 运行态基础能力 | DONE | 已实现 Redis 锁、幂等缓存、active task、stop flag、events 缓冲及降级行为。 | `backend/tests/test_redis_runtime.py` 覆盖锁 value 校验释放、TTL、敏感字段拒绝和 Redis 失败降级；后端测试通过。 | 无 |
| 005 SSE 问数最小闭环 | DONE | 已实现 `text/event-stream`、请求台账、Agent 回复消息、终态前落库、历史回显和重连幂等。 | `backend/tests/test_stream_sse.py` 覆盖 complete/stopped/error、断线重连不重复创建 Agent 消息；后端测试通过。 | 无 |
| 006 resultPayload 构造器 | DONE | 已实现统一结果载荷构造，覆盖 SUCCESS、NO_DATA、NEED_CLARIFICATION、CONFIG_UNAVAILABLE、FAILED，且禁止旧 `charts` 多图字段。 | `backend/tests/test_result_payload.py` 通过；`python -m pytest backend/tests -q` 通过。 | 无 |
| 007 三类 Mock 工具闭环 | DONE | 已实现工单状态、低安全库存、设备停机三类受控 Mock 工具，未知问题澄清，停用 Skill 后不调用工具。 | `backend/tests/test_agent_mock_tools.py` 覆盖三类命中、未知问题、停用 Skill；`python -m pytest backend/tests -q` 通过。 | 无 |
| 008 管理侧模型与数据源配置接口 | DONE | 已实现模型配置和数据源配置的新增、更新、测试、生效/绑定接口，敏感字段仅脱敏回显，未通过连接测试的数据源禁止进入 Schema 初始化入口。 | `backend/tests/test_admin_model_datasource.py` 通过；`python -m pytest backend/tests -q` 通过，42 passed。 | 下一步启动 009 |
| 009 Schema 初始化与语义字段校验 | DONE | 已实现同步 Schema 初始化、表字段缓存、表范围保存与语义字段来源校验，且 009 规则不覆盖 010 的知识/Skill 能力。 | `backend/tests/test_schema_semantic.py` 通过；`python -m pytest backend/tests -q` 通过，45 passed。 | 下一步启动 010 |

当前推进位置：001-009 已完成，下一步启动 010。

## 2026-06-25 后端契约骨架审查与修正

- 按最新接口设计文档审查 `backend/app` 和 `backend/tests`，确认第一阶段只修正 FastAPI 契约骨架，不接入 MySQL、Redis、LLM、RAG、ASR 或真实 SSE 事件流。
- 使用 TDD 方式重写 `backend/tests/test_contract.py`，覆盖默认 Agent、会话创建/列表、正式消息字段、未知会话/消息 404、`GET /api/stream/search` 参数和 `sessionId + userMessageId` 幂等、暂停占位接口。
- 首次运行 `python -m pytest backend\tests -q` 得到预期失败：旧响应 `code="OK"`、旧消息字段导致 422、未知消息未校验、停止接口仍返回旧 message。
- 修改 `backend/app/core/response.py`，统一 `code` 为数字，默认成功消息为 `操作成功`，并补充 `fail`。
- 修改 `backend/app/core/errors.py` 和 `backend/app/main.py`，增加轻量 `AppError/NotFoundError` 与统一错误响应处理。
- 修改 `backend/app/schemas/agent.py`、`backend/app/services/agent_service.py`，默认 Agent 返回 `isDefault/ready/missingItems/warningItems`，移除旧 `configStatus`。
- 修改 `backend/app/schemas/session.py`、`backend/app/services/session_service.py`，消息接口切到 `messageRole/inputType/messageContent`，支持 `PRESET_QUESTION`，并对未知会话返回 404。
- 修改 `backend/app/schemas/stream.py`、`backend/app/services/stream_service.py`、`backend/app/api/stream.py`，补齐 `agentId/threadId` 入参、消息存在性校验和内存幂等台账。
- 修改查询类 API 成功消息为 `查询成功`，同步 `backend/tests/test_health.py` 为新统一响应格式。
- 验证通过：`python -m pytest backend\tests -q`，8 个测试全部通过。
- 验证通过：`python -m compileall -q backend\app`。
- 静态扫描确认：后端 `app/tests` 中无旧 `"OK"`、`clientMessageId`、`/api/data-agent/chat`、旧 `PRESET` 正式口径；`configStatus` 仅在测试中作为反向断言出现。
- 清理本轮验证产生的 `backend/**/__pycache__`。
- 遗留边界：当前 `GET /api/stream/search` 仍是 JSON 占位响应，不是真实 `text/event-stream`；后续接入 Redis/SSE/Agent 编排时应在同一路由契约下替换实现。

## 2026-06-23 智能体方案 Vibe Coding 审查与修改

- 审查 `docs/design/KM-MOM-DataAgent-智能体开发专项方案.md`、`docs/Vibe-Coding-落地手册.md`、`docs/vibe-coding/执行清单.md`、`docs/vibe-coding/后端落地检查表.md` 和 `docs/design/KM-MOM-DataAgent-真实落地补充确认表.md`。
- 更新智能体专项方案：补充 Vibe Coding 执行原则，明确每轮只处理一个任务卡，并要求写清目标、范围、涉及文件、验收命令和失败回滚点。
- 更新智能体专项方案：修正当前仓库状态，明确第一阶段前端契约和 mock 闭环已完成，后续不回退到旧配置枚举、旧响应体或旧幂等规则。
- 更新智能体专项方案：将 `ChatAnswer` 目标契约修正为当前代码使用的扁平结构 `answerType/text/errorCode/toolName/metricVersion/traceId`，移除旧 `meta.traceId` 描述。
- 更新智能体专项方案：新增 5 张建议任务卡顺序，覆盖后端契约骨架、受控编排主链路、工具与 RAG 边界、答案与审计、验证与回归。
- 更新 `docs/vibe-coding/任务卡模板.md`，新增事实来源、验证命令、风险与回滚点，并补充智能体后端任务的额外检查项。
- 更新 `docs/vibe-coding/后端落地检查表.md`，新增 Vibe Coding 门禁、RAG 与工具边界、安全攻击样例和幂等重试检查。
- 更新 `docs/vibe-coding/README.md`，将当前推荐下一步改为按智能体专项方案的 Vibe Coding 任务卡顺序推进。
- 新增 `docs/vibe-coding/任务卡-后端契约骨架.md`，把后端第一步拆成可执行任务卡，覆盖 FastAPI 骨架、Schema、错误码、OpenAPI 和测试。
- 继续校准智能体专项方案与当前代码事实，确保 `ChatAnswer` 结构与 `src/types.ts` 一致，不再保留旧 `meta.traceId` 表述。

## 2026-06-18

- 使用 `planning-with-files` 和 `writing-plans` 组织第一阶段开发安排。
- 读取《docs/design/KM-MOM-DataAgent-智能体开发专项方案.md》《docs/planning/KM-MOM-DataAgent-开发任务文档.md》《docs/planning/KM-MOM-DataAgent-每日开发计划表.md》。
- 检查当前代码中的 `src/types.ts`、`src/mocks/mockData.ts`、`src/mocks/handlers.ts`。
- 创建项目级规划文件：`task_plan.md`、`findings.md`、`progress.md`。
- 创建计划目录：`docs/superpowers/plans`。
- 运行 `npm run test`，基线通过：3 个测试文件、13 个用例通过。
- 创建第一阶段实施计划：`docs/superpowers/plans/2026-06-18-phase-1-development.md`。

## 2026-06-22 数据库设计初稿

- 生成 `docs/database/MOM智能问数-MVP数据库设计文档.md`。
- 初稿覆盖系统自身 MySQL 表、Redis Key、敏感字段加密、SQL 安全、数据生命周期、初始化建议和后续细化项。
- 文档明确区分系统自身库与外部 MOM 业务数据源，避免将业务库表误纳入系统库设计。
- 根据最新 MVP 文档，数据库初稿已将语音识别记录作为 MVP 必需表纳入设计。

## 2026-06-22 数据库开发初稿补充

- 更新 `docs/database/MOM智能问数-MVP数据库设计文档.md` 第 12 节，将“后续需要细化的内容”改为“下一阶段数据库开发初稿”。
- 补充数据库下一阶段开发目标、推荐开发顺序、MySQL 表开发优先级、Redis Key 开发优先级、关键开发约束、AI 协同交付物和暂缓事项。
- 验证文档中无 `TODO`、`TBD`、`待补充`、`待定`、`后续需要细化` 等占位内容。
- 验证第 12 节可检索到 `trace_id`、`clientMessageId`、`MySQL DDL`、`Redis Key` 等后续开发关键点。

## 2026-06-22 数据库脚本与 Redis 规范初稿

- 新增 `docs/database/001_mvp_schema.sql`，覆盖 MOM 智能问数 MVP 系统库 21 张表。
- 新增 `docs/database/002_mvp_seed_data.sql`，包含默认 Agent、模型配置占位、数据源占位、3 个 Skill、3 个预设问题、API 访问配置和系统提示词。
- 新增 `docs/database/redis-key-spec.md`，说明 Redis Key 命名、P0/P1 Key、Value 示例、幂等流程、锁实现、缓存一致性、安全要求和验收清单。
- 静态检查确认核心表、核心 Redis Key、`trace_id`、`clientMessageId`、幂等锁和 Lua 释放规则均已覆盖。
- 本次未连接真实 MySQL/Redis 执行脚本，后续评审通过后再进行本地数据库执行验证。

## 2026-06-22 数据库文档评审后修改

- 根据评审意见修改 `docs/database/001_mvp_schema.sql`：字符集排序规则改为 `utf8mb4_unicode_ci`，JSON 结果字段改为 `LONGTEXT`，补充默认模型和 active 数据源唯一约束，强化 `client_message_id` 为问答主链路必填。
- 修改 `docs/database/002_mvp_seed_data.sql`：明确 seed 只用于本地开发和首次引导，真实密钥必须通过后端加密流程或管理 API 配置。
- 修改 `docs/database/redis-key-spec.md`：补充 Redis + MySQL 双层幂等流程、锁获取失败处理、90 秒锁 TTL、长耗时请求续期 Lua 和超时建议。
- 新增 `docs/database/database-implementation-checklist.md`，用于后端落地前校验数据库版本、DDL 执行、Service 层规则、安全规则和 Redis 验收。
- 补充表级 `COLLATE=utf8mb4_unicode_ci`，避免不同 MySQL 实例默认排序规则导致建表结果漂移。
- 静态验证通过：未再检索到 `utf8mb4_0900_ai_ci`、`JSON NOT NULL`、`NX PX 30000`、旧 30 秒锁描述和 TODO 类占位内容。
- 当前机器 Docker 客户端存在但 Docker daemon 未启动，且未发现可用 MySQL 客户端；本轮未完成真实 MySQL 执行验证。

## 2026-06-22 数据库执行验收脚本补充

- 新增 `docs/database/003_mvp_verify.sql`，用于验证 22 张系统表、默认初始化数据、关键唯一索引、`client_message_id` 非空约束和 JSON 结果字段类型。
- 新增 `docs/database/run-mysql-verification.ps1`，用于在 Windows PowerShell 下按顺序执行 schema、seed 和 verify SQL。
- 更新 `docs/database/database-implementation-checklist.md`，补充验证脚本命令、跳过 seed 的命令和验收期望。
- PowerShell 解析检查通过：`run-mysql-verification.ps1` 无语法解析错误。
- 仍未完成真实 MySQL 执行验证，原因是当前环境没有可用 MySQL 客户端，Docker daemon 也未启动。

## 2026-06-22 数据库本地验证体验优化

- 优化 `docs/database/run-mysql-verification.ps1`：改为生成临时合并 SQL 文件后一次 MySQL 连接执行，减少多次输入密码和中途状态不一致的风险。
- 新增 `docs/database/docker-compose.mysql.yml`，用于本地启动 MySQL 8.0 验证库，字符集和排序规则与 DDL 保持一致。
- 更新 `docs/database/database-implementation-checklist.md`，补充 Docker 启动命令，并明确默认 root 密码仅用于本地开发验证。
- 静态验证通过：PowerShell 脚本无语法解析错误，Compose 模板包含 MySQL 8.0、`utf8mb4_unicode_ci`、3306 端口和健康检查。

## 2026-06-22 数据库最终评审报告

- 新增 `docs/database/database-final-review-report.md`，集中汇总当前交付物、已关闭问题、静态验证证据、尚未关闭的真实落地门槛、验收命令和后端开发注意事项。
- 静态检查确认最终评审报告包含 `uk_active_default_model`、`uk_active_datasource`、`uk_session_client_role`、`NX PX 90000`、`da_table_count = 22` 等关键证据点。
- 报告明确当前不能声明真实落地闭环完成，剩余门槛是启动 MySQL 实例并实际执行 `001_mvp_schema.sql`、`002_mvp_seed_data.sql`、`003_mvp_verify.sql`。

## 2026-06-22 MySQL 验证脚本密码处理优化

- 修改 `docs/database/run-mysql-verification.ps1`：新增可选 `-Password` 参数；不传时使用 `Read-Host -AsSecureString` 交互输入。
- 移除 `mysql -p` 模式，避免密码提示与 SQL 重定向输入冲突。
- 脚本执行期间临时设置进程级 `MYSQL_PWD`，执行结束后恢复原值，不把密码写入命令历史。
- 更新 `docs/database/database-implementation-checklist.md` 和 `docs/database/database-final-review-report.md`，补充交互式密码输入和本地 Docker 验证密码参数示例。
- 静态验证通过：PowerShell 脚本无语法解析错误，执行命令中不再包含 `-p`。

## 2026-06-22 数据库 CI 验证方案补充

- 再次检查本机环境：未发现可用 `mysql` 客户端；Docker Compose 命令存在，但 Docker daemon 未启动，仍无法本机执行真实 MySQL 验证。
- 新增 `.github/workflows/database-verify.yml`，使用 GitHub Actions MySQL 8.0 服务容器执行 `001_mvp_schema.sql`、`002_mvp_seed_data.sql`、`003_mvp_verify.sql`。
- 更新 `docs/database/database-implementation-checklist.md` 和 `docs/database/database-final-review-report.md`，补充本机 Docker 不可用时可走 CI 验证。
- 静态检查确认 workflow 包含 MySQL 8.0、MySQL 客户端安装、三份 SQL 执行命令和 `docs/database/**` 路径触发。

## 2026-06-22 数据库验证断言增强

- 修改 `docs/database/003_mvp_verify.sql`：新增 `assert_mvp_database_ready` 存储过程，使用 `SIGNAL SQLSTATE '45000'` 对表数量、必需表、默认模型、active 数据源、关键索引、`client_message_id` 非空、结果 JSON 字段类型进行硬断言。
- 验证通过时输出 `MVP database verification passed.`，失败时 MySQL 命令会非零退出，CI 和本地脚本都能感知失败。
- 修改 `.github/workflows/database-verify.yml`：客户端安装包从 `mysql-client` 调整为 `default-mysql-client`，提高 Ubuntu runner 兼容性。
- 更新 `docs/database/database-implementation-checklist.md` 和 `docs/database/database-final-review-report.md`，说明 verify SQL 已具备失败断言能力。

## 2026-06-22 Seed 幂等验证补充

- 修改 `docs/database/run-mysql-verification.ps1`：默认将 `002_mvp_seed_data.sql` 加入合并 SQL 两次，验证初始化脚本可重复执行；使用 `-SkipSeed` 时仍完全跳过 seed。
- 修改 `.github/workflows/database-verify.yml`：CI 中连续执行两次 `002_mvp_seed_data.sql` 后再执行 `003_mvp_verify.sql`。
- 更新 `docs/database/database-implementation-checklist.md` 和 `docs/database/database-final-review-report.md`，说明本地脚本和 CI workflow 都会覆盖 seed 幂等验证。

## 2026-06-22 数据库初始化断言增强

- 修改 `docs/database/003_mvp_verify.sql`：新增默认 Agent、3 个内置 Skill、3 个首页预设问题、默认 API 访问配置、系统提示词 `v1.0` 的硬断言。
- 将关键索引断言从“只按索引名计数”收紧为“表名 + 索引名”配对校验，避免同名索引误判。
- 更新 `docs/database/database-implementation-checklist.md` 和 `docs/database/database-final-review-report.md`，补充初始化数据验收标准。

## 2026-06-22 数据库目录入口文档

- 新增 `docs/database/README.md`，作为数据库交付物入口，说明阅读顺序、本地验证命令、CI 验证路径、安全边界和验证状态。
- 静态检查确认 README 引用的数据库脚本、验证脚本、Docker Compose 文件和通过输出均与现有文件一致。

## 2026-06-22 数据库真实 MySQL 验证通过

- 成功启动 Docker Desktop daemon，并通过 `docs/database/docker-compose.mysql.yml` 启动 MySQL 8.0 本地验证容器。
- 因本机无 `mysql` 客户端，改用容器内 MySQL 客户端执行验证。
- 真实执行通过：`001_mvp_schema.sql`、`002_mvp_seed_data.sql`、第二次 `002_mvp_seed_data.sql`、`003_mvp_verify.sql`。
- 验证输出包含 `da_table_count=22`、必需表全部 `OK`、三类默认模型各 1 条、active 只读数据源 1 条、3 个 Skill、3 个预设问题、关键索引和字段类型检查，以及 `MVP database verification passed.`。
- 新增 `docs/database/run-mysql-verification-in-docker.ps1`，固化使用容器内 MySQL 客户端执行验证的路径。
- 更新 `docs/database/README.md`、`docs/database/database-implementation-checklist.md`、`docs/database/database-final-review-report.md`，补充容器内验证脚本并标记本地 MySQL 8.0 验证已通过。
- 最终复跑 `docs/database/run-mysql-verification-in-docker.ps1` 通过，确认固化脚本可复现真实验证结果。

## 2026-06-22 Vibe Coding 手册补充

- 新增 `docs/Vibe-Coding-落地手册.md`，把后续协作的输入格式、执行顺序、文件职责、常用提示词、质量门槛和开工方式写成可直接执行的操作手册。
- 这份手册用于降低后续 Vibe Coding 的沟通成本，避免每轮重新解释协作方式。
- 新增 `docs/vibe-coding/任务卡模板.md`、`docs/vibe-coding/执行清单.md`、`docs/vibe-coding/提示词库.md`、`docs/vibe-coding/后端落地检查表.md`。
- 新增 `docs/vibe-coding/第一阶段任务卡-契约对齐.md`，把第一阶段拆成 5 张可直接执行的任务卡。
- 新增 `docs/vibe-coding/README.md`，作为后续 Vibe Coding 文档入口。

## 2026-06-22 第一阶段任务卡执行完成

- 执行 `docs/vibe-coding/第一阶段任务卡-契约对齐.md`。
- 更新 `src/types.ts`：配置状态改为 `DRAFT`、`PUBLISHED`、`DISABLED`、`NO_EFFECTIVE_CONFIG`；补充 `CreateSessionRequest`、`clientMessageId`、`ChatResponse.answer`、`persisted`、`toolName`、`metricVersion`、`traceId` 等契约字段。
- 更新 `src/lib/configRules.ts`：仅 `PUBLISHED` 且模型、数据源可用时允许文本问答。
- 更新 `src/mocks/mockData.ts`：mock 配置和三类答案对齐新契约，会话补 `agentId`，答案补 `answerType`、`toolName`、`metricVersion`、`traceId`。
- 更新 `src/mocks/handlers.ts`：`POST /api/data-agent/chat` 返回新 `ChatResponse`，并按 `sessionId + clientMessageId` 做内存幂等台账。
- 更新 `src/api/dataAgent.ts` 和 `src/App.tsx`：新建会话提交默认 `agentId`，问答提交生成 `clientMessageId`，并把新 `ChatResponse.answer` 转换为页面消息。
- 更新 `src/components/AnswerRenderer.tsx` 和 `src/styles.css`：展示 `toolName`、`metricVersion`、`traceId` 和错误码。
- 更新 `src/__tests__/configRules.test.ts`、`src/__tests__/RuntimePage.test.tsx`、`src/__tests__/AnswerRenderer.test.tsx`、`e2e/runtime.spec.ts`：覆盖配置状态、三类 mock 问答、未知问题澄清、幂等响应和答案追踪字段。
- 验证通过：`npm run test`，3 个测试文件、15 个用例通过。
- 验证通过：`npm run build`，TypeScript 构建和 Vite 生产构建通过；Vite 输出 chunk size warning，不影响本轮验收。
- 验证通过：`npm run e2e`，Playwright 1 个浏览器冒烟用例通过。
- 收尾检查：当前目录不是 Git 仓库，未执行 merge、PR 或分支清理。

## 2026-06-22 文档瘦身整理

- 删除历史执行计划 `docs/superpowers/plans/2026-06-18-phase-1-development.md`，当前任务协作以 `task_plan.md`、`findings.md`、`progress.md` 和 `docs/vibe-coding/` 为入口。
- 删除已完成的一阶段任务卡 `docs/vibe-coding/第一阶段任务卡-契约对齐.md`，后续 Vibe Coding 以通用手册、执行清单和任务卡模板为准。
- 删除阶段性数据库评审报告 `docs/database/database-final-review-report.md`，数据库入口改为 `docs/database/README.md`、总体设计文档、落地清单、DDL/seed/verify 脚本和 Redis 规范。
- 更新 `docs/database/README.md`、`docs/vibe-coding/README.md` 和 `docs/Vibe-Coding-落地手册.md`，移除已删除文档的活链接。

## 2026-06-22 全栈与智能体目录边界整理

- 新增 `README.md` 作为项目总入口，明确当前可运行前端仍在根目录 `src/`、`public/`、`e2e/`，后续迁移需单独计划。
- 新增 `frontend/README.md`，将 `frontend/` 定义为未来前端工程化整理入口，暂不迁移现有 Vite 项目文件。
- 新增 `backend/README.md`，预留 FastAPI 后端开发边界，数据库脚本继续以 `docs/database/` 为事实来源。
- 新增 `agent/README.md`，预留智能体编排、提示词、工具、RAG 和评测目录边界。
- 新增目录骨架：`frontend/`、`backend/app/`、`backend/tests/`、`agent/prompts/`、`agent/tools/`、`agent/rag/`、`agent/evals/`。

## 2026-06-24 开发文档替换与新增

- 使用桌面新版 `MOM智能问数-MVP数据库设计文档.md` 替换 `docs/database/MOM智能问数-MVP数据库设计文档.md`。
- 使用桌面新版 `redis-key-spec.md` 替换 `docs/database/redis-key-spec.md`。
- 新增 `docs/design/MOM智能问数-MVP接口设计文档.md`，作为后端 API 和前后端契约事实来源。
- 新增 `docs/database/MOM智能问数-MVP数据库与Redis设计修改对比说明.md`，作为本轮数据库与 Redis 设计变更入口。
- 旧版数据库设计文档和 Redis 规范已备份到 `archive/replaced-docs/2026-06-24/`。
- 更新 `docs/database/README.md`、`docs/design/README.md`、`README.md` 和 `backend/README.md`，补充新版文档入口。

## 2026-06-25 最终基准文档导入整理

- 已将桌面 `Agent参考文档.zip` 解压归档到 `archive/imports/2026-06-25-agent-reference/`，保留原始导入内容用于追溯。
- 已将被最终文档替换的旧版需求、设计、接口、数据库、Redis 与旧 KM-MOM/DataAgent 相关文档归档到 `archive/replaced-docs/2026-06-25-final-agent-reference/`。
- 当前最高开发基准确定为 `docs/design/MOM智能问数-MVP开发Agent执行约束文档.md`；后续全栈、后端和智能体任务进入前必须先读取该文档。
- 已导入最终需求文档、接口设计、数据库设计、Redis 规范、全量对齐报告、项目方案和开发 Agent 执行约束文档到 `docs/` 活动目录。
- 已将需求截图统一放入 `docs/assets/requirements/`，并把管理侧需求文档中的旧 `需求评审/image` 图片引用改为项目内相对路径。
- 已把活动文档中的旧外部 `G:\Document\...` 路径替换为项目内路径；项目方案中未随最终包提供的 4 张架构图改为缺图说明。
- 已将 `docs/planning/` 下旧 KM-MOM/DataAgent 阶段计划归档，避免后续开发误用旧基准。

## 2026-06-25 后端接口与智能体开发计划
- 读取最新基准文档：开发 Agent 执行约束、终稿对齐报告、接口设计、数据库设计、Redis 规范、管理侧需求、用户侧需求、后端检查表和任务卡。
- 发现旧任务卡和部分数据库 SQL/检查表仍保留旧口径：agent-mom-data、client_message_id/clientMessageId、/api/data-agent/chat。
- 新增开发计划文档：docs/planning/2026-06-25-backend-agent-development-plan.md。
- 计划建议先修正基准冲突，再进入 FastAPI 骨架、MySQL/Redis、用户问数主链路、管理侧配置、智能体编排和语音输入。

## 2026-06-25 Coding 前项目文件夹整理

- 已按确认删除低风险可再生成内容：`.pytest_cache/`、`backend/.pytest_cache/`、`backend/**/__pycache__/`、`backend/**/*.pyc`、`dist/`、`test-results/`。
- 已统一后端入口命名：`backend/pyproject.toml`、`backend/README.md`、`backend/app/__init__.py`、`backend/app/core/config.py` 从旧 `KM-MOM DataAgent` 显示名调整为智能问数 MVP 后端口径。
- 已同步修正 `backend/tests/test_health.py` 的服务名断言。
- 已重写 `docs/vibe-coding/任务卡-后端契约骨架.md` 和 `docs/vibe-coding/后端落地检查表.md`，后端正式问数口径改为 `sessionId + userMessageId`，禁止新增旧 `/api/data-agent/chat` 和旧 `clientMessageId` 正式后端口径。
- 已验证：`python -m pytest backend\tests -q` 通过，6 个后端测试通过。
- 已验证：`npm run test` 通过，3 个前端测试文件、15 个用例通过。
- 已验证：`npm run build` 通过，Vite 仍有大 chunk 警告；构建产物 `dist/` 已在验证后再次清理。
- 遗留任务：`docs/database/*.sql` 和 `database-implementation-checklist.md` 仍包含 `agent-mom-data`、`client_message_id`、`clientMessageId` 等旧数据库口径，应作为下一张任务卡单独修正并运行数据库验证。
