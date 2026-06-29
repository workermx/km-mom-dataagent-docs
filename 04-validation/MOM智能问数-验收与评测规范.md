# MOM智能问数-验收与评测规范

## 1. 目标

定义智能问数后端、Agent、RAG、异步任务和重栈扩展的验收标准。

## 2. 测试分层

| 层级 | 覆盖内容 |
| --- | --- |
| 单元测试 | Service、Guard、Result Builder、工具适配 |
| 接口测试 | HTTP、SSE、上传、配置接口 |
| 数据库测试 | MySQL DDL、seed、verify |
| Redis 测试 | 锁、幂等、暂停、事件缓冲 |
| Agent 测试 | 意图识别、工具选择、边界提示 |
| RAG 测试 | 召回、引用、版本 |

## 3. 重点场景

- 正常问数
- 无数据
- 未知问题
- 越界问题
- 提示词注入
- SQL 诱导
- Skill 停用
- 数据源不可用
- 语音失败

## 4. 推荐命令

```powershell
python -m pytest backend/tests -q
.\docs\database\run-mysql-verification-in-docker.ps1
rg -n "agent-mom-data|clientMessageId|/api/data-agent/chat" docs backend agent
```

