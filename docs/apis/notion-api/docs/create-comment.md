# Create comment

**Source:** https://developers.notion.com/reference/create-a-comment
**Date:** 2026-03-01

---

Creates a comment in a page, block or existing discussion thread.

## Endpoint

```
POST /v1/comments
```

## Authentication

**Authorization** (header, required): `Bearer <token>`

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Request body (application/json)

There are three locations where a new comment can be added with the public API:
- A page
- A block
- An existing discussion thread

The request body differs depending on which type of comment is being added.

**Either** the `parent.page_id`, `parent.block_id`, **or** `discussion_id` parameter must be provided — ONLY one can be specified.

### Option 1: Comment on a page or block (with parent)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `rich_text` | `array` | required | An array of rich text objects (Text, Mention, or Equation) representing the comment content. Maximum array length: 100. |
| `parent` | `object` | required | The parent of the comment. Can be a page (`page_id`) or a block (`block_id`). |
| `attachments` | `object[]` | | Files to attach to the comment. Maximum of 3 allowed. |
| `display_name` | `object` | | Display name for the comment. Can be Integration, User, or Custom type. |

### Option 2: Comment on an existing discussion thread

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `rich_text` | `array` | required | An array of rich text objects for the comment content. |
| `discussion_id` | `string` | required | The ID of the existing discussion thread to reply to. |
| `attachments` | `object[]` | | Files to attach. Maximum of 3. |
| `display_name` | `object` | | Display name for the comment. |

> Note: Inline comments to start a new discussion thread cannot be created via the public API.

## Integration capabilities

> **Reminder: Turn on integration comment capabilities**
> Integration capabilities for reading and inserting comments are **off by default**.
> This endpoint requires an integration to have **insert comment capabilities**. Attempting to call this endpoint without insert comment capabilities will return an HTTP response with a 403 status code.
> To update your integration settings, visit the integration dashboard.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.comments.create({
  parent: { page_id: "b55c9c91-384d-452b-81db-d1ef79372b75" },
  rich_text: [{ text: { content: "This is a comment" } }]
})
```

## Response (200)

Returns a comment object for the created comment.

```json
{
  "object": "comment",
  "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a"
}
```

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `object` | `string` | Always `"comment"` |
| `id` | `string<uuid>` | The ID of the created comment |

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
