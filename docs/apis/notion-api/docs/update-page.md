# Update page properties

**Source:** https://developers.notion.com/reference/patch-page
**Date:** 2026-03-01

---

Use this API to modify attributes of a Notion page, such as its properties, icon, or cover.

## Endpoint

```
PATCH /v1/pages/{page_id}
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
| `page_id` | `string` | required | The ID of the page to update. |

## Request body (application/json)

| Parameter | Type | Description |
|-----------|------|-------------|
| `properties` | object | Property values to update. Only works if the page's parent is a data source, aside from updating the `title` of a page outside of a data source. |
| `icon` | object | Page icon. Can be: File Upload, Emoji, External, or Custom Emoji. |
| `cover` | object | Page cover image. Can be: File Upload or External. |
| `is_locked` | boolean | Whether the page should be locked from editing in the Notion app UI. Doesn't affect ability to update via API. |
| `template` | object | Template to apply. Can be the data source's default template (`type=default`) or a specific template (`type=template_id`). |
| `erase_content` | boolean | Whether to erase all existing content from the page. **Use caution** — this is a destructive action that **cannot** be reversed using the API. |
| `archived` | boolean | Set to `true` to archive the page. |
| `in_trash` | boolean | Set to `true` to move the page to trash. |

## Use cases

### Updating properties

To change the `properties` of a page in a data source, use the `properties` body parameter. This parameter can only be used if the page's parent is a data source, aside from updating the `title` of a page outside of a data source. The page's `properties` schema must match the parent data source's properties.

### Setting the icon, cover, or "in trash" status

This endpoint can be used to update any page `icon` or `cover`, and can be used to archive or restore any page.

### Locking and unlocking a page

Use the `is_locked` boolean parameter to lock or unlock the page from being further edited in the Notion app UI. Note that this setting doesn't affect the ability to update the page using the API.

### Applying a page template

Use the `template` body parameter object to apply a template to an existing page. This can either be the parent data source's default template (`type=default`), or a specific template (`type=template_id`).

After the API request finishes, Notion's systems merge the content and properties from your chosen template into the current page.

### Erasing content from a page

Use the `erase_content` flag to delete all block children of the current page. **Use caution** with this parameter, since this is a destructive action that **cannot** be reversed using the API.

The main use case is for applying a `template` in scenarios where it makes sense to clear all of the existing page content and replace it with the template page's content.

### Adding content to a page

To add content, use the append block children API instead. The `page_id` can be passed as the `block_id` when adding block children to the page.

## General behavior

Returns the updated page object.

> **Info — Requirements**
> Your integration must have **update content capabilities** on the target page. Attempting a query without update content capabilities returns HTTP 403.

> **Warning — Limitations**
> - Updating rollup property values is not supported.
> - A page's `parent` cannot be changed.

## Errors

Each Public API endpoint can return several possible error codes. See the Error codes section of the Status codes documentation for more information.
