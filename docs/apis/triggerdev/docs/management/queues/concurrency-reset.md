---
source: https://trigger.dev/docs/management/queues/concurrency-reset
scraped: 2026-02-28
---

# Reset Concurrency Limit

Reset the concurrency limit of a queue back to its base value defined in code.

## Endpoint

`POST /api/v1/queues/{queueParam}/concurrency/reset`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `queueParam` | path | string | Yes | Queue ID (e.g., `queue_1234`) or queue name when using `type` body parameter |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Request Body (optional)

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `type` | string | No | How to interpret `queueParam`: `id` (default), `task`, or `custom` |

```json
{
  "type": "task"
}
```

## Response

**200 - Concurrency limit reset successfully** — Returns a `QueueObject`

**400 - Queue is not overridden or invalid request parameters**

**401 - Unauthorized request**

**404 - Queue not found**

## QueueObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Queue ID (e.g., `queue_1234`) |
| `name` | string | Queue name |
| `type` | string | `task` or `custom` |
| `running` | integer | Number of runs currently executing |
| `queued` | integer | Number of runs currently queued |
| `paused` | boolean | Whether the queue is paused |
| `concurrencyLimit` | integer \| null | Current concurrency limit (now reset to base) |
| `concurrency.current` | integer \| null | Effective concurrency limit |
| `concurrency.base` | integer \| null | Base concurrency limit defined in code |
| `concurrency.override` | integer \| null | Override (null after reset) |
| `concurrency.overriddenAt` | date-time \| null | When overridden (null after reset) |
| `concurrency.overriddenBy` | string \| null | Who overrode (null after reset) |

## TypeScript SDK Examples

```typescript
import { queues } from "@trigger.dev/sdk";

// Reset concurrency limit to the base value
await queues.resetConcurrencyLimit("queue_1234");

// Using type and name
await queues.resetConcurrencyLimit({
  type: "task",
  name: "my-task-id",
});
```
