# Targeting
**Source:** https://developers.google.com/google-ads/api/docs/targeting/overview
**Date:** 2026-03-01

---

The Google Ads API supports several targeting options at the customer, campaign, and ad group levels. Depending on the criteria type, you can use the Google Ads API to:

- Target or exclude criteria at the campaign or ad group level.
- Set absolute bids for specific criteria at the ad group level.
- Modify bids for criteria at the campaign or ad group level.

## Targeting Levels

### Campaign-Level Targeting
Applied to all ad groups within a campaign. Managed through `CampaignCriterion` objects.

Common campaign-level targeting:
- **Locations** — Target or exclude geographic areas
- **Languages** — Target users by language
- **Devices** — Target by device type (DESKTOP, MOBILE, TABLET, CONNECTED_TV)
- **Ad Schedule** — Control when ads show
- **Audience Segments** — Broad audience targeting

### Ad Group-Level Targeting
More granular targeting applied per ad group. Managed through `AdGroupCriterion` objects.

Common ad group-level targeting:
- **Keywords** — For Search campaigns
- **Placements** — Specific websites for Display
- **Topics** — Category targeting for Display
- **User Interest** — Interest-based targeting
- **Custom Intent** — People actively researching topics
- **Similar Audiences** — Users similar to existing customers
- **Remarketing** — Past website/app visitors

## Criteria Types

Criteria are identified by a `criterion_type` and specific criterion sub-types:

| Criterion Type | API Enum Value | Use Case |
|----------------|---------------|----------|
| Keyword | `KEYWORD` | Search network keyword matching |
| Location | `LOCATION` | Geographic targeting |
| Age Range | `AGE_RANGE` | Demographic targeting |
| Gender | `GENDER` | Demographic targeting |
| Device | `DEVICE` | Device type targeting |
| User List | `USER_LIST` | Custom audience/remarketing |
| User Interest | `USER_INTEREST` | Interest category targeting |
| Placement | `PLACEMENT` | Specific website/app placement |
| Topic | `TOPIC` | Content category targeting |
| Ad Schedule | `AD_SCHEDULE` | Time-based targeting |
| Income Range | `INCOME_RANGE` | Household income targeting |
| IP Block | `IP_BLOCK` | Exclusion of specific IPs |
| Content Label | `CONTENT_LABEL` | Content safety exclusions |

## Bid Modifiers

Bid modifiers allow you to increase or decrease bids for specific criteria, without excluding them entirely. Modifiers are percentage adjustments (e.g., 1.5 = +50%, 0.8 = -20%).

Example use cases:
- Increase bids by 25% for mobile devices
- Reduce bids by 30% for users outside your main location
- Increase bids by 50% during peak hours

## What's Next

- Learn more about Criteria: `/google-ads/api/docs/targeting/criteria`
- Read about Bid Modifiers: `/google-ads/api/docs/targeting/bid-modifiers`

**Next:** Criteria

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
