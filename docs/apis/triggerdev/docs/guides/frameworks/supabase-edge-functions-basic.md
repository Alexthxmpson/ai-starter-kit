---
source: https://trigger.dev/docs/guides/frameworks/supabase-edge-functions-basic
scraped: 2026-02-28
---

# Triggering Tasks from Supabase Edge Functions

## Overview

This guide demonstrates how to trigger Trigger.dev tasks from Supabase edge functions. Supabase edge functions allow you to trigger tasks either when an event is sent from a third party (e.g. when a new Stripe payment is processed, when a new user signs up to a service, etc), or when there are any changes or updates to your Supabase database.

## Prerequisites

- Supabase CLI installed (version 1.123.4 or later requires Docker Desktop)
- TypeScript installed
- A Trigger.dev account and project created

## Initial Setup Steps

Run `npx trigger.dev@latest init` which will:

1. Optionally install the Trigger.dev MCP server for AI assistant integration
2. Authenticate you via CLI
3. Prompt you to select your project
4. Install required SDK packages
5. Create a `/trigger` directory with example tasks
6. Generate a `trigger.config.ts` configuration file

Run `npx trigger.dev@latest dev` to start a local development server that watches your `/trigger` directory and communicates with the Trigger.dev platform.

## Creating and Deploying an Edge Function

To create a Supabase edge function that triggers a task:

1. **Generate the function**: Use `supabase functions new edge-function-trigger`
2. **Add task trigger code**: The edge function imports the Trigger.dev SDK and uses `tasks.trigger()` to invoke tasks with a payload
3. **Deploy**: Run `supabase functions deploy edge-function-trigger --no-verify-jwt`

## Configuration Requirements

Before triggering tasks, you must add your Trigger.dev production secret key to Supabase:

1. Copy your `prod` secret key from Trigger.dev's API keys page
2. In Supabase, navigate to Project Settings > Edge functions
3. Click "Add new secret" and set `TRIGGER_SECRET_KEY` to your copied key

## Deployment and Testing

After deploying your task with `npx trigger.dev@latest deploy`, access your edge function's URL to trigger it. Successful runs will appear in your Trigger.dev cloud dashboard.

## Troubleshooting

If you encounter runtime errors with the SDK in Deno, use the Tasks API directly with `fetch` instead, avoiding SDK dependency issues specific to the Deno runtime.

## Additional Resources

- Database webhook integration
- Supabase authentication patterns
- Code examples for database operations and storage uploads
