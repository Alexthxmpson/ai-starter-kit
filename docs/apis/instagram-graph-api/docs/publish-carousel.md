# Publishing Carousels - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-api/guides/content-publishing/carousel
**Date:** 2026-03-01
**Note:** This URL does not exist as a separate page. Carousel publishing is covered in the main content publishing guide. See `content-publishing.md` and `ig-user-media-edge.md` for full details.

---

## Publishing Carousels

Carousels (also called Albums) let you publish up to 10 images and/or videos in a single post using a three-step flow.

### Three-Step Flow

1. **Create item containers** — One container per image or video (with `is_carousel_item=true`)
2. **Create carousel container** — References the item containers via `children`
3. **Publish the carousel container**

### Step 1 — Create Item Containers

For each image:
```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media
  ?image_url=<IMAGE_URL>
  &is_carousel_item=true
  &access_token=<ACCESS_TOKEN>
```

For each video:
```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media
  ?video_url=<VIDEO_URL>
  &media_type=VIDEO
  &is_carousel_item=true
  &access_token=<ACCESS_TOKEN>
```

Each item POST returns a container ID (e.g., `17889455560051444`).

### Step 2 — Create Carousel Container

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media
  ?media_type=CAROUSEL
  &children=<COMMA_SEPARATED_ITEM_IDS>
  &caption=<CAPTION>
  &access_token=<ACCESS_TOKEN>
```

Example:
```
POST graph.facebook.com/17841405822304914/media
  ?media_type=CAROUSEL
  &children=17889455560051444%2C17846368219941196
  &caption=Carousel+post+example
```

### Step 3 — Publish the Carousel Container

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media_publish
  ?creation_id=<CAROUSEL_CONTAINER_ID>
  &access_token=<ACCESS_TOKEN>
```

### Carousel Specifications

- Maximum items: 10 (images, videos, or mix)
- Images: JPEG (recommended), PNG — 8MB max, 320–1440px wide
- Videos: MP4, MOV — 100MB max, 3s to 60min, minimum 320px wide
- All items must use the same aspect ratio (recommended: square 1:1)
- Item containers expire after 24 hours

### Check Item Container Status

For video items, check status before creating the carousel container:
```
GET /<ITEM_CONTAINER_ID>?fields=status_code
```

Only proceed once all items return `FINISHED`.

### Rate Limits

- 50 carousel posts per 24-hour period (counts as 1 post toward the 50 post/day limit)
- 400 containers per 24-hour period (for creating item containers)

### Permissions Required

| API Config | Permissions |
|---|---|
| Instagram Login | `instagram_business_basic`, `instagram_business_content_publish` |
| Facebook Login | `instagram_basic`, `instagram_content_publish`, `pages_read_engagement` |

Refer to `content-publishing.md` for the complete guide and `ig-user-media-edge.md` for the full parameters reference.
