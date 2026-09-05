---
source: https://trigger.dev/docs/cli-switch
scraped: 2026-02-28
---

# CLI switch command

The `trigger.dev switch` command allows you to change between different profiles.

## Usage

Run the command using one of these package managers:

```bash
npx trigger.dev@latest switch [profile]
```

```bash
pnpm dlx trigger.dev@latest switch [profile]
```

```bash
yarn dlx trigger.dev@latest switch [profile]
```

## Behavior

When executed, the command switches to your specified profile. If you don't provide a profile name, the tool "will list all available profiles and run interactively."

## Arguments

**Profile** `[profile]`

The target profile you want to switch to. This argument is optional — leaving it blank triggers an interactive mode showing all available profiles.
