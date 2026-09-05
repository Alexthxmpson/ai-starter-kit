---
source: https://trigger.dev/docs/cli-whoami-commands
scraped: 2026-02-28
---

# CLI whoami Command

The `whoami` command displays details about the currently authenticated user and associated project.

## Usage

Execute the command using one of these package managers:

```bash
npx trigger.dev@latest whoami
```

```bash
pnpm dlx trigger.dev@latest whoami
```

```bash
yarn dlx trigger.dev@latest whoami
```

## Available Options

### Common Command Options

- **Login profile** (`--profile`): Specifies which login profile to use, with "default" as the fallback option.

- **API URL** (`--api-url | -a`): Overrides the standard API endpoint. Defaults to `https://api.trigger.dev` when not specified. Can alternatively be configured via the `TRIGGER_API_URL` environment variable.

- **Log level** (`--log-level | -l`): Sets CLI output verbosity. Accepted values include `debug`, `info`, `log`, `warn`, `error`, and `none`. Defaults to `log`. Note this only affects CLI output, not task logging.

- **Skip telemetry** (`--skip-telemetry`): Disables analytics collection. Can also be configured through the `TRIGGER_TELEMETRY_DISABLED` environment variable.

- **Help** (`--help | -h`): Displays usage information for this command.

- **Version** (`--version | -v`): Shows the installed CLI version number.
