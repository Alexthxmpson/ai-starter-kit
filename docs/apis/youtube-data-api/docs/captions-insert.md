# Captions: insert
**Source:** https://developers.google.com/youtube/v3/docs/captions/insert
**Date:** 2026-03-01
---

## Overview

Uploads a caption track.

This method supports media upload. Uploaded files must conform to these constraints:
- **Maximum file size:** 100MB
- **Accepted Media MIME types:** `text/xml`, `application/octet-stream`, `*/*`

**Quota impact:** A call to this method has a quota cost of **400 units**.

## Common use cases

This method has one common use case: adding a caption track to a video. The `snippet.videoId`, `snippet.language`, and `snippet.name` property values are all required. The `snippet.isDraft` property value can optionally be set to `true` to prevent the track from being publicly available.

## HTTP Request

```
POST https://www.googleapis.com/upload/youtube/v3/captions
```

## Authorization

This request requires authorization with at least one of the following scopes:
- `https://www.googleapis.com/auth/youtube.force-ssl`
- `https://www.googleapis.com/auth/youtubepartner`

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | string | Specifies the `caption` resource parts that the API response will include. Set the parameter value to `snippet`. Valid values: `id`, `snippet` |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. Allows content owners to authenticate once and get access to all their video and channel data. |
| `sync` | boolean | **Deprecated.** Indicates whether YouTube should automatically synchronize the caption file with the audio track of the video. If set to `true`, YouTube will disregard any time codes in the uploaded caption file and generate new time codes. Set to `true` if uploading a transcript with no time codes, or if the time codes are suspected to be incorrect. |

## Request body

Provide a `caption` resource in the request body.

### Required properties

- `snippet.videoId`
- `snippet.language`
- `snippet.name`

### Settable properties

- `snippet.videoId`
- `snippet.language`
- `snippet.name`
- `snippet.isDraft`

## Response

If successful, this method returns a `caption` resource in the response body.

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `badRequest (400)` | `contentRequired` | The request does not contain the caption track contents. |
| `conflict (409)` | `captionExists` | The specified video already has a caption track with the given `snippet.language` and `snippet.name`. A video can have multiple tracks for the same language, but each track must have a different name. You could delete the existing track and then insert a new one, or change the name of the new track before inserting it. |
| `forbidden (403)` | `forbidden` | The permissions associated with the request are not sufficient to upload the caption track. The request might not be properly authorized. |
| `invalidValue (400)` | `invalidMetadata` | The request contains invalid metadata values, which prevent the track from being created. Confirm that the request specifies valid values for the `snippet.language`, `snippet.name`, and `snippet.videoId` properties. The `snippet.isDraft` property can also be included, but it is not required. |
| `notFound (404)` | `videoNotFound` | The video identified by the `videoId` parameter couldn't be found. |
| `invalidValue (400)` | `nameTooLong` | The `snippet.name` specified in the request is too long. The maximum length supported is 150 characters. |

*Last updated 2025-08-28 UTC.*
