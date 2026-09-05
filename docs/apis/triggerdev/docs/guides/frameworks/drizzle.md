---
source: https://trigger.dev/docs/guides/frameworks/drizzle
scraped: 2026-02-28
---

# Drizzle Setup Guide for Trigger.dev

## Overview

This guide demonstrates integrating Drizzle ORM with Trigger.dev to create and deploy database tasks. The documentation covers initial setup, task creation, and production deployment.

## Key Prerequisites

- Node.js project with TypeScript
- PostgreSQL database (local or remote)
- Drizzle ORM already initialized
- `DATABASE_URL` environment variable configured

## Initial Setup Steps

### 1. Initialize Trigger.dev

Run the initialization command appropriate for your package manager (npm, pnpm, or yarn). This creates a `/trigger` folder, installs SDK packages, and generates a `trigger.config.ts` file.

### 2. Start Development Server

The CLI dev command launches a task server that monitors the `/trigger` directory and synchronizes with the Trigger.dev platform.

### 3. Test Initial Setup

Access the dashboard test page to run the provided example task without requiring any input payload.

### 4. View Run Results

The dashboard displays live-updated run information, while the terminal shows task status and run log links.

## Creating a Drizzle Task

The provided example creates a task for adding users to a database:

```typescript
import { eq } from "drizzle-orm";
import { task } from "@trigger.dev/sdk";
import { users } from "src/db/schema";
import { drizzle } from "drizzle-orm/node-postgres";

const db = drizzle(process.env.DATABASE_URL!);

export const addNewUser = task({
  id: "drizzle-add-new-user",
  run: async (payload: typeof users.$inferInsert) => {
    const [user] = await db.insert(users).values(payload).returning();
    return {
      createdUser: user,
      message: "User created and updated successfully",
    };
  },
});
```

## Build Configuration

Add `pg` to the externals array in `trigger.config.js` to prevent bundling the PostgreSQL client:

```javascript
export default defineConfig({
  project: "<project ref>",
  build: {
    externals: ["pg"],
  },
});
```

## Production Deployment

1. Deploy using CLI: `npx trigger.dev@latest deploy`
2. Add `DATABASE_URL` via the dashboard's Environment Variables section
3. Test the deployed task with sample user data (name, age, email)

## Next Steps

- Review task fundamentals and options
- Explore task writing practices
- Implement CI/CD deployment via GitHub Actions
