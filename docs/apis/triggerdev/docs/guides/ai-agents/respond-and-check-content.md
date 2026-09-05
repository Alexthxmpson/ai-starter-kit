---
source: https://trigger.dev/docs/guides/ai-agents/respond-and-check-content
scraped: 2026-02-28
---

# Respond to Customer Inquiry and Check for Inappropriate Content

## Overview

Parallelization is a workflow pattern where multiple tasks run simultaneously rather than sequentially, improving resource efficiency and execution speed. This approach is valuable when different parts of a task can be handled independently, such as running content analysis and response generation at the same time.

## Example Task

This workflow simultaneously checks content for issues while responding to customer inquiries. It uses the Vercel AI SDK to interact with OpenAI models and leverages `batch.triggerByTaskAndWait` to run customer response and content moderation tasks in parallel.

### Code Implementation

```typescript
import { openai } from "@ai-sdk/openai";
import { batch, task } from "@trigger.dev/sdk";
import { generateText } from "ai";

// Task to generate customer response
export const generateCustomerResponse = task({
  id: "generate-customer-response",
  run: async (payload: { question: string }) => {
    const response = await generateText({
      model: openai("o1-mini"),
      messages: [
        {
          role: "system",
          content: "You are a helpful customer service representative.",
        },
        { role: "user", content: payload.question },
      ],
      experimental_telemetry: {
        isEnabled: true,
        functionId: "generate-customer-response",
      },
    });

    return response.text;
  },
});

// Task to check for inappropriate content
export const checkInappropriateContent = task({
  id: "check-inappropriate-content",
  run: async (payload: { text: string }) => {
    const response = await generateText({
      model: openai("o1-mini"),
      messages: [
        {
          role: "system",
          content:
            "You are a content moderator. Respond with 'true' if the content is inappropriate or contains harmful, threatening, offensive, or explicit content, 'false' otherwise.",
        },
        { role: "user", content: payload.text },
      ],
      experimental_telemetry: {
        isEnabled: true,
        functionId: "check-inappropriate-content",
      },
    });

    return response.text.toLowerCase().includes("true");
  },
});

// Main task that coordinates the parallel execution
export const handleCustomerQuestion = task({
  id: "handle-customer-question",
  run: async (payload: { question: string }) => {
    const {
      runs: [responseRun, moderationRun],
    } = await batch.triggerByTaskAndWait([
      {
        task: generateCustomerResponse,
        payload: { question: payload.question },
      },
      {
        task: checkInappropriateContent,
        payload: { text: payload.question },
      },
    ]);

    // Check moderation result first
    if (moderationRun.ok && moderationRun.output === true) {
      return {
        response:
          "I apologize, but I cannot process this request as it contains inappropriate content.",
        wasInappropriate: true,
      };
    }

    // Return the generated response if everything is ok
    if (responseRun.ok) {
      return {
        response: responseRun.output,
        wasInappropriate: false,
      };
    }

    // Handle any errors
    throw new Error("Failed to process customer question");
  },
});
```

## Testing

To test this workflow, select the `handle-customer-question` task on the Test page and use this payload:

```json
{
  "question": "Can you explain 2FA?"
}
```

When triggered, the task generates a response while simultaneously checking for inappropriate content using two parallel LLM calls. The main task waits for both operations to complete before returning the final response.
