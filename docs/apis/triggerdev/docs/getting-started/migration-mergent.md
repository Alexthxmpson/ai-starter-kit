---
source: https://trigger.dev/docs/migration-mergent
scraped: 2026-02-28
---

# Migrating from Mergent to Trigger.dev

## Overview

Mergent is being integrated into Resend, making this an opportune time to transition your background jobs and scheduled tasks to Trigger.dev. The platform offers a modern, developer-centric approach to managing background work and scheduling.

## Advantages of Trigger.dev

The documentation highlights several benefits:

- **Straightforward async code**: Write tasks using familiar JavaScript/TypeScript patterns without learning specialized syntax
- **Built-in task management**: "Automatic retries, concurrency, and scheduling: Configure your tasks in your `trigger.config.ts` file"
- **Local-to-production parity**: Develop and test tasks locally with a dashboard that mirrors production
- **Flexible deployment**: Deploy to Trigger.dev Cloud or self-host based on your needs

## Migration Process

### Initial Setup

Start by creating an account at Trigger.dev Cloud, then establish an organization and project. The CLI provides local development capabilities:

```bash
npx trigger.dev@latest init
npx trigger.dev@latest dev
```

### Converting Tasks

**Mergent approach**: Tasks function as HTTP handlers registered through the Mergent dashboard.

**Trigger.dev approach**: Tasks are defined as functions deployed to managed workers:

```ts
import { task } from "@trigger.dev/sdk";

export const processVideoTask = task({
  id: "process-video",
  run: async (payload: { videoUrl: string }) => {
    const result = await processVideo(payload.videoUrl);
    return { success: true, processedUrl: result.url };
  },
});
```

Key improvements include type-safe payloads, automatic error handling, and elimination of HTTP endpoint management.

### Scheduled Tasks

Trigger.dev enables schedule definition within code:

```ts
import { schedules } from "@trigger.dev/sdk";

export const dailyReportTask = schedules.task({
  id: "daily-report",
  cron: "0 0 * * *",
  run: async () => {
    await sendDailyReport();
  },
});
```

### Task Triggering

Replace API calls with direct function invocation:

```ts
await processImageTask.trigger({
  imageUrl: "...",
  filters: ["blur"],
}, {
  delay: "5m",
});
```

This eliminates the need for HTTP endpoint exposure and provides cleaner integration with your codebase.
