---
source: https://trigger.dev/docs/management/runs/cancel
scraped: 2026-02-28
---

# Cancel Run

Cancels an in-progress run. If the run is already completed, this will have no effect.

## Endpoint

**POST** `/api/v2/runs/{runId}/cancel`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run identifier, begins with `run_` |

## Responses

| Status | Description | Details |
|--------|-------------|---------|
| 200 | Success | Returns the canceled run's ID |
| 400 | Invalid request | Missing or invalid run ID |
| 401 | Unauthorized | Invalid or missing API key |
| 404 | Not found | Run doesn't exist |

## Code Examples

```typescript
import { runs } from "@trigger.dev/sdk";

await runs.cancel("run_1234");
```

### SDK Configuration

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```
