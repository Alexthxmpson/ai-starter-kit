---
source: https://trigger.dev/docs/cli-login-commands
scraped: 2026-02-28
---

# CLI Login Command Documentation

## Overview

The `trigger.dev login` command authenticates users with Trigger.dev through the CLI.

## Command Syntax

```bash
npx trigger.dev@latest login
```

Alternative package managers:

```bash
pnpm dlx trigger.dev@latest login
```

```bash
yarn dlx trigger.dev@latest login
```

## Available Options

| Option | Type | Description |
|--------|------|-------------|
| `--profile` | Login profile | Specifies which profile to use (defaults to "default") |
| `--api-url`, `-a` | API URL | Overrides the default API endpoint; uses `https://api.trigger.dev` if unspecified. Can be set via `TRIGGER_API_URL` environment variable |
| `--log-level`, `-l` | Log level | Sets CLI verbosity: `debug`, `info`, `log`, `warn`, `error`, or `none` (defaults to `log`) |
| `--skip-telemetry` | Telemetry | Disables telemetry transmission. Alternative: set `TRIGGER_TELEMETRY_DISABLED` environment variable |
| `--help`, `-h` | Help | Displays command help information |
| `--version`, `-v` | Version | Shows the CLI version number |

**Note:** These options are commonly available across most Trigger.dev CLI commands.
