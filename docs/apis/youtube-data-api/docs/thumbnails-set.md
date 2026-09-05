# Thumbnails: set
**Source:** https://developers.google.com/youtube/v3/docs/thumbnails/set
**Date:** 2026-03-01
---

## Overview

Uploads a custom video thumbnail to YouTube and sets it for a video.

This method supports media upload. Uploaded files must conform to these constraints:
- **Maximum file size:** 2MB
- **Accepted Media MIME types:** `image/jpeg`, `image/png`, `application/octet-stream`

**Quota impact:** A call to this method has a quota cost of approximately **50 units**.

## Common use cases

This method has one common use case: uploading a custom thumbnail image to YouTube and setting the image as the thumbnail for the specified video. The `videoId` parameter is required.

## HTTP Request

```
POST https://www.googleapis.com/upload/youtube/v3/thumbnails/set
```

## Authorization

This request requires authorization with at least one of the following scopes:
- `https://www.googleapis.com/auth/youtubepartner`
- `https://www.googleapis.com/auth/youtube.upload`
- `https://www.googleapis.com/auth/youtube`
- `https://www.googleapis.com/auth/youtube.force-ssl`

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `videoId` | string | Specifies a YouTube video ID for which the custom video thumbnail is being provided. |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. Allows content owners to authenticate once and get access to all their video and channel data. The actual CMS account that the user authenticates with must be linked to the specified YouTube content owner. |

## Request body

The body of the request contains the thumbnail image that you are uploading. The request body does not contain a `thumbnail` resource.

## Response

If successful, this method returns a response body with the following structure:

```json
{
  "kind": "youtube#thumbnailSetResponse",
  "etag": etag,
  "items": [
    thumbnail resource
  ]
}
```

### Response properties

| Property | Type | Description |
|----------|------|-------------|
| `kind` | string | Identifies the API resource's type. The value will be `youtube#thumbnailSetResponse`. |
| `etag` | etag | The Etag of this resource. |
| `items[]` | list | A list of thumbnails. |

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `badRequest (400)` | `invalidImage` | The provided image content is invalid. |
| `badRequest (400)` | `mediaBodyRequired` | The request does not include the image content. |
| `forbidden (403)` | `forbidden` | The thumbnail can't be set for the specified video. The request might not be properly authorized. |
| `forbidden (403)` | `forbidden` | The authenticated user doesn't have permissions to upload and set custom video thumbnails. |
| `notFound (404)` | `videoNotFound` | The video that you are trying to insert a thumbnail image for cannot be found. Check the value of the request's `videoId` parameter to ensure that it is correct. |
| `tooManyRequests (429)` | `uploadRateLimitExceeded` | The channel has uploaded too many thumbnails recently. Please try the request again later. |

*Last updated 2025-08-28 UTC.*
