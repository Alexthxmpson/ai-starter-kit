# Ad Creative Reference - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/reference/ad-creative
**Date:** 2026-03-01

---

## Ad Creative

Format which provides layout and contains content for the ad. To see available ad creatives, visit [Ads Guide](https://www.facebook.com/business/ads-guide).

Only returns 50,000 ad creatives (pagination past this is unavailable).

---

## Examples

### Get Creative Info

```bash
curl -G \
  -d 'fields=name,object_story_id' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<CREATIVE_ID>
```

### Create a Link Ad

```bash
curl \
  -F 'name=Sample Creative' \
  -F 'object_story_spec={ "link_data": { "image_hash": "<IMAGE_HASH>", "link": "<URL>", "message": "try it out" }, "page_id": "<PAGE_ID>" }' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adcreatives
```

### Create Political Ad Creative

```bash
curl \
  -F 'authorization_category=POLITICAL' \
  -F 'object_story_spec={ ... }' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adcreatives
```

### Create Political Ad with Digitally Created/Altered Media (from Jan 9, 2024)

```bash
curl \
  -F 'authorization_category=POLITICAL_WITH_DIGITALLY_CREATED_MEDIA' \
  -F 'object_story_spec={ ... }' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adcreatives
```

### Read Thumbnail

```bash
curl -G \
  -d 'thumbnail_width=150' \
  -d 'thumbnail_height=120' \
  -d 'fields=thumbnail_url' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<CREATIVE_ID>
```

---

## Limits

| Limit | Value |
|-------|-------|
| Maximum ad title length | 25 characters (recommended) |
| Minimum ad title length | 1 character |
| Maximum ad body length | 90 characters (recommended) |
| Minimum ad body length | 1 character |
| Maximum URL length | 1000 characters |
| Maximum individual word length in title or body | 30 characters (recommended) |

### Title and Body Rules

- Should be between minimum and maximum title and body lengths.
- Cannot start with punctuation: `\ / ! . ? - * ( ) , ; :`
- Cannot have consecutive punctuation except for three full-stops `...`
- Words no longer than 30 characters
- Only three 1-character words allowed
- Not allowed: IPA symbols (except some), Standalone diacritical marks, Superscript/subscript, `^~_={}[]|<>`

### Exceptions

- Link Ads cannot use special characters
- Page Posts Ads allow special characters such as `★`

---

## Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | numeric string | Unique ID for an ad creative. (Default) |
| `account_id` | numeric string | Ad account ID this creative belongs to. |
| `actor_id` | numeric string | The actor ID (Page ID) of this creative |
| `ad_disclaimer_spec` | AdCreativeAdDisclaimer | Ad disclaimer data for additional info on ads. |
| `adlabels` | list\<AdLabel\> | Ad Labels associated with this creative. |
| `applink_treatment` | enum | For Dynamic Ads. Action if app isn't installed: open webpage or open app store. |
| `asset_feed_spec` | AdAssetFeedSpec | For Dynamic Creative. Multiple images, text and assets for generating ad variations. JSON string. |
| `authorization_category` | enum | Whether ad is labeled as political. Cannot be used for Dynamic Ads. Values: `POLITICAL`, `POLITICAL_WITH_DIGITALLY_CREATED_MEDIA` |
| `body` | string | The body of the ad. Not supported for video post creatives. |
| `branded_content` | AdCreativeBrandedContentAds | Branded content data |
| `branded_content_sponsor_page_id` | numeric string | ID for page representing business running Branded Content ads. |
| `call_to_action` | AdCreativeLinkDataCallToAction | Call to action for ad created from existing Instagram post |
| `call_to_action_type` | enum | Type of CTA button. Many values available: `OPEN_LINK`, `LIKE_PAGE`, `SHOP_NOW`, `INSTALL_APP`, `CALL`, `LEARN_MORE`, `SIGN_UP`, `DOWNLOAD`, `BOOK_NOW`, `ORDER_NOW`, `WHATSAPP_MESSAGE`, `FOLLOW_PAGE`, etc. |
| `categorization_criteria` | enum | Dynamic Category Ad categorization field, e.g. brand |
| `degrees_of_freedom_spec` | AdCreativeDegreesOfFreedomSpec | Specifies transformation types enabled for this creative |
| `dynamic_ad_voice` | string | For Store Traffic Dynamic Ads. `DYNAMIC` = nearest page, `STORY_OWNER` = main page. |
| `effective_authorization_category` | enum | Whether ad is political (system-detected, may differ from `authorization_category`). |
| `effective_instagram_media_id` | numeric string | ID of an Instagram post to use in an ad |
| `effective_object_story_id` | Post ID | ID of a page post to use in an ad (organic or unpublished) |
| `enable_direct_install` | bool | Whether Direct Install should be enabled on supported devices |
| `enable_launch_instant_app` | bool | Whether Instant App should be enabled on supported devices |
| `image_crops` | AdCreativeImageCrops | Image crop specs |
| `image_hash` | string | Hash of the image |
| `image_url` | string | URL of the image to use in the creative |
| `instagram_actor_id` | numeric string | Instagram user ID |
| `instagram_permalink_url` | string | URL of the Instagram post |
| `link_og_id` | numeric string | Open Graph object ID for link posts |
| `link_url` | string | Link URL |
| `name` | string | Name of the creative |
| `object_id` | numeric string | The ID of a Facebook object (page, app, event, etc.) |
| `object_story_id` | Post ID | The ID of a page post to use in the ad. Created using page post API. |
| `object_story_spec` | AdCreativeObjectStorySpec | Spec to create a new page post from. Required if `object_story_id` is not set. |
| `object_type` | enum | Type of object referenced by `object_id`. |
| `place_page_set_id` | numeric string | For Place Ads |
| `template_url` | string | URL of the Deep Link Template for Android apps |
| `thumbnail_url` | string | URL of the thumbnail image |
| `title` | string | Title of the creative |
| `url_tags` | string | URL tags for tracking |
| `video_id` | numeric string | ID of the video in this creative |

---

## Related Resources

- [App Ads](https://developers.facebook.com/docs/marketing-api/mobile-app-ads)
- [Video & Carousel Ads](https://developers.facebook.com/docs/marketing-api/guides/videoads)
- [Advantage+ Catalog Ads](https://developers.facebook.com/docs/marketing-api/advantage-catalog-ads)
- [Instagram Ads](https://developers.facebook.com/docs/marketing-api/guides/instagramads)
- [Ads that Click to WhatsApp](https://developers.facebook.com/docs/marketing-api/ad-creative/messaging-ads/click-to-whatsapp)
- [Lead Ads](https://developers.facebook.com/docs/marketing-api/guides/lead-ads)
