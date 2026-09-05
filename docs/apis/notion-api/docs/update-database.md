# Update a database

**Source:** https://developers.notion.com/reference/update-a-database
**Date:** 2026-03-01

---

> **Deprecated as of version 2025-09-03**
> This page describes the API for versions up to and including `2022-06-28`. In the new `2025-09-03` version, the concepts of databases and data sources were split up.
> Refer to the new APIs instead: Update a database (`/reference/database-update`) and Update a data source (`/reference/update-a-data-source`).

Updates an existing database as specified by the parameters.

## Endpoint

```
PATCH /v1/databases/{database_id}
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
| `database_id` | `string` | required | ID of a Notion database, a container for one or more data sources. |

## Request body (application/json)

| Parameter | Type | Description |
|-----------|------|-------------|
| `parent` | object | The parent page or workspace. Can be: Page Id or Workspace. |
| `title` | array of rich text objects | The title of the database. Maximum array length: 100. |
| `description` | array of rich text objects | The description of the database. Maximum array length: 100. |
| `is_inline` | boolean | Whether the database should be displayed inline in the parent page. |
| `icon` | object | The icon for the database. Can be: File Upload, Emoji, External, or Custom Emoji. |
| `cover` | object | The cover image for the database. Can be: File Upload or External. |
| `in_trash` | boolean | Set to `true` to move the database to trash. |
| `is_locked` | boolean | Whether the database should be locked from editing in the Notion app UI. |

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.databases.update({
  database_id: "d9824bdc-8445-4327-be8b-5b47500af6ce",
  title: [{ text: { content: "Updated Database Title" } }]
})
```

## Behavior

- Updating a database property's type will preserve as much data as possible.
- To update database rows (pages inside a database), use the **Update page properties** endpoint instead.
- The recommended schema size limit is **50KB**. If a schema update exceeds this limit, a `validation_error` is returned.

## Limitations

The following property types **cannot** be updated via the API:

- `formula` properties
- `select` properties
- `status` properties
- Synced content
- `multi_select` options values

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
