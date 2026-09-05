---
source: https://trigger.dev/docs/tasks/overview
scraped: 2026-02-28
---

# Tasks: Overview

## Core Concept

Tasks in Trigger.dev are "functions that can run for a long time and provide strong resilience to failure." They support different types, including regular and scheduled variants.

## Basic Task Structure

A minimal task requires three components:

1. **Unique ID**: Identifies the task for triggering and dashboard viewing
2. **Run function**: Executes the main task logic asynchronously
3. **Payload handling**: Receives data passed during task invocation

```typescript
import { task } from "@trigger.dev/sdk";

const helloWorld = task({
  id: "hello-world",
  run: async (payload: { message: string }) => {
    console.log(payload.message);
  },
});
```

## Triggering Tasks

Tasks can be triggered two ways:

1. Via the dashboard "Test" feature
2. Programmatically from backend code, returning a handle for status monitoring

## Configuration Options

### Retry Configuration
Tasks retry up to 3 times by default. Customize retry behavior with exponential backoff settings, including maximum attempts, timeout ranges, and randomization.

### Queue Management
Control task concurrency through queue settings, enabling sequential or parallel execution patterns.

### Machine Resources
Specify CPU and RAM requirements for computationally intensive tasks using preset machine configurations.

### Duration Limits
Set `maxDuration` to prevent runaway executions, measured in seconds.

## Lifecycle Hooks

Tasks support multiple lifecycle phases:

- **onStartAttempt**: Fires before each attempt begins
- **onWait/onResume**: Handle pause/resume states during async operations
- **onSuccess**: Executes upon successful completion
- **onComplete**: Runs regardless of success/failure outcome
- **onFailure**: Triggers after all retry attempts exhausted
- **onCancel**: Manages cleanup when runs are cancelled

## Advanced Features

### Middleware and Locals
The middleware system enables wrapping entire task execution lifecycles. The `locals` API shares data between middleware and hooks, useful for resource management like database connections.

### Error Handling
The `catchError` function controls error handling behavior and retry decisions.

### Global Hooks
Define lifecycle hooks that execute for all tasks via `init.ts` file or the `tasks` object methods.
