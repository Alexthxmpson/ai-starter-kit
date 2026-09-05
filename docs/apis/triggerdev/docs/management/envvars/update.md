---
source: https://trigger.dev/docs/management/envvars/update
scraped: 2026-02-28
---

# Update Env Var

Update a specific environment variable for a specific project and environment.

## Endpoint

`PUT /api/v1/projects/{projectRef}/envvars/{env}/{name}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `projectRef` | path | string | Yes | Project external ref, starts with `proj_` (e.g., `proj_yubjwjsfkxnylobaqvqz`) |
| `env` | path | string | Yes | Environment: `dev`, `staging`, or `prod` |
| `name` | path | string | Yes | Variable name to update (e.g., `SLACK_API_KEY`) |

## Authentication

Two methods supported:

- **Secret Key**: Project-specific Bearer token (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.)
- **Personal Access Token**: User-specific Bearer token (starts with `tr_pat_`)

## Request Body

```json
{
  "value": "slack_123456"
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `value` | string | Yes | New value for the variable |

## Response

**200 - Environment variable updated successfully**

```json
{ "success": true }
```

**400 - Invalid request parameters** — Returns `InvalidEnvVarsRequestResponse`

**401 - Unauthorized request**

**404 - Resource not found**

## TypeScript SDK Examples

```typescript
import { envvars } from "@trigger.dev/sdk";

// Outside of a task
await envvars.update("proj_yubjwjsfkxnylobaqvqz", "dev", "SLACK_API_KEY", {
  value: "slack_123456"
});
```

```typescript
import { envvars, task } from "@trigger.dev/sdk";

// Inside a task (projectRef and env auto-inferred from context)
export const myTask = task({
  id: "my-task",
  run: async () => {
    await envvars.update("SLACK_API_KEY", {
      value: "slack_123456"
    });
  }
});
```
