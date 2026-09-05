---
source: https://trigger.dev/docs/management/schedules/timezones
scraped: 2026-02-28
---

# Get Timezones

Retrieve all supported timezones that schedule tasks support.

## Endpoint

`GET /api/v1/timezones`

## Parameters

| Parameter | Location | Type | Required | Description |
|-----------|----------|------|----------|-------------|
| `excludeUtc` | query | boolean | No | Defaults to `false`. Set to `true` to exclude UTC from results. |

## Response

**200 - Successful request**

Returns a `GetTimezonesResult` object containing a `timezones` array of IANA timezone strings.

### Supported Timezone Regions

- **UTC**
- **Africa** — 50+ timezones (Abidjan, Accra, Addis_Ababa, etc.)
- **America** — 100+ timezones (Adak, Anchorage, Chicago, Denver, Los_Angeles, New_York, etc.)
- **Antarctica** — 11 timezones
- **Arctic** — Longyearbyen
- **Asia** — 60+ timezones (Bangkok, Dubai, Hong_Kong, Tokyo, etc.)
- **Atlantic** — 8 timezones
- **Australia** — 11 timezones
- **Europe** — 50+ timezones (London, Paris, Moscow, Berlin, etc.)
- **Indian** — 11 timezones
- **Pacific** — 40+ timezones (Auckland, Honolulu, Fiji, etc.)

## TypeScript SDK Example

```typescript
import { schedules } from "@trigger.dev/sdk";

const { timezones } = await schedules.timezones();
```
