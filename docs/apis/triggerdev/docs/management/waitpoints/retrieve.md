---
source: https://trigger.dev/docs/management/waitpoints/retrieve
scraped: 2026-02-28
---

# Retrieve a Waitpoint Token

Retrieve a waitpoint token by its ID, displaying its current status and output if completed.

## Endpoint

`GET /api/v1/waitpoints/tokens/{waitpointId}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `waitpointId` | path | string | Yes | The ID of the waitpoint token (e.g., `waitpoint_abc123`) |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.). The TypeScript SDK defaults to the `TRIGGER_SECRET_KEY` environment variable.

## Response

**200 - Successful request** — Returns a `WaitpointTokenObject`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | string | No | Unique identifier for the token |
| `url` | string | No | HTTP callback URL for completing the waitpoint |
| `status` | enum | No | `WAITING`, `COMPLETED`, or `TIMED_OUT` |
| `idempotencyKey` | string | Yes | Idempotency key used during creation |
| `idempotencyKeyExpiresAt` | date-time | Yes | Expiration time of the idempotency key |
| `timeoutAt` | date-time | Yes | When the token will timeout |
| `completedAt` | date-time | Yes | When the token was completed |
| `output` | string | Yes | Serialized output data (present when completed) |
| `outputType` | string | Yes | Content type of output (e.g., `application/json`) |
| `outputIsError` | boolean | Yes | Whether output represents an error |
| `tags` | array | No | Tags attached to the waitpoint |
| `createdAt` | date-time | No | Creation timestamp |

**401 - Unauthorized**

**404 - Waitpoint token not found**

**500 - Internal Server Error**

## TypeScript SDK Example

```typescript
import { wait } from "@trigger.dev/sdk";

const token = await wait.retrieveToken("waitpoint_abc123");

console.log(token.status); // "WAITING" | "COMPLETED" | "TIMED_OUT"

if (token.status === "COMPLETED") {
  console.log(token.output);
}
```
