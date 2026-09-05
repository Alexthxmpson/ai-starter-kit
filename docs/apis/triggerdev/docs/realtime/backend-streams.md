---
source: https://trigger.dev/docs/realtime/backend/streams
scraped: 2026-02-28
---

# Backend Streams

## Overview

The Streams API enables backend consumption of real-time streaming data from Trigger.dev tasks. This proves especially valuable for processing AI/LLM outputs, progress updates, and other continuous data emissions.

## Reading Streams

### Recommended Approach: Defined Streams

For maximum type safety, use defined streams:

```ts
import { streams } from "@trigger.dev/sdk";
import { aiStream } from "./trigger/streams";

async function consumeStream(runId: string) {
  const stream = await aiStream.read(runId);
  let fullText = "";

  for await (const chunk of stream) {
    console.log("Received chunk:", chunk);
    fullText += chunk;
  }

  console.log("Final text:", fullText);
}
```

### Direct Stream Reading

Alternative approach without defined streams:

```ts
import { streams } from "@trigger.dev/sdk";

async function consumeStream(runId: string) {
  const stream = await streams.read<string>(runId, "ai-output");

  for await (const chunk of stream) {
    console.log("Received chunk:", chunk);
  }
}
```

### Default Stream

Every run includes a default stream, making the stream key optional:

```ts
import { streams } from "@trigger.dev/sdk";

async function consumeDefaultStream(runId: string) {
  const stream = await streams.read<string>(runId);

  for await (const chunk of stream) {
    console.log("Received chunk:", chunk);
  }
}
```

## Stream Configuration Options

### Timeout Control

Set maximum wait duration for incoming data:

```ts
const stream = await aiStream.read(runId, {
  timeoutInSeconds: 120,
});

try {
  for await (const chunk of stream) {
    console.log("Received chunk:", chunk);
  }
} catch (error) {
  if (error.name === "TimeoutError") {
    console.log("Stream timed out");
  }
}
```

### Start Index for Resumption

Resume reading from a specific position:

```ts
const stream = await aiStream.read(runId, {
  startIndex: lastChunkIndex + 1,
});

for await (const chunk of stream) {
  console.log("Received chunk:", chunk);
}
```

### Abort Signal

Cancel stream reading using AbortController:

```ts
const controller = new AbortController();
setTimeout(() => controller.abort(), 30000);

const stream = await aiStream.read(runId, {
  signal: controller.signal,
});

try {
  for await (const chunk of stream) {
    console.log("Received chunk:", chunk);
    if (chunk.includes("STOP")) {
      controller.abort();
    }
  }
} catch (error) {
  if (error.name === "AbortError") {
    console.log("Stream was cancelled");
  }
}
```

### Combined Options

```ts
const stream = await aiStream.read(runId, {
  timeoutInSeconds: 300,
  startIndex: 0,
  signal: controller.signal,
});
```

## Practical Implementation Examples

### AI Response Consumption

```ts
async function consumeAIStream(runId: string) {
  const stream = await aiStream.read(runId, {
    timeoutInSeconds: 300,
  });

  let fullResponse = "";
  const chunks: string[] = [];

  for await (const chunk of stream) {
    chunks.push(chunk);
    fullResponse += chunk;
    console.log("Chunk received:", chunk);
  }

  return { fullResponse, chunks };
}
```

### Multiple Concurrent Streams

```ts
async function consumeMultipleStreams(runId: string) {
  const [aiData, progressData] = await Promise.all([
    consumeStream(aiStream, runId),
    consumeStream(progressStream, runId),
  ]);

  return { aiData, progressData };
}

async function consumeStream<T>(
  streamDef: { read: (runId: string) => Promise<AsyncIterableStream<T>> },
  runId: string
): Promise<T[]> {
  const stream = await streamDef.read(runId);
  const chunks: T[] = [];

  for await (const chunk of stream) {
    chunks.push(chunk);
  }

  return chunks;
}
```

### Server-Sent Events (SSE) Integration

```ts
import { streams } from "@trigger.dev/sdk";
import { aiStream } from "./trigger/streams";
import type { NextRequest } from "next/server";

export async function GET(request: NextRequest) {
  const runId = request.nextUrl.searchParams.get("runId");

  if (!runId) {
    return new Response("Missing runId", { status: 400 });
  }

  const stream = await aiStream.read(runId, {
    timeoutInSeconds: 300,
  });

  const encoder = new TextEncoder();
  const readableStream = new ReadableStream({
    async start(controller) {
      try {
        for await (const chunk of stream) {
          const data = `data: ${JSON.stringify({ chunk })}\n\n`;
          controller.enqueue(encoder.encode(data));
        }
        controller.close();
      } catch (error) {
        controller.error(error);
      }
    },
  });

  return new Response(readableStream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      "Connection": "keep-alive",
    },
  });
}
```

### Retry Implementation with Exponential Backoff

```ts
async function consumeStreamWithRetry(
  runId: string,
  maxRetries = 3
): Promise<string[]> {
  let lastChunkIndex = 0;
  const allChunks: string[] = [];
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      const stream = await aiStream.read(runId, {
        startIndex: lastChunkIndex,
        timeoutInSeconds: 120,
      });

      for await (const chunk of stream) {
        allChunks.push(chunk);
        lastChunkIndex++;
      }

      break;
    } catch (error) {
      attempt++;

      if (attempt >= maxRetries) {
        throw new Error(`Failed after ${maxRetries} attempts: ${error.message}`);
      }

      console.log(`Retry attempt ${attempt} after error:`, error.message);
      await new Promise((resolve) => setTimeout(resolve, 1000 * Math.pow(2, attempt)));
    }
  }

  return allChunks;
}
```

### Batch Processing

```ts
async function processStreamInBatches(runId: string, batchSize = 10) {
  const stream = await aiStream.read(runId);
  let batch: string[] = [];

  for await (const chunk of stream) {
    batch.push(chunk);

    if (batch.length >= batchSize) {
      await processBatch(batch);
      batch = [];
    }
  }

  if (batch.length > 0) {
    await processBatch(batch);
  }
}

async function processBatch(chunks: string[]) {
  console.log(`Processing batch of ${chunks.length} chunks`);
}
```

## Advanced: `runs.subscribeToRun()` with Streams

For scenarios requiring both run status tracking and stream data:

```ts
import { runs } from "@trigger.dev/sdk";
import type { myTask } from "./trigger/myTask";

async function subscribeToRunAndStreams(runId: string) {
  for await (const update of runs.subscribeToRun<typeof myTask>(runId).withStreams()) {
    switch (update.type) {
      case "run":
        console.log("Run update:", update.run.status);
        break;
      case "default":
        console.log("Stream chunk:", update.chunk);
        break;
    }
  }
}
```

**Note:** The documentation recommends "using `streams.read()` with defined streams for better type safety" over this approach for most scenarios.
