# API Reference - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/reference
**Date:** 2026-03-01

---

## Marketing API Reference

### Marketing API Root Nodes

This is a full list of root nodes for the Facebook Marketing API with links to reference docs for each. For background on the API's architecture how to call root nodes and their edges, see [Using the Graph API](https://developers.facebook.com/docs/graph-api/using-graph-api).

**Base URL:** `https://graph.facebook.com/v25.0`

| Node | Description |
|------|-------------|
| [`/{AD_ACCOUNT_USER_ID}`](https://developers.facebook.com/docs/marketing-api/reference/ad-account-user) | Someone on Facebook who creates ads. Each ad user can have a role on several ad accounts. |
| [`/act_{AD_ACCOUNT_ID}`](https://developers.facebook.com/docs/marketing-api/reference/ad-account) | Represents the business entity managing ads. |
| [`/{AD_ID}`](https://developers.facebook.com/docs/marketing-api/reference/adgroup) | Contains information for an ad, such as creative elements and measurement information. |
| [`/{AD_CREATIVE_ID}`](https://developers.facebook.com/docs/marketing-api/reference/ad-creative) | Format for your image, carousel, collection, or video ad. |
| [`/{AD_SET_ID}`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign) | Contains all ads that share the same budget, schedule, bid, and targeting. |
| [`/{AD_CAMPAIGN_ID}`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group) | Defines your ad campaigns' objective. Contains one or more ad set. |

---

## User

### Edges

| Edge | Description |
|------|-------------|
| [`/adaccounts`](https://developers.facebook.com/docs/graph-api/reference/user/adaccounts) | All ad accounts associated with this person |
| [`/accounts`](https://developers.facebook.com/docs/graph-api/reference/user/accounts/) | All pages and places that someone is an admin of |
| [`/promotable_events`](https://developers.facebook.com/docs/graph-api/reference/user/promotable_events/) | All promotable events you created or promotable page events that belong to pages you are an admin for |

---

## Ad Account

All collections of ad objects in Marketing APIs belong to an ad account.

### Edges

| Edge | Description |
|------|-------------|
| [`/adcreatives`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/adcreatives/) | Defines your ad's appearance and content |
| [`/adimages`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/adimages/) | Library of images to use in ad creatives. Can be uploaded and managed independently |
| [`/ads`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/ads/) | Data for an ad, such as creative elements and measurement information |
| [`/adsets`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/adsets/) | Contain all ads that share the same budget, schedule, bid, and targeting |
| [`/advideos`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/advideos/) | Library of videos for use in ad creatives. Can be uploaded and managed independently |
| [`/campaigns`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/campaigns/) | Define your campaigns' objective and contain one or more ad sets |
| [`/customaudiences`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/customaudiences) | The custom audiences owned by/shared with this ad account |
| [`/insights`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/insights/) | Interface for insights. De-dupes results across child objects, provides sorting, and async reports. |
| [`/users`](https://developers.facebook.com/docs/marketing-api/reference/ad-account/users/) | List of people assocated with an ad account |

---

## Ad

An individual ad associated with an ad set.

### Edges

| Edge | Description |
|------|-------------|
| [`/adcreatives`](https://developers.facebook.com/docs/marketing-api/reference/adgroup/adcreatives/) | Defines your ad's appearance and content |
| [`/insights`](https://developers.facebook.com/docs/marketing-api/reference/adgroup/insights/) | Insights on your advertising performance. |
| [`/leads`](https://developers.facebook.com/docs/marketing-api/reference/adgroup/leads/) | Any leads associated with with a Lead Ad. |
| [`/previews`](https://developers.facebook.com/docs/marketing-api/reference/adgroup/previews/) | Generate ad previews from an existing ad |

---

## Ad Set

An ad set is a group of ads that share the same daily or lifetime budget, schedule, bid type, bid info, and targeting data.

### Edges

| Edge | Description |
|------|-------------|
| [`/activities`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/activities/) | Log of actions taken on the ad set |
| [`/adcreatives`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/adcreatives/) | Defines your ad's content and appearance |
| [`/ads`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/ads/) | Data necessary for an ad, such as creative elements and measurement information |
| [`/insights`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/insights/) | Insights on your advertising performance. |

---

## Ad Campaign

A campaign is the highest level organizational structure within an ad account and should represent a single objective for an advertiser.

### Edges

| Edge | Description |
|------|-------------|
| [`/ads`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/ads) | Data necessary for an ad, such as creative elements and measurement information |
| [`/adsets`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group) | Contain all ads that share the same budget, schedule, bid, and targeting. |
| [`/insights`](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign-group/insights) | Insights on your advertising performance. |

---

## Ad Creative

The format which provides layout and contains content for the ad.

### Edges

| Edge | Description |
|------|-------------|
| [`/previews`](https://developers.facebook.com/docs/marketing-api/reference/ad-creative/previews/) | Generate ad previews from the existing ad creative object |
