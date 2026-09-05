---
source: https://trigger.dev/docs/guides/examples/hookdeck-webhook
scraped: 2026-02-28
---

# Trigger Tasks from Hookdeck Webhooks

## Overview

This documentation explains how to integrate Hookdeck with Trigger.dev to manage webhook infrastructure and execute reliable tasks. Hookdeck receives webhooks from external services, and forwards them directly to the Trigger.dev API, combining webhook management with task automation.

## Key Capabilities

- Hookdeck acts as your webhook endpoint for third-party services
- Direct forwarding of webhooks to Trigger.dev tasks via API
- Complete logging and replay functionality within Hookdeck

## Configuration Process

All setup occurs in the Hookdeck dashboard without requiring code modifications to your application.

### Creating a Destination

Configure a destination with these parameters:

- **URL**: `https://api.trigger.dev/api/v1/tasks/<task-id>/trigger` (substitute your actual task ID)
- **Method**: POST
- **Authentication**: Bearer token authentication using your `TRIGGER_SECRET_KEY`

### Adding a Transformation

Implement a transformation to structure the webhook data correctly:

```javascript
addHandler("transform", (request, context) => {
  request.body = { payload: { ...request.body } };
  return request;
});
```

This wraps the incoming webhook body in the "payload" field that Trigger.dev expects.

### Establishing a Connection

Link your webhook source to the destination and transformation through a connection configuration.

## Task Implementation

```ts
import { task } from "@trigger.dev/sdk";

export const webhookHandler = task({
  id: "webhook-handler",
  run: async (payload: Record<string, unknown>) => {
    console.log("Received webhook:", payload);
    // Custom logic goes here
  },
});
```

## Verification Steps

Test your integration by:

1. Completing Hookdeck configuration (destination, transformation, connection)
2. Sending a test webhook via Hookdeck Console or cURL
3. Verifying receipt and forwarding in the Hookdeck dashboard
4. Checking the Trigger.dev dashboard for successful task execution
