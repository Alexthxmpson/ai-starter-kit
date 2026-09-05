# Retrieve a database

**Source:** https://developers.notion.com/reference/retrieve-a-database
**Date:** 2026-03-01

---

> **Deprecated as of version 2025-09-03**
> This page describes the API for versions up to and including `2022-06-28`. In the new `2025-09-03` version, the concepts of databases and data sources were split up.
> Refer to the new APIs instead: Retrieve a database (`/reference/database-retrieve`) and Retrieve a data source (`/reference/retrieve-a-data-source`).

Retrieves a database object — information that describes the structure and columns of a database — for a provided database ID.

To fetch database rows rather than columns, use the Query a database endpoint.

To find a database ID, navigate to the database URL in your Notion workspace. The ID is the string of characters in the URL between the slash following the workspace name and the question mark. It is a 32-character alphanumeric string.

## Endpoint

```
GET /v1/databases/{database_id}
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

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.databases.retrieve({
  database_id: "d9824bdc-8445-4327-be8b-5b47500af6ce"
})
```

## Notes

> **Info — Database relations must be shared with your integration**
> To retrieve database properties from database relations, the related database must be shared with your integration in addition to the database being retrieved.

> **Warning — The Notion API does not support retrieving linked databases.**
> To fetch the information in a linked database, share the original source database with your Notion integration.

## Additional resources

- How to share a database with your integration
- Working with databases guide

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
