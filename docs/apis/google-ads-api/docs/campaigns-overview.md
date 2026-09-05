# Campaigns
**Source:** https://developers.google.com/google-ads/api/docs/campaigns/overview
**Date:** 2026-03-01

---

A Google Ads campaign is a set of one or more ad groups (ads, keywords, and bids) that share a budget, location targeting, and other settings. Campaigns are typically used to organize categories of products or services offered by an advertiser. Campaigns are the top-level organizational tool within your Google Ads account.

Items that can be set at the campaign level include bids, budget, language, location, distribution for the Google Network, and more. Large advertisers typically create separate ad campaigns to run ads in different locations or using different budgets.

While we recommend using client libraries, you can also modify campaigns with the REST endpoint at `CampaignService.MutateCampaigns`.

## Campaign Types

In Google Ads, think of these concepts in a hierarchy:

- **Campaign Type**: Your primary choice. The blueprint for your entire campaign.
- **Advertising Networks**: The places where your ads can run, largely determined by your Campaign Type.
- **Network/Channel Controls**: The specific settings you can use to fine-tune where your ads appear within those networks.

### Start with the Campaign Type (the "what" and "how")

The Campaign Type is the foundation of your advertising efforts. It dictates:
- What kind of ads you can create (text ads, image banners, video ads)
- What features and bidding strategies are available

Examples of Campaign Types include **Search, Display, Performance Max**, and **Demand Gen**.

Each campaign targets one campaign type, known in the API as the `AdvertisingChannelType` field on the `Campaign` object.

The API supports the following campaign types:
- Display Network only
- Search Network only
- Display Expansion on Search
- App campaigns
- Call-only
- Demand Gen
- Performance Max
- Shopping campaigns
- Local Services

### Understand the Networks (the "where")

The main advertising networks are:
- **Google Search Network**: Google Search, Google Maps, and Search Partner sites.
- **Google Display Network**: Millions of third-party websites, news sites, blogs, and Google properties like Gmail and YouTube.
- **YouTube Network**: YouTube itself, including the home feed, search results, videos, and shorts.

### Control Placements

| Example Campaign Type | How You Control Where Ads Show | Explanation |
|-----------------------|-------------------------------|-------------|
| Search | Uses `NetworkSettings` | You can use the `NetworkSettings` field to explicitly include or exclude the Google Search Partners and the Google Display Network. |
| Performance Max (PMax) | No Manual Control | PMax automatically serves your ads across **all** of Google's networks to find conversions. You cannot opt out of specific networks. |
| Demand Gen | Uses "Channel Controls" | More specific "channel" controls that let you opt in or out of specific parts of networks. |

### AdvertisingChannelType vs AdvertisingChannelSubType

| If you want to create this campaign... | Set AdvertisingChannelType to... | And set AdvertisingChannelSubType to... |
|---------------------------------------|-----------------------------------|-----------------------------------------|
| A Standard Search Campaign | SEARCH | (Do not set / Leave empty) |
| A Standard Display Campaign | DISPLAY | (Do not set / Leave empty) |
| A Standard Performance Max Campaign | PERFORMANCE_MAX | (Do not set / Leave empty) |
| A Performance Max for Travel Goals Campaign | PERFORMANCE_MAX | TRAVEL_GOALS |
| A Demand Gen Campaign | DEMAND_GEN | (Do not set / Leave empty) |

## Campaign Budget, Bidding Strategies, and Targeting

Managing a campaign means answering three fundamental questions:

### 1. How much can I spend? (Campaign Budget)

Create a separate `CampaignBudget` object with a daily spending limit (in micros) and then attach its resource name to your campaign. A single budget can be shared across multiple campaigns.

### 2. How should Google spend my money? (Bidding Strategy)

Choose a bidding strategy based on what you want to achieve:
- For traffic: Use `MaximizeClicks`.
- For leads/sign-ups: Use `MaximizeConversions` with a `TargetCpa`.
- For ecommerce sales: Use `MaximizeConversionValue` with a `TargetRoas`.

### 3. Who should see my ads? (Target Audience)

Add `CampaignCriterion` or `AdGroupCriterion` objects to narrow your reach. Targeting can be based on:
- **Keywords**: What users are searching for.
- **Locations**: Where users are located.
- **Demographics**: Their age, gender, etc.
- **Audiences**: Their past behavior (website visitors) or interests.

## Google Ads API Campaign Structures

| Structure | Example Use (AdvertisingChannelType) | How it Works | Key Concept |
|-----------|--------------------------------------|--------------|-------------|
| Ad Group Structure | `SEARCH`, Standard `DISPLAY` | The campaign is organized into Ad Groups. Each Ad Group contains a set of finished ads and a set of targeting criteria (keywords, audiences). | The link between manually created ads and their targeting is tightly controlled within the Ad Group. |
| Asset Group Structure | `PERFORMANCE_MAX` | Instead of Ad Groups, you create Asset Groups. Each Asset Group contains a pool of raw creative assets (headlines, images, etc.) and audience signals. | You provide the creative components, and Google's AI assembles the final ads in real-time to optimize them across different channels. |
| Hybrid Structure | `DEMAND_GEN`, `DISPLAY` | Standard Ad Group structure with modern Assets (formerly extensions like Sitelinks or Callouts) linked at the campaign or ad group level. | The core ad is manually created, but you provide extra, interchangeable assets for Google to show alongside it to enhance performance. |

## Differences from the Google Ads UI

- The Google Ads API has limitations for managing legacy and video campaigns.
- For video campaigns, you can use the Google Ads API to **read data** (pull performance reports). For some specific video campaign types, you **cannot write changes** with the API — use the Google Ads web interface instead.
- **Best Practice**: To fully create and manage video ads on YouTube using the API, use Performance Max or Demand Gen campaigns. These are fully supported for both reporting and management.

The Google Ads UI "Objective" ("Sales", "Leads") is a setup wizard. The API gives you the raw building blocks — you achieve your objective by assembling the right settings yourself:

```
# Example: Creating a "Sales" campaign
advertising_channel_type = "SEARCH" or "PERFORMANCE_MAX"
campaign_bidding_strategy = MaximizeConversionValue with target_roas
conversion_actions = [your "Purchase" conversion action]
```

**Next:** Create campaigns

---
*Last updated 2026-02-26 UTC. Content licensed under Creative Commons Attribution 4.0 License.*
