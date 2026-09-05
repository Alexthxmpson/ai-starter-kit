---
source: https://trigger.dev/docs/management/tasks/trigger-batch
scraped: 2026-02-28
---

# Trigger Task Batch

Batch trigger a specific task with up to 1,000 payloads. All items in the batch run the same task.

## Endpoint

**POST** `/api/v1/tasks/{taskIdentifier}/batch`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `taskIdentifier` | string | Yes | The id of the task |

## Request Body

```json
{
  "items": [
    {
      "payload": { },
      "context": { },
      "options": {
        "queue": { "name": "string", "concurrencyLimit": 0 },
        "concurrencyKey": "string",
        "idempotencyKey": "string",
        "ttl": "string or number",
        "delay": "string",
        "tags": ["string"],
        "machine": "micro|small-1x|small-2x|medium-1x|medium-2x|large-1x|large-2x"
      }
    }
  ]
}
```

### Constraints

- Maximum 1,000 items per batch
- Up to 10 tags per run (max 128 characters each)
- Concurrency limit: 0-1,000

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
| 404 | Task not found |

## Code Examples

### TypeScript SDK

```typescript
import { task } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  run: async (payload: { message: string }) => {
    console.log("Hello, world!");
  }
});

await myTask.batchTrigger([
  { payload: { message: "Hello, world!" } },
  { payload: { message: "Hello again!" } },
]);
```

### cURL

```bash
curl -X POST "https://api.trigger.dev/api/v1/tasks/my-task/batch" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer tr_dev_1234" \
  -d '{
    "items": [
      { "payload": { "message": "Hello, world!" } },
      { "payload": { "message": "Hello again!" } }
    ]
  }'
```
