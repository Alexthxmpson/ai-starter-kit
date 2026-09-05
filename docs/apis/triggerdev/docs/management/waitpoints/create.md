---
source: https://trigger.dev/docs/management/waitpoints/create
scraped: 2026-02-28
---

# Create a Waitpoint Token

Create a waitpoint token that pauses task execution until an external event completes it. Each token includes a callback URL for HTTP POST completion and works with the `wait.forToken()` method.

## Endpoint

`POST /api/v1/waitpoints/tokens`

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

## Request Body (optional)

| Property | Type | Description |
|----------|------|-------------|
| `idempotencyKey` | string | Optional key to prevent duplicate token creation. Reusing the same key within its TTL returns the original token. |
| `idempotencyKeyTTL` | string | Duration the idempotency key remains valid (e.g., `30s`, `1m`, `2h`, `3d`) |
| `timeout` | string | Maximum wait duration before expiration; returns `ok: false` when exceeded. Accepts ISO 8601 dates or durations like `30s`, `1m`, `2h`, `3d`, `4w` |
| `tags` | string or array | Up to 10 tags (max 128 characters each). Recommended namespace format: `user:1234567` |

```json
{
  "timeout": "1h",
  "tags": ["user:1234567"]
}
```

## Response

**200 - Token created successfully**

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique waitpoint token identifier (e.g., `waitpoint_abc123`) |
| `isCached` | boolean | Whether an existing token was returned via idempotency key matching |
| `url` | string | HTTP callback URL accepting POST requests to complete the waitpoint (no API auth required) |

**401 - Unauthorized**

**422 - Unprocessable entity**

**500 - Server error**

## TypeScript SDK Example

```typescript
import { wait } from "@trigger.dev/sdk";

const token = await wait.createToken({
  timeout: "1h",
  tags: ["user:1234567"],
});

console.log(token.id);  // e.g. "waitpoint_abc123"
console.log(token.url); // HTTP callback URL to complete externally
```
