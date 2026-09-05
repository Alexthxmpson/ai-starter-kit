---
source: https://trigger.dev/docs/guides/examples/open-ai-with-retrying
scraped: 2026-02-28
---

# Call OpenAI with Retrying

## Overview

This guide demonstrates implementing retry logic for OpenAI API calls using Trigger.dev. The task will automatically retry if API calls fail or return empty responses.

## Task Implementation

```ts
import { task } from "@trigger.dev/sdk";
import OpenAI from "openai";

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

export const openaiTask = task({
  id: "openai-task",
  retry: {
    maxAttempts: 10,
    factor: 1.8,
    minTimeoutInMs: 500,
    maxTimeoutInMs: 30_000,
    randomize: false,
  },
  run: async (payload: { prompt: string }) => {
    const chatCompletion = await openai.chat.completions.create({
      messages: [{ role: "user", content: payload.prompt }],
      model: "gpt-3.5-turbo",
    });

    if (chatCompletion.choices[0]?.message.content === undefined) {
      throw new Error("OpenAI call failed");
    }

    return chatCompletion.choices[0].message.content;
  },
});
```

## Testing

Use this payload to test the task in the dashboard:

```json
{
  "prompt": "What is the meaning of life?"
}
```

The retry configuration can override defaults specified in your `trigger.config` file, allowing customization of attempt limits and timeout intervals.
