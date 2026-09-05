---
source: https://trigger.dev/docs/cli-update-commands
scraped: 2026-02-28
---

# CLI update command

> Use these options when using the `update` CLI command.

Run the command like this:

```bash
npx trigger.dev@latest update
```

```bash
pnpm dlx trigger.dev@latest update
```

```bash
yarn dlx trigger.dev@latest update
```

## Options

### Common options

These options are available on most commands.

**Log level** (`--log-level | -l`)
The CLI log level to use. Options are `debug`, `info`, `log`, `warn`, `error`, and `none`. This does not affect the log level of your trigger.dev tasks. Defaults to `log`.

**Skip telemetry** (`--skip-telemetry`)
Opt-out of sending telemetry data. This can also be done via the `TRIGGER_TELEMETRY_DISABLED` environment variable. Just set it to anything other than an empty string.

**Help** (`--help | -h`)
Shows the help information for the command.

**Version** (`--version | -v`)
Displays the version number of the CLI.
