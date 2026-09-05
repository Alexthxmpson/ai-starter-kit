---
source: https://developers.google.com/sheets/api/limits
scraped: 2026-03-01
api: google-sheets-api
---

# Google Sheets API Usage Limits

## Quota Limits

The Google Sheets API enforces per-minute quotas that refresh every 60 seconds:

### Read Requests
- **300 per minute per project**
- **60 per minute per user per project**

### Write Requests
- **300 per minute per project**
- **60 per minute per user per project**

When limits are exceeded, the system responds with `429: Too many requests` HTTP status code.

## Payload Recommendations

- Google recommends maintaining a **2 MB maximum payload** to optimize request speed and processing performance
- No strict hard size limit exists but staying under 2 MB is strongly advised

## Processing Timeouts

Requests exceeding **180 seconds** of processing time will trigger a timeout error and be rejected.

## Key Behaviors

- Batch requests — including all subrequests — count as a **single API request** toward usage limits
- All operations are **atomic**: any invalid request causes the entire update to fail
- **No daily request limits** provided per-minute quotas remain respected

## Error Handling for Quota Violations

HTTP 429 responses require **truncated exponential backoff**:

```
wait_time = min(((2^n) + random_number_milliseconds), maximum_backoff)
```

Where `maximum_backoff` typically ranges from 32 to 64 seconds.

## Pricing

**All Google Sheets API usage is free.** Exceeding quotas does NOT incur charges — requests are simply rejected until the quota resets.

## Additional Error Codes

| Code | Cause | Solution |
|---|---|---|
| 400 Bad Request | Malformed request syntax | Check API reference for proper formatting |
| 429 Too Many Requests | Quota exceeded | Implement exponential backoff |
| 500 Internal Server Error | API issue | File bug report on issue tracker |
| 503 Service Unavailable | Service down or request too complex | Use batchUpdate, limit concurrent requests to 1/sec per spreadsheet |

## 503 Performance Tips

- Use `batchUpdate` to combine related updates
- Restrict concurrent requests to 1 per second per spreadsheet
- Retrieve only necessary values using A1 notation
- Apply field masks to limit returned data
- Rotate frequently-updated sheets to new files periodically
- Reduce reliance on complex formulas like `IMPORTRANGE` and `QUERY`
- Split oversized spreadsheets into multiple files
