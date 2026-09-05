---
source: https://developers.google.com/sheets/api/guides/performance
scraped: 2026-03-01
api: google-sheets-api
---

# Performance Optimization — Google Sheets API

## 1. Use Gzip Compression

Enable gzip compression to reduce bandwidth requirements. Decompression requires additional CPU processing, but the network cost savings typically justify the trade-off.

### Implementation

Set these headers on every request:

```
Accept-Encoding: gzip
User-Agent: my program (gzip)
```

Both headers are required — the user agent string must contain the word `gzip`.

## 2. Use Partial Resources (Fields Parameter)

Rather than retrieving complete resource representations, request only needed fields using the `fields` parameter. This conserves:
- Network bandwidth
- CPU cycles
- Memory resources

### Syntax

| Syntax | Description |
|---|---|
| `fields=kind,items` | Request specific top-level fields |
| `fields=a/b` | Nested field notation |
| `fields=items(title)` | Sub-selections on arrays/objects |
| `fields=items/pagemap/*` | Wildcard for all sub-fields |

### Example

A request like:
```http
GET https://sheets.googleapis.com/v4/spreadsheets/SPREADSHEET_ID?fields=kind,items(title,characteristics/length)
```

Returns only specified nested data rather than the complete resource structure.

**Server responses:**
- HTTP 200 OK — valid field request
- HTTP 400 Bad Request — invalid field selection

## 3. Batch Requests

Use batch methods instead of making individual calls:

| Instead of | Use |
|---|---|
| Multiple `values.get` calls | `values.batchGet` |
| Multiple `values.update` calls | `values.batchUpdate` |
| Multiple `batchUpdate` calls | Single `batchUpdate` with multiple requests |

Note: Batch requests count as a single API request toward your quota.

## 4. Limit Data Retrieved

- Use A1 notation to restrict ranges to only what you need
- Avoid `includeGridData: true` unless absolutely necessary
- Use `spreadsheets.values.get` instead of `spreadsheets.get` for large spreadsheets with lots of formatting

## 5. Concurrent Request Limits

- Restrict concurrent requests to **1 per second per spreadsheet**
- Avoid hammering a single spreadsheet from multiple workers simultaneously

## 6. Spreadsheet Design for Performance

- Rotate frequently-updated sheets to new files periodically
- Reduce reliance on complex formulas like `IMPORTRANGE` and `QUERY`
- Split oversized spreadsheets into multiple files
- Avoid using a single sheet as a source for numerous `IMPORTRANGE` formulas
- Restrict access to essential users only

## 7. Pagination

Combine pagination parameters with partial response requests:
- Use `maxResults` to limit query results
- Use `nextPageToken` for pagination
