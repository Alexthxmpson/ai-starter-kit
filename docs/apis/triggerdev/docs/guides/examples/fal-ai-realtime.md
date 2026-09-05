---
source: https://trigger.dev/docs/guides/examples/fal-ai-realtime
scraped: 2026-02-28
---

# Generate an Image from a Prompt Using Fal.ai and Trigger.dev Realtime

## Overview

This documentation describes an example task that leverages Fal.ai to generate images from text prompts while displaying task progress through Trigger.dev Realtime integration.

## Requirements

- An active project setup
- A Trigger.dev account with the framework initialized in your codebase
- A Fal.ai account for image generation services

## Implementation

### Task Definition

The core task utilizes the Fal.ai serverless client to transform images based on text instructions:

```ts
import * as fal from "@fal-ai/serverless-client";
import { logger, schemaTask } from "@trigger.dev/sdk";
import { z } from "zod";

export const FalResult = z.object({
  images: z.tuple([z.object({ url: z.string() })]),
});

export const payloadSchema = z.object({
  imageUrl: z.string().url(),
  prompt: z.string(),
});

export const realtimeImageGeneration = schemaTask({
  id: "realtime-image-generation",
  schema: payloadSchema,
  run: async (payload) => {
    const result = await fal.subscribe("fal-ai/flux/dev/image-to-image", {
      input: {
        image_url: payload.imageUrl,
        prompt: payload.prompt,
      },
      onQueueUpdate: (update) => {
        logger.info("Fal.ai processing update", { update });
      },
    });

    const $result = FalResult.parse(result);
    const [{ url: cartoonUrl }] = $result.images;

    return {
      imageUrl: cartoonUrl,
    };
  },
});
```

### Testing

You can validate the task using this example payload:

```json
{
  "imageUrl": "https://static.vecteezy.com/system/resources/previews/005/857/332/non_2x/funny-portrait-of-cute-corgi-dog-outdoors-free-photo.jpg",
  "prompt": "Dress this dog for Christmas"
}
```
