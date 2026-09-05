---
source: https://trigger.dev/docs/realtime/backend/subscribe
scraped: 2026-02-28
---

# Subscribe Functions

Subscribe to run updates using async iterators with Trigger.dev's SDK.

## Available Subscribe Functions

### runs.subscribeToRun

Monitors all changes to a specific run, yielding updates through an async iterator until completion.

```ts
import { runs } from "@trigger.dev/sdk";

for await (const run of runs.subscribeToRun("run_1234")) {
  console.log(run);
}
```

Supports both server-side (API key) and client-side (public access token) authentication.

### runs.subscribeToRunsWithTag

Tracks all updates to runs sharing a specific tag. The iterator continues indefinitely and requires manual loop termination.

```ts
import { runs } from "@trigger.dev/sdk";

for await (const run of runs.subscribeToRunsWithTag("user:1234")) {
  console.log(run);
}
```

### runs.subscribeToBatch

Observes all changes for runs within a batch. Like tag subscriptions, the iterator doesn't auto-complete.

```ts
import { runs } from "@trigger.dev/sdk";

for await (const run of runs.subscribeToBatch("batch_1234")) {
  console.log(run);
}
```

## Type Safety

Pass task types as generic parameters for payload and output typing:

```ts
import { runs, tasks } from "@trigger.dev/sdk";
import type { myTask } from "./trigger/my-task";

async function myBackend() {
  const handle = await tasks.trigger("my-task", { some: "data" });

  for await (const run of runs.subscribeToRun<typeof myTask>(handle.id)) {
    console.log(run.payload.some);
    if (run.output) {
      console.log(run.output.some);
    }
  }
}
```

For multiple task types with `subscribeToRunsWithTag`, use union types and narrow with `taskIdentifier`:

```ts
import { runs } from "@trigger.dev/sdk";
import type { myTask, myOtherTask } from "./trigger/my-task";

for await (const run of runs.subscribeToRunsWithTag<typeof myTask | typeof myOtherTask>("my-tag")) {
  switch (run.taskIdentifier) {
    case "my-task": {
      console.log("Run output:", run.output.foo);
      break;
    }
    case "my-other-task": {
      console.log("Run output:", run.output.bar);
      break;
    }
  }
}
```

## Metadata Updates

Tasks can emit real-time metadata changes using the metadata API, enabling progress tracking and status monitoring. Subscribers automatically receive updated run objects containing new metadata.

### Example: Progress Tracking Task

```ts
import { task, metadata } from "@trigger.dev/sdk";

export const progressTask = task({
  id: "progress-task",
  run: async (payload: { items: string[] }) => {
    const total = payload.items.length;

    for (let i = 0; i < payload.items.length; i++) {
      metadata.set("progress", {
        current: i + 1,
        total: total,
        percentage: Math.round(((i + 1) / total) * 100),
        currentItem: payload.items[i],
      });

      await processItem(payload.items[i]);
    }

    metadata.set("status", "completed");
    return { processed: total };
  },
});

async function processItem(item: string) {
  await new Promise((resolve) => setTimeout(resolve, 1000));
}
```

### Consuming Metadata Updates

```ts
import { runs } from "@trigger.dev/sdk";
import type { progressTask } from "./trigger/progress-task";

async function monitorProgress(runId: string) {
  for await (const run of runs.subscribeToRun<typeof progressTask>(runId)) {
    console.log(`Run ${run.id} status: ${run.status}`);

    if (run.metadata?.progress) {
      const progress = run.metadata.progress as {
        current: number;
        total: number;
        percentage: number;
        currentItem: string;
      };

      console.log(`Progress: ${progress.current}/${progress.total} (${progress.percentage}%)`);
      console.log(`Processing: ${progress.currentItem}`);
    }

    if (run.metadata?.status === "completed") {
      console.log("Task completed!");
      break;
    }
  }
}
```

### Type-Safe Metadata

Define metadata interfaces for enhanced type safety:

```ts
import { runs } from "@trigger.dev/sdk";
import type { progressTask } from "./trigger/progress-task";

interface ProgressMetadata {
  progress?: {
    current: number;
    total: number;
    percentage: number;
    currentItem: string;
  };
  status?: "running" | "completed" | "failed";
}

async function monitorTypedProgress(runId: string) {
  for await (const run of runs.subscribeToRun<typeof progressTask>(runId)) {
    const metadata = run.metadata as ProgressMetadata;

    if (metadata?.progress) {
      console.log(`Progress: ${metadata.progress.percentage}%`);
    }
  }
}
```
