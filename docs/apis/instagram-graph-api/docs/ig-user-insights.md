# Instagram Account Insights - Instagram Platform
**Source:** https://developers.facebook.com/docs/instagram-platform/api-reference/instagram-user/insights
**Date:** 2026-03-01
**Note:** Original URL https://developers.facebook.com/docs/instagram-api/reference/ig-user/insights redirects here.

---

## Instagram Account Insights

Represents social interaction metrics on your app user's Instagram business or creator account. Available for the Instagram API with Facebook Login and Instagram API with Instagram Login.

**Deprecation notice:** The `impressions` metric has been deprecated for v22.0+ and will be deprecated for all versions on April 21, 2025. The new `views` metric with `total_value` metric type has been introduced with breakdowns for `follower_type` and `media_product_type`.

---

## Creating

This operation is not supported.

---

## Reading

**`GET /<YOUR_APP_USERS_INSTAGRAM_ACCOUNT_ID>/insights`**

Returns insights on your app user's Instagram business or creator account.

### Requirements

| | Instagram API with Instagram Login | Instagram API with Facebook Login |
|---|---|---|
| Access Tokens | Instagram User access token | Facebook User access token |
| Host URL | `graph.instagram.com` | `graph.facebook.com` |
| Login Type | Business Login for Instagram | Facebook Login for Business |
| Permissions | `instagram_business_basic`, `instagram_business_manage_insights` | `instagram_basic`, `instagram_manage_insights`, `pages_read_engagement` (+ `ads_management` or `ads_read` for Business Manager roles) |

### Limitations

- `follower_count` and `online_followers` metrics are not available on Instagram business or creator accounts with fewer than 100 followers.
- Insights data for the `online_followers` metric is only available for the last 30 days.
- If insights data you are requesting does not exist or is currently unavailable, the API will return an empty data set instead of `0` for individual metrics.
- Demographic metrics only return the top 45 performers.
- Only viewers for whom we have demographic data are used in demographic metric calculations.
- Summing demographic metric values may result in a value less than the follower count.
- Data used to calculate metrics may be delayed up to 48 hours.

### Request Syntax

```
GET https://<HOST_URL>/<API_VERSION>/<APP_USERS_INSTAGRAM_ACCOUNT_ID>/insights
  ?metric=<COMMA_SEPARATED_LIST_OF_METRICS>
  &period=<PERIOD>
  &timeframe=<TIMEFRAME>
  &metric_type=<METRIC_TYPE>
  &breakdown=<BREAKDOWN_METRIC>
  &since=<START_TIME>
  &until=<STOP_TIME>
  &access_token=<INSTAGRAM_USER_ACCESS_TOKEN>
```

### Parameters

| Key | Value |
|---|---|
| `access_token` | **Required.** The app user's Facebook User or Instagram access token |
| `breakdown` | Designates how to break down result set into subsets. Values: `contact_button_type` (by profile component), `follow_type` (followers vs. non-followers), `media_product_type` (by surface: AD, FEED, REELS, STORY) |
| `metric` | **Required.** Comma-separated list of metrics you want returned |
| `metric_type` | Designates aggregation mode: `time_series` (by time period) or `total_value` (simple total, supports breakdowns) |
| `period` | **Required.** Period aggregation |
| `since` | Unix timestamp indicating start of range |
| `timeframe` | **Required for demographics-related metrics.** How far to look back (overrides `since`/`until`). Values: `last_14_days`, `last_30_days`, `last_90_days`, `prev_month`, `this_month`, `this_week` |
| `until` | Unix timestamp indicating end of range |

### Breakdown

If you request `metric_type=total_value`, you can specify one or more breakdowns:

- `contact_button_type` — Break down by profile UI component tapped. Values: `BOOK_NOW`, `CALL`, `DIRECTION`, `EMAIL`, `INSTANT_EXPERIENCE`, `TEXT`, `UNDEFINED`
- `follow_type` — Break down by followers or non-followers. Values: `FOLLOWER`, `NON_FOLLOWER`, `UNKNOWN`
- `media_product_type` — Break down by surface. Values: `AD`, `FEED`, `REELS`, `STORY`

**Note:** If `metric_type=time_series`, breakdowns will not be included in the response.

### Metric Type

- `time_series` — Tells the API to aggregate results by time period (see Period)
- `total_value` — Tells the API to return results as a simple total (supports breakdowns)

### Period

Tells the API which time frame to use when aggregating results. Only compatible with interaction-related metrics.

### Timeframe

Tells the API how far to look back for data when requesting demographic-related metrics. This value overrides the `since` and `until` parameters.

### Range

Assign UNIX timestamps to the `since` and `until` parameters to define a range. The API will only include data created within this range (inclusive). If you do not include these parameters, the API will look back 24 hours. For demographics-related metrics, the `timeframe` parameter overrides these values.

---

## Metrics

### Interaction Metrics

| Metric | Period | Timeframe | Breakdown | Metric Type | Description |
|---|---|---|---|---|---|
| `accounts_engaged` | `day` | n/a | n/a | `total_value` | The number of accounts that have interacted with your content, including in ads. Content includes posts, stories, reels, videos and live videos. Interactions can include likes, saves, comments, shares or replies. This metric is estimated. |
| `comments` | `day` | n/a | `media_product_type` | `total_value` | The number of comments on your posts, reels, videos and live videos. This metric is in development. |
| `engaged_audience_demographics` | `lifetime` | `last_14_days`, `last_30_days`, `last_90_days`, `prev_month`, `this_month`, `this_week` | `age`, `city`, `country`, `gender` | `total_value` | The demographic characteristics of the engaged audience, including countries, cities and gender distribution. Not returned if the IG User has less than 100 engagements during the timeframe. Does not support `since` or `until`. |
| `follows_and_unfollows` | `day` | n/a | `follow_type` | `total_value` | The number of accounts that followed you and the number that unfollowed you or left Instagram in the selected period. Not returned if the IG User has less than 100 followers. |
| `follower_demographics` | `lifetime` | `last_14_days`, `last_30_days`, `last_90_days`, `prev_month`, `this_month`, `this_week` | `age`, `city`, `country`, `gender` | `total_value` | The demographic characteristics of followers, including countries, cities and gender distribution. Does not support `since` or `until`. Not returned if the IG User has less than 100 followers. |
| `impressions` | `day` | n/a | n/a | `total_value`, `time_series` | **DEPRECATED for v22.0+ and all versions April 21, 2025.** The number of times your posts, stories, reels, videos and live videos were on screen, including in ads. |
| `likes` | `day` | n/a | `media_product_type` | `total_value` | The number of likes on your posts, reels, and videos. |
| `profile_links_taps` | `day` | n/a | `contact_button_type` | `total_value` | The number of taps on your business address, call button, email button and text button. |
| `reach` | `day` | n/a | `media_product_type`, `follow_type` | `total_value`, `time_series` | The number of unique accounts that have seen your content at least once, including in ads. This metric is estimated. |
| `replies` | `day` | n/a | n/a | `total_value` | The number of replies you received from your story, including text replies and quick reaction replies. |
| `reposts` | `day` | n/a | n/a | `total_value` | The number of reposts of your posts, stories, reels, and videos. |
| `saves` | `day` | n/a | `media_product_type` | `total_value` | The number of saves of your posts, reels, and videos. |
| `shares` | `day` | n/a | `media_product_type` | `total_value` | The number of shares of your posts, stories, reels, videos and live videos. |
| `total_interactions` | `day` | n/a | `media_product_type` | `total_value` | The total number of post interactions, story interactions, reels interactions, video interactions and live video interactions, including any interactions on boosted content. |
| `views` | `day` | n/a | `follower_type`, `media_product_type` | `total_value` | The number of times your content was played or displayed. Content includes reels, posts, stories. This metric is in development. |

---

## Response

A JSON object containing the results of your query:

```json
{
  "data": [
    {
      "name": "{data}",
      "period": "<PERIOD>",
      "title": "{title}",
      "description": "{description}",
      "total_value": {
        "value": "{value}",
        "breakdowns": [
          {
            "dimension_keys": ["{key-1}", "{key-2}", "..."],
            "results": [
              {
                "dimension_values": ["{value-1}", "{value-2}", "..."],
                "value": "{value}",
                "end_time": "{end-time}"
              }
            ]
          }
        ]
      },
      "id": "{id}"
    }
  ],
  "paging": {
    "previous": "{previous}",
    "next": "{next}"
  }
}
```

### Response Contents

| Property | Value Type | Description |
|---|---|---|
| `breakdowns` | Array | Array of objects describing the breakdowns requested and their results. Only returned if `metric_type=total_values` is requested. |
| `data` | Array | Array of objects describing your results. |
| `description` | String | Metric description. |
| `dimension_keys` | Array | Array of strings describing breakdowns requested in the query. Only returned if `metric_type=total_values` is requested. |
| `dimension_values` | Array | Array of strings describing breakdown set values. Only returned if `metric_type=total_values` is requested. |
| `end_time` | String | ISO 8601 timestamp with time and offset. Example: `2022-08-01T07:00:00+0000` |
| `id` | String | A string describing the query's path parameters. |
| `name` | String | Metric requested. |
| `next` | String | URL to retrieve the next page of results. |
| `paging` | Object | Object containing URLs used to request the next set of results. |
| `period` | String | Period requested. |
| `previous` | String | URL to retrieve the previous page of results. |
| `results` | Array | Array of objects describing each breakdown set. Only returned if `metric_type=total_values` is requested. |
| `title` | String | Metric title. |
| `total_value` | Object | Object describing requested breakdown values (if breakdowns were requested). |
| `value` | Integer | For `data.total_value.value`, sum of requested metric values. For `data.total_value.breakdowns.results.value`, sum of breakdown set values. Only returned if `metric_type=total_values` is requested. |

---

## Updating

This operation is not supported.

## Deleting

This operation is not supported.
