---
source: https://trigger.dev/docs/upgrading-packages
scraped: 2026-02-28
---

# How to Upgrade Trigger.dev Packages

## Overview

When Trigger.dev releases updates, upgrading your packages ensures you have access to the latest fixes and features.

## Quick Update

Run this command in your project directory:

```sh
npx trigger.dev@latest update
```

This command updates all Trigger.dev packages to their latest versions.

## Using the Latest CLI Locally

For development and deployment workflows, always use the latest CLI version:

```sh
npx trigger.dev@latest dev
```

```sh
npx trigger.dev@latest deploy
```

Both commands will prompt you to upgrade if your version is outdated.

## GitHub Actions Deployment

When deploying via GitHub Actions, you should lock your version in the workflow file to prevent mismatches. The deployment will fail if version inconsistencies are detected.

**Steps:**
1. Locate your workflow files in `.github/workflows/`
2. Update the `run` command to use the latest version (e.g., `npx trigger.dev@3.0.0 deploy`)

## Alternative: Add as Dev Dependency

You can add the CLI to your `package.json` as a dev dependency:

```json
{
  "devDependencies": {
    "trigger.dev": "3.0.0"
  }
}
```

Ensure this version matches your `@trigger.dev/sdk` package version.

Then run commands using:
- `npm exec trigger.dev`
- `pnpm exec trigger.dev`
- `yarn exec trigger.dev`

**Recommended approach:** Add shortcuts to your `package.json` scripts:

```json
{
  "scripts": {
    "dev:trigger": "trigger dev",
    "deploy:trigger": "trigger deploy"
  }
}
```

Then execute `npm run dev:trigger` or `npm run deploy:trigger`.
