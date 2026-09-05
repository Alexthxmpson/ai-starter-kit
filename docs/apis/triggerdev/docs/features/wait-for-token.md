---
source: https://trigger.dev/docs/wait-for-token
scraped: 2026-02-28
---

# Wait for Token

## Overview

Waitpoint tokens pause task runs until completion, commonly used for approval workflows and human-in-the-loop processes. They can be completed via SDK or HTTP POST requests.

## Core Functions

### wait.createToken

Creates a token that pauses execution. Returns an object containing:
- **id**: Token identifier (starts with `waitpoint_`)
- **url**: HTTP endpoint for completing the token
- **isCached**: Boolean indicating if token was cached via idempotency key
- **publicAccessToken**: For client-side completion

Optional parameters:
- `timeout`: Maximum wait duration (defaults to "10m")
- `idempotencyKey`: For idempotent token creation
- `idempotencyKeyTTL`: Idempotency key expiration (defaults to "1h")
- `tags`: String array for dashboard filtering

### wait.forToken

Waits for token completion inside task runs. Returns a result object with:
- **ok**: Boolean success indicator
- **output**: Token completion data (if successful)
- **error**: Timeout error information (if unsuccessful)

Includes an `.unwrap()` method that throws on timeout or returns the output directly.

### wait.completeToken

Completes a token from anywhere in your codebase. Requires:
- Token ID
- Output data (any type)

Returns success boolean.

### HTTP Completion

Tokens can be completed via POST requests to the provided URL:

```bash
curl -X POST "https://api.trigger.dev/api/v1/waitpoints/tokens/{tokenId}/complete" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"data": { "status": "approved"}}'
```

Examples provided in Python, Ruby, and Go.

### wait.listTokens

Lists environment tokens with optional filtering by:
- Status: `WAITING`, `COMPLETED`, `TIMED_OUT`
- Idempotency key
- Tags
- Time period or date range

Returns an async iterable of token objects (excludes output data).

### wait.retrieveToken

Retrieves a single token by ID, including its output and error information.

## Idempotency

Use `idempotencyKey` and `idempotencyKeyTTL` to skip waits when retrying tasks with the same key within the TTL period.

## Use Cases

The documentation demonstrates webhook callbacks with external services like Replicate, where tokens provide completion URLs for third-party systems to notify when operations finish.
