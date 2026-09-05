---
source: https://trigger.dev/docs/config/extensions/syncEnvVars
scraped: 2026-02-28
---

# Sync env vars

Use the syncEnvVars build extension to automatically sync environment variables to Trigger.dev.

The `syncEnvVars` build extension will sync env vars from another service into Trigger.dev before the deployment starts. This is useful if you are using a secret store service like Infisical or AWS Secrets Manager to store your secrets.

`syncEnvVars` takes an async callback function, and any env vars returned from the callback will be synced to Trigger.dev.

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncEnvVars } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  build: {
    extensions: [
      syncEnvVars(async (ctx) => {
        return [
          { name: "SECRET_KEY", value: "secret-value" },
          { name: "ANOTHER_SECRET", value: "another-secret-value" },
        ];
      }),
    ],
  },
});
```

The callback is passed a context object with the following properties:

- `environment`: The environment name that the task is being deployed to (e.g. `production`, `staging`, etc.)
- `projectRef`: The project ref of the Trigger.dev project
- `env`: The environment variables that are currently set in the Trigger.dev project

## Example: Sync env vars from Infisical

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncEnvVars } from "@trigger.dev/build/extensions/core";
import { InfisicalSDK } from "@infisical/sdk";

export default defineConfig({
  build: {
    extensions: [
      syncEnvVars(async (ctx) => {
        const client = new InfisicalSDK();

        await client.auth().universalAuth.login({
          clientId: process.env.INFISICAL_CLIENT_ID!,
          clientSecret: process.env.INFISICAL_CLIENT_SECRET!,
        });

        const { secrets } = await client.secrets().listSecrets({
          environment: ctx.environment,
          projectId: process.env.INFISICAL_PROJECT_ID!,
        });

        return secrets.map((secret) => ({
          name: secret.secretKey,
          value: secret.secretValue,
        }));
      }),
    ],
  },
});
```

## syncVercelEnvVars

The `syncVercelEnvVars` build extension syncs environment variables from your Vercel project to Trigger.dev.

### Setting up authentication including team projects

You need to set the `VERCEL_ACCESS_TOKEN` and `VERCEL_PROJECT_ID` environment variables, or pass in the token and project ID as arguments. If you're working with a team project, you'll also need to set `VERCEL_TEAM_ID`.

You can find / generate the `VERCEL_ACCESS_TOKEN` in your Vercel [dashboard](https://vercel.com/account/settings/tokens).

### Running in Vercel build environment

When running the build from a Vercel build environment (determined by checking if the `VERCEL` environment variable is present), the environment variable values will be read from `process.env` instead of fetching them from the Vercel API.

### Using with Neon database Vercel integration

If you have the Neon database Vercel integration installed and are running builds outside of the Vercel environment, use `syncNeonEnvVars` in addition to `syncVercelEnvVars` for your database environment variables.

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncVercelEnvVars } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    // This will automatically use the VERCEL_ACCESS_TOKEN and VERCEL_PROJECT_ID environment variables
    extensions: [syncVercelEnvVars()],
  },
});
```

Or pass in the token and project ID as arguments:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncVercelEnvVars } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      syncVercelEnvVars({
        projectId: "your-vercel-project-id",
        vercelAccessToken: "your-vercel-access-token", // optional, recommend as env variable
        vercelTeamId: "your-vercel-team-id", // optional
      }),
    ],
  },
});
```

## syncNeonEnvVars

The `syncNeonEnvVars` build extension syncs environment variables from your Neon database project to Trigger.dev. It automatically detects branches and builds the appropriate database connection strings.

### Setting up authentication

Set the `NEON_ACCESS_TOKEN` and `NEON_PROJECT_ID` environment variables, or pass them as arguments.

You can generate a `NEON_ACCESS_TOKEN` in your Neon [dashboard](https://console.neon.tech/app/settings/api-keys).

### Running in Vercel environment

When the `VERCEL` environment variable is present, this extension is skipped entirely — Neon's Vercel integration already handles synchronization in that case.

**Note:** This extension is skipped for `prod` environments. It is designed to sync branch-specific database connections for preview/staging environments.

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncNeonEnvVars } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [syncNeonEnvVars()],
  },
});
```

Or with explicit arguments:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncNeonEnvVars } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      syncNeonEnvVars({
        projectId: "your-neon-project-id",
        neonAccessToken: "your-neon-access-token",
        branch: "your-branch-name", // optional, defaults to ctx.branch
        databaseName: "your-database-name", // optional, defaults to the first database
        roleName: "your-role-name", // optional, defaults to the database owner
        envVarPrefix: "MY_PREFIX_", // optional, prefix for all synced env vars
      }),
    ],
  },
});
```

The extension syncs the following environment variables (with optional prefix):

- `DATABASE_URL` - Pooled connection string
- `DATABASE_URL_UNPOOLED` - Direct connection string
- `POSTGRES_URL`, `POSTGRES_URL_NO_SSL`, `POSTGRES_URL_NON_POOLING`
- `POSTGRES_PRISMA_URL` - Connection string optimized for Prisma
- `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DATABASE`
- `PGHOST`, `PGHOST_UNPOOLED`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`
