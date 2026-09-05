---
source: https://trigger.dev/docs/management/schedules/list
scraped: 2026-02-28
---

# List Schedules

List all schedules with optional pagination support.

## Endpoint

`GET /api/v1/schedules`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `page` | query | integer | No | Page number of the schedule listing |
| `perPage` | query | integer | No | Number of schedules per page |

## Authentication

Bearer token using your project-specific Secret API key (starts with `tr_dev_`, `tr_prod_`, `tr_stg_`, etc.).

```typescript
import { configure } from "@trigger.dev/sdk";

configure({ accessToken: "tr_dev_1234" });
```

## Response

**200 - Successful request**

Returns a `ListSchedulesResult` object:

```yaml
ListSchedulesResult:
  type: object
  properties:
    data:
      type: array
      items:
        $ref: '#/components/schemas/ScheduleObject'
    pagination:
      type: object
      properties:
        currentPage:
          type: integer
        totalPages:
          type: integer
        count:
          type: integer
```

**401 - Unauthorized request**

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
| `generator.description` | string | Plain-English description (e.g., "Every day at midnight") |
| `timezone` | string | IANA timezone (e.g., `America/New_York`), defaults to UTC |
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

const allSchedules = await schedules.list();
```
