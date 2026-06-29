# MOM智能问数-结果Payload扩展设计

## 1. 目标

在当前 `resultPayload` 基础上补充“来源标识”和“推导过程可配置展示”。

## 2. 新增字段建议

| 字段 | 作用 |
| --- | --- |
| `sourceLabel` | 展示来源名称 |
| `sourceRefs` | 来源引用列表 |
| `derivationVisible` | 是否展示推导过程 |
| `derivationSummary` | 推导摘要 |

## 3. 使用原则

- 只展示可公开的解释信息。
- 不暴露内部 SQL、密钥、完整执行链。
- 来源标识应可配置开启/关闭。
- 推导过程只做摘要，不做完整思维链输出。

## 4. 兼容原则

现有 `table`、`indicators`、`chart`、`notice` 结构保持不变，扩展字段应作为附加元数据，不破坏现有前端渲染。

