---
source: https://trigger.dev/docs/guides/examples/puppeteer
scraped: 2026-02-28
---

# Puppeteer Integration with Trigger.dev

## Overview

This guide demonstrates three practical implementations of Puppeteer within Trigger.dev workflows, enabling automated browser automation tasks.

## Prerequisites

- A Trigger.dev initialized project
- Puppeteer installed locally

## Required Configuration

Add Puppeteer build extensions to `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { puppeteer } from "@trigger.dev/build/extensions/puppeteer";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [puppeteer()],
  },
});
```

Set the environment variable:

```bash
PUPPETEER_EXECUTABLE_PATH: "/usr/bin/google-chrome-stable"
```

## Three Example Tasks

### 1. Basic Title Logging

```ts
import { logger, task } from "@trigger.dev/sdk";
import puppeteer from "puppeteer";

export const puppeteerTask = task({
  id: "puppeteer-log-title",
  run: async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto("https://trigger.dev");
    const content = await page.title();
    logger.info("Content", { content });
    await browser.close();
  },
});
```

### 2. PDF Generation

Generate PDFs and upload to Cloudflare R2 storage using S3 client integration.

### 3. Web Content Scraping with Proxy

**Critical requirement**: When web scraping, you MUST use a proxy to comply with our terms of service.

```ts
import { logger, task } from "@trigger.dev/sdk";
import puppeteer from "puppeteer-core";

export const puppeteerScrapeWithProxy = task({
  id: "puppeteer-scrape-with-proxy",
  run: async () => {
    const browser = await puppeteer.connect({
      browserWSEndpoint: `wss://connect.browserbase.com?apiKey=${process.env.BROWSERBASE_API_KEY}`,
    });
    // Scraping logic follows...
  },
});
```

## Recommended Proxy Services

- [Browserbase](https://www.browserbase.com/)
- [Brightdata](https://brightdata.com/)
- [Browserless](https://www.browserless.io/)
- [Oxylabs](https://oxylabs.io/)
- [ScrapingBee](https://www.scrapingbee.com/)
- [Smartproxy](https://smartproxy.com/)
