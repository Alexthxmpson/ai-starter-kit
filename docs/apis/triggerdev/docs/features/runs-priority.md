---
source: https://trigger.dev/docs/runs/priority
scraped: 2026-02-28
---

# Priority

Set a priority when triggering a run to prioritize certain runs over others, ensuring faster processing. This is particularly useful for critical work or premium user runs during high queue times.

## How Priority Works

The priority value is a time offset in seconds that determines dequeue order. According to the documentation, "If you specify a priority of `10` the run will dequeue before runs that were triggered with no priority 8 seconds ago."

Here's an example:

```ts
// no priority = 0
await myTask.trigger({ foo: "bar" });

//... imagine 8s pass by

// this run will start before the run above that was triggered 8s ago (with no priority)
await myTask.trigger({ foo: "bar" }, { priority: 10 });
```

A priority value of `3600` would allow a run to dequeue ahead of runs with no priority triggered an hour earlier.

## Important Limitation

Priority settings only affect the ordering within your own organization's runs. As noted in the documentation, "Setting a high priority will not allow you to beat runs from other organizations. It will only affect the order of your own runs."
