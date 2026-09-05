---
source: https://trigger.dev/docs/guides/example-projects/batch-llm-evaluator
scraped: 2026-02-28
---

# Next.js Batch LLM Evaluator

## Overview

This full-stack demonstration combines several technologies to evaluate multiple language models. The project leverages Next.js with Prisma for data persistence, Trigger.dev's Realtime functionality for frontend updates, and the Vercel AI SDK to work with various LLM providers including OpenAI, Anthropic, and XAI.

## Key Features

The implementation showcases:

- **Task Distribution**: Uses the `batch.triggerByTaskAndWait` method to parallelize LLM evaluation across multiple models
- **Real-time Updates**: Streams results to the frontend using Trigger.dev Realtime capabilities
- **Multi-provider Support**: Integrates with OpenAI, Anthropic, and XAI through the Vercel AI SDK
- **Two-stage Processing**: The `evaluateModels` task orchestrates model evaluations, then passes results to a `summarizeEvals` task for analysis

## Architecture Components

The codebase is organized around:

- **Task Layer** (`src/trigger/batch.ts`): Contains the batch evaluation and summarization logic
- **Frontend Layer** (`src/components/llm-evaluator.tsx`): Subscribes to run updates using the `useRealtimeRunsWithTag` hook
- **Model-Specific Components**: Dedicated evaluation displays for each provider (Anthropic, XAI, OpenAI)
- **Stream Handling**: Individual components use `useRealtimeRunWithStreams` to display real-time LLM responses

## Related Resources

For deeper understanding, consult the documentation on Trigger.dev Realtime features, batch triggering mechanisms, and React integration hooks.
