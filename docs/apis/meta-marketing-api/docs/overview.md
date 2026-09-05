# Overview - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/overview
**Date:** 2026-03-01

---

## Overview

The Marketing API is a Meta business tool designed to empower developers and marketers with the ability to automate advertising efforts across Meta technologies. It offers a comprehensive suite of functionalities that streamline the processes of ad creation, management, and performance analysis.

One of the primary features of the Marketing API is its ability to facilitate the automated creation of ads. You can programmatically generate ad campaigns, ad sets, and individual ads, allowing for rapid deployment and iteration based on real-time performance data. This automation also enables businesses to reach larger audiences with greater efficiency.

In addition to ad creation, you can:

- Update, pause, or delete ads seamlessly
- Ensure that campaigns remain aligned with business objectives
- Access detailed insights and analytics to track ad performance and make data-driven decisions to improve outcomes

## How it Works

### Ad campaigns

A campaign is the highest level organizational structure within an ad account and should represent a single objective, for example, to drive Page post engagement. Setting the objective of the campaign enforces validation on any ads added to that campaign to ensure they also have the correct objective.

### Ad sets

Ad sets are groups of ads and are used to configure the budget and period the ads should run for. All ads contained within an ad set should have the same targeting, budget, billing, optimization goal, and duration.

Create an ad set for each target audience with your bid; ads in the set target the same audience with the same bid. This helps control the amount you spend on each audience, determine when the audience will see your ads, and provides metrics for each audience.

### Ad creatives

Ad creatives contain just the visual elements of the ad and you can't change them once they're created. Each ad account has a creative library to store creatives for reuse in ads.

### Ads

An ad object contains all of the information necessary to display an ad on Facebook, Instagram, Messenger, and WhatsApp, including the ad creative. Create multiple ads in each ad set to optimize ad delivery based on different images, links, video, text, or placements.

### Ad Components

This table shows how the various ad components align to the different levels of ad creation.

| Component | Ad Campaign | Ad Set | Ad |
|-----------|------------|--------|----|
| **Objective** | ✓ | | |
| **Schedule** | | ✓ | |
| **Budget** | | ✓ | |
| **Bidding** | | ✓ | |
| **Audience** | | ✓ | |
| **Ad Creative** | | | ✓ |

## Related Topics

- Versioning: `/docs/marketing-api/overview/versioning`
- Rate Limiting: `/docs/marketing-api/overview/rate-limiting`
- Data Processing Options: `/docs/marketing-api/overview/data-processing-options`
