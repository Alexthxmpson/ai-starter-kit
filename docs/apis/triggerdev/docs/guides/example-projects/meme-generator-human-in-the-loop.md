---
source: https://trigger.dev/docs/guides/example-projects/meme-generator-human-in-the-loop
scraped: 2026-02-28
---

# Meme Generator with Human-in-the-Loop Approval

## Overview

This example demonstrates a complete stack application that generates memes using OpenAI's DALL-E 3 with human approval integrated into the workflow. The system leverages Trigger.dev's waitpoint tokens to manage the approval process.

## Key Technologies

The project incorporates:

- **Next.js** application with an approval endpoint
- **Trigger.dev** tasks for orchestrating the workflow
- **OpenAI DALL-E 3** for image generation
- **Slack app** integration for human review with approval buttons

## Architecture Components

**Meme Generator Task** (`memegenerator.ts`):
- Generates multiple meme variants simultaneously using DALL-E 3
- Implements `batchTriggerAndWait` for parallel processing
- Creates waitpoint tokens for approval flow
- Sends generated images to Slack with approval buttons
- Manages the complete approval workflow

**Approval Endpoint** (`page.tsx`):
- Processes user selections from Slack buttons
- Completes waitpoint tokens with chosen variants
- Provides success/failure feedback to approvers

## Learning Resources

To deepen your understanding of this implementation:

- Explore waitpoint tokens documentation for human-in-the-loop patterns
- Review the OpenAI DALL-E API documentation
- Examine Next.js framework features and capabilities
- Study Slack Incoming Webhooks for integration patterns

The complete source code is available in the Trigger.dev examples repository on GitHub.
