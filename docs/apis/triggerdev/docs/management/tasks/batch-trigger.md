---
source: https://trigger.dev/docs/management/tasks/batch-trigger
scraped: 2026-02-28
---

# Batch Trigger (Multi-Task)

Trigger multiple different tasks simultaneously in a single batch request. With SDK 4.3.1 and later, you can batch up to 1,000 payloads in a single request (500 in earlier versions).

## Endpoint

**POST** `/api/v1/tasks/batch`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Request Body

The request body contains an `items` array. Each item must include:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `task` | string | Yes | The task identifier (the `id` from your task definition) |
| `payload` | any JSON | No | Data for the task |
| `context` | any JSON | No | Context data |
| `options` | object | No | Trigger options (see below) |

### Options

| Field | Type | Description |
|-------|------|-------------|
| `queue.name` | string | Queue name |
| `queue.concurrencyLimit` | integer (0-1000) | Max concurrent executions |
| `concurrencyKey` | string | Scope concurrency to a specific key |
| `idempotencyKey` | string | Prevents duplicate runs |
| `ttl` | string or number | Time-to-live (e.g., `1h42m` or seconds) |
| `delay` | string | Execution delay (e.g., `1h`, `30d`, `15m`) |
| `tags` | array | Up to 10 tags per run (max 128 characters each) |
| `machine` | string | Preset: `micro`, `small-1x`, `small-2x`, `medium-1x`, `medium-2x`, `large-1x`, `large-2x` |

## Response (200)

```json
{
  "batchId": "batch_1234",
  "runs": ["run_id_1", "run_id_2"]
}
```

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid request parameters or body |
| 401 | Unauthorized |
| 404 | Resource not found |

## Code Examples

### TypeScript SDK

```typescript
import { task } from "@trigger.dev/sdk";

export const myTask = await task({
  id: "my-task",
  run: async (payload: { message: string }) => {
    console.log("Hello, world!");
  }
});

await myTask.batchTrigger([
  {
    payload: { message: "Hello, world!" },
    options: {
      idempotencyKey: "unique-key-123",
      concurrencyKey: "user-123-task",
      queue: {
        name: "my-task-queue",
        concurrencyLimit: 5
      }
    }
  }
]);
```

### cURL

```bash
curl -X POST "https://api.trigger.dev/api/v1/tasks/batch" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tr_dev_1234" \
  -d '{
    "items": [
      {
        "task": "my-task",
        "payload": {
          "message": "Hello, world!"
        },
        "context": {
          "user": "user123"
        },
        "options": {
          "queue": {
            "name": "default",
            "concurrencyLimit": 5
          },
          "concurrencyKey": "user123-task",
          "idempotencyKey": "unique-key-123"
        }
      }
    ]
  }'
```
