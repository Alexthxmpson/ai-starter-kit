# Google Ads API — Use Cases & Practical Guide

**Date:** 2026-03-01

---

## What You Can Do

### Free / No Auth Required
- Nothing — all calls require OAuth 2.0 + a developer token

### Paid / Requires Setup
- Create a Google Ads account with active billing
- Register as a Google Ads API developer and apply for a developer token at developers.google.com/google-ads/api
- Set up OAuth 2.0 credentials (service account, single-user, or multi-user flow)
- **Explorer Access** (default, sandboxed): 2,880 operations/day against production accounts; 15,000/day against test accounts
- **Basic Access**: 15,000 operations/day against both test and production
- **Standard Access**: Higher limits — requires additional review
- Create and manage campaigns (Search, Display, Performance Max, Demand Gen, Shopping, App, Call-only)
- Create and manage ad groups, ads, keywords, and bidding criteria
- Set and modify budgets, bidding strategies (MaximizeClicks, MaximizeConversions, TargetCPA, TargetROAS)
- Define audience targeting: keywords, locations, demographics, Custom and Lookalike audiences
- Pull performance reports at account, campaign, ad group, and ad level using GAQL (Google Ads Query Language)
- Upload offline/server-side conversions via Conversion Upload Service
- Manage manager (MCC) accounts and operate across multiple client accounts from a single token
- Build Performance Max asset groups with AI-assembled creatives
- Use `SearchStream` for streaming large reporting responses without gRPC size limits

### What the API Cannot Do
- Manage legacy video campaigns for writes (read-only via API — use the UI for changes)
- Exceed the immutable 10,000 operations-per-mutate-request limit
- Exceed the 64 MB gRPC response size limit (reduce selected fields or use `SearchStream`)
- Create or modify ad creatives for all campaign types equally — Performance Max uses asset groups, not traditional ads
- Access accounts outside your manager hierarchy without explicit account linking
- Use the API without a valid developer token (even for test accounts)
- Bypass Ad Review — all ads go through Google's automated review process

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key Service / Endpoint |
|---|---|---|---|
| List all campaigns and their statuses | Easy | GAQL: `SELECT campaign.id, campaign.name, campaign.status FROM campaign` | `GoogleAdsService.Search` |
| Pause or enable a campaign | Easy | `CampaignService.MutateCampaigns` with `status: PAUSED / ENABLED` | `CampaignService` |
| Get last 7-day impressions/clicks/spend | Easy | GAQL with `segments.date DURING LAST_7_DAYS` | `GoogleAdsService.Search` |
| Create a new Search campaign with budget | Medium | Create `CampaignBudget` → create `Campaign` with `SEARCH` channel type | `CampaignBudgetService` + `CampaignService` |
| Create an ad group and add keywords | Medium | `AdGroupService.MutateAdGroups` → `AdGroupCriterionService` with keyword criteria | `AdGroupService` + `AdGroupCriterionService` |
| Create a responsive search ad | Medium | `AdGroupAdService.MutateAdGroupAds` with headlines/descriptions array | `AdGroupAdService` |
| Set a TargetCPA bidding strategy | Medium | Create `BiddingStrategy` with `target_cpa`, attach to campaign | `BiddingStrategyService` + `CampaignService` |
| Pull account-level performance report | Medium | GAQL from `customer` resource with metrics and date range | `GoogleAdsService.SearchStream` |
| Upload server-side conversion events | Medium | `ConversionUploadService.UploadClickConversions` with `gclid` + conversion time | `ConversionUploadService` |
| Build a Performance Max campaign | Medium | Create campaign with `PERFORMANCE_MAX` channel type → create Asset Group with images/headlines/logos | `CampaignService` + `AssetGroupService` |
| Automated keyword bid adjustment by performance | Hard | Query keyword CPA → `AdGroupCriterionService.MutateAdGroupCriteria` to update bids | `GoogleAdsService` + `AdGroupCriterionService` |
| Auto-pause ads below quality threshold | Hard | Poll `metrics.quality_score` via GAQL → `AdGroupAdService` to pause underperformers | `GoogleAdsService` + `AdGroupAdService` |
| Multi-account spend dashboard | Hard | Loop MCC child accounts → `GoogleAdsService.Search` per account → aggregate spend | `CustomerService` + `GoogleAdsService` |
| Bulk campaign duplication with budget scaling | Hard | Query existing campaigns → batch-mutate new campaigns at 2× budget | `GoogleAdsService` + `CampaignService` (batch) |
| Anomaly detection on daily spend | Hard | Pull `metrics.cost_micros` daily → compare to 7-day rolling average → alert if >30% deviation | `GoogleAdsService.SearchStream` |
| Dynamic keyword insertion from product feed | Hard | Read product catalog → generate ad groups + keywords + RSAs per product category | `AdGroupService` + `AdGroupCriterionService` + `AdGroupAdService` |

---

## Key Limits and Gotchas

### API Access Levels
- **Explorer**: Default. 2,880 ops/day (production), 15,000/day (test). Requires approval to upgrade.
- **Basic**: 15,000 ops/day both environments. Apply via developer token console.
- **Standard**: Higher quota — requires demonstrated usage and additional review.
- Operations = total of `Search`/`SearchStream` calls + mutate operations. Paginated continuation requests with valid `next_page_token` do NOT count against quota.

### Required Headers on Every Request
| Header | Description |
|--------|-------------|
| `Authorization: Bearer {token}` | OAuth 2.0 access token (expires after 1 hour) |
| `developer-token: {token}` | 22-character token from your API developer account |
| `login-customer-id: {id}` | Required when accessing a client account via a manager (MCC) account |

### Mutate Limits
- Max **10,000 operations per mutate request** — error: `TOO_MANY_MUTATE_OPERATIONS`
- Max **2,000 conversions per upload request**
- Planning services: max **1 QPS** per developer token
- Billing and Account Budget services: max **1 operation per mutate request**

### gRPC / Transport
- Primary protocol: **gRPC over HTTP/2** (protobuf); REST over HTTP/1.1 also supported
- Max response size: **64 MB** — use `SearchStream` or reduce selected fields to stay under
- Use `SearchStream` (streaming) for large reporting queries to avoid size limit errors
- Resource names are used as identifiers: e.g., `customers/1234567890/campaigns/987654321`
- Composite IDs for non-globally-unique objects: `{parent_id}~{child_id}` (e.g., `123~45678`)

### Campaign Types and API Limitations
- **Performance Max**: Uses Asset Groups (not Ad Groups); Google AI assembles ads — cannot opt out of specific networks
- **Video campaigns (legacy)**: Read-only via API for many write operations — use Google Ads UI for edits
- **AdvertisingChannelType** must be set correctly at campaign creation and cannot be changed after
- Setting the campaign `objective` is done via bidding strategy + conversion actions, not a single field (unlike the UI wizard)

### GAQL (Google Ads Query Language)
- SQL-like syntax: `SELECT ... FROM {resource} WHERE ... ORDER BY ... LIMIT ...`
- Segments (e.g., `segments.date`) split metrics per row — adding a segment multiplies result rows
- `LIMIT` is strongly recommended during development to avoid processing huge datasets
- Field compatibility must be checked — not all fields are `selectable_with` each other; use `GoogleAdsFieldService` to verify
- Filtering on metrics (e.g., `WHERE metrics.impressions > 1000`) is supported in `WHERE` clauses

### OAuth / Auth
- Access tokens expire after **1 hour** — use a refresh token flow; client libraries handle this automatically
- **Service account**: Best for server-to-server automation managing accounts you own
- **Multi-user OAuth**: Required when managing other users' accounts (SaaS / agency tool)
- Manager (MCC) accounts must set `login-customer-id` to the manager's customer ID on every request
- `CustomerService.ListAccessibleCustomers` returns all accounts reachable with current credentials (no `login-customer-id` needed for this call)

### Other Gotchas
- Budget amounts are in **micros** (1 USD = 1,000,000 micros) — divide by 1,000,000 for display
- A `CampaignBudget` can be shared across multiple campaigns
- Archived ad objects (up to 5,000) still queryable by ID; deleted objects not returned via parent edges
- Changes to creative, targeting, or bidding may trigger a new ad review cycle
- The Google Ads UI "Objective" selector is a setup wizard — the API exposes the raw fields; manually set `AdvertisingChannelType` + bidding strategy + conversion actions to match a UI objective
