---
source: https://trigger.dev/docs/guides/example-projects/claude-thinking-chatbot
scraped: 2026-02-28
---

# Claude 3.7 Thinking Chatbot

## Overview

This Next.js project demonstrates a thinking chatbot using several key technologies:

- **Next.js** - for the chat interface
- **Trigger.dev Realtime** - to stream AI responses and reasoning to the frontend
- **Claude 3.7 Sonnet** - for generating responses
- **AI SDK** - for Claude model integration

## GitHub Repository

The full project code is available in the [examples repository](https://github.com/triggerdotdev/examples/tree/main/claude-thinking-chatbot).

## Key Components

**Claude Stream Task** - Located in `src/trigger/claude-stream.ts`, this establishes the streaming connection with Claude.

**Chat Component** - Found in `app/components/claude-chat.tsx`, this handles:
- Message state management
- User input handling
- Message bubble rendering
- Trigger.dev streaming integration

**Stream Response** - This component within the chat interface manages:
- Displaying streamed text from Claude
- Toggling the thinking process display with animation
- Auto-scrolling as content arrives

## Related Resources

- [Trigger.dev Realtime](/realtime) - subscribing to runs and real-time updates
- [Realtime Streaming](/realtime/react-hooks/streams) - streaming data from tasks
- [Batch Triggering](/triggering#tasks-batchtrigger) - triggering tasks in batches
- [React Hooks](/realtime/react-hooks) - interacting with the Trigger.dev API
