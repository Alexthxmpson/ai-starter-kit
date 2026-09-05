---
source: https://trigger.dev/docs/realtime/backend/overview
scraped: 2026-02-28
---

# Backend Overview

The Trigger.dev backend API enables server-side subscription to runs and streams.

## Main Capabilities

The documentation covers three primary functional areas:

1. **Subscribe functions** - Async iterators for monitoring run updates
2. **Metadata** - Real-time run metadata management and observation
3. **Streams** - Consumption of real-time streaming data from tasks

## Authentication Options

The system supports dual authentication approaches:

- Server-side authentication via API keys (automatic within tasks)
- Client-side authentication through Public Access Tokens with defined scopes

Further details are available in the [authentication guide](/realtime/auth).

## Quick Start Example

```ts
import { runs, tasks } from "@trigger.dev/sdk";

// Trigger a task
const handle = await tasks.trigger("my-task", { some: "data" });

// Subscribe to real-time updates
for await (const run of runs.subscribeToRun(handle.id)) {
  console.log(`Run ${run.id} status: ${run.status}`);
}
```

This example shows triggering a task and then iterating through real-time status updates.

## Additional Resources

- Documentation index: https://trigger.dev/docs/llms.txt
- [Emitting streams from tasks](/tasks/streams)
- [Backend subscribe functions](/realtime/backend/subscribe)
- [Backend streams](/realtime/backend/streams)
