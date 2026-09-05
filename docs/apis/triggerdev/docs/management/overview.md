---
source: https://trigger.dev/docs/management/overview
scraped: 2026-02-28
---

# Trigger.dev Management API Documentation

## Overview

The Trigger.dev management API enables developers to interact with Trigger.dev functionality programmatically through the SDK.

## Installation

The management API is bundled with the standard Trigger.dev SDK package. Install it using your preferred package manager:

```bash
npm i @trigger.dev/sdk@latest
```

```bash
pnpm add @trigger.dev/sdk@latest
```

```bash
yarn add @trigger.dev/sdk@latest
```

## Getting Started

Access all v3 features through the `@trigger.dev/sdk` module. You can import specific resources or the entire module as needed.

```ts
import { configure, runs } from "@trigger.dev/sdk";

configure({
  secretKey: process.env["TRIGGER_SECRET_KEY"],
});

async function main() {
  const runs = await runs.list({
    limit: 10,
    status: ["COMPLETED"],
  });
}

main().catch(console.error);
```

The `configure()` function establishes your authentication credentials. If the `TRIGGER_SECRET_KEY` environment variable exists, calling `configure()` becomes optional. This example demonstrates querying a list of completed task runs, limited to 10 results.
