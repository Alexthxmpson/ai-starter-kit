---
source: https://trigger.dev/docs/guides/examples/ffmpeg-video-processing
scraped: 2026-02-28
---

# Video Processing with FFmpeg

## Overview

This documentation covers video processing techniques using FFmpeg within Trigger.dev, including compression, audio extraction, and thumbnail generation.

## Setup Requirements

- A Trigger.dev-initialized project
- FFmpeg installed locally
- The FFmpeg build extension configured in `trigger.config.ts`
- The `@trigger.dev/build` package as a dev dependency

## Configuration

Add the FFmpeg extension to your build configuration:

```ts
import { ffmpeg } from "@trigger.dev/build/extensions/core";
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [ffmpeg()],
  },
});
```

Build extensions allow customization of the build process and resulting container images.

## Three Core Tasks

### 1. Video Compression

Reduces file size while maintaining quality by:
- Fetching video from a URL
- Applying H.264 codec with CRF 28 compression
- Reducing resolution and audio bitrate
- Uploading to R2 storage

### 2. Audio Extraction

Converts video audio to WAV format by:
- Fetching the source video
- Disabling video output
- Using PCM 16-bit encoding at 44.1 kHz
- Uploading the audio file to R2

### 3. Thumbnail Generation

Creates a still image from video at a specified timestamp by:
- Capturing a frame at the 5-second mark
- Generating a 320x240 JPEG
- Uploading to R2 storage

## Testing

All tasks accept a simple payload structure:

```json
{
  "videoUrl": "<video-url>"
}
```

For audio extraction, ensure the video contains an audio track to avoid task failures.

## Local Development

Install FFmpeg locally to test these tasks before deployment.
