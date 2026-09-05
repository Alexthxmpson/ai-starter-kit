# IG User Media Publish - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media_publish
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/reference/ig-user/media_publish redirects here.

---

## IG User Media Publish

Publish an IG Container on an Instagram Business IG User. Refer to the Content Publishing guide for complete publishing steps.

---

## Creating

**`POST /{ig-user-id}/media_publish`**

Publish an IG Container object on an Instagram Business IG User.

### Limitations

- An Instagram professional account can only publish **50 posts within a 24-hour moving period**
- If the Page connected to the targeted Instagram Business account requires Page Publishing Authorization (PPA), PPA must be completed or the request will fail
- If the Page requires two-factor authentication, the Facebook User must also have performed two-factor authentication

### Requirements

| Type | Description |
|---|---|
| Access Tokens | User |
| Business Roles | For product tagging: app user must have admin role on Business Manager that owns the IG User's Instagram Shop |
| Instagram Shop | For product tagging: IG User must have an approved Instagram Shop with a product catalog containing products |
| Permissions | `instagram_basic`, `instagram_content_publish` (+ `ads_management` or `ads_read` for Business Manager roles; + `catalog_management`, `instagram_shopping_tag_products` for product tagging) |
| Tasks | App user must be able to perform `MANAGE` or `CREATE_CONTENT` tasks on the Page connected to the targeted Instagram account |

### Request Syntax

```
POST https://graph.facebook.com/{api-version}/{ig-user-id}/media_publish
  ?creation_id={creation-id}
  &access_token={access-token}
```

### Path Parameters

| Placeholder | Value |
|---|---|
| `{api-version}` | API version (e.g., `v25.0`) |
| `{ig-user-id}` | **Required.** App user's app-scoped user ID |

### Query String Parameters

| Key | Placeholder | Description |
|---|---|---|
| `access_token` | `{access-token}` | **Required.** The app user's User access token |
| `creation_id` | `{creation-id}` | **Required.** The ID of the IG Container to be published |

### Sample Request

```
POST graph.facebook.com/17841405822304914/media_publish
  ?creation_id=17889455560051444
```

### Sample Response

```json
{ "id": "17920238422030506" }
```

---

## Reading

This operation is not supported.

## Updating

This operation is not supported.

## Deleting

This operation is not supported.
