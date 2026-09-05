---
source: https://trigger.dev/docs/guides/example-projects/claude-changelog-generator
scraped: 2026-02-28
---

# Changelog Generator Using Claude Agent SDK

## Overview

This demonstration illustrates building an intelligent agent using the Claude Agent SDK that examines GitHub commits, investigates ambiguous changes through on-demand diff retrieval, and produces developer-friendly changelogs.

## Technology Stack

- **Next.js** - Frontend framework with App Router
- **Claude Agent SDK** - Anthropic's framework for constructing AI agents with personalized tools
- **Trigger.dev** - Workflow management featuring real-time streaming, observability, and hosting
- **Octokit** - GitHub API client for retrieving commits and diffs

## Workflow Process

The agent follows these steps:

1. **Accept input** - User submits a GitHub repository URL and timeframe
2. **Retrieve commits** - Agent uses `list_commits` tool to gather all commits
3. **Evaluate commits** - Agent categorizes each commit:
   - Exclude minor commits (typos, formatting)
   - Incorporate transparent features/improvements immediately
   - Examine uncertain commits by fetching their diffs
4. **Produce changelog** - Agent creates organized markdown documentation
5. **Transmit output** - Changelog flows to the frontend instantaneously

## Key Capabilities

- **Dual-stage assessment** - Fetches all commits initially, then retrieves diffs selectively for questionable items
- **Personalized tools** - `list_commits` and `get_commit_diff` executed autonomously by Claude
- **Instantaneous streaming** - Changelog transmits to the frontend during creation via Trigger.dev Realtime
- **Active monitoring** - Agent status, iteration count, and tool operations shared via run metadata
- **Secure repository support** - Optional GitHub authentication for restricted repositories

## Important Files

| File | Purpose |
| --- | --- |
| `trigger/generate-changelog.ts` | Core task implementation with personalized tools |
| `trigger/changelog-stream.ts` | Stream specification for instantaneous output |
| `app/api/generate-changelog/route.ts` | API handler initiating the task |
| `app/response/[runId]/page.tsx` | Streaming presentation interface |

## Configuration Setup

Mark the Claude Agent SDK as external in `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: process.env.TRIGGER_PROJECT_REF!,
  runtime: "node",
  logLevel: "log",
  maxDuration: 300,
  build: {
    external: ["@anthropic-ai/claude-agent-sdk"],
  },
  machine: "small-2x",
});
```

**Note:** Designating packages as `external` prevents bundling, which is mandatory for the Claude Agent SDK.

## Additional Resources

- Building agents with Claude Agent SDK - Complete guidance for integrating Claude Agent SDK with Trigger.dev
- Realtime - Stream task advancement to your interface
- Scheduled tasks - Automate changelog creation on recurring schedules

## GitHub Repository

[View the complete open-source code](https://github.com/triggerdotdev/examples/tree/main/changelog-generator)
