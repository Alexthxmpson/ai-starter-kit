---
source: https://trigger.dev/docs/management/queues/list
scraped: 2026-02-28
---

# List Queues

List all queues in your environment with pagination support.

## Endpoint

`GET /api/v1/queues`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `page` | query | integer | No | Page number of the queue listing (1-based) |
| `perPage` | query | integer | No | Number of queues per page |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Response

**200 - Successful request**

Returns a `ListQueuesResult` object:

| Property | Type | Description |
|----------|------|-------------|
| `data` | array | Array of `QueueObject` items |
| `pagination.currentPage` | integer | Current page number |
| `pagination.totalPages` | integer | Total number of pages |
| `pagination.count` | integer | Total number of queues |

**401 - Unauthorized request**

## QueueObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Queue ID (e.g., `queue_1234`) |
| `name` | string | Queue name (task ID for task queues, custom name for custom queues) |
| `type` | string | `task` or `custom` |
| `running` | integer | Number of runs currently executing |
| `queued` | integer | Number of runs currently queued |
| `paused` | boolean | Whether the queue is paused |
| `concurrencyLimit` | integer \| null | Current concurrency limit |
| `concurrency.current` | integer \| null | Effective concurrency limit |
| `concurrency.base` | integer \| null | Base concurrency limit defined in code |
| `concurrency.override` | integer \| null | Override concurrency limit (if set) |
| `concurrency.overriddenAt` | date-time \| null | When the concurrency limit was overridden |
| `concurrency.overriddenBy` | string \| null | Who overrode the limit (null if via API) |

## TypeScript SDK Examples

```typescript
import { queues } from "@trigger.dev/sdk";

// List all queues
const allQueues = await queues.list();

// With pagination
const pagedQueues = await queues.list({
  page: 1,
  perPage: 20,
});
```
