# Insights API - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/insights
**Date:** 2026-03-01

---

## Insights API

Provides a single, consistent interface to retrieve ad statistics.

- [Breakdowns](https://developers.facebook.com/docs/marketing-api/insights/breakdowns) - Group results
- [Action Breakdowns](https://developers.facebook.com/docs/marketing-api/insights/action-breakdowns) - Understanding the response from action breakdowns.
- [Async Jobs](https://developers.facebook.com/docs/marketing-api/insights/async) - For requests with large results, use asynchronous jobs
- [Limits and Best Practices](https://developers.facebook.com/docs/marketing-api/insights/best-practices/) - Call limits, filtering and best practices.

Before you can get data on your ad's performance, you should set up your ads to track the metrics you are interested in. For that, you can use URL Tags, Meta Pixel, and the Conversions API.

## Before you begin

You will need:

- The `ads_read` permission.
- An app. See [Meta App Development](https://developers.facebook.com/docs/development) for more information.

## Campaign Statistics

To get the statistics of a campaign's last 7 day performance:

```bash
curl -G \
  -d "date_preset=last_7d" \
  -d "access_token=ACCESS_TOKEN" \
  "https://graph.facebook.com/API_VERSION/AD_CAMPAIGN_ID/insights"
```

## Making Calls

The Insights API is available as an edge on any ads object.

| API Method |
|------------|
| `act_<AD_ACCOUNT_ID>/insights` |
| `<CAMPAIGN_ID>/insights` |
| `<ADSET_ID>/insights` |
| `<AD_ID>/insights` |

### Request

You can request specific fields with a comma-separated list in the `fields` parameter. For example:

```bash
curl -G \
  -d "fields=impressions" \
  -d "access_token=ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/<AD_ID>/insights"
```

### Response

```json
{
  "data": [
    {
      "impressions": "2466376",
      "date_start": "2009-03-28",
      "date_stop": "2016-04-01"
    }
  ],
  "paging": {
    "cursors": {
      "before": "MAZDZD",
      "after": "MAZDZD"
    }
  }
}
```

## Levels

Aggregate results at a defined object level. This automatically deduplicates data.

### Request

For example, get a campaign's insights on ad level:

```bash
curl -G \
  -d "level=ad" \
  -d "fields=impressions,ad_id" \
  -d "access_token=ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/CAMPAIGN_ID/insights"
```

### Response

```json
{
  "data": [
    {
      "impressions": "9708",
      "ad_id": "6142546123068",
      "date_start": "2009-03-28",
      "date_stop": "2016-04-01"
    },
    {
      "impressions": "18841",
      "ad_id": "6142546117828",
      "date_start": "2009-03-28",
      "date_stop": "2016-04-01"
    }
  ],
  "paging": {
    "cursors": {
      "before": "MAZDZD",
      "after": "MQZDZD"
    }
  }
}
```

If you don't have access to all ad objects at the requested level, the insights call returns no data. For example, while requesting insights with `level` set to `ad`, if you don't have access to one or more ad objects under the ad account, this API call will return a permission error.

## Attribution windows

The **conversion attribution window** provides timeframes that define when we attribute an event to an ad on a Meta app. We measure the actions that occur when a conversion event occurs and look back in time 1-day and 7-days. To view actions attributed to different attribution windows, make a request to `/{ad-account-id}/insights`. If you do not provide `action_attribution_windows` we use `7d_click` and provide it under `value`.

Example: `act_10151816772662695/insights?action_attribution_windows=['1d_click','1d_view']`

```json
"spend": 2352.45,
"actions": [
  {
    "action_type": "link_click",
    "value": 6608,
    "1d_view": 86,
    "1d_click": 6510
  }
],
"cost_per_action_type": [
  {
    "action_type": "link_click",
    "value": 0.35600030266344,
    "1d_view": 27.354069767442,
    "1d_click": 0.36135944700461
  }
]
```

## Field Expansion

Request fields at the node level and by fields specified in field expansion.

### Request

```bash
curl -G \
  -d "fields=insights{impressions}" \
  -d "access_token=ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/AD_ID"
```

### Response

```json
{
  "id": "6042542123268",
  "name": "My Website Clicks Ad",
  "insights": {
    "data": [
      {
        "impressions": "9708",
        "date_start": "2016-03-06",
        "date_stop": "2016-04-01"
      }
    ],
    "paging": {
      "cursors": {
        "before": "MAZDZD",
        "after": "MAZDZD"
      }
    }
  }
}
```

## Sorting

Sort results by providing the `sort` parameter with `{fieldname}_descending` or `{fieldname}_ascending`:

### Request

```bash
curl -G \
  -d "sort=reach_descending" \
  -d "level=ad" \
  -d "fields=reach" \
  -d "access_token=ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/AD_SET_ID/insights"
```

## Ads Labels

Stats for all labels whose names are identical. Aggregated into a single value at an ad object level.

### Request

```bash
curl -G \
  -d "fields=id,name,insights{unique_clicks,cpm,total_actions}" \
  -d "level=ad" \
  -d 'filtering=[{"field":"ad.adlabels","operator":"ANY", "value":["Label Name"]}]' \
  -d 'time_range={"since":"2015-03-01","until":"2015-03-31"}' \
  -d "access_token=ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/AD_OBJECT_ID/insights"
```

## Clicks definition

- **Link Clicks, `actions:link_click`** - The number of clicks on ad links to select destinations or experiences, on or off Meta-owned properties.
- **Clicks (All), `clicks`** - The metric counts multiple types of clicks on your ad, including certain types of interactions with the ad container, links to other destinations, and links to expanded ad experiences.

## Deleted and Archived Objects

Ad units may be `DELETED` or `ARCHIVED`. The stats of deleted or archived objects appear when you query their parents.

### Request — Get ARCHIVED ads

```bash
curl -G \
  -d "level=ad" \
  -d "filtering=[{'field':'ad.effective_status','operator':'IN','value':['ARCHIVED']}]" \
  -d "access_token=<ACCESS_TOKEN>" \
  "https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/insights/"
```

### Request — Deleted Objects by ID

```bash
curl -G \
  -d "fields=id,name,status,insights{impressions}" \
  -d "access_token=ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/AD_SET_ID"
```

### Request — Deleted Objects by filter

```
POST https://graph.facebook.com/<VERSION>/act_ID/insights?access_token=token&fields=ad_id,impressions&date_preset=lifetime&level=ad&filtering=[{"field":"ad.effective_status","operator":"IN","value":["DELETED"]}]
```

## Troubleshooting

### Timeouts

The most common issues causing failure at this endpoint are too many requests and time outs:

- On `GET` or synchronous requests, you can get out-of-memory or timeout errors.
- On `POST` or asynchronous requests, you can possibly get timeout errors. For asynchronous requests, it can take up to an hour to complete a request including retry attempts.

**Recommendations:**
- There is no explicit limit for when a query will fail. When it times out, try to break down the query into smaller queries by putting in filters like date range.
- Unique metrics are time consuming to compute. Try to query unique metrics in a separate call to improve performance of non-unique metrics.

### Rate Limiting

The Meta Insights API utilizes rate limiting to ensure an optimal reporting experience for all partners. See [Limits & Best Practices](https://developers.facebook.com/docs/marketing-api/insights/best-practices/).

### Discrepancy with Ads Manager

Beginning June 10, 2025, to reduce discrepancies with Meta Ads Manager, `use_unified_attribution_setting` and `action_report_time parameters` will be disregarded and API responses will mimic Ads Manager settings:

- Attributed `value`s will be based on Ad-Set-level attribution settings (similar to `use_unified_attribution_setting=true`), and inline/on-ad actions will be included in `1d_click` or `1d_view` attribution window data. After this change, standalone `inline` attribution window data will no longer be returned.
- Actions will be reported using `action_report_time=mixed`: on-Meta actions (like Link Clicks) will use impression-based reporting time; whereas off-Meta actions (like Web Purchases) will leverage conversion-based reporting time.

The default behavior of the API is different from the default behavior in Ads Manager. If you would like to observe the same behavior as in Ads Manager, please set the field `use_unified_attribution_setting` to true.

## Learn More

- [Ad Account Insights](https://developers.facebook.com/docs/marketing-api/reference/ad-account/insights)
- [Ad Campaign Insights](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/insights)
- [Ad Set Insights](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/insights)
- [Ad Insights](https://developers.facebook.com/docs/marketing-api/reference/adgroup/insights/)
