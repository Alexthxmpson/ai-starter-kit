---
source: https://trigger.dev/docs/tags
scraped: 2026-02-28
---

# Tags

## Overview

Tags enable efficient filtering of runs in the dashboard and SDK. Each run supports up to 10 tags, with each tag being a string of 1-128 characters.

**Naming Convention:** The documentation recommends prefixing tags with their type followed by an underscore or colon (e.g., `user_123456`, `video:123`). While not enforced, this approach improves clarity and filtering efficiency.

## Adding Tags

### Method 1: During Run Triggering

Tags can be specified when initiating a run using the `tags` option across all trigger methods:

```ts
const handle = await myTask.trigger(
  { message: "hello world" },
  { tags: ["user_123456", "org_abcdefg"] }
);
```

For batch operations:

```ts
const batch = await myTask.batchTrigger([
  {
    payload: { message: "foo" },
    options: { tags: "product_123456" },
  },
  {
    payload: { message: "bar" },
    options: { tags: ["user_123456", "product_3456789"] },
  },
]);
```

### Method 2: Inside the Run Function

Use `tags.add()` to attach tags during execution:

```ts
import { task, tags } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  run: async (payload: { message: string }, { ctx }) => {
    logger.log("Tags from the run context", { tags: ctx.run.tags });
    await tags.add("product_1234567");
  },
});
```

**Limit Note:** If adding tags exceeds the 10-tag maximum, an error is logged and new tags are ignored.

## Child Run Tag Propagation

Tags do not automatically cascade to child runs. To propagate tags explicitly:

```ts
export const myTask = task({
  id: "my-task",
  run: async (payload: Payload, { ctx }) => {
    const { id } = await otherTask.trigger(
      { message: "triggered from myTask" },
      { tags: ctx.run.tags }
    );
  },
});
```

## Filtering Runs

### Dashboard Filtering

On the Runs page, access the filter menu, select "Tags," and type the desired tag name. Multiple tags can be applied simultaneously for refined results.

### SDK Filtering

The `runs.list()` function accepts tag filters:

```ts
import { runs } from "@trigger.dev/sdk";

for await (const run of runs.list({ tag: "user_123456", status: ["COMPLETED"] })) {
  console.log(run.id, run.taskIdentifier, run.finishedAt, run.tags);
}
```
