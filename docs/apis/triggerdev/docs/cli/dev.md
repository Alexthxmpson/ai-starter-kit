---
source: https://trigger.dev/docs/cli-dev
scraped: 2026-02-28
---

# CLI dev Command Documentation

## Overview

The `trigger.dev dev` command runs a local server for executing Trigger.dev tasks on your machine. Each task operates in a separate Node process, enabling concurrent execution without blocking.

## Installation

Choose your package manager:

```bash
npx trigger.dev@latest dev
```

```bash
pnpm dlx trigger.dev@latest dev
```

```bash
yarn dlx trigger.dev@latest dev
```

The CLI performs an automatic version check before starting, requiring user confirmation.

## Configuration Options

| Option | Flag | Purpose |
|--------|------|---------|
| Config file | `--config, -c` | Specify config filename (defaults to `trigger.config.ts`) |
| Project ref | `--project-ref, -p` | Required if no config file exists |
| Env file | `--env-file` | Load environment variables for CLI process |
| Skip update check | `--skip-update-check` | Bypass version checking |
| Analyze build output | `--analyze` | Display import timing diagnostics |

## Common Options

- `--profile`: Select login profile (default: "default")
- `--api-url, -a`: Override API endpoint (`https://api.trigger.dev` by default)
- `--log-level, -l`: Set CLI verbosity (debug, info, log, warn, error, none)
- `--skip-telemetry`: Disable telemetry reporting
- `--help, -h`: Display command help
- `--version, -v`: Show CLI version

## Running Concurrently

Use the `concurrently` package to run your framework and Trigger.dev simultaneously:

```json
{
  "scripts": {
    "dev": "concurrently --raw --kill-others npm:dev:*",
    "dev:trigger": "npx trigger.dev@latest dev",
    "dev:next": "next dev"
  }
}
```
