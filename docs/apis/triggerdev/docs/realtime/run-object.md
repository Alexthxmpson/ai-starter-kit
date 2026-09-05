---
source: https://trigger.dev/docs/realtime/run-object
scraped: 2026-02-28
---

# The Run Object

> The run object schema for Realtime subscriptions

The run object is the primary data structure returned by Realtime subscriptions (e.g., `runs.subscribeToRun()`). It encompasses comprehensive information about the run, including identification, task details, input/output data, and execution metadata.

Type-safety is supported for the run object, allowing you to infer the types of the run's payload and output. See [type-safety](#type-safety) for more information.

## The Run Object

### Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | string | Yes | The run ID |
| `taskIdentifier` | string | Yes | The task identifier |
| `payload` | object | Yes | The input payload for the run |
| `output` | object | | The output result of the run |
| `createdAt` | Date | Yes | Timestamp when the run was created |
| `updatedAt` | Date | Yes | Timestamp when the run was last updated |
| `number` | number | Yes | Sequential number assigned to the run |
| `status` | RunStatus | Yes | Current status of the run |
| `durationMs` | number | Yes | Duration of the run in milliseconds |
| `costInCents` | number | Yes | Total cost of the run in cents |
| `baseCostInCents` | number | Yes | Base cost before additional charges |
| `tags` | string[] | Yes | Array of tags associated with the run |
| `idempotencyKey` | string | | Key for idempotent execution |
| `expiredAt` | Date | | Timestamp when the run expired |
| `ttl` | string | | Time-to-live duration for the run |
| `finishedAt` | Date | | Timestamp when the run finished |
| `startedAt` | Date | | Timestamp when the run started |
| `delayedUntil` | Date | | Timestamp until which the run is delayed |
| `queuedAt` | Date | | Timestamp when the run was queued |
| `metadata` | Record<string, DeserializedJson> | | Additional metadata associated with the run |
| `error` | SerializedError | | Error information if the run failed |
| `isTest` | boolean | Yes | Indicates whether this is a test run |

### RunStatus Enum

| Status | Description |
|--------|-------------|
| `WAITING_FOR_DEPLOY` | Task hasn't been deployed yet but is waiting to be executed |
| `QUEUED` | Run is waiting to be executed by a worker |
| `EXECUTING` | Run is currently being executed by a worker |
| `REATTEMPTING` | Run has failed and is waiting to be retried |
| `FROZEN` | Run has been paused by the system, and will be resumed by the system |
| `COMPLETED` | Run has been completed successfully |
| `CANCELED` | Run has been canceled by the user |
| `FAILED` | Run has been completed with errors |
| `CRASHED` | Run has crashed and won't be retried, most likely the worker ran out of resources, e.g. memory or storage |
| `INTERRUPTED` | Run was interrupted during execution, mostly this happens in development environments |
| `SYSTEM_FAILURE` | Run has failed to complete, due to an error in the system |
| `DELAYED` | Run has been scheduled to run at a specific time |
| `EXPIRED` | Run has expired and won't be executed |
| `TIMED_OUT` | Run has reached its maxDuration and has been stopped |

## Type-Safety

You can infer the types of the run's payload and output by passing the task type to the `subscribeToRun` function. This provides type-safe access to the run's payload and output.

```ts
import { runs, tasks } from "@trigger.dev/sdk";
import type { myTask } from "./trigger/my-task";

// Somewhere in your backend code
async function myBackend() {
  const handle = await tasks.trigger("my-task", { some: "data" });

  for await (const run of runs.subscribeToRun<typeof myTask>(handle.id)) {
    // This will log the run every time it changes
    console.log(run.payload.some);

    if (run.output) {
      // This will log the output if it exists
      console.log(run.output.some);
    }
  }
}
```

When using `subscribeToRunsWithTag`, you can pass a union of task types for all the possible tasks that can have the tag.

```ts
import { runs } from "@trigger.dev/sdk";
import type { myTask, myOtherTask } from "./trigger/my-task";

// Somewhere in your backend code
for await (const run of runs.subscribeToRunsWithTag<typeof myTask | typeof myOtherTask>("my-tag")) {
  // You can narrow down the type based on the taskIdentifier
  switch (run.taskIdentifier) {
    case "my-task": {
      console.log("Run output:", run.output.foo); // This will be type-safe
      break;
    }
    case "my-other-task": {
      console.log("Run output:", run.output.bar); // This will be type-safe
      break;
    }
  }
}
```

This works with all realtime subscription functions:

- `runs.subscribeToRun<TaskType>()`
- `runs.subscribeToRunsWithTag<TaskType>()`
- `runs.subscribeToBatch<TaskType>()`
