# Foreplay API — Use Cases & Practical Summary

## What You Can Do

### Free Tier (All Plans Include API)
- 10,000 credits/month (monthly billing) or 20,000 credits/month (annual billing)
- 1 credit = 1 ad returned; 1 credit = 1 brand request (regardless of results count)
- Discovery search across 100M+ ads
- Full ad data including transcriptions, emotional drivers, content classification
- SwipeFile access (your saved ads)
- Board management
- Brand analytics
- Usage monitoring (0 credits)

### Paid Tiers (higher limits, more Spyder brands)

| Plan | Monthly | Annual/mo | Users | Spyder Brands | Lens Brands |
|------|---------|-----------|-------|---------------|-------------|
| Basic | $59 | $49 | 1 (+$20/extra) | Included | Included |
| Workflow | $175 | $149 | Up to 5 (+$20/extra) | 15 (monthly) / Unlimited (annual) | 1 (Unlimited Ad Spend) |
| Agency | $459 | $389 | Up to 10 (+$20/extra) | 50 (monthly) / Unlimited (annual) | 10 (Unlimited Ad Spend) |
| Enterprise | Custom | Custom | Unlimited | Custom | Custom |

---

## Practical Ideas / Automations

| Idea | Endpoint(s) | Complexity | Credits/Run |
|------|-------------|------------|-------------|
| **Competitor Ad Monitor** — daily scan of competitor's new ads | `/api/brand/getAdsByBrandId` with date range | Easy | ~50-100/day |
| **Ad Creative Swipe File Builder** — auto-save high-performing ads from niche | `/api/discovery/ads` + filter by niche + longest_running | Easy | ~100-250/run |
| **Winning Ad Transcript Analyzer** — pull video ad transcripts for copywriting research | `/api/discovery/ads` (video only) → extract `full_transcription` | Easy | ~50/run |
| **Emotional Tone Analyzer** — find ads using specific emotional drivers | `/api/discovery/ads` → filter results by `emotional_drivers` scores | Easy | ~100/run |
| **Landing Page Scraper Trigger** — get `link_url` from top ads, then scrape with Firecrawl | `/api/discovery/ads` → extract `link_url` → Firecrawl | Medium | ~50/run |
| **Creative Velocity Dashboard** — track how fast competitors launch new creatives | `/api/brand/analytics` per competitor | Easy | ~5-10/run |
| **Duplicate Creative Detector** — find who's using the same creative assets | `/api/ad/duplicates/{ad_id}` | Easy | ~1-10/run |
| **Niche Market Scanner** — discover all brands advertising in a niche | `/api/discovery/brands/explore` with niche filter | Easy | ~1/run |
| **Domain-to-Ads Pipeline** — enter competitor domain, get all their ads | `/api/brand/getBrandsByDomain` → `/api/brand/getAdsByBrandId` | Easy | ~50-100/run |
| **Ad Longevity Report** — find ads running 30+ days (likely profitable) | `/api/discovery/ads` + `running_duration_min_days=30` | Easy | ~100-250/run |
| **Multi-Brand Competitive Report** — compare ad strategies across 5-10 competitors | `/api/brand/getAdsByBrandId` with multiple brand_ids | Medium | ~500-1000/run |
| **Video Ad Hook Library** — extract first 5 seconds of transcripts from winning video ads | `/api/discovery/ads` (video, longest_running) → `timestamped_transcription` | Medium | ~100/run |
| **Content Type Distribution Analysis** — what % of a brand's ads are UGC vs testimonial vs promo | `/api/brand/getAdsByBrandId` → aggregate `content_filter` scores | Medium | ~200/run |
| **CTA Pattern Mining** — analyze which CTAs correlate with long-running ads | `/api/discovery/ads` → map `cta_type` + `cta_title` vs `running_duration` | Medium | ~250/run |
| **Weekly Competitor Digest** — Trigger.dev scheduled task, weekly email/Discord summary | `/api/spyder/brand/ads` + Trigger.dev + Discord webhook | Medium | ~200/week |
| **Ad Creative Brief Generator** — pull top ads, feed to Claude for brief generation | `/api/discovery/ads` → Claude analysis → output brief | Medium | ~50-100/run |

---

## Key Limits & Gotchas

1. **Credit system is per-ad**: fetching 250 ads in one request = 250 credits. Budget carefully.
2. **Brand requests are cheap**: 1 credit regardless of how many brands returned.
3. **Max limit per request**: 250 for ads, 10 for brands (except discovery/brands/explore = 10,000).
4. **Rate limits exist** but exact numbers are not published. Use exponential backoff.
5. **Platforms covered**: Facebook, Instagram, Audience Network, Messenger, TikTok, YouTube, LinkedIn, Threads, WhatsApp (per the enum, though primary coverage is Meta/Facebook Ad Library).
6. **No write API**: you cannot save ads to swipefile, create boards, or subscribe to brands via API. Read-only.
7. **Manual uploads excluded**: SwipeFile endpoint does not return manually uploaded ads.
8. **Analytics max range**: 30 days per request for brand analytics.
9. **No official SDK**: use raw HTTP requests (Python requests / JS fetch).
10. **MCP server available**: can be added directly as an MCP in Claude Code for direct LLM access.
11. **Transcriptions are free**: included in every ad response, no extra credits.
12. **Emotional drivers and content classification**: AI-powered analysis included in ad responses.

---

## Available Scripts/Tools

**No custom scripts built yet.** Recommended first build:

```python
# foreplay_client.py — minimal wrapper
import requests

class ForeplayClient:
    BASE = "https://public.api.foreplay.co"
    
    def __init__(self, api_key: str):
        self.headers = {"Authorization": api_key}
    
    def search_ads(self, query=None, **filters):
        params = {k: v for k, v in {**filters, "query": query}.items() if v is not None}
        return requests.get(f"{self.BASE}/api/discovery/ads", params=params, headers=self.headers).json()
    
    def get_brand_by_domain(self, domain: str):
        return requests.get(f"{self.BASE}/api/brand/getBrandsByDomain", params={"domain": domain}, headers=self.headers).json()
    
    def get_brand_ads(self, brand_ids: list, **filters):
        params = {**filters, "brand_ids": brand_ids}
        return requests.get(f"{self.BASE}/api/brand/getAdsByBrandId", params=params, headers=self.headers).json()
    
    def usage(self):
        return requests.get(f"{self.BASE}/api/usage", headers=self.headers).json()
```

---

## Integration Priority for Claude Code Warp

1. **Add MCP server** to `.mcp.json` (native LLM access to all endpoints)
2. **Build `/foreplay` skill** for competitive ad research
3. **Connect to Trigger.dev** for weekly competitor digest
4. **Feed ad transcripts** into copywriting skills (hormozi, vsl-scripts, facebook-ad-copy)
5. **Cross-reference** with existing `/market-intelligence` and `/company-niche-research` skills
