# Best Practices
**Source:** https://developers.google.com/google-ads/api/docs/best-practices/overview
**Date:** 2026-03-01

---

This guide covers some best practices you can implement to optimize the efficiency and performance of your apps.

## Ongoing Maintenance

To ensure that your app runs uninterrupted:

1. **Keep your developer contact email in the API center up to date.** This is the alias Google uses to contact you. If they're unable to contact you regarding compliance with the API Terms and Conditions, your API access may be revoked without your prior knowledge. Avoid using a personal email address tied to an individual or unmonitored account.

2. **Subscribe to the API blog and Product blog** to be informed of issues such as product changes, maintenance downtime, deprecation dates, and so on.
   - API blog: https://ads-developers.googleblog.com/search/label/google_ads_api
   - Product blog: https://blog.google/products/ads-commerce/

3. **Keep your app compliant with the Google Ads API Terms and Conditions (T&C).** If required, the token review and compliance team will reach out using your contact email.

## Optimization

### Batch Operations

Making a request to the API entails a number of fixed costs (round-trip network latency, serialization/deserialization, back-end calls). To lessen the impact of these fixed costs and increase overall performance, most mutate methods in the API are designed to accept an array of operations.

**Avoid making requests with only one operation.** For example, suppose you're adding 50,000 keywords to a campaign across multiple ad groups. Instead of making 50,000 requests with 1 keyword each, make 100 requests with 500 keywords each, or even 10 requests with 5,000 keywords each. There are limits on the number of operations allowed in a request, so you may need to adjust your batch size.

### Send Sparse Objects

The Google Ads API supports sparse updates, allowing you to populate only the fields in an object that you need to change or that are required. Sparse updates process faster and are less likely to produce errors.

Fields that aren't in the `update_mask` (also known as `FieldMask`) are left unchanged.

**Example:** An app that updates keyword-level bids can benefit from using sparse updates, as only the ad group ID, criterion ID, and bids fields would need to be populated.

## Error Handling and Management

### Distinguish Request Sources

- **User-initiated requests**: Provide a good UX. Use the specific error that occurred to provide as much context as possible. Offer easy steps users can take to resolve the error.
- **Back-end requests**: Implement handlers for different types of errors. Always include a default handler. A good approach for a default handler is to add the failed operation and error to a queue for a human operator to review.

### Distinguish Error Types

Common error types to handle:
- **Authentication errors** — Token expired, invalid credentials
- **Retryable errors** — Transient server errors; implement exponential backoff
- **Validation errors** — Invalid field values, constraint violations
- **Sync-related errors** — Local database out of sync with API state

Refer to Error Types and Common Errors documentation for more details.

### Sync Back Ends

If your app's users have manual access to Google Ads accounts, they may make changes that your app is not aware of, causing your app's local database to go out of sync. Proactive strategy: run a nightly sync job on all your accounts, retrieving the Google Ads objects and comparing against your local database.

### Log Errors

All errors should be logged to facilitate debugging and monitoring. At a minimum, log:
- The request ID
- The operations that caused the error
- The error itself

Other information to log: customer ID, API service, round-trip request latency, number of retries, and the raw request and response.

### Monitor Trends

Monitor trends in API errors so that you can detect and address problems with your app. Consider building your own solution or using commercial tools that can produce interactive dashboards and send automated alerts.

## Development

### Use Test Accounts

Test accounts are Google Ads accounts that don't actually serve ads. You can use a test account to experiment with the Google Ads API and test that your app's connectivity, campaign management logic, or other processing are working as expected.

Your developer token does not need to be approved to be used on a test account, so you can start developing with the Google Ads API immediately after requesting a developer token, even before your app is reviewed.

**Next:** API limits and quotas

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
