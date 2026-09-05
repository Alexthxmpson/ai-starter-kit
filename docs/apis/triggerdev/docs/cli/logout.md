---
source: https://trigger.dev/docs/cli-logout-commands
scraped: 2026-02-28
---

# CLI logout command

> Use these options when using the `logout` CLI command.

Run the command like this:

```bash
npx trigger.dev@latest logout
```

```bash
pnpm dlx trigger.dev@latest logout
```

```bash
yarn dlx trigger.dev@latest logout
```

## Options

### Common options

These options are available on most commands.

| Option | Description |
|--------|-------------|
| `--profile` | The login profile to use. Defaults to "default". |
| `--api-url, -a` | Override the default API URL. If not specified, it uses `https://api.trigger.dev`. This can also be set via the `TRIGGER_API_URL` environment variable. |
| `--log-level, -l` | The CLI log level to use. Options are `debug`, `info`, `log`, `warn`, `error`, and `none`. This does not affect the log level of your trigger.dev tasks. Defaults to `log`. |
| `--skip-telemetry` | Opt-out of sending telemetry data. This can also be done via the `TRIGGER_TELEMETRY_DISABLED` environment variable. Just set it to anything other than an empty string. |
| `--help, -h` | Shows the help information for the command. |
| `--version, -v` | Displays the version number of the CLI. |
