---
source: https://trigger.dev/docs/deployment/overview
scraped: 2026-02-28
---

# Deployment

## Overview

Trigger.dev requires deploying tasks to production via CLI before running production workloads. The deployment process builds tasks and uploads them to Trigger.dev cloud or a self-hosted instance.

## Deployment Process

### Initial Setup

Log in to the CLI first:

```bash
npx trigger.dev login
```

This opens a browser for authentication and links your CLI to your account.

### Deploying Tasks

Execute the deploy command:

```bash
npx trigger.dev deploy
```

The system builds your code and creates a new version. A successful deployment displays output indicating the version number and detected task count.

### Using Production API Keys

After deployment, trigger tasks using the production API key from the dashboard:

```
TRIGGER_SECRET_KEY="tr_prod_abc123"
```

Then invoke tasks as before:

```typescript
import { myTask } from "./trigger/tasks";

await myTask.trigger({ foo: "bar" });
```

## Version Management

### Current Version

Each deployment automatically increments the version number and sets it as the current version. One "current" version exists per environment at any time. New task runs execute against the current version, ensuring consistency across retries.

### Version Locking

Specify a particular version when triggering:

```typescript
await myTask.trigger({ foo: "bar" }, { version: "20250228.1" });
```

Or globally via environment variable:

```bash
TRIGGER_VERSION=20250228.1
```

### Child Task Auto-Locking

Functions like `triggerAndWait()` and `batchTriggerAndWait()` automatically lock child tasks to the parent's version. Non-waiting trigger functions don't apply version locking.

### Skipping Automatic Promotion

Deploy without promoting to current version:

```bash
npx trigger.dev deploy --skip-promotion
```

Then promote manually via CLI or dashboard:

```bash
npx trigger.dev promote 20250228.1
```

## Multiple Environments

### Staging Deployment

Deploy to staging environment (requires Hobby+ plan on Cloud):

```bash
npx trigger.dev deploy --env staging
```

This creates an independent version set with its own staging API key:

```
TRIGGER_SECRET_KEY="tr_stg_abcd123"
```

For additional custom environments, use preview branches.

## Build Options

### Local Builds

Force local builds on your machine:

```bash
npx trigger.dev deploy --force-local-build
```

Requires Docker and Docker Buildx installed.

## Environment Variables

Add custom environment variables in the dashboard, or auto-sync using configuration extensions like `syncEnvVars` or `syncVercelEnvVars`.

## Troubleshooting

### Dry Run

Preview deployment without uploading:

```bash
npx trigger.dev deploy --dry-run
```

### Debug Logs

Enable verbose output:

```bash
npx trigger.dev deploy --log-level debug
```

### Common Issues

**Build Failures:** Check build logs provided in error messages. Try local builds with `--force-local-build` if remote provider has issues.

**Node Files Error:** Add packages to `build.external` in `trigger.config.ts`:

```typescript
export default defineConfig({
  project: "<project ref>",
  build: {
    external: ["your-node-package"],
  },
});
```

**Corepack Compatibility:** Either downgrade to Node.js v20 LTS or install latest corepack globally.
