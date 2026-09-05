---
source: https://developers.google.com/workspace/docs/api/limits
scraped: 2026-03-01
api: google-docs-api
---

# Google Docs API — Usage Limits

## Request Quotas

| Metric | Limit |
|--------|-------|
| Read requests per minute per project | 3,000 |
| Read requests per minute per user per project | 300 |
| Write requests per minute per project | 600 |
| Write requests per minute per user per project | 60 |

## Error Handling

When quotas are exceeded, the system returns a `429: Too many requests` HTTP status code.

Google recommends implementing exponential backoff algorithms to handle these errors.

## Exponential Backoff Implementation

The standard algorithm uses the formula: `min(((2^n)+random_number_milliseconds), maximum_backoff)`

Key parameters:
- **n**: Iteration counter (increments by 1 per retry)
- **random_number_milliseconds**: Random value <= 1,000ms (recalculated per retry)
- **maximum_backoff**: Typically 32 or 64 seconds

Retry sequence example: wait 1+random, then 2+random, then 4+random, continuing until reaching maximum backoff time.

## Pricing

All Google Docs API usage is provided **at no cost**. Exceeding quotas does not trigger additional charges.

## Quota Adjustment

Users may request quota increases via the Google Cloud console's Quotas page. Service account API calls count toward a single account's quota. Significant increases may require extended approval periods.
