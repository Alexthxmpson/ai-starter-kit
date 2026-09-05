---
source: https://trigger.dev/docs/realtime/react-hooks/streams
scraped: 2026-02-28
---

# Streams Hooks

> Subscribe to real-time streams from your tasks in React components

These hooks enable you to consume real-time streams from your tasks. Streams prove valuable for displaying AI/LLM outputs as they're generated, or any other real-time data from your tasks.

To learn how to emit streams from your tasks, see the [Realtime Streams](/tasks/streams) documentation.

## useRealtimeStream (Recommended)

Available in SDK version **4.1.0 or later**. This is the recommended way to consume streams in your React components.

The `useRealtimeStream` hook allows you to subscribe to a specific stream by its run ID and stream key. This hook is designed to work seamlessly with [defined streams](/tasks/streams#defining-typed-streams-recommended) for full type safety.

### Basic Usage

```tsx
"use client";

import { useRealtimeStream } from "@trigger.dev/react-hooks";

export function StreamViewer({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  const { parts, error } = useRealtimeStream<string>(runId, "ai-output", {
    accessToken: publicAccessToken,
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

### With Defined Streams

The recommended approach is to use defined streams for full type safety:

```tsx
"use client";

import { useRealtimeStream } from "@trigger.dev/react-hooks";
import { aiStream } from "@/app/streams";

export function StreamViewer({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  // Pass the defined stream directly - full type safety!
  const { parts, error } = useRealtimeStream(aiStream, runId, {
    accessToken: publicAccessToken,
    timeoutInSeconds: 600,
    onData: (chunk) => {
      console.log("New chunk:", chunk); // chunk is typed!
    },
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

### Streaming AI Responses

```tsx
"use client";

import { useRealtimeStream } from "@trigger.dev/react-hooks";
import { aiStream } from "@/trigger/streams";
import { Streamdown } from "streamdown";

export function AIStreamViewer({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  const { parts, error } = useRealtimeStream(aiStream, runId, {
    accessToken: publicAccessToken,
    timeoutInSeconds: 300,
  });

  if (error) return <div>Error: {error.message}</div>;
  if (!parts) return <div>Loading stream...</div>;

  const text = parts.join("");

  return (
    <div className="prose">
      <Streamdown isAnimating={true}>{text}</Streamdown>
    </div>
  );
}
```

### Options

```tsx
const { parts, error } = useRealtimeStream(streamOrRunId, streamKeyOrOptions, {
  accessToken: "pk_...",       // Required: Public access token
  baseURL: "https://api.trigger.dev", // Optional: Custom API URL
  timeoutInSeconds: 60,        // Optional: Timeout (default: 60)
  startIndex: 0,               // Optional: Start from specific chunk
  throttleInMs: 16,            // Optional: Throttle updates (default: 16ms)
  onData: (chunk) => {},       // Optional: Callback for each chunk
});
```

### Using Default Stream

You can omit the stream key to use the default stream:

```tsx
const { parts, error } = useRealtimeStream<string>(runId, {
  accessToken: publicAccessToken,
});
```

## useRealtimeRunWithStreams

> For new projects, we recommend using `useRealtimeStream` instead (available in SDK 4.1.0+). This hook is still supported for backward compatibility and use cases where you need to subscribe to both the run and all its streams at once.

The `useRealtimeRunWithStreams` hook allows you to subscribe to a run by its ID and also receive any streams that are emitted by the task. This is useful when you need to access both the run metadata and multiple streams simultaneously.

```tsx
"use client";

import { useRealtimeRunWithStreams } from "@trigger.dev/react-hooks";

export function MyComponent({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  const { run, streams, error } = useRealtimeRunWithStreams(runId, {
    accessToken: publicAccessToken,
  });

  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      <div>Run: {run.id}</div>
      <div>
        {Object.keys(streams).map((stream) => (
          <div key={stream}>Stream: {stream}</div>
        ))}
      </div>
    </div>
  );
}
```

### With Type Safety

```tsx
import { useRealtimeRunWithStreams } from "@trigger.dev/react-hooks";
import type { myTask } from "@/trigger/myTask";

type STREAMS = {
  openai: string; // this is the type of each "part" of the stream
};

export function MyComponent({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  const { run, streams, error } = useRealtimeRunWithStreams<typeof myTask, STREAMS>(runId, {
    accessToken: publicAccessToken,
  });

  if (error) return <div>Error: {error.message}</div>;

  const text = streams.openai?.map((part) => part).join("");

  return (
    <div>
      <div>Run: {run.id}</div>
      <div>{text}</div>
    </div>
  );
}
```

### With Object Stream Type

```tsx
import type { TextStreamPart } from "ai";
import type { myTask } from "@/trigger/myTask";

type STREAMS = { openai: TextStreamPart<{}> };

export function MyComponent({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  const { run, streams, error } = useRealtimeRunWithStreams<typeof myTask, STREAMS>(runId, {
    accessToken: publicAccessToken,
  });

  if (error) return <div>Error: {error.message}</div>;

  const text = streams.openai
    ?.filter((stream) => stream.type === "text-delta")
    ?.map((part) => part.text)
    .join("");

  return (
    <div>
      <div>Run: {run.id}</div>
      <div>{text}</div>
    </div>
  );
}
```

### AI SDK with Tools

```tsx
import { useRealtimeRunWithStreams } from "@trigger.dev/react-hooks";
import type { aiStreamingWithTools, STREAMS } from "./trigger/ai-streaming";

function MyComponent({ runId, publicAccessToken }: { runId: string; publicAccessToken: string }) {
  const { streams } = useRealtimeRunWithStreams<typeof aiStreamingWithTools, STREAMS>(runId, {
    accessToken: publicAccessToken,
  });

  if (!streams.openai) {
    return <div>Loading...</div>;
  }

  // streams.openai is an array of TextStreamPart
  const toolCall = streams.openai.find(
    (stream) => stream.type === "tool-call" && stream.toolName === "getWeather"
  );
  const toolResult = streams.openai.find((stream) => stream.type === "tool-result");
  const textDeltas = streams.openai.filter((stream) => stream.type === "text-delta");

  const text = textDeltas.map((delta) => delta.textDelta).join("");
  const weatherLocation = toolCall ? toolCall.args.location : undefined;
  const weather = toolResult ? toolResult.result.temperature : undefined;

  return (
    <div>
      <h2>OpenAI response:</h2>
      <p>{text}</p>
      <h2>Weather:</h2>
      <p>
        {weatherLocation
          ? `The weather in ${weatherLocation} is ${weather} degrees.`
          : "No weather data"}
      </p>
    </div>
  );
}
```

### Throttling Updates

```tsx
import { useRealtimeRunWithStreams } from "@trigger.dev/react-hooks";

export function MyComponent({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  const { run, streams, error } = useRealtimeRunWithStreams(runId, {
    accessToken: publicAccessToken,
    experimental_throttleInMs: 1000, // Throttle updates to once per second
  });

  if (error) return <div>Error: {error.message}</div>;

  return (
    <div>
      <div>Run: {run.id}</div>
      {/* Display streams */}
    </div>
  );
}
```

For the newer `useRealtimeStream` hook, use the `throttleInMs` option instead.
