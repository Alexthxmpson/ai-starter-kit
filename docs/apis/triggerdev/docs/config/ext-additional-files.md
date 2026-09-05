---
source: https://trigger.dev/docs/config/extensions/additionalFiles
scraped: 2026-02-28
---

# Additional Files Build Extension

The `additionalFiles` build extension enables copying extra files to your build directory during development and deployment.

## Setup

Import and configure the extension in your `trigger.config.ts`:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { additionalFiles } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  legacyDevProcessCwdBehaviour: false,
  build: {
    extensions: [additionalFiles({ files: ["./assets/**", "wrangler/wrangler.toml"] })],
  },
});
```

## How It Works

The extension copies specified files to the build directory using glob patterns. Output paths maintain the original file structure relative to your project root.

## Usage with Modern Config

When `legacyDevProcessCwdBehaviour: false` is set, you can reference files using `process.cwd()`:

```ts
import path from "node:path";

const interRegularFont = path.join(process.cwd(), "assets/Inter-Regular.ttf");
```

## Key Points

- The extension affects both `dev` and `deploy` commands
- "The root of the project is the directory that contains the trigger.config.ts file"
- Relative paths remain consistent across environments
- The recommendation is to disable legacy working directory behavior for production-like local development
