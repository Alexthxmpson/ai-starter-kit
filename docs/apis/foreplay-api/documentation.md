# Foreplay Public API — Technical Documentation

**Source**: https://docs.foreplay.co / https://public.api.foreplay.co/openapi.json
**Date Saved**: 2026-04-12
**API Version**: 0.18.1b (OpenAPI 3.1.0)
**Terms of Service**: https://www.foreplay.co/page/terms-of-service

---

## Base URL

```
https://public.api.foreplay.co
```

All endpoints are prefixed with `/api/`.

---

## Authentication

**Method**: Bearer Token (HTTP Bearer scheme)

Every request must include the API key in the `Authorization` header:

```http
Authorization: YOUR_API_KEY
```

Generate your API key at: https://app.foreplay.co/api-overview

**Security Tips**:
- Never commit keys to source control
- Rotate keys immediately if exposed

---

## Credit System

### Credit Costs

| Action | Cost | Example |
|--------|------|---------|
| Retrieving Ads | 1 credit per ad returned | A request returning 25 ads costs 25 credits |
| Retrieving Brands | 1 credit per request | A request returning 1 or 10 brands costs 1 credit |

### Monitoring Usage
1. Check `X-Credits-Remaining` response header
2. Use `GET /api/usage` (costs 0 credits)
3. View usage at https://app.foreplay.co/api-logs

### Credit Allowances by Plan

| Plan | Monthly (credits) | Annual (credits) | Price (monthly) | Price (annual/mo) |
|------|-------------------|-------------------|-----------------|-------------------|
| Basic | 10,000 | 20,000 | $59/mo | $49/mo |
| Workflow | 10,000 | 20,000 | $175/mo | $149/mo |
| Agency | 10,000 | 20,000 | $459/mo | $389/mo |
| Enterprise | Custom | Custom | Custom | Custom |

Note: All plans include API access. The credit difference between monthly and annual is 10K vs 20K.

---

## Response Headers

All responses include:

| Header | Description |
|--------|-------------|
| `X-Process-Time` | Server processing time |
| `X-Trace-ID` | Unique request ID (for debugging/support) |
| `X-Credits-Remaining` | Credits left on your plan |
| `X-Credit-Cost` | Credit cost of this specific request |

---

## Error Codes

| Code | Meaning | Cause |
|------|---------|-------|
| 400 | Bad Request | Invalid parameters, incorrect data types |
| 401 | Unauthorized | Missing or invalid API key |
| 402 | Payment Required | Out of credits |
| 403 | Forbidden | Plan doesn't include this feature |
| 404 | Not Found | Incorrect ID |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Temporary server issue |

Error response format:
```json
{
  "metadata": {
    "success": false,
    "message": "Authentication failed.",
    "status_code": 401,
    "processed_at": 1756488402833
  },
  "error": {
    "message": "Invalid or missing API key"
  },
  "data": []
}
```

---

## Rate Limiting

Rate limits enforced; exceeding triggers `429 Too Many Requests`. Implement retry with exponential backoff. Exact rate limits are not published in the docs.

---

## Pagination

Two methods depending on endpoint:

### 1. Cursor-Based (preferred)
Use `metadata.cursor` from response to fetch next page. Keep same `limit` between requests.

### 2. Offset-Based
Use `offset` and `limit` params. Increment offset by limit for each page.

Max `limit` for ad endpoints: **250**
Max `limit` for brand endpoints: **10** (except discovery/brands/explore which allows up to 10,000)

---

## Endpoints

### SwipeFile

#### GET /api/swipefile/ads
**Get user's swipefile ads (personal saved collection)**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| start_date | No | string | Inclusive start date (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS) |
| end_date | No | string | Inclusive end date |
| live | No | enum | `true` or `false` |
| display_format | No | array | video, image, carousel, dco, story, reels |
| publisher_platform | No | array | facebook, instagram, audience_network, messenger |
| niches | No | array | See Niche enum below |
| market_target | No | array | b2b, b2c |
| languages | No | array | en, fr, es, de, etc. |
| video_duration_min | No | number | Min video duration (seconds) |
| video_duration_max | No | number | Max video duration (seconds) |
| running_duration_min_days | No | integer | Min days ad has been running |
| running_duration_max_days | No | integer | Max days ad has been running |
| offset | No | integer | Pagination offset (default 0) |
| limit | No | integer | Results per page (max 250, default 10) |
| order | No | enum | saved_newest (default), newest, oldest, longest_running, most_relevant |

**Note**: Manual uploads are NOT returned. Only unique ads returned.

---

### Boards

#### GET /api/boards
**Get all boards for authenticated user**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| offset | No | integer | Default 0 |
| limit | No | integer | Max 10, default 10 |

#### GET /api/board/brands
**Get brands in a specific board**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| board_id | Yes | string | Board ID |
| offset | No | integer | Default 0 |
| limit | No | integer | Max 10, default 10 |

#### GET /api/board/ads
**Get ads by board ID with filters**

Same filter parameters as swipefile/ads, plus:

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| board_id | Yes | string | Board ID |
| cursor | No | string | Cursor from previous response |

Uses cursor-based pagination. Max limit: 250.

---

### Spyder (Competitor Tracking)

#### GET /api/spyder/brands
**Get user's tracked/subscribed brands**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| offset | No | integer | Default 0 |
| limit | No | integer | Max 10, default 10 |

#### GET /api/spyder/brand
**Get specific tracked brand details**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| brand_id | Yes | string | Brand ID (must be subscribed) |

#### GET /api/spyder/brand/ads
**Get ads for a tracked brand**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| brand_id | Yes | string/integer | Brand ID (get from /spyder/brands or from URL: app.foreplay.co/library-spyder/{brand_id}) |

Plus all standard ad filters (start_date, end_date, live, display_format, publisher_platform, niches, market_target, languages, video_duration_min/max, running_duration_min/max_days, cursor, limit, order).

---

### Ad (Single Ad Lookup)

#### GET /api/ad
**Get ad details by query parameter**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| ad_id | Yes | string | Unique ad identifier |

#### GET /api/ad/{ad_id}
**Get ad details by path parameter** (identical to above, RESTful variant)

#### GET /api/ad/duplicates/{ad_id}
**Find ads using the same image or video as this ad**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| ad_id | Yes | string (path) | Ad ID to find duplicates for |

Returns all ads sharing the same creative asset.

---

### Brand

#### GET /api/brand/getAdsByBrandId
**Get ads by brand ID(s) — supports multiple brands in one request**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| brand_ids | Yes | array of strings | One or more brand IDs |

Plus all standard ad filters, cursor pagination, max limit 250.

#### GET /api/brand/getAdsByPageId
**Get ads by Facebook Page ID**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| page_id | Yes | string/integer | Facebook page numeric ID |

Plus all standard ad filters, cursor pagination, max limit 250.

#### GET /api/brand/getBrandsByDomain
**Find brands associated with a domain**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| domain | Yes | string | Full URL or domain (e.g. "nike.com" or "https://nike.com") |
| limit | No | integer | Max 10, default 10 |
| order | No | enum | most_ranked (default), least_ranked |

Domain is auto-normalized. Excluded domains are blocked.

#### GET /api/brand/analytics
**Brand analytics: running ads distribution and creative velocity**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| id | Yes | string | Brand ID (20-25 char alphanumeric) or Page ID (numeric) |
| start_date | No | string | Start date (max 30-day range) |
| end_date | No | string | End date |
| order | No | enum | newest, oldest, longest_running, relevance |

---

### Discovery (Full Database Search)

#### GET /api/discovery/ads
**Search and filter ads across entire database**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| query | No | string | Search text for ad name/description (leave empty for filter-only) |

Plus all standard ad filters, cursor pagination, max limit 250.

This is the main endpoint for broad competitive research.

#### GET /api/discovery/brands
**Search brands by name (fuzzy matching)**

| Parameter | Required | Type | Description |
|-----------|----------|------|-------------|
| query | Yes | string | Brand name search (fuzzy matching) |
| limit | No | integer | Max 10, default 10 |

#### GET /api/discovery/brands/explore
**Discover brands based on ad criteria**

Same ad filters as discovery/ads but no `query` or `cursor` params. Returns distinct brands. Max limit: **10,000**.

---

### Usage

#### GET /api/usage
**Get credit usage information (costs 0 credits)**

No parameters required. Returns:
```json
{
  "data": {
    "start_date": "...",
    "end_date": "...",
    "total_credits": 10000,
    "remaining_credits": 8750,
    "user": { "id": "...", "email": "..." }
  }
}
```

---

## MCP Integration

Foreplay exposes an MCP (Model Context Protocol) server:

**MCP Base URL**: `https://public.api.foreplay.co/mcp`

Features:
- HTTP endpoints for all API methods
- SSE (Server-Sent Events) for streaming
- Same API key auth as main API

---

## Data Model

### Ad Object (AdResponse)

| Field | Type | Description |
|-------|------|-------------|
| id | string | Unique Foreplay ad identifier |
| ad_id | string | Platform-specific ad identifier |
| name | string | Ad name/headline |
| brand_id | string | Associated brand ID |
| description | string | Text description |
| headline | string | Headline/main text |
| cta_title | string | CTA text (e.g. "Shop Now") |
| categories | array[string] | Categories the ad belongs to |
| creative_targeting | string | Targeting info (e.g. "18-35, women") |
| languages | array[string] | Languages used |
| market_target | string | b2b or b2c |
| niches | array[string] | Relevant niches |
| product_category | string | Product category |
| timestamped_transcription | array[TimestampedTranscription] | Timestamped segments (video ads) |
| full_transcription | string | Complete transcription text (video ads) |
| cards | array[CardModel] | Carousel/DCO/DPA components |
| avatar | string (URL) | Ad avatar image URL |
| cta_type | string | CTA type (SHOP_NOW, SUBSCRIBE) |
| display_format | string | Format: video, image, carousel, dco, dpa, multi_images, etc. |
| emotional_drivers | EmotionalDrivers | Emotional analysis scores (15 emotions) |
| link_url | string (URL) | Destination/landing page URL |
| live | boolean | Currently active |
| persona | PersonaModel | Target persona (age, gender) |
| publisher_platform | array[string] | Platforms: facebook, instagram, audience_network, messenger, tiktok, youtube, linkedin, threads, whatsapp |
| started_running | integer (timestamp) | Unix timestamp when ad started |
| thumbnail | string (URL) | Thumbnail image URL |
| time_product_was_mentioned | unknown | When product first mentioned |
| type | string | Ad type |
| video | string (URL) | Video file URL |
| image | string (URL) | Image file URL |
| content_filter | ContentFilterModel | Content classification scores |
| running_duration | object | How long ad has been running (e.g. {"days": 10}) |
| video_duration | number | Video duration in seconds |

### EmotionalDrivers (15 emotions, each integer 0-100 score)

| Field | Type |
|-------|------|
| achievement | integer |
| anger | integer |
| authority | integer |
| belonging | integer |
| competence | integer |
| curiosity | integer |
| empowerment | integer |
| engagement | integer |
| esteem | integer |
| fear | integer |
| guilt | integer |
| nostalgia | integer |
| nurturance | integer |
| security | integer |
| urgency | integer |

### ContentFilterModel (content classification scores, each number 0-1)

| Field |
|-------|
| Facts_and_Stats |
| Features_and_Benefits |
| Promotion_and_Discount |
| Testimonial_Review |
| other |
| UGC |
| Us_vs_Them |
| Before_and_After |
| Podcast |
| Reasons_why |
| Media_and_Press |
| Unboxing |
| Green_Screen |
| Holiday_Seasonal |

### CardModel (carousel/DCO/DPA card)

| Field | Type |
|-------|------|
| cta_text | string |
| description | string |
| headline | string |
| image | string (URL) |
| video | string (URL) |
| link_description | string |
| title | string |
| type | string |
| timestamped_transcription | array |
| full_transcription | string |
| video_duration | number |

### PersonaModel

| Field | Type |
|-------|------|
| age | string (e.g. "18-35") |
| gender | string (e.g. "women") |

### TimestampedTranscription

| Field | Type |
|-------|------|
| startTime | number |
| endTime | number |
| sentence | string |

### Brand Object

| Field | Type | Description |
|-------|------|-------------|
| id | string | Unique brand identifier |
| name | string | Brand name |
| description | object | Brand description |
| category | string | Brand category/vertical |
| niches | array[string] | Relevant niches |
| verification_status | string | Verification status |
| url | string | Main website URL |
| websites | array[string] | Additional website URLs |
| avatar | string (URL) | Brand avatar image |
| ad_library_id | string | Platform ad library ID |
| is_delegate_page_with_linked_primary_profile | boolean | Delegate page flag |

---

## Enum Values

### DisplayFormat
carousel, dco, dpa, event, image, multi_images, multi_medias, multi_videos, page_like, text, video

### PublisherPlatform
facebook, instagram, audience_network, messenger, tiktok, youtube, linkedin, threads, whatsapp

### Niche
accessories, app/software, beauty, business/professional, education, entertainment, fashion, food/drink, health/wellness, home/garden, jewelry/watches, other, parenting, pets, real estate, service business, medical, charity/nfp, kids/baby

### MarketTarget
b2b, b2c

### Language
dutch/flemish, english, french, german, italian, japanese, latvian, lithuanian, polish, portuguese, romanian/moldavian/moldovan, serbian, slovene, spanish/castilian, swedish

### SortOrder
newest, oldest, longest_running, most_relevant

### SwipefileSortOrder
saved_newest, newest, oldest, longest_running, most_relevant

### BrandSortOrder
most_ranked, least_ranked

---

## Transcription Notes

- Transcriptions are automatically generated for video/audio content
- Included in ALL ad responses at no extra cost
- Video ads: `full_transcription` and `timestamped_transcription` at root level
- Image ads: both fields are `null`
- Carousel/DCO/DPA ads: check `cards` array — each card has its own transcription fields
- Multi-video ads: transcriptions per video component in `cards` array

---

## Code Examples

### Python
```python
import requests

API_KEY = "your_api_key"
BASE = "https://public.api.foreplay.co"
HEADERS = {"Authorization": API_KEY}

# Search ads by keyword
r = requests.get(f"{BASE}/api/discovery/ads",
    params={"query": "summer sale", "limit": 25, "display_format": "video"},
    headers=HEADERS)
data = r.json()

# Check remaining credits
print(r.headers.get("X-Credits-Remaining"))

# Paginate with cursor
cursor = data["metadata"].get("cursor")
if cursor:
    r2 = requests.get(f"{BASE}/api/discovery/ads",
        params={"query": "summer sale", "limit": 25, "cursor": cursor},
        headers=HEADERS)
```

### JavaScript
```js
const API_KEY = "your_api_key";
const BASE = "https://public.api.foreplay.co";

const res = await fetch(`${BASE}/api/discovery/ads?query=summer+sale&limit=25`, {
  headers: { Authorization: API_KEY }
});
const data = await res.json();
console.log("Credits remaining:", res.headers.get("X-Credits-Remaining"));
```

### cURL
```bash
curl -X GET "https://public.api.foreplay.co/api/discovery/ads?query=summer+sale&limit=25" \
  -H "Authorization: YOUR_API_KEY"
```

---

## SDK / Packages

No official Python or npm SDK exists. Third-party integrations:

| Package | Platform | Description |
|---------|----------|-------------|
| `n8n-nodes-foreplay-api` | npm (n8n) | n8n community node for Foreplay API |
| `@activepieces/piece-foreplay-co` | npm (Activepieces) | Activepieces integration |
| `@scopieflows/app-foreplay-co` | npm (Scopie) | Scopie integration |

No Apify actors found for Foreplay as of 2026-04-12.

---

## Foreplay MCP Server Config

Add to `.mcp.json` for Claude Code integration:
```json
{
  "mcpServers": {
    "foreplay": {
      "type": "url",
      "url": "https://public.api.foreplay.co/mcp",
      "headers": {
        "Authorization": "YOUR_FOREPLAY_API_KEY"
      }
    }
  }
}
```
