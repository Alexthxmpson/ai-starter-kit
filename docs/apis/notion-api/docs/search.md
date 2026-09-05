# Search by title

**Source:** https://developers.notion.com/reference/post-search
**Date:** 2026-03-01

---

Searches all parent or child pages and data_sources that have been shared with an integration.

## Endpoint

```
POST /v1/search
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
| `query` | `string` | The search query string. If not provided, all pages/data sources shared with the integration are returned. |
| `filter` | `object` | Filter to limit results to only pages or only data sources. |
| `sort` | `object` | Sort order for results. |
| `start_cursor` | `string<uuid>` | Pagination cursor. |
| `page_size` | `number` | Number of results per page. |

### filter object

Use to limit search to only pages or only data sources:

```json
{
  "property": "object",
  "value": "page"
}
```

or

```json
{
  "property": "object",
  "value": "database"
}
```

### sort object

```json
{
  "direction": "descending",
  "timestamp": "last_edited_time"
}
```

## Behavior

- Returns all pages or data_sources (excluding duplicated linked databases) that have titles including the `query` param.
- If no `query` param is provided, returns all pages or data_sources shared with the integration.
- Results adhere to the integration's capabilities.
- Supports pagination.

> **Warning** — To search a specific data_source (not all sources shared with the integration), use the Query a data_source endpoint instead.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.search({
  query: "meeting notes",
  filter: {
    property: "object",
    value: "page"
  },
  sort: {
    direction: "descending",
    timestamp: "last_edited_time"
  }
})
```

## Response (200)

```json
{
  "type": "page_or_data_source",
  "page_or_data_source": {},
  "object": "list",
  "next_cursor": "<string>",
  "has_more": true,
  "results": [
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
  ]
}
```

### Response fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | `string` | Always `"page_or_data_source"` |
| `page_or_data_source` | `object` | Metadata |
| `object` | `string` | Always `"list"` |
| `next_cursor` | `string \| null` | Pagination cursor |
| `has_more` | `boolean` | Whether more results exist |
| `results` | `object[]` | Array of page or data source objects |

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
