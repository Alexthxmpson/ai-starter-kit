---
source: https://trigger.dev/docs/management/waitpoints/complete-callback
scraped: 2026-02-28
---

# Complete a Waitpoint Token via HTTP Callback

Complete a waitpoint token using a pre-signed callback URL. No API key is required — the `callbackHash` in the URL acts as the authentication token. Designed for external services (such as webhooks) to unblock waiting runs without exposing API credentials.

The entire request body is passed as the output data to the waiting run. If the token is already completed, the request returns `success: true` with no further action.

## Endpoint

`POST https://api.trigger.dev/api/v1/waitpoints/tokens/{waitpointId}/callback/{callbackHash}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `waitpointId` | path | string | Yes | The ID of the waitpoint token (e.g., `waitpoint_abc123`) |
| `callbackHash` | path | string | Yes | HMAC hash authenticating the request, embedded in the URL returned during token creation |

## Authentication

No API key required. The `callbackHash` in the URL serves as authentication.

## Request Body (optional)

Any valid JSON — becomes the output data for the waiting run. If invalid JSON is provided, an empty object is used.

```json
{
  "status": "approved",
  "comment": "Looks good to me!"
}
```

## Response

| Status | Description |
|--------|-------------|
| 200 | Success — returns `{ "success": true }` |
| 401 | Invalid callback URL or hash mismatch |
| 404 | Waitpoint token not found |
| 405 | Method not allowed |
| 411 | Content-Length header required |
| 413 | Request body too large |
| 500 | Internal server error |

## Usage Pattern

```typescript
import { wait } from "@trigger.dev/sdk";

// Create token in your task
const token = await wait.createToken({ timeout: "1h" });

await sendApprovalRequestEmail({
  callbackUrl: token.url, // Share with external service
});

// External service POSTs to token.url to unblock
const result = await wait.forToken<{ status: string }>(token);
```

## cURL Example

```bash
curl -X POST \
  "https://api.trigger.dev/api/v1/waitpoints/tokens/waitpoint_abc123/callback/abc123hash" \
  -H "Content-Type: application/json" \
  -d '{"status": "approved", "comment": "Looks good to me!"}'
```
