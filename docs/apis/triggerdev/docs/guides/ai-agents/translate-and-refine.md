---
source: https://trigger.dev/docs/guides/ai-agents/translate-and-refine
scraped: 2026-02-28
---

# Translate text and refine it based on feedback

## Overview

This guide demonstrates creating a task using the **evaluator-optimizer pattern**, where one LLM generates content while another provides iterative feedback. This approach works well for tasks with measurable quality criteria.

The pattern involves:
- An LLM that produces an initial response and refinements
- An evaluator LLM that assesses quality and suggests improvements
- A loop that continues until approval or maximum iterations

## Example Task: Translation with Refinement

This implementation translates text into a target language and improves it iteratively based on LLM feedback.

**Key Features:**

- Leverages `generateText` from [Vercel's AI SDK](https://sdk.vercel.ai/docs/introduction)
- Integrates `experimental_telemetry` for dashboard visibility
- Caps iterations at 10 attempts
- Uses a separate evaluator call to assess translation quality
- Recursively refines based on feedback

### Code Implementation

```typescript
import { task } from "@trigger.dev/sdk";
import { generateText } from "ai";
import { openai } from "@ai-sdk/openai";

interface TranslationPayload {
  text: string;
  targetLanguage: string;
  previousTranslation?: string;
  feedback?: string;
  rejectionCount?: number;
}

export const translateAndRefine = task({
  id: "translate-and-refine",
  run: async (payload: TranslationPayload) => {
    const rejectionCount = payload.rejectionCount || 0;

    if (rejectionCount >= 10) {
      return {
        finalTranslation: payload.previousTranslation,
        iterations: rejectionCount,
        status: "MAX_ITERATIONS_REACHED",
      };
    }

    const translationPrompt = payload.feedback
      ? `Previous translation: "${payload.previousTranslation}"\n\nFeedback received: "${payload.feedback}"\n\nPlease provide an improved translation addressing this feedback.`
      : `Translate this text into ${payload.targetLanguage}, preserving style and meaning: "${payload.text}"`;

    const translation = await generateText({
      model: openai("o1-mini"),
      messages: [
        {
          role: "system",
          content: `You are an expert literary translator into ${payload.targetLanguage}.
                   Focus on accuracy first, then style and natural flow.`,
        },
        {
          role: "user",
          content: translationPrompt,
        },
      ],
      experimental_telemetry: {
        isEnabled: true,
        functionId: "translate-and-refine",
      },
    });

    const evaluation = await generateText({
      model: openai("o1-mini"),
      messages: [
        {
          role: "system",
          content: `You are an expert literary critic and translator focused on practical, high-quality translations.
                 Your goal is to ensure translations are accurate and natural, but not necessarily perfect.
                 This is iteration ${
                   rejectionCount + 1
                 } of a maximum 5 iterations.

                 RESPONSE FORMAT:
                 - If the translation meets 90%+ quality: Respond with exactly "APPROVED" (nothing else)
                 - If improvements are needed: Provide only the specific issues that must be fixed

                 Evaluation criteria:
                 - Accuracy of meaning (primary importance)
                 - Natural flow in the target language
                 - Preservation of key style elements

                 DO NOT provide detailed analysis, suggestions, or compliments.
                 DO NOT include the translation in your response.

                 IMPORTANT RULES:
                 - First iteration MUST receive feedback for improvement
                 - Be very strict on accuracy in early iterations
                 - After 3 iterations, lower quality threshold to 85%`,
        },
        {
          role: "user",
          content: `Original: "${payload.text}"
                 Translation: "${translation.text}"
                 Target Language: ${payload.targetLanguage}
                 Iteration: ${rejectionCount + 1}
                 Previous Feedback: ${
                   payload.feedback ? `"${payload.feedback}"` : "None"
                 }

                 ${
                   rejectionCount === 0
                     ? "This is the first attempt. Find aspects to improve."
                     : 'Either respond with exactly "APPROVED" or provide only critical issues that must be fixed.'
                 }`,
        },
      ],
      experimental_telemetry: {
        isEnabled: true,
        functionId: "translate-and-refine",
      },
    });

    if (evaluation.text.trim() === "APPROVED") {
      return {
        finalTranslation: translation.text,
        iterations: rejectionCount,
        status: "APPROVED",
      };
    }

    await translateAndRefine
      .triggerAndWait({
        text: payload.text,
        targetLanguage: payload.targetLanguage,
        previousTranslation: translation.text,
        feedback: evaluation.text,
        rejectionCount: rejectionCount + 1,
      })
      .unwrap();
  },
});
```

## Testing the Task

Use the dashboard's Test page with the `translate-and-refine` task and this sample payload:

```json
{
  "text": "In the twilight of his years, the old clockmaker's hands, once steady as the timepieces he crafted, now trembled like autumn leaves in the wind.",
  "targetLanguage": "French"
}
```

This payload requires multiple refinement iterations, demonstrating the evaluator-optimizer pattern in action.
