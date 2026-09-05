---
source: https://trigger.dev/docs/realtime/react-hooks/triggering
scraped: 2026-02-28
---

# Trigger Hooks

> Triggering tasks from your frontend application.

For triggering tasks from the frontend, you must use "trigger" tokens. These can only be used once to trigger a task and are more secure than regular Public Access Tokens. See [Trigger Tokens](/realtime/auth#trigger-tokens-for-frontend-triggering-only) documentation.

## Available Hooks

- `useTaskTrigger` - Trigger a task from your frontend application.
- `useRealtimeTaskTrigger` - Trigger a task from your frontend application and subscribe to the run.
- `useRealtimeTaskTriggerWithStreams` - Trigger a task from your frontend application and subscribe to the run, and also receive any streams that are emitted by the task.

## useTaskTrigger

```tsx
"use client";

import { useTaskTrigger } from "@trigger.dev/react-hooks";
import type { myTask } from "@/trigger/myTask";

export function MyComponent({ publicAccessToken }: { publicAccessToken: string }) {
  const { submit, handle, error, isLoading } = useTaskTrigger<typeof myTask>("my-task", {
    accessToken: publicAccessToken, // this is the "trigger" token
  });

  if (error) {
    return <div>Error: {error.message}</div>;
  }

  if (handle) {
    return <div>Run ID: {handle.id}</div>;
  }

  return (
    <button onClick={() => submit({ foo: "bar" })} disabled={isLoading}>
      {isLoading ? "Loading..." : "Trigger Task"}
    </button>
  );
}
```

`useTaskTrigger` returns an object with the following properties:

| Property | Description |
|----------|-------------|
| `submit` | A function that triggers the task. Takes the payload as an argument. |
| `handle` | The run handle object. Contains the ID of the run and a Public Access Token. |
| `isLoading` | Boolean indicating whether the task is currently being triggered. |
| `error` | An error object if triggering failed. |

The `submit` function can also accept optional trigger options:

```tsx
submit({ foo: "bar" }, { tags: ["tag1", "tag2"] });
```

### Using the Handle Object

You can use the `handle` object to initiate a subsequent Realtime hook to subscribe to the run:

```tsx
"use client";

import { useTaskTrigger, useRealtimeRun } from "@trigger.dev/react-hooks";
import type { myTask } from "@/trigger/myTask";

export function MyComponent({ publicAccessToken }: { publicAccessToken: string }) {
  const { submit, handle, error, isLoading } = useTaskTrigger<typeof myTask>("my-task", {
    accessToken: publicAccessToken,
  });

  const { run, error: realtimeError } = useRealtimeRun(handle, {
    accessToken: handle?.publicAccessToken,
    enabled: !!handle, // Only subscribe to the run if the handle is available
  });

  if (error) {
    return <div>Error: {error.message}</div>;
  }

  if (handle) {
    return <div>Run ID: {handle.id}</div>;
  }

  if (realtimeError) {
    return <div>Error: {realtimeError.message}</div>;
  }

  if (run) {
    return <div>Run ID: {run.id}</div>;
  }

  return (
    <button onClick={() => submit({ foo: "bar" })} disabled={isLoading}>
      {isLoading ? "Loading..." : "Trigger Task"}
    </button>
  );
}
```

## useRealtimeTaskTrigger

Trigger a task from the frontend and subscribe to the run in one step using Realtime:

```tsx
"use client";

import { useRealtimeTaskTrigger } from "@trigger.dev/react-hooks";
import type { myTask } from "@/trigger/myTask";

export function MyComponent({ publicAccessToken }: { publicAccessToken: string }) {
  const { submit, run, error, isLoading } = useRealtimeTaskTrigger<typeof myTask>("my-task", {
    accessToken: publicAccessToken,
  });

  if (error) {
    return <div>Error: {error.message}</div>;
  }

  // This is the Realtime run object, which will automatically update when the run changes
  if (run) {
    return <div>Run ID: {run.id}</div>;
  }

  return (
    <button onClick={() => submit({ foo: "bar" })} disabled={isLoading}>
      {isLoading ? "Loading..." : "Trigger Task"}
    </button>
  );
}
```

## useRealtimeTaskTriggerWithStreams

Trigger a task from the frontend, subscribe to the run, and receive any streams emitted by the task:

```tsx
"use client";

import { useRealtimeTaskTriggerWithStreams } from "@trigger.dev/react-hooks";
import type { myTask } from "@/trigger/myTask";

type STREAMS = {
  openai: string; // this is the type of each "part" of the stream
};

export function MyComponent({ publicAccessToken }: { publicAccessToken: string }) {
  const { submit, run, streams, error, isLoading } = useRealtimeTaskTriggerWithStreams<
    typeof myTask,
    STREAMS
  >("my-task", {
    accessToken: publicAccessToken,
  });

  if (error) {
    return <div>Error: {error.message}</div>;
  }

  if (streams && run) {
    const text = streams.openai?.map((part) => part).join("");

    return (
      <div>
        <div>Run ID: {run.id}</div>
        <div>{text}</div>
      </div>
    );
  }

  return (
    <button onClick={() => submit({ foo: "bar" })} disabled={isLoading}>
      {isLoading ? "Loading..." : "Trigger Task"}
    </button>
  );
}
```
