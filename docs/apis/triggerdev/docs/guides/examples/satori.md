---
source: https://trigger.dev/docs/guides/examples/satori
scraped: 2026-02-28
---

# Generate OG Images using Satori

## Overview

This guide demonstrates using Trigger.dev to create dynamic Open Graph images via Vercel's Satori library. The implementation accepts a title and image URL, then produces an OG image with text overlay.

## Task Implementation

```tsx
// trigger/generateOgImage.ts
import { schemaTask } from "@trigger.dev/sdk";
import { z } from "zod";
import satori from "satori";
import sharp from "sharp";
import { join } from "path";
import fs from "fs/promises";

export const generateOgImage = schemaTask({
  id: "generate-og-image",
  schema: z.object({
    width: z.number().optional(),
    height: z.number().optional(),
    title: z.string(),
    imageUrl: z.string().url(),
  }),
  run: async (payload) => {
    // Load font
    const fontResponse = await fetch(
      "https://github.com/googlefonts/roboto/raw/main/src/hinted/Roboto-Regular.ttf"
    ).then((res) => res.arrayBuffer());

    // Fetch and convert image to base64
    const imageResponse = await fetch(payload.imageUrl);
    const imageBuffer = await imageResponse.arrayBuffer();
    const imageBase64 = `data:${
      imageResponse.headers.get("content-type") || "image/jpeg"
    };base64,${Buffer.from(imageBuffer).toString("base64")}`;

    const markup = (
      <div
        style={{
          width: payload.width ?? 1200,
          height: payload.height ?? 630,
          display: "flex",
          backgroundColor: "#121317",
          position: "relative",
          fontFamily: "Roboto",
        }}
      >
        <img
          src={imageBase64}
          width={payload.width ?? 1200}
          height={payload.height ?? 630}
          style={{
            objectFit: "cover",
          }}
        />
        <h1
          style={{
            fontSize: "60px",
            fontWeight: "bold",
            color: "#fff",
            margin: 0,
            position: "absolute",
            top: "50%",
            transform: "translateY(-50%)",
            left: "48px",
            maxWidth: "60%",
            textShadow: "0 2px 4px rgba(0,0,0,0.5)",
          }}
        >
          {payload.title}
        </h1>
      </div>
    );

    const svg = await satori(markup, {
      width: payload.width ?? 1200,
      height: payload.height ?? 630,
      fonts: [
        {
          name: "Roboto",
          data: fontResponse,
          weight: 400,
          style: "normal",
        },
      ],
    });

    const fileName = `og-${Date.now()}.jpg`;
    const tempDir = join(process.cwd(), "tmp");
    await fs.mkdir(tempDir, { recursive: true });
    const outputPath = join(tempDir, fileName);

    await sharp(Buffer.from(svg))
      .jpeg({
        quality: 90,
        mozjpeg: true,
      })
      .toFile(outputPath);

    return {
      filePath: outputPath,
      width: payload.width,
      height: payload.height,
    };
  },
});
```

## Testing the Task

Use this payload in the dashboard to test:

```json
{
  "title": "My Awesome OG image",
  "imageUrl": "<your-image-url>",
  "width": 1200,
  "height": 630
}
```

The width and height parameters are optional and default to 1200 and 630 respectively. Additional customization options are available through Satori's configuration.
