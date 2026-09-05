---
source: https://trigger.dev/docs/cli-init-commands
scraped: 2026-02-28
---

# CLI init command

> Use these options when running the CLI `init` command.

Run the command like this:

```bash
npx trigger.dev@latest init
```

```bash
pnpm dlx trigger.dev@latest init
```

```bash
yarn dlx trigger.dev@latest init
```

## Options

| Option | Type | Description |
|--------|------|-------------|
| Javascript | `--javascript` | By default, the init command assumes you are using TypeScript. Use this flag to initialize a project that uses JavaScript. |
| Project ref | `--project-ref`, `-p` | The project ref to use when initializing the project. |
| Package tag | `--tag`, `-t` | The version of the `@trigger.dev/sdk` package to install. Defaults to `latest`. |
| Skip package install | `--skip-package-install` | Skip installing the `@trigger.dev/sdk` package. |
| Override config | `--override-config` | Override the existing config file if it exists. |
| Package arguments | `--pkg-args` | Additional arguments to pass to the package manager. Accepts CSV for multiple args. |

### Common options

These options are available on most commands.

| Option | Type | Description |
|--------|------|-------------|
| Login profile | `--profile` | The login profile to use. Defaults to "default". |
| API URL | `--api-url`, `-a` | Override the default API URL. If not specified, it uses `https://api.trigger.dev`. This can also be set via the `TRIGGER_API_URL` environment variable. |
| Log level | `--log-level`, `-l` | The CLI log level to use. Options are `debug`, `info`, `log`, `warn`, `error`, and `none`. This does not affect the log level of your trigger.dev tasks. Defaults to `log`. |
| Skip telemetry | `--skip-telemetry` | Opt-out of sending telemetry data. This can also be done via the `TRIGGER_TELEMETRY_DISABLED` environment variable. Just set it to anything other than an empty string. |
| Help | `--help`, `-h` | Shows the help information for the command. |
| Version | `--version`, `-v` | Displays the version number of the CLI. |
