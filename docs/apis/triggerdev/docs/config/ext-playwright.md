---
source: https://trigger.dev/docs/config/extensions/playwright
scraped: 2026-02-28
---

# Playwright Build Extension for Trigger.dev

## Overview

The Playwright build extension integrates Playwright with Trigger.dev's build and deployment process. It automatically handles browser installation and configuration without affecting the `dev` command.

## Key Features

- Automatic installation of Playwright and browser dependencies
- Configurable browser selection (chromium, firefox, webkit)
- Support for headless and non-headless modes
- Automatic version detection from project dependencies
- Optimized builds that install only necessary dependencies

## Basic Setup

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { playwright } from "@trigger.dev/build/extensions/playwright";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      playwright(),
    ],
  },
});
```

## Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `browsers` | Array | `["chromium"]` | Browsers to install: chromium, firefox, webkit |
| `headless` | Boolean | `true` | Run in headless mode; Xvfb auto-enables when false |
| `version` | String | Auto-detect | Specific Playwright version to use |

## Advanced Configuration

```ts
playwright({
  browsers: ["chromium", "webkit"],
  version: "1.43.1",
  headless: false,
})
```

## Environment Variables Set During Build

- `PLAYWRIGHT_BROWSERS_PATH`: `/ms-playwright`
- `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD`: `1`
- `PLAYWRIGHT_SKIP_BROWSER_VALIDATION`: `1`
- `DISPLAY`: `:99` (when headless mode is disabled)

## Troubleshooting Browser Download Issues

If builds fail with download errors, revert to version 1.40.0:

```ts
playwright({
  version: "1.40.0",
})
```

## Managing Browser Instances

Use middleware and locals to maintain browser instances across waits and resumes:

```ts
import { logger, tasks, locals } from "@trigger.dev/sdk";
import { chromium, type Browser } from "playwright";

const PlaywrightBrowserLocal = locals.create<{ browser: Browser }>("playwright-browser");

export function getBrowser() {
  return locals.getOrThrow(PlaywrightBrowserLocal).browser;
}

export function setBrowser(browser: Browser) {
  locals.set(PlaywrightBrowserLocal, { browser });
}

tasks.middleware("playwright-browser", async ({ next }) => {
  const browser = await chromium.launch();
  setBrowser(browser);

  try {
    await next();
  } finally {
    await browser.close();
  }
});

tasks.onWait("playwright-browser", async () => {
  const browser = getBrowser();
  await browser.close();
});

tasks.onResume("playwright-browser", async () => {
  const browser = await chromium.launch();
  setBrowser(browser);
});
```

This pattern ensures proper cleanup during waits, resumes, and task completion.
