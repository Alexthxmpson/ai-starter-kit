# Instagram Graph API — Use Cases & Practical Guide

**Date:** 2026-03-28 (updated)

---

## What You Can Do

### Free / No Auth Required
- Nothing — all calls require an OAuth 2.0 access token

### With Standard Access (your own accounts)
| Use Case | Endpoint | Permissions |
|----------|----------|-------------|
| Read your media list | `GET /{user-id}/media` | `instagram_business_basic` |
| Get media details (URL, caption, timestamp) | `GET /{media-id}?fields=...` | `instagram_business_basic` |
| Publish photos/reels/carousels | `POST /{user-id}/media` + `/media_publish` | `instagram_business_content_publish` |
| Read/reply to comments | `GET /{media-id}/comments` | `instagram_business_manage_comments` |
| Get media insights | `GET /{media-id}/insights` | `instagram_business_basic` |
| Get profile stats | `GET /me?fields=followers_count,...` | `instagram_business_basic` |
| Check publishing limits | `GET /{user-id}/content_publishing_limit` | `instagram_business_content_publish` |

### Requires Advanced Access (App Review — other people's accounts)
| Use Case | Endpoint | Notes |
|----------|----------|-------|
| Build SaaS for IG management | All endpoints | Needs App Review |
| Business discovery (lookup other accounts) | `GET /{user-id}?fields=business_discovery.fields(...)` | Facebook Login path only |
| Hashtag search/tracking | `GET /ig_hashtag_search` | Facebook Login path only |

### What the API Cannot Do
- Publish to personal Instagram accounts — Business or Creator accounts only
- Delete individual items inside a carousel (must delete entire carousel)
- Post Stories with interactive elements (polls, stickers, links) via API
- Access data for accounts your app hasn't been granted access to
- Retrieve insights data older than 90 days
- Retrieve data from personal (non-professional) Instagram accounts
- Provide image hashes or fingerprints for matching

---

## Automation Ideas

| Use Case | Complexity | How | Key Endpoint |
|----------|-----------|-----|--------------|
| Pull all posted media + match against local DB | Easy | `GET /{user-id}/media` with timestamp matching | `GET /<IG_ID>/media` |
| Publish a photo to Instagram feed | Easy | POST container with `image_url` -> POST `media_publish` | `POST /<IG_ID>/media` -> `/media_publish` |
| Get account profile info | Easy | GET IG User fields | `GET /<IG_USER_ID>?fields=...` |
| Auto-post photos from a queue | Easy | Container create -> publish flow | `POST /<IG_ID>/media` |
| Track engagement per post | Easy | Query `like_count`, `comments_count` fields | `GET /<IG_MEDIA_ID>?fields=...` |
| Detect if a specific photo was posted | Medium | Match by timestamp + perceptual hash of downloaded image | `GET /<IG_ID>/media` + download + hash |
| Publish a carousel (multi-image post) | Medium | Create individual containers -> carousel container -> publish | `POST /<IG_ID>/media` x N |
| Auto-reply to comments | Medium | Webhooks + `POST /{media-id}/comments` | Comments edge |
| Content calendar with scheduled posts | Medium | Cron + container publish API | `POST /media` + `/media_publish` |
| Daily content performance report | Hard | List media -> insights per post -> store | `GET /media` + `GET /<ID>/insights` |
| Cross-post to IG + other platforms | Medium | Combine with other APIs | Multiple APIs |

---

## Key Limits and Gotchas

1. **media_url EXPIRES** — CDN URLs have expiration signatures (2-7 days). Download images immediately, do not store URLs as permanent references. `permalink` is permanent but links to IG app, not raw image.

2. **No image hash from API** — The API does not return any perceptual hash, MD5, or content hash. To match images: download via `media_url`, compute your own hash, then compare.

3. **10K media limit** — `GET /{user-id}/media` returns max 10,000 most recent posts.

4. **Stories excluded** — Must use separate `/{user-id}/stories` endpoint.

5. **Professional accounts only** — Personal IG accounts cannot use this API.

6. **Caption @ symbol stripped** — Unless app user has admin-equivalent Page tasks.

7. **Rate limit is impression-based** — `4800 * impressions` calls per 24h. Minimum floor: 48,000 calls/day (10 impressions minimum).

8. **Two auth paths** — Instagram Login (simpler, no Page needed) vs Facebook Login (legacy, more features like hashtag search & business discovery).

9. **Copyrighted media** — `media_url` is omitted for media flagged for copyright violations.

10. **Token refresh window** — Long-lived tokens last 60 days. Must refresh before expiry. Token must be 24h+ old to refresh. Un-refreshed tokens expire permanently.

11. **Publishing limits** — 400 containers per rolling 24 hours. Containers expire after 24h if not published.

12. **Two login types differ in features:**

| Feature | Instagram Login | Facebook Login |
|---------|----------------|----------------|
| Host URL | `graph.instagram.com` | `graph.facebook.com` |
| Requires Facebook Page | No | Yes |
| Hashtag search | No | Yes |
| Business discovery | No | Yes |
| Caption field | No | Yes |
| media_product_type field | No | Yes |

---

## Image Matching Strategy

Since the API provides no image fingerprint/hash, matching posted media against a local database requires:

1. **Timestamp matching** (fastest) — Compare `timestamp` field against your upload queue timestamps. Works if you track when each photo was submitted for posting. Accuracy: ~seconds precision in ISO 8601.

2. **Perceptual hash matching** (most reliable) — Download image via `media_url` -> compute pHash/dHash -> compare against pre-computed hashes of your database images. Libraries: Python `imagehash`, `pillow`. Note: Instagram may compress/resize images, so use perceptual hashing not exact MD5.

3. **Caption/metadata matching** — Match by caption text if you set unique captions per post.

4. **Media ID tracking** — After publishing via API, store the returned `media_id` and `permalink`. Then match by ID on subsequent reads. Most reliable if you control the publishing flow.

5. **Shortcode matching** — Each media has a unique `shortcode`. If you know the shortcode (from the post URL), you can match directly.

**Recommended approach:** If publishing via API, store the `media_id` from `media_publish` response. If verifying manually-posted content, use timestamp + perceptual hash combo.

---

## Available Scripts/Tools Already Built

None yet. This is a new integration being planned.
