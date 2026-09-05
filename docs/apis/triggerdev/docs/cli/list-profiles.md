---
source: https://trigger.dev/docs/cli-list-profiles-commands
scraped: 2026-02-28
---

# CLI list-profiles Command

## Overview

The `list-profiles` command displays available profiles in your trigger.dev configuration.

## Running the Command

Execute the command using your preferred package manager:

```bash
npx trigger.dev@latest list-profiles
```

```bash
pnpm dlx trigger.dev@latest list-profiles
```

```bash
yarn dlx trigger.dev@latest list-profiles
```

## Available Options

### Common Options

**Log Level** (`--log-level | -l`)
Sets the CLI logging verbosity. Choose from: `debug`, `info`, `log`, `warn`, `error`, or `none`. Defaults to `log`. This setting does not impact task-level logging.

**Skip Telemetry** (`--skip-telemetry`)
Disables anonymous usage data collection. You can also set the `TRIGGER_TELEMETRY_DISABLED` environment variable to any non-empty value to achieve the same result.

**Help** (`--help | -h`)
Displays command documentation and usage information.

**Version** (`--version | -v`)
Shows your currently installed CLI version number.
