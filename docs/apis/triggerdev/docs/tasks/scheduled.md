---
source: https://trigger.dev/docs/tasks/scheduled
scraped: 2026-02-28
---

# Scheduled Tasks (Cron) - Trigger.dev Documentation

## Overview

Scheduled tasks in Trigger.dev enable recurring task execution using cron syntax. The documentation emphasizes that scheduled tasks are specifically for recurring patterns; for one-time future executions, the delay option should be used instead.

## Defining Scheduled Tasks

A scheduled task accepts a payload object with several properties:

- **timestamp**: UTC date when the task was scheduled to run
- **lastTimestamp**: UTC date of the previous execution (undefined if never run)
- **timezone**: IANA format timezone string (defaults to "UTC")
- **scheduleId**: Identifier for the specific schedule triggering the task
- **externalId**: Optional external identifier (e.g., user ID) provided during schedule creation
- **upcoming**: Array of the next 5 scheduled execution dates

Tasks must be placed in a `/trigger` folder and cannot execute until a schedule is attached.

## Attaching Schedules

Two approaches exist for schedule attachment:

### Declarative Schedules
Defined directly in task code via the `cron` property. These synchronize automatically during `dev` or `deploy` commands. Configuration supports optional timezone specification and environment filtering (PRODUCTION, STAGING, PREVIEW, DEVELOPMENT).

### Imperative Schedules
Created dynamically through the dashboard or SDK using `schedules.create()`. These enable per-user or per-tenant scheduling without code redeployment. The `deduplicationKey` parameter prevents duplicate schedules.

## Cron Syntax Support

The system supports standard five-field cron format (minute, hour, day of month, month, day of week) without seconds. Special characters include:
- "L" for last occurrence (e.g., "1L" = last Monday, "L" = last day of month)
- Ranges and step values follow standard cron conventions

## SDK Management Functions

The `schedules` namespace provides these operations:

| Function | Purpose |
|----------|---------|
| `create()` | Create new schedules with deduplication |
| `retrieve()` | Fetch specific schedule details |
| `list()` | Get all schedules |
| `update()` | Modify existing schedules |
| `deactivate()` | Temporarily disable schedules |
| `activate()` | Re-enable schedules |
| `del()` | Permanently remove schedules |
| `timezones()` | Retrieve supported timezone list |

## Execution Conditions

Scheduled tasks trigger only when:
- Development: Dev CLI is actively running
- Staging/Production: Task exists in the current deployment (latest version)

## Multi-Tenant Implementation

Using `externalId`, applications can create user-specific schedules, enabling patterns like per-user reminders or notifications. The deduplication key prevents duplicate schedule creation for the same user.

## Testing

The dashboard Test page allows scheduled task validation, with `scheduleId` appearing as "sched_1234" during test runs.
