---
source: https://trigger.dev/docs/config/extensions/puppeteer
scraped: 2026-02-28
---

# Puppeteer Integration Guide

## Overview

The Puppeteer build extension enables browser automation capabilities within Trigger.dev projects.

## Setup Instructions

### Configuration

Add the Puppeteer extension to your `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { puppeteer } from "@trigger.dev/build/extensions/puppeteer";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [puppeteer()],
  },
});
```

### Environment Variable

Configure the Chrome executable path in your Trigger.dev dashboard's Environment Variables page:

```bash
PUPPETEER_EXECUTABLE_PATH: "/usr/bin/google-chrome-stable"
```

## Next Steps

Consult the [Puppeteer example guide](/guides/examples/puppeteer) for detailed implementation instructions and project setup.
