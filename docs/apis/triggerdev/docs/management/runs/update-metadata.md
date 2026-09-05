---
source: https://trigger.dev/docs/management/runs/update-metadata
scraped: 2026-02-28
---

# Update Run Metadata

Update the metadata of a run.

## Endpoint

**PUT** `/api/v1/runs/{runId}/metadata`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run ID, starts with `run_`. Example: `run_1234` |

## Request Body

```json
{
  "metadata": {
    "key": "value"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `metadata` | object | The new metadata to set on the run |

## Response (200)

```json
{
  "metadata": {
    "key": "value"
  }
}
```

Returns the updated metadata of the run.

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid or missing run ID / Invalid metadata |
| 401 | Invalid or Missing API key |
| 404 | Task Run not found |

## Code Example

```typescript
import { metadata, task } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  run: async () => {
    await metadata.save({ key: "value" });
  }
});
```
