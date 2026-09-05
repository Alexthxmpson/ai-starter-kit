# Meta (Facebook) Marketing API — Technical Documentation

**Source:** https://developers.facebook.com/docs/marketing-api/
**Date saved:** 2026-03-09
**Current API version:** v25.0 (backward-compatible from v18.0+)

---

## 1. Overview

The Meta Marketing API is a Graph API extension that lets you programmatically manage Facebook and Instagram ad campaigns, ad sets, ads, creatives, and reporting. It sits on top of the Graph API and follows the same HTTP + JSON conventions.

**Base URL:**
```
https://graph.facebook.com/v18.0/
```
Use `v25.0` for the latest stable version. Version is included in every URL path segment.

---

## 2. Authentication

### 2.1 Token Types

| Token Type | Use Case | Expiry |
|---|---|---|
| User Access Token | Acting on behalf of a logged-in user | ~60 days (short-lived: 1–2 h) |
| App Access Token | App-level calls, no user context | Never expires |
| System User Token | Server-to-server automation (recommended) | Never expires (if set to non-expiring) |
| Page Access Token | Managing Page-linked ad accounts | Inherited from user token expiry |

**Recommended for production:** System User Token — created inside Business Manager under Business Settings > System Users. Does not expire and does not require a logged-in user.

### 2.2 Obtaining a User Access Token (OAuth 2.0)

```
GET https://www.facebook.com/dialog/oauth
  ?client_id={app-id}
  &redirect_uri={redirect-uri}
  &scope=ads_management,ads_read
```

Exchange the code for a long-lived token:
```
GET https://graph.facebook.com/oauth/access_token
  ?grant_type=fb_exchange_token
  &client_id={app-id}
  &client_secret={app-secret}
  &fb_exchange_token={short-lived-token}
```

### 2.3 Required Permissions

| Permission | Purpose |
|---|---|
| `ads_management` | Read and write campaigns, ad sets, ads |
| `ads_read` | Read-only access to ad data and insights |
| `business_management` | Manage Business Manager assets |
| `pages_read_engagement` | Required for Page-linked ad creatives |

Standard access is granted automatically. Advanced access (for managing other people's accounts) requires App Review.

### 2.4 Token in Requests

Pass the token as a query parameter or in the Authorization header:
```
# Query parameter (most common)
GET https://graph.facebook.com/v25.0/act_{AD_ACCOUNT_ID}/campaigns
  ?access_token=YOUR_ACCESS_TOKEN

# Authorization header
Authorization: Bearer YOUR_ACCESS_TOKEN
```

---

## 3. Ad Account Structure

Every resource is scoped to an Ad Account. The prefix `act_` is required in all ad account references:

```
act_{AD_ACCOUNT_ID}
```

Hierarchy:
```
Ad Account
  └── Campaign (objective)
        └── Ad Set (budget, targeting, schedule)
              └── Ad (creative + URL)
                    └── Ad Creative (images, copy, CTA)
```

---

## 4. Key Endpoints

### 4.1 Campaigns

#### List Campaigns
```http
GET https://graph.facebook.com/v25.0/act_{ad_account_id}/campaigns
  ?fields=id,name,objective,status,daily_budget,lifetime_budget
  &access_token={token}
```

**Response:**
```json
{
  "data": [
    {
      "id": "120210000001",
      "name": "Summer Sale Campaign",
      "objective": "LINK_CLICKS",
      "status": "ACTIVE",
      "daily_budget": "5000"
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

#### Create Campaign
```http
POST https://graph.facebook.com/v25.0/act_{ad_account_id}/campaigns
```

**Required fields:**

| Field | Type | Description |
|---|---|---|
| `name` | string | Campaign name |
| `objective` | enum | Campaign objective (see Section 6) |
| `special_ad_categories` | array | Required. Pass `[]` or `["NONE"]` for non-special ads |
| `status` | enum | `ACTIVE`, `PAUSED` |

**Optional fields:**

| Field | Type | Description |
|---|---|---|
| `daily_budget` | int | Daily budget in cents (e.g., 1000 = $10.00) |
| `lifetime_budget` | int | Lifetime budget in cents |
| `bid_strategy` | enum | `LOWEST_COST_WITHOUT_CAP`, `LOWEST_COST_WITH_BID_CAP`, `COST_CAP` |
| `buying_type` | enum | `AUCTION` (default), `RESERVED` |

**Example:**
```bash
curl -X POST \
  -F 'name=My Campaign' \
  -F 'objective=LINK_CLICKS' \
  -F 'status=PAUSED' \
  -F 'special_ad_categories=[]' \
  -F 'daily_budget=5000' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/campaigns
```

**Response:**
```json
{ "id": "120210000001" }
```

#### Update Campaign Status (Pause / Enable)
```http
POST https://graph.facebook.com/v25.0/{campaign_id}
  ?status=PAUSED
  &access_token={token}
```

Or via form:
```bash
curl -X POST \
  -F 'status=PAUSED' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<CAMPAIGN_ID>
```

**Response:** `{ "success": true }`

---

### 4.2 Ad Sets

#### List Ad Sets
```http
GET https://graph.facebook.com/v25.0/act_{ad_account_id}/adsets
  ?fields=id,name,status,daily_budget,targeting,optimization_goal,billing_event
  &access_token={token}
```

#### Create Ad Set
```http
POST https://graph.facebook.com/v25.0/act_{ad_account_id}/adsets
```

**Required fields:**

| Field | Type | Description |
|---|---|---|
| `name` | string | Ad set name |
| `campaign_id` | string | Parent campaign ID |
| `daily_budget` OR `lifetime_budget` | int | Budget in cents |
| `targeting` | JSON | Targeting spec object (see Section 7) |
| `optimization_goal` | enum | `REACH`, `LINK_CLICKS`, `IMPRESSIONS`, `CONVERSIONS`, `APP_INSTALLS`, `VIDEO_VIEWS`, `LEAD_GENERATION` |
| `billing_event` | enum | `IMPRESSIONS`, `LINK_CLICKS`, `APP_INSTALLS` |
| `status` | enum | `ACTIVE`, `PAUSED` |

**Optional fields:**

| Field | Type | Description |
|---|---|---|
| `bid_amount` | int | Bid in cents |
| `start_time` | datetime | ISO 8601 format |
| `end_time` | datetime | ISO 8601 format (required if `lifetime_budget`) |
| `promoted_object` | JSON | Page ID, pixel ID, or app ID depending on objective |
| `pacing_type` | array | `["standard"]` or `["day_parting"]` |

**Example:**
```bash
curl -X POST \
  -F 'name=My Ad Set' \
  -F 'campaign_id=<CAMPAIGN_ID>' \
  -F 'daily_budget=2000' \
  -F 'billing_event=IMPRESSIONS' \
  -F 'optimization_goal=REACH' \
  -F 'bid_amount=2' \
  -F 'targeting={"geo_locations":{"countries":["US"]},"age_min":25,"age_max":45}' \
  -F 'status=PAUSED' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adsets
```

---

### 4.3 Ads

#### List Ads
```http
GET https://graph.facebook.com/v25.0/act_{ad_account_id}/ads
  ?fields=id,name,status,adset_id,creative
  &access_token={token}
```

#### Create Ad
```http
POST https://graph.facebook.com/v25.0/act_{ad_account_id}/ads
```

**Required fields:**

| Field | Type | Description |
|---|---|---|
| `name` | string | Ad name |
| `adset_id` | string | Parent ad set ID |
| `creative` | JSON | `{"creative_id": "<CREATIVE_ID>"}` |
| `status` | enum | `ACTIVE`, `PAUSED` |

**Example:**
```bash
curl -X POST \
  -F 'name=My Ad' \
  -F 'adset_id=<ADSET_ID>' \
  -F 'creative={"creative_id":"<CREATIVE_ID>"}' \
  -F 'status=PAUSED' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/ads
```

---

### 4.4 Upload Image

```http
POST https://graph.facebook.com/v25.0/{ad_account_id}/adimages
```

Note: endpoint uses `{ad_account_id}` (without `act_` prefix in some SDK calls, but use `act_` format in REST).

**Upload from file:**
```bash
curl -X POST \
  -F 'filename=@/path/to/image.jpg' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adimages
```

**Response:**
```json
{
  "images": {
    "image.jpg": {
      "hash": "a83b4b4b3a3d3b2c1a1a1a1a1a1a1a1a",
      "url": "https://fbcdn-photos-b.akamaihd.net/..."
    }
  }
}
```

Use the `hash` value when creating ad creatives.

---

### 4.5 Create Ad Creative

```http
POST https://graph.facebook.com/v25.0/act_{ad_account_id}/adcreatives
```

**Fields:**

| Field | Type | Description |
|---|---|---|
| `name` | string | Creative name |
| `object_story_spec` | JSON | Defines page + link data |
| `image_hash` | string | From adimages upload |
| `url_tags` | string | UTM parameters appended to URL |

**Example (link ad with image):**
```bash
curl -X POST \
  -F 'name=My Creative' \
  -F 'object_story_spec={
    "page_id": "<PAGE_ID>",
    "link_data": {
      "image_hash": "<IMAGE_HASH>",
      "link": "https://example.com/landing",
      "message": "Check out our summer sale!",
      "call_to_action": {
        "type": "SHOP_NOW",
        "value": {"link": "https://example.com/landing"}
      }
    }
  }' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adcreatives
```

**Response:**
```json
{ "id": "120210000999" }
```

**Common `call_to_action` types:**
`SHOP_NOW`, `LEARN_MORE`, `SIGN_UP`, `DOWNLOAD`, `BOOK_NOW`, `CONTACT_US`, `GET_OFFER`, `WATCH_MORE`, `APPLY_NOW`, `DONATE_NOW`

---

### 4.6 Insights (Performance Data)

#### Synchronous Query
```http
GET https://graph.facebook.com/v25.0/act_{ad_account_id}/insights
  ?fields=impressions,clicks,ctr,cpc,cpm,spend,reach,frequency
  &date_preset=last_7d
  &level=campaign
  &access_token={token}
```

Insights are available as an edge on any ads object:
- `act_{ad_account_id}/insights` — account-level
- `{campaign_id}/insights` — campaign-level
- `{adset_id}/insights` — ad set-level
- `{ad_id}/insights` — ad-level

**Response:**
```json
{
  "data": [
    {
      "impressions": "124500",
      "clicks": "3210",
      "ctr": "2.578",
      "cpc": "0.48",
      "cpm": "12.37",
      "spend": "1540.10",
      "reach": "98200",
      "frequency": "1.27",
      "date_start": "2026-03-02",
      "date_stop": "2026-03-09"
    }
  ],
  "paging": { "cursors": { "before": "MAZDZD", "after": "MAZDZD" } }
}
```

#### Asynchronous Report (for large date ranges)
```bash
# Step 1: Create async job
curl -X POST \
  -F 'fields=impressions,clicks,ctr,spend' \
  -F 'date_preset=last_30d' \
  -F 'level=ad' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/insights

# Response: { "report_run_id": "123456789" }

# Step 2: Poll for completion
curl -G \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<REPORT_RUN_ID>

# Step 3: Fetch results when async_status = "Job Completed"
curl -G \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<REPORT_RUN_ID>/insights
```

---

## 5. Insights Fields Reference

### Core Metrics

| Field | Description |
|---|---|
| `impressions` | Number of times ads were shown |
| `clicks` | Total clicks on the ad |
| `unique_clicks` | Unique users who clicked |
| `ctr` | Click-through rate (clicks / impressions × 100) |
| `unique_ctr` | CTR based on unique users |
| `cpc` | Cost per click |
| `cpm` | Cost per 1,000 impressions |
| `cpp` | Cost per 1,000 people reached |
| `spend` | Total amount spent |
| `reach` | Unique accounts reached |
| `frequency` | Average times each person saw the ad (impressions / reach) |
| `actions` | Array of conversion actions and counts |
| `action_values` | Revenue values associated with actions |
| `conversions` | Total conversions |
| `cost_per_action_type` | Cost per specific action type |
| `video_avg_time_watched_actions` | Average video watch time |
| `video_p25_watched_actions` | Users who watched 25% of video |
| `video_p50_watched_actions` | Users who watched 50% of video |
| `video_p75_watched_actions` | Users who watched 75% of video |
| `video_p100_watched_actions` | Users who watched 100% of video |

### Date Presets (`date_preset`)

`today`, `yesterday`, `this_month`, `last_month`, `this_quarter`, `last_7d`, `last_14d`, `last_28d`, `last_30d`, `last_90d`, `last_year`, `maximum` (up to 37 months)

### Breakdowns

| Breakdown | Values |
|---|---|
| `age` | `13-17`, `18-24`, `25-34`, `35-44`, `45-54`, `55-64`, `65+` |
| `gender` | `male`, `female`, `unknown` |
| `country` | ISO country codes |
| `region` | Region name |
| `publisher_platform` | `facebook`, `instagram`, `audience_network`, `messenger` |
| `platform_position` | `feed`, `right_hand_column`, `instant_article`, `marketplace`, `instagram_explore`, `instagram_reels`, `instagram_stories` |
| `device_platform` | `mobile`, `desktop` |
| `impression_device` | `iphone`, `ipad`, `android_smartphone`, `desktop` |

### Levels

| Level | Description |
|---|---|
| `campaign` | Aggregate at campaign level |
| `adset` | Aggregate at ad set level |
| `ad` | Aggregate at individual ad level |
| `account` | Account-wide aggregate |

---

## 6. Campaign Objectives

| Objective | Use Case |
|---|---|
| `LINK_CLICKS` | Drive traffic to a URL |
| `CONVERSIONS` | Optimize for pixel-tracked conversion events |
| `VIDEO_VIEWS` | Maximize video views (ThruPlay or 2-second) |
| `REACH` | Maximize unique reach |
| `BRAND_AWARENESS` | Maximize ad recall lift |
| `LEAD_GENERATION` | Collect leads via native Meta lead form |
| `APP_INSTALLS` | Drive mobile app downloads |
| `PAGE_LIKES` | Grow Facebook Page following |
| `POST_ENGAGEMENT` | Boost likes, comments, shares on a post |
| `MESSAGES` | Drive conversations in Messenger/WhatsApp/Instagram DM |
| `EVENT_RESPONSES` | Drive RSVPs to Facebook events |
| `CATALOG_SALES` | Dynamic product ads from a product catalog |
| `STORE_VISITS` | Drive foot traffic to physical locations |

**Note:** Meta is transitioning to new objective names (OUTCOME_* naming) in newer API versions:
- `OUTCOME_TRAFFIC` → replaces `LINK_CLICKS`
- `OUTCOME_LEADS` → replaces `LEAD_GENERATION`
- `OUTCOME_SALES` → replaces `CONVERSIONS` / `CATALOG_SALES`
- `OUTCOME_ENGAGEMENT` → replaces `POST_ENGAGEMENT`
- `OUTCOME_APP_PROMOTION` → replaces `APP_INSTALLS`
- `OUTCOME_AWARENESS` → replaces `BRAND_AWARENESS` / `REACH`

---

## 7. Targeting Spec Fields

The `targeting` parameter is a JSON object passed to the `/adsets` endpoint.

### Core Demographic Fields

| Field | Type | Description |
|---|---|---|
| `age_min` | int | Minimum age (13–65). Default: 18 |
| `age_max` | int | Maximum age (13–65). Default: 65 |
| `genders` | array | `[1]` = male, `[2]` = female, `[1,2]` = all |
| `user_age_unknown` | bool | Include WhatsApp users with unknown age |

### Geographic Targeting (`geo_locations`)

```json
{
  "geo_locations": {
    "countries": ["US", "GB", "NL"],
    "regions": [{"key": "3847"}],
    "cities": [{"key": "2430536", "radius": 25, "distance_unit": "mile"}],
    "zips": [{"key": "US:94025"}],
    "location_types": ["home", "recent"]
  }
}
```

### Interest & Behavior Targeting

Interests and behaviors use IDs retrieved from the Targeting Search API (`/search?type=adinterest&q={keyword}`).

```json
{
  "interests": [
    {"id": "6003107902433", "name": "Soccer"},
    {"id": "6003139266461", "name": "Movies"}
  ],
  "behaviors": [
    {"id": "6002714895372", "name": "Frequent Travelers"}
  ]
}
```

### Flexible Targeting (`flexible_spec`)

Combines targeting with AND/OR logic:
```json
{
  "flexible_spec": [
    {
      "interests": [{"id": "6003107902433", "name": "Soccer"}],
      "behaviors": [{"id": "6002714895372", "name": "Frequent Travelers"}]
    }
  ],
  "geo_locations": {"countries": ["US"]},
  "age_min": 25,
  "age_max": 45
}
```

### Placement Fields

```json
{
  "publisher_platforms": ["facebook", "instagram", "audience_network"],
  "facebook_positions": ["feed", "right_hand_column", "marketplace", "video_feeds"],
  "instagram_positions": ["stream", "story", "reels", "explore"],
  "device_platforms": ["mobile", "desktop"]
}
```

### Custom Audiences

```json
{
  "custom_audiences": [{"id": "<CUSTOM_AUDIENCE_ID>"}],
  "excluded_custom_audiences": [{"id": "<EXCLUSION_AUDIENCE_ID>"}]
}
```

---

## 8. Rate Limits

### Marketing API vs. Graph API

The Marketing API has its own rate limiting system, separate from the standard Graph API. Marketing API calls do NOT count toward Graph API rate limits.

### Ad Account Level Score Limits

| Tier | Max Score | Block Duration | Decay Rate |
|---|---|---|---|
| Development | 60 | 300 seconds | 300 seconds |
| Standard | 9,000 | 60 seconds | 300 seconds |

Scoring: Read calls = 1 point, Write calls = 3 points.

### QPS Limits (Mutation Endpoints)

- **100 requests per second** per app + ad account combination
- Applies to: create/edit campaigns, ad sets, ads
- Operates in real-time to catch traffic spikes

### Insights Rate Limits

- Reach-related breakdown queries: limited to **10 async requests per ad account per day** for date ranges older than 13 months
- Monitor via `x-Fb-Ads-Insights-Reach-Throttle` response header

### Rate Limit Headers

```
X-Business-Use-Case-Usage: {"<AD_ACCOUNT_ID>":[{"type":"ads_management","call_count":5,"total_cputime":1,"total_time":3,"estimated_time_to_regain_access":0}]}
```

---

## 9. Error Codes

### General Graph API Errors

| Code | Subcode | Description | Fix |
|---|---|---|---|
| `1` | — | Unknown error | Retry with exponential backoff |
| `1` | `99` | Wrong `level` parameter value | Check level=campaign vs level=adset |
| `4` | — | Application request limit reached | Wait and retry; reduce call frequency |
| `10` | — | App lacks permission | Request required permissions in App Review |
| `17` | `2446079` | User request limit reached | Back off for 300s |
| `100` | — | Invalid parameter | Check field names and values |
| `100` | `33` | Unsupported POST request | System user not added to ad account |
| `100` | `1487694` | Deprecated targeting category | Use Targeting Search to find active categories |
| `102` | — | Session key invalid | Refresh/regenerate access token |
| `104` | — | Incorrect signature | Recheck app secret |
| `190` | — | Invalid OAuth 2.0 Access Token | Token expired — regenerate |
| `200` | — | Permission error | Check ads_management scope |
| `200` | `1870034` | Custom Audience Terms not accepted | Accept terms in Business Manager |
| `200` | `1870047` | Audience size too low | Broaden targeting |
| `294` | — | App not allow-listed for Marketing API | Submit for App Review |
| `613` | `1487742` | Too many calls from ad account | Rate limit — wait and retry |

### Insights-Specific Errors

| Code | Subcode | Summary | Description |
|---|---|---|---|
| `100` | `1504018` | Request Timed Out | Reduce date range or use async jobs |
| `4` | `1504022` | Too Many API Requests | Backoff and retry |
| `2` | `1504038` | Request Timed Out (sync) | Use async for large queries |
| `-3` | `1504045` | Report Too Large | Break into smaller queries |
| `100` | `3191001` | Permission Error | Check ads_read permission |

### Error Response Format

```json
{
  "error": {
    "message": "Invalid parameter",
    "type": "OAuthException",
    "code": 100,
    "error_subcode": 1487694,
    "error_user_title": "Invalid Targeting",
    "error_user_msg": "The category you selected is no longer available.",
    "fbtrace_id": "Abcd1234"
  }
}
```

---

## 10. Pagination

All list endpoints return cursor-based pagination:

```json
{
  "data": [...],
  "paging": {
    "cursors": {
      "before": "MAZDZD",
      "after": "MQZDZD"
    },
    "next": "https://graph.facebook.com/v25.0/act_.../campaigns?after=MQZDZD&..."
  }
}
```

Fetch next page by appending `&after={cursor}` to the request URL, or use the `next` URL directly. Add `&limit={n}` to control page size (default 25, max 100 for most endpoints).

---

## 11. Batch Requests

Send up to 50 API calls in a single HTTP request:

```bash
curl -X POST \
  -F 'access_token=<ACCESS_TOKEN>' \
  -F 'batch=[
    {"method":"GET","relative_url":"act_<AD_ACCOUNT_ID>/campaigns?fields=id,name"},
    {"method":"GET","relative_url":"act_<AD_ACCOUNT_ID>/adsets?fields=id,name,status"}
  ]' \
  https://graph.facebook.com/
```

---

## 12. Versioning

- New version released approximately every 6 months
- Each version is supported for **2 years** after release
- Breaking changes are only introduced in new versions
- Version is specified in the URL path: `/v25.0/`
- Upgrade path: test on new version, update base URL in code

---

## 13. SDKs

| Language | Package | Install |
|---|---|---|
| Python | `facebook-sdk` | `pip install facebook-sdk` |
| Python (official) | `facebook-business` | `pip install facebook-business` |
| Node.js | `facebook-nodejs-business-sdk` | `npm install facebook-nodejs-business-sdk` |
| PHP | `facebook/php-business-sdk` | `composer require facebook/php-business-sdk` |
| Ruby | `koala` | `gem install koala` |

**Python SDK quick example:**
```python
from facebook_business.api import FacebookAdsApi
from facebook_business.adobjects.adaccount import AdAccount

FacebookAdsApi.init(app_id, app_secret, access_token)
account = AdAccount('act_<AD_ACCOUNT_ID>')
campaigns = account.get_campaigns(fields=['name', 'objective', 'status'])
for campaign in campaigns:
    print(campaign['name'], campaign['status'])
```

---

## 14. Webhooks (Real-Time Updates)

Subscribe to real-time notifications for ad object changes:

1. Go to App Dashboard > Webhooks
2. Subscribe to the `ad_account` topic
3. Select fields: `campaign`, `adset`, `ad`, `campaign_delivery`, `adset_delivery`
4. Meta sends a POST to your callback URL with a JSON payload when events occur

```json
{
  "object": "ad_account",
  "entry": [{
    "id": "act_123456789",
    "time": 1614556800,
    "changes": [{
      "field": "campaign",
      "value": {"id": "120210000001", "verb": "edited"}
    }]
  }]
}
```

---

*Documentation compiled from: https://developers.facebook.com/docs/marketing-api/ | API v25.0 | Date: 2026-03-09*
