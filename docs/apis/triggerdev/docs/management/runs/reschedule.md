---
source: https://trigger.dev/docs/management/runs/reschedule
scraped: 2026-02-28
---

# Reschedule Run

Updates a delayed run with a new delay. Only valid when the run is in the `DELAYED` state.

## Endpoint

**POST** `/api/v1/runs/{runId}/reschedule`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run ID, starts with `run_`. Example: `run_1234` |

## Request Body

```json
{
  "delay": "1hr"
}
```

The `delay` field accepts either:
- A duration string: `1d`, `6h`, `10m`, `11s`, etc.
- A date-time string: `"2024-06-25T15:45:26Z"`

## Response (200)

Returns a `RetrieveRunResponse` object with full run details including:
- Run metadata (id, status, taskIdentifier, timestamps)
- Payload and output (omitted with Public API keys)
- Presigned URLs for large payloads/outputs
- Related runs (parent, root, children)
- Schedule information
- Attempts array

### Run Status Values

`PENDING_VERSION`, `DELAYED`, `QUEUED`, `EXECUTING`, `REATTEMPTING`, `FROZEN`, `COMPLETED`, `CANCELED`, `FAILED`, `CRASHED`, `INTERRUPTED`, `SYSTEM_FAILURE`

### Attempt Status Values

`PENDING`, `EXECUTING`, `PAUSED`, `COMPLETED`, `FAILED`, `CANCELED`

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid or missing run ID / Failed to create new run |
| 401 | Invalid or Missing API key |
| 404 | Run not found |

## Code Example

```typescript
import { runs } from "@trigger.dev/sdk";

const handle = await runs.reschedule("run_1234", { delay: new Date("2024-06-29T20:45:56.340Z") });
```
