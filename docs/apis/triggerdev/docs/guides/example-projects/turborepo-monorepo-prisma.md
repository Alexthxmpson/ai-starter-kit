---
source: https://trigger.dev/docs/guides/example-projects/turborepo-monorepo-prisma
scraped: 2026-02-28
---

# Turborepo Monorepo with Prisma

## Overview

The documentation describes two distinct approaches for integrating Prisma and Trigger.dev within a Turborepo monorepo structure. Both examples feature task triggering from a Next.js application using server actions and Prisma for database operations, but differ in their architectural setup.

## Example 1: Shared Packages Approach

This configuration places both Trigger.dev and Prisma as dedicated packages within the monorepo:

**Architecture highlights:**
- `@repo/tasks` package houses Trigger.dev implementation
- `@repo/db` package manages Prisma ORM functionality
- Uses pnpm as the package manager
- Tasks execute via server actions from the Next.js application

**Key structural elements:**
- Trigger.dev configuration includes the Prisma build extension
- Task exports occur through dedicated index files
- The `addNewUser.ts` task manages database user creation
- Prisma version specification is required in `trigger.config.ts`

## Example 2: Integrated Approach

This setup incorporates Trigger.dev directly into the Next.js application while maintaining Prisma as a shared package:

**Architecture highlights:**
- Trigger.dev initialization occurs within `apps/web`
- `@repo/db` remains as the centralized database package
- Tasks are defined locally in the Next.js app's `src/trigger/` directory
- Server actions still trigger task execution

**Key structural elements:**
- Configuration file lives at the application level
- Prisma schema remains in the shared database package
- Task definitions coexist with application code

Both examples utilize Turborepo for workspace management and provide GitHub repositories for reference implementation.
