# PlaylistItems: insert
**Source:** https://developers.google.com/youtube/v3/docs/playlistItems/insert
**Date:** 2026-03-01
---

## Overview

Adds a resource to a playlist.

**Quota impact:** A call to this method has a quota cost of **50 units**.

## HTTP Request

```
POST https://www.googleapis.com/youtube/v3/playlistItems
```

## Authorization

This request requires authorization with at least one of the following scopes:
- `https://www.googleapis.com/auth/youtubepartner`
- `https://www.googleapis.com/auth/youtube`
- `https://www.googleapis.com/auth/youtube.force-ssl`

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | string | Identifies the properties that the write operation will set and what the API response will include. Valid values: `contentDetails`, `id`, `snippet`, `status` |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. |

## Request body

Provide a `playlistItem` resource in the request body.

### Required properties

- `snippet.playlistId`
- `snippet.resourceId`

### Settable properties

- `snippet.playlistId`
- `snippet.position`
- `snippet.resourceId`
- `contentDetails.note`
- `contentDetails.startAt`
- `contentDetails.endAt`

## Response

If successful, this method returns a `playlistItem` resource in the response body.

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `forbidden (403)` | `playlistContainsMaximumNumberOfVideos` | The playlist already contains the maximum allowed number of items. |
| `forbidden (403)` | `playlistItemsNotAccessible` | The request is not properly authorized to insert the specified playlist item. |
| `invalidValue (400)` | `invalidContentDetails` | The `contentDetails` property in the request is not valid. A possible reason is that `contentDetails.note` field is longer than 280 characters. |
| `invalidValue (400)` | `invalidPlaylistItemPosition` | The request attempts to set the playlist item's position to an invalid or unsupported value. |
| `invalidValue (400)` | `invalidResourceType` | The `type` specified for the resource ID is not supported for this operation. The resource ID identifies the item being added to the playlist (e.g. `youtube#video`). |
| `invalidValue (400)` | `manualSortRequired` | The request attempts to set the playlist item's position, but the playlist does not use manual sorting. Remove the `snippet.position` element from the request, or update the playlist's Ordering option to Manual. |
| `invalidValue (400)` | `videoAlreadyInAnotherSeriesPlaylist` | The video that you are trying to add to the playlist is already in another series playlist. |
| `notFound (404)` | `playlistNotFound` | The playlist identified with the request's `playlistId` parameter cannot be found. |
| `notFound (404)` | `videoNotFound` | The video that you are trying to add to the playlist cannot be found. Check the value of the `videoId` property. |
| `required (400)` | `channelIdRequired` | The request does not specify a value for the required `channelId` property. |
| `required (400)` | `playlistIdRequired` | The request does not specify a value for the required `playlistId` property. |
| `required (400)` | `resourceIdRequired` | The request must contain a resource in which the `snippet` object specifies a `resourceId`. |
| `invalidValue (400)` | `playlistOperationUnsupported` | The API does not support the ability to insert videos into the specified playlist. For example, you can't insert a video into your uploaded videos playlist. |

*Last updated 2025-08-28 UTC.*
