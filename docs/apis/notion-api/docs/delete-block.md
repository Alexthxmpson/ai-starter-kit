# Delete a block

**Source:** https://developers.notion.com/reference/delete-a-block
**Date:** 2026-03-01

---

Sets a Block object, including page blocks, to `in_trash: true` using the ID specified. In the Notion UI application, this moves the block to the "Trash" where it can still be accessed and restored.

To restore the block with the API, use the Update a block or Update page endpoints respectively.

## Endpoint

```
DELETE /v1/blocks/{block_id}
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
| `block_id` | `string` | required | The ID of the block to delete. |

## Integration capabilities

This endpoint requires an integration to have **update content capabilities**. Attempting to call this API without update content capabilities will return an HTTP response with a 403 status code.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.blocks.delete({
  block_id: "c02fc1d3-db8b-45c5-a222-27595b15aea7"
})
```

## Response (200)

Returns the deleted block object with `in_trash: true`.

```json
{
  "object": "<string>",
  "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `object` | `string` | Always `"block"` |
| `id` | `string<uuid>` | The block ID |

## Errors

Returns a 404 HTTP response if the block doesn't exist, or if the integration doesn't have access to the block.

Returns a 400 or 429 HTTP response if the request exceeds the request limits.

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
