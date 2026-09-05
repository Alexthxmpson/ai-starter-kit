---
source: https://trigger.dev/docs/mcp-agent-rules
scraped: 2026-02-28
---

# Agent Rules

## Overview

Trigger.dev agent rules are instruction sets that guide AI assistants toward optimal code patterns. They ensure assistants understand best practices, current APIs, and recommended patterns when working with Trigger.dev projects.

## Installation

Install via command line:

```bash
npx trigger.dev@latest install-rules
```

## Five Specialized Rule Sets

| Rule Set | Tokens | Purpose |
|----------|--------|---------|
| Basic tasks | 1,200 | Essential patterns for fundamental Trigger.dev tasks |
| Advanced tasks | 3,000 | Complex workflows, error handling, advanced patterns |
| Scheduled tasks | 780 | Cron jobs, scheduled workflows, time-based triggers |
| Configuration | 1,900 | trigger.config.ts setup and project structure |
| Realtime | 1,700 | Frontend integration and realtime features |

## Claude Code Subagent

A specialized subagent called `trigger-dev-expert` provides expert-level Trigger.dev code generation. Activate it by explicitly requesting it in prompts:

```markdown
use the trigger-dev-expert subagent to create a trigger.dev job that...
```

## Automatic Updates

The CLI includes automatic update detection. When running `npx trigger.dev@latest dev`, notifications appear for available rule updates. Manual updates are available anytime with the install command.

## Supported AI Clients

Rules work across:
- Cursor
- Claude Code
- VSCode Copilot
- Windsurf
- Gemini CLI
- Cline
- Sourcegraph AMP
- Kilo
- Ruler
- AGENTS.md-compatible tools

Most activate automatically in Trigger.dev projects.
