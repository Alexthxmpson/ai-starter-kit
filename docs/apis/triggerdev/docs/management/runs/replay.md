---
source: https://trigger.dev/docs/management/runs/replay
scraped: 2026-02-28
---

# Replay Run

Creates a new run by replicating the payload and configuration from an existing run.

## Endpoint

**POST** `/api/v1/runs/{runId}/replay`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run identifier (format: `run_1234`) |

## Response (200)

```json
{
  "id": "string"
}
```

Returns a JSON object containing the new run's identifier.

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid or missing run ID, or failure to create the new run |
| 401 | Missing or invalid API key |
| 404 | The specified run does not exist |

## Code Examples

```typescript
import { runs } from "@trigger.dev/sdk";

const handle = await runs.replay("run_1234");
```

### Configuration

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```
