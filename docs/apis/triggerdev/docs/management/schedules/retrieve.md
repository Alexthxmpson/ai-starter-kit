---
source: https://trigger.dev/docs/management/schedules/retrieve
scraped: 2026-02-28
---

# Retrieve Schedule

Get a schedule by its ID.

## Endpoint

`GET /api/v1/schedules/{schedule_id}`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `schedule_id` | path | string | Yes | The ID of the schedule (e.g., `sched_1234`) |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Response

**200 - Successful request** — Returns a `ScheduleObject`

**401 - Unauthorized request**

**404 - Resource not found**

## ScheduleObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique ID prefixed with `sched_` (e.g., `sched_1234`) |
| `task` | string | ID of the scheduled task that will be triggered |
| `type` | string | `DECLARATIVE` or `IMPERATIVE` |
| `active` | boolean | Whether the schedule is active |
| `deduplicationKey` | string | Key to prevent duplicate schedules |
| `externalId` | string | External ID (e.g., user ID, org ID) |
| `generator.type` | string | `CRON` |
| `generator.expression` | string | Cron expression (e.g., `0 0 * * *`) |
| `generator.description` | string | Plain-English description |
| `timezone` | string | IANA timezone, defaults to UTC |
| `nextRun` | date-time | Next scheduled run time |
| `environments` | array | Array of `ScheduleEnvironment` objects |

### ScheduleEnvironment Schema

| Property | Type |
|----------|------|
| `id` | string |
| `type` | string |
| `userName` | string |

## TypeScript SDK Example

```typescript
import { schedules } from "@trigger.dev/sdk";

const schedule = await schedules.retrieve(scheduleId);
```
