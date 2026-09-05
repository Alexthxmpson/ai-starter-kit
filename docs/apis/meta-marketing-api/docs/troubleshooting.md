# Troubleshooting - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/troubleshooting
**Date:** 2026-03-01

---

## Overview

Working with the Marketing API can occasionally present challenges. Below are issues users may encounter, along with practical solutions to help streamline your experience.

---

## Error Handling

Use the error handling techniques and best practices below to enhance the reliability and efficiency of your applications.

### Authorization Errors

These errors often occur due to [access tokens](https://developers.facebook.com/docs/facebook-login/guides/access-tokens) that are expired, invalid, or lacking the necessary permissions. To mitigate these issues, ensure that tokens are refreshed regularly and that the correct scopes are requested during authorization.

**Common error codes:**

| Code | Description |
|------|-------------|
| 190 | Invalid OAuth 2.0 Access Token |
| 200 | Permissions error |
| 104 | Incorrect signature |
| 270 | App not authorized for Ads API |

### Invalid Parameters

Sending requests with incorrect or missing parameters can lead to [errors](https://developers.facebook.com/docs/marketing-api/error-reference). Always validate the input data before making API calls. Utilizing validation tools can significantly reduce such errors.

**Common error codes:**

| Code | Description |
|------|-------------|
| 100 | Invalid parameter |
| 2500 | Error parsing graph query |
| 3018 | Start date cannot be beyond 37 months from current date |

### Resource Not Found

This error occurs when attempting to access a resource that does not exist or has been deleted. To resolve this, check that resources (like campaigns or ad sets) exist before performing operations on them.

### Rate Limiting

The Marketing API enforces [rate limits](https://developers.facebook.com/docs/marketing-apis/rate-limiting) to prevent abuse. Exceeding these limits results in error messages indicating that too many requests have been made in a short time.

**Common error codes:**

| Code | Description |
|------|-------------|
| 613 | Rate limit exceeded. Calls to this API have exceeded the rate limit. |
| 80004 | Too many calls to this ad-account. Wait and retry. |

**Recommended approach:** Employ exponential backoff strategies to slow down request rates after hitting the limit.

To optimize performance and avoid hitting rate limits, create a queue system for API requests. This allows for controlled pacing of requests, ensuring compliance with the API's limits without sacrificing performance.

### Caching Strategies

Implement caching for frequently accessed data, such as audience insights or ad performance metrics. This reduces the number of API calls and speeds up data retrieval, leading to a more efficient application.

### Managing API Versioning

Stay informed about [updates and changes](https://developers.facebook.com/docs/marketing-api/marketing-api-changelog) in the Marketing API by regularly checking the documentation. Placing API calls within version-specific functions can prepare your application for version changes, allowing for independent updates.

**Common error codes:**

| Code | Description |
|------|-------------|
| 2635 | Deprecated version of the Ads API. Update to latest. |

### Error Logging and Monitoring

Implement robust error logging to track API interactions. This will help identify patterns in errors and facilitate quicker resolutions. Utilizing monitoring tools can alert developers to critical failures or unusual patterns in API usage.

### Transient Issues

Errors will sometimes indicate that the issue is transient (i.e., `"is_transient": true`). This indicates it might recover or be fixed soon, so it's best to wait and retry later.

---

## Common Error Reference

| Error Code | Description | Resolution |
|------------|-------------|------------|
| 100 | Invalid parameter | Check required fields and data types |
| 104 | Incorrect signature | Verify access token and app secret |
| 190 | Invalid OAuth 2.0 Access Token | Refresh or regenerate the access token |
| 200 | Permissions error | Request correct permissions (`ads_management`, `ads_read`) |
| 270 | App not authorized for Ads API | Upgrade from development access via App Review |
| 613 | Rate limit exceeded | Implement backoff; reduce call frequency |
| 2500 | Error parsing graph query | Check query syntax and field names |
| 2635 | Deprecated API version | Update to the latest API version (`v25.0`) |
| 3018 | Start date out of range | Start date cannot be beyond 37 months from today |
| 80004 | Too many calls to ad account | Wait and retry with backoff |

---

## Related Resources

- [Error Reference](https://developers.facebook.com/docs/marketing-api/error-reference)
- [Rate Limiting](https://developers.facebook.com/docs/marketing-apis/rate-limiting)
- [Access Tokens](https://developers.facebook.com/docs/facebook-login/guides/access-tokens)
- [Graph API Changelog](https://developers.facebook.com/docs/marketing-api/marketing-api-changelog)
- [Graph API Explorer](https://developers.facebook.com/tools/explorer) — Test API calls interactively
