---
source: https://trigger.dev/docs/realtime/auth
scraped: 2026-02-28
---

# Realtime Authentication

Authenticate real-time API requests using Public Access Tokens or Trigger Tokens, which provide secure, scoped access to runs in both frontend and backend applications.

## Token Types

Two token types are available:

- **Public Access Tokens** — Read and subscribe to run data in frontend or backend
- **Trigger Tokens** — Frontend-only, single-use tokens for triggering tasks securely

## Public Access Tokens

### Creating Tokens

Generate tokens in backend code using the `auth.createPublicToken` function:

```tsx
import { auth } from "@trigger.dev/sdk";

const publicToken = await auth.createPublicToken();
```

### Scoping Permissions

By default, tokens have no permissions. Specify scopes when creating:

```ts
const publicToken = await auth.createPublicToken({
  scopes: {
    read: {
      runs: ["run_1234", "run_5678"],
    },
  },
});
```

Available scope options:

- `runs` — Specific run IDs
- `tasks` — All runs for specified tasks
- `tags` — All runs with specified tags
- `batch` — All runs in a batch

Scopes can be combined to restrict access further.

### Expiration

Default expiration is 15 minutes. Customize using the `expirationTime` parameter:

```ts
const publicToken = await auth.createPublicToken({
  expirationTime: "1hr",
});
```

The parameter accepts:

- String time spans (e.g., "24hr", "7 days")
- Unix timestamps (number)
- Date objects

Time span units: "sec", "minute", "hour", "day", "week", "year", etc. Use "ago" or "-" prefix to subtract from current time.

### Auto-Generated Tokens

When triggering tasks from the backend, the returned handle includes a `publicAccessToken`. These expire after 15 minutes by default and scope to the triggered run(s).

### Using Public Access Tokens

Access the Realtime API in backend or frontend applications once authenticated with a token.

## Trigger Tokens

### Creating Tokens

Generate in backend code for frontend task triggering:

```ts
import { auth } from "@trigger.dev/sdk";

const triggerToken = await auth.createTriggerPublicToken("my-task");
```

### Multiple Tasks

Pass an array to enable triggering multiple tasks:

```ts
const triggerToken = await auth.createTriggerPublicToken([
  "my-task-1",
  "my-task-2"
]);
```

### Multiple Use

Enable reuse (use cautiously):

```ts
const triggerToken = await auth.createTriggerPublicToken("my-task", {
  multipleUse: true,
});
```

### Expiration

Default expiration is 15 minutes. Set custom duration:

```ts
const triggerToken = await auth.createTriggerPublicToken("my-task", {
  expirationTime: "24hr",
});
```
