---
source: https://trigger.dev/docs/guides/examples/scrape-hacker-news
scraped: 2026-02-28
---

# Scrape the Top 3 Articles from Hacker News and Email Yourself a Summary Every Weekday

## Overview

This Trigger.dev example demonstrates how to automatically collect and summarize popular articles. The workflow accomplishes three main objectives:

1. Retrieve the top 3 articles from Hacker News
2. Generate concise summaries of each article
3. Deliver the summaries via email

## Key Technologies

The implementation leverages several integrated services:

- **Schedules**: Automation runs every weekday at 9 AM
- **Batch Triggering**: Separate child tasks process each article while the parent awaits completion
- **Idempotency Keys**: Prevent duplicate task execution
- **BrowserBase**: Provides proxy access for web scraping
- **Puppeteer**: Extracts article content from web pages
- **OpenAI API**: Generates article summaries using GPT-4o
- **Resend**: Sends formatted email notifications

## Setup Requirements

### Prerequisites

- An initialized Trigger.dev project
- Puppeteer library installed locally
- Active accounts on BrowserBase, OpenAI, and Resend

### Configuration

Update `trigger.config.ts` to include Puppeteer build extensions:

```typescript
import { defineConfig } from "@trigger.dev/sdk";
import { puppeteer } from "@trigger.dev/build/extensions/puppeteer";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [puppeteer()],
  },
});
```

### Environment Variables

Store these credentials locally in `.env`:

```
BROWSERBASE_API_KEY: "<your key>"
OPENAI_API_KEY: "<your key>"
RESEND_API_KEY: "<your key>"
```

## Implementation

### Parent Task

The scheduled task connects to BrowserBase, navigates to Hacker News, extracts article metadata, and triggers child tasks for processing. It collects summaries and dispatches the compiled email.

### Child Task

Individual article tasks handle scraping, content extraction, and summarization. The implementation includes request interception to skip resource-heavy assets like images and stylesheets, optimizing performance.

### Email Template

A React Email component formats the summaries into a professional HTML email with article titles linked to original sources.

## Important Note on Web Scraping

When web scraping, you MUST use a proxy to comply with our terms of service. Direct scraping of third-party websites without permission on Trigger.dev Cloud is prohibited and may result in account suspension.
