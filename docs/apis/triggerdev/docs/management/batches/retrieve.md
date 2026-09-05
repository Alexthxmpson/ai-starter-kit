---
source: https://trigger.dev/docs/management/batches/retrieve
scraped: 2026-02-28
---

# Retrieve a Batch

Fetch batch details by its ID, including the current status and all associated run IDs.

## Endpoint

**GET** `/api/v1/batches/{batchId}`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `batchId` | string | Yes | The batch identifier, prefixed with `batch_`. Example: `batch_1234` |

## Response (200)

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | The batch identifier |
| `status` | string | Current status: `PENDING`, `PROCESSING`, `COMPLETED`, `PARTIAL_FAILED`, or `ABORTED` |
| `idempotencyKey` | string (nullable) | The idempotency key from the original request, if provided |
| `createdAt` | datetime | Creation timestamp |
| `updatedAt` | datetime | Last update timestamp |
| `runCount` | integer | Total number of runs in the batch |
| `runs` | array | List of run IDs |
| `successfulRunCount` | integer (nullable) | Count of successful runs (available after completion) |
| `failedRunCount` | integer (nullable) | Count of failed runs (available after completion) |
| `errors` | array (nullable) | Error details for failed items (present in `PARTIAL_FAILED` batches) |

## Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Batch ID does not exist |

## Code Example

```typescript
const response = await fetch("https://api.trigger.dev/api/v1/batches/batch_1234", {
  headers: {
    "Authorization": `Bearer ${process.env.TRIGGER_SECRET_KEY}`,
  },
});

const batch = await response.json();
```
