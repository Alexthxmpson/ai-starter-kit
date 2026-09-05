# Sources - Meta Marketing API Documentation

**Scraped:** 2026-03-01
**API Version:** v25.0
**Base URL:** https://graph.facebook.com/v25.0

---

## Scraped Pages

| # | Filename | Source URL | Notes |
|---|----------|------------|-------|
| 1 | `overview.md` | https://developers.facebook.com/docs/marketing-api/overview | |
| 2 | `get-started.md` | https://developers.facebook.com/docs/marketing-api/get-started | |
| 3 | `basic-ad-creation.md` | https://developers.facebook.com/docs/marketing-api/get-started/basic-ad-creation | |
| 4 | `manage-campaigns.md` | https://developers.facebook.com/docs/marketing-api/get-started/manage-campaigns | |
| 5 | `ad-creative.md` | https://developers.facebook.com/docs/marketing-api/creative | |
| 6 | `audiences.md` | https://developers.facebook.com/docs/marketing-api/audiences | |
| 7 | `insights.md` | https://developers.facebook.com/docs/marketing-api/insights | |
| 8 | `bidding.md` | https://developers.facebook.com/docs/marketing-api/bidding | |
| 9 | `api-reference.md` | https://developers.facebook.com/docs/marketing-api/reference | |
| 10 | `campaigns.md` | https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group | Large page — extracted via Python chunking |
| 11 | `ad-sets.md` | https://developers.facebook.com/docs/marketing-api/reference/ad-campaign | Large page — extracted via Python chunking |
| 12 | `ads.md` | https://developers.facebook.com/docs/marketing-api/reference/adgroup | Large page — extracted via Python chunking |
| 13 | `ad-creatives-ref.md` | https://developers.facebook.com/docs/marketing-api/reference/ad-creative | Large page — extracted via Python chunking; contained Unicode special chars (★) |
| 14 | `access-and-auth.md` | https://developers.facebook.com/docs/marketing-api/access | Redirected to https://developers.facebook.com/docs/marketing-api/get-started/authorization |
| 15 | `best-practices.md` | https://developers.facebook.com/docs/marketing-api/best-practices | |
| 16 | `pages-api.md` | https://developers.facebook.com/docs/pages-api | Overview/index page only (not a Marketing API subpage) |
| 17 | `conversions-api.md` | https://developers.facebook.com/docs/marketing-api/conversions-api | Overview/index page only |
| 18 | `troubleshooting.md` | https://developers.facebook.com/docs/marketing-api/troubleshooting | |

---

## Skipped Pages

None. All 18 requested pages were successfully scraped.

---

## Notes

- **Cookie consent:** Handled on first page load by clicking "Allow all cookies". Subsequent pages loaded without prompts.
- **Large reference pages (10–13):** Pages for campaigns, ad-sets, ads, and ad-creatives reference exceeded snapshot token limits. Content was extracted using Python by parsing the JSON snapshot and reading in 15–20K character chunks using offset slicing.
- **Unicode encoding:** The ad-creatives-ref page contained special characters (e.g., `★` U+2605). Fixed by using `sys.stdout.reconfigure(encoding='utf-8')` in the Python extraction script.
- **Pages API (page 16):** This is a top-level index page for the Facebook Pages API (not a Marketing API subpage). The overview content and documentation contents table were captured.
- **Conversions API (page 17):** This is the top-level overview page for the Conversions API. The full index, recommended steps, documentation table, and resources were captured.
- **Access/Auth redirect (page 14):** The URL `https://developers.facebook.com/docs/marketing-api/access` redirected to the authorization guide at `https://developers.facebook.com/docs/marketing-api/get-started/authorization`.
