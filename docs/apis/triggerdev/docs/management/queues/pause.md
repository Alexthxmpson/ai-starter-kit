---
source: https://trigger.dev/docs/management/queues/pause
scraped: 2026-02-28
---

# Pause or Resume Queue

Pause a queue to prevent new runs from starting, or resume a paused queue. Runs that are currently executing will continue to completion.

## Endpoint

`POST /api/v1/queues/{queueParam}/pause`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `queueParam` | path | string | Yes | Queue ID (e.g., `queue_1234`), task ID, or custom queue name |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

## Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | No | How to interpret `queueParam`: `id` (default), `task`, or `custom` |
| `action` | string | Yes | Either `pause` or `resume` |

```json
{
  "type": "id",
  "action": "pause"
}
```

## Response

**200 - Successful request** — Returns a `QueueObject`

**401 - Unauthorized request**

**404 - Queue not found**

## QueueObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Queue ID |
| `name` | string | Queue name |
| `type` | string | `task` or `custom` |
| `running` | integer | Runs currently executing |
| `queued` | integer | Runs currently queued |
| `paused` | boolean | Whether the queue is paused |
| `concurrencyLimit` | integer | Current concurrency limit |
| `concurrency` | object | Detailed concurrency information |

## TypeScript SDK Examples

```typescript
import { queues } from "@trigger.dev/sdk";

// Pause a queue
await queues.pause("queue_1234");
await queues.pause({ type: "task", name: "my-task-id" });

// Resume a queue
await queues.resume("queue_1234");
await queues.resume({ type: "task", name: "my-task-id" });
```
