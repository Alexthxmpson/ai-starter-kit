---
source: https://trigger.dev/docs/management/envvars/retrieve
scraped: 2026-02-28
---

# Retrieve Env Var

Retrieve a specific environment variable for a specific project and environment.

## Endpoint

`GET /api/v1/projects/{projectRef}/envvars/{env}/{name}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `projectRef` | path | string | Yes | Project external ref, starts with `proj_` (e.g., `proj_yubjwjsfkxnylobaqvqz`) |
| `env` | path | string | Yes | Environment: `dev`, `staging`, or `prod` |
| `name` | path | string | Yes | Variable name (e.g., `SLACK_API_KEY`) |

## Authentication

Two methods supported:

- **Secret Key**: Project-specific Bearer token (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.)
- **Personal Access Token**: User-specific Bearer token (starts with `tr_pat_`)

## Response

**200 - Successful request**

```json
{
  "value": "slack_123456"
}
```

**400 - Invalid request parameters**

**401 - Unauthorized request**

**404 - Resource not found**

## TypeScript SDK Examples

```typescript
import { envvars } from "@trigger.dev/sdk";

// Outside of a task
const variable = await envvars.retrieve("proj_yubjwjsfkxnylobaqvqz", "dev", "SLACK_API_KEY");

console.log(`Value: ${variable.value}`);
```

```typescript
import { envvars, task } from "@trigger.dev/sdk";

// Inside a task (projectRef and env auto-inferred from context)
export const myTask = task({
  id: "my-task",
  run: async () => {
    const variable = await envvars.retrieve("SLACK_API_KEY");

    console.log(`Value: ${variable.value}`);
  }
});
```
