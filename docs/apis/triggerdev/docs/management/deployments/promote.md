---
source: https://trigger.dev/docs/management/deployments/promote
scraped: 2026-02-28
---

# Promote Deployment

Promote a previously deployed version to be the current version for the environment. This makes the specified version active for new task runs.

## Endpoint

`POST /api/v1/deployments/{version}/promote`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `version` | path | string | Yes | The deployment version to promote (e.g., `20250228.1`) |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Response

**200 - Deployment promoted successfully**

```json
{
  "id": "deployment_1234",
  "version": "20250228.1",
  "shortCode": "abc123"
}
```

**400 - Invalid request**

```json
{ "error": "..." }
```

**401 - Unauthorized — API key is missing or invalid**

**404 - Deployment not found**

## Code Examples

### TypeScript

```typescript
const response = await fetch(
  `https://api.trigger.dev/api/v1/deployments/${version}/promote`,
  {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${secretKey}`,
      "Content-Type": "application/json",
    },
  }
);
const result = await response.json();
```

### cURL

```bash
curl -X POST "https://api.trigger.dev/api/v1/deployments/20250228.1/promote" \
  -H "Authorization: Bearer tr_dev_1234" \
  -H "Content-Type: application/json"
```
