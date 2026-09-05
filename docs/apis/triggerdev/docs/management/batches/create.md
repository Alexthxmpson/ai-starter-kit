---
source: https://trigger.dev/docs/management/batches/create
scraped: 2026-02-28
---

# Create Batch

Phase 1 of the 2-phase batch API. Creates a batch record and optionally blocks the parent run for `batchTriggerAndWait`. After creating a batch, stream items via `POST /api/v3/batches/{batchId}/items`.

## Endpoint

**POST** `/api/v3/batches`

## Authentication

Requires a Bearer token (JWT). Use your project-specific Secret API key.

## Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `runCount` | integer (min 1) | Yes | Expected number of items in the batch. Must be a positive integer |
| `parentRunId` | string | No | Parent run ID (friendly ID) for `batchTriggerAndWait` |
| `resumeParentOnCompletion` | boolean | No | Whether to resume parent on completion. Set to `true` for `batchTriggerAndWait` |
| `idempotencyKey` | string | No | If provided and a batch with this key already exists, the existing batch will be returned |

## Response (202)

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | The batch ID. Use this to stream items via `POST /api/v3/batches/{batchId}/items` |
| `runCount` | integer | The expected run count |
| `isCached` | boolean | Whether this response came from a cached/idempotent batch |
| `idempotencyKey` | string | The idempotency key if provided |

Response headers include:
- `x-trigger-jwt-claims`: JWT claims for the batch
- `x-trigger-jwt`: JWT token for browser clients

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid request (e.g., runCount <= 0 or exceeds maximum) |
| 401 | Unauthorized - API key is missing or invalid |
| 422 | Validation error |
| 429 | Rate limit exceeded |
| 500 | Internal server error |

### Rate Limit Headers (429)

- `X-RateLimit-Limit`: Maximum number of requests allowed
- `X-RateLimit-Remaining`: Number of requests remaining
- `X-RateLimit-Reset`: Unix timestamp when the rate limit resets
- `Retry-After`: Seconds to wait before retrying
