---
source: https://trigger.dev/docs/deploy-environment-variables
scraped: 2026-02-28
---

# Environment Variables

## Overview

Environment variables in Node.js are accessed using `process.env.MY_ENV_VAR`. Trigger.dev automatically injects these variables before task execution, so any variables your tasks require must be configured in the platform.

## Dashboard Management

### Setting Variables

Navigate to the Environment Variables page in the sidebar and click "New environment variable." You can specify distinct values for local development, staging, and production environments.

**Note:** Dev values are optional and will be overridden by values in your `.env` file during local development.

### Editing Variables

You can modify variable values but cannot change the key name — deletion and recreation is required for key changes.

### Deleting Variables

**Warning:** "Environment variables are fetched and injected before a run begins." Deleting variables may cause active runs to fail if they expect those variables.

## Local Development

Running `npx trigger.dev dev` automatically loads variables from these files in priority order (later files override earlier duplicates):

- `.env`
- `.env.development`
- `.env.local`
- `.env.development.local`
- `dev.vars`

No `--env-file` flag is needed for this automatic loading.

## Programmatic Access

### SDK Functions

| Function | Purpose |
|----------|---------|
| `envvars.list()` | List all environment variables |
| `envvars.upload()` | Bulk import/override multiple variables |
| `envvars.create()` | Create new variable |
| `envvars.retrieve()` | Fetch specific variable |
| `envvars.update()` | Modify variable |
| `envvars.del()` | Remove variable |

### Initial .env Import

Use `envvars.upload()` for one-time bulk imports from `.env` files:

```ts
import { envvars } from "@trigger.dev/sdk";
import { readFileSync } from "fs";
import { parse } from "dotenv";

const envContent = readFileSync(".env.production", "utf-8");
const parsed = parse(envContent);

await envvars.upload("proj_your_project_ref", "prod", {
  variables: parsed,
  override: false,
});
```

Inside tasks, project reference and environment are inferred automatically.

### Accessing Environment Context

Within a task, retrieve current environment details:

```ts
import { task } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  run: async (payload, { ctx }) => {
    const slug = ctx.environment.slug; // "dev", "prod", etc.
    const type = ctx.environment.type; // "DEVELOPMENT", "PRODUCTION", etc.
  },
});
```

## Syncing from External Services

Use the `syncEnvVars` build extension in `trigger.config` for automated synchronization:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncEnvVars } from "@trigger.dev/build/extensions/core";
import { InfisicalSDK } from "@infisical/sdk";

export default defineConfig({
  build: {
    extensions: [
      syncEnvVars(async (ctx) => {
        const client = new InfisicalSDK();
        // Fetch and return secrets
      }),
    ],
  },
});
```

**Important:** `syncEnvVars` only affects deploys, not local `dev` command execution. For local development with external secrets, use service CLIs: `infisical run -- npx trigger.dev@latest dev`

## .env.production and dotenvx

Trigger.dev does not automatically load `.env.production` or dotenvx files during deployment. Two options:

**Option 1 — Manual Entry:** Copy file contents into the dashboard Environment Variables editor.

**Option 2 — Automated Sync:** Use `syncEnvVars` with dotenvx parsing.

## Google Credentials

Securely pass Google credential JSON files by:

1. Converting to base64: `base64 -i path/to/service-account-file.json`
2. Setting `GOOGLE_CREDENTIALS_BASE64` environment variable
3. Decoding in your task:

```ts
const credentials = JSON.parse(
  Buffer.from(process.env.GOOGLE_CREDENTIALS_BASE64, "base64").toString("utf8")
);
```

## Multi-Tenant Applications

For applications serving multiple tenants, use a secrets service (AWS Secrets Manager, Infisical, Vault) to retrieve tenant-specific credentials at runtime rather than syncing per-tenant variables. This maintains a single codebase while securely isolating tenant data.

**Critical:** Never include secrets in task payloads, as payloads are logged and visible in the dashboard.
