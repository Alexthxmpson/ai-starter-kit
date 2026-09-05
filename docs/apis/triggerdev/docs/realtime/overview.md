---
source: https://trigger.dev/docs/realtime/overview
scraped: 2026-02-28
---

# Realtime Overview

Trigger.dev's Realtime API enables real-time triggering, subscription, and monitoring of task runs. The system notifies users of run status changes, metadata updates, tag modifications, and real-time data streams.

## Subscription Scopes

Users can monitor runs across four different levels:

- Individual runs by ID
- Groups of runs sharing specific tags
- All runs within a batch
- Combined trigger-and-subscribe operations (frontend only)

## Update Categories

The Realtime API delivers comprehensive run objects with automatic updates for:

- Status transitions through execution phases
- Custom metadata for progress tracking
- Tag additions and removals
- Real-time data streams from tasks

## Implementation Approaches

**Frontend:** The documentation recommends React hooks for building dynamic interfaces that reflect run changes, useful for progress indicators and live dashboards.

**Backend:** Server-side SDKs enable subscription from backend systems, other tasks, or serverless environments—ideal for workflow automation, notifications, and database synchronization.

## Core Requirement

All subscriptions require authentication to ensure secure access to trigger and monitor runs.

The documentation index is available at https://trigger.dev/docs/llms.txt for discovering additional resources.
