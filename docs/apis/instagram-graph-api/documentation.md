# Instagram Graph API — Technical Documentation

**Source:** https://developers.facebook.com/docs/instagram-platform/
**Date saved:** 2026-03-28
**API Version:** v25.0

---

## Overview

The Instagram Graph API (now called "Instagram Platform") allows apps to access Instagram professional account data (Business + Creator accounts). Personal accounts are NOT supported.

There are **two authentication paths**:
1. **Instagram API with Instagram Login** (newer, simpler, no Facebook Page required)
2. **Instagram API with Facebook Login** (legacy, requires Facebook Page linked to IG account)

Host URLs:
- `graph.instagram.com` — Instagram API with Instagram Login
- `graph.facebook.com` — Instagram API with Facebook Login

---

## Authentication

### Path A: Instagram API with Instagram Login (Recommended)

Uses **Business Login for Instagram**. No Facebook Page linkage required.

#### Permissions (scope values):
- `instagram_business_basic` — Read profile, media, comments
- `instagram_business_content_publish` — Publish media
- `instagram_business_manage_comments` — Manage/reply to comments
- `instagram_business_manage_messages` — Send/receive messages

> Old scope values (`business_basic`, `business_content_publish`, etc.) were deprecated January 27, 2025.

#### OAuth Flow:

**Step 1: Authorization**
```
GET https://www.instagram.com/oauth/authorize
  ?client_id={INSTAGRAM_APP_ID}
  &redirect_uri={REDIRECT_URI}
  &response_type=code
  &scope=instagram_business_basic,instagram_business_content_publish
```

User authorizes -> redirected to `{REDIRECT_URI}?code={AUTH_CODE}#_`

Strip `#_` from the code.

**Step 2: Exchange code for short-lived token**
```
POST https://api.instagram.com/oauth/access_token
  -F client_id={INSTAGRAM_APP_ID}
  -F client_secret={INSTAGRAM_APP_SECRET}
  -F grant_type=authorization_code
  -F redirect_uri={REDIRECT_URI}
  -F code={AUTH_CODE}
```

Response:
```json
{
  "data": [{
    "access_token": "EAACEdEose0...",
    "user_id": "1020...",
    "permissions": "instagram_business_basic,..."
  }]
}
```

**Step 3: Exchange for long-lived token (60 days)**
```
GET https://graph.instagram.com/access_token
  ?grant_type=ig_exchange_token
  &client_secret={INSTAGRAM_APP_SECRET}
  &access_token={SHORT_LIVED_TOKEN}
```

Response:
```json
{
  "access_token": "EAACEdEose0...",
  "token_type": "bearer",
  "expires_in": 5183944
}
```

**Step 4: Refresh long-lived token (before it expires)**
```
GET https://graph.instagram.com/refresh_access_token
  ?grant_type=ig_refresh_token
  &access_token={LONG_LIVED_TOKEN}
```

- Token must be at least 24 hours old to refresh
- Tokens not refreshed within 60 days expire permanently
- Requires `instagram_business_basic` permission

#### App Dashboard Token (for development):
App Dashboard > Instagram > API setup with Instagram business login > Generate token
These are long-lived (60 days) by default.

### Path B: Instagram API with Facebook Login (Legacy)

Uses **Facebook Login for Business**. Requires Facebook Page linked to IG professional account.

#### Permissions:
- `instagram_basic` — Read profile, media
- `instagram_content_publish` — Publish media
- `instagram_manage_comments` — Manage comments
- `instagram_manage_insights` — Read insights
- `pages_read_engagement` — Required alongside instagram_basic
- `pages_show_list` — Alternative to pages_read_engagement

#### OAuth Flow:
```
GET https://www.facebook.com/dialog/oauth
  ?client_id={META_APP_ID}
  &display=page
  &extras={"setup":{"channel":"IG_API_ONBOARDING"}}
  &redirect_uri={REDIRECT_URI}
  &response_type=token
  &scope=instagram_basic,instagram_content_publish,pages_read_engagement
```

After auth, get the Instagram Business Account ID:
```
GET /me/accounts?fields=id,name,access_token,instagram_business_account
```

Response includes `instagram_business_account.id` which is the IG User ID for API calls.

---

## Key Endpoints

### GET /me — Get User Profile
```
GET https://graph.instagram.com/v25.0/me
  ?fields=user_id,username,name,account_type,profile_picture_url,followers_count,follows_count,media_count
  &access_token={TOKEN}
```

Fields:
| Field | Description |
|-------|-------------|
| `id` | App-scoped user ID |
| `user_id` | Instagram professional account ID |
| `username` | Instagram username |
| `name` | Display name |
| `account_type` | `Business` or `Media_Creator` |
| `profile_picture_url` | Profile picture URL |
| `followers_count` | Follower count |
| `follows_count` | Following count |
| `media_count` | Total media count |

### GET /{user-id}/media — List User's Media

```
GET https://graph.instagram.com/v25.0/{IG_USER_ID}/media
  ?fields=id,caption,media_type,media_url,timestamp,permalink,thumbnail_url,username,like_count,comments_count
  &access_token={TOKEN}
```

**Limitations:**
- Returns maximum **10,000** most recently created media
- Stories NOT included (use `GET /{user-id}/stories` instead)
- Supports **time-based pagination** with `since` and `until` (Unix timestamps)
- Supports cursor-based pagination via `paging.cursors.before` / `paging.cursors.after`

**Permissions required:**
- Instagram Login: `instagram_business_basic`
- Facebook Login: `instagram_basic` + `pages_read_engagement` (or `pages_show_list`)

### GET /{media-id} — Get Single Media Object

```
GET https://graph.instagram.com/v25.0/{MEDIA_ID}
  ?fields=id,caption,media_type,media_url,timestamp,permalink,thumbnail_url,username,like_count,comments_count,shortcode,owner,is_shared_to_feed,alt_text
  &access_token={TOKEN}
```

**Available fields:**

| Field | Description |
|-------|-------------|
| `id` | Media ID |
| `caption` | Post caption (excludes `@` symbol unless admin) |
| `media_type` | `IMAGE`, `VIDEO`, or `CAROUSEL_ALBUM` |
| `media_url` | CDN URL for the media (EXPIRES — see notes) |
| `timestamp` | ISO 8601 creation date in UTC |
| `permalink` | Permanent URL to the post |
| `shortcode` | Shortcode for the media |
| `thumbnail_url` | Thumbnail URL (VIDEO type only) |
| `username` | Creator's username |
| `owner` | Creator's IG user ID (only if you created it) |
| `like_count` | Like count (hidden if owner disabled) |
| `comments_count` | Comment count (excludes album children) |
| `is_shared_to_feed` | Reels only: whether shown in Feed tab |
| `media_product_type` | `AD`, `FEED`, `STORY`, or `REELS` (Facebook Login only) |
| `alt_text` | Alternative text for images (added March 2025) |
| `is_comment_enabled` | Whether comments are enabled |
| `copyright_check_information` | Copyright status and matches |

**Edges:**
- `children` — Album/carousel child media
- `collaborators` — Collaborator list (Facebook Login only)
- `comments` — Comments on the media
- `insights` — Engagement metrics

### GET /{media-id}/children — Carousel Children
Returns child media objects for carousel/album posts.

### GET /{user-id}/stories — User's Stories
Returns currently active stories (expire after 24 hours).

---

## Media URL Behavior (CRITICAL)

**`media_url` values are TEMPORARY.** They are CDN URLs with expiration signatures that stop working after a few days (typically 2-7 days).

- Do NOT store `media_url` as a permanent reference
- Download and cache images on your own server/CDN immediately upon retrieval
- `media_url` is omitted entirely if media contains copyrighted material
- To get a fresh URL, re-query the media endpoint
- `permalink` is permanent and always works (but links to Instagram, not the raw image)

---

## Content Publishing

### POST /{user-id}/media — Create Container

**Step 1: Create container**
```
POST https://graph.facebook.com/v25.0/{IG_USER_ID}/media
  ?image_url={PUBLIC_IMAGE_URL}
  &caption={CAPTION}
  &access_token={TOKEN}
```

**Step 2: Publish container**
```
POST https://graph.facebook.com/v25.0/{IG_USER_ID}/media_publish
  ?creation_id={CONTAINER_ID}
  &access_token={TOKEN}
```

**Permissions:** `instagram_basic` + `instagram_content_publish` + `pages_read_engagement`

**Limitations:**
- Containers expire after 24 hours
- Max 400 containers per rolling 24 hours
- Max 2200 characters in caption, 30 hashtags, 20 @tags
- Image: JPEG, max 8MB, aspect ratio 4:5 to 1.91:1
- Reel: MOV/MP4, max 300MB, 3s-15min, max 1920px wide
- Story image: JPEG, max 8MB, recommended 9:16
- Story video: max 100MB, 3-60 seconds

---

## Rate Limits

### Instagram Platform BUC Rate Limits
```
Calls within 24 hours = 4800 * Number of Impressions
```

- **Number of Impressions** = times any content from the IG professional account entered a person's screen in the last 24 hours
- Minimum impressions floor is 10 (so minimum = 48,000 calls/day)
- Rate limits are per app + per user pair
- Error code when throttled: `80002`

### Headers
Response includes `X-Business-Use-Case-Usage` header:
```json
{
  "business-id": [{
    "type": "instagram",
    "call_count": 28,
    "total_cputime": 25,
    "total_time": 25,
    "estimated_time_to_regain_access": 0
  }]
}
```

### Publishing Limits
- 400 containers per rolling 24 hours
- Check via `GET /{user-id}/content_publishing_limit`

### Best Practices
- Stop making calls when limit reached (continuing increases cooldown time)
- Check `X-Business-Use-Case-Usage` header
- Spread queries evenly, avoid spikes
- Use field filtering to reduce response size

---

## Error Codes

| Code | Meaning |
|------|---------|
| 80002 | Instagram BUC rate limit reached |
| 4 | App rate limit reached |
| 17 | User rate limit reached |
| 10 | Permission denied |
| 190 | Invalid/expired access token |
| 100 | Invalid parameter |
| 803 | Permission not granted |

---

## Pagination

### Cursor-based (default)
Response includes `paging.cursors.before` and `paging.cursors.after`. Use `?after={cursor}` or `?before={cursor}`.

### Time-based (/{user-id}/media)
Use `?since={unix_timestamp}&until={unix_timestamp}` to filter by creation date.

---

## Access Levels

- **Standard Access** — Only accounts you own/manage (added in App Dashboard)
- **Advanced Access** — Any IG professional account (requires App Review)

---

## API Versioning

Current latest: **v25.0**
Versioning follows Facebook Graph API versioning schedule. Each version has ~2 year lifespan.
