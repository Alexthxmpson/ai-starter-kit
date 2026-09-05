---
source: https://trigger.dev/docs/guides/example-projects/vercel-ai-sdk-image-generator
scraped: 2026-02-28
---

# Vercel AI SDK Image Generator

## Project Overview

This Next.js demonstration showcases a full-stack implementation combining:

- **Next.js framework** with **shadcn** UI components
- The **useRealtimeRun React hook** for subscribing to run updates on the frontend
- **Vercel AI SDK** integration with OpenAI's DALL-E models for image generation

## Repository

The complete project code is available in the [Trigger.dev examples repository on GitHub](https://github.com/triggerdotdev/examples/tree/main/vercel-ai-sdk-image-generator).

## Demo Video

A video walkthrough of the application is available in the GitHub repository.

## Key Implementation Files

- **Task implementation**: The Trigger.dev task that handles image generation using Vercel AI SDK is located in `src/trigger/realtime-generate-image.ts`
- **Frontend subscription**: The React component that subscribes to run updates using the useRealtimeRun hook is in `src/app/processing/[id]/ProcessingContent.tsx`

## Related Resources

- [Trigger.dev Realtime](/realtime) - subscribing to runs and receiving live updates
- [Realtime Streaming](/realtime/react-hooks/streams) - streaming data from tasks
- [Batch Triggering](/triggering#tasks-batchtrigger) - triggering multiple tasks efficiently
- [React Hooks](/realtime/react-hooks) - interacting with the Trigger.dev API via React
