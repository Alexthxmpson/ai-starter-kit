---
source: https://trigger.dev/docs/management/waitpoints/complete
scraped: 2026-02-28
---

# Complete a Waitpoint Token

Complete a waitpoint token, which unblocks any run waiting for it through `wait.forToken()`. You can optionally pass a data payload that will be returned to the waiting run. If the token is already completed, the operation is idempotent and returns `success: true`.

Supports both secret API keys and short-lived JWTs (public access tokens), making it safe for frontend client calls.

## Endpoint

`POST /api/v1/waitpoints/tokens/{waitpointId}/complete`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `waitpointId` | path | string | Yes | The ID of the waitpoint token to complete (e.g., `waitpoint_abc123`) |

## Authentication

Two authentication methods are supported:

- **Secret API Key**: Project-specific keys (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.)
- **Public Access Token**: Short-lived JWT scoped to a specific waitpoint token, returned from `wait.createToken()` or `POST /api/v1/waitpoints/tokens`

## Request Body (optional)

Any JSON-serializable value to pass back to the run waiting on this token.

```json
{
  "status": "approved",
  "comment": "Looks good to me!"
}
```

## Response

**200 - Waitpoint token completed successfully**

```json
{ "success": true }
```

**401 - Unauthorized**

**404 - Waitpoint token not found**

**500 - Internal Server Error**

## TypeScript SDK Examples

```typescript
import { wait } from "@trigger.dev/sdk";

// Complete with data (returned to the waiting run)
await wait.completeToken(token, {
  status: "approved",
  comment: "Looks good to me!",
});

// Complete with no data
await wait.completeToken(token, {});
```
