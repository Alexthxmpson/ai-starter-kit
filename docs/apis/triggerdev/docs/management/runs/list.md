---
source: https://trigger.dev/docs/management/runs/list
scraped: 2026-02-28
---

# List Runs

List runs in a specific environment with filtering capabilities.

## Endpoint

**GET** `/api/v1/runs`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Query Parameters

### Pagination (`page`)

| Property | Type | Description |
|----------|------|-------------|
| `page[size]` | integer (10-100, default 25) | Number of runs per page |
| `page[after]` | string | Run ID to start page after (forward pagination) |
| `page[before]` | string | Run ID to start page before (backward pagination) |

### Filters (`filter`)

| Property | Type | Description |
|----------|------|-------------|
| `filter[status]` | array | Comma-separated statuses: `PENDING_VERSION`, `QUEUED`, `EXECUTING`, `REATTEMPTING`, `FROZEN`, `COMPLETED`, `CANCELED`, `FAILED`, `CRASHED`, `INTERRUPTED`, `SYSTEM_FAILURE` |
| `filter[taskIdentifier]` | array | Task identifier(s) |
| `filter[version]` | array | Worker version(s) |
| `filter[createdAt][from]` | date-time | Start date filter |
| `filter[createdAt][to]` | date-time | End date filter |
| `filter[createdAt][period]` | string | Period filter (e.g. `1d`) |
| `filter[bulkAction]` | string | Filter by bulk action ID |
| `filter[schedule]` | string | Filter by schedule ID |
| `filter[isTest]` | boolean | Filter test runs |
| `filter[tag]` | array | Filter by tags |

## Response (200)

```json
{
  "data": [
    {
      "id": "run_1234",
      "status": "COMPLETED",
      "taskIdentifier": "my-task",
      "version": "20240523.1",
      "env": {
        "id": "cl1234",
        "name": "dev",
        "user": "Anna"
      },
      "idempotencyKey": "idempotency_key_1234",
      "isTest": false,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:01:00Z",
      "startedAt": "2024-01-01T00:00:01Z",
      "finishedAt": "2024-01-01T00:01:00Z",
      "tags": ["user_5df987al13", "org_c6b7dycmxw"],
      "costInCents": 0.00292,
      "baseCostInCents": 0.0025,
      "durationMs": 491
    }
  ],
  "pagination": {
    "next": "run_1234",
    "previous": "run_5678"
  }
}
```

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid query parameters |
| 401 | Unauthorized |

## Code Examples

```typescript
import { runs } from "@trigger.dev/sdk";

// Get the first page of runs
let page = await runs.list({ limit: 20 });

for (const run of page.data) {
  console.log(`Run ID: ${run.id}, Status: ${run.status}`);
}

// Manual pagination
while (page.hasNextPage()) {
  page = await page.getNextPage();
}

// Auto-paginate through all runs
const allRuns = [];

for await (const run of runs.list({ limit: 20 })) {
  allRuns.push(run);
}
```

```typescript
import { runs } from "@trigger.dev/sdk";

// Filter runs
const response = await runs.list({
  status: ["QUEUED", "EXECUTING"],
  taskIdentifier: ["my-task", "my-other-task"],
  from: new Date("2024-04-01T00:00:00Z"),
  to: new Date(),
});

for (const run of response.data) {
  console.log(`Run ID: ${run.id}, Status: ${run.status}`);
}
```
