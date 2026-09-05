---
source: https://trigger.dev/docs/deployment/preview-branches
scraped: 2026-02-28
---

# Preview Branches Documentation

## Overview

Preview branches create isolated environments for testing code changes before merging to production. They're created from a special preview environment and support all standard features including triggered runs, schedules, and Realtime functionality.

## Core Workflow

The typical process involves four steps:

1. Create a preview branch
2. Deploy to it (one or more times)
3. Trigger runs using preview API credentials and branch name
4. Archive when finished

## Deployment Methods

### GitHub Actions (Recommended)

The recommended approach uses automated GitHub Actions that:

- Automatically create preview branches when pull requests open
- Deploy code changes
- Archive branches when PRs close or merge

This requires setting `TRIGGER_ACCESS_TOKEN` as a repository secret (tokens begin with `tr_pat_`).

### Manual CLI Deployment

Deploy manually using:

```bash
npx trigger.dev@latest deploy --env preview
```

Specify a branch explicitly if auto-detection fails:

```bash
npx trigger.dev@latest deploy --env preview --branch your-branch-name
```

### Dashboard Management

Preview branches can also be created and archived directly through the dashboard's dedicated "Preview branches" page.

## Configuration Requirements

When deploying, set two environment variables:

- `TRIGGER_SECRET_KEY`: Your preview API credentials
- `TRIGGER_PREVIEW_BRANCH`: The branch identifier

For edge runtimes without `process.env` support, manually configure the SDK using the `configure()` function with `secretKey` and `previewBranch` parameters.

## Active Branch Limits

| Plan | Maximum Active Branches |
|------|------------------------|
| Free | 0 |
| Hobby | 5 |
| Pro | 20 (additional paid) |

Archiving branches frees up slots for new ones.

## Environment Variables

Variables can be set at the preview environment level (applying to all branches) or for specific branches. Branch-specific settings override general preview settings. Synchronization extensions like `syncEnvVars()` and `syncVercelEnvVars()` automate variable management during deployment.
