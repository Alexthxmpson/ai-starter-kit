---
source: https://trigger.dev/docs/runs/heartbeats
scraped: 2026-02-28
---

# Heartbeats

Heartbeats prevent long-running tasks from being marked as stalled on Trigger.dev.

## How Heartbeats Work

The platform receives a heartbeat from your task every 30 seconds. If no heartbeat arrives within 5 minutes, the run is marked stalled and stops with a `TASK_RUN_STALLED_EXECUTING` error.

## Handling Event Loop Blocking

When synchronous work blocks the event loop for extended periods, heartbeats cannot be sent. Use `heartbeats.yield()` inside loops to allow the runtime to send heartbeats:

```ts
import { task, heartbeats } from "@trigger.dev/sdk";

export const processLargeDataset = task({
  id: "process-large-dataset",
  run: async (payload: { items: string[] }) => {
    for (const row of payload.items) {
      await heartbeats.yield();
      processRow(row);
    }
    return { processed: payload.items.length };
  },
});

function processRow(row: string) {
  // synchronous CPU-heavy work
}
```

You can call `heartbeats.yield()` every iteration; it only yields when necessary.

## Progress Tracking

Send progress updates to the Trigger.dev dashboard using `metadata.set()` or `metadata.append()`. These updates stream to the dashboard and Realtime listeners in real-time. See the Progress monitoring documentation for complete examples.

## External System Updates

Trigger.dev doesn't automatically push updates to external services. To notify your own backend (like Supabase Realtime), call your API directly from within the task — such as in the same loop where you use heartbeats or metadata functions.
