# Ads
**Source:** https://developers.google.com/google-ads/api/docs/ads/overview
**Date:** 2026-03-01

---

A Google Ads Ad is the resource that represents an actual ad being served on one of the Google networks.

This guide provides an overview of the various ad types and features available in the API.

## Ad Types

The following ad types are supported in the Google Ads API (see `/google-ads/api/docs/ads/ad-types` for full detail):

- **Expanded Text Ads** (legacy, still readable but no longer creatable)
- **Responsive Search Ads (RSA)** — Provide multiple headlines and descriptions; Google auto-assembles combinations
- **Responsive Display Ads** — For the Display Network; auto-assembled from headlines, descriptions, images, logos
- **Call Ads** — Click-to-call ads; appear on mobile
- **App Ads** — Promote apps across Google networks
- **Smart Ads** (DSA) — Dynamic Search Ads; auto-generate headlines from website content
- **Hotel Ads** — For hotels/travel; shown on Google Hotel Search
- **Local Ads** — For local businesses
- **Video Ads** — For YouTube and Display Network
- **Image Ads** — Static or animated image ads for Display Network

## Key API Resource

The `Ad` resource lives at: `google-ads/api/reference/rpc/v23/Ad`

Ads are always associated with an `AdGroup` via an `AdGroupAd` resource:

```
Customer
  └── Campaign
        └── AdGroup
              └── AdGroupAd → Ad
```

## Ad Status

Ads have an `AdGroupAd.status` (not `Ad.status`). Valid values:
- `ENABLED`
- `PAUSED`
- `REMOVED`

## Creating Ads

Ads are created through `AdGroupAdService.mutateAdGroupAds`. You cannot create ads independently — they must be attached to an ad group.

**Next:** Ad types

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
