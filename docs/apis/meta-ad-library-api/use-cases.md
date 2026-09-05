# Meta Ad Library API -- Use Cases & Practical Summary

**Date:** 2026-04-12

---

## What You Can Do

### Free (Official Meta API -- requires identity verification)

| Use Case | Difficulty | Notes |
|----------|------------|-------|
| Search competitor political ads by keyword | Easy | `search_terms` param, any country |
| Pull all ads from a specific Facebook Page | Easy | `search_page_ids` with up to 10 page IDs |
| Monitor EU/UK commercial ads for any brand | Easy | `ad_reached_countries=['GB']` + `ad_type=ALL` |
| Get spend ranges for political advertisers | Easy | `spend` field returns min/max buckets |
| Track when competitors launch/stop ads | Easy | `ad_delivery_start_time` / `ad_delivery_stop_time` |
| Filter ads by media type (video vs image) | Easy | `media_type=VIDEO` |
| Analyze demographic targeting (EU only) | Medium | `demographic_distribution`, `target_ages`, `target_gender` |
| Build a competitive intelligence dashboard | Medium | Paginate through results, store in DB, analyze trends |
| Track ad creative changes over time | Medium | Poll API periodically, diff `ad_creative_bodies` |
| Bulk export ad data to CSV | Medium | Use minimaxir scraper or custom pagination script |

### Paid (Third-Party APIs / Scraping Services)

| Use Case | Difficulty | Service | Cost |
|----------|------------|---------|------|
| Get ALL commercial ads globally (not just EU) | Easy | Apify, SearchAPI | $0.75-5.80/1K ads |
| Download actual image files | Easy | SearchAPI (returns `original_image_url`) | API pricing |
| Download video files | Medium | HAR method or Apify | Free (HAR) or API pricing |
| Get landing page URLs | Easy | SearchAPI, Apify | API pricing |
| Cross-platform ad monitoring (FB + TikTok + Google) | Medium | AdLibrary.com | Subscription |
| Monitor ad creative + copy at scale | Medium | Foreplay, Swipekit | $29-99/mo |

### DIY (Browser Automation / Scraping)

| Use Case | Difficulty | Method |
|----------|------------|--------|
| Scrape ALL active ads for any brand worldwide | Hard | Playwright + stealth + proxies on facebook.com/ads/library/ |
| Extract video_hd_url from ad snapshots | Hard | Intercept AJAX requests via CDP/page.route() |
| Bulk download ad creatives | Hard | Visit ad_snapshot_url pages, parse HTML for media |
| HAR file video extraction | Medium | DevTools Network tab -> export HAR -> parse JSON |

---

## Practical Automation Ideas

| Idea | Stack | Complexity |
|------|-------|------------|
| Daily competitor ad tracker | Python + Ad Library API + Airtable | Medium |
| Ad creative swipe file builder | Apify actor + Notion MCP | Medium |
| Political ad spending dashboard | API + Recharts/D3 + Vercel | Medium |
| Ad copy analyzer (what copy patterns competitors use) | API + Claude analysis | Medium |
| Video ad trend spotter | HAR method or Apify + video download | Hard |
| Cross-brand ad frequency monitor | API + cron job + Discord alerts | Medium |
| New ad launch alerter (notify when competitor launches) | API polling + Trigger.dev + Discord webhook | Medium |
| Ad spend estimation tracker over time | API + time-series DB + dashboard | Medium |

---

## Key Limits & Gotchas

1. **The #1 gotcha:** The API does NOT give you access to all commercial ads globally. Only political ads + EU/UK/Brazil commercial ads. The website shows everything but the API is restricted.

2. **No direct media files:** The API returns `ad_snapshot_url` (a preview page), not actual image/video file URLs. You need scraping workarounds for media files.

3. **Spend/impressions are ranges, not exact:** You get buckets like "500-999" not "$743.21"

4. **Rate limit: ~200 calls/hour.** Not officially documented. Temporary blocks can last hours.

5. **Identity verification required:** Government ID upload + address verification. Can take days to weeks.

6. **Non-political ads expire after 1 year** from the archive. Political ads kept for 7 years.

7. **No engagement metrics:** No CTR, no clicks, no conversions, no comments/likes counts.

8. **No detailed targeting:** You don't get interests, behaviors, custom audiences, or lookalike info. Only age/gender/location (and only for EU ads).

9. **EU political ads stopped:** Since October 2025, no new political ads in EU. Existing archive still available.

10. **Page size trap:** Max 2000 per page but large pages timeout. Use 500-1000 for reliability.

11. **Pagination tokens can exceed 8KB** after many pages, causing 413/414 errors. Use POST requests for deep pagination.

---

## Available Scripts / Tools Already Built

| Tool | Location | What It Does |
|------|----------|--------------|
| `/facebook-ads` skill | `.claude/commands/facebook-ads.md` | Meta Ads Manager skill (manages your own ads, not competitor scraping) |
| minimaxir scraper | `github.com/minimaxir/facebook-ad-library-scraper` | Python, 3 CSVs output, political ads |
| Apify actors | apify.com marketplace | Multiple actors, $0.75-5.80/1K ads |
| SearchAPI | searchapi.io | Unofficial API wrapper with direct media URLs |

---

## Quick Start (Fastest Path to Data)

### Option A: Official API (free, limited scope)
```bash
# 1. Verify identity at facebook.com/ID
# 2. Create app at developers.facebook.com
# 3. Get token from Graph API Explorer
# 4. Query:
curl -G \
  -d "search_page_ids=['COMPETITOR_PAGE_ID']" \
  -d "ad_reached_countries=['ALL']" \
  -d "ad_active_status=ALL" \
  -d "fields=id,page_name,ad_creative_bodies,ad_snapshot_url,spend,impressions,ad_delivery_start_time" \
  -d "access_token=YOUR_TOKEN" \
  "https://graph.facebook.com/v25.0/ads_archive"
```

### Option B: Third-Party API (paid, full scope)
```bash
# SearchAPI -- returns direct image/video URLs, all ad types
curl "https://www.searchapi.io/api/v1/search?engine=meta_ad_library&q=competitor+brand&country=US&api_key=YOUR_KEY"
```

### Option C: Apify (paid, full scope, no code)
1. Go to apify.com/apify/facebook-ads-scraper
2. Enter search terms or page URL
3. Run actor
4. Download results as JSON/CSV with media URLs
