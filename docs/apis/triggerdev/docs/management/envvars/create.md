---
source: https://trigger.dev/docs/management/envvars/create
scraped: 2026-02-28
---

# Create Env Var

Create a new environment variable for a specific project and environment.

## Endpoint

`POST /api/v1/projects/{projectRef}/envvars/{env}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `projectRef` | path | string | Yes | Project external ref, starts with `proj_` (e.g., `proj_yubjwjsfkxnylobaqvqz`) |
| `env` | path | string | Yes | Environment: `dev`, `staging`, or `prod` |

## Authentication

Two methods supported:

- **Secret Key**: Project-specific Bearer token (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.)
- **Personal Access Token**: User-specific Bearer token (starts with `tr_pat_`)

## Request Body

```json
{
  "name": "SLACK_API_KEY",
  "value": "slack_123456"
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `name` | string | Yes | Variable name |
| `value` | string | Yes | Variable value |

## Response

**200 - Environment variable created successfully**

```json
{ "success": true }
```

**400 - Invalid request parameters** — Returns `InvalidEnvVarsRequestResponse` with `error`, `issues`, and `variableErrors` fields

**401 - Unauthorized request**

**404 - Resource not found**

## TypeScript SDK Examples

```typescript
import { envvars } from "@trigger.dev/sdk";

// Outside of a task
await envvars.create("proj_yubjwjsfkxnylobaqvqz", "dev", {
  name: "SLACK_API_KEY",
  value: "slack_123456"
});
```

```typescript
import { envvars, task } from "@trigger.dev/sdk";

// Inside a task (projectRef and env auto-inferred from context)
export const myTask = task({
  id: "my-task",
  run: async () => {
    await envvars.create({
      name: "SLACK_API_KEY",
      value: "slack_123456"
    });
  }
});
```
