---
source: https://trigger.dev/docs/replaying
scraped: 2026-02-28
---

# Replaying

## Overview

A replay creates a duplicate of a run using the same payload but executes it against the most current code version in that environment. This feature proves valuable when errors occur and you need to retry with updated code.

## UI-Based Replaying

### From a Run Detail View

1. **Initiate replay** - Click the Replay button positioned in the top right corner
2. **Configure settings** - Adjust the payload if editable and select which environment should execute the replay

### From the Runs List

1. **Access actions** - Click the action button (triple dot menu) on any run
2. **Select replay** - Choose the replay option from the popover menu

## SDK-Based Replaying

You can programmatically replay a run using the SDK:

```ts
const replayedRun = await runs.replay(run.id);
```

After triggering a task with `trigger()` or `batchTrigger()`, you receive a run handle containing an `id` property, which enables replaying that specific execution.

The run ID is also accessible within task execution:

```ts
export const simpleChildTask = task({
  id: "simple-child-task",
  run: async (payload, { ctx }) => {
    const runId = ctx.run.id;
  },
});
```

This allows you to persist the run ID to your database for later replay operations.

## Bulk Operations

For information on replaying multiple runs simultaneously, consult the [Bulk actions](/bulk-actions) documentation.
