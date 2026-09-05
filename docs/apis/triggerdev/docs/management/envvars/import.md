---
source: https://trigger.dev/docs/management/envvars/import
scraped: 2026-02-28
---

# Import Env Vars

Upload multiple environment variables for a specific project and environment.

## Endpoint

`POST /api/v1/projects/{projectRef}/envvars/{env}/import`

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
  "variables": [
    { "name": "SLACK_API_KEY", "value": "slack_123456" },
    { "name": "OTHER_KEY", "value": "other_value" }
  ],
  "override": false
}
```

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `variables` | array | Yes | Array of `EnvVar` objects (`{ name, value }`) |
| `override` | boolean | No | Whether to override existing variables (default: `false`) |

## Response

**200 - Environment variables imported successfully**

```json
{ "success": true }
```

**400 - Invalid request parameters** — Returns `InvalidEnvVarsRequestResponse`:

```json
{
  "error": "...",
  "issues": [],
  "variableErrors": []
}
```

**401 - Unauthorized request**

**404 - Resource not found**

## TypeScript SDK Example

```typescript
import { envvars } from "@trigger.dev/sdk";

await envvars.upload("proj_yubjwjsfkxnylobaqvqz", "dev", {
  variables: { SLACK_API_KEY: "slack_key_1234" },
  override: false
});
```
