# Conversions API

**Source:** https://developers.facebook.com/docs/marketing-api/conversions-api
**Date:** 2026-03-01

---

## Overview

The Conversions API is designed to create a connection between an advertiser's marketing data (such as website events, app events, business messaging events, and offline conversions) from an advertiser's server, website platform, mobile app, or CRM to Meta systems that optimize ad targeting, decrease cost per result, and measure outcomes.

Rather than maintaining separate connection points for each data source, advertisers can leverage the Conversions API to send multiple event types and simplify their technology stack.

Server events are linked to a **dataset ID** and are processed like events sent using:
- Meta Pixel
- Facebook SDK for iOS or Android
- Mobile measurement partner SDK
- Offline event set
- .csv upload

---

## Endpoint

```
POST https://graph.facebook.com/v25.0/<DATASET_ID>/events
```

Parameters are sent in the POST body with your access token.

---

## Recommended Steps

1. **[Get Started](https://developers.facebook.com/docs/marketing-api/conversions-api/get-started)** — Choose the integration method, see prerequisites, and understand where to begin.
2. **[Implement the API](https://developers.facebook.com/docs/marketing-api/conversions-api/using-the-api)** — Start making `POST` requests. Learn about dropped events, batch requests, and event transaction time.
3. **[Verify your setup](https://developers.facebook.com/docs/marketing-api/conversions-api/verifying-setup)** — Confirm events are received, deduplicated, and matched correctly.

---

## Documentation

| Section | Description |
|---------|-------------|
| [Get Started](https://developers.facebook.com/docs/marketing-api/conversions-api/get-started) | Integration methods and prerequisites |
| [Using the API](https://developers.facebook.com/docs/marketing-api/conversions-api/using-the-api) | Making POST requests, batch requests, dropped events |
| [Verifying Setup](https://developers.facebook.com/docs/marketing-api/conversions-api/verifying-setup) | Confirm events are received and deduplicated |
| [Parameters](https://developers.facebook.com/docs/marketing-api/conversions-api/parameters) | Required and optional parameters for attribution and optimization |
| [Parameter Builder Library](https://developers.facebook.com/docs/marketing-api/conversions-api/parameter-builder-feature-library) | Helper library for building parameters |
| [Conversions API for App Events](https://developers.facebook.com/docs/marketing-api/conversions-api/app-events) | Sending app events via Conversions API |
| [Conversions API for Offline Events](https://developers.facebook.com/docs/marketing-api/conversions-api/offline-events) | Offline event sets and measurement |
| [Conversions API for Business Messaging](https://developers.facebook.com/docs/marketing-api/conversions-api/business-messaging) | Messaging events integration |
| [Conversion Leads Integration](https://developers.facebook.com/docs/marketing-api/conversions-api/conversion-leads-integration) | Lead conversion tracking |
| [Dataset Quality API](https://developers.facebook.com/docs/marketing-api/conversions-api/dataset-quality-api) | Monitor quality of your event data |
| [Handling Duplicate Events](https://developers.facebook.com/docs/marketing-api/conversions-api/deduplicate-pixel-and-server-events) | Deduplicating Pixel and server events |
| [Guides](https://developers.facebook.com/docs/marketing-api/conversions-api/guides) | Integration guides |
| [Payload Helper](https://developers.facebook.com/docs/marketing-api/conversions-api/payload-helper) | Visual tool to structure your payload |
| [Best Practices](https://developers.facebook.com/docs/marketing-api/conversions-api/best-practices) | Recommendations for optimal performance |
| [Troubleshooting](https://developers.facebook.com/docs/marketing-api/conversions-api/support) | Error codes and support |

---

## Resources

| Resource | Description |
|----------|-------------|
| [Meta Pixel Standard Events](https://developers.facebook.com/docs/facebook-pixel/implementation/conversion-tracking#standard-events) | Standard event types compatible with Conversions API |
| [Meta Pixel Custom Events](https://developers.facebook.com/docs/facebook-pixel/implementation/conversion-tracking#custom-events) | Custom event types |
| [About Conversions API (Help Center)](https://www.facebook.com/business/help/2041148702652965) | Business Help Center overview |
| [Test Your Server Events](https://www.facebook.com/business/help/1624255387706033) | How to test event delivery |
| [Direct Integration Playbook (PDF)](https://www.facebook.com/gms_hub/share/conversions-api-direct-integration-playbook_english.pdf) | Developer playbook for direct integration |
| [Data Processing Options](https://developers.facebook.com/docs/marketing-apis/data-processing-options) | Limited Data Use (LDU) feature implementation |

---

## Key Concepts

### Event Deduplication

When using both the Meta Pixel and Conversions API, events may be sent from both the browser and server. Use the `event_id` parameter to deduplicate events across Pixel and server to avoid double-counting.

### Dataset ID

Each Conversions API integration is tied to a dataset ID (previously called "pixel ID"). Find it in the Events Manager in Meta Business Manager.

### Event Match Quality

Meta scores how well your events match to Meta accounts. Higher match quality = better attribution and optimization. Send as many user data parameters as possible (email, phone, external ID, etc.) — all hashed with SHA-256.

### Use Cases

| Use Case | Event Source |
|----------|-------------|
| Website purchase events | Server-side (avoids ad blocker/cookie loss) |
| App install and in-app purchase | Conversions API for App Events |
| CRM lead submission | Offline events / Conversion Leads |
| WhatsApp/Messenger conversions | Business Messaging events |
