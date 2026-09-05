---
source: https://trigger.dev/docs/runs/metadata
scraped: 2026-02-28
---

# Run Metadata

## Overview

Trigger.dev allows you to attach structured data to task runs through metadata. This feature supports up to 256KB of data per run, accessible within the run function, via API, Realtime, and dashboard.

## Attaching Metadata

Pass metadata when triggering a task:

```ts
const handle = await myTask.trigger(
  { message: "hello world" },
  { metadata: { user: { name: "Eric", id: "user_1234" } } }
);
```

## Retrieving Metadata

Inside a run function, access metadata using:

```ts
import { task, metadata } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  run: async (payload: { message: string }) => {
    const currentMetadata = metadata.current();
    const user = metadata.get("user");
  },
});
```

Metadata methods work in nested function calls and lifecycle hooks (onStart, onSuccess, etc.) within runs, but have no effect when called outside run contexts.

## Update Methods

All methods except `flush` and `stream` are synchronous and non-blocking:

| Method | Purpose |
|--------|---------|
| `set(key, value)` | Set a key-value pair |
| `del(key)` | Remove a key |
| `replace(object)` | Replace entire metadata object |
| `append(key, value)` | Add value to array |
| `remove(key, value)` | Remove value from array |
| `increment(key, amount)` | Increment numeric value |
| `decrement(key, amount)` | Decrement numeric value |
| `flush()` | Persist metadata immediately |

Methods chain fluently:

```ts
metadata
  .set("progress", 0.1)
  .append("logs", "Step 1 complete")
  .increment("progress", 0.4);
```

## Parent & Root Updates

Child tasks can update parent or root task metadata:

```ts
metadata.parent.set("progress", 0.5);
metadata.root.append("logs", "Update from child");
```

All update methods are available on `metadata.parent` and `metadata.root`.

## Stream Handling

**Note:** As of SDK v4.1.0, `metadata.stream()` is deprecated. Use [Realtime Streams v2](/tasks/streams) with `streams.pipe()` instead.

## Type Safety

Metadata accepts JSON-serializable objects. Use validation libraries like Zod for type safety:

```ts
import { z } from "zod";

const MetadataSchema = z.object({
  user: z.object({
    name: z.string(),
    id: z.string(),
  }),
});

type Metadata = z.infer<typeof MetadataSchema>;
```

## Constraints

- **Maximum size:** 256KB per run (configurable via `TASK_RUN_METADATA_MAXIMUM_SIZE` in self-hosted deployments)
- **Top-level format:** Must be an object, not an array or string
- **Serialization:** Functions and class instances cannot be serialized; dates become strings when stored

## Inspecting Metadata

View metadata in the Trigger.dev dashboard's run details view, or programmatically:

```ts
import { runs } from "@trigger.dev/sdk";

const run = await runs.retrieve("run_1234");
console.log(run.metadata);
```
