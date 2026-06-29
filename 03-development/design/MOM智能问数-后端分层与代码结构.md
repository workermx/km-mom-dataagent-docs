# MOM智能问数-后端分层与代码结构

## 1. 目的

本文档定义后端代码如何分层，避免路由、数据库、运行态和智能体逻辑互相缠绕。

## 2. 分层职责

| 层 | 职责 | 不负责什么 |
| --- | --- | --- |
| `api/` | HTTP 路由、参数接收、响应返回、SSE 事件输出 | 不写业务规则，不直接操作 SQL |
| `schemas/` | Pydantic 请求/响应/枚举/结果模型 | 不访问数据库 |
| `services/` | 业务流程、校验、编排、结果拼装 | 不直接耦合路由 |
| `repositories/` | MySQL 读写、查询封装 | 不做 UI/接口格式处理 |
| `db/` | MySQL/Redis 客户端 | 不写业务逻辑 |
| `runtime/` | 锁、幂等、暂停、SSE 缓冲 | 不作为事实源 |
| `agent/` | 意图识别、工具调用、RAG 召回、结果解释 | 不直接对外暴露 HTTP |

## 3. 代码组织建议

```text
backend/
  app/
    api/
    core/
    db/
    models/
    repositories/
    schemas/
    services/
    runtime/
agent/
  prompts/
  intent/
  tools/
  rag/
  guards/
  evals/
```

## 4. 关键约束

1. 路由只做输入输出，不做复杂编排。
2. Service 负责把“保存用户消息 -> 写台账 -> 发起 Agent -> 落库结果”串起来。
3. Repository 只负责数据库。
4. Redis 只保存短期运行态，不保存事实结果。
5. Agent 工具必须受注册表约束，不能让模型直接执行 SQL。

## 5. 适用场景

- 后端契约骨架扩展
- MySQL/Redis 接入
- SSE 问数链路
- 受控工具编排
- 结果保存与审计

