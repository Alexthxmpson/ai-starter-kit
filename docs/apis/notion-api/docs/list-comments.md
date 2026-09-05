# List comments

**Source:** https://developers.notion.com/reference/list-comments
**Date:** 2026-03-01

---

Retrieves a list of un-resolved Comment objects from a page or block.

## Endpoint

```
GET /v1/comments
```

## Authentication

**Authorization** (header, required): `Bearer <token>`

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `block_id` | `string` | required | Identifier for a Notion block or page. |
| `start_cursor` | `string` | | If supplied, returns results starting after the cursor provided. If not supplied, returns the first page of results. |
| `page_size` | `integer` | | The number of items from the full list desired in the response. Maximum: 100. Required range: `1 <= x <= 100`. |

## Notes

- See Pagination for details about how to use a cursor to iterate through the list.

> **Reminder: Turn on integration comment capabilities**
> Integration capabilities for reading and inserting comments are off by default.
> This endpoint requires an integration to have **read comment capabilities**. Attempting to call this endpoint without read comment capabilities will return an HTTP response with a 403 status code.
> To update your integration settings, visit the integration dashboard.

## Integration capabilities

This endpoint requires an integration to have **read comment capabilities**. Integration capabilities for comments are off by default and must be explicitly enabled.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.comments.list({
  block_id: "b55c9c91-384d-452b-81db-d1ef79372b75",
  start_cursor: undefined,
  page_size: 50
})
```

## Response (200)

```json
{
  "object": "list",
  "next_cursor": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "has_more": true,
  "type": "comment",
  "comment": {},
  "results": [
    {
      "object": "<string>",
      "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
      "parent": {
        "type": "<string>",
        "page_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a"
      },
      "discussion_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
      "created_time": "2023-11-07T05:31:56Z",
      "last_edited_time": "2023-11-07T05:31:56Z",
      "created_by": {
        "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
        "object": "<string>"
      },
      "rich_text": [
        {
          "plain_text": "<string>",
          "href": "<string>",
          "annotations": {
            "bold": true,
            "italic": true,
            "strikethrough": true,
            "underline": true,
            "code": true,
            "color": "default"
          },
          "type": "<string>",
          "text": {
            "content": "<string>",
            "link": {
              "url": "<string>"
            }
          }
        }
      ],
      "display_name": {
        "type": "custom",
        "resolved_name": "<string>"
      },
      "attachments": [
        {
          "category": "audio",
          "file": {
            "url": "<string>",
            "expiry_time": "2023-11-07T05:31:56Z"
          }
        }
      ]
    }
  ]
}
```

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `object` | `string` | Always `"list"` |
| `next_cursor` | `string<uuid> \| null` | Pagination cursor |
| `has_more` | `boolean` | Whether more results exist |
| `type` | `string` | Always `"comment"` |
| `comment` | `object` | Comment metadata |
| `results` | `object[]` | Array of comment objects |

### Comment object fields

| Field | Type | Description |
|-------|------|-------------|
| `object` | `string` | Always `"comment"` |
| `id` | `string<uuid>` | Comment ID |
| `parent` | `object` | Parent page or block reference |
| `discussion_id` | `string<uuid>` | The discussion thread this comment belongs to |
| `created_time` | `datetime` | When the comment was created |
| `last_edited_time` | `datetime` | When the comment was last edited |
| `created_by` | `object` | The user who created the comment |
| `rich_text` | `array` | The comment content as rich text |
| `display_name` | `object` | Display name configuration |
| `attachments` | `array` | File attachments on the comment |

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
