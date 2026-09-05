---
source: https://trigger.dev/docs/guides/examples/deepgram-transcribe-audio
scraped: 2026-02-28
---

# Transcribe Audio Using Deepgram

## Overview

This guide demonstrates how to implement audio transcription using Deepgram's speech recognition API with Trigger.dev.

## Key Capabilities

- Transcribe audio files from URLs
- Leverage the Nova 2 model for high-quality transcription

## Implementation Example

```ts
import { createClient } from "@deepgram/sdk";
import { logger, task } from "@trigger.dev/sdk";

const deepgram = createClient(process.env.DEEPGRAM_SECRET_KEY);

export const deepgramTranscription = task({
  id: "deepgram-transcribe-audio",
  run: async (payload: { audioUrl: string }) => {
    const { audioUrl } = payload;

    logger.log("Transcribing audio from URL", { audioUrl });

    const { result, error } = await deepgram.listen.prerecorded.transcribeUrl(
      {
        url: audioUrl,
      },
      {
        model: "nova-2",
        smart_format: true,
        diarize: true,
      }
    );

    if (error) {
      logger.error("Failed to transcribe audio", { error });
      throw error;
    }

    console.dir(result, { depth: null });

    const transcription = result.results.channels[0].alternatives[0].paragraphs?.transcript;

    logger.log(`Generated transcription: ${transcription}`);

    return {
      result,
    };
  },
});
```

## Testing the Task

Use this payload to test in the dashboard:

```json
{
  "audioUrl": "https://dpgr.am/spacewalk.wav"
}
```
