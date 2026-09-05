---
source: https://trigger.dev/docs/apikeys
scraped: 2026-02-28
---

# API Keys

## Authentication and Secret Keys

To trigger tasks from your backend, you must set the `TRIGGER_SECRET_KEY` environment variable. Each environment maintains its own secret key, accessible via the API keys page in the Trigger.dev dashboard.

For preview branches, also configure `TRIGGER_PREVIEW_BRANCH`.

## Automatic SDK Configuration

Set environment variables to enable automatic configuration:

```bash
TRIGGER_SECRET_KEY="tr_dev_…"
TRIGGER_PREVIEW_BRANCH="my-branch"
```

For self-hosted instances, optionally configure a custom URL:

```bash
TRIGGER_API_URL="https://trigger.example.com"
TRIGGER_PREVIEW_BRANCH="my-branch"
```

The default API endpoint is `https://api.trigger.dev`.

## Manual SDK Configuration

Alternatively, use the `configure` method for explicit setup:

```ts
import { configure } from "@trigger.dev/sdk";
import { myTask } from "./trigger/myTasks";

configure({
  secretKey: "tr_dev_1234",
  previewBranch: "my-branch",
  baseURL: "https://mytrigger.example.com",
});

async function triggerTask() {
  await myTask.trigger({ userId: "1234" });
}
```

**Warning:** Never hardcode secret keys in source code.
