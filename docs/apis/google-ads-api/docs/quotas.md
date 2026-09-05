# API Limits and Quotas
**Source:** https://developers.google.com/google-ads/api/docs/best-practices/quotas
**Date:** 2026-03-01

---

The Google Ads API enforces limits on API operations, such as the number of operations that can be sent in a single mutate request.

## Summary Table

| Request Type | Limitation | Error Code |
|-------------|------------|------------|
| Operations with Explorer Access level | 2,880 API operations per day against production accounts; 15,000 API operations per day against test accounts | `RESOURCE_EXHAUSTED` |
| Operations with Basic Access level | 15,000 API operations per day against both test and production accounts | `RESOURCE_EXHAUSTED` |
| Mutate requests | 10,000 operations per request | `TOO_MANY_MUTATE_OPERATIONS` |
| Planning Service requests | 1 QPS | `RESOURCE_EXHAUSTED` |
| Conversion Upload Service requests | 2,000 conversions per request | `TOO_MANY_CONVERSIONS_IN_REQUEST` |
| Billing and Account Budget Service requests | 1 operation per mutate request | `TOO_MANY_MUTATE_OPERATIONS` |

## Daily API Operation Limits

Daily API usage limits are based on the number of API operations made per developer token. API operations are the total sum of get requests and mutate operations. The limits for daily API operations depends on the access level of the developer token.

Requests that violate these limits are rejected with the error: `RESOURCE_EXHAUSTED`.

### Access Levels
- **Test**: Unlimited operations against test accounts (15,000/day for Explorer tier)
- **Explorer Access**: 2,880 operations/day against production accounts
- **Basic Access**: 15,000 operations/day against both environments
- **Standard Access**: Higher limits — see Access Levels and Permissible Use guide

## gRPC Limitations

All Google Ads API client libraries use gRPC for generating requests and responses. By default, gRPC has a message size of 4 MB, but client libraries set the max message size to **64 MB** to increase efficiency.

Responses must not exceed this limit. To avoid this limit:
- Reduce the number of selected fields in queries
- Use streaming (`SearchStream` instead of `Search`)
- For mutates, send fewer operations per request

Requests that violate this limitation will **not** generate a `GoogleAdsError`, but will generate a `429 Resource Exhausted` gRPC error.

## Mutate Requests

A mutate request cannot contain more than **10,000 operations** per request.

Requests that violate this limitation are rejected with the error: `TOO_MANY_MUTATE_OPERATIONS`.

## Search Requests

A `Search` or `SearchStream` request counts as **one operation** against the user's daily operation quota. One `SearchStream` request counts as one API operation irrespective of the number of batches.

## Paginated Requests

Paginated requests (requests that contain a valid `next_page_token`) are **not** counted against a user's daily operation quota. However, pagination requests that contain an expired or invalid page token will generate an exception and will count against the daily operation quota.

## Rate Limits

Note: Rate limits are enforced per developer token. If you exceed the rate limit, you will receive a `RESOURCE_EXHAUSTED` error. Implement exponential backoff when retrying rate-limited requests.

Key limits to know:
- Planning services: 1 QPS per token
- Avoid making single-operation requests — batch where possible
- Use sparse field masks to reduce response sizes

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
