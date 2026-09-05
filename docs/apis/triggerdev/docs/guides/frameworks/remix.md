---
source: https://trigger.dev/docs/guides/frameworks/remix
scraped: 2026-02-28
---

# Remix Setup Guide for Trigger.dev

## Overview

This guide walks developers through integrating Trigger.dev into an existing Remix project, testing tasks, and deploying to production environments like Vercel.

## Prerequisites

- An existing Remix project with TypeScript installed
- A Trigger.dev account and project created
- Node.js package manager (npm, pnpm, or yarn)

## Initial Setup Process

### Step 1: Run the CLI Init Command

Run `npx trigger.dev@latest init` (or equivalent for pnpm/yarn). This command:

1. Optionally installs the Trigger.dev MCP server for AI assistant integration
2. Authenticates the CLI
3. Prompts project selection
4. Installs necessary SDK packages
5. Creates a `/trigger` directory with an example task
6. Generates a `trigger.config.ts` configuration file

### Step 2: Start the Development Server

Run `npx trigger.dev@latest dev` to start a local server that monitors the `/trigger` directory, registers tasks with the Trigger.dev platform, and manages task execution.

### Step 3: Test via Dashboard

The dev command outputs useful URLs. Navigate to the Test page to find the Example task, configure options, and execute a test run using the "Run test" button.

### Step 4: View Run Results

The dashboard displays live-updated run information, while the terminal shows task status and links to detailed run logs.

## Authentication Configuration

Set the `TRIGGER_SECRET_KEY` environment variable in `.env`. This key is available in the Trigger.dev dashboard under API Keys (selecting the DEV secret key).

## Triggering Tasks in Remix

### Creating an API Route

Create `app/routes/api.hello-world.ts`:

```typescript
import type { helloWorldTask } from "../../src/trigger/example";
import { tasks } from "@trigger.dev/sdk";

export async function loader() {
  const handle = await tasks.trigger<typeof helloWorldTask>("hello-world", "James");
  return new Response(JSON.stringify(handle), {
    headers: { "Content-Type": "application/json" },
  });
}
```

After running both the Remix dev server and the Trigger.dev dev server, accessing `http://localhost:3000/api/trigger` executes the task.

## Environment Variables

Optional environment variables can be managed through the Trigger.dev dashboard's "Environment Variables" page, supporting separate values for local dev, staging, and production environments.

## Deployment Options

### Manual Deployment

Run `npx trigger.dev@latest deploy` to manually deploy tasks.

### Alternative Deployment Methods

- **GitHub Actions**: Automatically deploy when code is pushed and `/trigger` directory changes
- **Vercel Integration**: Integration development in progress

## Deploying to Vercel Edge Functions

Vercel deployment requires several configuration changes:

### 1. Update API Route

Use `runtime: "edge"` configuration and change from `loader` to `action`:

```typescript
export const config = {
  runtime: "edge",
};

export async function action({ request }: { request: Request }) {
  const payload = await request.json();
  const handle = await tasks.trigger<typeof helloWorldTask>("hello-world", payload);
  return new Response(JSON.stringify(handle), {
    headers: { "Content-Type": "application/json" },
  });
}
```

### 2. Create vercel.json

```json
{
  "buildCommand": "npm run vercel-build",
  "devCommand": "npm run dev",
  "framework": "remix",
  "installCommand": "npm install",
  "outputDirectory": "build/client"
}
```

### 3. Update package.json Scripts

Include a `vercel-build` script that runs `remix vite:build && cp -r ./public ./build/client`

### 4. Deploy to Vercel

Push code to Git and create a new Vercel project.

### 5. Add Environment Variables

Set `TRIGGER_SECRET_KEY` in Vercel project settings.

### 6. Test Production

Use curl to POST to the deployed endpoint:

```bash
curl -X POST https://your-app.vercel.app/api/hello-world \
-H "Content-Type: application/json" \
-d '{"name": "James"}'
```

## Key Considerations

- Type-only imports (`import type { ... }`) ensure edge runtime compatibility
- The `@trigger.dev/sdk` package natively supports edge runtime environments
- The `vercel-build` script correctly handles static asset distribution for Remix on Vercel

## Next Steps

- Task fundamentals and available options
- Writing custom tasks
- CLI-based deployment workflows
- GitHub Actions integration for continuous deployment
