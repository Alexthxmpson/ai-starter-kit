---
source: https://trigger.dev/docs/vercel-integration
scraped: 2026-02-28
---

# Vercel Integration for Trigger.dev

## Overview

The Vercel integration automates task deployments whenever you push code to Vercel. It connects your Vercel project to your Trigger.dev project so that every Vercel deployment automatically triggers a Trigger.dev deployment.

## Key Features

**Automatic Deployments**: The integration eliminates manual `trigger.dev deploy` commands by triggering builds automatically with each Vercel deployment.

**Environment Variable Sync**: Variables flow bidirectionally—Trigger.dev pulls settings from Vercel and pushes API keys back to keep your deployment synchronized.

**Atomic Deployments**: When enabled, this feature gates your Vercel deployment until the task build completes, ensuring your app and tasks stay in sync across environments.

## Installation Paths

You can set up the integration through:
1. The Trigger.dev dashboard (Settings → Connect Vercel)
2. The Vercel Marketplace with guided setup

Both approaches require connecting your GitHub repository, as Trigger.dev builds tasks from your source code.

## Configuration

The integration supports three build options per environment:
- Atomic deployments (enabled for production by default)
- Automatic environment variable pulling before builds
- Automatic discovery of new environment variables

## Important Considerations

If your Vercel project uses a custom Root Directory, you may encounter errors. The recommended solution is to keep the root directory empty in Vercel settings and instead configure the Trigger.dev project path in your build options.

Disconnecting the integration stops automatic deployments and syncing but preserves existing data.
