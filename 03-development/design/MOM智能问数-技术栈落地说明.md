# MOM智能问数-技术栈落地说明

## 1. 目的

本文档说明当前智能问数系统各技术栈分别负责什么，以及在什么条件下引入。它只用于技术落地和任务拆分，不改变 `MOM智能问数-MVP开发Agent执行约束文档.md` 定义的 MVP 边界。

## 2. 技术栈职责

| 技术栈 | 负责什么 | 何时引入 |
| --- | --- | --- |
| FastAPI | 管理侧/用户侧 API、SSE、健康检查、文件上传 | 立即使用 |
| Pydantic | 请求/响应模型、结果结构校验、枚举约束 | 立即使用 |
| SQLAlchemy | MySQL 模型、Repository、查询封装 | 立即使用 |
| Alembic | 数据库迁移管理 | 数据结构开始稳定后引入 |
| redis-py | 幂等、锁、暂停信号、运行态、限流 | 立即使用 |
| StreamingResponse / SSE | 问数流式返回 | 立即使用 |
| cryptography | 敏感字段加密保存 | 立即使用 |
| pytest + httpx | 单测、接口测试、SSE 测试 | 立即使用 |
| PyMilvus | 知识、SOP、术语召回 | 知识/RAG 需求出现时引入 |
| BackgroundTasks | 简单异步任务 | MVP 早期可用 |
| Celery / RQ | 长任务、重试、排队、失败恢复 | 任务量变大后引入 |
| structlog / logging | 结构化日志 | 联调阶段引入 |
| OpenTelemetry | 链路追踪和耗时定位 | 多服务联调后引入 |
| Docker Compose | MySQL/Redis 本地联调 | 立即使用 |

## 3. 引入原则

1. 先满足主链路，再加重栈。
2. 新栈只解决当前明确痛点，不为了“将来可能用到”提前引入。
3. 同一类能力只保留一个主方案，避免重复抽象。
4. 任何新栈都必须写清测试命令和回滚方案。

## 4. 当前推荐顺序

1. FastAPI + Pydantic + SQLAlchemy + Redis + SSE + cryptography。
2. pytest + httpx + MySQL/Redis 容器化验证。
3. 受控 Agent 编排、RAG、PyMilvus。
4. BackgroundTasks 或 Celery/RQ。
5. structlog / OpenTelemetry。

## 5. 不建议现在加入

- Neo4j / GraphRAG
- 完整 IAM / 权限中心
- 大数据流处理
- 完整报表中心
- 多 Agent 市场化管理

