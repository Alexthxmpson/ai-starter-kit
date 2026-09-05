# Append block children

**Source:** https://developers.notion.com/reference/patch-block-children
**Date:** 2026-03-01

---

Creates and appends new children blocks to the parent `block_id` specified. Blocks can be parented by other blocks, pages, or databases.

## Endpoint

```
PATCH /v1/blocks/{block_id}/children
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
| `block_id` | `string` | required | The ID of the parent block to append children to. |

## Request body (application/json)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `children` | `array` | required | Array of block objects to append. Maximum array length: 100. Supported types: Embed, Bookmark, Image, Video, Pdf, File, Audio, Code, Equation, Divider, Breadcrumb, Table Of Contents, Link To Page, Table Row, Table, Column List, Column, Heading 1/2/3, Paragraph, Bulleted List Item, Numbered List Item, Quote, To Do, Toggle, Template, Callout, Synced Block. |
| `position` | `object` | | Where to insert the blocks (see below). |
| `after` | `string` | | **Deprecated.** Use `position` instead. |

## Controlling insert position

By default, blocks are appended to the **end** of the parent block's children. Use the `position` parameter to insert blocks at a specific location:

| Position type | Description |
|---------------|-------------|
| `{ "type": "end" }` | Insert at the end of the parent's children (default behavior) |
| `{ "type": "start" }` | Insert at the beginning of the parent's children |
| `{ "type": "after_block", "after_block": { "id": "<block_id>" } }` | Insert after the specified block |

**Insert at start example:**

```json
{
  "children": [/* blocks */],
  "position": { "type": "start" }
}
```

> **Warning — Deprecated parameter**
> The `after` parameter is deprecated. Use the `position` parameter instead, which provides more flexibility including inserting at the start of the children list.
>
> If you're currently using `after`, migrate to `position` with type `after_block`:
> - **Before:** `{ "children": [...], "after": "<block_id>" }`
> - **After:** `{ "children": [...], "position": { "type": "after_block", "after_block": { "id": "<block_id>" } } }`
>
> You cannot specify both `after` and `position` in the same request.

## Behavior

- Returns a paginated list of newly created first level children block objects.
- Existing blocks **cannot** be moved using this endpoint. Once a block is appended as a child, it can't be moved elsewhere via the API.
- For blocks that allow children, we allow up to **two** levels of nesting in a single request.
- There is a limit of **100 block children** that can be appended by a single API request.

## Integration capabilities

This endpoint requires an integration to have **insert content capabilities**. Attempting to call this API without insert content capabilities will return an HTTP response with a 403 status code.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.blocks.children.append({
  block_id: "c02fc1d3-db8b-45c5-a222-27595b15aea7",
  children: [
    {
      type: "paragraph",
      paragraph: {
        rich_text: [{ text: { content: "Hello, world!" } }]
      }
    }
  ]
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

## Errors

Returns a 404 HTTP response if the block specified by `id` doesn't exist, or if the integration doesn't have access to the block.

Returns a 400 or 429 HTTP response if the request exceeds the request limits.

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
