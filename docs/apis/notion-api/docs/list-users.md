# List all users

**Source:** https://developers.notion.com/reference/get-users
**Date:** 2026-03-01

---

Returns a paginated list of Users for the workspace. The response may contain fewer than `page_size` of results.

Guests are **not** included in the response.

## Endpoint

```
GET /v1/users
```

## Authentication

**Authorization** (header, required): `Bearer <token>`

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `start_cursor` | `string` | Cursor for pagination. |
| `page_size` | `number` | Number of results per page. |

## Notes

- Guests are not included in the response.
- See Pagination for details about how to use a cursor to iterate through the list.
- The API does not currently support filtering users by their email and/or name.

## Integration capabilities

This endpoint requires an integration to have **user information capabilities**. Attempting to call this API without user information capabilities will return an HTTP response with a 403 status code.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.users.list({
  start_cursor: undefined,
  page_size: 10
})
```

## Response (200)

```json
{
  "type": "user",
  "user": {},
  "object": "list",
  "next_cursor": "<string>",
  "has_more": true,
  "results": [
    {
      "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
      "object": "<string>",
      "name": "<string>",
      "avatar_url": "<string>",
      "type": "<string>",
      "person": {
        "email": "<string>"
      }
    }
  ]
}
```

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | `string` | Always `"user"` |
| `user` | `object` | User metadata |
| `object` | `string` | Always `"list"` |
| `next_cursor` | `string \| null` | Cursor for the next page |
| `has_more` | `boolean` | Whether more results exist |
| `results` | `array` | Array of Person or Bot user objects |

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
