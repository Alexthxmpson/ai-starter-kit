---
source: https://trigger.dev/docs/guides/python/python-image-processing
scraped: 2026-02-28
---

# Python Image Processing Example

## Overview

This tutorial demonstrates integrating Trigger.dev with Python to process images from URLs using Pillow and upload results to S3-compatible storage.

## Key Requirements

- A Trigger.dev-initialized project
- Python installed locally
- S3-compatible storage credentials

## Core Components

**Build Configuration**: The `trigger.config.ts` file incorporates the Python extension with paths to `requirements.txt` and Python scripts:

```ts
import { pythonExtension } from "@trigger.dev/python/extension";
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  runtime: "node",
  project: "<your-project-ref>",
  build: {
    extensions: [
      pythonExtension({
        requirementsFile: "./requirements.txt",
        devPythonBinaryPath: `venv/bin/python`,
        scripts: ["src/python/**/*.py"],
      }),
    ],
  },
});
```

**Task Implementation**: The TypeScript task uses `python.runScript()` to execute image processing with parameters like dimensions, quality, and filters. It then uploads the processed image to S3 using the AWS SDK.

**Python Dependencies**:
- Pillow 10.2.0 (image processing)
- Requests 2.31.0 (HTTP operations)
- NumPy 1.26.3 (numerical operations)
- Optional: OpenCV for advanced processing

## Processing Capabilities

The `ImageProcessor` class handles:
- Image resizing with optional aspect ratio maintenance
- Format conversion (JPEG, PNG, WebP, GIF, AVIF)
- Quality optimization
- Filter application (brightness, contrast, sharpness, grayscale)

## Testing & Deployment

1. Set up virtual environment and install dependencies
2. Configure S3 credentials in `.env` or dashboard
3. Test via Trigger.dev dashboard with sample image URLs
4. Deploy using `npx trigger.dev@latest deploy`

## Example Input

```json
{
  "imageUrl": "<your-image-url>",
  "height": 1200,
  "width": 900,
  "quality": 90,
  "maintainAspectRatio": true,
  "outputFormat": "webp",
  "brightness": 1.2,
  "contrast": 1.1,
  "sharpness": 1.3,
  "grayscale": false
}
```
