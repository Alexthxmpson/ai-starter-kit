# Publishing Videos - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-api/guides/content-publishing/video
**Date:** 2026-03-01
**Note:** This URL does not exist as a separate page. Video publishing is covered in the main content publishing guide. See `content-publishing.md` and `ig-user-media-edge.md` for full details.

---

## Publishing Videos

Video publishing to the Feed (non-Reels) uses the standard two-step container flow. For Reels, see `publish-reels.md`. For Stories, see `publish-stories.md`.

### Two-Step Flow

1. **Create container:** `POST /<IG_USER_ID>/media` with `video_url` and `media_type=VIDEO`
2. **Publish container:** `POST /<IG_USER_ID>/media_publish` with `creation_id`

### Create Video Container (Standard Upload)

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media
  ?media_type=VIDEO
  &video_url=<VIDEO_URL>
  &caption=<CAPTION>
  &access_token=<ACCESS_TOKEN>
```

### Create Video Container (Resumable Upload — for large files)

**Step 1 — Initialize:**
```
POST https://rupload.facebook.com/instagram-graph-photo-store/<APP_SCOPED_USER_ID>
  -H "Authorization: OAuth <ACCESS_TOKEN>"
  -H "X-Instagram-Rupload-Params: {\"media_type\":\"VIDEO\", \"upload_type\":\"resumable\"}"
  -H "X-FB-Video-Waterfall-ID: <WATERFALL_ID>"
  -H "Offset: 0"
  -H "X-Entity-Length: <FILE_SIZE_IN_BYTES>"
  -H "X-Entity-Name: <FILE_NAME>"
  -H "X-Entity-Type: video/mp4"
```

**Step 2 — Upload file chunks**

**Step 3 — Create container using the upload_id:**
```
POST /<IG_USER_ID>/media
  ?media_type=VIDEO
  &upload_id=<UPLOAD_ID>
  &caption=<CAPTION>
```

### Check Container Status

Before publishing, verify the container is ready:

```
GET /<CONTAINER_ID>?fields=status_code
```

Status codes:
- `FINISHED` — Ready to publish
- `IN_PROGRESS` — Still processing
- `ERROR` — Failed; create a new container
- `EXPIRED` — Expired after 24 hours

### Publish the Container

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media_publish
  ?creation_id=<CONTAINER_ID>
  &access_token=<ACCESS_TOKEN>
```

### Video Specifications (Feed Video)

- Formats: MP4 (recommended), MOV
- Maximum file size: 100MB (standard upload); larger files use resumable upload
- Duration: 3 seconds minimum, 60 minutes maximum
- Frame rate: 23-60 FPS
- Minimum width: 320px

### Permissions Required

| API Config | Permissions |
|---|---|
| Instagram Login | `instagram_business_basic`, `instagram_business_content_publish` |
| Facebook Login | `instagram_basic`, `instagram_content_publish`, `pages_read_engagement` |

Refer to `content-publishing.md` for the complete guide including carousel posts and troubleshooting. Refer to `ig-user-media-edge.md` for the full parameters reference.
