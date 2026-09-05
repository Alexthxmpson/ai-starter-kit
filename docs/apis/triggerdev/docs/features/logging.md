---
source: https://trigger.dev/docs/logging
scraped: 2026-02-28
---

# Logging, Tracing & Metrics

## Logs

Standard console methods (`console.log()`, `console.error()`, etc.) work normally in task runs and appear in the run log. However, Trigger.dev recommends using the `logger` object for structured logging, which enables easier searching and filtering.

The structured logger supports multiple levels:

```ts
import { task, logger } from "@trigger.dev/sdk";

export const loggingExample = task({
  id: "logging-example",
  run: async (payload: { data: Record<string, string> }) => {
    logger.debug("Debug message", payload.data);
    logger.log("Log message", payload.data);
    logger.info("Info message", payload.data);
    logger.warn("You've been warned", payload.data);
    logger.error("Error message", payload.data);
  },
});
```

Each method accepts a message string and a key-value object for contextual data.

## Tracing and Spans

Trigger.dev uses OpenTelemetry for tracing under the hood, with automatic instrumentation for:

- Task triggers
- Task attempts
- HTTP requests

### Custom Traces

Use `logger.trace()` to wrap code sections and attach span attributes:

```ts
import { logger, task } from "@trigger.dev/sdk";

export const customTrace = task({
  id: "custom-trace",
  run: async (payload) => {
    const user = await logger.trace("fetch-user", async (span) => {
      span.setAttribute("user.id", "1");
      return { id: "1", name: "John Doe", fetchedAt: new Date() };
    });
  },
});
```

### Instrumentations

Additional instrumentations (like Prisma) can be added via configuration to automatically trace database queries and other operations.

## Metrics

Trigger.dev automatically collects system and runtime metrics for deployed tasks and provides a custom metrics API using OpenTelemetry.

### Custom Metrics API

Create instruments at module level (outside task functions) for reuse across runs:

```ts
import { task, logger, otel } from "@trigger.dev/sdk";

const meter = otel.metrics.getMeter("my-app");

const itemsProcessed = meter.createCounter("items.processed", {
  description: "Total number of items processed",
  unit: "items",
});

const itemDuration = meter.createHistogram("item.duration", {
  description: "Time spent processing each item",
  unit: "ms",
});

const queueDepth = meter.createUpDownCounter("queue.depth", {
  description: "Current queue depth",
  unit: "items",
});

export const processQueue = task({
  id: "process-queue",
  run: async (payload: { items: string[] }) => {
    queueDepth.add(payload.items.length);
    for (const item of payload.items) {
      const start = performance.now();
      const elapsed = performance.now() - start;
      itemsProcessed.add(1, { "item.type": "order" });
      itemDuration.record(elapsed, { "item.type": "order" });
      queueDepth.add(-1);
    }
  },
});
```

#### Instrument Types

| Instrument | Method | Purpose |
|:-----------|:-------|:--------|
| Counter | `meter.createCounter()` | Monotonically increasing values |
| Histogram | `meter.createHistogram()` | Value distributions |
| UpDownCounter | `meter.createUpDownCounter()` | Values that increase and decrease |

### Automatic System Metrics

Deployed tasks automatically collect (SDK 4.4.1+):

| Metric | Type | Unit | Description |
|:-------|:-----|:-----|:------------|
| `process.cpu.utilization` | gauge | ratio | CPU usage (0-1) |
| `process.cpu.time` | counter | seconds | CPU time consumed |
| `process.memory.usage` | gauge | bytes | Memory usage |
| `nodejs.event_loop.utilization` | gauge | ratio | Event loop usage (0-1) |
| `nodejs.event_loop.delay.p95` | gauge | seconds | p95 delay |
| `nodejs.event_loop.delay.max` | gauge | seconds | Maximum delay |
| `nodejs.heap.used` | gauge | bytes | V8 heap used |
| `nodejs.heap.total` | gauge | bytes | V8 heap total |

*Note: Dev mode only includes `process.*` and custom metrics.*

### Context Attributes

All metrics include run context tags: `run_id`, `task_identifier`, `attempt_number`, `machine_name`, `worker_version`, and `environment_type`.

### Querying and Exporting

Query metrics using TRQL or export to external services (Axiom, Honeycomb, Datadog, etc.) via telemetry exporters in `trigger.config.ts`.
