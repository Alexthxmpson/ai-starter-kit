# Insights - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/insights
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/guides/insights redirects here.

---

## Insights

This guide shows you how to get insights for your app users' Instagram media and professional accounts using the Instagram Platform.

"Instagram user" and "Instagram professional account" are used interchangeably. An Instagram User object represents your app user's Instagram professional account.

Instagram Insights are now available for Instagram API with Instagram Login.

## Requirements

### Requirements Table

| | Instagram API with Instagram Login | Instagram API with Facebook Login |
|---|---|---|
| Access Tokens | Instagram User access token | Facebook User access token |
| Host URL | `graph.instagram.com` | `graph.facebook.com` |
| Login Type | Business Login for Instagram | Facebook Login for Business |
| Permissions | `instagram_business_basic`, `instagram_business_manage_insights` | `instagram_basic`, `instagram_manage_insights`, `pages_read_engagement` (+ `ads_management` or `ads_read` for Business Manager roles) |

### Access Level

- Advanced Access — if your app serves Instagram professional accounts you don't own or manage
- Standard Access — if your app serves Instagram professional accounts you own or manage

### Endpoints

- `GET /<INSTAGRAM_MEDIA_ID>/insights` — Gets metrics on a media object
- `GET /<INSTAGRAM_ACCOUNT_ID>/insights` — Gets metrics on an Instagram Business Account or Instagram Creator account

Refer to each endpoint's reference documentation for additional metrics, parameters, and permission requirements.

### UTC

Timestamps in API responses use UTC with zero offset and are formatted using ISO-8601. Example: `2019-04-05T07:56:32+0000`

### Webhook event subscriptions

- `story_insights` — Only available for Instagram API with Facebook Login

## Limitations

### Media Insights

- Fields that return aggregated values don't include ads-driven data (e.g., `comments_count` returns comments on photo, not on ads containing that photo)
- Captions don't include the `@` symbol unless the app user can perform admin-equivalent tasks on the app
- Some fields, such as `permalink`, cannot be used on photos within albums (children)
- Live video Instagram Media can only be read while they are being broadcast
- This API returns only data for media owned by Instagram professional accounts; not for personal Instagram accounts

### Account Insights

- Some metrics are not available on Instagram accounts with fewer than 100 followers
- User Metrics data is stored for up to 90 days
- You can only get insights for a single user at a time
- You cannot get insights for Facebook Pages
- If insights data doesn't exist or is currently unavailable, the API returns an empty data set instead of `0` for individual metrics

## Examples

### Instagram Account Request

Get `impressions`, `profile_views`, and `reach` for app user's Instagram professional account over one 24-hour period.

```
GET graph.facebook.com/17841405822304914/insights
  ?metric=impressions,reach,profile_views
  &period=day
```

**Sample Response:**

```json
{
  "data": [
    {
      "name": "impressions",
      "period": "day",
      "values": [
        { "value": 32, "end_time": "2018-01-11T08:00:00+0000" },
        { "value": 32, "end_time": "2018-01-12T08:00:00+0000" }
      ],
      "title": "Impressions",
      "description": "Total number of times the Business Account's media objects have been viewed",
      "id": "instagram_business_account_id/insights/impressions/day"
    },
    {
      "name": "reach",
      "period": "day",
      "values": [
        { "value": 12, "end_time": "2018-01-11T08:00:00+0000" },
        { "value": 12, "end_time": "2018-01-12T08:00:00+0000" }
      ],
      "title": "Reach",
      "description": "Total number of times the Business Account's media objects have been uniquely viewed",
      "id": "instagram_business_account_id/insights/reach/day"
    },
    {
      "name": "profile_views",
      "period": "day",
      "values": [
        { "value": 15, "end_time": "2018-01-11T08:00:00+0000" },
        { "value": 15, "end_time": "2018-01-12T08:00:00+0000" }
      ],
      "title": "Profile Views",
      "description": "Total number of users who have viewed the Business Account's profile within the specified period",
      "id": "instagram_business_account_id/insights/profile_views/day"
    }
  ]
}
```

### Instagram Media Request

Get `engagement`, `impressions`, and `reach` for app user's Instagram media.

```
GET graph.instagram.com/17841491440582230/insights
  ?metric=engagement,impressions,reach
```

**Sample Response:**

```json
{
  "data": [
    {
      "name": "engagement",
      "period": "lifetime",
      "values": [{ "value": 8 }],
      "title": "Engagement",
      "description": "Total number of likes and comments on the media object",
      "id": "media_id/insights/engagement/lifetime"
    },
    {
      "name": "impressions",
      "period": "lifetime",
      "values": [{ "value": 13 }],
      "title": "Impressions",
      "description": "Total number of times the media object has been seen",
      "id": "media_id/insights/impressions/lifetime"
    },
    {
      "name": "reach",
      "period": "lifetime",
      "values": [{ "value": 13 }],
      "title": "Reach",
      "description": "Total number of unique accounts that have seen the media object",
      "id": "media_id/insights/reach/lifetime"
    }
  ]
}
```

## Next Steps

Visit the API Reference for all available metrics for:
- Instagram business and creator accounts: https://developers.facebook.com/docs/instagram-api/reference/ig-user
- Instagram Media objects: https://developers.facebook.com/docs/instagram-api/reference/ig-media
