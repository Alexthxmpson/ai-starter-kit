---
source: https://trigger.dev/docs/guides/frameworks/nextjs
scraped: 2026-02-28
---

# Next.js Setup Guide for Trigger.dev

## Overview

This comprehensive guide explains how to integrate Trigger.dev into an existing Next.js project, whether you're using the App Router, Pages Router, or Server Actions.

## Prerequisites

Before starting, ensure you have:
- An existing Next.js project with TypeScript installed
- A Trigger.dev account and project created

## Initial Setup Process

### Step 1: Run the CLI Init Command

The quickest way to begin involves running the initialization command in your project root:

```bash
npx trigger.dev@latest init
```

This command will:
- Optionally install the Trigger.dev MCP server for AI assistant integration
- Authenticate your CLI if needed
- Prompt you to select your project
- Install required SDK packages
- Create a `/trigger` directory with an example task
- Generate a `trigger.config.ts` file

### Step 2: Start the Dev Server

Launch the development server that manages your tasks:

```bash
npx trigger.dev@latest dev
```

This server watches your `/trigger` directory for changes and communicates with the Trigger.dev platform to register tasks and execute runs.

### Step 3: Test via Dashboard

Access the test page from the URLs provided by the dev command. Select the example task and press "Run test" to verify your setup works correctly.

### Step 4: View Run Results

The run page displays real-time status updates. Your terminal will also show task status and dashboard links.

## Running Next.js and Trigger.dev Concurrently

Add these scripts to your `package.json` to run both servers simultaneously:

```json
{
  "scripts": {
    "trigger:dev": "npx trigger.dev@latest dev",
    "dev": "npx concurrently --kill-others --names \"next,trigger\" --prefix-colors \"yellow,blue\" \"next dev\" \"npm run trigger:dev\""
  }
}
```

Then start both with: `npm run dev`

## Configuration: Secret Key Setup

Set your `TRIGGER_SECRET_KEY` in `.env.local` (App Router) or `.env` (Pages Router). Retrieve the DEV secret key from your dashboard's API Keys page. This authenticates task triggers from your Next.js application.

## Triggering Tasks from Next.js

### App Router Approach

Create a Route Handler at `app/api/hello-world/route.ts`:

```typescript
import type { helloWorldTask } from "@/trigger/example";
import { tasks } from "@trigger.dev/sdk";
import { NextResponse } from "next/server";

export async function GET() {
  const handle = await tasks.trigger<typeof helloWorldTask>(
    "hello-world",
    "James"
  );

  return NextResponse.json(handle);
}
```

Visit `http://localhost:3000/api/hello-world` to trigger the task.

### Server Actions Approach

Create `app/api/actions.ts` with the `"use server"` directive:

```typescript
"use server";

import type { helloWorldTask } from "@/trigger/example";
import { tasks } from "@trigger.dev/sdk";

export async function myTask() {
  try {
    const handle = await tasks.trigger<typeof helloWorldTask>(
      "hello-world",
      "James"
    );

    return { handle };
  } catch (error) {
    console.error(error);
    return { error: "something went wrong" };
  }
}
```

Then in `app/page.tsx`, create a button that calls this function:

```typescript
"use client";

import { myTask } from "./actions";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <button onClick={async () => { await myTask(); }}>
        Trigger my task
      </button>
    </main>
  );
}
```

### Pages Router Approach

Create `pages/api/hello-world.ts`:

```typescript
import { helloWorldTask } from "@/trigger/example";
import { tasks } from "@trigger.dev/sdk";
import type { NextApiRequest, NextApiResponse } from "next";

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<{ id: string }>
) {
  const handle = await tasks.trigger<typeof helloWorldTask>(
    "hello-world",
    "James"
  );

  res.status(200).json(handle);
}
```

## Environment Variables

### Automatic Sync from Vercel (Optional)

Use the `syncVercelEnvVars` build extension in `trigger.config.ts` to automatically synchronize environment variables from your Vercel project:

```typescript
import { defineConfig } from "@trigger.dev/sdk";
import { syncVercelEnvVars } from "@trigger.dev/build/extensions/core";

export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [syncVercelEnvVars()],
  },
});
```

You'll need `VERCEL_ACCESS_TOKEN` and `VERCEL_PROJECT_ID` set as environment variables (and `VERCEL_TEAM_ID` for team projects).

### Manual Setup

In the Trigger.dev dashboard, navigate to Environment Variables and add values for your local dev, staging, and production environments. Access these in your code using `process.env.MY_ENV_VAR`.

## Deploying Tasks

### Manual Deployment

Deploy your tasks using the CLI command:

```bash
npx trigger.dev@latest deploy
```

### Alternative Deployment Methods

- **GitHub Actions**: Automatically deploy whenever code changes
- **Vercel Integration**: Official integration in development

## Troubleshooting

### Next.js Build Failures Without API Key

If your Next.js build fails in GitHub CI due to missing `TRIGGER_SECRET_KEY`, mark relevant routes as dynamic:

```typescript
export const dynamic = "force-dynamic";
```

### Event Handler Issues

When passing functions to React component props like `onClick`, wrap them in arrow functions:

```typescript
// Works:
<Button onClick={() => myTask()}>Trigger my task</Button>

// Doesn't work:
<Button onClick={myTask}>Trigger my task</Button>
```

### Next.js ISR Revalidation

To revalidate cached routes from Trigger.dev tasks, create handlers that call Next.js revalidation functions.

**App Router handler** (`app/api/revalidate/path/route.ts`):

```typescript
import { NextRequest, NextResponse } from "next/server";
import { revalidatePath } from "next/cache";

export async function POST(request: NextRequest) {
  try {
    const { path, type, secret } = await request.json();

    if (secret !== process.env.REVALIDATION_SECRET) {
      return NextResponse.json({ message: "Invalid secret" }, { status: 401 });
    }

    if (!path) {
      return NextResponse.json({ message: "Path is required" }, { status: 400 });
    }

    revalidatePath(path, type);
    return NextResponse.json({ revalidated: true });
  } catch (err) {
    console.error("Error revalidating path:", err);
    return NextResponse.json({ message: "Error revalidating path" }, { status: 500 });
  }
}
```

**Pages Router handler** (`pages/api/revalidate/path.ts`):

```typescript
import type { NextApiRequest, NextApiResponse } from "next";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    if (req.method !== "POST") {
      return res.status(405).json({ message: "Method not allowed" });
    }

    const { path, secret } = req.body;

    if (secret !== process.env.REVALIDATION_SECRET) {
      return res.status(401).json({ message: "Invalid secret" });
    }

    if (!path) {
      return res.status(400).json({ message: "Path is required" });
    }

    await res.revalidate(path);
    return res.json({ revalidated: true });
  } catch (err) {
    console.error("Error revalidating path:", err);
    return res.status(500).json({ message: "Error revalidating path" });
  }
}
```

Create a revalidation task in `trigger/revalidate-path.ts`:

```typescript
import { logger, task } from "@trigger.dev/sdk";

const NEXTJS_APP_URL = process.env.NEXTJS_APP_URL;
const REVALIDATION_SECRET = process.env.REVALIDATION_SECRET;

export const revalidatePath = task({
  id: "revalidate-path",
  run: async (payload: { path: string }) => {
    const { path } = payload;

    try {
      const response = await fetch(`${NEXTJS_APP_URL}/api/revalidate/path`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          path: `${NEXTJS_APP_URL}/${path}`,
          secret: REVALIDATION_SECRET,
        }),
      });

      if (response.ok) {
        logger.log("Path revalidation successful", { path });
        return { success: true };
      } else {
        logger.error("Path revalidation failed", {
          path,
          statusCode: response.status,
          statusText: response.statusText,
        });
        return {
          success: false,
          error: `Revalidation failed with status ${response.status}`,
        };
      }
    } catch (error) {
      logger.error("Path revalidation encountered an error", {
        path,
        error: error instanceof Error ? error.message : String(error),
      });
      return {
        success: false,
        error: "Failed to revalidate path due to an unexpected error",
      };
    }
  },
});
```

Test this task using the payload:

```json
{
  "path": "<path-to-revalidate>"
}
```

Remember to set `REVALIDATION_SECRET` in your local `.env.local`, Vercel project settings, and Trigger.dev dashboard environment variables.

## Next Steps

- Explore the [Tasks Overview](/tasks/overview) to understand task capabilities
- Learn [Writing Tasks](/writing-tasks-introduction) for custom implementations
- Review [CLI Deployment](/cli-deploy) for manual deployment details
- Set up [GitHub Actions](/github-actions) for automated deployments
