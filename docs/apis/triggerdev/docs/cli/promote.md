---
source: https://trigger.dev/docs/cli-promote-commands
scraped: 2026-02-28
---

# CLI Promote Command

## Overview

The `promote` command enables you to elevate a previously deployed version to become the current active version.

## Usage

Execute the command using one of these package managers:

```bash
npx trigger.dev@latest promote [version]
```

```bash
pnpm dlx trigger.dev@latest promote [version]
```

```bash
yarn dlx trigger.dev@latest promote [version]
```

## Parameters

**Deployment version** `[version]`
The specific version identifier you wish to promote from a prior deployment.

## Common Options

**Login profile** `--profile`
Specifies which login profile to use; defaults to "default".

**API URL** `--api-url | -a`
Overrides the standard API endpoint (`https://api.trigger.dev`). Can alternatively be set through the `TRIGGER_API_URL` environment variable.

**Log level** `--log-level | -l`
Adjusts CLI output verbosity. Accepted values: `debug`, `info`, `log`, `warn`, `error`, `none`. Defaults to `log`. Note: this setting does not control your trigger.dev task logging.

**Skip telemetry** `--skip-telemetry`
Disables analytics reporting. Can also be configured via the `TRIGGER_TELEMETRY_DISABLED` environment variable by setting it to any non-empty value.

**Help** `--help | -h`
Displays command documentation.

**Version** `--version | -v`
Shows the installed CLI version number.
