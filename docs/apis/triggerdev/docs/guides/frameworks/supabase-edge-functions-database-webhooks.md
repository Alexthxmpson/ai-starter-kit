---
source: https://trigger.dev/docs/guides/frameworks/supabase-edge-functions-database-webhooks
scraped: 2026-02-28
---

# Triggering Tasks from Supabase Database Webhooks

## Overview

This guide demonstrates creating an automated workflow where database changes trigger background tasks. When a new row with a video URL is added to a Supabase table, an Edge Function activates a Trigger.dev task that extracts audio, transcribes it, and updates the original record.

## Architecture Flow

The workflow consists of three main components:

1. **Database Webhook** - Monitors the `video_transcriptions` table for new insertions
2. **Supabase Edge Function** - Receives webhook notifications and forwards them to Trigger.dev
3. **Trigger.dev Task** - Processes video files through FFmpeg and Deepgram for transcription

## Prerequisites

- Supabase CLI (version 1.123.4+)
- Docker Desktop (required for Edge Function deployment)
- TypeScript installed
- Active accounts with Trigger.dev and Deepgram
- Deepgram API key

## Setup Steps

### Initialize Your Project

```bash
npx trigger.dev@latest init
```

When prompted, select "None" for example tasks as you'll create a custom one.

### Create Database Table

In the Supabase dashboard:
1. Navigate to Table Editor
2. Create table named `video_transcriptions`
3. Add columns:
   - `video_url` (text)
   - `transcription` (text)

### Generate TypeScript Types

```bash
supabase gen types --lang=typescript --project-id <project-ref> --schema public > database.types.ts
```

### Create the Transcription Task

File: `/trigger/videoProcessAndUpdate.ts`

Install required dependencies:

```bash
npm install @deepgram/sdk @supabase/supabase-js fluent-ffmpeg
```

```typescript
import { createClient as createDeepgramClient } from "@deepgram/sdk";
import { createClient as createSupabaseClient } from "@supabase/supabase-js";
import { logger, task } from "@trigger.dev/sdk";
import ffmpeg from "fluent-ffmpeg";
import fs from "fs";
import { Readable } from "node:stream";
import os from "os";
import path from "path";
import { Database } from "../../database.types";

const supabase = createSupabaseClient<Database>(
  process.env.SUPABASE_PROJECT_URL as string,
  process.env.SUPABASE_SERVICE_ROLE_KEY as string
);

const deepgram = createDeepgramClient(process.env.DEEPGRAM_SECRET_KEY);

export const videoProcessAndUpdate = task({
  id: "video-process-and-update",
  run: async (payload: { videoUrl: string; id: number }) => {
    const { videoUrl, id } = payload;
    logger.log(`Processing video at URL: ${videoUrl}`);

    const tempDirectory = os.tmpdir();
    const outputPath = path.join(tempDirectory, `audio_${Date.now()}.wav`);

    const response = await fetch(videoUrl);

    await new Promise((resolve, reject) => {
      if (!response.body) {
        return reject(new Error("Failed to fetch video"));
      }

      ffmpeg(Readable.from(response.body))
        .outputOptions([
          "-vn",
          "-acodec pcm_s16le",
          "-ar 44100",
          "-ac 2",
        ])
        .output(outputPath)
        .on("end", resolve)
        .on("error", reject)
        .run();
    });

    logger.log(`Audio extracted from video`, { outputPath });

    const { result, error } = await deepgram.listen.prerecorded.transcribeFile(
      fs.readFileSync(outputPath),
      {
        model: "nova-2",
        smart_format: true,
        diarize: true,
      }
    );

    if (error) {
      throw error;
    }

    const transcription = result.results.channels[0].alternatives[0].paragraphs?.transcript;

    logger.log(`Transcription: ${transcription}`);
    fs.unlinkSync(outputPath);

    const { error: updateError } = await supabase
      .from("video_transcriptions")
      .update({ transcription: transcription })
      .eq("id", id);

    if (updateError) {
      throw new Error(`Failed to update transcription: ${updateError.message}`);
    }

    return {
      message: `Summary of the audio: ${transcription}`,
      result,
    };
  },
});
```

### Configure FFmpeg Build Extension

Update `trigger.config.ts`:

```typescript
import { ffmpeg } from "@trigger.dev/build/extensions/core";
import { defineConfig } from "@trigger.dev/sdk";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [ffmpeg()],
  },
});
```

### Add Environment Variables

In Trigger.dev project dashboard, add:
- `DEEPGRAM_SECRET_KEY`
- `SUPABASE_PROJECT_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

### Deploy Task

```bash
npx trigger.dev@latest deploy
```

## Set Up Supabase Edge Function

### Add Trigger.dev Secret to Supabase

1. Copy your Trigger.dev `prod` secret key from API keys page
2. In Supabase project: Settings > Edge Functions
3. Add new secret: `TRIGGER_SECRET_KEY` with the copied value

### Create Edge Function

```bash
supabase functions new video-processing-handler
```

File: `functions/video-processing-handler/index.ts`

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { tasks } from "npm:@trigger.dev/sdk@latest";
import type { videoProcessAndUpdate } from "../../../src/trigger/videoProcessAndUpdate.ts";

Deno.serve(async (req) => {
  const payload = await req.json();

  const videoUrl = payload.record.video_url;
  const id = payload.record.id;

  await tasks.trigger<typeof videoProcessAndUpdate>("video-process-and-update", { videoUrl, id });

  return new Response("ok");
});
```

### Deploy Edge Function

```bash
supabase functions deploy video-processing-handler
```

## Configure Database Webhook

### Get API Keys

In Supabase: Settings > API > Copy `anon` `public` key

### Create Webhook

1. Database > Webhooks > Create a new hook
2. Name: `edge-function-hook`
3. Table: `public.video_transcriptions`
4. Event: `insert`
5. Webhook configuration: Supabase Edge Functions
6. HTTP method: `POST`
7. Edge Function: `video-processing-handler`
8. HTTP Headers: Add `Authorization: Bearer <your-api-key>`

## Test the Workflow

1. In Supabase Table Editor, insert a new row
2. Add a video URL (example: `https://content.trigger.dev/Supabase%20Edge%20Functions%20Quickstart.mp4`)
3. Check Trigger.dev Runs list for the active task
4. Once complete, the `transcription` column will populate with results

## Important Considerations

Service role keys have unlimited access and bypass all security checks. Review authentication best practices for production environments. Database updates triggered by webhook changes require careful implementation to prevent infinite loops.

## Additional Resources

- [Supabase Authentication Guide](/guides/frameworks/supabase-authentication) - JWT and Row Level Security implementation
- [Edge Function Hello World](/guides/frameworks/supabase-edge-functions-basic) - URL-triggered tasks
- [Supabase Database Operations Example](/guides/examples/supabase-database-operations) - CRUD operations
- [GitHub Repository](https://github.com/triggerdotdev/examples/tree/main/supabase-edge-functions) - Full project code
