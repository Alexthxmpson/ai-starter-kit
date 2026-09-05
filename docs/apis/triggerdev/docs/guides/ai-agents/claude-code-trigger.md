---
source: https://trigger.dev/docs/guides/ai-agents/claude-code-trigger
scraped: 2026-02-28
---

# Claude Agent SDK Setup Guide

## Overview

The Claude Agent SDK enables development of AI agents capable of reading files, executing commands, and modifying code. When integrated with Trigger.dev, these agents gain durable execution, automatic retries, and full observability features.

## Installation Steps

### 1. Install the SDK

```bash
npm install @anthropic-ai/claude-agent-sdk
```

### 2. Update trigger.config.ts

Add the package to the `external` array to prevent bundling:

```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: process.env.TRIGGER_PROJECT_REF!,
  build: {
    external: ["@anthropic-ai/claude-agent-sdk"],
  },
  machine: "small-2x",
});
```

### 3. Configure API Key

Set your Anthropic credentials via environment variables:

```bash
ANTHROPIC_API_KEY=sk-ant-...
```

Configure this in the Trigger.dev dashboard or local `.env` file.

### 4. Create an Agent Task

Here's a practical example implementing a code generation task:

```ts
import { query } from "@anthropic-ai/claude-agent-sdk";
import { schemaTask, logger } from "@trigger.dev/sdk";
import { mkdtemp, rm, readdir } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { z } from "zod";

export const codeGenerator = schemaTask({
  id: "code-generator",
  schema: z.object({
    prompt: z.string(),
  }),
  run: async ({ prompt }, { signal }) => {
    const abortController = new AbortController();
    signal.addEventListener("abort", () => abortController.abort());

    const workDir = await mkdtemp(join(tmpdir(), "claude-agent-"));
    logger.info("Created workspace", { workDir });

    try {
      const result = query({
        prompt,
        options: {
          model: "claude-sonnet-4-20250514",
          abortController,
          cwd: workDir,
          maxTurns: 10,
          permissionMode: "acceptEdits",
          allowedTools: ["Read", "Edit", "Write", "Glob"],
        },
      });

      for await (const message of result) {
        logger.info("Agent message", { type: message.type });
      }

      const files = await readdir(workDir, { recursive: true });
      logger.info("Files created", { files });

      return { filesCreated: files };
    } finally {
      await rm(workDir, { recursive: true, force: true });
    }
  },
});
```

### 5. Run and Test

Start the development server:

```bash
npx trigger.dev@latest dev
```

Test via the dashboard with sample input:

```json
{
  "prompt": "Create a Node.js project with a fibonacci.ts file containing a function to calculate fibonacci numbers, and a fibonacci.test.ts file with tests."
}
```

## How It Works

The `query()` function operates an agent loop supporting four primary capabilities:

1. **File exploration** - Access codebases using Read, Grep, and Glob operations
2. **Code modification** - Update existing code or create new files
3. **Command execution** - Run shell commands (when enabled)
4. **Reasoning** - Leverage extended thinking for complex problem-solving

Processing continues until task completion or the `maxTurns` limit is reached.

## Permission Modes

| Mode | Behavior |
|------|----------|
| `"default"` | Requires approval for potentially unsafe operations |
| `"acceptEdits"` | Auto-approves file changes; prompts for bash and network calls |
| `"bypassPermissions"` | Disables safety checks (not recommended) |

## Available Tools

```ts
allowedTools: [
  "Task",      // Planning and task management
  "Glob",      // Pattern-based file discovery
  "Grep",      // Content searching
  "Read",      // File content retrieval
  "Edit",      // File modification
  "Write",     // File creation
  "Bash",      // Shell command execution
  "TodoRead",  // Task list reading
  "TodoWrite", // Task list updates
];
```

## Additional Resources

- Official [Claude Agent SDK documentation](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Trigger.dev Realtime](/realtime/overview) for frontend agent progress streaming
- [Waitpoints](/wait) for human-in-the-loop approval workflows
