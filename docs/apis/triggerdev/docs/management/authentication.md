---
source: https://trigger.dev/docs/management/authentication
scraped: 2026-02-28
---

# Authentication

## Overview

Trigger.dev provides two backend authentication methods for the management API: secret keys (environment-scoped) and personal access tokens (user-scoped). Both should only be used on backend servers.

> "There is a separate authentication strategy when making requests from your frontend application."

## Authentication Methods

### Secret Key Authentication

Secret keys are tied to specific environments within a project. They begin with `tr_dev_` or `tr_prod_` prefixes and work with most endpoints without requiring a `projectRef` argument.

### Personal Access Token (PAT)

PATs are user-associated tokens providing access across all organizations, projects, and environments the user can access. These tokens start with `tr_pat_` and require a `projectRef` argument (sometimes also an environment parameter) since they're not environment-scoped.

## Implementation Examples

**Using Secret Key:**
```ts
import { configure, runs } from "@trigger.dev/sdk";

configure({
  secretKey: process.env["TRIGGER_SECRET_KEY"],
});

runs.list({
  limit: 10,
  status: ["COMPLETED"],
});
```

**Using Personal Access Token:**
```ts
configure({
  secretKey: process.env["TRIGGER_ACCESS_TOKEN"],
});

runs.list("prof_1234", {
  limit: 10,
  status: ["COMPLETED"],
  projectRef: "tr_proj_1234567890",
});
```

## Endpoint Support Matrix

| Endpoint | Secret Key | PAT |
|----------|:----------:|:---:|
| `task.trigger` | Yes | |
| `task.batchTrigger` | Yes | |
| `runs.list` | Yes | Yes |
| `runs.retrieve` | Yes | |
| `runs.cancel` | Yes | |
| `runs.replay` | Yes | |
| `envvars.*` | Yes | Yes |
| `schedules.*` | Yes | |

## Preview Branch Targeting

Target specific preview branches using the `previewBranch` configuration option:

**SDK Method:**
```ts
configure({
  secretKey: process.env["TRIGGER_ACCESS_TOKEN"],
  previewBranch: "feature-xyz",
});

await envvars.update("proj_1234", "preview", "DATABASE_URL", {
  value: "your_preview_database_url",
});
```

**cURL Method:**
```bash
curl --request PUT \
  --url https://api.trigger.dev/api/v1/projects/{projectRef}/envvars/preview/DATABASE_URL \
  --header 'Authorization: Bearer <token>' \
  --header 'x-trigger-branch: feature-xyz' \
  --header 'Content-Type: application/json' \
  --data '{"value": "your_preview_database_url"}'
```

> "The x-trigger-branch header is only relevant when working with the preview environment."
