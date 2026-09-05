---
source: https://trigger.dev/docs/guides/ai-agents/generate-translate-copy
scraped: 2026-02-28
---

# Generate and Translate Copy

## Overview

**Prompt chaining** breaks down complex tasks into sequential steps where each LLM call processes the previous output. This pattern prioritizes accuracy over speed by simplifying individual tasks and enabling programmatic validation between steps.

## Example Task

The workflow generates marketing copy and translates it using these components:

- Vercel's AI SDK `generateText` function for OpenAI model interactions
- `experimental_telemetry` for LLM logging
- Marketing copy generation based on subject and word count
- Word count validation (±10 words tolerance)
- Language translation while preserving tone

## Implementation

```typescript
import { openai } from "@ai-sdk/openai";
import { task } from "@trigger.dev/sdk";
import { generateText } from "ai";

export interface TranslatePayload {
  marketingSubject: string;
  targetLanguage: string;
  targetWordCount: number;
}

export const generateAndTranslateTask = task({
  id: "generate-and-translate-copy",
  maxDuration: 300,
  run: async (payload: TranslatePayload) => {
    // Step 1: Generate marketing copy
    const generatedCopy = await generateText({
      model: openai("o1-mini"),
      messages: [
        {
          role: "system",
          content: "You are an expert copywriter.",
        },
        {
          role: "user",
          content: `Generate as close as possible to ${payload.targetWordCount} words of compelling marketing copy for ${payload.marketingSubject}`,
        },
      ],
      experimental_telemetry: {
        isEnabled: true,
        functionId: "generate-and-translate-copy",
      },
    });

    // Gate: Validate word count
    const wordCount = generatedCopy.text.split(/\s+/).length;

    if (
      wordCount < payload.targetWordCount - 10 ||
      wordCount > payload.targetWordCount + 10
    ) {
      throw new Error(
        `Generated copy length (${wordCount} words) is outside acceptable range of ${
          payload.targetWordCount - 10
        }-${payload.targetWordCount + 10} words`
      );
    }

    // Step 2: Translate to target language
    const translatedCopy = await generateText({
      model: openai("o1-mini"),
      messages: [
        {
          role: "system",
          content: `You are an expert translator specializing in marketing content translation into ${payload.targetLanguage}.`,
        },
        {
          role: "user",
          content: `Translate the following marketing copy to ${payload.targetLanguage}, maintaining the same tone and marketing impact:\n\n${generatedCopy.text}`,
        },
      ],
      experimental_telemetry: {
        isEnabled: true,
        functionId: "generate-and-translate-copy",
      },
    });

    return {
      englishCopy: generatedCopy,
      translatedCopy,
    };
  },
});
```

## Test Configuration

Select the `generate-and-translate-copy` task in the dashboard Test page with this payload:

```json
{
  "marketingSubject": "The controversial new Jaguar electric concept car",
  "targetLanguage": "Spanish",
  "targetWordCount": 100
}
```

The workflow executes sequential LLM calls, validating generated copy against word count requirements before proceeding to translation.
