# Create a database

**Source:** https://developers.notion.com/reference/create-a-database
**Date:** 2026-03-01

---

> **Deprecated as of version 2025-09-03**
> This page describes the API for versions up to and including `2022-06-28`. In the new `2025-09-03` version, the concepts of databases and data sources were split up.
> Refer to the new APIs instead: Create a database (`/reference/database-create`) and Create a data source (`/reference/create-a-data-source`).

Creates a database as a subpage in the specified parent page, with the specified `properties` schema. Currently, the parent of a new database must be a Notion page or a wiki database.

## Endpoint

```
POST /v1/databases
```

## Authentication

**Authorization** (header, required): `Bearer <token>`

## Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `Notion-Version` | `enum<string>` | required | The API version. Latest: `2025-09-03` |

## Request body (application/json)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `parent` | object | required | The parent page or workspace where the database will be created. Can be: Page Id or Workspace. |
| `title` | array of rich text objects | | The title of the database. Maximum array length: 100. |
| `description` | array of rich text objects | | The description of the database. Maximum array length: 100. |
| `is_inline` | boolean | | Whether the database should be displayed inline in the parent page. Defaults to false. |
| `initial_data_source` | object | | Initial data source configuration for the database. |
| `icon` | object | | The icon for the database. Can be: File Upload, Emoji, External, or Custom Emoji. |
| `cover` | object | | The cover image for the database. Can be: File Upload or External. |

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.databases.create({
  parent: {
    type: "page_id",
    page_id: "b55c9c91-384d-452b-81db-d1ef79372b75"
  },
  title: [{ text: { content: "My Database" } }]
})
```

## Integration capabilities

This endpoint requires an integration to have insert content capabilities. Attempting to call this API without insert content capabilities will return an HTTP response with a 403 status code.

## Limitations

Creating new `status` database properties is currently not supported.

## Errors

Returns a 404 if the specified parent page does not exist, or if the integration does not have access to the parent page.

Returns a 400 if the request is incorrectly formatted, or a 429 HTTP response if the request exceeds the request limits.
