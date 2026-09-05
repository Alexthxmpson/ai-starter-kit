---
source: https://trigger.dev/docs/management/schedules/delete
scraped: 2026-02-28
---

# Delete Schedule

Delete a schedule by its ID. This will only work on `IMPERATIVE` schedules that were created in the dashboard or using the imperative SDK functions like `schedules.create()`.

## Endpoint

`DELETE /api/v1/schedules/{schedule_id}`

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

**200 - Schedule deleted successfully**

**401 - Unauthorized request**

**404 - Resource not found**

## TypeScript SDK Example

```typescript
import { schedules } from "@trigger.dev/sdk";

await schedules.del(scheduleId);
```
