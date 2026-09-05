---
source: https://trigger.dev/docs/config/extensions/ffmpeg
scraped: 2026-02-28
---

# FFmpeg Integration Guide

The documentation explains how to incorporate FFmpeg into your Trigger.dev project through a build extension.

## Basic Setup

To enable FFmpeg, add the extension to your configuration:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { ffmpeg } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [ffmpeg()],
  },
});
```

By default, this installs the FFmpeg version available through Debian's package manager.

## FFmpeg 7.x Installation

For newer functionality, you can specify a static build:

```ts
import { defineConfig } from "@trigger.dev/sdk";
import { ffmpeg } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [ffmpeg({ version: "7" })],
  },
});
```

## Environment Variables

The extension automatically exposes `FFMPEG_PATH` and `FFPROBE_PATH` environment variables, enabling compatibility with popular FFmpeg libraries like fluent-ffmpeg. Note that fluent-ffmpeg should be added to the `external` configuration in your `trigger.config.ts` file.

For complete setup instructions, the documentation references an FFmpeg video processing example guide.
