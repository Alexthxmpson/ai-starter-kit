---
source: https://trigger.dev/docs/management/schedules/update
scraped: 2026-02-28
---

# Update Schedule

Update a schedule by its ID. This will only work on `IMPERATIVE` schedules that were created in the dashboard or using the imperative SDK functions like `schedules.create()`.

## Endpoint

`PUT /api/v1/schedules/{schedule_id}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `schedule_id` | path | string | Yes | The ID of the schedule |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Request Body

### UpdateScheduleOptions Schema

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `task` | string | Yes | The task ID to trigger |
| `cron` | string | Yes | Cron expression |
| `externalId` | string | No | External ID (e.g., user ID, org ID) |
| `timezone` | string | No | IANA timezone (e.g., `America/New_York`), defaults to `UTC` |

## Response

**200 - Schedule updated successfully** — Returns a `ScheduleObject`

**400 - Invalid request parameters**

**401 - Unauthorized**

**404 - Resource not found**

**422 - Unprocessable Entity**

## ScheduleObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique ID prefixed with `sched_` |
| `task` | string | ID of the scheduled task |
| `type` | string | `DECLARATIVE` or `IMPERATIVE` |
| `active` | boolean | Whether the schedule is active |
| `deduplicationKey` | string | The deduplication key |
| `externalId` | string | External ID |
| `generator.type` | string | `CRON` |
| `generator.expression` | string | Cron expression |
| `generator.description` | string | Plain-English description |
| `timezone` | string | IANA timezone |
| `nextRun` | date-time | Next scheduled run time |
| `environments` | array | Array of `ScheduleEnvironment` objects |

## TypeScript SDK Example

```typescript
import { schedules } from "@trigger.dev/sdk";

const updatedSchedule = await schedules.update(scheduleId, {
  task: 'my-updated-task',
  cron: '0 0 * * *'
});
```
