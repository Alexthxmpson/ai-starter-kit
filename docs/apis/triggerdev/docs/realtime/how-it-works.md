---
source: https://trigger.dev/docs/realtime/how-it-works
scraped: 2026-02-28
---

# Trigger.dev Realtime API — How It Works

## Overview

The Realtime API enables real-time monitoring of task execution. It's constructed atop "Electric SQL, an open-source PostgreSQL syncing engine," which Trigger.dev wraps to provide straightforward subscription capabilities.

## What Triggers Updates

Runs generate updates through three mechanisms:

- State transitions in the run lifecycle
- Addition or removal of run tags
- Changes to run metadata

## Core Subscription Methods

**Single Run Monitoring:**
Subscribe to individual runs post-trigger using `runs.subscribeToRun()`, which returns an async iterator yielding updates whenever the run changes.

**Tag-Based Subscriptions:**
Monitor all runs sharing specific tags with `runs.subscribeToRunsWithTag()`, useful for tracking user-specific or category-specific tasks.

**Batch Subscriptions:**
Track multiple runs triggered together via `runs.subscribeToBatch()` for batch operations.

## Metadata Integration

The metadata API lets you attach custom data to runs, enabling use cases like:

- Linking related resources
- Referencing users or organizations
- Displaying custom progress indicators

Metadata updates can be consumed through React hooks (frontend) or backend functions (server-side).

## Constraints

Concurrent subscription limits vary by pricing plan; exceeding them returns an error.

## Additional Resources

- Technical deep-dive: "How we built a real-time service that handles 20,000 updates per second"
- Frontend implementation: [React Hooks documentation](/realtime/react-hooks/overview)
- Server-side usage: [Backend functions guide](/realtime/backend/overview)
