---
source: https://trigger.dev/docs/realtime/react-hooks/overview
scraped: 2026-02-28
---

# React Hooks Overview

The `@trigger.dev/react-hooks` package enables easy interaction with the Trigger.dev Realtime API from React applications, allowing you to subscribe to real-time updates and trigger tasks from your frontend.

## Installation

Add the `@trigger.dev/react-hooks` package using your preferred package manager:

```bash
npm add @trigger.dev/react-hooks
```

```bash
pnpm add @trigger.dev/react-hooks
```

```bash
yarn install @trigger.dev/react-hooks
```

## Authentication

All hooks require authentication using a Public Access Token. Provide this token through the `accessToken` option:

```tsx
import { useRealtimeRun } from "@trigger.dev/react-hooks";

export function MyComponent({
  runId,
  publicAccessToken,
}: {
  runId: string;
  publicAccessToken: string;
}) {
  const { run, error } = useRealtimeRun(runId, {
    accessToken: publicAccessToken,
    baseURL: "https://your-trigger-dev-instance.com", // optional, only needed if you are self-hosting Trigger.dev
  });

  // ...
}
```

For additional information, consult the [authentication guide](/realtime/auth) about generating and managing tokens.

## Available Hooks

The package provides several hook categories:

- **[Triggering hooks](/realtime/react-hooks/triggering)** - Trigger tasks from your frontend application
- **[Subscribe hooks](/realtime/react-hooks/subscribe)** - Subscribe to runs, batches, metadata, and more
- **[Streams hooks](/realtime/react-hooks/streams)** - Subscribe to real-time streams from your tasks
- **[SWR hooks](/realtime/react-hooks/swr)** - Fetch data once and cache it using SWR

## SWR vs Realtime Hooks

Two hook styles are available: SWR hooks use the [swr](https://swr.vercel.app/) library for one-time data fetching with caching, while Realtime hooks use [Trigger.dev Realtime](/realtime) for real-time update subscriptions.

Due to rate-limiting and API design considerations, Realtime hooks are recommended for most scenarios, even though SWR can be configured for polling.
