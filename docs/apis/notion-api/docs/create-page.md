# Create a page

**Source:** https://developers.notion.com/reference/post-page
**Date:** 2026-03-01

---

Use this API to create a new page as a child of an existing page or data source.

## Endpoint

```
POST /v1/pages
```

## Authentication

**Authorization** (header, required): `Bearer <token>`

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Request body (application/json)

| Parameter | Type | Description |
|-----------|------|-------------|
| `parent` | object | The parent of the new page. Can be: Page Id, Database Id, Data Source Id, or Workspace. |
| `properties` | object | Property values of the new page. If parent is a page, only `title` is valid. If parent is a data source, keys must match the data source's property schema. |
| `icon` | object | Page icon. Can be: File Upload, Emoji, External, or Custom Emoji. |
| `cover` | object | Page cover image. Can be: File Upload or External. |
| `content` | array of block objects | Page content blocks. Maximum array length: 100. Mutually exclusive with `markdown`. |
| `children` | array of block objects | Child blocks for the page. Maximum array length: 100. |
| `markdown` | string | Page content as Notion-flavored Markdown. Mutually exclusive with `content`/`children`. |
| `template` | object | Template to apply when creating the page. See template options below. |

## Use cases

### Choosing a parent

In most cases, provide a `page_id` or `data_source` under the `parent` parameter to create a page under an existing page or data source.

There is a 3rd option, available only for bots of public integrations: creating a private page at the workspace level. To do this, omit the `parent` parameter, or provide `parent[workspace]=true`.

For internal integrations, a page or data source parent is currently required.

### Setting up page properties

If the new page is a child of an existing page, `title` is the only valid property in the `properties` body parameter.

If the new page is a child of an existing data source, the keys of the `properties` object body param must match the parent data source's properties.

### Setting up page content

This endpoint can be used to create a new page with or without content using the `children` option. To add content to a page after creating it, use the Append block children endpoint.

**Templates**: The `template` body parameter can be used to specify an existing data source template to populate the content and properties of the new page.

When omitted, the default is `template[type]=none`. Other options for `template[type]`:
- `default`: Apply the data source's default template. Only allowed for pages created under a data source that has a default template configured.
- `template_id`: Provide a specific `template_id` to use as the blueprint for your page.

When applying a template, the `children` parameter is **not** allowed. The page is returned blank initially, and then Notion's systems apply the template asynchronously.

## General behavior

Returns a new page object.

> **Warning — Some page `properties` are not supported via the API**
> A request body that includes `rollup`, `created_by`, `created_time`, `last_edited_by`, or `last_edited_time` values in the properties object returns an error. These Notion-generated values cannot be created or updated via the API.

> **Info — Requirements**
> Your integration must have **Insert Content capabilities** on the target parent page or database. Attempting a query without insert content capabilities returns HTTP 403.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.pages.create({
  parent: {
    data_source_id: "d9824bdc-8445-4327-be8b-5b47500af6ce"
  },
  properties: {
    Name: {
      title: [{ text: { content: "New Page Title" } }]
    }
  }
})
```

## Response (200)

```json
{
  "object": "<string>",
  "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
  "created_time": "2023-11-07T05:31:56Z",
  "last_edited_time": "2023-11-07T05:31:56Z",
  "archived": true,
  "in_trash": true,
  "is_locked": true,
  "url": "<string>",
  "public_url": "<string>",
  "parent": {
    "type": "<string>",
    "database_id": "3c90c3cc-0d44-4b50-8888-8dd25736052a"
  },
  "properties": {},
  "icon": {
    "type": "<string>",
    "emoji": "<string>"
  },
  "cover": {
    "type": "<string>",
    "file": {
      "url": "<string>",
      "expiry_time": "2023-11-07T05:31:56Z"
    }
  },
  "created_by": {
    "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
    "object": "<string>"
  },
  "last_edited_by": {
    "id": "3c90c3cc-0d44-4b50-8888-8dd25736052a",
    "object": "<string>"
  }
}
```

## Error codes

Returns standard error codes (400, 401, 403, 404, 409, 429, 500, 503). See Status codes documentation.
