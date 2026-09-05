---
source: https://trigger.dev/docs/guides/examples/supabase-database-operations
scraped: 2026-02-28
---

# Supabase Database Operations Using Trigger.dev

## Overview

This documentation demonstrates how to execute basic CRUD operations on Supabase tables through Trigger.dev tasks.

## Adding a New User

### Setup Requirements

- Active Supabase account with project
- Table named `user_subscriptions`
- Column: `user_id` (text data type)

### Implementation

The task uses the `@supabase/supabase-js` library to establish a client connection. Key steps include:

1. Generate a JWT token using the Supabase JWT secret
2. Initialize the Supabase client with the bearer token in headers
3. Insert the new record using the `.insert()` method

```ts
import { createClient } from "@supabase/supabase-js";
import { task } from "@trigger.dev/sdk";
import jwt from "jsonwebtoken";
import { Database } from "database.types";

export const supabaseDatabaseInsert = task({
  id: "add-new-user",
  run: async (payload: { userId: string }) => {
    const { userId } = payload;
    const jwtSecret = process.env.SUPABASE_JWT_SECRET;

    if (!jwtSecret) {
      throw new Error("SUPABASE_JWT_SECRET is not defined");
    }

    const token = jwt.sign({ sub: userId }, jwtSecret, { expiresIn: "1h" });

    const supabase = createClient<Database>(
      process.env.SUPABASE_URL as string,
      process.env.SUPABASE_ANON_KEY as string,
      {
        global: {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        },
      }
    );

    const { error } = await supabase.from("user_subscriptions").insert({
      user_id: userId,
    });

    if (error) {
      throw new Error(`Failed to insert new user: ${error.message}`);
    }

    return {
      message: `New user added successfully: ${userId}`,
    };
  },
});
```

### Test Payload

```json
{
  "userId": "user_12345"
}
```

## Updating User Subscriptions

### Setup Requirements

- `user_subscriptions` table
- Columns: `user_id` (text), `plan` (text), `updated_at` (timestamptz)

### Key Features

This task demonstrates:
- Checking for existing user records via `.select()` and `.eq()`
- Inserting new records if the user doesn't exist
- Updating existing records using `.update()`
- Using `AbortTaskRunError` to halt execution without retry on invalid input

```ts
import { createClient } from "@supabase/supabase-js";
import { AbortTaskRunError, task } from "@trigger.dev/sdk";
import { Database } from "database.types";

type PlanType = "hobby" | "pro" | "enterprise";

const supabase = createClient<Database>(
  process.env.SUPABASE_PROJECT_URL as string,
  process.env.SUPABASE_SERVICE_ROLE_KEY as string
);

export const supabaseUpdateUserSubscription = task({
  id: "update-user-subscription",
  run: async (payload: { userId: string; newPlan: PlanType }) => {
    const { userId, newPlan } = payload;

    if (!["hobby", "pro", "enterprise"].includes(newPlan)) {
      throw new AbortTaskRunError(
        `Invalid plan type: ${newPlan}. Allowed types are 'hobby', 'pro', or 'enterprise'.`
      );
    }

    const { data: existingSubscriptions } = await supabase
      .from("user_subscriptions")
      .select("user_id")
      .eq("user_id", userId);

    if (!existingSubscriptions || existingSubscriptions.length === 0) {
      const { error: insertError } = await supabase.from("user_subscriptions").insert({
        user_id: userId,
        plan: newPlan,
        updated_at: new Date().toISOString(),
      });

      if (insertError) {
        throw new Error(`Failed to insert user subscription: ${insertError.message}`);
      }
    } else {
      const { error: updateError } = await supabase
        .from("user_subscriptions")
        .update({ plan: newPlan, updated_at: new Date().toISOString() })
        .eq("user_id", userId);

      if (updateError) {
        throw new Error(`Failed to update user subscription: ${updateError.message}`);
      }
    }

    return {
      userId,
      newPlan,
    };
  },
});
```

### Test Payload

```json
{
  "userId": "user_12345",
  "newPlan": "pro"
}
```

## Related Resources

- **Edge Function Guide**: Trigger tasks from Supabase edge functions on URL visits
- **Database Webhooks Guide**: Trigger tasks on database events
- **Authentication Guide**: Configure JWT and service role key authentication for Row Level Security
