---
source: https://trigger.dev/docs/management/runs/add-tags
scraped: 2026-02-28
---

# Add Tags to a Run

Adds one or more tags to a run. Runs can have a maximum of 10 tags. Duplicate tags are ignored.

## Endpoint

**POST** `/api/v1/runs/{runId}/tags`

## Authentication

Requires a Secret API key (Bearer token). Keys start with `tr_dev_`, `tr_prod`, `tr_stg`, etc.

## Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `runId` | string | Yes | The run ID, starts with `run_`. Example: `run_1234` |

## Request Body

```json
{
  "tags": ["tag-1", "tag-2"]
}
```

The `tags` field accepts either:
- A single string (max 128 characters)
- An array of strings (max 10 items, each max 128 characters, unique)

## Response (200)

```json
{
  "message": "Successfully set 2 new tags."
}
```

## Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid request |
| 401 | Invalid or Missing API Key |
| 422 | Too many tags |

## Code Examples

### TypeScript SDK

```typescript
import { runs } from "@trigger.dev/sdk";

await runs.addTags("run_1234", ["tag-1", "tag-2"]);
```

### Fetch API

```typescript
await fetch("https://api.trigger.dev/api/v1/runs/run_1234/tags", {
  method: "POST",
  headers: {
    "Authorization": `Bearer ${process.env.TRIGGER_SECRET_KEY}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({ tags: ["tag-1", "tag-2"] }),
});
```
