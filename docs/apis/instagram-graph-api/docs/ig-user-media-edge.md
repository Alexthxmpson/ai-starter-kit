# IG User Media - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/ig-user/media
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/reference/ig-user/media redirects here.

---

## IG User Media

Represents a collection of IG Media objects on an IG User.

**Updates:**
- July 9, 2025: Added support for `user_tags` field for image and video stories. You can mention users in a story and optionally specify x, y coordinates.
- March 24, 2025: New `alt_text` field for image posts. Reels and stories not supported.

---

## Creating

**`POST /<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media`**

Create an image, carousel, story, or reel IG Container for use in the post publishing process.

**Steps to publish:**
1. Create a container
2. Upload the media to the container
3. Publish the container

### Limitations

**General Limitations:**
- Containers expire after 24 hours
- An Instagram account can only create 400 containers within a rolling 24-hour period
- If the Page connected to the targeted Instagram professional account requires Page Publishing Authorization (PPA), PPA must be completed or the request will fail
- If the Page requires two-factor authentication, the Facebook User must also have performed two-factor authentication
- HTTP IETF standard character set for URLs strongly recommended (US ASCII characters only)

**Reels Limitations:**
- Reels cannot appear in carousels
- Account privacy settings are respected upon publish
- Music tagging is only available for original audio

**Story Limitations:**
- Stories expire after 24 hours
- Support either video URL or Reels URL but not both
- Publishing stickers (link, poll, location) is not supported; however mentioning users without a sticker is supported

### Requirements

| Type | Description |
|---|---|
| Access Tokens | User |
| Business Roles | For product tagging: app user must have admin role on the Business Manager that owns the IG User's Instagram Shop |
| Permissions | `instagram_basic`, `instagram_content_publish`, `pages_read_engagement` (+ `ads_management` or `ads_read` for Business Manager roles; + `catalog_management`, `instagram_shopping_tag_products` for product tagging) |
| Tasks | App user must be able to perform `MANAGE` or `CREATE_CONTENT` tasks on the linked Page |

### Image Specifications

- Format: JPEG
- File size: 8 MB maximum
- Aspect ratio: Must be within a 4:5 to 1.91:1 range
- Minimum width: 320 (scaled up if necessary)
- Maximum width: 1440 (scaled down if necessary)
- Height: Varies depending on width and aspect ratio
- Color Space: sRGB

### Reel Specifications

- Container: MOV or MP4 (MPEG-4 Part 14), no edit lists, moov atom at the front
- Audio codec: AAC, 48khz sample rate maximum, 1 or 2 channels (mono or stereo)
- Video codec: HEVC or H264, progressive scan, closed GOP, 4:2:0 chroma subsampling
- Frame rate: 23-60 FPS
- Maximum columns (horizontal pixels): 1920
- Aspect ratio: Required between 0.01:1 and 10:1, recommended 9:16
- Video bitrate: VBR, 25Mbps maximum
- Audio bitrate: 128kbps
- Duration: 15 mins maximum, 3 seconds minimum
- File size: 300MB maximum

**Reels cover photo specifications:**
- Format: JPEG
- File size: 8MB maximum
- Color Space: sRGB
- Aspect ratio: Recommended 9:16

### Story Image Specifications

- Format: JPEG
- File size: 8 MB maximum
- Aspect ratio: Recommended 9:16
- Color Space: sRGB

### Story Video Specifications

- Container: MOV or MP4 (MPEG-4 Part 14), no edit lists, moov atom at the front
- Audio codec: AAC, 48khz sample rate maximum, 1 or 2 channels (mono or stereo)
- Video codec: HEVC or H264, progressive scan, closed GOP, 4:2:0 chroma subsampling
- Frame rate: 23-60 FPS
- Maximum columns (horizontal pixels): 1920
- Aspect ratio: Required between 0.1:1 and 10:1, recommended 9:16
- Video bitrate: VBR, 25Mbps maximum
- Audio bitrate: 128kbps
- Duration: 60 seconds maximum, 3 seconds minimum
- File size: 100MB maximum

### Request Syntax

**Image Containers:**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_IG_USER_ID>/media
  ?image_url=<IMAGE_URL>
  &is_carousel_item=<TRUE_OR_FALSE>
  &alt_text=<IMAGE_ALTERNATIVE_TEXT>
  &caption=<IMAGE_CAPTION>
  &location_id=<LOCATION_PAGE_ID>
  &user_tags=<ARRAY_OF_USERS_FOR_TAGGING>
  &product_tags=<ARRAY_OF_PRODUCTS_FOR_TAGGING>
  &access_token=<USER_ACCESS_TOKEN>
```

**Reel Containers (Standard upload):**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media
  ?media_type=REELS
  &video_url=<REEL_URL>
  &caption=<IMAGE_CAPTION>
  &share_to_feed=<TRUE_OR_FALSE>
  &collaborators=<COLLABORATOR_USERNAMES>
  &cover_url=<COVER_URL>
  &audio_name=<AUDIO_NAME>
  &user_tags=<ARRAY_OF_USERS_FOR_TAGGING>
  &location_id=<LOCATION_PAGE_ID>
  &thumb_offset=<THUMB_OFFSET>
  &trial_params=<TRIAL_PARAM>
  &access_token=<USER_ACCESS_TOKEN>
```

**Reel Containers (Resumable upload session):**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media
  ?media_type=REELS
  &upload_type=resumable
  &caption=<IMAGE_CAPTION>
  &collaborators=<COLLABORATOR_USERNAMES>
  &cover_url=<COVER_URL>
  &audio_name=<AUDIO_NAME>
  &user_tags=<ARRAY_OF_USERS_FOR_TAGGING>
  &location_id=<LOCATION_PAGE_ID>
  &thumb_offset=<THUMB_OFFSET>
  &access_token=<USER_ACCESS_TOKEN>
```

On success, returns `ig-container-id` and `uri`:
```json
{
  "id": "<IG_CONTAINER_ID>",
  "uri": "https://rupload.facebook.com/ig-api-upload/v25.0/<IG_CONTAINER_ID>"
}
```

**Carousel Containers (Standard upload):**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media
  ?media_type=CAROUSEL
  &caption=<IMAGE_CAPTION>
  &share_to_feed=<TRUE_OR_FALSE>
  &collaborators=<COLLABORATOR_USERNAMES>
  &location_id=<LOCATION_PAGE_ID>
  &product_tags=<ARRAY_OF_PRODUCTS_FOR_TAGGING>
  &children=<ARRAY_OF_CAROUSEL_CONTAINTER_IDS>
  &access_token=<USER_ACCESS_TOKEN>
```

**Carousel Containers (Resumable upload — individual video items):**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media
  ?media_type=VIDEO
  &is_carousel_item=true
  &upload_type=resumable
  &access_token=<USER_ACCESS_TOKEN>
```

**Image Story Containers:**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media
  ?image_url=<IMAGE_URL>
  &media_type=STORIES
  &user_tags=<ARRAY_OF_USERS_FOR_TAGGING>
  &access_token=<USER_ACCESS_TOKEN>
```

**Video Story Containers (Standard upload):**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media
  ?video_url=<VIDEO_URL>
  &media_type=STORIES
  &user_tags=<ARRAY_OF_USERS_FOR_TAGGING>
  &access_token=<USER_ACCESS_TOKEN>
```

**Video Story Containers (Resumable upload session):**
```
POST https://graph.facebook.com/v25.0/<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media
  ?media_type=STORIES
  &upload_type=resumable
  &access_token=<USER_ACCESS_TOKEN>
```

**Upload a video through resumable upload protocol:**
```bash
curl -X POST "https://rupload.facebook.com/ig-api-upload/v25.0/<IG_CONTAINER_ID>" \
  -H "Authorization: OAuth <USER_ACCESS_TOKEN>" \
  -H "offset: 0" \
  -H "file_size: Your_file_size_in_bytes" \
  --data-binary "@Your_local_file_path.extension"
```

**Upload a video from a hosted URL:**
```bash
curl -X POST "https://rupload.facebook.com/ig-api-upload/v25.0/<IG_CONTAINER_ID>" \
  -H "Authorization: OAuth <USER_ACCESS_TOKEN>" \
  -H "file_url: <VIDEO_URL>"
```

### Path Parameters

| Placeholder | Value |
|---|---|
| `<LATEST_API_VERSION>` | Latest API version: `v25.0` |
| `<YOUR_APP_USERS_INSTAGRAM_USER_ID>` | Required. App user's app-scoped user ID |

### Query String Parameters

| Key | Placeholder | Description |
|---|---|---|
| `access_token` | `<USER_ACCESS_TOKEN>` | **Required.** App user's User access token |
| `alt_text` | `<IMAGE_ALTERNATIVE_TEXT>` | For image posts only. Alternative text, up to 1000 chars. Only supported on single image or image media in carousel. **Reels and stories not supported.** |
| `audio_name` | `<AUDIO_NAME>` | **For Reels only.** Name of the audio of your Reels media. Can only rename once. |
| `caption` | `<IMAGE_CAPTION>` | Caption for the image, video, or carousel. Can include hashtags (e.g., `#crazywildebeest`) and usernames (e.g., `@natgeo`). Max 2200 characters, 30 hashtags, 20 @ tags. **Not supported on images or videos in carousels.** |
| `children` | `<ARRAY_OF_CAROUSEL_CONTAINER_IDS>` | **Required for carousels.** Array of up to 10 container IDs. Carousels can have up to 10 total images, videos, or a mix. |
| `collaborators` | `<LIST_OF_COLLABORATORS>` | **For Feed image, Reels and Carousels only.** List of up to 3 Instagram usernames as collaborators. **Not supported for Stories.** |
| `cover_url` | `<COVER_URL>` | **For Reels only.** Path to an image to use as the cover image for the Reels tab. Must be on a public server. If `cover_url` and `thumb_offset` both specified, `cover_url` is used. |
| `image_url` | `<IMAGE_URL>` | **For images only, required for images.** Path to the image. Must be on a public server. |
| `is_carousel_item` | `<TRUE_OR_FALSE>` | **For images and video in carousels.** Set to `true`. Indicates media appears in a carousel. |
| `location_id` | `<LOCATION_PAGE_ID>` | ID of a Page associated with a location to tag. Use Pages Search API to find. **Not supported on images or videos in carousels.** |
| `media_type` | `<MEDIA_TYPE>` | **Required for carousels, stories, and reels.** Values: `CAROUSEL`, `REELS`, `STORIES` |
| `product_tags` | `<ARRAY_OF_PRODUCTS_FOR_TAGGING>` | **Required for product tagging. Images and videos only.** Array of objects (max 5). Each: `product_id` (required), `x` (images only, 0.0-1.0), `y` (images only, 0.0-1.0). Example: `[{product_id:'3231775643511089',x:0.5,y:0.8}]` |
| `share_to_feed` | `<TRUE_OR_FALSE>` | **For Reels only.** When `true`, reel can appear in Feed and Reels tabs. When `false`, only Reels tab. Does not guarantee appearance. |
| `thumb_offset` | `<THUMB_OFFSET>` | **For videos and reels.** Location in milliseconds of video frame to use as cover thumbnail. Default `0` (first frame). If `cover_url` specified for reels, `thumb_offset` is ignored. |
| `trial_params` | `<TRIAL_PARAM>` | Optional for trial reels. `media_type` must be `REELS`. Object with `graduation_strategy` (required): `MANUAL` or `SS_PERFORMANCE`. |
| `upload_type` | `<UPLOAD_TYPE>` | Optional. Set to `resumable` to upload video through the rupload protocol. |
| `user_tags` | `<ARRAY_OF_USERS_FOR_TAGGING>` | **Required for user tagging in images, videos, and stories.** Videos in carousels not supported. Array of objects with: `username` (required), `x` (required for images, optional for stories; 0.0-1.0), `y` (required for images, optional for stories; 0.0-1.0). |
| `video_url` | `<VIDEO_URL>` | **Required for videos and reels.** Path to the video. Must be on a public server. |

### Response

A JSON-formatted object containing an IG Container ID.

```json
{ "id": "<IG_CONTAINER_ID>" }
```

Video uploads are asynchronous — receiving a container ID does not guarantee the upload was successful. Request the `status_code` field on the IG Container to verify. If `FINISHED`, video was uploaded successfully.

### Sample Request

```
POST graph.facebook.com/17841400008460056/media
  ?image_url=https://www.example.com/images/bronzed-fonzes.jpg
  &caption=#BronzedFonzes!
  &collaborators=['username1','username2']
  &user_tags=[{"username":"kevinhart4real","x":0.5,"y":0.8},{"username":"therock","x":0.3,"y":0.2}]
```

### Sample Response

```json
{ "id": "17889455560051444" }
```

---

## Reading

**`GET /<YOUR_APP_USERS_INSTAGRAM_USER_ID>/media`**

Get all IG Media on an IG User.

### Limitations

- Returns a maximum of 10K of the most recently created media
- Story IG Media not supported — use `GET /<YOUR_APP_USERS_INSTAGRAM_USER_ID>/stories` instead

### Requirements

| Type | Description |
|---|---|
| Access Tokens | User |
| Permissions | `instagram_basic`, `pages_read_engagement` or `pages_show_list` (+ `ads_management` or `business_management` for Business Manager roles) |

### Time-based Pagination

Supports time-based pagination. Include `since` and `until` query-string parameters with Unix timestamp or `strtotime` data values to define a time range.

### Sample Request

```
GET graph.facebook.com/v25.0/17841405822304914/media
```

### Sample Response

```json
{
  "data": [
    { "id": "17895695668004550" },
    { "id": "17899305451014820" },
    { "id": "17896450804038745" },
    { "id": "17881042411086627" },
    { "id": "17869102915168123" }
  ]
}
```

---

## Updating

This operation is not supported.

## Deleting

This operation is not supported.

## See Also

- Error Codes: https://developers.facebook.com/docs/instagram-platform/instagram-graph-api/reference/error-codes
