---
source: https://trigger.dev/docs/guides/frameworks/prisma
scraped: 2026-02-28
---

# Prisma Setup Guide for Trigger.dev

## Overview

This guide explains how to integrate Prisma ORM with Trigger.dev, including testing and deploying tasks to production.

## Prerequisites

- Node.js project with `package.json`
- TypeScript installed
- PostgreSQL database (local or remote)
- Prisma installed and initialized
- `DATABASE_URL` environment variable configured

## Initial Setup Steps

### 1. Initialize Trigger.dev

Run the CLI initialization command:

```bash
npx trigger.dev@latest init
```

Or use your preferred package manager:

```bash
pnpm dlx trigger.dev@latest init
```

```bash
yarn dlx trigger.dev@latest init
```

The command will install SDK packages, create a `/trigger` directory, and generate a `trigger.config.ts` file.

### 2. Run Development Server

Start the local development server:

```bash
npx trigger.dev@latest dev
```

### 3. Test via Dashboard

Access the Test page from the CLI output to run your example task without payload input.

### 4. View Run Results

Monitor task execution on the run page with live updates.

## Creating and Deploying a Prisma Task

### Step 1: Write the Task

Create `/trigger/prisma-add-new-user.ts`:

```ts
import { PrismaClient } from "@prisma/client";
import { task } from "@trigger.dev/sdk";

const prisma = new PrismaClient();

export const addNewUser = task({
  id: "prisma-add-new-user",
  run: async (payload: { name: string; email: string; id: number }) => {
    const { name, email, id } = payload;

    const user = await prisma.user.create({
      data: {
        name: name,
        email: email,
        id: id,
      },
    });

    return {
      message: `New user added successfully: ${user.id}`,
    };
  },
});
```

**Note:** Your Prisma schema must include a `user` model with `id`, `name`, and `email` fields.

### Step 2: Configure Build Extension

Update `trigger.config.js`:

```js
export default defineConfig({
  project: "<project ref>",
  build: {
    extensions: [
      prismaExtension({
        mode: "legacy",
        version: "5.20.0",
        schema: "prisma/schema.prisma",
      }),
    ],
  },
});
```

The `prismaExtension` bundles the Prisma client for production deployment.

### Step 3: Optional - Add Instrumentation

Enable telemetry for Prisma queries in `trigger.config.js`:

```js
import { defineConfig } from "@trigger.dev/sdk";
import { PrismaInstrumentation } from "@prisma/instrumentation";

export default defineConfig({
  instrumentations: [new PrismaInstrumentation()],
});
```

### Step 4: Deploy

Deploy your task using:

```bash
npx trigger.dev@latest deploy
```

### Step 5: Add Environment Variables

In the Trigger.dev dashboard, navigate to "Environment Variables" and add your `DATABASE_URL` for production.

### Step 6: Test the Task

In the dashboard's Test page, run the task with:

```json
{
  "name": "John Doe",
  "email": "john@doe.test",
  "id": 12345
}
```

The task will create a new user in your database.

## Next Steps

- **Tasks overview** - Learn task fundamentals and options
- **Writing tasks** - Explore task creation techniques
- **CLI deployment** - Manual deployment instructions
- **GitHub Actions** - Automated deployment workflows
