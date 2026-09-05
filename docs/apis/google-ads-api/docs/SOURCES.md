# Google Ads API Documentation Sources
**Scraped:** 2026-03-01
**API Version:** v23

---

## Scraped Pages

| # | Requested URL | Final URL | Status | Saved As |
|---|---------------|-----------|--------|----------|
| 1 | https://developers.google.com/google-ads/api/docs/start | https://developers.google.com/google-ads/api/docs/get-started/introduction | Redirected — content saved | `introduction.md` |
| 2 | https://developers.google.com/google-ads/api/docs/concepts/overview | https://developers.google.com/google-ads/api/docs/concepts/overview | OK | `overview.md` |
| 3 | https://developers.google.com/google-ads/api/docs/concepts/call-structure | https://developers.google.com/google-ads/api/docs/concepts/call-structure | OK | `call-structure.md` |
| 4 | https://developers.google.com/google-ads/api/docs/concepts/api-access-configuration | — | **404 Not Found** | — |
| 5 | https://developers.google.com/google-ads/api/docs/oauth/overview | https://developers.google.com/google-ads/api/docs/oauth/overview | OK | `oauth-overview.md` |
| 6 | https://developers.google.com/google-ads/api/docs/concepts/campaign-structure | — | **404 Not Found** | — |
| 7 | https://developers.google.com/google-ads/api/docs/query/overview | https://developers.google.com/google-ads/api/docs/query/overview | OK | `query-overview.md` |
| 8 | https://developers.google.com/google-ads/api/docs/reporting/overview | https://developers.google.com/google-ads/api/docs/reporting/overview | OK | `reporting-overview.md` |
| 9 | https://developers.google.com/google-ads/api/docs/performance-max/overview | https://developers.google.com/google-ads/api/performance-max | Redirected — content saved | `performance-max-overview.md` |
| 10 | https://developers.google.com/google-ads/api/docs/campaigns/overview | https://developers.google.com/google-ads/api/docs/campaigns/overview | OK | `campaigns-overview.md` |
| 11 | https://developers.google.com/google-ads/api/docs/ad-groups/overview | — | **404 Not Found** | — |
| 12 | https://developers.google.com/google-ads/api/docs/ads/overview | https://developers.google.com/google-ads/api/docs/ads/overview | OK (minimal content — intro page only) | `ads-overview.md` |
| 13 | https://developers.google.com/google-ads/api/docs/targeting/overview | https://developers.google.com/google-ads/api/docs/targeting/overview | OK | `targeting-overview.md` |
| 14 | https://developers.google.com/google-ads/api/docs/best-practices/overview | https://developers.google.com/google-ads/api/docs/best-practices/overview | OK | `best-practices-overview.md` |
| 15 | https://developers.google.com/google-ads/api/docs/concepts/rate-limits | — | **404 Not Found** — content at `best-practices/quotas` instead | — |
| 16 | https://developers.google.com/google-ads/api/docs/concepts/quotas | — | **404 Not Found** — content at `best-practices/quotas` instead | — |
| 16b | https://developers.google.com/google-ads/api/docs/best-practices/quotas | https://developers.google.com/google-ads/api/docs/best-practices/quotas | OK — scraped as replacement for pages 15 & 16 | `quotas.md` |
| 17 | https://developers.google.com/google-ads/api/reference/rpc/latest | https://developers.google.com/google-ads/api/reference/rpc/v23/overview | Redirected — content saved | `rpc-reference.md` |

---

## Files Created

| File | Content | Source URL |
|------|---------|------------|
| `introduction.md` | Getting started introduction page | https://developers.google.com/google-ads/api/docs/get-started/introduction |
| `overview.md` | API concepts overview | https://developers.google.com/google-ads/api/docs/concepts/overview |
| `call-structure.md` | API call structure, headers, request/response | https://developers.google.com/google-ads/api/docs/concepts/call-structure |
| `oauth-overview.md` | OAuth 2.0 authentication overview | https://developers.google.com/google-ads/api/docs/oauth/overview |
| `query-overview.md` | Google Ads Query Language (GAQL) | https://developers.google.com/google-ads/api/docs/query/overview |
| `reporting-overview.md` | Reporting overview | https://developers.google.com/google-ads/api/docs/reporting/overview |
| `performance-max-overview.md` | Performance Max campaign overview | https://developers.google.com/google-ads/api/performance-max |
| `campaigns-overview.md` | Campaigns overview — types, budgets, bidding, targeting | https://developers.google.com/google-ads/api/docs/campaigns/overview |
| `ads-overview.md` | Ads overview | https://developers.google.com/google-ads/api/docs/ads/overview |
| `targeting-overview.md` | Targeting options overview | https://developers.google.com/google-ads/api/docs/targeting/overview |
| `best-practices-overview.md` | Best practices — batching, error handling, optimization | https://developers.google.com/google-ads/api/docs/best-practices/overview |
| `quotas.md` | API limits and quotas | https://developers.google.com/google-ads/api/docs/best-practices/quotas |
| `rpc-reference.md` | Complete v23 gRPC service and resource reference | https://developers.google.com/google-ads/api/reference/rpc/v23/overview |
| `SOURCES.md` | This file | — |

---

## Failed/Redirected Pages

### 404 Not Found
The following URLs returned 404 and could not be scraped. They may have been moved or never existed at the specified paths:

- `https://developers.google.com/google-ads/api/docs/concepts/api-access-configuration` — The correct page for API access configuration is likely at: `https://developers.google.com/google-ads/api/docs/oauth/service-accounts` or `https://developers.google.com/google-ads/api/docs/get-started/dev-token`
- `https://developers.google.com/google-ads/api/docs/concepts/campaign-structure` — The correct page for campaign structure is at: `https://developers.google.com/google-ads/api/docs/concepts/api-structure`
- `https://developers.google.com/google-ads/api/docs/ad-groups/overview` — No equivalent page found; ad group content is covered within the campaign and API structure docs
- `https://developers.google.com/google-ads/api/docs/concepts/rate-limits` — Correct URL is: `https://developers.google.com/google-ads/api/docs/best-practices/quotas`
- `https://developers.google.com/google-ads/api/docs/concepts/quotas` — Correct URL is: `https://developers.google.com/google-ads/api/docs/best-practices/quotas`

---

## Notes

- API version scraped: **v23** (current as of 2026-03-01)
- All content is licensed under Creative Commons Attribution 4.0 License
- Code samples are licensed under Apache 2.0 License
- The RPC reference page at `rpc/latest` auto-redirects to the current version (`v23`)
- Performance Max overview URL was restructured — old path `/docs/performance-max/overview` redirects to `/performance-max`
