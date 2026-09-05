---
source: https://trigger.dev/docs/cli-dev-commands
scraped: 2026-02-28
---

# CLI dev Command Documentation

## Overview

The `trigger.dev dev` command executes Trigger.dev tasks locally by running a server on your machine.

## Installation & Usage

Run the command using your preferred package manager:

```bash
npx trigger.dev@latest dev
```

```bash
pnpm dlx trigger.dev@latest dev
```

```bash
yarn dlx trigger.dev@latest dev
```

## Key Features

- Performs automatic update checks before running
- Displays server status and task execution in the terminal
- Provides dashboard links for task monitoring
- "Each task runs in a separate Node process" to prevent long-running tasks from blocking others

## Configuration Options

| Option | Flag | Description |
|--------|------|-------------|
| Config file | `--config, -c` | Specifies config file name (defaults to `trigger.config.ts`) |
| Project ref | `--project-ref, -p` | Required if no config file exists |
| Env file | `--env-file` | Loads environment variables for the CLI process |
| Skip update check | `--skip-update-check` | Bypasses package update verification |
| Analyze build output | `--analyze` | Shows detailed import timing information |

## Common Options

- `--profile`: Login profile selection (defaults to "default")
- `--api-url, -a`: Override default API endpoint
- `--log-level, -l`: Set CLI verbosity (`debug`, `info`, `log`, `warn`, `error`, `none`)
- `--skip-telemetry`: Disable telemetry collection
- `--help, -h`: Display command help
- `--version, -v`: Show CLI version

## Concurrent Development Setup

Use the `concurrently` package to run multiple processes together:

```json
{
  "scripts": {
    "dev": "concurrently --raw --kill-others npm:dev:*",
    "dev:trigger": "npx trigger.dev@latest dev",
    "dev:next": "next dev"
  }
}
```
