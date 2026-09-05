---
source: https://trigger.dev/docs/wait-for
scraped: 2026-02-28
---

# Wait for

## Overview

The `wait.for` function enables tasks to pause execution for specified time periods before continuing. This feature eliminates the need to manage complex scheduling or cron jobs manually.

## Usage

Tasks support waiting across multiple time units:

```ts
export const veryLongTask = task({
  id: "very-long-task",
  run: async (payload) => {
    await wait.for({ seconds: 5 });
    await wait.for({ minutes: 10 });
    await wait.for({ hours: 1 });
    await wait.for({ days: 1 });
    await wait.for({ weeks: 1 });
    await wait.for({ months: 1 });
    await wait.for({ years: 1 });
  },
});
```

## Performance Optimization

When using Trigger.dev Cloud, task execution pauses automatically for waits exceeding a few seconds. Parent tasks remain checkpointed during subtask waits, which don't consume compute resources. Time-based waits longer than 5 seconds similarly checkpoint and exclude usage from billing.

## Idempotency

Include an idempotency key to skip duplicate waits during task retries:

```ts
await wait.for(
  { seconds: 10 },
  { idempotencyKey: "my-idempotency-key", idempotencyKeyTTL: "1h" }
);
```

This mechanism helps prevent repeated waits when the same task execution is retried with identical parameters.
