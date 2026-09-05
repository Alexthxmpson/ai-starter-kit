---
source: https://trigger.dev/docs/management/batches/stream-items
scraped: 2026-02-28
---

# Stream Batch Items

Phase 2 of the 2-phase batch API. Accepts an NDJSON stream of batch items and enqueues them. Each line in the body should be a valid `BatchItemNDJSON` object. The stream is processed with backpressure - items are enqueued as they arrive. The batch is sealed when the stream completes successfully.

## Endpoint

**POST** `/api/v3/batches/{batchId}/items`

## Authentication

Requires a Bearer token (JWT). Use your project-specific Secret API key.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `batchId` | string | Yes | The batch ID returned from `POST /api/v3/batches` |

## Request Body

Content-Type must be `application/x-ndjson` or `application/ndjson`.

Each line is a `BatchItemNDJSON` object:

```
{"index":0,"task":"my-task","payload":{"key":"value1"}}
{"index":1,"task":"my-task","payload":{"key":"value2"}}
```

## Response (200)

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | The batch ID |
| `itemsAccepted` | integer | Number of items successfully accepted |
| `itemsDeduplicated` | integer | Number of items that were deduplicated (already enqueued) |
| `sealed` | boolean | Whether the batch was sealed and is ready for processing. If false, the batch needs more items before processing can start |
| `enqueuedCount` | integer | Total items currently enqueued. Only present when `sealed=false` to help with retries |
| `expectedCount` | integer | Expected total item count. Only present when `sealed=false` to help with retries |

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid request (e.g., invalid JSON, item exceeds maximum size) |
| 401 | Unauthorized - API key is missing or invalid |
| 415 | Unsupported Media Type - Content-Type must be `application/x-ndjson` or `application/ndjson` |
| 422 | Validation error |
| 500 | Internal server error |
