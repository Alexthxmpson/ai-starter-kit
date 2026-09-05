---
source: https://trigger.dev/docs/guides/example-projects/human-in-the-loop-workflow
scraped: 2026-02-28
---

# Human-in-the-loop Workflow with ReactFlow and Trigger.dev Waitpoint Tokens

## Overview

This full-stack example demonstrates how to create audio summaries of newspaper articles using a human-in-the-loop approach. The project integrates several technologies:

- **Next.js** - web application framework
- **ReactFlow** - workflow visualization UI
- **Trigger.dev Realtime** - real-time task run subscriptions
- **Trigger.dev waitpoint tokens** - human approval steps
- **OpenAI API** - article summarization
- **ElevenLabs** - text-to-speech conversion

## Architecture

The system uses task composition where each node in the workflow corresponds to a Trigger.dev task. Output from one task feeds into the next, enabling modular workflow building.

### Key Tasks

The workflow includes four main tasks:

1. **summarizeArticle** - uses OpenAI to generate article summaries
2. **convertTextToSpeech** - converts summaries to audio via ElevenLabs and uploads to S3
3. **reviewSummary** - a human-in-the-loop step requiring user approval
4. **articleWorkflow** - orchestrates all tasks together

### ReactFlow Components

Three custom node types power the UI:

- **InputNode** - initiates workflows by accepting article URLs
- **ActionNode** - displays real-time task status using Trigger.dev hooks
- **ReviewNode** - presents summaries and collects user approval decisions

## Implementation Details

The waitpoint token is created through a server action:

```ts
const reviewWaitpointToken = await wait.createToken({
  tags: [workflowTag],
  timeout: "1h",
  idempotencyKey: `review-summary-${workflowTag}`,
});
```

Token completion occurs in another server action:

```ts
await wait.completeToken<ReviewPayload>(
  { id: tokenId },
  {
    approved: true,
    approvedAt: new Date(),
    approvedBy: user,
  }
);
```

## Resources

- [GitHub Repository](https://github.com/triggerdotdev/examples/tree/main/article-summary-workflow) - complete project code
- Trigger.dev Realtime documentation
- Waitpoint tokens guide
- React hooks integration guide
