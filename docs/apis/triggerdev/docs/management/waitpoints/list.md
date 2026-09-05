---
source: https://trigger.dev/docs/management/waitpoints/list
scraped: 2026-02-28
---

# List Waitpoint Tokens

Retrieve a paginated list of waitpoint tokens for the current environment, ordered by creation date (newest first).

## Endpoint

`GET /api/v1/waitpoints/tokens`

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

## Query Parameters

### Pagination

| Parameter | Type | Description |
|-----------|------|-------------|
| `page[size]` | integer (1–100) | Number of tokens per page |
| `page[after]` | string | Cursor for next page (from previous response) |
| `page[before]` | string | Cursor for previous page (from previous response) |

### Filtering

| Parameter | Type | Description |
|-----------|------|-------------|
| `filter[status]` | string | Comma-separated statuses: `WAITING`, `COMPLETED`, `TIMED_OUT` |
| `filter[idempotencyKey]` | string | Filter by idempotency key |
| `filter[tags]` | string | Comma-separated tags (e.g., `user:1234567,org:9876543`) |
| `filter[createdAt][period]` | string | Shorthand period like `1h`, `24h`, `7d` |
| `filter[createdAt][from]` | ISO 8601 | Tokens created at or after this timestamp |
| `filter[createdAt][to]` | ISO 8601 | Tokens created at or before this timestamp |

## Response

**200 - Successful request**

Returns an object with:

- `data`: Array of `WaitpointTokenObject` items
- `pagination`: Object with `next` and `previous` cursor strings (nullable)

### WaitpointTokenObject Schema

| Property | Type | Nullable | Description |
|----------|------|----------|-------------|
| `id` | string | No | Unique identifier (e.g., `waitpoint_abc123`) |
| `url` | string | No | HTTP callback URL for completing the waitpoint |
| `status` | enum | No | `WAITING`, `COMPLETED`, or `TIMED_OUT` |
| `idempotencyKey` | string | Yes | Key used during creation |
| `timeoutAt` | ISO 8601 | Yes | Timeout timestamp |
| `completedAt` | ISO 8601 | Yes | Completion timestamp |
| `output` | string | Yes | Serialized output data |
| `outputType` | string | Yes | Content type (e.g., `application/json`) |
| `outputIsError` | boolean | Yes | Whether output is an error |
| `tags` | array | No | Attached tags |
| `createdAt` | ISO 8601 | No | Creation timestamp |

**401 - Unauthorized**

**422 - Invalid query parameters**

**500 - Internal Server Error**

## TypeScript SDK Examples

```typescript
import { wait } from "@trigger.dev/sdk";

// Iterate over all tokens (auto-paginated)
for await (const token of wait.listTokens()) {
  console.log(token.id, token.status);
}

// Filter by status and tags
for await (const token of wait.listTokens({
  status: ["WAITING"],
  tags: ["user:1234567"],
})) {
  console.log(token.id);
}
```
