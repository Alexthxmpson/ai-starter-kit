# Playlists: list
**Source:** https://developers.google.com/youtube/v3/docs/playlists/list
**Date:** 2026-03-01
---

## Overview

Returns a collection of playlists that match the API request parameters. For example, you can retrieve all playlists that the authenticated user owns, or you can retrieve one or more playlists by their unique IDs.

**Quota impact:** A call to this method has a quota cost of **1 unit**.

## Common use cases

| Use case | Description |
|----------|-------------|
| list (all playlists for a channel) | Retrieves playlists owned by the YouTube channel that the request's `channelId` parameter identifies. |
| list (my playlists) | Retrieves playlists created in the authorized user's YouTube channel. Uses the `mine` request parameter to indicate that the API should only return playlists owned by the user authorizing the request. |

## HTTP Request

```
GET https://www.googleapis.com/youtube/v3/playlists
```

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | string | Specifies a comma-separated list of one or more `playlist` resource properties that the API response will include. Valid values: `contentDetails`, `id`, `localizations`, `player`, `snippet`, `status` |

### Filters (specify exactly one of the following parameters)

| Parameter | Type | Description |
|-----------|------|-------------|
| `channelId` | string | Indicates that the API should only return the specified channel's playlists. |
| `id` | string | Specifies a comma-separated list of the YouTube playlist ID(s) for the resource(s) that are being retrieved. |
| `mine` | boolean | Requires authorization. Set to `true` to instruct the API to only return playlists owned by the authenticated user. |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hl` | string | Instructs the API to retrieve localized resource metadata for a specific application language that the YouTube website supports. |
| `maxResults` | unsigned integer | Specifies the maximum number of items that should be returned in the result set. Acceptable values are 0 to 50, inclusive. The default value is 5. |
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. |
| `onBehalfOfContentOwnerChannel` | string | For YouTube content partners only. Specifies the YouTube channel ID of the channel for which the API response will include playlists. |
| `pageToken` | string | Identifies a specific page in the result set that should be returned. |

## Request body

Do not provide a request body when calling this method.

## Response

If successful, this method returns a response body with the following structure:

```json
{
  "kind": "youtube#playlistListResponse",
  "etag": etag,
  "nextPageToken": string,
  "prevPageToken": string,
  "pageInfo": {
    "totalResults": integer,
    "resultsPerPage": integer
  },
  "items": [
    playlist Resource
  ]
}
```

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `forbidden (403)` | `forbidden` | The request is not authorized to retrieve the specified playlist(s). The playlist may be private or restricted. |
| `notFound (404)` | `playlistNotFound` | The playlist identified with the request's `id` parameter cannot be found. |
