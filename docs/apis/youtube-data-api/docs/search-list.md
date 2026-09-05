# Search: list
**Source:** https://developers.google.com/youtube/v3/docs/search/list
**Date:** 2026-03-01
---

## Overview

Returns a collection of search results that match the query parameters specified in the API request. By default, a search result set identifies matching `video`, `channel`, and `playlist` resources, but you can also configure queries to only retrieve a specific type of resource.

**Quota impact:** A call to this method has a quota cost of **100 units**.

## Common use cases

| Use case | Description |
|----------|-------------|
| list (by keyword) | Retrieves the first 25 search results associated with a keyword. By default, the `type` parameter does not specify a value, which means the response could include videos, playlists, and channels. |
| list (by location) | Retrieves search results that also specify in their metadata a geographic location within a specific radius. |
| list (live events) | Retrieves a list of active live broadcasts associated with a keyword. Since the `eventType` parameter is set, the request must also set the `type` parameter value to `video`. |
| list (my videos) | Searches within the authorized user's videos for videos that match a keyword. Uses the `forMine` parameter, which requires setting `type` to `video`. |

## HTTP Request

```
GET https://www.googleapis.com/youtube/v3/search
```

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | string | Specifies a comma-separated list of one or more `search` resource properties that the API response will include. Set the parameter value to `snippet`. |

### Filters (specify 0 or 1 of the following parameters)

| Parameter | Type | Description |
|-----------|------|-------------|
| `forContentOwner` | boolean | Requires authorization. Intended exclusively for YouTube content partners. Restricts the search to only retrieve videos owned by the content owner identified by the `onBehalfOfContentOwner` parameter. If `forContentOwner` is `true`, the `type` parameter must be set to `video`. |
| `forDeveloper` | boolean | Requires authorization. Restricts the search to only retrieve videos uploaded via the developer's application or website. |
| `forMine` | boolean | Requires authorization. Restricts the search to only retrieve videos owned by the authenticated user. If `true`, the `type` parameter must be set to `video`. |
| `relatedToVideoId` | string | Retrieves a list of videos that are related to the video that the parameter value identifies. If this parameter is set, the `type` parameter must be set to `video`. |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `channelId` | string | Indicates that the API response should only contain resources created by the channel. Note: Search results are constrained to a maximum of 500 videos if your request specifies a `channelId` value and sets the `type` value to `video`, but does not also set one of the `forContentOwner`, `forDeveloper`, or `forMine` filters. |
| `channelType` | string | Restricts a search to a particular type of channel. Acceptable values: `any` (all channels), `show` (only shows). |
| `eventType` | string | Restricts a search to broadcast events. Acceptable values: `completed`, `live`, `upcoming`. If set, `type` must be set to `video`. |
| `location` | string | Restricts a search to videos that specify, in their metadata, a geographic location that falls within the specified, circular geographic area (e.g., `37.42307,-122.08427`). |
| `locationRadius` | string | Defines the circular geographic area in conjunction with the `location` parameter. Valid measurement units are `m`, `km`, `ft`, and `mi` (e.g., `1500m`, `5km`, `10000ft`, `0.75mi`). |
| `maxResults` | unsigned integer | Specifies the maximum number of items that should be returned in the result set. Acceptable values are 0 to 50, inclusive. The default value is 5. |
| `onBehalfOfContentOwner` | string | For YouTube content partners only. |
| `order` | string | Specifies the method that will be used to order resources in the API response. Acceptable values: `date` (reverse chronological order), `rating` (highest to lowest rating), `relevance` (default, by search query relevance), `title` (alphabetically), `videoCount` (channels by video count), `viewCount` (most views first). |
| `pageToken` | string | Identifies a specific page in the result set that should be returned. |
| `publishedAfter` | datetime | Restricts the response to only include resources created at or after the specified time. The value is an RFC 3339 formatted date-time value (e.g., `1970-01-01T00:00:00Z`). |
| `publishedBefore` | datetime | Restricts the response to only include resources created before or at the specified time. |
| `q` | string | Specifies the query term to search for. Your request can also use the Boolean NOT (`-`) and OR (`\|`) operators to exclude videos or to find videos associated with one of several search terms. |
| `regionCode` | string | Instructs the API to return search results for videos that can be viewed in the specified country (ISO 3166-1 alpha-2 country code). |
| `relevanceLanguage` | string | Instructs the API to return search results that are most relevant to the specified language (ISO 639-1 two-letter language code). |
| `safeSearch` | string | Indicates whether the search results should include restricted content as well as standard content. Acceptable values: `moderate` (default), `none`, `strict`. |
| `topicId` | string | Indicates that the API response should only contain resources associated with the specified topic. |
| `type` | string | Restricts a search query to only retrieve a particular type of resource. The value is a comma-separated list of resource types. Acceptable values: `channel`, `playlist`, `video`. Default: `video,channel,playlist` |
| `videoCaption` | string | Indicates whether the API should filter video search results based on whether they have captions. Acceptable values: `any`, `closedCaption`, `none`. `type` must be set to `video`. |
| `videoCategoryId` | string | Filters video search results based on their category. `type` must be set to `video`. |
| `videoDefinition` | string | Filters video search results based on their definition. Acceptable values: `any`, `high`, `standard`. `type` must be set to `video`. |
| `videoDimension` | string | Restricts a search to only retrieve 2D or 3D videos. Acceptable values: `2d`, `3d`, `any`. `type` must be set to `video`. |
| `videoDuration` | string | Filters video search results based on their duration. Acceptable values: `any` (default), `long` (> 20 minutes), `medium` (4 to 20 minutes), `short` (< 4 minutes). `type` must be set to `video`. |
| `videoEmbeddable` | string | Restricts a search to only videos that can be embedded into a webpage. Acceptable values: `any`, `true`. `type` must be set to `video`. |
| `videoLicense` | string | Filters search results to only include videos with a particular license. Acceptable values: `any`, `creativeCommon`, `youtube`. `type` must be set to `video`. |
| `videoPaidProductPlacement` | string | Filters search results to videos marked as containing paid product placement. Acceptable values: `any`, `true`. `type` must be set to `video`. |
| `videoSyndicated` | string | Restricts a search to only videos that can be played outside youtube.com. Acceptable values: `any`, `true`. `type` must be set to `video`. |
| `videoType` | string | Filters search results to only include a particular type of videos. Acceptable values: `any`, `episode`, `movie`. `type` must be set to `video`. |

## Request body

Do not provide a request body when calling this method.

## Response

If successful, this method returns a response body with the following structure:

```json
{
  "kind": "youtube#searchListResponse",
  "etag": etag,
  "nextPageToken": string,
  "prevPageToken": string,
  "regionCode": string,
  "pageInfo": {
    "totalResults": integer,
    "resultsPerPage": integer
  },
  "items": [
    search Resource
  ]
}
```

## Important notes

- Search results are constrained to a maximum of 500 videos if your request specifies a `channelId` value and sets `type` to `video`, but does not also set one of the `forContentOwner`, `forDeveloper`, or `forMine` filters.
- `totalResults` in the response is an approximation and should not be used as an authoritative value.
- The `q` parameter supports Boolean NOT (`-`) and OR (`|`) operators.
