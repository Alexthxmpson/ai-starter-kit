# Ad Creative - Marketing API

**Source:** https://developers.facebook.com/docs/marketing-api/creative
**Date:** 2026-03-01

---

## Ad Creative

Use Facebook ads with your existing customers and to reach new ones. Each guide describes Facebook ads products to help meet your advertising goals. There are several types of ad units with a variety of appearances, placement and creative options. For guidelines on ads units as creative content, see [Facebook Ads Guide](https://www.facebook.com/business/ads-guide/).

## Creative

An ad creative is an object that contains all the data for visually rendering the ad itself. In the API, there are different types of ads that you can create on Facebook.

If you have a campaign with the Page Post Engagement Objective, you can now create an ad that promotes a post made by the page. This is considered a Page post ad. Page post ads require a field called `object_story_id`, which is the `id` property of a Page post.

An ad creative has three parts:

- The ad creative itself, defined by the visual attributes of the creative object
- Placement that the ad runs on
- Preview of the unit itself, per placement

**To create the ad creative object:**

```bash
curl -X POST \
  -F 'name="Sample Promoted Post"' \
  -F 'object_story_id="<PAGE_ID>_<POST_ID>"' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adcreatives
```

The response to the API call is the `id` of the creative object. Use it for the ad object:

```bash
curl -X POST \
  -F 'name="My Ad"' \
  -F 'adset_id="<AD_SET_ID>"' \
  -F 'creative={ "creative_id": "<CREATIVE_ID>" }' \
  -F 'status="PAUSED"' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/ads
```

### Limits

There are limits on the creative's text, image size, image aspect ratio and other aspects of the creative. See the [Ads Guide](https://www.facebook.com/business/ads-guide).

### Read

In the Ads API, each field you want to retrieve needs to be asked for explicitly, except for `id`.

```bash
curl -G \
  -d 'fields=name,object_story_id' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/<CREATIVE_ID>
```

## Placements

A placement is where your ad is shown on Facebook, such as on Feed on desktop, Feed on a mobile device or on the right column. See [Ads Product Guide](https://www.facebook.com/business/ads-guide/).

We encourage you to run ads across the full range of available placements. Facebook's ad auction is designed to deliver ad impressions to the placement most likely to drive campaign results at the lowest possible cost.

The easiest way to take advantage of this optimization is to leave this field blank. You can also select specific placements in an ad set's `target_spec`.

```bash
curl -X POST \
  -F 'name=Desktop Ad Set' \
  -F 'campaign_id=<CAMPAIGN_ID>' \
  -F 'daily_budget=10000' \
  -F 'targeting={ "geo_locations": {"countries":["US"]}, "publisher_platforms": ["facebook","audience_network"] }' \
  -F 'optimization_goal=LINK_CLICKS' \
  -F 'billing_event=IMPRESSIONS' \
  -F 'bid_amount=1000' \
  -F 'status=PAUSED' \
  -F 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/adsets
```

## Preview an Ad

You preview an ad in one of two ways — with the ad preview API or the ad preview plugin.

There are three ways to generate a preview with the API:

- By ad ID
- By ad creative ID
- By supplying a creative spec

**Minimum required preview API call:**

```bash
curl -G \
  --data-urlencode 'creative="<CREATIVE_SPEC>"' \
  -d 'ad_format="<AD_FORMAT>"' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/generatepreviews
```

**Preview by creative spec:**

```bash
curl -G \
  -d 'creative={"object_story_id":"<PAGE_ID>_<POST_ID>"}' \
  -d 'ad_format=<AD_FORMAT>' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/generatepreviews
```

**Preview for Desktop Feed:**

```bash
curl -G \
  -d 'creative={"object_story_id":"<PAGE_ID>_<POST_ID>"}' \
  -d 'ad_format=DESKTOP_FEED_STANDARD' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/generatepreviews
```

**Preview for Right Column:**

```bash
curl -G \
  -d 'creative={"object_story_id":"<PAGE_ID>_<POST_ID>"}' \
  -d 'ad_format=RIGHT_COLUMN_STANDARD' \
  -d 'access_token=<ACCESS_TOKEN>' \
  https://graph.facebook.com/v25.0/act_<AD_ACCOUNT_ID>/generatepreviews
```

The response is an iFrame that's valid for 24 hrs.

## See More

- [Ad Creative Reference](https://developers.facebook.com/docs/marketing-api/reference/ad-creative)
- [Facebook App Ads](https://developers.facebook.com/docs/app-ads)
- [Ads Guide](https://www.facebook.com/business/ads-guide)
