# Query a database

**Source:** https://developers.notion.com/reference/post-database-query
**Date:** 2026-03-01

---

> **Deprecated as of version 2025-09-03**
> This page describes the API for versions up to and including `2022-06-28`. In the new `2025-09-03` version, the concepts of databases and data sources were split up.
> Refer to the new APIs instead: Query a data source (`/reference/query-a-data-source`).

Gets a list of Pages and/or Databases contained in the database, filtered and ordered according to the filter conditions and sort criteria provided in the request. The response may contain fewer than `page_size` of results. If the response includes a `next_cursor` value, refer to the pagination reference for details about how to use a cursor to iterate through the list.

> **Info** — Wiki databases can contain both pages and databases as children.

## Endpoint

```
POST /v1/databases/{database_id}/query
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
| `database_id` | `string` | required | The ID of the database to query. |

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filter_properties` | `string[]` | Supply a list of property IDs to filter which properties are returned in the response. Multiple values can be chained: `?filter_properties=id1&filter_properties=id2`. |

## Request body (application/json)

### Filters

Filters are similar to the filters provided in the Notion UI. The set of filters chained by "And" in the UI is equivalent to having each filter in the array of the compound `"and"` filter. Filters chained by "Or" correspond to the `"or"` compound filter. If no filter is provided, all pages in the database are returned with pagination.

**Compound filter example (And + Or):**

```json
{
  "and": [
    {
      "property": "Done",
      "checkbox": {
        "equals": true
      }
    },
    {
      "or": [
        {
          "property": "Tags",
          "contains": "A"
        },
        {
          "property": "Tags",
          "contains": "B"
        }
      ]
    }
  ]
}
```

**Single filter example:**

```json
{
  "property": "Done",
  "checkbox": {
    "equals": true
  }
}
```

See the [Filter database entries](/reference/post-database-query-filter) reference for the full filter object schema.

### Sorts

Sorts are similar to the sorts provided in the Notion UI. Sorts operate on database properties or page timestamps and can be combined. The order of the sorts in the request matters — earlier sorts take precedence over later ones.

See the [Sort database entries](/reference/post-database-query-sort) reference for the full sort object schema.

## Filtering response properties

Use the `filter_properties` query parameter to limit which properties are returned:

```
https://api.notion.com/v1/databases/[database_id]/query?filter_properties=[property_id_1]
```

Multiple properties:

```
https://api.notion.com/v1/databases/[database_id]/query?filter_properties=[property_id_1]&filter_properties=[property_id_2]
```

With the JavaScript SDK:

```javascript
notion.databases.query({
  database_id: id,
  filter_properties: ["propertyID1", "propertyID2"]
})
```

Property IDs can be determined with the Retrieve a database endpoint.

## Permissions

Before an integration can query a database, the database must be shared with the integration. Attempting to query a database that has not been shared will return an HTTP response with a 404 status code.

To share a database with an integration, click the ••• menu at the top right of a database page, scroll to `Add connections`, and use the search bar to find and select the integration from the dropdown list.

## Integration capabilities

This endpoint requires an integration to have **read content capabilities**. Attempting to call this API without read content capabilities will return an HTTP response with a 403 status code.

## Notes

> **To display the page titles of related pages rather than just the ID:**
> - Add a rollup property to the database which uses a formula to get the related page's title. This works well if you have access to updating the database's schema.
> - Otherwise, retrieve the individual related pages using each page ID.

> **Warning — Formula and Rollup Limitation**
> - If a formula depends on a page property that is a relation, and that relation has more than 25 references, only 25 will be evaluated as part of the formula.
> - Rollups and formulas that depend on multiple layers of relations may not return correct results.

## Errors

Returns a 404 HTTP response if the database doesn't exist, or if the integration doesn't have access to the database.

Returns a 400 or a 429 HTTP response if the request exceeds the request limits.

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
