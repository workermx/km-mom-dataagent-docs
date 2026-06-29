# MOM智能问数-Agent编排设计

## 1. 目标

定义智能问数 Agent 如何从用户问题走到工具调用、结果解释和最终 `resultPayload`。

## 2. 核心链路

1. 接收用户已保存的问题。
2. 做意图识别。
3. 抽取参数。
4. 选择受控工具。
5. 工具执行。
6. 结果拼装。
7. 落库并返回 SSE 终态事件。

## 3. 编排模块

| 模块 | 作用 |
| --- | --- |
| intent classifier | 把问题分到工单、库存、设备、制造订单、质量、异常、SOP、未知 |
| tool registry | 管理允许调用的工具 |
| tool adapter | 统一工具入参/出参 |
| guard | 拦截危险 SQL、越界工具、注入提示 |
| result builder | 统一组装 resultPayload |
| explanation layer | 把事实结果解释成可读文本 |

## 4. 设计约束

- LLM 只做解释和抽取，不直接生成并执行 SQL。
- 未注册工具不能调用。
- `NO_DATA` 是成功空结果，不视为失败。
- RAG 只负责口径解释，不负责实时事实。
- 每次执行至少记录 `traceId`、`toolName`、`metricVersion`。

## 5. 推荐工具域

- `work_order`
- `inventory`
- `equipment`
- `production_order`
- `quality_metric`
- `exception_stat`
- `sop_lookup`

## 6. 结果输出

结果统一写入 `metadata_json.resultPayload`，并通过 SSE `complete` 事件返回同一份业务结构。

