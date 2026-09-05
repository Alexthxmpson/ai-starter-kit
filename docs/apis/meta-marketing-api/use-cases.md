# Meta Marketing API — Use Cases & Practical Summary

**Source:** https://developers.facebook.com/docs/marketing-api/
**Date saved:** 2026-03-09

---

## What You Can Do

### Free Tier (Standard Access — auto-approved)
- Read all campaigns, ad sets, and ads across your own ad accounts
- Create and manage campaigns programmatically
- Pull performance insights (impressions, clicks, spend, CTR, ROAS)
- Upload images and create ad creatives
- Manage up to 9,000 score points per account (rate limit)
- Build complete campaign automation for your own business

### Requires Advanced Access (App Review required)
- Manage ad accounts on behalf of OTHER businesses
- White-label tooling or SaaS dashboards for clients
- Significantly higher rate limit capacity
- Access to certain restricted features (housing/employment/credit ad categories)

### Easy (low complexity)
- List and pause/enable campaigns via API
- Pull daily spend and performance reports
- Duplicate campaigns by reading and re-POSTing
- Schedule campaigns with start_time/end_time

### Complex (higher effort)
- Automated creative testing with dynamic variables
- Rule-based budget optimization (requires reading insights + writing budget updates)
- Lookalike audience creation and refresh automation
- Cross-account reporting dashboards
- Async bulk reporting for large date ranges

---

## Practical Automations Table

| # | Automation | Difficulty | Endpoints Used | Value |
|---|---|---|---|---|
| 1 | Daily spend report to Discord/Notion | Easy | `/insights` | Know your burn rate every morning |
| 2 | Auto-pause underperforming ads (CPC > threshold) | Medium | `/insights` + `POST /{ad_id}` | Stop wasting budget automatically |
| 3 | Bulk campaign upload from CSV/spreadsheet | Medium | `POST /campaigns` + `POST /adsets` + `POST /ads` | Launch 10+ campaigns in minutes |
| 4 | Budget reallocation (shift budget to top performer) | Medium | `/insights` + `POST /{adset_id}` | ROAS optimization at scale |
| 5 | A/B creative rotation — pause loser, scale winner | Medium | `/insights` + `POST /{ad_id}` | Continuous creative testing |
| 6 | Scheduled campaign activation (product launch) | Easy | `POST /{campaign_id}?status=ACTIVE` | No manual launch required |
| 7 | Weekly performance PDF/Notion report | Medium | `/insights` with breakdowns | Client reporting automation |
| 8 | Lookalike audience refresh from Airtable CRM | Complex | `POST /customaudiences` + `POST /adsets` | Always-fresh audience from real customer data |
| 9 | Cross-account consolidated dashboard | Complex | `/insights` across multiple accounts | Agency-level reporting |
| 10 | Auto-scale winning ad sets (increase budget 20% if ROAS > target) | Medium | `/insights` + `POST /{adset_id}` | Growth without manual monitoring |
| 11 | Image upload pipeline (generate → upload → attach to creative) | Medium | `POST /adimages` + `POST /adcreatives` | Fully automated creative production |
| 12 | Alert on ad disapprovals via webhook | Easy | Webhooks subscription | Catch policy violations instantly |

---

## Scripts Already Built

| Script | Purpose | Location |
|---|---|---|
| `fb_api.py` | Core API wrapper — auth, get/post, pagination | `Documentation API/Meta Marketing API/fb_api.py` |
| `bulk_upload.py` | Reads a CSV and creates campaigns + ad sets + ads in bulk | `Documentation API/Meta Marketing API/bulk_upload.py` |
| `optimizer.py` | Pulls insights daily, pauses ads below CTR/CPC thresholds, scales winners | `Documentation API/Meta Marketing API/optimizer.py` |

---

## Key Limits and Gotchas

### Rate Limits
- Development tier: max score 60, resets every 300s — barely usable for production
- Standard tier: max score 9,000 — sufficient for most single-account use cases
- Read = 1 point, Write = 3 points
- Mutation QPS hard cap: 100 requests/second per app+account pair
- Insights async: max 10 reach-breakdown requests/day for data older than 13 months
- Monitor quota via `X-Business-Use-Case-Usage` response header

### Budget Gotchas
- Budgets are always in **cents** of the account currency (e.g., 5000 = $50.00 USD)
- You cannot have both `daily_budget` AND `lifetime_budget` on the same ad set
- Lifetime budget requires `end_time` to be set
- Campaign Budget Optimization (CBO): set budget on the campaign, not the ad sets

### Status Gotchas
- Effective status != status. An ad may have `status=ACTIVE` but `effective_status=CAMPAIGN_PAUSED` because the parent campaign is paused
- Always check `effective_status` for actual delivery state
- Statuses: `ACTIVE`, `PAUSED`, `DELETED`, `ARCHIVED` — deleted items cannot be restored

### Special Ad Categories
- `special_ad_categories` is **required** on every campaign POST — pass `[]` for normal ads
- Housing, employment, credit, and political ads have restricted targeting (no age/gender targeting in the US)

### Targeting Restrictions (2025+)
- Custom audiences suggesting health conditions or financial status will be flagged from September 2025
- Behavior-based categories are being deprecated — verify category IDs via Targeting Search API
- Interests/behaviors require numeric IDs (fetch from `/search?type=adinterest&q=keyword`), not plain text strings

### Image Requirements
- Upload via `POST /act_{id}/adimages` — get back a `hash` to use in creatives
- Supported formats: JPEG, PNG
- Minimum size: 600x315px for link ads; 1080x1080px recommended for square
- High text overlay reduces reach (keep text under 20% of image area)
- Image must be publicly accessible if uploading via URL

### Access Token Expiry
- Short-lived user tokens expire in 1–2 hours
- Long-lived user tokens expire in ~60 days
- System user tokens: set to **never expire** in Business Manager — use these for production
- Always use system user tokens for server-to-server automation

### Insights Data Delay
- Data is typically delayed 15–30 minutes for most metrics
- Reach and frequency data may be delayed up to 24–48 hours
- Attribution windows affect conversion counts (default: 7-day click, 1-day view)
- Historical data available up to 37 months via `date_preset=maximum`

### Pagination
- Default page size is 25 results — always paginate using the `after` cursor
- Use `&limit=100` to fetch up to 100 results per page
- Never assume all data is on page 1

### API Version Lifecycle
- Each version supported for 2 years after release
- Meta releases new versions every ~6 months
- Objective naming is transitioning to `OUTCOME_*` names — plan migration for v17.0+
- Current stable: v25.0

---

## Required Environment Variables

```env
META_ACCESS_TOKEN=your_system_user_token
META_AD_ACCOUNT_ID=act_123456789
META_APP_ID=your_app_id
META_APP_SECRET=your_app_secret
META_PAGE_ID=your_facebook_page_id
```

---

## Useful Companion Resources

| Resource | URL |
|---|---|
| Official Marketing API docs | https://developers.facebook.com/docs/marketing-api/ |
| Graph API Explorer (test calls) | https://developers.facebook.com/tools/explorer/ |
| Access Token Debugger | https://developers.facebook.com/tools/debug/accesstoken/ |
| Business Manager | https://business.facebook.com/settings/ |
| Targeting Search API | `GET /search?type=adinterest&q={keyword}&access_token={token}` |
| Ad Preview API | `GET /{creative_id}/previews?ad_format=DESKTOP_FEED_STANDARD` |
| Ads Insights Reference | https://developers.facebook.com/docs/marketing-api/reference/ads-insights/ |
| Error Codes Reference | https://developers.facebook.com/docs/marketing-api/error-reference/ |
