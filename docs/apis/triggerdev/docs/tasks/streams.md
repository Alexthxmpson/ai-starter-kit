---
source: https://trigger.dev/docs/tasks/streams
scraped: 2026-02-28
---

# Realtime Streams

Stream data in realtime from your Trigger.dev tasks to your frontend or backend applications.

## Overview

Realtime Streams v2 enables piping streaming data from Trigger.dev tasks to applications in real-time. This suits use cases like AI completions, progress updates, or continuous data flows.

Key improvements in v2 include:
- Unlimited stream length (previously 2,000 chunks)
- Unlimited active streams per run (previously 5)
- Automatic resumption on connection loss
- 28-day retention (previously 1 day)
- Multiple client streams to single stream support
- Enhanced dashboard visibility

## Requirements

Streams v2 requires SDK version 4.1.0 or later. Upgrade `@trigger.dev/sdk` and `@trigger.dev/react-hooks` packages accordingly.

## Enabling/Disabling v2

v2 automatically activates with SDK 4.1.0+. To opt out, configure via SDK:

```ts
import { auth } from "@trigger.dev/sdk";

auth.configure({
  future: {
    v2RealtimeStreams: false,
  },
});
```

Or set `TRIGGER_V2_REALTIME_STREAMS=0` environment variable.

## Limits Comparison

| Aspect | v1 | v2 |
|--------|----|----|
| Maximum stream length | 2,000 | Unlimited |
| Active streams per run | 5 | Unlimited |
| Stream TTL | 1 day | 28 days |
| Maximum stream size | 10MB | 300 MiB |

## Defining Typed Streams (Recommended)

Define streams once in a shared location using `streams.define()`:

```ts
import { streams, InferStreamType } from "@trigger.dev/sdk";

export const aiStream = streams.define<string>({
  id: "ai-output",
});

export type AIStreamPart = InferStreamType<typeof aiStream>;
```

Support any JSON-serializable type:

```ts
export const progressStream = streams.define<{ step: string; percent: number }>({
  id: "progress",
});
```

## Using Streams in Tasks

### Piping

```ts
import { task } from "@trigger.dev/sdk";
import { aiStream } from "./streams";

export const streamTask = task({
  id: "stream-task",
  run: async (payload: { prompt: string }) => {
    const stream = await getAIStream(payload.prompt);
    const { stream: readableStream, waitUntilComplete } = aiStream.pipe(stream);

    for await (const chunk of readableStream) {
      console.log("Received chunk:", chunk);
    }

    await waitUntilComplete();
    return { message: "Stream completed" };
  },
});
```

### Reading Streams

```ts
import { aiStream } from "./streams";

const stream = await aiStream.read(runId);

for await (const chunk of stream) {
  console.log(chunk); // fully typed
}
```

With options:

```ts
const stream = await aiStream.read(runId, {
  timeoutInSeconds: 60,
  startIndex: 10,
});
```

### Appending Chunks

```ts
import { task } from "@trigger.dev/sdk";
import { progressStream, logStream } from "./streams";

export const appendTask = task({
  id: "append-task",
  run: async (payload) => {
    await logStream.append("Processing started");
    await progressStream.append({ step: "Initialization", percent: 0 });
    // ... work ...
    await progressStream.append({ step: "Complete", percent: 100 });
  },
});
```

### Writing Multiple Chunks

```ts
import { task } from "@trigger.dev/sdk";
import { logStream } from "./streams";

export const writerTask = task({
  id: "writer-task",
  run: async (payload) => {
    const { waitUntilComplete } = logStream.writer({
      execute: ({ write, merge }) => {
        write("Chunk 1");
        write("Chunk 2");

        const additionalStream = ReadableStream.from(["Chunk 3", "Chunk 4"]);
        merge(additionalStream);
      },
    });

    await waitUntilComplete();
  },
});
```

## Using Streams in React

### With Defined Streams (Recommended)

```tsx
"use client";

import { useRealtimeStream } from "@trigger.dev/react-hooks";
import { aiStream } from "@/app/streams";

export function StreamViewer({ accessToken, runId }) {
  const { parts, error } = useRealtimeStream(aiStream, runId, {
    accessToken,
    timeoutInSeconds: 600,
  });

  if (error) return <div>Error: {error.message}</div>;
  if (!parts) return <div>Loading...</div>;

  return (
    <div>
      {parts.map((part, i) => (
        <span key={i}>{part}</span>
      ))}
    </div>
  );
}
```

### Hook Options

```tsx
const { parts, error } = useRealtimeStream(streamDef, runId, {
  accessToken: "pk_...",           // Required
  baseURL: "https://api.trigger.dev", // Optional
  timeoutInSeconds: 60,             // Optional
  startIndex: 0,                    // Optional
  throttleInMs: 16,                 // Optional
  onData: (chunk) => {},            // Optional
});
```

## Targeting Different Runs

Pipe streams to parent, root, or specific run IDs:

```ts
import { task } from "@trigger.dev/sdk";
import { logStream } from "./streams";

export const childTask = task({
  id: "child-task",
  run: async (payload, { ctx }) => {
    const stream = getDataStream();

    logStream.pipe(stream, { target: "parent" });
    logStream.pipe(stream, { target: "root" });
    logStream.pipe(stream, { target: payload.otherRunId });
  },
});
```

## Streaming from Outside Tasks

Stream from external sources like Next.js API routes:

```ts
import { streams } from "@trigger.dev/sdk";
import { openai } from "@ai-sdk/openai";
import { streamText } from "ai";

export async function POST(req: Request) {
  const { messages, runId } = await req.json();

  const result = streamText({
    model: openai("gpt-4o"),
    messages,
  });

  const { stream } = streams.pipe("ai-stream", result.toUIMessageStream(), {
    target: runId,
  });

  return new Response(stream as any, {
    headers: { "Content-Type": "text/event-stream" },
  });
}
```

## Direct Methods (Not Recommended)

Without defining streams, specify keys directly each time:

```ts
const { stream: readableStream, waitUntilComplete } = streams.pipe("ai-output", stream);
await waitUntilComplete();

const stream = await streams.read(runId, "ai-output");

await streams.append("logs", "Processing started");
```

## Default Stream

Use the implicit default stream to skip specifying keys:

```ts
const { waitUntilComplete } = streams.pipe(stream);
const readStream = await streams.read(runId);
```

## Complete Example: AI Streaming

### Stream Definition

```ts
// app/streams.ts
import { streams, InferStreamType } from "@trigger.dev/sdk";
import { UIMessageChunk } from "ai";

export const aiStream = streams.define<UIMessageChunk>({
  id: "ai",
});

export type AIStreamPart = InferStreamType<typeof aiStream>;
```

### Task Implementation

```ts
// trigger/ai-task.ts
import { task } from "@trigger.dev/sdk";
import { openai } from "@ai-sdk/openai";
import { streamText } from "ai";
import { aiStream } from "@/app/streams";

export const generateAI = task({
  id: "generate-ai",
  run: async (payload: { prompt: string }) => {
    const result = streamText({
      model: openai("gpt-4o"),
      prompt: payload.prompt,
    });

    const { waitUntilComplete } = aiStream.pipe(result.toUIMessageStream());
    await waitUntilComplete();

    return { success: true };
  },
});
```

### Frontend Component

```tsx
// components/ai-stream.tsx
"use client";

import { useRealtimeStream } from "@trigger.dev/react-hooks";
import { aiStream } from "@/app/streams";

export function AIStream({ accessToken, runId }) {
  const { parts, error } = useRealtimeStream(aiStream, runId, {
    accessToken,
    timeoutInSeconds: 300,
  });

  if (error) return <div>Error: {error.message}</div>;
  if (!parts) return <div>Loading...</div>;

  return (
    <div className="prose">
      {parts.map((part, i) => (
        <span key={i}>{part}</span>
      ))}
    </div>
  );
}
```

## Migration from v1

### Step 1: Create Streams Definition

```ts
// app/streams.ts
import { streams, InferStreamType } from "@trigger.dev/sdk";

export const myStream = streams.define<string>({
  id: "my-stream",
});

export type MyStreamPart = InferStreamType<typeof myStream>;
```

### Step 2: Update Tasks

```ts
// Before (v1)
import { metadata, task } from "@trigger.dev/sdk";

export const myTask = task({
  id: "my-task",
  run: async (payload) => {
    const stream = getDataStream();
    await metadata.stream("my-stream", stream);
  },
});
```

```ts
// After (v2)
import { task } from "@trigger.dev/sdk";
import { myStream } from "./streams";

export const myTask = task({
  id: "my-task",
  run: async (payload) => {
    const stream = getDataStream();
    const { waitUntilComplete } = myStream.pipe(stream);
    await waitUntilComplete();
  },
});
```

### Step 3: Update React Components

```tsx
// After
import { myStream } from "@/app/streams";

const { parts, error } = useRealtimeStream(myStream, runId, {
  accessToken,
});
```

## Reliability Features

v2 automatically handles:
- Automatic resumption after connection loss
- Zero data loss for network issues
- Idempotent duplicate chunk handling

No code changes needed — improvements work automatically.

## Dashboard Integration

View streams in the Trigger.dev dashboard to:
- Monitor stream data generation in real-time
- Inspect historical stream data for completed runs
- Debug streaming issues with full chunk delivery visibility

## Best Practices

1. Always use `streams.define()` for organization, type safety, and reusability
2. Export stream types with `InferStreamType` for frontend components
3. Handle errors gracefully when reading streams in UI
4. Set appropriate timeouts based on use case (AI tasks may need longer durations)
5. Target parent runs when orchestrating with child tasks
6. Throttle frontend updates using `throttleInMs` to prevent excessive re-renders
7. Use descriptive stream IDs like "ai-output" or "progress"

## Troubleshooting

### Stream Not Appearing in Dashboard

- Verify v2 is enabled via future flag or environment variable
- Confirm your task writes to the stream
- Check stream key consistency between writing and reading

### Stream Timeout Errors

- Increase `timeoutInSeconds` in `read()` or `useRealtimeStream()` calls
- Ensure stream source produces data actively
- Verify network connectivity to Trigger.dev

### Missing Chunks

- v2 automatically prevents chunk loss through resumption
- Verify correct stream key usage
- Check `startIndex` option if expecting specific chunks
