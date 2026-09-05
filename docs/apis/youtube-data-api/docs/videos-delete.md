# Videos: delete
**Source:** https://developers.google.com/youtube/v3/docs/videos/delete
**Date:** 2026-03-01
---

## Overview

Deletes a YouTube video.

**Quota impact:** A call to this method has a quota cost of **50 units**.

## HTTP Request

```
DELETE https://www.googleapis.com/youtube/v3/videos
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
| `id` | string | Specifies the YouTube video ID for the resource that is being deleted. In a `video` resource, the `id` property specifies the video's ID. |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. |

## Request body

Do not provide a request body when calling this method.

## Response

If successful, this method returns an HTTP `204` response code (`No Content`).

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `forbidden (403)` | `forbidden` | The video that you are trying to delete cannot be deleted. The request might not be properly authorized. |
| `notFound (404)` | `videoNotFound` | The video that you are trying to delete cannot be found. Check the value of the request's `id` parameter to ensure that it is correct. |

*Last updated 2025-08-28 UTC.*
