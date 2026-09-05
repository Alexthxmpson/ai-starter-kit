---
source: https://trigger.dev/docs/management/batches/retrieve-results
scraped: 2026-02-28
---

# Retrieve Batch Results

Retrieves execution results from completed runs within a batch. Only finished runs (successful or failed) are included in the items array — runs that are still executing are omitted.

## Endpoint

**GET** `/api/v1/batches/{batchId}/results`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `batchId` | string | Yes | The batch identifier, prefixed with `batch_`. Example: `batch_1234` |

## Response (200)

Returns a JSON object containing:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | The batch identifier |
| `items` | array | Array of execution results |

Each item in `items`:

| Field | Type | Description |
|-------|------|-------------|
| `ok` | boolean | Whether the run completed successfully |
| `id` | string | Run identifier |
| `output` | string | Serialized output string (when ok is true) |
| `outputType` | string | Content type of output (e.g., `application/json`) |
| `error` | object | Error details object (when ok is false) |
| `usage` | object | Execution usage stats |
| `usage.durationMs` | number | Duration of the run in milliseconds |
| `taskIdentifier` | string | The task identifier |

## Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Batch not found |

## Code Example

```typescript
const response = await fetch("https://api.trigger.dev/api/v1/batches/batch_1234/results", {
  headers: {
    "Authorization": `Bearer ${process.env.TRIGGER_SECRET_KEY}`,
  },
});

const results = await response.json();
```
