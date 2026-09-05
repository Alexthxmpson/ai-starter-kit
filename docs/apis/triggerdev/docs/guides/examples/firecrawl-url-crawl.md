---
source: https://trigger.dev/docs/guides/examples/firecrawl-url-crawl
scraped: 2026-02-28
---

# Crawl a URL using Firecrawl

## Overview

Firecrawl is a website crawling tool that extracts clean, LLM-ready markdown from web pages. The documentation provides two implementation approaches using Trigger.dev.

## Prerequisites

- A Trigger.dev project (see quick-start guide)
- Active Firecrawl account

## Example 1: Website Crawl

This approach processes an entire website and returns structured crawl data:

```ts
import Firecrawl from "@mendable/firecrawl-js";
import { task } from "@trigger.dev/sdk";

const firecrawlClient = new Firecrawl({
  apiKey: process.env.FIRECRAWL_API_KEY,
});

export const firecrawlCrawl = task({
  id: "firecrawl-crawl",
  run: async (payload: { url: string }) => {
    const { url } = payload;

    const crawlResult = await firecrawlClient.crawl(url, {
      limit: 100,
      scrapeOptions: {
        formats: ["markdown", "html"],
      },
    });

    if (crawlResult.status === "failed") {
      throw new Error(`Failed to crawl: ${url}`);
    }

    return { data: crawlResult };
  },
});
```

**Testing:** Provide the target URL via the Trigger.dev dashboard.

## Example 2: Single URL Scrape

This approach extracts content from a single page:

```ts
import Firecrawl from "@mendable/firecrawl-js";
import { task } from "@trigger.dev/sdk";

const firecrawlClient = new Firecrawl({
  apiKey: process.env.FIRECRAWL_API_KEY,
});

export const firecrawlScrape = task({
  id: "firecrawl-scrape",
  run: async (payload: { url: string }) => {
    const { url } = payload;

    const scrapeResult = await firecrawlClient.scrape(url, {
      formats: ["markdown", "html"],
    });

    return { data: scrapeResult };
  },
});
```

**Testing:** Provide the target URL via the Trigger.dev dashboard.
