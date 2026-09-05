---
source: https://trigger.dev/docs/management/schedules/deactivate
scraped: 2026-02-28
---

# Deactivate Schedule

Deactivate a schedule by its ID. This will only work on `IMPERATIVE` schedules that were created in the dashboard or using the imperative SDK functions like `schedules.create()`.

## Endpoint

`POST /api/v1/schedules/{schedule_id}/deactivate`

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

## Response

**200 - Schedule updated successfully** — Returns a `ScheduleObject`

**401 - Unauthorized request**

**404 - Resource not found**

## ScheduleObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique ID prefixed with `sched_` |
| `task` | string | ID of the scheduled task |
| `type` | string | `DECLARATIVE` or `IMPERATIVE` |
| `active` | boolean | Whether the schedule is active (will be `false` after deactivation) |
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

const schedule = await schedules.deactivate(scheduleId);
```
