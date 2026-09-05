---
source: https://trigger.dev/docs/run-usage
scraped: 2026-02-28
---

# Run Usage

## Getting Run Cost and Duration

You can retrieve cost and duration metrics for the current run using the `usage.getCurrent()` method:

```ts
import { task, usage, wait } from "@trigger.dev/sdk";

export const heavyTask = task({
  id: "heavy-task",
  machine: {
    preset: "medium-2x",
  },
  run: async (payload, { ctx }) => {
    const result = await convertVideo(payload.videoUrl);

    let currentUsage = usage.getCurrent();
    /* currentUsage = {
        compute: {
          attempt: {
            costInCents: 0.01700,
            durationMs: 1000,
          },
          total: {
            costInCents: 0.0255,
            durationMs: 1500,
          },
        },
        baseCostInCents: 0.0025,
        totalCostInCents: 0.028,
      }
      */

    await wait.for({ seconds: 5 });

    currentUsage = usage.getCurrent();

    const result = await convertVideo(payload.videoUrl);

    currentUsage = usage.getCurrent();
  },
});
```

**Important Note:** "In Trigger.dev cloud we do not include time between attempts, before your code executes, or waits towards the compute cost or duration."

## Retrieving Run Data from Backend

Use the `runs.retrieve()` or `runs.list()` methods to access cost and duration information:

```ts
import { runs } from "@trigger.dev/sdk";

const run = await runs.retrieve("run-id");
console.log(run.costInCents, run.baseCostInCents, run.durationMs);
const totalCost = run.costInCents + run.baseCostInCents;
```

```ts
import { runs } from "@trigger.dev/sdk";

let totalCost = 0;
for await (const run of runs.list({ tag: "user_123456" })) {
  totalCost += run.costInCents + run.baseCostInCents;
  console.log(run.costInCents, run.baseCostInCents, run.durationMs);
}

console.log("Total cost", totalCost);
```

## Measuring Specific Code Blocks

Wrap code sections with `usage.measure()` to capture metrics for that block:

```ts
import { usage, logger } from "@trigger.dev/sdk";

const { result, compute } = await usage.measure(async () => {
  return {
    foo: "bar",
  };
});

logger.info("Result", { result, compute });
/* result = {
    foo: "bar"
  }
  compute = {
    costInCents: 0.01700,
    durationMs: 1000,
  }
*/
```

This method works within task `run` functions, lifecycle hooks, and functions called from them.
