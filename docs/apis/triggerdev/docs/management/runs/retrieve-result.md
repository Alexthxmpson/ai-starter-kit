---
source: https://trigger.dev/docs/management/runs/retrieve-result
scraped: 2026-02-28
---

# Retrieve Run Result

Returns the execution result of a completed run. Returns 404 if the run doesn't exist or hasn't finished yet.

## Endpoint

**GET** `/api/v1/runs/{runId}/result`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run ID, starts with `run_`. Example: `run_1234` |

## Response (200)

| Field | Type | Description |
|-------|------|-------------|
| `ok` | boolean | Whether the run completed successfully |
| `id` | string | The run ID |
| `output` | string | Serialized output (present when ok is true). Use `outputType` to determine how to parse it — for `application/json` use `JSON.parse()` |
| `outputType` | string | Content type of the serialized output, e.g. `application/json` |
| `error` | object | Error details (present when ok is false) |
| `usage` | object | Execution usage stats |
| `usage.durationMs` | number | Duration of the run in milliseconds |
| `taskIdentifier` | string | The task identifier |

## Error Responses

| Status | Description |
|--------|-------------|
| 401 | Invalid or Missing API Key |
| 404 | Run either doesn't exist or is not finished |

## Code Example

```typescript
const response = await fetch("https://api.trigger.dev/api/v1/runs/run_1234/result", {
  headers: {
    "Authorization": `Bearer ${process.env.TRIGGER_SECRET_KEY}`,
  },
});

const result = await response.json();
```
