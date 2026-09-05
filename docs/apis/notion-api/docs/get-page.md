# Retrieve a page

**Source:** https://developers.notion.com/reference/retrieve-a-page
**Date:** 2026-03-01

---

Retrieves a Page object using the ID specified.

## Endpoint

```
GET /v1/pages/{page_id}
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
| `page_id` | `string` | required | The ID of the page to retrieve. |

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `filter_properties` | `string[]` | Supply a list of property IDs to filter properties in the response. Maximum array length: 100. Note that if a page doesn't have a property, it won't be included in the filtered response. |

## Notes

> **Warning — This endpoint will not accurately return properties that exceed 25 references**
> Do **not** use this endpoint if a page property includes more than 25 references to receive the full list of references. Instead, use the Retrieve a page property endpoint for the specific property to get its complete reference list.

Responses contains page **properties**, not page content. To fetch page content, use the Retrieve block children endpoint.

Page properties are limited to up to **25 references** per page property. To retrieve data related to properties that have more than 25 references, use the Retrieve a page property endpoint.

### Parent objects: Pages vs. databases

If a page's Parent object is a database, then the property values will conform to the database property schema.

If a page object is not part of a database, then the only property value available for that page is its `title`.

### Limits

The endpoint returns a maximum of 25 page or person references per page property. If a page property includes more than 25 references, then the 26th reference and beyond might be returned as `Untitled`, `Anonymous`, or not be returned at all.

This limit affects the following properties:
- `people`: response object can't be guaranteed to return more than 25 people.
- `relation`: the `has_more` value of the `relation` in the response object is `true` if a `relation` contains more than 25 related pages. Otherwise, `has_more` is false.
- `rich_text`: response object includes a maximum of 25 populated inline page or person mentions.
- `title`: response object includes a maximum of 25 inline page or person mentions.

> **Info — Integration capabilities**
> This endpoint requires an integration to have read content capabilities. Attempting to call this API without read content capabilities will return an HTTP response with a 403 status code.

## Errors

Returns a 404 HTTP response if the page doesn't exist, or if the integration doesn't have access to the page.

Returns a 400 or 429 HTTP response if the request exceeds the request limits.

## Code sample

```javascript
import { Client } from "@notionhq/client"
const notion = new Client({ auth: process.env.NOTION_API_KEY })
const response = await notion.pages.retrieve({
  page_id: "b55c9c91-384d-452b-81db-d1ef79372b75"
})
```

## Response (200)

Returns a Page object. See the Page object documentation for the full schema.
