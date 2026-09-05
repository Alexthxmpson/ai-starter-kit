---
source: https://trigger.dev/docs/runs/max-duration
scraped: 2026-02-28
---

# Max Duration

The `maxDuration` parameter establishes a compute time threshold for tasks in Trigger.dev. When exceeded, tasks are automatically terminated to prevent resource waste.

## Configuration Levels

You must define a default `maxDuration` in your `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "proj_gtcwttqhhtlasxgfuhxs",
  maxDuration: 60, // seconds
});
```

The minimum allowed value is 5 seconds. You can override this default at the task level or when triggering individual runs.

## How It Works

The system measures CPU time elapsed during task execution, measured in seconds. As noted in the documentation, this "does not include time spent waiting during `wait.for` calls, `triggerAndWait` calls, or `batchTriggerAndWait` calls."

Monitor CPU time usage within your task:

```ts
import { task, usage } from "@trigger.dev/sdk";

export const maxDurationTask = task({
  id: "max-duration-task",
  maxDuration: 300,
  run: async (payload: any, { ctx }) => {
    let currentUsage = usage.getCurrent();
    currentUsage.attempt.durationMs; // CPU time in milliseconds
  },
});
```

When a task exceeds its limit, execution halts with an error.

## Task-Level Configuration

Override defaults for specific tasks:

```ts
export const maxDurationTask = task({
  id: "max-duration-task",
  maxDuration: 300, // 5 minutes
  run: async (payload: any, { ctx }) => { /*...*/ },
});
```

Disable limits using `timeout.None`:

```ts
import { timeout } from "@trigger.dev/sdk";

maxDuration: timeout.None, // No maximum duration
```

## Run-Level Configuration

Set duration when triggering:

```ts
const run = await maxDurationTask.trigger(
  { foo: "bar" },
  { maxDuration: 300 }
);
```

Access the configured duration in context:

```ts
console.log(ctx.run.maxDuration); // 300
```

## Lifecycle Considerations

When a task exceeds its `maxDuration`, lifecycle functions (`cleanup`, `onSuccess`, `onFailure`) are not invoked.
