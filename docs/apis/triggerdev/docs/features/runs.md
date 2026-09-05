---
source: https://trigger.dev/docs/runs
scraped: 2026-02-28
---

# Runs

Understanding the lifecycle of task run execution in Trigger.dev

## What are runs?

A run represents a single instance of task execution, created when you trigger a task. Each run contains "a unique run ID," "the current status of the run," "the payload (input data) for the task," and associated metadata.

## The run lifecycle

Runs progress through various states during execution. The standard path involves being queued, executed, and completed.

### Initial states

- **Pending version**: Task awaits version updates before execution can proceed
- **Delayed**: Run waits until a specified delay period passes
- **Queued**: Run is ready and waiting for worker assignment
- **Dequeued**: Task is being sent to a worker for execution

### Execution states

- **Executing**: Worker is actively processing the task
- **Waiting**: Task is paused using triggerAndWait(), batchTriggerAndWait(), or a wait function

### Final states

- **Completed**: Task finished successfully
- **Canceled**: User manually stopped the run
- **Failed**: Task encountered an error
- **Timed out**: Task exceeded its maxDuration
- **Crashed**: Worker process crashed (typically out of memory)
- **System failure**: Unrecoverable system error occurred
- **Expired**: Run's time-to-live (TTL) passed before execution started

## Attempts

An attempt represents a single task execution within a run. Runs may have multiple attempts based on retry settings. Each attempt has "a unique attempt ID," "a status," and "an output (if successful) or an error (if failed)."

A run completes when the final attempt succeeds or when retry limits are exhausted.

## Boolean helpers

Run objects include convenient methods for status checking:

- `isQueued`, `isExecuting`, `isWaiting`, `isCompleted`, `isCanceled`, `isFailed`, `isSuccess`

## Advanced run features

### Idempotency Keys

Provide an idempotency key to prevent duplicate executions:

```ts
await yourTask.trigger({ foo: "bar" }, { idempotencyKey: "unique-key" });
```

If a run with the same key exists in progress, the new trigger is ignored. If finished, previous results are returned.

### Canceling runs

```ts
await runs.cancel(runId);
```

Cancellation halts execution, prevents retries, and cancels child runs.

### Time-to-live (TTL)

```ts
await yourTask.trigger({ foo: "bar" }, { ttl: "10m" });
```

TTL defines how long a run can remain queued before automatic expiration. Dev runs default to 10 minutes; Cloud environments support up to 14 days.

### Delayed runs

```ts
await yourTask.trigger({ foo: "bar" }, { delay: "1h" });
```

Schedule task execution for a future time.

### Replaying runs

```ts
await runs.replay(runId);
```

Create a new run with identical input, useful for debugging or recovery.

### Waiting for runs

**triggerAndWait()**: Triggers a task and waits for results before continuing.

**batchTriggerAndWait()**: Batch-triggers tasks and waits for all results.

## Runs API

### runs.list()

```ts
let page = await runs.list({ limit: 20 });

for (const run of page.data) {
  console.log(run);
}

while (page.hasNextPage()) {
  page = await page.getNextPage();
}
```

Filter options include status, taskIdentifier, date range, version, tags, batch ID, and schedule ID.

### runs.retrieve()

```ts
const run = await runs.retrieve(runId);
```

Optionally provide task type for proper payload and output typing.

### runs.cancel()

```ts
await runs.cancel(runId);
```

### runs.replay()

```ts
await runs.replay(runId);
```

### runs.reschedule()

```ts
await runs.reschedule(runId, { delay: "1h" });
```

Updates delayed runs with new timing (only valid in DELAYED state).

## Real-time updates

```ts
for await (const run of runs.subscribeToRun(runId)) {
  console.log(run);
}
```

Subscribe to live run changes with optional task typing for type safety.

## Triggering undeployed tasks

Runs can be triggered for tasks not yet deployed. The run enters "Waiting for deploy" state until deployment, then executes normally — useful in CI/CD pipelines.
