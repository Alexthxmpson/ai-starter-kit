---
source: https://trigger.dev/docs/guides/example-projects/realtime-fal-ai
scraped: 2026-02-28
---

# Image Generation with Fal.ai and Trigger.dev Realtime

## Overview

This Next.js example demonstrates a complete full-stack implementation combining image generation capabilities with real-time progress tracking. The project showcases:

- A Trigger.dev task that generates an image from a prompt using Fal.ai
- Form submission in the UI that triggers the task via server action
- Real-time progress visualization on the frontend with error handling and fallback UI
- Display of the generated image alongside the original prompt image once complete

## Key Components

**Backend Task:**
The Trigger.dev task handles image generation using the Fal.ai integration, managing the processing workflow.

**Frontend Integration:**
A server action processes form submissions, initiating the backend task while maintaining connection to receive progress updates through Trigger.dev Realtime.

**Progress Display:**
The frontend subscribes to task execution updates, displaying status changes, handling errors gracefully, and rendering the final output.

## Resources

**GitHub Repository:**
The complete project code is available in the Trigger.dev examples repository, providing a foundation for your own implementations.

**Video Walkthrough:**
A comprehensive walkthrough demonstrates building this task within a Next.js environment.

## Related Documentation

- Trigger.dev Realtime - subscribing to runs and receiving real-time updates
- Realtime streaming - streaming data from tasks
- Batch Triggering - triggering tasks in batches
- React hooks - interacting with the Trigger.dev API through React
