# Retrieve your token's bot user

**Source:** https://developers.notion.com/reference/get-self
**Date:** 2026-03-01

---

Retrieves the bot User associated with the API token provided in the authorization header. The bot will have an `owner` field with information about the person who authorized the integration.

## Endpoint

```
GET /v1/users/me
```

## Authentication

**Authorization** (header, required): `Bearer <token>`

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Integration capabilities

This endpoint is accessible from integrations with **any level of capabilities**. The user object returned will adhere to the limitations of the integration's capabilities.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.users.me()
```

## Response (200)

Returns a Person or Bot user object. Example Person response:

```json
{
  "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "object": "user",
  "name": "<string>",
  "avatar_url": "<string>",
  "type": "person",
  "person": {
    "email": "<string>"
  }
}
```

### Response fields (Person)

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string<uuid>` | The ID of the user |
| `object` | `string` | Always `"user"` |
| `name` | `string \| null` | The name of the user |
| `avatar_url` | `string \| null` | The avatar URL of the user |
| `type` | `string` | `"person"` for a person user |
| `person` | `object` | Details about the person (includes `email`) |

For a bot user, `type` is `"bot"` and the object includes a `bot` sub-object with `owner`, `workspace_name`, `workspace_id`, and workspace limits.

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
