---
source: https://trigger.dev/docs/wait
scraped: 2026-02-28
---

# Wait: Overview

Trigger.dev provides waiting functionality that allows complex asynchronous tasks to execute without requiring additional task scheduling or polling mechanisms.

## Key Capabilities

The platform automatically pauses task execution when waits exceed a few seconds. Importantly, parent task checkpoints during subtask waits, and such periods don't consume compute resources. Similarly, time-based waits exceeding 5 seconds are checkpointed and excluded from usage calculations.

## Available Functions

| Function | Purpose |
| :--- | :--- |
| `wait.for()` | Pauses execution for a specified duration, such as one day |
| `wait.until()` | Pauses execution until a designated `Date` is reached |
| `wait.forToken()` | Suspends runs pending token completion |

These functions enable developers to structure tasks as continuous async code flows rather than relying on external scheduling or manual change detection systems.
