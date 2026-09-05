---
source: https://trigger.dev/docs/guides/frameworks/nextjs-webhooks
scraped: 2026-02-28
---

# Triggering Tasks with Webhooks in Next.js

## Overview

This guide demonstrates how to trigger a Trigger.dev task from a webhook in a Next.js application.

## Prerequisites

- A Next.js project configured with Trigger.dev
- cURL installed locally for sending POST requests

## Implementation

### Pages Router Approach

Create `pages/api/webhook-handler.ts`:

```ts
import { helloWorldTask } from "@/trigger/example";
import { tasks } from "@trigger.dev/sdk";
import type { NextApiRequest, NextApiResponse } from "next";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  const payload = req.body;
  await tasks.trigger<typeof helloWorldTask>("hello-world", payload);
  res.status(200).json({ message: "OK" });
}
```

### App Router Approach

Create `app/api/webhook-handler/route.ts`:

```ts
import type { helloWorldTask } from "@/trigger/example";
import { tasks } from "@trigger.dev/sdk";
import { NextResponse } from "next/server";

export async function POST(req: Request) {
  const payload = await req.json();
  await tasks.trigger<typeof helloWorldTask>("hello-world", payload);
  return NextResponse.json("OK", { status: 200 });
}
```

## Local Testing

1. Start your Next.js dev server and Trigger.dev dev server in separate terminals
2. Use cURL to send test data:

```bash
curl -X POST -H "Content-Type: application/json" -d '{"Name": "John Doe", "Age": "87"}' http://localhost:3000/api/webhook-handler
```

3. Verify successful execution in the Trigger.dev dashboard
