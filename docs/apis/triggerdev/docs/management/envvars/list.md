---
source: https://trigger.dev/docs/management/envvars/list
scraped: 2026-02-28
---

# List Env Vars

List all environment variables for a specific project and environment.

## Endpoint

`GET /api/v1/projects/{projectRef}/envvars/{env}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `projectRef` | path | string | Yes | Project external ref, starts with `proj_` (e.g., `proj_yubjwjsfkxnylobaqvqz`) |
| `env` | path | string | Yes | Environment: `dev`, `staging`, or `prod` |

## Authentication

Two methods supported:

- **Secret Key**: Project-specific Bearer token (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.)
- **Personal Access Token**: User-specific Bearer token (starts with `tr_pat_`)

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
// or
configure({ accessToken: "tr_pat_1234" });
```

## Response

**200 - Successful request** — Returns an array of `EnvVar` objects

```json
[
  { "name": "SLACK_API_KEY", "value": "slack_123456" }
]
```

**400 - Invalid request parameters**

**401 - Unauthorized request**

**404 - Resource not found**

## EnvVar Schema

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Variable name (e.g., `SLACK_API_KEY`) |
| `value` | string | Variable value (e.g., `slack_123456`) |

## TypeScript SDK Examples

```typescript
import { envvars, configure } from "@trigger.dev/sdk";

// Outside of a task
const variables = await envvars.list("proj_yubjwjsfkxnylobaqvqz", "dev");

for (const variable of variables) {
  console.log(`Name: ${variable.name}, Value: ${variable.value}`);
}
```

```typescript
import { envvars, task } from "@trigger.dev/sdk";

// Inside a task (projectRef and env auto-inferred from context)
export const myTask = task({
  id: "my-task",
  run: async () => {
    const variables = await envvars.list();

    for (const variable of variables) {
      console.log(`Name: ${variable.name}, Value: ${variable.value}`);
    }
  }
});
```
