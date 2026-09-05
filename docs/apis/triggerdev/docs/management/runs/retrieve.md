---
source: https://trigger.dev/docs/management/runs/retrieve
scraped: 2026-02-28
---

# Retrieve Run

Fetch details about a specific run on Trigger.dev, including its current status, input payload, results, and execution attempts.

> Retrieve information about a run, including its status, payload, output, and attempts. If you authenticate with a Public API key, we will omit the payload and output fields for security reasons.

## Endpoint

**GET** `/api/v3/runs/{runId}`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The unique run identifier, prefixed with `run_`. Example: `run_1234` |

## Run Status Values

`PENDING_VERSION`, `DELAYED`, `QUEUED`, `EXECUTING`, `REATTEMPTING`, `FROZEN`, `COMPLETED`, `CANCELED`, `FAILED`, `CRASHED`, `INTERRUPTED`, `SYSTEM_FAILURE`

## Attempt Status Values

`PENDING`, `EXECUTING`, `PAUSED`, `COMPLETED`, `FAILED`, `CANCELED`

## Response (200)

Returns a `RetrieveRunResponse` containing:
- Run metadata (id, status, task identifier, timestamps)
- Payload (omitted with Public API keys)
- Output/results (omitted with Public API keys)
- Presigned URLs for large payloads/outputs
- Related runs (parent, root, children)
- Schedule information (if triggered by a schedule)
- Attempt history with error details

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid or missing run ID |
| 401 | Invalid or Missing API key |
| 404 | Run not found |

## Code Example

```typescript
import { runs } from "@trigger.dev/sdk";

const result = await runs.retrieve("run_1234");

// Boolean status helpers
if (result.isSuccess) {
  console.log("Run was successful with output", result.output);
}

// Access detailed status
console.log("Run status:", result.status);

// Access payload and output
console.log("Payload:", result.payload);
console.log("Output:", result.output);

// Inspect attempts for error information
for (const attempt of result.attempts) {
  if (attempt.status === "FAILED") {
    console.log("Attempt failed with error:", attempt.error);
  }
}
```
