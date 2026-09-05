---
source: https://trigger.dev/docs/limits
scraped: 2026-02-28
---

# Limits

## Overview

Trigger.dev enforces various hard and soft limits across its platform. Users can monitor their current usage through the **Limits** page in the dashboard.

## Concurrency Limits

Concurrent run capacity varies by pricing tier:

| Tier | Limit |
|------|-------|
| Free | 10 concurrent runs |
| Hobby | 25 concurrent runs |
| Pro | 100+ concurrent runs |

Pro tier subscribers can purchase additional concurrency through the dashboard.

## Rate Limits

The platform enforces an API rate limit of "1,500 requests per minute" for all tiers. Paid plan users may request higher limits.

To avoid hitting rate limits, use `batchTrigger()` instead of calling `trigger()` in loops. Batch operations support up to 1,000 tasks per call (SDK 4.3.1+) or 500 in earlier versions.

## Queued Tasks Per Queue

Maximum queued runs per individual queue:

| Tier | Development | Staging/Production |
|------|-------------|-------------------|
| Free | 500 | 10,000 |
| Hobby | 500 | 250,000 |
| Pro | 5,000 | 1,000,000 |

## Additional Limits

**Run TTL**: Maximum 14 days on Cloud (configurable in self-hosted deployments)

**Schedules**: Free (10), Hobby (100), Pro (1,000+) per project

**Projects**: 10 per organization across all tiers

**Preview Branches**: Free (unavailable), Hobby (5), Pro (20+)

**Realtime Connections**: Free (10), Hobby (50), Pro (500+) concurrent

**Task Payloads**: Single triggers max 3MB; batch items max 3MB each; outputs max 10MB

**Log Retention**: Free (1 day), Hobby (7 days), Pro (30 days)

**Team Members**: Free/Hobby (5), Pro (25+)
