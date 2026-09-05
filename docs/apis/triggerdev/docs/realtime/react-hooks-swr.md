---
source: https://trigger.dev/docs/realtime/react-hooks/swr
scraped: 2026-02-28
---

# SWR Hooks

## Overview

SWR hooks leverage the [swr](https://swr.vercel.app/) library to retrieve and store data with single-fetch caching. These hooks work best when real-time synchronization isn't required.

> While SWR can be configured to poll for updates, Realtime hooks are recommended for most use-cases due to rate-limits.

## useRun Hook

This hook retrieves a specific run using its identifier.

### Basic Usage

```tsx
"use client";

import { useRun } from "@trigger.dev/react-hooks";

export function MyComponent({ runId }: { runId: string }) {
  const { run, error, isLoading } = useRun(runId);

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return <div>Run: {run.id}</div>;
}
```

### With Type Safety

```tsx
import { useRun } from "@trigger.dev/react-hooks";
import type { myTask } from "@/trigger/myTask";

export function MyComponent({ runId }: { runId: string }) {
  const { run, error, isLoading } = useRun<typeof myTask>(runId, {
    refreshInterval: 0,
  });

  if (isLoading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;

  return <div>Run: {run.id}</div>;
}
```

## Configuration Options

| Option | Type | Description |
|--------|------|-------------|
| `revalidateOnFocus` | boolean | Refresh data when window becomes active |
| `revalidateOnReconnect` | boolean | Refresh data when network connection restores |
| `refreshInterval` | number | Poll interval in milliseconds (not recommended) |

## Return Values

| Property | Type | Description |
|----------|------|-------------|
| `error` | Error | Error object if fetch fails |
| `isLoading` | boolean | Indicates ongoing data fetch |
| `isValidating` | boolean | Indicates ongoing revalidation |
| `isError` | boolean | Boolean error flag |
