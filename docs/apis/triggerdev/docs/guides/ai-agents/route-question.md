---
source: https://trigger.dev/docs/guides/ai-agents/route-question
scraped: 2026-02-28
---

# Route a Question to a Different AI Model

## Overview

Routing is a workflow pattern that classifies input and directs it to specialized followup tasks. This separation of concerns allows for optimized prompts tailored to distinct categories, improving overall performance.

## Key Concept

This pattern allows for separation of concerns and building more specialized prompts, which is particularly effective when there are distinct categories that are better handled separately.

Without routing, optimizing for one category of input can degrade performance on others.

## Example Implementation

The provided example creates a workflow that:

- Uses Vercel's AI SDK to interact with OpenAI models
- Employs a lightweight model (o1-mini) to classify question complexity
- Routes simple questions to `gpt-4o` and complex ones to `gpt-o3-mini`
- Returns the answer alongside routing decision metadata

### Code Structure

```typescript
import { openai } from "@ai-sdk/openai";
import { task } from "@trigger.dev/sdk";
import { generateText } from "ai";
import { z } from "zod";

// Schema for router response
const routingSchema = z.object({
  model: z.enum(["gpt-4o", "gpt-o3-mini"]),
  reason: z.string(),
});

// Router prompt template
const ROUTER_PROMPT = `You are a routing assistant that determines the complexity of questions.
Analyze the following question and route it to the appropriate model:

- Use "gpt-4o" for simple, common, or straightforward questions
- Use "gpt-o3-mini" for complex, unusual, or questions requiring deep reasoning

Respond with a JSON object in this exact format:
{"model": "gpt-4o" or "gpt-o3-mini", "reason": "your reasoning here"}

Question: `;

export const routeAndAnswerQuestion = task({
  id: "route-and-answer-question",
  run: async (payload: { question: string }) => {
    // Step 1: Route the question
    const routingResponse = await generateText({
      model: openai("o1-mini"),
      messages: [
        {
          role: "system",
          content:
            "You must respond with a valid JSON object containing only 'model' and 'reason' fields. No markdown, no backticks, no explanation.",
        },
        {
          role: "user",
          content: ROUTER_PROMPT + payload.question,
        },
      ],
      temperature: 0.1,
      experimental_telemetry: {
        isEnabled: true,
        functionId: "route-and-answer-question",
      },
    });

    // Add error handling and cleanup
    let jsonText = routingResponse.text.trim();
    if (jsonText.startsWith("```")) {
      jsonText = jsonText.replace(/```json\n|\n```/g, "");
    }

    const routingResult = routingSchema.parse(JSON.parse(jsonText));

    // Step 2: Get the answer using the selected model
    const answerResult = await generateText({
      model: openai(routingResult.model),
      messages: [{ role: "user", content: payload.question }],
    });

    return {
      answer: answerResult.text,
      selectedModel: routingResult.model,
      routingReason: routingResult.reason,
    };
  },
});
```

## Test Example

When triggered with a straightforward question like "How many planets are there in the solar system?", the workflow routes to gpt-4o and returns the answer with routing reasoning included in the response.
