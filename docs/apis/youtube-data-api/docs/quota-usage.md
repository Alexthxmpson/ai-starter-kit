# Quota Costs for API Requests
**Source:** https://developers.google.com/youtube/v3/determine_quota_cost
**Date:** 2026-03-01
**Note:** The originally requested URL `https://developers.google.com/youtube/v3/determine_quota_usage` returned 404. The correct URL is `https://developers.google.com/youtube/v3/determine_quota_cost`.
---

## Overview

Every API request, including invalid ones, incurs a minimum quota cost of one unit. Projects that enable the YouTube Data API have a default quota allocation of **10,000 units per day**. Quota resets at midnight Pacific Time.

## How Quota Is Calculated

- Each API request consumes quota units based on the resource and method called.
- If your application calls a method that returns multiple pages of results (e.g., `search.list`), each request to retrieve an additional page incurs the same estimated quota cost.
- Live Streaming API methods are included in the YouTube Data API and carry identical quota costs.
- Invalid requests still consume at least 1 unit.

## Quota Cost Table

| Resource | Method | Cost (units) |
|----------|--------|--------------|
| activities | list | 1 |
| captions | list | 50 |
| captions | insert | 400 |
| captions | update | 450 |
| captions | delete | 50 |
| channelBanners | insert | 50 |
| channels | list | 1 |
| channels | update | 50 |
| channelSections | list | 1 |
| channelSections | insert | 50 |
| channelSections | update | 50 |
| channelSections | delete | 50 |
| comments | list | 1 |
| comments | insert | 50 |
| comments | update | 50 |
| comments | setModerationStatus | 50 |
| comments | delete | 50 |
| commentThreads | list | 1 |
| commentThreads | insert | 50 |
| commentThreads | update | 50 |
| guideCategories | list | 1 |
| i18nLanguages | list | 1 |
| i18nRegions | list | 1 |
| members | list | 1 |
| membershipsLevels | list | 1 |
| playlistItems | list | 1 |
| playlistItems | insert | 50 |
| playlistItems | update | 50 |
| playlistItems | delete | 50 |
| playlists | list | 1 |
| playlists | insert | 50 |
| playlists | update | 50 |
| playlists | delete | 50 |
| search | list | 100 |
| subscriptions | list | 1 |
| subscriptions | insert | 50 |
| subscriptions | delete | 50 |
| thumbnails | set | 50 |
| videoAbuseReportReasons | list | 1 |
| videoCategories | list | 1 |
| videos | list | 1 |
| videos | getRating | 1 |
| videos | insert | 100 |
| videos | update | 50 |
| videos | rate | 50 |
| videos | reportAbuse | 50 |
| videos | delete | 50 |
| watermarks | set | 50 |
| watermarks | unset | 50 |

## Monitoring Quota Usage

View quota consumption in the **Quotas page in the API Console** (Google Cloud Console) under your project's APIs & Services section.

## Requesting Quota Increases

If you reach the daily quota limit, you can request additional quota by completing the **Quota extension request form for YouTube API Services** available in the Google Cloud Console.

## Important Notes

- Default quota of 10,000 units/day is subject to change.
- The `search.list` method costs **100 units per call** — use it sparingly. Prefer `videos.list`, `channels.list`, or `playlists.list` (1 unit each) where possible.
- `captions.insert` costs 400 units and `captions.update` costs 450 units — the most expensive non-upload operations.
- `videos.insert` costs 100 units per upload.
