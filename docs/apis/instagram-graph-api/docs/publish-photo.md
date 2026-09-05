# Publishing Photos - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-api/guides/content-publishing/photo
**Date:** 2026-03-01
**Note:** This URL does not exist as a separate page. Photo publishing is covered in the main content publishing guide. See `content-publishing.md` and `ig-user-media-edge.md` for full details.

---

## Publishing Photos

Photo (image) publishing is handled through the standard two-step content publishing flow using the IG User Media edge.

### Two-Step Flow

1. **Create container:** `POST /<IG_USER_ID>/media` with `image_url` parameter
2. **Publish container:** `POST /<IG_USER_ID>/media_publish` with `creation_id`

### Create Image Container

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media
  ?image_url=<IMAGE_URL>
  &caption=<CAPTION>
  &access_token=<ACCESS_TOKEN>
```

**Key Parameters:**
- `image_url` (required) — Publicly accessible URL of the JPEG or PNG image
- `caption` — Caption for the image. Up to 2,200 characters. Use `\n` for newlines.
- `location_id` — Facebook Page ID of a location to tag
- `user_tags` — Array of objects with `username` and `x`/`y` (position) to tag users
- `alt_text` — Custom accessibility alt text

**Image Specifications:**
- Formats: JPEG (recommended), PNG
- Maximum file size: 8MB
- Minimum width: 320px
- Maximum width: 1440px
- Aspect ratios: landscape (1.91:1), square (1:1), portrait (4:5)

### Publish the Container

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media_publish
  ?creation_id=<CONTAINER_ID>
  &access_token=<ACCESS_TOKEN>
```

Returns the published IG Media ID.

### Rate Limits

- 50 posts per 24-hour moving period (shared across all media types)
- 100 API calls per hour per app per IG User

### Permissions Required

| API Config | Permissions |
|---|---|
| Instagram Login | `instagram_business_basic`, `instagram_business_content_publish` |
| Facebook Login | `instagram_basic`, `instagram_content_publish`, `pages_read_engagement` |

Refer to `content-publishing.md` for the complete guide including carousel posts, check container status, and troubleshooting. Refer to `ig-user-media-edge.md` for the full parameters reference.
