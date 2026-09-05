# Campaign Reference - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group
**Date:** 2026-03-01

---

## Campaign

A campaign is the highest level organizational structure within an ad account and should represent a single objective for an advertiser, for example, to drive page post engagement. Setting objective of the campaign will enforce validation on any ads added to the campaign to ensure they also have the correct objective.

**Note:** The `date_preset = lifetime` parameter is disabled in Graph API v10.0 and replaced with `date_preset = maximum`, which returns a maximum of 37 months of data.

### Limits

- You can only create 200 ad sets per ad campaign.
- If your campaign has more than 70 ad sets and uses Campaign Budget Optimization, you are not able to edit your current bid strategy or turn off CBO.

### New Required Field for All Campaigns

All businesses using the Marketing API must identify whether or not new and edited campaigns belong to a Special Ad Category. Current available categories are: housing, employment, credit, or issues, elections, and politics. Businesses whose ads do not belong to a Special Ad Category must indicate NONE or send an empty array in the `special_ad_categories` field.

**Note:** As of Marketing API 7.0, the `special_ad_category` parameter has been deprecated and replaced with a new `special_ad_categories` parameter (accepts an array).

---

## Reading

### Example

```
GET v25.0/...?fields={fieldname_of_type_Campaign} HTTP/1.1
Host: graph.facebook.com
```

### Parameters

| Parameter | Description |
|-----------|-------------|
| `date_preset` | `enum{today, yesterday, this_month, last_month, this_quarter, maximum, data_maximum, last_3d, last_7d, last_14d, last_28d, last_30d, last_90d, last_week_mon_sun, last_week_sun_sat, last_quarter, last_year, this_week_mon_today, this_week_sun_today, this_year}` — Date Preset |
| `time_range` | `{'since':YYYY-MM-DD,'until':YYYY-MM-DD}` — Time Range. Note if time range is invalid, it will be ignored. |

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | numeric string | Campaign's ID (Default) |
| `account_id` | numeric string | ID of the ad account that owns this campaign |
| `adlabels` | list\<AdLabel\> | Ad Labels associated with this campaign |
| `bid_strategy` | enum `{LOWEST_COST_WITHOUT_CAP, LOWEST_COST_WITH_BID_CAP, COST_CAP, LOWEST_COST_WITH_MIN_ROAS}` | Bid strategy for this campaign when you enable campaign budget optimization. `LOWEST_COST_WITHOUT_CAP`: automatic bidding. `LOWEST_COST_WITH_BID_CAP`: manual maximum-cost bidding. `COST_CAP`: limits average cost per optimization event. `LOWEST_COST_WITH_MIN_ROAS`: minimum return on ad spend. Note: `TARGET_COST` deprecated in Marketing API v9. |
| `boosted_object_id` | numeric string | The Boosted Object this campaign has associated, if any |
| `brand_lift_studies` | list\<AdStudy\> | Automated Brand Lift V2 studies for this ad set. |
| `budget_rebalance_flag` | bool | Deprecated on Marketing API V7.0 |
| `budget_remaining` | numeric string | Remaining budget |
| `buying_type` | string | `AUCTION` (default) or `RESERVED` (for reach and frequency ads). Reach and Frequency is disabled for housing, employment and credit ads. |
| `can_create_brand_lift_study` | bool | If we can create a new automated brand lift study for the ad set. |
| `can_use_spend_cap` | bool | Whether the campaign can set the spend cap |
| `configured_status` | enum `{ACTIVE, PAUSED, DELETED, ARCHIVED}` | If PAUSED, all active ad sets and ads will be paused with effective status CAMPAIGN_PAUSED. Prefer using 'status' instead. |
| `created_time` | datetime | Created Time |
| `daily_budget` | numeric string | The daily budget of the campaign |
| `effective_status` | enum `{ACTIVE, PAUSED, DELETED, ARCHIVED, IN_PROCESS, WITH_ISSUES}` | IN_PROCESS available for v4.0+ |
| `is_adset_budget_sharing_enabled` | bool | Whether the child ad sets are managed under ad set budget sharing |
| `is_budget_schedule_enabled` | bool | Whether budget scheduling is enabled for the campaign group |
| `is_skadnetwork_attribution` | bool | When true, indicates the campaign will include SKAdNetwork, iOS 14+. |
| `issues_info` | list\<AdCampaignIssuesInfo\> | Issues for this campaign that prevented it from delivering |
| `last_budget_toggling_time` | datetime | Last budget toggling time |
| `lifetime_budget` | numeric string | The lifetime budget of the campaign |
| `name` | string | Campaign's name |
| `objective` | string | Campaign's objective |
| `pacing_type` | list\<string\> | Defines pacing type of the campaign. Options: "standard". |
| `promoted_object` | AdPromotedObject | The object this campaign is promoting across all its ads |
| `smart_promotion_type` | enum | guided_creation or smart_app_promotion |
| `source_campaign` | Campaign | The source campaign that this campaign is copied from |
| `source_campaign_id` | numeric string | The source campaign id that this campaign is copied from |
| `special_ad_categories` | list\<enum\> | special ad categories |
| `special_ad_category` | enum | The campaign's Special Ad Category. One of `HOUSING`, `EMPLOYMENT`, `CREDIT`, or `NONE`. |
| `special_ad_category_country` | list\<enum\> | Country field for Special Ad Category. |
| `spend_cap` | numeric string | A spend cap for the campaign. Expressed as integer value of the subunit in your currency. |
| `start_time` | datetime | Read-only. Set start_time at the ad set level. |
| `status` | enum `{ACTIVE, PAUSED, DELETED, ARCHIVED}` | Suggested field to use. If PAUSED, all active ad sets and ads will be paused with effective status CAMPAIGN_PAUSED. |
| `stop_time` | datetime | Read-only. Set stop_time at the ad set level. |
| `topline_id` | numeric string | Topline ID |
| `updated_time` | datetime | Updated Time. Updating spend_cap or daily/lifetime budget does not update this field. |

### Edges

| Edge | Type | Description |
|------|------|-------------|
| `ad_studies` | Edge\<AdStudy\> | The ad studies containing this campaign |
| `adrules_governed` | Edge\<AdRule\> | Ad rules that govern this campaign |
| `ads` | Edge\<Adgroup\> | Ads under this campaign |
| `adsets` | Edge\<AdCampaign\> | The ad sets under this campaign |
| `copies` | Edge\<AdCampaignGroup\> | The copies of this campaign |

### Error Codes

| Error | Description |
|-------|-------------|
| 100 | Invalid parameter |
| 80004 | Too many calls to this ad-account. Wait and retry. |
| 613 | Calls to this api have exceeded the rate limit. |
| 190 | Invalid OAuth 2.0 Access Token |
| 104 | Incorrect signature |
| 2500 | Error parsing graph query |
| 3018 | The start date of the time range cannot be beyond 37 months from the current date |
| 200 | Permissions error |
| 2635 | You are calling a deprecated version of the Ads API. |

---

## Creating

### POST /act_{ad_account_id}/campaigns

```
POST /v25.0/act_<AD_ACCOUNT_ID>/campaigns HTTP/1.1
Host: graph.facebook.com

name=My+campaign&objective=OUTCOME_TRAFFIC&status=PAUSED&special_ad_categories=[]&is_adset_budget_sharing_enabled=0
```

### Create Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `adlabels` | list\<Object\> | Ad Labels associated with this campaign |
| `bid_strategy` | enum | `LOWEST_COST_WITHOUT_CAP`, `LOWEST_COST_WITH_BID_CAP`, `COST_CAP`, `LOWEST_COST_WITH_MIN_ROAS` |
| `buying_type` | string | `AUCTION` or `RESERVED` |
| `daily_budget` | int64 | Daily budget in account currency subunit |
| `is_adset_budget_sharing_enabled` | bool | Enable ad set budget sharing |
| `is_skadnetwork_attribution` | bool | Include SKAdNetwork (iOS 14+) |
| `lifetime_budget` | int64 | Lifetime budget in account currency subunit |
| `name` | string | Campaign name. Required. |
| `objective` | enum | Campaign objective. Required. Examples: `OUTCOME_TRAFFIC`, `OUTCOME_AWARENESS`, `OUTCOME_ENGAGEMENT`, `OUTCOME_LEADS`, `OUTCOME_SALES`, `OUTCOME_APP_PROMOTION` |
| `special_ad_categories` | list\<enum\> | Required. `HOUSING`, `EMPLOYMENT`, `CREDIT`, `ISSUES_ELECTIONS_POLITICS`, or `[]` for NONE |
| `spend_cap` | int64 | Spend cap for the campaign |
| `start_time` | datetime | Start time |
| `status` | enum | `ACTIVE`, `PAUSED`, `DELETED`, `ARCHIVED`. Defaults to PAUSED. |
| `stop_time` | datetime | End time |

### Copy a Campaign — POST /{campaign_id}/copies

| Parameter | Type | Description |
|-----------|------|-------------|
| `deep_copy` | boolean | Default: false. Whether to copy all child ads. Max 3 for sync, 51 for async. |
| `end_time` | datetime | End time for copied sets |
| `start_time` | datetime | Start time for copied sets |
| `status_option` | enum | `ACTIVE`, `PAUSED` (default), or `INHERITED_FROM_SOURCE` |

Return type: `{ copied_campaign_id, ad_object_ids }`
