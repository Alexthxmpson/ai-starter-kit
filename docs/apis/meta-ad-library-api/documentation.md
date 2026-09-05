# Meta Ad Library API -- Full Technical Documentation

**Source:** https://developers.facebook.com/docs/graph-api/reference/ads_archive/
**Supplementary:** https://developers.facebook.com/docs/graph-api/reference/archived-ad/
**Date saved:** 2026-04-12
**API Version:** Graph API v25.0 (latest as of date)

---

## 1. Overview

The Meta Ad Library API (`ads_archive` endpoint) provides programmatic, read-only access to Meta's public ad transparency archive. It covers ads across Facebook, Instagram, Messenger, Audience Network, WhatsApp, and Threads.

**Critical scope limitation:** The API primarily returns:
- **Political/issue ads** globally (7-year history)
- **All ad types** (including commercial) that were delivered to **EU/UK/Brazil** users (1-year rolling window)
- Non-political ads outside EU/UK/Brazil are generally NOT available via API

The website at https://www.facebook.com/ads/library/ shows ALL active ads globally regardless of type, but the API does not mirror this full scope.

---

## 2. Base Endpoint

```
GET https://graph.facebook.com/{API_VERSION}/ads_archive
```

Example:
```
https://graph.facebook.com/v25.0/ads_archive
```

---

## 3. Authentication

### Requirements
1. **Facebook Developer Account** -- register at developers.facebook.com
2. **Facebook App** -- create an app in the developer portal
3. **Identity Verification** -- upload government ID at facebook.com/ID; may take days to weeks
4. **User Access Token** -- generate via Graph API Explorer

### Token Types
| Type | Lifespan | Use Case |
|------|----------|----------|
| Short-lived user token | ~1-2 hours | Testing/debugging |
| Long-lived user token | ~60 days | Automation scripts |
| System User token | Never expires | Production systems |

### Getting a Token
1. Go to https://developers.facebook.com/tools/explorer/
2. Select your app
3. Generate User Token (no special permissions needed for Ad Library)
4. Optionally extend via Access Token Debugger to 60-day token

**App Review is NOT required** -- the Ad Library API accesses public archive data, so no special permissions or app review needed, as long as your identity is verified.

---

## 4. Request Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `access_token` | string | Your user/system access token |
| `ad_reached_countries` | array<enum> | ISO country codes, e.g. `['US']`, `['NL','DE']`, or `['ALL']` |

### Search Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `search_terms` | string | Keywords to search (max 100 chars). Blank space = AND. No translation. |
| `search_type` | enum | `KEYWORD_UNORDERED` (default) or `KEYWORD_EXACT_PHRASE` |
| `search_page_ids` | array<int64> | Filter by up to **10** Facebook Page IDs |

### Filtering Parameters

| Parameter | Type | Options |
|-----------|------|---------|
| `ad_type` | enum | `ALL` (default), `POLITICAL_AND_ISSUE_ADS`, `HOUSING_ADS`, `EMPLOYMENT_ADS`, `FINANCIAL_PRODUCTS_AND_SERVICES_ADS` |
| `ad_active_status` | enum | `ACTIVE` (default), `INACTIVE`, `ALL` |
| `media_type` | enum | `ALL`, `IMAGE`, `MEME`, `VIDEO`, `NONE` |
| `publisher_platforms` | array<enum> | `FACEBOOK`, `INSTAGRAM`, `AUDIENCE_NETWORK`, `MESSENGER`, `WHATSAPP`, `OCULUS`, `THREADS` |

### Date Parameters

| Parameter | Type | Format |
|-----------|------|--------|
| `ad_delivery_date_min` | string | `YYYY-MM-DD` |
| `ad_delivery_date_max` | string | `YYYY-MM-DD` |

### Political/Issue-Specific Parameters

| Parameter | Type | Notes |
|-----------|------|-------|
| `bylines` | array<string> | "Paid for by" disclaimers; exact match |
| `estimated_audience_size_min` | int64 | Boundaries: 100, 1K, 5K, 10K, 50K, 100K, 500K, 1M |
| `estimated_audience_size_max` | int64 | Same boundaries |
| `languages` | array<string> | ISO 639-1 codes + CMN, YUE |
| `delivery_by_region` | array<string> | State/province names (political ads only) |
| `unmask_removed_content` | boolean | Show policy-violating content (default: false) |

### Pagination

| Parameter | Type | Description |
|-----------|------|-------------|
| `limit` | int | Results per page. Default: 25. Max: 2,000. |
| `after` | string | Cursor from `paging.cursors.after` in response |

---

## 5. Response Fields (ArchivedAd Object)

### Fields Available for ALL Ads

| Field | Type | Description |
|-------|------|-------------|
| `id` | numeric string | Library ID of the ad |
| `ad_creation_time` | string | UTC timestamp when ad was created |
| `ad_creative_bodies` | list<string> | Text body for each unique ad card |
| `ad_creative_link_captions` | list<string> | CTA section captions |
| `ad_creative_link_descriptions` | list<string> | CTA section descriptions |
| `ad_creative_link_titles` | list<string> | CTA section titles |
| `ad_delivery_start_time` | string | UTC delivery start |
| `ad_delivery_stop_time` | string | UTC delivery stop (null if active) |
| `ad_snapshot_url` | string | URL to view the archived ad (visual preview) |
| `page_id` | numeric string | Facebook Page ID that ran the ad |
| `page_name` | string | Name of the Facebook Page |
| `publisher_platforms` | list<enum> | Platforms where ad appeared |
| `languages` | list<string> | Languages in ad |
| `currency` | string | ISO currency code |
| `bylines` | string | Funding entity ("Paid for by...") |

### Fields Available for Political/Issue Ads + EU/UK/Brazil Ads

| Field | Type | Description |
|-------|------|-------------|
| `spend` | InsightsRangeValue | `{lower_bound, upper_bound}` -- spend ranges (buckets: <100, 100-499, 500-999, 1K-5K, 5K-10K, 10K-50K, 50K-100K, 100K-500K, 500K-1M, >1M) |
| `impressions` | InsightsRangeValue | `{lower_bound, upper_bound}` -- impression ranges |
| `estimated_audience_size` | InsightsRangeValue | Estimated reach |
| `demographic_distribution` | list<AudienceDistribution> | Age/gender reach percentages |
| `delivery_by_region` | list<AudienceDistribution> | Regional reach distribution |
| `target_ages` | list<numeric string> | Targeted age ranges (13-65+) |
| `target_gender` | enum | "Women", "Men", or "All" |
| `target_locations` | list<TargetLocation> | Included/excluded targeting locations |

### EU-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `eu_total_reach` | int32 | Combined reach for EU |
| `age_country_gender_reach_breakdown` | list | Demographic distribution (EU/UK/Brazil only) |
| `beneficiary_payers` | list<BeneficiaryPayer> | Reported beneficiaries and payers (EU only) |
| `total_reach_by_location` | list<KeyValue> | Reach by location |

### Brazil-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `br_total_reach` | int32 | Estimated reach for Brazil |

---

## 6. Sample API Call

```bash
curl -G \
  -d "search_terms=electric vehicles" \
  -d "ad_type=ALL" \
  -d "ad_active_status=ALL" \
  -d "ad_reached_countries=['US']" \
  -d "media_type=VIDEO" \
  -d "fields=id,page_name,page_id,ad_creative_bodies,ad_creative_link_titles,ad_snapshot_url,ad_delivery_start_time,ad_delivery_stop_time,spend,impressions,publisher_platforms,demographic_distribution" \
  -d "limit=25" \
  -d "access_token=YOUR_ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/ads_archive"
```

### Search by Specific Advertiser (Page ID)

```bash
curl -G \
  -d "search_page_ids=['123456789']" \
  -d "ad_reached_countries=['ALL']" \
  -d "ad_active_status=ALL" \
  -d "fields=id,page_name,ad_creative_bodies,ad_snapshot_url,spend,impressions,ad_delivery_start_time" \
  -d "access_token=YOUR_ACCESS_TOKEN" \
  "https://graph.facebook.com/v25.0/ads_archive"
```

---

## 7. Sample Response

```json
{
  "data": [
    {
      "id": "23842378423",
      "page_name": "Tesla",
      "page_id": "12345678",
      "ad_creative_bodies": [
        "Experience the future of driving. Order your Model Y today."
      ],
      "ad_creative_link_titles": [
        "Model Y | Tesla"
      ],
      "ad_snapshot_url": "https://www.facebook.com/ads/archive/render_ad/?id=23842378423&access_token=...",
      "ad_delivery_start_time": "2026-03-15T08:00:00+0000",
      "ad_delivery_stop_time": null,
      "publisher_platforms": ["facebook", "instagram"],
      "spend": {
        "lower_bound": "500",
        "upper_bound": "999"
      },
      "impressions": {
        "lower_bound": "10000",
        "upper_bound": "50000"
      },
      "demographic_distribution": [
        {
          "age": "25-34",
          "gender": "male",
          "percentage": "0.285"
        },
        {
          "age": "25-34",
          "gender": "female",
          "percentage": "0.195"
        }
      ]
    }
  ],
  "paging": {
    "cursors": {
      "before": "abc123...",
      "after": "def456..."
    },
    "next": "https://graph.facebook.com/v25.0/ads_archive?after=def456...&access_token=..."
  }
}
```

---

## 8. Rate Limits

- **Default:** ~200 calls per hour per token
- **Error 613:** Rate limit exceeded -- implement exponential backoff
- Meta does NOT publicly document exact thresholds
- General Graph API rate limiting applies
- Temporary blocks can last hours when exceeded
- Recommended: use page sizes of 500-1000 instead of max 2000 for reliability
- Pagination ends when `data` returns empty array

---

## 9. Video & Image Creative Access

### What the API provides
- `ad_snapshot_url` -- a URL to view the ad in a browser (shows images/video)
- `ad_creative_bodies` -- text content
- Media type classification

### What the API does NOT provide
- Direct image file URLs
- Direct video file URLs
- Downloadable creative assets

### Workaround: HAR File Method
1. Browse facebook.com/ads/library/ with DevTools Network tab open
2. Scroll through results to load ads
3. Export HAR file
4. Parse HAR for `/ads/library/async/search_ads/` requests
5. Video URLs found in:
   - `snapshot.cards[0].video_hd_url`
   - `snapshot.videos[0].video_hd_url`
6. Image URLs in similar nested `snapshot` objects

### Workaround: Snapshot URL Scraping
- Visit each `ad_snapshot_url` programmatically
- Parse the rendered HTML for `<video>` and `<img>` tags
- Extract `src` attributes
- **Warning:** May violate Meta ToS if done at scale

---

## 10. Geographic Restrictions & Data Availability

| Region | Non-Political Ads | Political/Issue Ads | Data Retention |
|--------|-------------------|---------------------|----------------|
| EU/UK | Yes (all types) | Yes | 1 year (non-political), 7 years (political) |
| Brazil | Limited | Yes | 7 years (political) |
| US | No (API only) | Yes | 7 years (political) |
| Rest of World | No (API only) | Yes (where classified) | 7 years (political) |

**Key:** As of October 2025, Meta stopped allowing NEW political/electoral/social issue ads in the EU due to EU regulations. Existing political ads remain in the archive but no new ones are being added for EU.

---

## 11. Error Codes

| Code | Meaning |
|------|---------|
| 190 | Invalid OAuth 2.0 Access Token |
| 100 | Invalid parameter |
| 613 | Rate limit exceeded |
| 1009 | Parameter validation failure |
| 2500 | Graph query parsing error |

---

## 12. Website vs API -- Key Differences

### Available on Website (facebook.com/ads/library/) but NOT via API:
- **ALL active commercial ads globally** (API is limited to EU/UK + political)
- Visual preview with full creative rendering (images, video, carousel)
- Landing page links visible in ad preview
- A/B test variants
- Call-to-action button text and destination URL
- Downloadable creative assets (via browser right-click)
- Ad placement details

### Available via API but harder to get from website:
- Structured JSON data for bulk analysis
- Spend/impression ranges (for qualifying ads)
- Demographic distribution breakdowns
- Target age, gender, location data (EU)
- Funding entity/byline data
- Programmatic pagination through thousands of results

---

## 13. Meta Content Library API (Separate Product)

**Not the same as Ad Library API.** The Content Library API provides access to organic (non-ad) content from Facebook Pages, Groups, Instagram accounts, etc.

- **Access:** Restricted to academic/nonprofit researchers
- **Environment:** Must be used in Meta's Secure Research Environment (cleanroom)
- **Fields:** 100+ data fields across Pages, posts, groups, events, profiles, comments
- **Cost:** Free compute via Meta SRE; SOMAR VDE $371/month per team starting Jan 2026

---

## 14. Meta Marketing API (Separate Product)

The Marketing API at `developers.facebook.com/docs/marketing-api` is for managing YOUR OWN ad campaigns, not competitor intelligence.

**Useful for competitive intelligence:** NO -- it only returns data for ad accounts you have access to.

**What it provides (for your own ads):**
- Exact spend, impressions, clicks, CTR, CPC, conversions
- Detailed targeting settings
- Creative assets
- A/B test results
- Audience insights

**Not useful for:** Seeing competitor ads, competitor spend, or competitor targeting.

---

## 15. Third-Party API Alternatives

### SearchAPI.io (Meta Ad Library engine)
- **Endpoint:** `GET https://www.searchapi.io/api/v1/search?engine=meta_ad_library`
- **Returns direct image URLs:** Yes (`original_image_url`, `resized_image_url`)
- **Returns video URLs:** Yes (when available)
- **Returns:** CTA text, landing page URLs, page like count, page categories
- **Auth:** Simple API key (no Meta identity verification needed)
- **Note:** This is an unofficial scraping-based API

### Apify Actors (multiple)
- `apify/facebook-ads-scraper` -- $3.40-5.80 per 1K ads
- `curious_coder/facebook-ads-library-scraper` -- $0.75 per 1K results
- `leadsbrary/meta-ads-library-scraper` -- $1.50 per 1K ads
- Returns: images, video URLs, landing pages, full creative data

### ScrapeCreators
- **Endpoint:** `GET https://api.scrapecreators.com/v1/facebookadlibrary/profile`
- 100 free API calls, simple API key auth
- Unofficial; video transcription for videos under 2 minutes

### AdLibrary.com
- Covers Facebook, Instagram, TikTok, Google, LinkedIn, X
- Simple API key authentication
- Includes creative assets (image URLs, video thumbnails)

---

## 16. Open-Source GitHub Scrapers

### Official API-Based (require Meta token)

| Repository | Stars | Description |
|------------|-------|-------------|
| `minimaxir/facebook-ad-library-scraper` | ~132 | Python, outputs 3 CSVs (ads, demographics, regions). Original. |
| `skylarcheung/Facebook-Ad-Library-Scraper` | Fork | Better docs for beginners. Fork of minimaxir. |
| `WhoTargetsMe/Ad_Library_API` | -- | Python package for Ad Library data collection |
| `Wesleyan-Media-Project/fb_ad_scraper` | -- | Academic project, stores in database, scrapes media |
| `Lejo1/facebook_ad_library` | -- | Copies ads from API |
| `ChrisFeldmeier/fb_ad_scraper` | -- | Meta Ads Library Scraper |

### Browser-Based (scrape the website)

| Tool | Method | Notes |
|------|--------|-------|
| Apify actors (multiple) | Headless browser | Most reliable for commercial ads |
| Phantombuster | Browser automation | Facebook Ads Library Scraper template |
| Custom Playwright/Selenium | DIY | Requires stealth plugins + proxy rotation |

---

## 17. Playwright/Selenium Scraping Feasibility

### Anti-Bot Difficulty: 5/5 (Very Difficult)

Facebook employs:
- Custom WAF (Web Application Firewall)
- Aggressive bot detection on main Facebook.com
- The Ad Library pages are somewhat less protected than core Facebook, but still challenging

### Recommended Stack
```
Playwright + playwright-stealth + residential proxies
  OR
Patchright (patched Playwright with webdriver=false)
  OR
undetected-playwright-python
```

### Key Techniques
1. Use `playwright-stealth` or `patchright` to avoid `navigator.webdriver` detection
2. Rotate user agents per session
3. Use mobile residential or ISP proxies (NOT datacenter)
4. Add random delays and human-like mouse movements
5. Avoid headless mode if possible (use headed with `--headless=new`)
6. Run from a logged-in Chrome profile for better trust signals

### Practical Reality
- The Ad Library search page (`facebook.com/ads/library/`) is publicly accessible without login
- It's a React SPA that loads ads via AJAX calls to internal endpoints
- Those AJAX endpoints return JSON with full creative data including video_hd_url
- Intercepting these network requests (via `page.route()` or CDP) is more reliable than parsing the DOM
- Expect to update scraper logic every few weeks as Meta changes internal APIs

---

## 18. API Version History Notes

- API versions are bumped quarterly
- Older versions deprecated ~2 years after release
- Always specify version in URL (e.g., `/v25.0/ads_archive`)
- Breaking changes announced in Meta Developer changelog
