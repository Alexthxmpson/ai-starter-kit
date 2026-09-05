---
source: https://trigger.dev/docs/cli-deploy-commands
scraped: 2026-02-28
---

# CLI Deploy Command

The `trigger.dev` deploy command is used to deploy tasks to Trigger.dev. It can be invoked using npm, pnpm, or yarn:

```bash
npx trigger.dev@latest deploy
```

## Deployment Process

The command executes several steps:

1. Optionally updates packages when running locally
2. Compiles and bundles the code
3. Deploys the code to the Trigger.dev instance
4. Registers tasks as a new version in the environment (production by default)

**Important:** Version mismatches will cause CI deployments to fail. Test locally first using the dev command before deploying.

## CI/CD Authentication

For non-interactive deployments in CI environments like GitHub Actions or Jenkins, set the `TRIGGER_ACCESS_TOKEN` environment variable. Refer to the CI/GitHub Actions guide for detailed instructions.

## Command Syntax

```
npx trigger.dev@latest deploy [path]
```

**Arguments:**
- `[path]` — Project directory (defaults to current directory)

## Key Options

| Option | Purpose |
|--------|---------|
| `--config, -c` | Specify config file name (default: `trigger.config.ts`) |
| `--project-ref, -p` | Project reference (required without config file) |
| `--env, -e` | Target environment: `prod`, `staging`, or `preview` |
| `--branch, -b` | Manually specify preview branch name |
| `--dry-run` | Build without deploying; prints build path |
| `--skip-promotion` | Skip auto-promoting to current deploy |
| `--skip-sync-env-vars` | Disable environment variable syncing |
| `--local-build` | Force local Docker build |

## Additional Common Options

- `--profile` — Login profile selection
- `--api-url, -a` — Override default API URL
- `--log-level, -l` — Set CLI verbosity
- `--skip-telemetry` — Opt out of telemetry

## Self-Hosting

Self-hosted instances perform builds locally by default. After CLI authentication, deploy with the standard command. For CI environments, configure `TRIGGER_ACCESS_TOKEN` and `TRIGGER_API_URL` environment variables.
