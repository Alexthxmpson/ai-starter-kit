---
source: https://trigger.dev/docs/management/runs/retrieve-events
scraped: 2026-02-28
---

# Retrieve Run Events

Fetch all OpenTelemetry span events associated with a specific run, enabling debugging and observability insights.

## Endpoint

**GET** `/api/v1/runs/{runId}/events`

## Authentication

Requires a bearer token using your project-specific Secret API key (starting with `tr_dev_`, `tr_prod`, `tr_stg`, etc.). Can be provided via the `TRIGGER_SECRET_KEY` environment variable.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run identifier beginning with `run_`, returned when triggering a task |

## Response (200)

Returns an object containing an `events` array. Each event object includes:

| Field | Type | Description |
|-------|------|-------------|
| `spanId` | string | Identifier for the span |
| `parentId` | string (nullable) | Parent span identifier if applicable |
| `runId` | string (nullable) | Associated run identifier |
| `message` | string | Event description |
| `startTime` | string | Event start time as bigint nanoseconds since epoch |
| `duration` | number | Event duration in nanoseconds |
| `isError` | boolean | Error status indicator |
| `isPartial` | boolean | In-progress status |
| `isCancelled` | boolean | Cancellation status |
| `level` | enum | Log level: `TRACE`, `DEBUG`, `LOG`, `INFO`, `WARN`, `ERROR` |
| `kind` | enum | Span type: `UNSPECIFIED`, `INTERNAL`, `SERVER`, `CLIENT`, `PRODUCER`, `CONSUMER`, `UNRECOGNIZED`, `LOG` |
| `attemptNumber` | number (nullable) | Retry attempt count |
| `taskSlug` | string | Task identifier |
| `events` | array | Sub-events (exceptions, cancellations, failures) |
| `style` | object | Display metadata with icon, variant, and accessory properties |

## Error Responses

| Status | Description |
|--------|-------------|
| 401 | Invalid or Missing API key |
| 404 | Run not found |

## Code Example

```typescript
const response = await fetch("https://api.trigger.dev/api/v1/runs/run_1234/events", {
  headers: {
    Authorization: `Bearer ${process.env.TRIGGER_SECRET_KEY}`,
  },
});

const { events } = await response.json();
```
