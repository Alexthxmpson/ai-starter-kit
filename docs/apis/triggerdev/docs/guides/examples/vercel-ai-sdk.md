---
source: https://trigger.dev/docs/guides/examples/vercel-ai-sdk
scraped: 2026-02-28
---

# Using the Vercel AI SDK

## Overview

The Vercel AI SDK is a straightforward tool for accessing AI models across multiple providers including OpenAI, Microsoft Azure, Google Generative AI, Anthropic, Amazon Bedrock, Groq, Perplexity and more. It offers a unified interface that allows developers to switch between different AI models without substantial code modifications.

## Generate text using OpenAI

This task demonstrates text generation from a prompt using the Vercel AI SDK with OpenAI.

### Task code

```ts
import { logger, task } from "@trigger.dev/sdk";
import { generateText } from "ai";
import { openai } from "@ai-sdk/openai";

export const openaiTask = task({
  id: "openai-text-generate",

  run: async (payload: { prompt: string }) => {
    const chatCompletion = await generateText({
      model: openai("gpt-4-turbo"),
      system: "You are a friendly assistant!",
      prompt: payload.prompt,
    });

    logger.log("chatCompletion text:" + chatCompletion.text);

    return chatCompletion;
  },
});
```

## Testing your task

Test payload for the dashboard:

```json
{
  "prompt": "What is the meaning of life?"
}
```

## Related Resources

- Next.js setup guide for Trigger.dev integration
- Next.js webhook triggering documentation
- Fal.ai realtime image generation example
- Fal.ai image-to-cartoon conversion guide
- Vercel environment variables synchronization
- Additional Vercel AI SDK examples
