---
source: https://trigger.dev/docs/versioning
scraped: 2026-02-28
---

# Versioning

Trigger.dev employs atomic versioning to isolate task runs from code modifications. A version represents a specific snapshot of tasks at a particular moment.

## Version Identifiers

Version IDs follow this format:
- `20240313.1` - March 13th, 2024, version 1
- `20240313.2` - March 13th, 2024, version 2
- `20240314.1` - March 14th, 2024, version 1

Each identifier has two components:
- The date (in reverse format)
- The version number

The version number increments when multiple versions are created for the same date and environment, allowing identical version numbers across different environments.

## Version Locking

"When a task run starts it is locked to the latest version of the code (for that environment). Once locked it won't change versions, even if you deploy new versions."

Delayed runs become locked to whichever version is active upon execution, not at the time of queueing.

### Child Tasks and Version Locking

The `triggerAndWait()` and `batchTriggerAndWait()` functions lock child tasks to the parent task's version, ensuring alignment between parent expectations and child results. Non-waiting trigger functions don't apply version locks.

| Function | Parent Version | Child Version | Locked |
|----------|---|---|---|
| `trigger()` | `20240313.2` | Latest | No |
| `batchTrigger()` | `20240313.2` | Latest | No |
| `triggerAndWait()` | `20240313.2` | `20240313.2` | Yes |
| `batchTriggerAndWait()` | `20240313.2` | `20240313.2` | Yes |

## Local Development

Local development automatically generates new task versions following code changes, with each task run executing on its locked version through separate processes.

## Deployment

Each deployment creates fresh versions of all tasks within that environment.

## Retries and Reattempts

Task retries maintain the original run's version, assuming `maxAttempts` isn't set to 0.

## Replays

A replay creates a new task run using identical inputs but executing with the latest code version—useful for re-running tasks after bug fixes.
