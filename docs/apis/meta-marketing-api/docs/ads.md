# Ads Reference - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/reference/adgroup
**Date:** 2026-03-01

---

## Ad

An ad object contains the data necessary to visually display an ad and associate it with a corresponding ad set. Each ad is associated with an ad set and all ads in a set have the same daily or lifetime budget, schedule, and targeting.

Creating multiple ads in an ad set helps optimize their delivery based on variations in images, links, video, text or placements.

---

## Creating an Ad

Before you create an ad, you need an existing ad set and ad creative.

### Create Example

```bash
curl -X POST \
  -F 'name="My Ad"' \
  -F 'adset_id="<AD_SET_ID>"' \
  -F 'creative={ "creative_id": "<CREATIVE_ID>" }' \
  -F 'status="PAUSED"' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/ads
```

### Create Political Ad

```bash
curl -X POST \
  -F 'name="My AdGroup"' \
  -F 'adset_id="<AD_SET_ID>"' \
  -F 'creative={ "creative_id": "<CREATIVE_ID>" }' \
  -F 'status="PAUSED"' \
  -F 'authorization_category="POLITICAL"' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/ads
```

---

## Reading

### By Ad ID

```bash
curl -X GET \
  -d 'fields="id,name"' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<AD_ID>/
```

### By Campaign

```bash
curl -X GET \
  -d 'fields="name"' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<AD_CAMPAIGN_ID>/ads
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `date_preset` | `enum{today, yesterday, this_month, last_month, this_quarter, maximum, data_maximum, last_3d, last_7d, last_14d, last_28d, last_30d, last_90d, ...}` |
| `time_range` | `{'since':YYYY-MM-DD,'until':YYYY-MM-DD}` |

---

## Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | numeric string | The ID of this ad. (Default) |
| `account_id` | numeric string | The ID of the ad account that this ad belongs to. |
| `ad_active_time` | numeric string | The time from when the ad was recently active |
| `ad_review_feedback` | AdgroupReviewFeedback | The review feedback for this ad after it is reviewed. |
| `ad_schedule_end_time` | datetime | Optional end time for an individual ad. Only for sales and app promotion campaigns. |
| `ad_schedule_start_time` | datetime | Optional start time for an individual ad. Only for sales and app promotion campaigns. |
| `adlabels` | list\<AdLabel\> | Ad labels associated with this ad |
| `adset` | AdSet | Ad set that contains this ad |
| `adset_id` | numeric string | ID of the ad set that contains the ad |
| `bid_amount` | int32 | Bid amount for this ad in auction. Same as bid_amount on the ad set. |
| `campaign` | Campaign | Ad campaign that contains this ad |
| `campaign_id` | numeric string | ID of the ad campaign that contains this ad |
| `configured_status` | enum `{ACTIVE, PAUSED, DELETED, ARCHIVED}` | Use `status` instead. |
| `conversion_domain` | string | Domain where conversions happen. First and second level only (e.g., `facebook.com`). No longer required since June 2023. |
| `created_time` | datetime | Time when the ad was created. |
| `creative` | AdCreative | **Required for create.** The ID or creative spec. Supply as `{"creative_id": <CREATIVE_ID>}` or full creative spec. |
| `creative_asset_groups_spec` | AdCreativeAssetGroupsSpec | For Flexible ad format. |
| `effective_status` | enum | `ACTIVE`, `PAUSED`, `DELETED`, `PENDING_REVIEW`, `DISAPPROVED`, `PREAPPROVED`, `PENDING_BILLING_INFO`, `CAMPAIGN_PAUSED`, `ARCHIVED`, `ADSET_PAUSED`, `IN_PROCESS`, `WITH_ISSUES` |
| `issues_info` | list\<AdgroupIssuesInfo\> | Issues for this ad that prevented it from delivering |
| `last_updated_by_app_id` | id | App used for most recent update of the ad. |
| `name` | string | Name of the ad. |
| `preview_shareable_link` | string | Link to preview ads in different placements |
| `recommendations` | list\<AdRecommendation\> | Recommendations for this ad (if any). Not included in redownload mode. |
| `source_ad` | Ad | The source ad that this ad is copied from |
| `source_ad_id` | numeric string | Source ad ID (if copied) |
| `status` | enum `{ACTIVE, PAUSED, DELETED, ARCHIVED}` | The configured status. Use this instead of `configured_status`. |
| `tracking_specs` | list\<ConversionActionQuery\> | Tracking specs to log actions taken on your ad. |
| `updated_time` | datetime | Time when this ad was updated. |

---

## Edges

| Edge | Type | Description |
|------|------|-------------|
| `adcreatives` | Edge\<AdCreative\> | Creative associated with this ad |
| `adrules_governed` | Edge\<AdRule\> | Ad rules that govern this ad |
| `copies` | Edge\<Adgroup\> | Copies of this ad |
| `insights` | Edge\<AdsInsights\> | Insights for this ad |
| `leads` | Edge\<UserLeadGenInfo\> | Leads submitted for this ad |
| `previews` | Edge\<AdPreview\> | Preview of the ad |
| `targetingsentencelines` | Edge\<TargetingSentenceLine\> | Targeting description sentence for this ad |

---

## Error Codes

| Error | Description |
|-------|-------------|
| 100 | Invalid parameter |
| 80004 | Too many calls to this ad-account. |
| 613 | Rate limit exceeded. |
| 190 | Invalid OAuth 2.0 Access Token |
| 104 | Incorrect signature |
| 2635 | Deprecated version of the Ads API. Update to latest. |
| 2500 | Error parsing graph query |
| 3018 | Start date cannot be beyond 37 months from current date |
| 200 | Permissions error |
| 270 | App not authorized for Ads API (needs upgrade from development access). |

---

## Notes

### Ads with Political Content

- Ad account must be authorized by a Page admin to run political ads.
- Use `authorization_category="POLITICAL"` when creating the ad.

### Targeting DSA Regulated Locations (EU)

Set `dsa_payor` and `dsa_beneficiary` on the ad set before creating/copying ads targeting EU locations. If defaults are set on the ad account, they auto-populate.

### Youth Targeting (EU/EEA/Switzerland)

Meta stopped showing ads to youth in EU, EEA, and Switzerland as of November 2023. Ad sets targeting youth in these regions will be prevented or paused.
