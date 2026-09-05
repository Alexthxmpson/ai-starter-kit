---
source: https://trigger.dev/docs/triggering
scraped: 2026-02-28
---

# Triggering Tasks in Trigger.dev

## Overview

Tasks in Trigger.dev require explicit triggering to execute. The platform provides multiple methods depending on your context — whether you're triggering from a backend, within another task, or from a frontend.

## Backend Triggering Functions

From your backend code, you have two primary options:

**`tasks.trigger()`** initiates a single task run and "returns a handle you can use to fetch and manage the run." This method accepts a task type as a generic argument for full type safety, using only a type-level import to avoid bundling task code.

**`tasks.batchTrigger()`** processes multiple runs of one task simultaneously. You can pass options either globally or per-item within the batch.

**`batch.trigger()`** differs by allowing "multiple different tasks" to trigger in one call.

## Task-to-Task Triggering

When triggering from inside another task, you have access to waiting capabilities:

- **`yourTask.trigger()`** initiates without waiting
- **`yourTask.triggerAndWait()`** blocks until completion and returns the result
- **`yourTask.batchTriggerAndWait()`** handles multiple runs in parallel with result blocking

Results from wait operations return a "Result" type requiring success/failure checking via the `.ok` property, or you can use `.unwrap()` to directly access output or throw errors.

## Configuration Options

All trigger methods accept options objects. Key settings include:

**Delay**: Schedule execution at a later time using duration strings (`"1h"`, `"88s"`) or absolute timestamps. Delayed runs display as "Delayed" in the dashboard until enqueued.

**TTL**: Automatically expire runs that haven't started within a specified timeframe, defaulting to 10 minutes in development.

**Debounce**: Consolidate multiple triggers into a single delayed execution. Subsequent calls with the same debounce key "push" the existing run's execution time later. Options include `mode` ("leading" for first payload, "trailing" for last) and `maxDelay` to guarantee execution within a timeframe.

**Queue & Concurrency**: Override concurrency limits per trigger using `queue.name` and `queue.concurrencyLimit`. Use `concurrencyKey` to create separate queues per entity (e.g., per user).

**Idempotency**: The `idempotencyKey` option ensures a task triggers only once with the same key, useful for retriable parent tasks.

**Machine & Region**: Override default execution machine and geographic region when triggering.

## Batch Handling

For large batches, pass `AsyncIterable` or `ReadableStream` instead of arrays. This generates items on-demand without full memory loading.

When batch triggers fail, the SDK throws `BatchTriggerError` with properties including `isRateLimited`, `retryAfterMs`, `phase`, and `batchId` — enabling retry logic for rate-limited scenarios.

## Payload Constraints

Payloads exceed a hard limit of 10MB. Payloads larger than 512KB automatically upload to S3-compatible storage, with URLs stored in the database. The system automatically downloads payloads when tasks execute. For even larger data, upload to your storage and pass presigned URLs in the payload instead.
