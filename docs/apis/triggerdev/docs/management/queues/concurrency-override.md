---
source: https://trigger.dev/docs/management/queues/concurrency-override
scraped: 2026-02-28
---

# Override Concurrency Limit

Override the concurrency limit of a queue. This is useful for temporarily scaling up or down based on demand.

## Endpoint

`POST /api/v1/queues/{queueParam}/concurrency/override`

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

## Request Body

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `type` | string | No | How to interpret `queueParam`: `id` (default), `task`, or `custom` |
| `concurrencyLimit` | integer | Yes | New concurrency limit (min: 0, max: 100000) |

```json
{
  "type": "id",
  "concurrencyLimit": 5
}
```

## Response

**200 - Concurrency limit overridden successfully** — Returns a `QueueObject`

**400 - Invalid request parameters**

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
| `concurrencyLimit` | integer \| null | Current concurrency limit |
| `concurrency.current` | integer \| null | Effective concurrency limit |
| `concurrency.base` | integer \| null | Base concurrency limit defined in code |
| `concurrency.override` | integer \| null | Override concurrency limit (if set) |
| `concurrency.overriddenAt` | date-time \| null | When the limit was overridden |
| `concurrency.overriddenBy` | string \| null | Who overrode the limit (null if via API) |

## TypeScript SDK Examples

```typescript
import { queues } from "@trigger.dev/sdk";

// Override concurrency limit to 5
await queues.overrideConcurrencyLimit("queue_1234", 5);

// Using type and name
await queues.overrideConcurrencyLimit(
  { type: "task", name: "my-task-id" },
  20
);
```
