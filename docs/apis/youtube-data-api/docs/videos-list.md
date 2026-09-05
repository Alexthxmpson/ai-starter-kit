# Videos: list
**Source:** https://developers.google.com/youtube/v3/docs/videos/list
**Date:** 2026-03-01
---

## Overview

Returns a list of videos that match the API request parameters.

**Quota impact:** A call to this method has a quota cost of **1 unit**.

## Common use cases

| Use case | Description |
|----------|-------------|
| list (by video ID) | Retrieves information about a specific video. Uses the `id` parameter to identify the video. |
| list (multiple video IDs) | Retrieves information about a group of videos. The `id` parameter value is a comma-separated list of YouTube video IDs. |
| list (most popular videos) | Retrieves a list of YouTube's most popular videos. The `regionCode` parameter identifies the country for which you are retrieving videos. You can also use the `videoCategoryId` parameter to retrieve the most popular videos in a particular category. |
| list (my liked videos) | Retrieves a list of videos liked by the user authorizing the API request. By setting the `rating` parameter value to `dislike`, you could also use this to retrieve disliked videos. |

## HTTP Request

```
GET https://www.googleapis.com/youtube/v3/videos
```

## Authorization

For requests that retrieve private videos, authorization is required. Supported scopes:
- `https://www.googleapis.com/auth/youtube.readonly`
- `https://www.googleapis.com/auth/youtube`
- `https://www.googleapis.com/auth/youtubepartner`
- `https://www.googleapis.com/auth/youtube.force-ssl`

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | string | Specifies a comma-separated list of one or more `video` resource properties that the API response will include. Valid values: `contentDetails`, `fileDetails`, `id`, `liveStreamingDetails`, `localizations`, `paidProductPlacementDetails`, `player`, `processingDetails`, `recordingDetails`, `snippet`, `statistics`, `status`, `suggestions`, `topicDetails` |

### Filters (specify exactly one of the following parameters)

| Parameter | Type | Description |
|-----------|------|-------------|
| `chart` | string | Identifies the chart that you want to retrieve. Acceptable values: `mostPopular` |
| `id` | string | Specifies a comma-separated list of the YouTube video ID(s) for the resource(s) that are being retrieved. |
| `myRating` | string | Set this parameter's value to `like` or `dislike` to instruct the API to return videos liked or disliked by the authenticated user. Requires authorization. |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hl` | string | Instructs the API to retrieve localized resource metadata for the app language. Default value is `en_US`. |
| `maxHeight` | integer | Specifies the maximum height of the embedded player returned in the `player.embedHtml` property. Acceptable values are 72 to 8192. |
| `maxResults` | unsigned integer | Specifies the maximum number of items that should be returned. Acceptable values are 1 to 50, inclusive. The default value is 5. |
| `maxWidth` | integer | Specifies the maximum width of the embedded player returned in the `player.embedHtml` property. Acceptable values are 72 to 8192. |
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. |
| `pageToken` | string | Identifies a specific page in the result set that should be returned. |
| `regionCode` | string | Instructs the API to select a video chart available in the specified region. Parameter value is an ISO 3166-1 alpha-2 country code. |
| `videoCategoryId` | string | Identifies the video category for which the chart should be retrieved. By default, charts are not restricted to a particular category. |

## Request body

Do not provide a request body when calling this method.

## Response

If successful, this method returns a response body with the following structure:

```json
{
  "kind": "youtube#videoListResponse",
  "etag": etag,
  "nextPageToken": string,
  "prevPageToken": string,
  "pageInfo": {
    "totalResults": integer,
    "resultsPerPage": integer
  },
  "items": [
    video Resource
  ]
}
```

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `forbidden (403)` | `forbidden` | The request is not properly authorized to retrieve the specified video. The request may not be properly authorized. |
| `forbidden (403)` | `videoRatingDisabled` | The owner of the video identified by the `id` parameter has disabled ratings for that video. |
| `notFound (404)` | `videoNotFound` | The video that you are trying to retrieve cannot be found. Check the value of the `id` parameter to ensure that it is correct. |
