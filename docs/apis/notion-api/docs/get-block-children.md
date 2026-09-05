# Retrieve block children

**Source:** https://developers.notion.com/reference/get-block-children
**Date:** 2026-03-01

---

Returns a paginated array of child block objects contained in the block using the ID specified. In order to receive a complete representation of a block, you may need to recursively retrieve the block children of child blocks.

> Page content is represented by block children. See the Working with page content guide for more information.

## Endpoint

```
GET /v1/blocks/{block_id}/children
```

## Authentication

**Authorization** (header, required): `Bearer <token>`

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `block_id` | `string` | required | The ID of the block whose children to retrieve. |

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `start_cursor` | `string<uuid>` | Cursor for pagination. Pass `next_cursor` from a previous response to get the next page. |
| `page_size` | `number` | Number of results to return per page. |

## Notes

- Returns only the **first level of children** for the specified block. See block objects for more detail on determining if that block has nested children.
- The response may contain fewer than `page_size` of results.
- See Pagination for details about how to use a cursor to iterate through the list.

## Integration capabilities

This endpoint requires an integration to have **read content capabilities**. Attempting to call this API without read content capabilities will return an HTTP response with a 403 status code.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.blocks.children.list({
  block_id: "c02fc1d3-db8b-45c5-a222-27595b15aea7",
  start_cursor: undefined,
  page_size: 50
})
```

## Response (200)

```json
{
  "type": "block",
  "block": {},
  "object": "list",
  "next_cursor": "<string>",
  "has_more": true,
  "results": [
    {
      "object": "<string>",
      "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a"
    }
  ]
}
```

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | `string` | Always `"block"` |
| `block` | `object` | Block metadata |
| `object` | `string` | Always `"list"` |
| `next_cursor` | `string \| null` | Cursor to retrieve the next page of results |
| `has_more` | `boolean` | Whether there are more results |
| `results` | `array` | Array of block objects. Possible types: Paragraph, Heading 1/2/3, Bulleted List Item, Numbered List Item, Quote, To Do, Toggle, Template, Synced Block, Child Page, Child Database, Equation, Code, Callout, Divider, Breadcrumb, Table Of Contents, Column List, Column, Link To Page, Table, Table Row, Embed, Bookmark, Image, Video, Pdf, File, Audio, Link Preview, Unsupported |

## Errors

Returns a 404 HTTP response if the block specified by `id` doesn't exist, or if the integration doesn't have access to the block.

Returns a 400 or 429 HTTP response if the request exceeds the request limits.

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
