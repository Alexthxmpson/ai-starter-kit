# Ad Set Reference - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/reference/ad-campaign
**Date:** 2026-03-01

---

## Ad Set

An ad set is a group of ads that share the same daily or lifetime budget, schedule, bid type, bid info, and targeting data. Ad sets enable you to group ads according to your criteria, and you can retrieve the ad-related statistics that apply to a set.

### Limits

| Limit | Value |
|-------|-------|
| Maximum number of ad sets per regular ad account | 5000 non-deleted ad sets |
| Maximum number of ad sets per bulk ad account | 10000 non-deleted ad sets |
| Maximum number of ads per ad set | 50 non-archived ads |

### Create Example — Daily Budget

```bash
curl -X POST \
  -F 'name="My Reach Ad Set"' \
  -F 'optimization_goal="REACH"' \
  -F 'billing_event="IMPRESSIONS"' \
  -F 'bid_amount=2' \
  -F 'daily_budget=1000' \
  -F 'campaign_id="<AD_CAMPAIGN_ID>"' \
  -F 'targeting={ "geo_locations": { "countries": [ "US" ] }, "facebook_positions": [ "feed" ] }' \
  -F 'status="PAUSED"' \
  -F 'promoted_object={ "page_id": "<PAGE_ID>" }' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adsets
```

### Create Example — Lifetime Budget

```bash
curl -X POST \
  -F 'name="My First Adset"' \
  -F 'lifetime_budget=20000' \
  -F 'start_time="2025-12-04T20:32:30-0800"' \
  -F 'end_time="2025-12-14T20:32:30-0800"' \
  -F 'campaign_id="<AD_CAMPAIGN_ID>"' \
  -F 'bid_amount=100' \
  -F 'billing_event="LINK_CLICKS"' \
  -F 'optimization_goal="LINK_CLICKS"' \
  -F 'targeting={ "facebook_positions": [ "feed" ], "geo_locations": { "countries": [ "US" ] }, "publisher_platforms": [ "facebook", "audience_network" ] }' \
  -F 'status="PAUSED"' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adsets
```

### Read Example

```bash
curl -X GET \
  -d 'fields="name,status"' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<AD_SET_ID>/
```

---

## Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | numeric string | ID for the Ad Set (Default) |
| `account_id` | numeric string | ID for the Ad Account associated with this Ad Set |
| `adlabels` | list\<AdLabel\> | Ad Labels associated with this ad set |
| `adset_schedule` | list\<DayPart\> | Ad set schedule, representing a delivery schedule for a single day |
| `asset_feed_id` | numeric string | The ID of the asset feed that contains content to create ads |
| `attribution_spec` | list\<AttributionSpec\> | Conversion attribution spec used for attributing conversions for optimization |
| `bid_adjustments` | AdBidAdjustments | Map of bid adjustment types to values |
| `bid_amount` | unsigned int32 | Bid cap or target cost for this ad set. Unit is cents for USD/EUR, basic unit for JPY/KRW. For IMPRESSION or REACH billing_event, bid is per 1,000 occurrences. |
| `bid_constraints` | AdCampaignBidConstraint | Bid constraints for ad set. Works together with bid_strategy. |
| `bid_info` | map\<string, unsigned int32\> | Map of bid objective to bid value. |
| `bid_strategy` | enum `{LOWEST_COST_WITHOUT_CAP, LOWEST_COST_WITH_BID_CAP, COST_CAP, LOWEST_COST_WITH_MIN_ROAS}` | Bid strategy. If CBO is enabled, use at campaign level. TARGET_COST deprecated in v9. |
| `billing_event` | enum | The billing event: `APP_INSTALLS` (pay per install), `CLICKS` (pay per click), `IMPRESSIONS` (pay per impression), `LINK_CLICKS` (pay per link click), `OFFER_CLAIMS`, `PAGE_LIKES`, `POST_ENGAGEMENT`, `THRUPLAY` (played to completion or 15s+), `PURCHASE`, `LISTING_INTERACTION` |
| `budget_remaining` | numeric string | Remaining budget |
| `campaign_id` | numeric string | Campaign ID |
| `campaign_attribution` | string | The campaign attribution of the ad set. |
| `configured_status` | enum `{ACTIVE, PAUSED, DELETED, ARCHIVED}` | The configured status |
| `created_time` | datetime | Created time |
| `creative_sequence` | list\<numeric string\> | Sequence of ad creative IDs |
| `daily_budget` | numeric string | Daily budget |
| `daily_imps` | unsigned int32 | Daily impressions. Only for RIGHT_HAND_COLUMN placement |
| `daily_min_spend_target` | numeric string | Daily minimum spend target for the ad set |
| `daily_spend_cap` | numeric string | Daily spend cap |
| `destination_type` | string | Destination type for the ad set |
| `dsa_beneficiary` | string | DSA beneficiary for EU-targeted ads |
| `dsa_payor` | string | DSA payor for EU-targeted ads |
| `effective_status` | enum | `ACTIVE`, `PAUSED`, `DELETED`, `CAMPAIGN_PAUSED`, `ARCHIVED`, `IN_PROCESS`, `WITH_ISSUES` |
| `end_time` | datetime | End time |
| `frequency_control_specs` | list\<AdCampaignFrequencyControlSpecs\> | Frequency control specs |
| `instagram_actor_id` | numeric string | Instagram actor ID for ads using the Instagram placement |
| `is_dynamic_creative` | bool | Whether to generate multiple ad variations |
| `issues_info` | list\<AdCampaignIssuesInfo\> | Issues that prevented delivery |
| `learning_stage_info` | AdCampaignLearningStageInfo | Info on learning stage |
| `lifetime_budget` | numeric string | Lifetime budget |
| `lifetime_imps` | unsigned int32 | Lifetime impressions. Only for RIGHT_HAND_COLUMN |
| `lifetime_min_spend_target` | numeric string | Lifetime minimum spend target |
| `lifetime_spend_cap` | numeric string | Lifetime spend cap |
| `name` | string | Ad set name |
| `optimization_goal` | enum | Optimization goal. Options include: `NONE`, `APP_INSTALLS`, `BRAND_AWARENESS`, `AD_RECALL_LIFT`, `CLICKS`, `ENGAGED_USERS`, `EVENT_RESPONSES`, `IMPRESSIONS`, `LEAD_GENERATION`, `LINK_CLICKS`, `OFFSITE_CONVERSIONS`, `PAGE_ENGAGEMENT`, `PAGE_LIKES`, `POST_ENGAGEMENT`, `QUALITY_LEAD`, `REACH`, `SOCIAL_IMPRESSIONS`, `APP_INSTALLS_AND_OFFSITE_CONVERSIONS`, `CONVERSATIONS`, `THRUPLAY`, `DERIVED_EVENTS`, `LANDING_PAGE_VIEWS`, `VISIT_INSTAGRAM_PROFILE` |
| `pacing_type` | list\<string\> | Defines pacing: `standard`, `no_pacing`, `day_parting` |
| `promoted_object` | AdPromotedObject | The object being promoted |
| `recommendations` | list\<AdRecommendation\> | Recommendations for this ad set |
| `recurring_budget_semantics` | bool | True if the budget is recurring |
| `review_feedback` | string | Review feedback |
| `rf_prediction_id` | numeric string | Reach and Frequency prediction ID |
| `source_adset` | AdCampaign | The source ad set (if copied) |
| `source_adset_id` | numeric string | Source ad set ID |
| `start_time` | datetime | Start time |
| `status` | enum `{ACTIVE, PAUSED, DELETED, ARCHIVED}` | Status |
| `targeting` | Targeting | Audience targeting spec |
| `time_based_ad_rotation_id_blocks` | list\<list\<unsigned int32\>\> | Ad rotation blocks |
| `time_based_ad_rotation_intervals` | list\<unsigned int32\> | Ad rotation intervals |
| `updated_time` | datetime | Updated time |
| `use_new_app_click` | bool | Use new app click |

---

## Targeting Fields (inside `targeting` object)

Key fields in the targeting spec:

| Field | Description |
|-------|-------------|
| `geo_locations` | Countries, regions, cities, zips. e.g. `{"countries": ["US"]}` |
| `age_min` | Minimum age (18–64) |
| `age_max` | Maximum age (18–65+) |
| `genders` | `[1]` = male, `[2]` = female |
| `publisher_platforms` | `facebook`, `instagram`, `audience_network`, `messenger` |
| `facebook_positions` | `feed`, `right_hand_column`, `marketplace`, `video_feeds`, `story`, `search` |
| `instagram_positions` | `stream`, `story`, `reels` |
| `interests` | Interest targeting |
| `behaviors` | Behavioral targeting |
| `custom_audiences` | Custom audiences to include |
| `excluded_custom_audiences` | Custom audiences to exclude |
| `locales` | Language targeting |

---

## EU Digital Services Act (DSA) Requirements

Beginning August 16, 2023, ad sets targeting EU and associated territories must include:
- `dsa_beneficiary` — who benefits from the ad
- `dsa_payor` — who pays for the ad

If not provided, the ad will not be published. Use `default_dsa_payor` and `default_dsa_beneficiary` on the ad account to set defaults.

---

## Flagged Custom Audiences / Conversions

If a custom audience or conversion is flagged:
- The `issues_info` list will be populated with error code `2460003` (audience) or `2460004` (conversion)
- Ad set creation/editing containing flagged items will fail with an error listing restricted IDs

Error responses:

```json
{
  "error": {
    "error_subcode": 246003,
    "error_data": {
      "Restricted Custom Audience IDs": ["<CUSTOM_AUDIENCE_ID1>"]
    }
  }
}
```

---

## Edges

| Edge | Description |
|------|-------------|
| `/activities` | Log of actions taken on the ad set |
| `/adcreatives` | Ad creatives used in this ad set |
| `/ads` | Ads in this ad set |
| `/copys` | Copies of this ad set |
| `/insights` | Insights on advertising performance |
| `/promoted_object` | Object being promoted |
| `/targeting_sentence_lines` | Human-readable targeting description |
