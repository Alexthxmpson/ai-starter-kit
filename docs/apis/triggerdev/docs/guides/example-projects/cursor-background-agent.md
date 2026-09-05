---
source: https://trigger.dev/docs/guides/example-projects/cursor-background-agent
scraped: 2026-02-28
---

# Background Cursor Agent Using the Cursor CLI

## Overview

This example demonstrates running Cursor's headless CLI in a Trigger.dev task with real-time output streaming to the frontend using Realtime Streams.

**Technology Stack:**
- Next.js (App Router with server actions)
- Cursor CLI (headless AI coding agent)
- Trigger.dev (task orchestration, real-time streaming, deployment)

## Key Features

The implementation showcases several capabilities:

- **System binary deployment**: Uses `addLayer` to install the `cursor-agent` binary into the task container
- **Realtime Streams v2**: NDJSON output from a child process is parsed and piped directly to browsers
- **Live terminal rendering**: Each Cursor event displays as a distinct row with automatic scrolling
- **Long-running task support**: Trigger.dev manages lifecycle, timeouts, and retries for extended operations
- **Resource selection**: Uses `medium-2x` preset for computationally intensive CLI tools
- **Model flexibility**: Users can select between different models before triggering execution

## How It Works

### Task Orchestration Flow

1. A Next.js server action triggers the `cursor-agent` task with user prompt and model selection
2. The task spawns the Cursor CLI as a child process, returning a typed NDJSON stream
3. NDJSON lines are parsed into typed Cursor events and piped to a Realtime Stream
4. Frontend subscribes via `useRealtimeRunWithStreams` hook, rendering events in a terminal UI
5. Task waits for CLI process exit and returns results

### Build Extension Implementation

A custom build extension installs `cursor-agent` using Docker instructions:

```ts
const CURSOR_AGENT_DIR = "/usr/local/lib/cursor-agent";

export const cursorCli = (): BuildExtension => ({
  name: "cursor-cli",
  onBuildComplete(context) {
    if (context.target === "dev") return;

    context.addLayer({
      id: "cursor-cli",
      image: {
        instructions: [
          "RUN apt-get update && apt-get install -y curl ca-certificates && rm -rf /var/lib/apt/lists/*",
          'ENV PATH="/root/.local/bin:$PATH"',
          "RUN curl -fsSL https://cursor.com/install | bash",
          `RUN cp -r $(dirname $(readlink -f /root/.local/bin/cursor-agent)) ${CURSOR_AGENT_DIR}`,
        ],
      },
    });
  },
});
```

### Streaming Implementation

Stream definition with typed schema:

```ts
export const cursorStream = streams.define("cursor", cursorEventSchema);
```

Piping child process output:

```ts
const { stream, waitUntilExit } = spawnCursorAgent({ prompt, model });
cursorStream.pipe(stream);
await waitUntilExit();
```

## Relevant Code Files

- **extensions/cursor-cli.ts**: Binary installation and NDJSON stream helper with exit promise
- **trigger/cursor-agent.ts**: CLI spawning, stream piping, exit handling
- **trigger/cursor-stream.ts**: Realtime Streams v2 definition with typed schema
- **components/terminal.tsx**: Live event rendering using `useRealtimeRunWithStreams`
- **lib/cursor-events.ts**: TypeScript types and parsers for Cursor NDJSON events
- **trigger.config.ts**: Project configuration with build extension

## Additional Resources

- [Trigger.dev Realtime documentation](/realtime)
- [Realtime streaming guide](/realtime/react-hooks/streams)
- [Batch triggering documentation](/triggering#tasks-batchtrigger)
- [React hooks reference](/realtime/react-hooks)

## GitHub Repository

[View the Cursor background agent example](https://github.com/triggerdotdev/examples/tree/main/cursor-cli-demo)
