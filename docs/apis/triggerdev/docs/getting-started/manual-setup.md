---
source: https://trigger.dev/docs/manual-setup
scraped: 2026-02-28
---

# Manual Setup for Trigger.dev

## Overview

This guide provides instructions for manually setting up Trigger.dev in a project, replicating the steps performed by the `trigger.dev init` command. Prerequisites include Node.js 18.20+, a Trigger.dev account, and TypeScript 5.0.4+ for TypeScript projects.

## Authentication & Installation

Users must first authenticate via `npx trigger.dev@latest login`, then install packages: `@trigger.dev/sdk@latest` and `@trigger.dev/build@latest` (dev dependency). The `TRIGGER_SECRET_KEY` environment variable, obtained from the project dashboard's API Keys page, enables local development authentication.

## Configuration

A `trigger.config.ts` file in the project root specifies the project reference, task directories, retry policies, and maximum task duration (default 3600 seconds). The Bun runtime can be specified as an alternative to Node.js.

## Task Creation

Users create a trigger directory and add tasks using the SDK's `task()` function. A basic example: "a task with ID `hello-world` accepts a name payload and returns a greeting message with a timestamp."

## Additional Setup

TypeScript projects should include `trigger.config.ts` in `tsconfig.json`. The `.trigger` directory should be added to `.gitignore`. For React frontends, the `@trigger.dev/react-hooks` package enables real-time task monitoring through public access tokens.

## Monorepo Strategies

Two approaches support monorepo architectures: creating a dedicated tasks package shared across applications, or installing Trigger.dev directly in individual apps. The tasks-as-package approach suits shared task requirements; the app-based approach works better for app-specific background tasks.

## Development

The CLI runs via `npx trigger.dev@latest dev` or as a dev dependency with custom npm scripts. Version consistency across SDK, build tools, and CLI prevents warnings during deployment.
