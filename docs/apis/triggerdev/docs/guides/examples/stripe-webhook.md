---
source: https://trigger.dev/docs/guides/examples/stripe-webhook
scraped: 2026-02-28
---

# Trigger a Task from Stripe Webhook Events

## Overview

This guide demonstrates how to set up a webhook handler within your application to process Stripe events. When a `checkout.session.completed` event arrives, the system automatically triggers a corresponding task. The implementation is flexible and can be adapted for other Stripe event types.

## Required Environment Variables

- `STRIPE_WEBHOOK_SECRET` - Secret key for verifying Stripe webhook signatures
- `TRIGGER_API_URL` - Your Trigger.dev API endpoint: `https://api.trigger.dev`
- `TRIGGER_SECRET_KEY` - Your Trigger.dev secret key

## Setting Up the Stripe Webhook Handler

### Next.js

```ts
// app/api/stripe-webhook/route.ts
import { NextResponse } from "next/server";
import { tasks } from "@trigger.dev/sdk";
import Stripe from "stripe";
import type { stripeCheckoutCompleted } from "@/trigger/stripe-checkout-completed";

export async function POST(request: Request) {
  const signature = request.headers.get("stripe-signature");
  const payload = await request.text();

  if (!signature || !payload) {
    return NextResponse.json(
      { error: "Invalid Stripe payload/signature" },
      { status: 400 }
    );
  }

  const event = Stripe.webhooks.constructEvent(
    payload,
    signature,
    process.env.STRIPE_WEBHOOK_SECRET as string
  );

  switch (event.type) {
    case "checkout.session.completed": {
      const { id } = await tasks.trigger<typeof stripeCheckoutCompleted>(
        "stripe-checkout-completed",
        event.data.object
      );
      return NextResponse.json({ runId: id });
    }
    default: {
      return NextResponse.json(
        { message: "Event not handled" },
        { status: 200 }
      );
    }
  }
}
```

### Remix

```ts
// app/webhooks.stripe.ts
import { type ActionFunctionArgs, json } from "@remix-run/node";
import type { stripeCheckoutCompleted } from "src/trigger/stripe-webhook";
import { tasks } from "@trigger.dev/sdk";
import Stripe from "stripe";

export async function action({ request }: ActionFunctionArgs) {
  const signature = request.headers.get("stripe-signature");
  const payload = await request.text();

  if (!signature || !payload) {
    return json({ error: "Invalid Stripe payload/signature" }, { status: 400 });
  }

  const event = Stripe.webhooks.constructEvent(
    payload,
    signature,
    process.env.STRIPE_WEBHOOK_SECRET as string
  );

  switch (event.type) {
    case "checkout.session.completed": {
      const { id } = await tasks.trigger<typeof stripeCheckoutCompleted>(
        "stripe-checkout-completed",
        event.data.object
      );
      return json({ runId: id });
    }
    default: {
      return json({ message: "Event not handled" }, { status: 200 });
    }
  }
}
```

## Task Implementation

```ts
// trigger/stripe-checkout-completed.ts
import { task } from "@trigger.dev/sdk";
import type stripe from "stripe";

export const stripeCheckoutCompleted = task({
  id: "stripe-checkout-completed",
  run: async (payload: stripe.Checkout.Session) => {
    // Add custom logic for handling the checkout.session.completed event
  },
});
```

## Local Testing

Test your implementation with the Stripe CLI:

1. Install the [Stripe CLI](https://stripe.com/docs/stripe-cli#install) and authenticate
2. Follow the [test instructions](https://docs.stripe.com/webhooks#test-webhook) for your handler endpoint, which provides a temporary `STRIPE_WEBHOOK_SECRET`
3. Send a test event: `stripe trigger checkout.session.completed`
4. Verify your endpoint receives the event with a `200` status in your console logs
5. Check the [Trigger.dev dashboard](https://cloud.trigger.dev) to confirm successful task execution

For additional details on webhook setup and testing, consult the [Stripe Webhook Documentation](https://stripe.com/docs/webhooks).
