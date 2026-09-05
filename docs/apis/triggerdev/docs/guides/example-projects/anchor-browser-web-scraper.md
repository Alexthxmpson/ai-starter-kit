---
source: https://trigger.dev/docs/guides/example-projects/anchor-browser-web-scraper
scraped: 2026-02-28
---

# Automated Website Monitoring with Anchor Browser

## Overview

This guide demonstrates combining Trigger.dev's scheduling capabilities with Anchor Browser's AI-powered automation to monitor websites automatically. The example implementation tracks Broadway ticket prices daily at 5pm ET, identifying the cheapest available same-day shows through intelligent browser interaction.

## How It Works

The system operates through three main components:

1. **Trigger.dev** schedules and executes the monitoring task
2. **Anchor Browser** manages a remote browser session with AI capabilities
3. **AI Agent** analyzes web content using computer vision and NLP to extract ticket information

## Required Technology Stack

- **Node.js** (v18.2+)
- **Trigger.dev** - task scheduling and orchestration
- **Anchor Browser** - AI-powered browser automation
- **Playwright** - browser automation libraries (as external dependency)

## Implementation Example

### Broadway Ticket Monitor Task

The core task (`src/trigger/broadway-monitor.ts`) executes on schedule using this approach:

```ts
import { schedules } from "@trigger.dev/sdk";
import Anchorbrowser from "anchorbrowser";

export const broadwayMonitor = schedules.task({
  id: "broadway-ticket-monitor",
  cron: "0 21 * * *",
  run: async (payload, { ctx }) => {
    const client = new Anchorbrowser({
      apiKey: process.env.ANCHOR_BROWSER_API_KEY!,
    });

    let session;
    try {
      session = await client.sessions.create();
      console.log(`Session ID: ${session.data.id}`);
      console.log(`Live View URL: https://live.anchorbrowser.io?sessionId=${session.data.id}`);

      const response = await client.tools.performWebTask({
        sessionId: session.data.id,
        url: "https://www.tdf.org/discount-ticket-programs/tkts-by-tdf/tkts-live/",
        prompt: `Look for the "Broadway Shows" section on this page. Find the show with the absolute lowest starting price available right now and return the show name, current lowest price, and show time. Be very specific about the current price you see. Format as: Show: [name], Price: [exact current price], Time: [time]`,
      });

      const result = response.data.result?.result || response.data.result || response.data;

      if (result && typeof result === "string" && result.includes("Show:")) {
        console.log(`Best Broadway Deal Found!`);
        console.log(result);

        return {
          success: true,
          bestDeal: result,
          liveViewUrl: `https://live.anchorbrowser.io?sessionId=${session.data.id}`,
        };
      } else {
        console.log("No Broadway deals found today");
        return { success: true, message: "No deals found" };
      }
    } finally {
      if (session?.data?.id) {
        try {
          await client.sessions.delete(session.data.id);
        } catch (cleanupError) {
          console.warn("Failed to cleanup session:", cleanupError);
        }
      }
    }
  },
});
```

### Build Configuration

Configure Trigger.dev to handle Playwright dependencies properly (`trigger.config.ts`):

```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "proj_your_project_id_here",
  maxDuration: 3600,
  dirs: ["./src/trigger"],
  build: {
    external: ["playwright-core", "playwright", "chromium-bidi"],
  },
});
```

## Important Web Scraping Requirement

When web scraping, you MUST use a proxy to comply with Trigger.dev's terms of service. Direct scraping without site owner permission via Trigger.dev Cloud results in account suspension.

## Additional Resources

- [Anchor Browser documentation](https://anchorbrowser.io/docs)
- [GitHub repository](https://github.com/triggerdotdev/examples/tree/main/anchor-browser-web-scraper)
- [Trigger.dev examples](/guides/introduction)
