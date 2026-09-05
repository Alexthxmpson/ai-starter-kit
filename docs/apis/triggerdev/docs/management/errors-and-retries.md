---
source: https://trigger.dev/docs/management/errors-and-retries
scraped: 2026-02-28
---

# Errors and Retries

## Error Handling

The Trigger.dev SDK throws an `ApiError` when unable to connect to the API server or when the server returns a non-successful response. Developers can catch and handle these errors:

```ts
import { runs, APIError } from "@trigger.dev/sdk";

async function main() {
  try {
    const run = await runs.retrieve("run_1234");
  } catch (error) {
    if (error instanceof ApiError) {
      console.error(`API error: ${error.status}, ${error.headers}, ${error.body}`);
    } else {
      console.error(`Unknown error: ${error.message}`);
    }
  }
}
```

## Automatic Retries

The SDK implements automatic retry logic with sensible defaults. By default, failed requests are retried up to 3 times using exponential backoff.

Customize retry behavior via the `configure` function:

```ts
import { configure } from "@trigger.dev/sdk";

configure({
  requestOptions: {
    retry: {
      maxAttempts: 5,
      minTimeoutInMs: 1000,
      maxTimeoutInMs: 5000,
      factor: 1.8,
      randomize: true,
    },
  },
});
```

Individual SDK calls accept a `requestOptions` parameter to override global settings:

```ts
import { runs } from "@trigger.dev/sdk";

async function main() {
  const run = await runs.retrieve("run_1234", {
    retry: {
      maxAttempts: 1, // Disable retries
    },
  });
}
```

**Note:** When executing inside a task, the SDK disregards custom retry options for certain functions like `task.trigger` and `task.batchTrigger`, applying task-optimized retry settings instead.
