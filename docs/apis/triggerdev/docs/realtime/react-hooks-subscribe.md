---
source: https://trigger.dev/docs/realtime/react-hooks/subscribe
scraped: 2026-02-28
---

# Subscribing to Runs — React Hooks

## Overview

Trigger.dev offers React hooks for subscribing to real-time updates on runs, batches, and streams. These tools enable developers to display live progress indicators, status updates, and metadata changes in frontend applications without manual polling.

## Primary Hooks

### useRealtimeRun

This hook subscribes to a single run by its ID. Basic usage requires passing the run ID and an access token:

```tsx
const { run, error } = useRealtimeRun(runId, {
  accessToken: publicAccessToken,
});
```

The hook supports TypeScript generics for type-safe access to payload and output fields. It also accepts an `onComplete` callback to trigger actions when runs finish.

To reduce payload size, developers can use the `skipColumns` option to exclude large fields like `payload` and `output` when only monitoring status is needed.

### useRealtimeRunsWithTag

This hook subscribes to multiple runs sharing a specific tag. It supports the same typing and `skipColumns` options as `useRealtimeRun`. When multiple task types share the same tag, union types allow narrowing by `taskIdentifier`.

### useRealtimeBatch

This hook monitors all runs within a batch using the batch ID, useful for tracking batch progress collectively.

## Metadata-Driven UI Updates

All realtime hooks automatically reflect metadata changes. As tasks call methods like `metadata.set()` or `metadata.append()`, components re-render with updated data.

Reusable component patterns include:

- Progress bars with percentage displays
- Status indicators with log streams
- Multi-stage deployment monitors with visual stage tracking
- Type-safe metadata interfaces for enhanced developer experience

## Configuration Options

Common options include:

| Option | Description |
|--------|-------------|
| `accessToken` | Authentication token (required) |
| `baseURL` | Self-hosted instance support |
| `enabled` | Conditionally activate/deactivate subscriptions |
| `id` | Change subscription identity to switch targets dynamically |
| `skipColumns` | Reduce transmitted data by excluding specific fields |

Trigger.dev's realtime hooks eliminate the need for polling, enabling responsive, data-efficient frontend experiences for long-running background tasks.
