---
source: https://trigger.dev/docs/management/tasks/trigger
scraped: 2026-02-28
---

# Trigger a Task

Trigger a task by its identifier.

## Endpoint

**POST** `/api/v1/tasks/{taskIdentifier}/trigger`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `taskIdentifier` | string | Yes | The id of a task. Example: `my-task` |

## Request Body

| Field | Type | Description |
|-------|------|-------------|
| `payload` | any JSON | The payload to pass to the task |
| `context` | any JSON | Additional context to pass to the task |
| `options` | object | Trigger options (see below) |

### Options

| Field | Type | Description |
|-------|------|-------------|
| `queue` | object | Queue configuration |
| `queue.name` | string | Shared queue name |
| `queue.concurrencyLimit` | integer (0-1000) | Maximum concurrent run executions |
| `concurrencyKey` | string | Scope the concurrency limit to a specific key |
| `idempotencyKey` | string | Prevents creating duplicate runs. Returns existing run ID if key already exists |
| `ttl` | string or number | Time-to-live: `1h`, `1m`, `1h42m` or seconds (min 1) |
| `delay` | string | Execution delay: `1h`, `30d`, `15m`, `2w`, `60s`, or ISO date string |
| `tags` | string or array | Up to 10 tags per run (max 128 characters each). Recommend namespacing: `user_1234` or `org:9876` |
| `machine` | string | Machine preset: `micro`, `small-1x`, `small-2x`, `medium-1x`, `medium-2x`, `large-1x`, `large-2x` |

## Response (200)

```json
{
  "id": "run_1234"
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

// Somewhere else in your code
await myTask.trigger({ message: "Hello, world!" }, {
  idempotencyKey: "unique-key-123",
  concurrencyKey: "user123-task",
  queue: {
    name: "my-task-queue",
    concurrencyLimit: 5
  },
});
```

### cURL

```bash
curl -X POST "https://api.trigger.dev/api/v1/tasks/my-task/trigger" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tr_dev_1234" \
  -d '{
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
      }'
```

### Python

```python
import requests

url = "https://api.trigger.dev/api/v1/tasks/my-task/trigger"
headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer tr_dev_1234"
}
data = {
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

response = requests.post(url, headers=headers, json=data)
print(response.json())
```
