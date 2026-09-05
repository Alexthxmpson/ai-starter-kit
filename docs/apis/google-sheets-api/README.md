# Google Sheets API — Documentation

**Scraped:** 2026-03-01
**Source:** https://developers.google.com/sheets/api/
**API Version:** v4
**Auth:** OAuth 2.0
**Pricing:** Free (quota-based, no cost for exceeding)

---

## What's in This Folder

| Directory | Contents |
|---|---|
| `overview/` | Core concepts, usage limits, authentication/scopes |
| `reference/` | All REST endpoints, resources, enums, request/response schemas |
| `guides/` | How-to guides: reading/writing, formatting, pivot tables, charts, filters, metadata, etc. |
| `samples/` | Ready-to-run code examples (HTTP + Python) for all major operations |

---

## Key API Facts

- **Service Endpoint:** `https://sheets.googleapis.com`
- **Version:** v4 (v3 shut down August 2, 2021)
- **Quotas:** 300 requests/minute per project, 60 requests/minute per user
- **Payload Limit:** 2MB recommended
- **Timeout:** 180 seconds max per request
- **All usage is free** — quota exceeded = 429 error, not a bill

---

## Quick Reference: Most Used Methods

| Task | Method | HTTP |
|---|---|---|
| Read single range | `spreadsheets.values.get` | GET |
| Read multiple ranges | `spreadsheets.values.batchGet` | GET |
| Write single range | `spreadsheets.values.update` | PUT |
| Write multiple ranges | `spreadsheets.values.batchUpdate` | POST |
| Append rows | `spreadsheets.values.append` | POST |
| Clear a range | `spreadsheets.values.clear` | POST |
| Format cells, add sheets, charts, etc. | `spreadsheets.batchUpdate` | POST |
| Create a spreadsheet | `spreadsheets.create` | POST |
| Get spreadsheet metadata | `spreadsheets.get` | GET |
| Copy sheet to another spreadsheet | `spreadsheets.sheets.copyTo` | POST |

---

## ValueInputOption — Critical Parameter

When writing data, always specify:
- `RAW` — write exactly as-is (formulas stay as text)
- `USER_ENTERED` — parse like a human typing (dates become dates, formulas execute)

---

## Tracking Files

- `SOURCES.md` — All URLs scraped with status
- `COVERAGE.md` — Coverage by category
- `VALIDATION.md` — File count and content validation
