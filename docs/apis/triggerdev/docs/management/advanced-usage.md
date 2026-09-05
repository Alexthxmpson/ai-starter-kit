---
source: https://trigger.dev/docs/management/advanced-usage
scraped: 2026-02-28
---

# Advanced Usage

Advanced usage of the Trigger.dev management API.

## Accessing Raw HTTP Responses

All API methods return a `Promise` subclass called `ApiPromise` that provides helpers for accessing the underlying HTTP response:

```ts
import { runs } from "@trigger.dev/sdk";

async function main() {
  const { data: run, response: raw } = await runs.retrieve("run_1234").withResponse();

  console.log(raw.status);
  console.log(raw.headers);

  const response = await runs.retrieve("run_1234").asResponse(); // Returns a Response object

  console.log(response.status);
  console.log(response.headers);
}
```

The `withResponse()` method returns both the parsed data and the raw HTTP response object, allowing you to inspect status codes and headers. Alternatively, use `asResponse()` to receive the Response object directly for more granular control over the HTTP details.
