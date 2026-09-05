# Trigger.dev API Documentation

> Scraped: 2026-02-28 | Coverage: 234/235 pages (99.6%)
> Source: https://trigger.dev/docs

## What is Trigger.dev?

Trigger.dev is a background jobs and workflow platform for TypeScript/Node.js. It lets you write long-running tasks as regular code with built-in retries, concurrency control, real-time monitoring, and human-in-the-loop workflows.

## Directory Structure

```
trigger.dev/
├── getting-started/     # Quick start, how-it-works, migration guides
├── tasks/               # Task types: basic, scheduled, schema, streams
├── features/            # Triggering, runs, waits, errors, queues, logging
├── config/              # Config file, build extensions, deployment
├── cli/                 # All CLI commands reference
├── realtime/            # Realtime API + React hooks
├── management/          # REST Management API (runs, batches, schedules, queues, envvars, deployments)
│   ├── runs/
│   ├── batches/
│   ├── tasks/
│   ├── schedules/
│   ├── queues/
│   ├── envvars/
│   ├── deployments/
│   ├── waitpoints/
│   └── query/
├── observability/       # Dashboards, TRQL query language
├── self-hosting/        # Docker, Kubernetes, env vars
├── mcp/                 # MCP server tools and agent rules
├── guides/              # Integration guides by category
│   ├── ai-agents/
│   ├── frameworks/      # Next.js, Remix, Bun, Supabase, etc.
│   ├── examples/        # Code examples (OpenAI, Stripe, FFmpeg, etc.)
│   ├── example-projects/
│   ├── python/
│   ├── use-cases/
│   └── community/
└── misc/                # API keys, versioning, troubleshooting, integrations
```

## Key Files to Read First

- `getting-started/introduction.md` — What Trigger.dev is
- `getting-started/quick-start.md` — Run your first task in 3 minutes
- `tasks/overview.md` — How tasks work
- `features/triggering.md` — How to trigger tasks from your app
- `management/overview.md` — REST API for managing runs programmatically

## Authentication

- **Secret Key**: `TRIGGER_SECRET_KEY` env var (from dashboard → API Keys)
- **Base URL**: `https://api.trigger.dev`
- **SDK**: `@trigger.dev/sdk` (TypeScript/Node.js)

## Tracking

- `SOURCES.md` — Full URL inventory
- `COVERAGE.md` — Coverage metrics
