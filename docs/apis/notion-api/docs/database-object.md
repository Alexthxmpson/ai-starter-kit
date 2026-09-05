# Database

**Source:** https://developers.notion.com/reference/database
**Date:** 2026-03-01

---

A **database** is an object that contains one or more data sources. Databases can either be displayed inline in the parent page (`is_inline: true`) or as a full page (`is_inline: false`). The properties (schema) of each data source under a database can be maintained independently, and each data source has its own set of rows (pages).

Individual data sources don't have permissions settings, so the set of Notion users and bots that have access to data source children is managed through **databases**.

> **Note — Changed as of 2025-09-03**
> In September 2025, the Data source object was introduced, and includes the `properties` that used to exist here at the database level.
> After upgrading your API integration to `2025-09-03`, the new database object shape is displayed, including an array of child `data_sources` but **not** the data source `properties`.

## Object fields

| Field | Type | Description | Example value |
|-------|------|-------------|---------------|
| `object` | `string` | Always `"database"`. | `"database"` |
| `id` | `string` (UUID) | Unique identifier for the database. | `"2f26ee68-df30-4251-aad4-8ddc420cba3d"` |
| `data_sources` | array of data source objects | List of child data sources, each of which is a JSON object with an `id` and `name`. Use Retrieve a data source to get more details on the data source, including its `properties`. | `[{"id": "c174b72c-d782-432f-8dc0-b647e1c96df6", "name": "Tasks data source"}]` |
| `created_time` | `string` (ISO 8601 date and time) | Date and time when this database was created. | `"2020-03-17T19:10:04.968Z"` |
| `created_by` | Partial User | User who created the database. | `{"object": "user","id": "45ee8d13-687b-47ce-a5ca-6e2e45548c4b"}` |
| `last_edited_time` | `string` (ISO 8601 date and time) | Date and time when this database was updated. | `"2020-03-17T21:49:37.913Z"` |
| `last_edited_by` | Partial User | User who last edited the database. | `{"object": "user","id": "45ee8d13-687b-47ce-a5ca-6e2e45548c4b"}` |
| `title` | array of rich text objects | Name of the database as it appears in Notion. | See rich text object |
| `description` | array of rich text objects | Description of the database as it appears in Notion. | |
| `icon` | File Object or Emoji object | Page icon. | |
| `cover` | File object | Page cover image. | |
| `parent` | `object` | Information about the database's parent. See Parent object. | `{ "type": "page_id", "page_id": "af5f89b5-a8ff-4c56-a5e8-69797d11b9f8" }` |
| `url` | `string` | The URL of the Notion database. | `"https://www.notion.so/668d797c76fa49349b05ad288df2d136"` |
| `archived` | `boolean` | **Deprecated.** Use `in_trash` instead. Alias for `in_trash`. | `false` |
| `in_trash` | `boolean` | Whether the database has been trashed. | `false` |
| `is_inline` | `boolean` | Has the value `true` if the database appears in the page as an inline block. Otherwise has the value `false` if the database appears as a child page. | `false` |
| `public_url` | `string` | The public page URL if the page has been published to the web. Otherwise, `null`. | `"https://jm-testing.notion.site/p1-6df2c07bfc6b4c46815ad205d132e22d"` |
