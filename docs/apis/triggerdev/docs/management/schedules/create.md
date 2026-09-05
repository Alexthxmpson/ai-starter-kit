---
source: https://trigger.dev/docs/management/schedules/create
scraped: 2026-02-28
---

# Create Schedule

Create a new `IMPERATIVE` schedule based on the specified options.

## Endpoint

`POST /api/v1/schedules`

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Request Body

```json
{
  "task": "my-task",
  "cron": "0 0 * * *",
  "deduplicationKey": "my-schedule",
  "timezone": "America/New_York"
}
```

### CreateScheduleOptions Schema

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `task` | string | Yes | The task ID to trigger |
| `cron` | string | Yes | Cron expression |
| `deduplicationKey` | string | Yes | Key to prevent duplicate schedules |
| `externalId` | string | No | External ID (e.g., user ID, org ID) |
| `timezone` | string | No | IANA timezone (e.g., `America/New_York`), defaults to `UTC` |

## Response

**200 - Schedule created successfully** — Returns a `ScheduleObject`

**400 - Invalid request parameters**

**401 - Unauthorized**

**422 - Unprocessable Entity**

## ScheduleObject Schema

| Property | Type | Description |
|----------|------|-------------|
| `id` | string | Unique ID prefixed with `sched_` |
| `task` | string | ID of the scheduled task |
| `type` | string | `IMPERATIVE` (for created schedules) |
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

const schedule = await schedules.create({
  task: 'my-task',
  cron: '0 0 * * *',
  deduplicationKey: 'my-schedule',
  timezone: 'America/New_York'
});
```
