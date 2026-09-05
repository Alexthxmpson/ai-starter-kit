---
source: https://trigger.dev/docs/management/queues/retrieve
scraped: 2026-02-28
---

# Retrieve Queue

Get a queue by its ID, or by type and name.

## Endpoint

`GET /api/v1/queues/{queueParam}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `queueParam` | path | string | Yes | Queue ID (e.g., `queue_1234`) or queue name when using the `type` query parameter |
| `type` | query | string | No | How to interpret `queueParam`: `id` (default), `task`, or `custom` |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

## Response

**200 - Successful request** — Returns a `QueueObject`

**401 - Unauthorized request**

**404 - Queue not found**

## QueueObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Queue ID (e.g., `queue_1234`) |
| `name` | string | Queue name |
| `type` | string | `task` or `custom` |
| `running` | integer | Number of currently executing runs |
| `queued` | integer | Number of currently queued runs |
| `paused` | boolean | Whether the queue is paused |
| `concurrencyLimit` | integer \| null | Current concurrency limit |
| `concurrency` | object | Detailed concurrency info (`current`, `base`, `override`, `overriddenAt`, `overriddenBy`) |

## TypeScript SDK Examples

```typescript
import { queues } from "@trigger.dev/sdk";

// Using queue ID
const queue = await queues.retrieve("queue_1234");

// Using type and name for a task queue
const taskQueue = await queues.retrieve({
  type: "task",
  name: "my-task-id",
});

// Using type and name for a custom queue
const customQueue = await queues.retrieve({
  type: "custom",
  name: "my-custom-queue",
});
```
