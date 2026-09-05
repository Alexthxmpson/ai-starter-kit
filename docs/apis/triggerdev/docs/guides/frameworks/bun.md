---
source: https://trigger.dev/docs/guides/frameworks/bun
scraped: 2026-02-28
---

# Bun Guide

This guide demonstrates how to integrate Trigger.dev into an existing Bun project, run a sample task, and monitor its execution.

## Prerequisites

- A Bun project with TypeScript installed
- A Trigger.dev account and project created at https://cloud.trigger.dev

## Supported Version

Deployed tasks run on Bun 1.3.3. For local development, use Bun 1.3.x for compatibility.

## Known Issues

The trigger.dev CLI does not yet support Bun natively; you'll need to run CLI commands using Node.js while Bun executes tasks locally and in production.

Certain OpenTelemetry instrumentation is incompatible with Bun due to lack of Node's `register` hook support.

If Bun is installed via Homebrew, you may encounter spawn errors. Workaround — create a symlink:

```bash
mkdir -p ~/.bun/bin && ln -s $(which bun) ~/.bun/bin/bun
```

## Initial Setup

### Step 1: Run the CLI Init Command

Execute this command at your project root:

```bash
npx trigger.dev@latest init --runtime bun
```

Alternative package managers:

```bash
pnpm dlx trigger.dev@latest init --runtime bun
```

```bash
yarn dlx trigger.dev@latest init --runtime bun
```

This creates:
- A `trigger.config.ts` configuration file
- A `/src/trigger` directory with example tasks
- An example task file (`example.ts` or `example.js`)

Install the "Hello World" example when prompted for testing purposes.

### Step 2: Update example.ts for Bun

Replace the contents of `/src/trigger/example.ts`:

```ts
import { Database } from "bun:sqlite";
import { task } from "@trigger.dev/sdk";

export const bunTask = task({
  id: "bun-task",
  run: async (payload: { query: string }) => {
    const db = new Database(":memory:");
    const query = db.query("select 'Hello world' as message;");
    console.log(query.get()); // => { message: "Hello world" }

    return {
      message: "Query executed",
    };
  },
});
```

### Step 3: Run the Dev Server

```bash
npx trigger.dev@latest dev
```

Alternative commands:

```bash
pnpm dlx trigger.dev@latest dev
```

```bash
yarn dlx trigger.dev@latest dev
```

This server monitors your `/trigger` directory, registers tasks, and communicates with the Trigger.dev platform.

### Step 4: Test via Dashboard

The dev command outputs useful URLs. Navigate to the Test page and:

1. Select the Example task from the list
2. Note that this particular task requires no input payload
3. Configure any additional run options as needed
4. Click "Run test"

### Step 5: Monitor Execution

The run page displays live updates of task execution status. Your terminal will also show task status and run log links.
