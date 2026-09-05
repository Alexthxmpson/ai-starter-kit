# Publishing Reels - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-api/guides/content-publishing/reels
**Date:** 2026-03-01
**Note:** This URL does not exist as a separate page. Reels publishing is covered in the main content publishing guide. See `content-publishing.md` and `ig-user-media-edge.md` for full details.

---

## Publishing Reels

Reels are short-form videos published using `media_type=REELS`. They support standard uploads, resumable uploads (for large files), and Trial Reels.

### Two-Step Flow

1. **Create container:** `POST /<IG_USER_ID>/media` with `media_type=REELS`
2. **Publish container:** `POST /<IG_USER_ID>/media_publish` with `creation_id`

### Create Reel Container (Standard Upload)

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media
  ?media_type=REELS
  &video_url=<VIDEO_URL>
  &caption=<CAPTION>
  &share_to_feed=<true|false>
  &access_token=<ACCESS_TOKEN>
```

**Key Parameters:**
- `media_type` (required) — Must be `REELS`
- `video_url` (required for standard) — Publicly accessible URL of the video
- `caption` — Caption text, up to 2,200 characters
- `share_to_feed` — If `true`, the reel will appear on both the Feed and Reels tabs. Default: `false` (Reels tab only)
- `cover_url` — URL of an image to use as the reel cover
- `thumb_offset` — Millisecond position of the frame to use as cover thumbnail
- `audio_name` — Name of the audio track
- `collaborators` — List of up to 3 Instagram usernames to add as collaborators

### Create Reel Container (Resumable Upload — for large files)

**Step 1 — Initialize upload session:**
```
POST https://rupload.facebook.com/instagram-graph-photo-store/<APP_SCOPED_USER_ID>
  -H "Authorization: OAuth <ACCESS_TOKEN>"
  -H "X-Instagram-Rupload-Params: {\"media_type\":\"REELS\", \"upload_type\":\"resumable\"}"
  -H "X-FB-Video-Waterfall-ID: <WATERFALL_ID>"
  -H "Offset: 0"
  -H "X-Entity-Length: <FILE_SIZE_IN_BYTES>"
  -H "X-Entity-Name: <FILE_NAME>"
  -H "X-Entity-Type: video/mp4"
```

Response returns an `upload_id`.

**Step 2 — Upload file in chunks** (recommended: 10MB chunks)

**Step 3 — Create media container using the upload_id:**
```
POST /<IG_USER_ID>/media
  ?media_type=REELS
  &upload_id=<UPLOAD_ID>
  &caption=<CAPTION>
```

### Check Container Status

```
GET /<CONTAINER_ID>?fields=status_code
```

Status codes:
- `FINISHED` — Ready to publish
- `IN_PROGRESS` — Still processing (poll every 30 seconds)
- `ERROR` — Processing failed; create a new container
- `EXPIRED` — Container expired (24 hours); create a new container
- `PUBLISHED` — Already published

### Publish the Container

```
POST https://<HOST_URL>/<API_VERSION>/<IG_USER_ID>/media_publish
  ?creation_id=<CONTAINER_ID>
  &access_token=<ACCESS_TOKEN>
```

### Trial Reels

Trial Reels let you test a reel with non-followers before deciding whether to share it with your followers.

```
POST /<IG_USER_ID>/media
  ?media_type=REELS
  &video_url=<VIDEO_URL>
  &trial_params={"graduation_strategy": "<STRATEGY>"}
```

**Graduation strategies:**
- `MANUAL` — The reel stays as a trial until you manually graduate it to a full reel
- `SS_PERFORMANCE` — The reel auto-graduates when it reaches a performance threshold

To graduate a trial reel to a full reel:
```
POST /<IG_CONTAINER_ID>
  ?trial_reel_to_reel=true
```

To delete a trial reel (without graduating):
```
DELETE /<IG_MEDIA_ID>
```

### Reel Video Specifications

- Formats: MP4 (recommended), MOV
- Maximum file size: 300MB
- Duration: 3 seconds minimum, 15 minutes maximum
- Recommended aspect ratio: 9:16 (vertical)
- Recommended resolution: 1080 x 1920px
- Frame rate: 23-60 FPS
- Minimum width: 320px

### Rate Limits

- 50 posts per 24-hour moving period (shared with all other published media types)

### Permissions Required

| API Config | Permissions |
|---|---|
| Instagram Login | `instagram_business_basic`, `instagram_business_content_publish` |
| Facebook Login | `instagram_basic`, `instagram_content_publish`, `pages_read_engagement` |

Refer to `content-publishing.md` for the complete guide and `ig-user-media-edge.md` for the full parameters reference.
