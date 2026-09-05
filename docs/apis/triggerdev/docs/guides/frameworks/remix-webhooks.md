---
source: https://trigger.dev/docs/guides/frameworks/remix-webhooks
scraped: 2026-02-28
---

# Triggering Tasks with Webhooks in Remix

## Overview

This guide demonstrates how to trigger a Trigger.dev task from a webhook in a Remix application using the Trigger.dev SDK.

## Prerequisites

- A Remix project configured with Trigger.dev
- cURL installed locally for sending POST requests

## Implementation

### Webhook Handler Setup

Create a new API route file at `app/routes/api.webhook-handler.ts` containing:

```ts
import type { ActionFunctionArgs } from "@remix-run/node";
import { tasks } from "@trigger.dev/sdk";
import { helloWorldTask } from "src/trigger/example";

export async function action({ request }: ActionFunctionArgs) {
  const payload = await request.json();

  // Trigger the helloWorldTask with the webhook data as the payload
  await tasks.trigger<typeof helloWorldTask>("hello-world", payload);

  return new Response("OK", { status: 200 });
}
```

This handler accepts webhook payloads and triggers the designated task.

## Local Testing

**Step 1:** Launch both your Remix app and the Trigger.dev development server in separate terminal windows.

**Step 2:** Send a test POST request using cURL:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"Name": "John Doe", "Age": "87"}' http://localhost:5173/api/webhook-handler
```

**Step 3:** Verify successful execution by checking your Trigger.dev dashboard for the completed run with your test payload.
