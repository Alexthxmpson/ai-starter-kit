---
source: https://trigger.dev/docs/migrating-from-v3
scraped: 2026-02-28
---

# Migrating from v3

## Trigger.dev v3 Deprecation Notice

Trigger.dev v3 is being retired with key deadlines:

- **April 1, 2026**: New v3 deploys will stop working; existing v3 runs continue
- **July 1, 2026**: Complete v3 shutdown; all v3 runs cease executing

Migration to v4 takes approximately 2 minutes and is required before April 2026.

---

## What's New in v4

| Feature | Description |
|---------|-------------|
| Wait for token | Create and wait for tokens to enable approval workflows and external condition handling |
| Wait idempotency | Skip waits using the same idempotency key across wait operations |
| Priority | Specify priority when triggering tasks |
| Global lifecycle hooks | Register hooks executed for all runs regardless of task |
| onWait and onResume | Execute code when runs pause or resume due to waits |
| onComplete | Execute code when runs finish, regardless of outcome |
| onCancel | Execute code when runs are cancelled |
| Hidden tasks | Create unexported tasks that remain executable |
| Middleware & locals | Top-level middleware executes before/after hooks; locals share data |
| useWaitToken hook | Complete wait tokens from React components |
| ai.tool | Create AI tools from existing schemaTasks for Vercel AI SDK |

---

## Node.js Runtime Support

**v3**: Node.js 21.7.3

**v4** (configurable via `trigger.config.ts`):
- Node.js 21.7.3 (default)
- Node.js 22.16.0 (`node-22`)
- Bun 1.3.3 (`bun`)

Set runtime in configuration:
```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  runtime: "node-22",
  project: "<your-project-ref>",
});
```

---

## Migration Steps

1. Install v4 package using `trigger.dev@latest update`
2. Run `trigger dev` locally and test, fixing breaking changes
3. Deploy to staging and test (recommended)
4. Deploy updated backend with v4 package
5. Deploy tasks to production

**Note**: Between steps 4 and 5, v4-triggered runs initially use v3; only post-deployment runs use v4.

**IP Allowlisting**: Update IP allowlists before/after switching to v4 to avoid connectivity issues.

---

## Deprecations

### Import Path Changes
```ts
// Old path (deprecated)
import { task } from "@trigger.dev/sdk/v3";

// New path
import { task } from "@trigger.dev/sdk";
```

### handleError Renamed
`handleError` is now `catchError` to better reflect error-catching capability.

### init Deprecated
Replaced by `locals` API and middleware. Old pattern:
```ts
const myTask = task({
  init: async () => ({ myClient: new MyClient() }),
  run: async (payload, { ctx, init }) => {
    const client = init.myClient;
  },
});
```

New pattern using middleware:
```ts
import { task, locals, tasks } from "@trigger.dev/sdk";

const MyClientLocal = locals.create<MyClient>("myClient");

tasks.middleware("my-client", async ({ next }) => {
  const client = new MyClient();
  locals.set(MyClientLocal, client);
  await next();
});

function getMyClient() {
  return locals.getOrThrow(MyClientLocal);
}

const myTask = task({
  run: async (payload, { ctx }) => {
    const client = getMyClient();
  },
});
```

### toolTask Deprecated
Replaced by `ai.tool()` function. Old approach:
```ts
const myToolTask = toolTask({
  id: "my-tool-task",
  run: async (payload, { ctx }) => {},
});
```

New approach:
```ts
const myToolTask = schemaTask({
  id: "my-tool-task",
  schema: z.object({ input: z.string() }),
  run: async (payload, { ctx }) => {},
});

const myTool = ai.tool(myToolTask);
```

---

## Breaking Changes

### Queue Definition
Queues must now be pre-defined; on-demand creation is removed.

**Old approach**:
```ts
await myTask.trigger({ foo: "bar" },
  { queue: { name: "my-queue", concurrencyLimit: 10 } });
```

**New approach**:
```ts
import { queue, task } from "@trigger.dev/sdk";

const myQueue = queue({
  name: "my-queue",
  concurrencyLimit: 10,
});

export const myTask = task({
  id: "my-task",
  queue: myQueue,
  run: async (payload, { ctx }) => {},
});

// Trigger by queue name or task-defined queue
await myTask.trigger({ foo: "bar" }, { queue: "my-queue" });
await myTask.trigger({ foo: "bar" }); // Uses task queue
```

### Lifecycle Hook Signatures
All hooks now use single object parameter format.

**Old signature**:
```ts
onStart: (payload, { ctx }) => {},
onSuccess: (payload, output, { ctx }) => {},
```

**New signature**:
```ts
onStart: ({ payload, ctx, task }) => {},
onSuccess: ({ payload, ctx, task, output }) => {},
onFailure: ({ payload, ctx, task, error }) => {},
onWait: ({ payload, ctx, task, wait }) => {},
onResume: ({ payload, ctx, task, wait }) => {},
onComplete: ({ payload, ctx, task, result }) => {},
catchError: ({ payload, ctx, task, error, retry, retryAt, retryDelayInMs }) => {},
```

### Context Changes
- `ctx.attempt.id` and `ctx.attempt.status` removed
- `ctx.task.exportName` removed
- `ctx.attempt.number` remains available

### BatchTrigger Changes
Batch runs no longer accessible directly from handle.

**Old approach**:
```ts
const batchHandle = await tasks.batchTrigger([
  [myTask, { foo: "bar" }],
]);
console.log(batchHandle.runs);
```

**New approach**:
```ts
const batchHandle = await tasks.batchTrigger([
  [myTask, { foo: "bar" }],
]);
const batch = await batch.retrieve(batchHandle.batchId);
console.log(batch.runs);
```

### triggerAndWait / batchTriggerAndWait
Returns Result object instead of raw output. Use pattern:
```ts
if (result.ok) {
  const output = result.output;
}
// Or use .unwrap() (throws on failure)
const output = result.unwrap();
```

Do not wrap these functions in `Promise.all()`.

### OpenTelemetry Updates
Major version updates to OpenTelemetry packages (0.52.1 to 0.203.0):
- @opentelemetry/api-logs
- @opentelemetry/exporter-logs-otlp-http
- @opentelemetry/exporter-trace-otlp-http
- @opentelemetry/instrumentation

Custom exporters may require package updates.

---

## Installation

Update dependencies:
```bash
npx trigger.dev@latest update
```

or with yarn/pnpm equivalents. This updates all `@trigger.dev/*` packages to version 4.x.
