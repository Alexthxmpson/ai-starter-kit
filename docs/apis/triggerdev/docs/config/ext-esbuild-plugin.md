---
source: https://trigger.dev/docs/config/extensions/esbuildPlugin
scraped: 2026-02-28
---

# esbuild Plugin

## Overview

The `esbuildPlugin` build extension enables developers to integrate existing or custom esbuild plugins into their build process.

## Usage

You can add esbuild plugins to your Trigger.dev configuration like this:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { esbuildPlugin } from "@trigger.dev/build/extensions";
import { sentryEsbuildPlugin } from "@sentry/esbuild-plugin";

export default defineConfig({
  project: "<project ref>",
  // Your other config settings...
  build: {
    extensions: [
      esbuildPlugin(
        sentryEsbuildPlugin({
          org: process.env.SENTRY_ORG,
          project: process.env.SENTRY_PROJECT,
          authToken: process.env.SENTRY_AUTH_TOKEN,
        }),
        // optional - only runs during the deploy command, and adds the plugin to the end of the list of plugins
        { placement: "last", target: "deploy" }
      ),
    ],
  },
});
```

## Configuration Options

The plugin accepts optional configuration parameters:

- **placement**: Specifies where the plugin should be positioned ("last" places it at the end)
- **target**: Restricts execution to specific commands (e.g., "deploy")

This approach allows you to enhance your build pipeline with third-party or custom esbuild plugins without modifying core build logic.
