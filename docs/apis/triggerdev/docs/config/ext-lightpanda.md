---
source: https://trigger.dev/docs/config/extensions/lightpanda
scraped: 2026-02-28
---

# Lightpanda Build Extension

## Overview

The Lightpanda build extension integrates the Lightpanda browser into Trigger.dev projects. To implement it, add the extension to your `trigger.config.ts` configuration file.

## Setup

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { lightpanda } from "@trigger.dev/build/extensions/lightpanda";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [lightpanda()],
  },
});
```

## Configuration Options

Two configuration options are available:

- **`version`**: Specifies the browser version to install (default: `"latest"`)
- **`disableTelemetry`**: Toggles telemetry collection (default: `false`)

### Example with Custom Options

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { lightpanda } from "@trigger.dev/build/extensions/lightpanda";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      lightpanda({
        version: "nightly",
        disableTelemetry: true,
      }),
    ],
  },
});
```

## Local Development

For development environments, you must first download the Lightpanda browser binary and ensure it's accessible in your system's `PATH`. Refer to the [Lightpanda installation guide](https://lightpanda.io/docs/getting-started/installation) for detailed setup instructions.

## Additional Resources

For hands-on implementation guidance, see the [Lightpanda usage guide](/guides/examples/lightpanda).
