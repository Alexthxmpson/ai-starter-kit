---
source: https://trigger.dev/docs/idempotency
scraped: 2026-02-28
---

# Idempotency

## Overview

Idempotency ensures that API calls produce consistent results when executed multiple times. Trigger.dev implements task-level idempotency: triggering a task with the same `idempotencyKey` twice returns the original run's handle rather than creating a duplicate.

## Primary Use Cases

The most common application is "preventing duplicate child tasks when a parent task retries." Additional scenarios include:

- Preventing duplicate emails during retries
- Avoiding double-charging customers in payment processing
- Ensuring one-time setup tasks run only once
- Deduplicating webhook event processing

## Creating Idempotency Keys

You can create keys using `idempotencyKeys.create()`:

```ts
import { idempotencyKeys, task } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  retry: { maxAttempts: 4 },
  run: async (payload: any) => {
    const idempotencyKey = await idempotencyKeys.create("my-task-key");
    await childTask.trigger({ foo: "bar" }, { idempotencyKey });
  },
});
```

Alternatively, pass a raw string directly:

```ts
await myTask.trigger({ some: "data" }, { idempotencyKey: myUser.id });
```

## Understanding Scopes

The `scope` parameter determines how context gets combined with your key:

| Scope | Hashed Content | Purpose |
|-------|---|---|
| `"run"` (default) | key + parentRunId | Prevents duplicates within a single parent run |
| `"attempt"` | key + parentRunId + attemptNumber | Allows child task re-execution on each retry |
| `"global"` | key only | Ensures task runs once ever, regardless of parent |

### Run Scope (Default)

Idempotency keys are scoped to the current parent task run. Multiple parent runs with the same key will trigger separate child tasks:

```ts
const idempotencyKey = await idempotencyKeys.create(`send-confirmation-${orderId}`);
await sendEmail.trigger({ to: payload.email }, { idempotencyKey });
```

### Attempt Scope

Child tasks re-execute on each parent retry:

```ts
const idempotencyKey = await idempotencyKeys.create(`fetch-${userId}`, {
  scope: "attempt",
});
const result = await fetchLatestData.triggerAndWait(payload, { idempotencyKey });
```

### Global Scope

Tasks run once ever, regardless of which parent triggered them:

```ts
const idempotencyKey = await idempotencyKeys.create(
  `welcome-email-${userId}`,
  { scope: "global" }
);
await sendWelcomeEmail.trigger({ to: email }, { idempotencyKey });
```

## Key Expiration (TTL)

The `idempotencyKeyTTL` option sets a time window for idempotency. The default is 30 days. After expiration, triggering with the same key creates a new run:

```ts
await childTask.trigger(
  { foo: "bar" },
  { idempotencyKey, idempotencyKeyTTL: "60s" }
);
```

Supported units: `s` (seconds), `m` (minutes), `h` (hours), `d` (days).

## Failed Runs and Idempotency

Failed runs automatically clear their idempotency keys, allowing re-triggering. Successful and canceled runs retain keys. Reset keys using:

```ts
await idempotencyKeys.reset("my-task", "my-idempotency-key");
```

Or set a shorter TTL for automatic expiration.

## Resetting Idempotency Keys

Clear keys to allow re-triggering:

```ts
idempotencyKeys.reset(
  taskIdentifier: string,
  idempotencyKey: string,
  requestOptions?: ZodFetchOptions
): Promise<{ id: string }>
```

For run-scoped keys outside task context, provide `parentRunId`:

```ts
await idempotencyKeys.reset("my-task", "my-key", {
  scope: "run",
  parentRunId: "run_abc123"
});
```

For attempt-scoped keys, also provide `attemptNumber`:

```ts
await idempotencyKeys.reset("my-task", "my-key", {
  scope: "attempt",
  parentRunId: "run_abc123",
  attemptNumber: 1
});
```

You can also reset keys through the Trigger.dev dashboard.

## Payload-Based Idempotency

Not natively supported, but implementable via hashing:

```ts
import { createHash } from "node:crypto";

const idempotencyKey = await idempotencyKeys.create(hash(childPayload));

function hash(payload: any): string {
  const hashObj = createHash("sha256");
  hashObj.update(JSON.stringify(payload));
  return hashObj.digest("hex");
}
```

## Important Considerations

- Idempotency keys are scoped to specific tasks and environments
- Different tasks with the same key will both execute
- Same key + different scopes = different behaviors
- Resetting affects only the current environment
