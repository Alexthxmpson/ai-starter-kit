# IG Media - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/reference/instagram-media
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/reference/ig-media redirects here.

---

## IG Media

Represents an Instagram album, photo, or video (uploaded video, live video, reel, or story).

**Migration note (Marketing API to Instagram Platform endpoints):**
- New field introduced: `legacy_instagram_media_id`
- Unsupported fields from Marketing API: `filter_name`, `location`, `location_name`, `latitude`, `longitude`

---

## Creating

This operation is not supported. See the IG User Media endpoint to create media containers.

---

## Reading

**`GET /<IG_MEDIA_ID>`**

Returns fields and edges on Instagram media.

### Requirements

| | Instagram API with Instagram Login | Instagram API with Facebook Login |
|---|---|---|
| Access Tokens | Instagram User access token | Facebook User access token |
| Host URL | `graph.instagram.com` | `graph.facebook.com` |
| Login Type | Business Login for Instagram | Facebook Login for Business |
| Permissions | `instagram_business_basic` | `instagram_basic`, `pages_read_engagement` or `pages_show_list` (+ `ads_management` or `business_management` for Business Manager roles) |

### Limitations

- Fields that return aggregated values don't include ads-driven data
- Some fields may not be available depending on media type or visibility settings

### Request Syntax

```
GET https://<HOST_URL>/<API_VERSION>/<IG_MEDIA_ID>
  ?fields=<LIST_OF_FIELDS>
  &access_token=<ACCESS_TOKEN>
```

### Query String Parameters

| Key | Placeholder | Description |
|---|---|---|
| `access_token` | `<ACCESS_TOKEN>` | Required. App user's User access token |
| `fields` | `<LIST_OF_FIELDS>` | Comma-separated list of fields you want returned |

### Fields

Public fields can be read via field expansion.

| Field | Description |
|---|---|
| `alt_text` (Public) | Descriptive text for images, for accessibility |
| `boost_ads_list` | Overview of all Instagram ad information associated with organic media for ACTIVE status ads. Includes ad ID and ad delivery status. **Facebook Login only.** |
| `boost_eligibility_info` | Information about boosting eligibility of Instagram media as an ad and additional details if not eligible. **Facebook Login only.** |
| `caption` (Public) | Caption. Excludes album children. The `@` symbol is excluded unless app user can perform admin-equivalent tasks on the connected Facebook Page. **Facebook Login only.** |
| `comments_count` (Public) | Count of comments on the media. Excludes comments on album child media and the media's caption. Includes replies on comments. |
| `copyright_check_information.status` | Returns `status` (`completed`, `error`, `in_progress`, `not_started`) and `matches_found` (`true`/`false`) objects. If violating copyright, returns `copyright_matches` array with: `author`, `content_title`, `matched_segments` (array of `duration_in_seconds`, `segment_type` [`AUDIO`/`VIDEO`], `start_time_in_seconds`), `owner_copyright_policy` (with `name`, `actions` with `action` values `BLOCK` or `MUTE`) |
| `id` (Public) | Media ID |
| `is_comment_enabled` | Indicates if comments are enabled or disabled. Excludes album children. |
| `is_shared_to_feed` (Public) | **For Reels only.** When `true`, reel can appear in Feed and Reels tabs. When `false`, only Reels tab. Does not guarantee appearance in Reels tab. |
| `legacy_instagram_media_id` | The ID for Instagram media created for Marketing API endpoints for v21.0 and older. |
| `like_count` | Count of likes on the media, including replies on comments. Excludes likes on album child media and promoted posts. Omitted if media owner has hidden like counts when queried indirectly. |
| `media_product_type` (Public) | Surface where the media is published: `AD`, `FEED`, `STORY`, or `REELS`. **Facebook Login only.** |
| `media_type` (Public) | Media type: `CAROUSEL_ALBUM`, `IMAGE`, or `VIDEO`. |
| `media_url` (Public) | URL for the media. Omitted if the media contains copyrighted material or has been flagged for a copyright violation (e.g., audio on reels). |
| `owner` (Public) | Instagram user ID who created the media. Only returned if the app user making the query also created the media; otherwise `username` is returned. |
| `permalink` (Public) | Permanent URL to the media. |
| `shortcode` (Public) | Shortcode to the media. |
| `thumbnail_url` (Public) | Media thumbnail URL. Only available on `VIDEO` media. |
| `timestamp` (Public) | ISO 8601-formatted creation date in UTC. |
| `username` (Public) | Username of user who created the media. |
| `view_count` (Public) | View count for Instagram reels (paid + organic metrics). Available for Business Discovery API only. |

### Edges

Public edges can be returned through field expansion.

| Edge | Description |
|---|---|
| `children` (Public) | Collection of IG Media objects on an album IG Media |
| `collaborators` | List of users added as collaborators on the IG Media. **Facebook Login only.** |
| `comments` | Collection of IG Comments on the IG Media |
| `insights` | Social interaction metrics on the IG Media |

### cURL Example

**Request:**
```bash
curl -X GET \
  'https://graph.instagram.com/v25.0/17895695668004550?fields=id,media_type,media_url,owner,timestamp&access_token=IGQVJ...'
```

**Response:**
```json
{
  "id": "17918920912340654",
  "media_type": "IMAGE",
  "media_url": "https://sconten...",
  "owner": { "id": "17841405309211844" },
  "timestamp": "2019-09-26T22:36:43+0000"
}
```

---

## Updating

**`POST /<IG_MEDIA_ID>`**

Enable or disable comments on an Instagram Media.

### Requirements

| | Instagram API with Instagram Login | Instagram API with Facebook Login |
|---|---|---|
| Access Tokens | Instagram User access token | Facebook User access token |
| Host URL | `graph.instagram.com` | `graph.facebook.com` |
| Login Type | Business Login for Instagram | Facebook Login for Business |
| Permissions | `instagram_business_basic`, `instagram_business_manage_comments` | `instagram_basic`, `instagram_manage_comments`, `pages_read_engagement` (+ `ads_management` or `ads_read` for Business Manager roles) |

### Limitations

- Live video Instagram Media not supported

### Request Syntax

```
POST https://<HOST_URL>/<API_VERSION>/<IG_MEDIA_ID>
  ?comment_enabled=<BOOL>
  &access_token=<ACCESS_TOKEN>
```

---

## Deleting

**`DELETE /<IG_MEDIA_ID>`**

Delete a reel or story from the Instagram account. Note: Published reels and stories can be deleted using this endpoint.

### Requirements

Similar permissions to Updating.

### Request Syntax

```
DELETE https://<HOST_URL>/<API_VERSION>/<IG_MEDIA_ID>
  ?access_token=<ACCESS_TOKEN>
```
