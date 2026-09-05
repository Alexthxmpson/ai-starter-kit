---
source: https://trigger.dev/docs/management/deployments/get-latest
scraped: 2026-02-28
---

# Get Latest Deployment

Retrieve information about the latest unmanaged deployment for the authenticated project.

## Endpoint

`GET /api/v1/deployments/latest`

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.). Found in the API Keys section of your project dashboard.

## Response

**200 - Successful request**

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | The deployment identifier |
| `status` | string | `PENDING`, `INSTALLING`, `BUILDING`, `DEPLOYING`, `DEPLOYED`, `FAILED`, `CANCELED`, or `TIMED_OUT` |
| `contentHash` | string | Hash representing the deployment content |
| `shortCode` | string | Brief identifier for the deployment |
| `version` | string | Version number (e.g., `20250228.1`) |
| `imageReference` | string \| null | Container image reference if applicable |
| `errorData` | object \| null | Error details if deployment failed |

**401 - Missing or invalid API key**

**404 - No deployment found**

## Code Examples

### TypeScript

```typescript
const response = await fetch(
  "https://api.trigger.dev/api/v1/deployments/latest",
  {
    method: "GET",
    headers: {
      "Authorization": `Bearer ${secretKey}`,
    },
  }
);
const deployment = await response.json();
```

### cURL

```bash
curl -X GET "https://api.trigger.dev/api/v1/deployments/latest" \
  -H "Authorization: Bearer tr_dev_1234"
```
