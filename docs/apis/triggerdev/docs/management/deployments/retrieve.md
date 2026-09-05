---
source: https://trigger.dev/docs/management/deployments/retrieve
scraped: 2026-02-28
---

# Get Deployment

Retrieve information about a specific deployment by its ID.

## Endpoint

`GET /api/v1/deployments/{deploymentId}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `deploymentId` | path | string | Yes | The deployment ID |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Response

**200 - Successful request**

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | The deployment ID |
| `status` | string | `PENDING`, `INSTALLING`, `BUILDING`, `DEPLOYING`, `DEPLOYED`, `FAILED`, `CANCELED`, or `TIMED_OUT` |
| `contentHash` | string | Hash of the deployment content |
| `shortCode` | string | The short code for the deployment |
| `version` | string | The deployment version (e.g., `20250228.1`) |
| `imageReference` | string \| null | Reference to the deployment image |
| `imagePlatform` | string | Platform of the deployment image |
| `externalBuildData` | object \| null | External build data if applicable |
| `errorData` | object \| null | Error data if the deployment failed |
| `worker` | object \| null | Worker information if available |
| `worker.id` | string | Worker ID |
| `worker.version` | string | Worker version |
| `worker.tasks` | array | Array of tasks with `id`, `slug`, `filePath`, `exportName` |

**401 - Unauthorized**

**404 - Deployment not found**

## Code Examples

### TypeScript

```typescript
const response = await fetch(
  `https://api.trigger.dev/api/v1/deployments/${deploymentId}`,
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
curl -X GET "https://api.trigger.dev/api/v1/deployments/deployment_1234" \
  -H "Authorization: Bearer tr_dev_1234"
```
