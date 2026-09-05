---
source: https://trigger.dev/docs/cli-preview-archive
scraped: 2026-02-28
---

# CLI Preview Archive Command

The `trigger.dev preview archive` command allows you to archive a preview branch.

## Usage

Run the command using one of these package managers:

```bash
npx trigger.dev@latest preview archive
```

```bash
pnpm dlx trigger.dev@latest preview archive
```

```bash
yarn dlx trigger.dev@latest preview archive
```

The command automatically detects your branch name from git, though you can manually specify it with the `--branch` option.

## Command Syntax

```
npx trigger.dev@latest preview archive [path]
```

## Arguments

**Project path** `[path]`
- The directory containing your project. Uses current directory by default.

## Options

**Preview branch** `--branch | -b`
- Manually specify the branch name (e.g., `--branch my-branch` or `-b my-branch`). Normally detected automatically from git.

**Config file** `--config | -c`
- Name of the config file in your project path. Defaults to `trigger.config.ts`

**Project ref** `--project-ref | -p`
- The project reference. Required if no config file exists.

**Env file** `--env-file`
- Load environment variables from a file. Hydrates the CLI process only, not tasks.

**Skip update check** `--skip-update-check`
- Skip checking for package updates.

## Common Options

**Login profile** `--profile`
- Which login profile to use. Defaults to "default".

**API URL** `--api-url | -a`
- Override the default API endpoint (`https://api.trigger.dev`). Can also use `TRIGGER_API_URL` environment variable.

**Log level** `--log-level | -l`
- CLI verbosity level: `debug`, `info`, `log`, `warn`, `error`, or `none`. Defaults to `log`.

**Skip telemetry** `--skip-telemetry`
- Disable telemetry. Can also use `TRIGGER_TELEMETRY_DISABLED` environment variable.

**Help** `--help | -h`
- Display help information.

**Version** `--version | -v`
- Show CLI version number.
