---
source: https://trigger.dev/docs/management/envvars/delete
scraped: 2026-02-28
---

# Delete Env Var

Delete a specific environment variable for a specific project and environment.

## Endpoint

`DELETE /api/v1/projects/{projectRef}/envvars/{env}/{name}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `projectRef` | path | string | Yes | Project external ref, starts with `proj_` (e.g., `proj_yubjwjsfkxnylobaqvqz`) |
| `env` | path | string | Yes | Environment: `dev`, `staging`, or `prod` |
| `name` | path | string | Yes | Variable name to delete (e.g., `SLACK_API_KEY`) |

## Authentication

Two methods supported:

- **Secret Key**: Project-specific Bearer token (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.)
- **Personal Access Token**: User-specific Bearer token (starts with `tr_pat_`)

## Response

**200 - Environment variable deleted successfully**

```json
{ "success": true }
```

**400 - Invalid request parameters**

**401 - Unauthorized request**

**404 - Resource not found**

## TypeScript SDK Examples

```typescript
import { envvars } from "@trigger.dev/sdk";

// Outside of a task
await envvars.del("proj_yubjwjsfkxnylobaqvqz", "dev", "SLACK_API_KEY");
```

```typescript
import { envvars, task } from "@trigger.dev/sdk";

// Inside a task (projectRef and env auto-inferred from context)
export const myTask = task({
  id: "my-task",
  run: async () => {
    await envvars.del("SLACK_API_KEY");
  }
});
```
