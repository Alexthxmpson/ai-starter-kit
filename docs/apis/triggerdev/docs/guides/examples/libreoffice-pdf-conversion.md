---
source: https://trigger.dev/docs/guides/examples/libreoffice-pdf-conversion
scraped: 2026-02-28
---

# Convert Documents to PDF Using LibreOffice

This guide shows how to transform documents into PDFs with LibreOffice integration in Trigger.dev.

## Requirements

- A Trigger.dev project that's already set up
- LibreOffice installed locally
- Cloudflare R2 storage account with a bucket

## Setup Configuration

To deploy this solution, add LibreOffice through the build extension:

```ts
import { aptGet } from "@trigger.dev/build/extensions/core";
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      aptGet({
        packages: ["libreoffice"],
      }),
    ],
  },
});
```

Include `@trigger.dev/build` in your `devDependencies`.

## Implementation

The task handles three main operations:

1. **Retrieves** documents from a provided URL
2. **Converts** them to PDF format via LibreOffice
3. **Stores** the resulting PDF in R2

```ts
import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3";
import { task } from "@trigger.dev/sdk";
import libreoffice from "libreoffice-convert";
import { promisify } from "node:util";
import path from "path";
import fs from "fs";

const convert = promisify(libreoffice.convert);

const s3Client = new S3Client({
  region: "auto",
  endpoint: process.env.R2_ENDPOINT,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID ?? "",
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY ?? "",
  },
});

export const libreOfficePdfConvert = task({
  id: "libreoffice-pdf-convert",
  run: async (payload: { documentUrl: string }, { ctx }) => {
    if (ctx.environment.type !== "DEVELOPMENT") {
      process.env.LIBREOFFICE_PATH = "/usr/bin/libreoffice";
    }

    try {
      const inputPath = path.join(process.cwd(), `input_${Date.now()}.docx`);
      const outputPath = path.join(process.cwd(), `output_${Date.now()}.pdf`);

      const response = await fetch(payload.documentUrl);
      const buffer = Buffer.from(await response.arrayBuffer());
      fs.writeFileSync(inputPath, buffer);

      const inputFile = fs.readFileSync(inputPath);
      const pdfBuffer = await convert(inputFile, ".pdf", undefined);
      fs.writeFileSync(outputPath, pdfBuffer);

      const key = `converted-pdfs/output_${Date.now()}.pdf`;
      await s3Client.send(
        new PutObjectCommand({
          Bucket: process.env.R2_BUCKET,
          Key: key,
          Body: fs.readFileSync(outputPath),
        })
      );

      fs.unlinkSync(inputPath);
      fs.unlinkSync(outputPath);

      return { pdfLocation: key };
    } catch (error) {
      console.error("Error converting PDF:", error);
      throw error;
    }
  },
});
```

## Testing

Use this payload structure to test:

```json
{
  "documentUrl": "<a-document-url>"
}
```

Replace the placeholder with an actual document URL.

## Local Testing

Install LibreOffice on your machine before running local tests.
