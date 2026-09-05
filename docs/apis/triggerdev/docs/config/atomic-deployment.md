---
source: https://trigger.dev/docs/deployment/atomic-deployment
scraped: 2026-02-28
---

# Atomic Deploys

## Overview

Atomic deploys in Trigger.dev synchronize application deployments with specific task versions. This approach ensures "your application always uses the correct version of its associated tasks, preventing inconsistencies or errors due to version mismatches."

## Core Process

The deployment workflow involves three main steps:

1. Deploy tasks using the `--skip-promotion` flag to create a new version without setting it as default
2. Capture the deployment version output from the CLI
3. Deploy your application with an environment variable (like `TRIGGER_VERSION`) set to this version

## Implementation Strategies

### Vercel CLI with GitHub Actions

For teams using Vercel's CLI, the workflow deploys to Trigger.dev first with `--skip-promotion`, captures the version number, then deploys the application to Vercel with that version as an environment variable. A final step promotes the Trigger.dev version after application deployment succeeds.

**Required secrets:**
- `TRIGGER_ACCESS_TOKEN`
- `VERCEL_TOKEN`

### Vercel GitHub Integration

For projects using Vercel's GitHub integration, disable automatic production promotion in Vercel settings first. Then use a GitHub Actions workflow that:

1. Waits for the Vercel deployment to complete
2. Deploys tasks to Trigger.dev (with automatic promotion)
3. Promotes the Vercel deployment once Trigger.dev deployment finishes

**Required secrets:**
- `TRIGGER_ACCESS_TOKEN`
- `VERCEL_TOKEN`
- `VERCEL_PROJECT_ID`
- `VERCEL_SCOPE_NAME`

The documentation includes a complete example repository demonstrating this workflow in production use.
