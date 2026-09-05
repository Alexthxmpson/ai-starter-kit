---
source: https://trigger.dev/docs/machines
scraped: 2026-02-28
---

# Machines

## Overview

Configure the number of vCPUs and GBs of RAM for task execution. The `machine` configuration is optional, though higher-spec machines increase costs while potentially improving performance for CPU or memory-intensive workloads.

## Basic Configuration

```ts
import { task } from "@trigger.dev/sdk";

export const heavyTask = task({
  id: "heavy-task",
  machine: "large-1x",
  run: async ({ payload, ctx }) => {
    //...
  },
});
```

Set a default machine in your `trigger.config.ts` file:

```ts
import type { TriggerConfig } from "@trigger.dev/sdk";

export const config: TriggerConfig = {
  machine: "small-2x",
  // ... other config
};
```

## Available Machine Configurations

| Preset             | vCPU | Memory | Disk Space |
| :----------------- | :--- | :----- | :--------- |
| micro              | 0.25 | 0.25   | 10GB       |
| small-1x (default) | 0.5  | 0.5    | 10GB       |
| small-2x           | 1    | 1      | 10GB       |
| medium-1x          | 1    | 2      | 10GB       |
| medium-2x          | 2    | 4      | 10GB       |
| large-1x           | 4    | 8      | 10GB       |
| large-2x           | 8    | 16     | 10GB       |

View pricing details at https://trigger.dev/pricing#computePricing

## Overriding Machine at Trigger Time

Override the task machine when triggering:

```ts
await tasks.trigger<typeof heavyTask>(
  "heavy-task",
  { message: "hello world" },
  { machine: "large-2x" }
);
```

This is useful when you anticipate specific payloads requiring additional resources, such as processing larger files or customers with substantial data.

## Out Of Memory (OOM) Errors

Tasks may fail with error message: "TASK_PROCESS_OOM_KILLED. Your run was terminated due to exceeding the machine's memory limit. Try increasing the machine preset in your task options or replay using a larger machine."

### Automatic OOM Detection

The system detects common scenarios:
- V8 heap limit exceeded (large long-lived objects)
- Process exceeds machine memory limit
- Child processes (e.g., ffmpeg) trigger memory limit and exit with non-zero code

### Memory/Resource Monitoring

Use the provided `ResourceMonitor` helper class to log memory debug information at regular intervals. This class tracks disk usage, memory consumption, Node.js process metrics, heap statistics, and garbage collection activity.

Key monitoring features:
- System disk and memory metrics
- Node.js process and heap statistics
- Child process resource tracking
- Garbage collection monitoring
- Configurable logging intervals
- Enhanced and compact logging modes

Enable monitoring in middleware:

```ts
import { task, logger, wait } from "@trigger.dev/sdk";
import { ResourceMonitor } from "../resourceMonitor.js";

tasks.middleware("resource-monitor", async ({ ctx, next }) => {
  const resourceMonitor = new ResourceMonitor({
    ctx,
  });

  if (process.env.RESOURCE_MONITOR_ENABLED === "1") {
    resourceMonitor.startMonitoring(1_000);
  }

  await next();

  resourceMonitor.stopMonitoring();
});
```

Monitor child processes by specifying the process name:

```ts
const resourceMonitor = new ResourceMonitor({
  ctx,
  processName: "ffmpeg",
});
```

### Explicit OOM Errors

Throw an OutOfMemoryError explicitly for proactive handling:

```ts
import { task } from "@trigger.dev/sdk";
import { OutOfMemoryError } from "@trigger.dev/sdk";

export const yourTask = task({
  id: "your-task",
  machine: "medium-1x",
  run: async (payload: any, { ctx }) => {
    //...
    throw new OutOfMemoryError();
  },
});
```

### Retrying with a Larger Machine

Configure automatic retry with a larger machine for occasional OOM errors:

```ts
import { task } from "@trigger.dev/sdk";

export const yourTask = task({
  id: "your-task",
  machine: "medium-1x",
  retry: {
    outOfMemory: {
      machine: "large-1x",
    },
  },
  run: async (payload: any, { ctx }) => {
    //...
  },
});
```

**Note:** This setting only retries on OOM errors and doesn't permanently change the default machine. For consistent OOM errors, modify the `machine` property directly.
