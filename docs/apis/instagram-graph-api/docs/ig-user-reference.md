# IG User - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/reference/ig-user redirects here.

---

## IG User

Represents an Instagram Business Account or an Instagram Creator Account. Throughout the documentation, "Instagram User" and "Instagram Account" are used interchangeably — both represent your app user's Instagram professional account.

---

## Requirements

| | Instagram API with Instagram Login | Instagram API with Facebook Login |
|---|---|---|
| Access Tokens | Instagram User access token | Facebook User access token |
| Host URL | `graph.instagram.com` | `graph.facebook.com` |
| Login Type | Business Login for Instagram | Facebook Login for Business |
| Permissions | `instagram_business_basic` | `instagram_basic`, `pages_read_engagement` (+ `ads_management` or `ads_read` for Business Manager roles; + `catalog_management`, `instagram_shopping_tag_products` for product tagging) |
| Business Roles | Not applicable | For product tagging: app user must have admin role on Business Manager that owns the IG User's Instagram Shop |
| Instagram Shop | Not applicable | For product tagging: IG User must have an approved Instagram Shop with a product catalog containing products |

---

## Creating

This operation is not supported.

---

## Reading

**`GET /<IG_USER_ID>`**

Get fields and edges on an Instagram Business or Creator Account.

Note: If you are migrating from Marketing API Instagram Ads endpoints to Instagram Platform endpoints, be aware that some field names are different.

### Request Syntax

```
GET https://graph.facebook.com/<API_VERSION>/<IG_USER_ID>
  ?fields=<LIST_OF_FIELDS>
  &access_token=<ACCESS_TOKEN>
```

### Path Parameters

| Placeholder | Value |
|---|---|
| `<API_VERSION>` | API version (e.g., `v25.0`) |
| `<IG_USER_ID>` | **Required.** IG User ID |

### Query String Parameters

| Key | Placeholder | Value |
|---|---|---|
| `access_token` | `<ACCESS_TOKEN>` | **Required.** App user's User access token |
| `fields` | `<LIST_OF_FIELDS>` | Comma-separated list of IG User fields you want returned |

### Fields

Public fields can be returned by an edge using field expansion. Only a few fields will be available for accessing Page-backed Instagram accounts.

| Field Name | Description |
|---|---|
| `alt_text` (Public) | Descriptive text for images, for accessibility |
| `biography` (Public) | Profile bio text |
| `followers_count` (Public) | Total number of Instagram users following the user |
| `follows_count` | Total number of Instagram users the user follows |
| `has_profile_pic` | Indicates whether your app user's Instagram professional account has a profile picture |
| `id` (Public) | App-scoped User ID. Available for Page-backed Instagram accounts |
| `is_published` | Indicates whether your app user's Instagram account is published. Available for Page-backed Instagram accounts |
| `legacy_instagram_user_id` | Your app user's Instagram ID that was created for Marketing API endpoints for v21.0 and older. Available for Page-backed Instagram accounts |
| `media_count` (Public) | Total number of IG Media published on your app user's account |
| `name` | Your app user's Instagram profile name |
| `profile_picture_url` | Your app user's Instagram profile picture URL |
| `shopping_product_tag_eligibility` | Returns `true` if your app user has set up an Instagram Shop and is therefore eligible for product tagging, otherwise returns `false` |
| `username` (Public) | Your app user's Instagram profile username |
| `website` (Public) | Your app user's website URL |

### Edges

| Edge | Description |
|---|---|
| `agencies` | A list of businesses that can advertise for this Instagram professional account |
| `authorized_adaccounts` | Ad accounts that can advertise for this Instagram professional account |
| `business_discovery` | Get data about other Instagram Business or Instagram Creator IG Users |
| `connected_threads_user` | Represents a Threads account connected to an Instagram account |
| `content_publishing_limit` | Represents an IG User's current content publishing usage |
| `insights` | Represents social interaction metrics on an IG User |
| `instagram_backed_threads_user` | Represents a Threads account backed by an Instagram account |
| `live_media` | Represents a collection of live video IG Media on an IG User |
| `media` | Represents a collection of IG Media on an IG User |
| `media_publish` | Publish an IG Container on an Instagram Business IG User |
| `mentions` | Create an IG Comment on an IG Comment or captioned IG Media that an IG User has been @mentioned in by another Instagram user |
| `mentioned_comment` | Get data on an IG Comment in which an IG User has been @mentioned by another Instagram user |
| `mentioned_media` | Get data on an IG Media in which an IG User has been @mentioned in a caption by another Instagram user |
| `recently_searched_hashtags` | Get IG Hashtags that an IG User has searched for within the last 7 days |
| `stories` | Represents a collection of story IG Media objects on an IG User |
| `tags` | Represents a collection of IG Media in which an IG User has been tagged by another Instagram user |
| `upcoming_events` | A list of events this Instagram professional account is hosting |

### Response

A JSON-formatted object containing default and requested fields and edges.

```json
{ "<FIELD>": "<VALUE>", ... }
```

### cURL Example

**Request:**
```bash
curl -X GET \
  'https://graph.facebook.com/v25.0/17841405822304914?fields=biography%2Cid%2Cusername%2Cwebsite&access_token=EAACwX...'
```

**Response:**
```json
{
  "biography": "Dino data crunching app",
  "id": "17841405822304914",
  "username": "metricsaurus",
  "website": "http://www.metricsaurus.com/"
}
```

---

## Updating

This operation is not supported.

## Deleting

This operation is not supported.
