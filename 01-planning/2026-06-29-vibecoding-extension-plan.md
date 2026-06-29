# MOM智能问数重栈与扩展 VibeCoding 开发计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or executing-plans when implementing this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把后续重栈与扩展能力补成可执行的 VibeCoding 任务卡，覆盖技术栈落地、Agent 编排、RAG/向量库、异步任务、日志追踪、结果 Payload 扩展和 ZHGC 业务事实确认。

**Architecture:** 先补文档，再补任务卡，再进入实现。所有扩展任务都必须明确依赖现有 MVP 约束，不得把重栈直接当成新的默认范围。

**Tech Stack:** FastAPI、Pydantic、SQLAlchemy、redis-py、cryptography、PyMilvus、BackgroundTasks、Celery/RQ、logging/structlog、OpenTelemetry、pytest。

---

## 1. 适用边界

本计划只负责后续扩展文档和任务卡，不直接改后端业务代码。

默认前提：

- 当前 MVP 主链路仍按 `sessionId + userMessageId` 运行。
- RAG 和向量库只服务知识/SOP，不服务实时事实。
- 异步任务只承载长任务，不抢占 SSE 主链路。
- 结果 Payload 扩展不破坏现有前端渲染。

## 2. 任务卡 001：技术栈落地与后端分层

### 目标

补齐技术栈落地说明和后端分层文档，明确各栈负责什么、何时引入、谁负责。

### 涉及文件

- `docs/design/MOM智能问数-技术栈落地说明.md`
- `docs/design/MOM智能问数-后端分层与代码结构.md`
- `docs/design/README.md`
- `docs/vibe-coding/README.md`

### 验收命令

```powershell
rg -n "技术栈落地|后端分层|SQLAlchemy|PyMilvus|Celery|OpenTelemetry" docs
```

## 3. 任务卡 002：Agent 编排与结果输出扩展

### 目标

补齐 Agent 编排设计和 resultPayload 扩展设计，覆盖来源标识和推导摘要。

### 涉及文件

- `docs/design/MOM智能问数-Agent编排设计.md`
- `docs/design/MOM智能问数-结果Payload扩展设计.md`
- `docs/vibe-coding/任务卡-后端契约骨架.md`
- `docs/vibe-coding/README.md`

### 验收命令

```powershell
rg -n "sourceLabel|sourceRefs|derivationVisible|derivationSummary|toolName|metricVersion" docs
```

## 4. 任务卡 003：RAG、向量库与异步任务

### 目标

补齐 RAG/向量库设计、异步任务与重试设计，以及日志与链路追踪设计。

### 涉及文件

- `docs/design/MOM智能问数-RAG与向量库设计.md`
- `docs/design/MOM智能问数-异步任务与重试设计.md`
- `docs/design/MOM智能问数-日志与链路追踪.md`
- `docs/vibe-coding/README.md`

### 验收命令

```powershell
rg -n "RAG|向量库|异步任务|重试|traceId|OpenTelemetry|BackgroundTasks|Celery|RQ" docs
```

## 5. 任务卡 004：ZHGC 业务事实确认与评测规范

### 目标

把 ZHGC 整体需求中可纳入智能问数的部分整理成业务事实确认清单，并补齐验收与评测规范。

### 涉及文件

- `docs/design/MOM智能问数-ZHGC业务事实确认清单.md`
- `docs/testing/MOM智能问数-验收与评测规范.md`
- `docs/vibe-coding/README.md`

### 验收命令

```powershell
rg -n "制造订单|合格率|废品率|异常统计|SOP|验收与评测" docs
```

## 6. 执行顺序

1. 先完成任务卡 001。
2. 再完成任务卡 002。
3. 再完成任务卡 003。
4. 最后完成任务卡 004。

## 7. 备注

- 以上任务卡都是文档任务卡。
- 若后续要转实现，再按每张任务卡拆成独立编码任务。

