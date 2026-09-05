---
source: https://trigger.dev/docs/guides/examples/sentry-error-tracking
scraped: 2026-02-28
---

# Track Errors with Sentry

## Overview

This integration allows you to automatically send errors and source maps from Trigger.dev tasks to your Sentry project. Source maps enable Sentry to map minified code back to original source, providing more detailed stack traces.

## Requirements

- Active Sentry account and project
- Active Trigger.dev account and project
- `SENTRY_AUTH_TOKEN` and `SENTRY_DSN` environment variables configured

## Implementation Steps

### 1. Build Configuration

Update your `trigger.config.ts` to upload source maps during deployment using the Sentry esbuild plugin:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { esbuildPlugin } from "@trigger.dev/build/extensions";
import { sentryEsbuildPlugin } from "@sentry/esbuild-plugin";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      esbuildPlugin(
        sentryEsbuildPlugin({
          org: "<your-sentry-org>",
          project: "<your-sentry-project>",
          authToken: process.env.SENTRY_AUTH_TOKEN,
        }),
        { placement: "last", target: "deploy" }
      ),
    ],
  },
});
```

### 2. Runtime Setup

Create `trigger/init.ts` to initialize Sentry and register a global failure hook:

```ts
import { tasks } from "@trigger.dev/sdk";
import * as Sentry from "@sentry/node";

Sentry.init({
  defaultIntegrations: false,
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV === "production" ? "production" : "development",
});

tasks.onFailure(({ payload, error, ctx }) => {
  Sentry.captureException(error, {
    extra: {
      payload,
      ctx,
    },
  });
});
```

### 3. Test Task

Create a sample failing task to verify integration:

```ts
import { task } from "@trigger.dev/sdk";

export const sentryErrorTest = task({
  id: "sentry-error-test",
  retry: {
    maxAttempts: 1,
  },
  run: async () => {
    const error = new Error("This is a custom error that Sentry will capture");
    error.cause = { additionalContext: "This is additional context" };
    throw error;
  },
});
```

### 4. Deploy and Test

Deploy your project using your package manager, then run the test task from your Trigger.dev dashboard. Failed runs should appear in your Sentry project dashboard shortly after execution.
