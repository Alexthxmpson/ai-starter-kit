---
source: https://trigger.dev/docs/management/runs/retrieve-trace
scraped: 2026-02-28
---

# Retrieve Run Trace

Returns the full OTel trace tree for a run, including all spans and their children.

## Endpoint

**GET** `/api/v1/runs/{runId}/trace`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run ID, starts with `run_`. Example: `run_1234` |

## Response (200)

```json
{
  "trace": {
    "traceId": "string",
    "rootSpan": {
      // SpanDetailedSummary object
    }
  }
}
```

### SpanDetailedSummary Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | The span ID |
| `parentId` | string (nullable) | The parent span ID, if any |
| `runId` | string | The run ID this span belongs to |
| `data` | object | Span metadata (see below) |
| `children` | array | Nested child spans with identical structure |

### Data Properties

| Property | Type | Description |
|----------|------|-------------|
| `message` | string | The span message |
| `taskSlug` | string | The task identifier, if applicable |
| `startTime` | string | Start time (ISO 8601 format) |
| `duration` | number | Duration in nanoseconds |
| `isError` | boolean | Error flag |
| `isPartial` | boolean | Partial flag |
| `isCancelled` | boolean | Cancellation flag |
| `level` | enum | Log level: `TRACE`, `DEBUG`, `LOG`, `INFO`, `WARN`, `ERROR` |
| `attemptNumber` | number (nullable) | Attempt number |
| `properties` | object | Arbitrary OTel attributes |
| `events` | array | Span events with name, time, and event-specific properties |

## Error Responses

| Status | Description |
|--------|-------------|
| 401 | Invalid or Missing API key |
| 404 | Run not found or Trace not found |

## Code Example

```typescript
const response = await fetch("https://api.trigger.dev/api/v1/runs/run_1234/trace", {
  headers: {
    Authorization: `Bearer ${process.env.TRIGGER_SECRET_KEY}`,
  },
});

const { trace } = await response.json();
```
