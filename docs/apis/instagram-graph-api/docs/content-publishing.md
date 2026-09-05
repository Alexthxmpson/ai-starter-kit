# Content Publishing - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/content-publishing
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/guides/content-publishing redirected to https://developers.facebook.com/docs/instagram-platform/content-publishing

---

## Content Publishing

This guide shows you how to publish single images, videos, reels (single media posts), or posts containing multiple images and videos (carousel posts) on Instagram professional accounts using the Instagram Platform.

**Update (March 24, 2025):** New `alt_text` field introduced for image posts on the `/<INSTAGRAM_PROFESSIONAL_ACCOUNT_ID>/media` endpoint. Reels and stories are not supported.

## Requirements

### Media on a public server

We cURL media used in publishing attempts, so the media must be hosted on a publicly accessible server at the time of the attempt.

### Page Publishing Authorization

An Instagram professional account connected to a Page that requires Page Publishing Authorization (PPA) cannot be published to until PPA has been completed.

### Requirements Table

| | Instagram API with Instagram Login | Instagram API with Facebook Login |
|---|---|---|
| **Access Levels** | Advanced Access, Standard Access | Advanced Access, Standard Access |
| **Access Tokens** | Instagram User access token | Facebook Page access token |
| **Host URL** | `graph.instagram.com` | `graph.facebook.com`, `rupload.facebook.com` (resumable video uploads) |
| **Login Type** | Business Login for Instagram | Facebook Login for Business |
| **Permissions** | `instagram_business_basic`, `instagram_business_content_publish` | `instagram_basic`, `instagram_content_publish`, `pages_read_engagement` (+ `ads_management`, `ads_read` if Business Manager role) |
| **Webhooks** | Yes | Yes |

### Endpoints

- `/<IG_ID>/media` — Create media container and upload the media
  - `upload_type=resumable` — Create a resumable upload session for large videos (Facebook Login for Business only)
- `/<IG_ID>/media_publish` — Publish uploaded media using their media containers
- `/<IG_CONTAINER_ID>?fields=status_code` — Check media container publishing eligibility and status
- `/<IG_ID>/content_publishing_limit` — Check app user's current publishing rate limit usage
- `POST https://rupload.facebook.com/ig-api-upload/<IG_MEDIA_CONTAINER_ID>` — Upload video to Meta servers
- `GET /<IG_MEDIA_CONTAINER_ID>?fields=status_code` — Check publishing eligibility and status of the video

### HTML URL Encoding

- Some parameters are supported in list/dict format
- Characters must be encoded: `[` → `%5B`, `{` → `%7B`
- Example: `user_tags=[{username:'ig_user_name'}]` → `user_tags=%5B%7Busername:ig_user_name%7D%5D`

## Limitations

- JPEG is the only image format supported. Extended JPEG formats such as MPO and JPS are not supported.
- Shopping tags are not supported.
- Branded content tags are not supported.
- Filters are not supported.

### Rate Limit

Instagram accounts are limited to **100 API-published posts within a 24-hour moving period**. Carousels count as a single post. Enforced on `POST /<IG_ID>/media_publish`.

To check current rate limit usage:
```
GET /<IG_ID>/content_publishing_limit
```

## Step 1: Create a Container

To publish a media object, it must have a container. Send a `POST` request to `/<IG_ID>/media` with:

- `access_token` — Set to your app user's access token
- `image_url` or `video_url` — Path to the image or video (must be on a public server)
- `media_type` — If the container will be for a video, set to `VIDEO`, `REELS`, or `STORIES`
- `is_carousel_item` — If the media will be part of a carousel, set to `true`
- `upload_type` — Set to `resumable` if creating a resumable upload session for a large video file

### Example Request

```bash
curl -X POST "https://<HOST_URL>/<LATEST_API_VERSION>/<IG_ID>/media" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{
    "image_url": "https://www.example.com/images/bronz-fonz.jpg"
  }'
```

### Example Response

```json
{ "id": "<IG_CONTAINER_ID>" }
```

## Create a Carousel Container

To publish up to 10 images, videos, or a combination, send a `POST` request to `/<IG_ID>/media` with:

- `media_type` — Set to `CAROUSEL`
- `children` — Comma-separated list of up to 10 container IDs

### Carousel Limitations

- Carousels are limited to 10 images, videos, or a mix of the two
- Carousel images are all cropped based on the first image in the carousel (default 1:1 aspect ratio)
- Accounts are limited to 50 published posts within a 24-hour period (carousel counts as a single post)

### Example Request

```bash
curl -X POST "https://graph.instagram.com/v25.0/90010177253934/media" \
  -H "Content-Type: application/json" \
  -d '{
    "caption": "Fruit%20candies",
    "media_type": "CAROUSEL",
    "children": "<IG_CONTAINER_ID_1>,<IG_CONTAINER_ID_2>,<IG_CONTAINER_ID_3>"
  }'
```

### Example Response

```json
{ "id": "<IG_CAROUSEL_CONTAINER_ID>" }
```

## Resumable Upload Session

If you created a container for a resumable video upload, you need to upload the video before it can be published.

- Most API calls use `graph.facebook.com` but calls to upload Reels videos use `rupload.facebook.com`

Supported file sources:
- A file located on your computer
- A file hosted on a public facing server (CDN)

### Sample Request — Upload Local Video File

```bash
curl -X POST "https://rupload.facebook.com/ig-api-upload/<API_VERSION>/<IG_MEDIA_CONTAINER_ID>" \
  -H "Authorization: OAuth <ACCESS_TOKEN>" \
  -H "offset: 0" \
  -H "file_size: Your_file_size_in_bytes" \
  --data-binary "@my_video_file.mp4"
```

Key parameters:
- `ig-container-id` — The ID returned from resumable upload session calls
- `access-token` — Same as used in previous steps
- `offset` — First byte being uploaded (generally `0`)
- `file_size` — Size of your file in bytes
- `Your_file_local_path` — File path (e.g., `@Downloads/example.mov` on macOS)

### Sample Request — Upload Public Hosted Video

```bash
curl -X POST "https://rupload.facebook.com/ig-api-upload/<API_VERSION>/<IG_MEDIA_CONTAINER_ID>" \
  -H "Authorization: OAuth <ACCESS_TOKEN>" \
  -H "file_url: https://example_hosted_video.com"
```

### Sample Response

```json
// Success
{
  "success": true,
  "message": "Upload successful."
}

// Failure
{
  "debug_info": {
    "retriable": false,
    "type": "ProcessingFailedError",
    "message": "{\"success\":false,\"error\":{\"message\":\"unauthorized user request\"}}"
  }
}
```

## Step 2: Publish the Container

Send a `POST` request to `/<IG_ID>/media_publish` with:

- `creation_id` — Set to the container ID (single media container or carousel container)

### Example Request

```bash
curl -X POST "https://<HOST_URL>/<LATEST_API_VERSION>/<IG_ID>/media_publish" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -d '{
    "creation_id": "<IG_CONTAINER_ID>"
  }'
```

### Example Response

```json
{ "id": "<IG_MEDIA_ID>" }
```

## Reels Posts

Reels are short-form videos that appear in the **Reels** tab of the Instagram app.

To publish a reel:
1. Create a container with `media_type=REELS` and `video_url` parameters

**Note:** If you publish a reel and request its `media_type` field, the value returned is `VIDEO`. To determine if a published video is a reel, request its `media_product_type` field instead.

Code sample: https://github.com/fbsamples/reels_publishing_apis/tree/main/insta_reels_publishing_api_sample

## Trial Reels Posts

Trial reels are reels that are only shared to non-followers. To publish a trial reel, create a container with a valid `trial_params` parameter along with the Reels parameters.

`trial_params` fields:

| Field Name | Description |
|---|---|
| `graduation_strategy` | The graduation strategy specifies conditions to graduate a reel (convert trial reel to a reel, sharing it to followers). Possible values: `MANUAL` — The trial reel can be manually graduated in the native app. `SS_PERFORMANCE` — The trial reel will be automatically graduated if the trial reel performs well. |

### Example Request

```bash
curl -X POST "https://graph.instagram.com/v25.0/90010177253934/media" \
  -H "Content-Type: application/json" \
  -d '{
    "media_type": "REELS",
    "video_url": "https://www.example.com/videos/bronz-fonz.mp4",
    "trial_params": {
      "graduation_strategy": "MANUAL"
    }
  }'
```

## Story Posts

To publish a story, create a container for the media object with `media_type=STORIES`.

**Note:** If you publish a story and request its `media_type` field, the value will be returned as `IMAGE/VIDEO`. To determine if a published image/video is a story, request its `media_product_type` field instead.

## Troubleshooting

If you can create a container but `POST /<IG_ID>/media_publish` doesn't return the published media ID, query `GET /<IG_CONTAINER_ID>?fields=status_code`:

| Status Code | Description |
|---|---|
| `EXPIRED` | The container was not published within 24 hours and has expired |
| `ERROR` | The container failed to complete the publishing process |
| `FINISHED` | The container and its media object are ready to be published |
| `IN_PROGRESS` | The container is still in the publishing process |
| `PUBLISHED` | The container's media object has been published |

Recommendation: Query a container's status once per minute, for no more than 5 minutes.

## Errors

See the Error Codes reference: https://developers.facebook.com/docs/instagram-api/reference/error-codes

## Next Steps

Learn how to moderate comments on your media.
