---
source: https://trigger.dev/docs/guides/examples/fal-ai-image-to-cartoon
scraped: 2026-02-28
---

# Convert an Image to a Cartoon Using Fal.ai

## Overview

This example task generates an image from a URL using Fal.ai and uploads it to Cloudflare R2.

## Prerequisites

- An existing project
- A Trigger.dev account with Trigger.dev initialized in your project
- A Fal.ai account
- A Cloudflare account with an R2 bucket setup

## Task Implementation

```typescript
import { logger, task } from "@trigger.dev/sdk";
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import * as fal from "@fal-ai/serverless-client";
import fetch from "node-fetch";
import { z } from "zod";

// Initialize fal.ai client
fal.config({
  credentials: process.env.FAL_KEY,
});

// Initialize S3-compatible client for Cloudflare R2
const s3Client = new S3Client({
  region: "auto",
  endpoint: process.env.R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID ?? "",
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY ?? "",
  },
});

export const FalResult = z.object({
  images: z.tuple([z.object({ url: z.string() })]),
});

export const falAiImageToCartoon = task({
  id: "fal-ai-image-to-cartoon",
  run: async (payload: { imageUrl: string; fileName: string }) => {
    logger.log("Converting image to cartoon", payload);

    const result = await fal.subscribe("fal-ai/flux/dev/image-to-image", {
      input: {
        prompt: "Turn the image into a cartoon in the style of a Pixar character",
        image_url: payload.imageUrl,
      },
      onQueueUpdate: (update) => {
        logger.info("Fal.ai processing update", { update });
      },
    });

    const $result = FalResult.parse(result);
    const [{ url: cartoonImageUrl }] = $result.images;

    const imageResponse = await fetch(cartoonImageUrl);
    const imageBuffer = await imageResponse.arrayBuffer().then(Buffer.from);

    const r2Key = `cartoons/${payload.fileName}`;
    const uploadParams = {
      Bucket: process.env.R2_BUCKET,
      Key: r2Key,
      Body: imageBuffer,
      ContentType: "image/png",
    };

    logger.log("Uploading cartoon to R2", { key: r2Key });
    await s3Client.send(new PutObjectCommand(uploadParams));

    logger.log("Cartoon uploaded to R2", { key: r2Key });

    return {
      originalUrl: payload.imageUrl,
      cartoonUrl: `File uploaded to storage at: ${r2Key}`,
    };
  },
});
```

## Testing the Task

Test your task from the Trigger.dev dashboard with the following JSON structure:

```json
{
  "imageUrl": "<image-url>",
  "fileName": "<file-name>"
}
```

Replace the placeholder values with the image URL to convert and desired filename for R2 storage.
