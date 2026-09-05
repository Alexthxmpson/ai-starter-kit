---
source: https://trigger.dev/docs/guides/examples/sharp-image-processing
scraped: 2026-02-28
---

# Process Images Using Sharp

## Overview

This documentation explains how to process and watermark images with the Sharp library in Trigger.dev, then store results in R2 compatible storage.

## Prerequisites

- A Trigger.dev initialized project
- Sharp library installed locally
- R2-compatible object storage (such as Cloudflare R2)

## Build Configuration

Add Sharp to your `trigger.config.ts` external packages:

```ts
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "<project ref>",
  build: {
    external: ["sharp"],
  },
});
```

> Any packages that install or build a native binary should be added to `external`.

## Key Capabilities

- Resizes JPEG images to 800x800 pixels
- Applies PNG watermarks positioned in bottom-right corner
- Uploads processed images to R2 storage

## Implementation Example

```ts
import sharp from "sharp";

await sharp(Buffer.from(imageBuffer))
  .resize(800, 800)
  .composite([
    {
      input: Buffer.from(watermarkBuffer),
      gravity: "southeast",
    },
  ])
  .jpeg()
  .toBuffer()
```

The implementation fetches both source and watermark images, processes them using Sharp, writes output to temporary storage, uploads to R2, then cleans up local files.

## Testing

Use this payload structure for dashboard testing:

```json
{
  "imageUrl": "<image-url.jpg>",
  "watermarkUrl": "<watermark-url.png>"
}
```

## Local Setup

Install Sharp locally to match your build configuration before testing.
