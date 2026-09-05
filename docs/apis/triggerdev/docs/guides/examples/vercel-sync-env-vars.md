---
source: https://trigger.dev/docs/guides/examples/vercel-sync-env-vars
scraped: 2026-02-28
---

# Syncing Environment Variables from Vercel to Trigger.dev

## Overview

This documentation explains how to automatically sync environment variables from Vercel projects to Trigger.dev using a build extension.

## Setup Requirements

- `VERCEL_ACCESS_TOKEN` - Generated from your Vercel account settings
- `VERCEL_PROJECT_ID` - Found in your project's settings
- `VERCEL_TEAM_ID` - Required only for team projects (found in team settings)

## Configuration

Add the `syncVercelEnvVars` build extension to your `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { syncVercelEnvVars } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      syncVercelEnvVars({
        vercelAccessToken: process.env.VERCEL_ACCESS_TOKEN,
        projectId: process.env.VERCEL_PROJECT_ID,
        vercelTeamId: process.env.VERCEL_TEAM_ID,
      }),
    ],
  },
});
```

## Key Behavior

When deploying from a Vercel build environment, environment variable values are sourced from `process.env` instead of fetching them via the Vercel API. The system still uses the API to identify configured variables, but retrieves actual values locally.

## Deployment

Execute the deployment command to initiate the sync:

```bash
npx trigger.dev@latest deploy
```

Upon completion, synced variables appear in your Trigger.dev dashboard.

## Related Resources

- Next.js setup guide
- Next.js webhook triggering guide
- Build extensions overview
- Fal.ai integration examples
- Vercel AI SDK guide
