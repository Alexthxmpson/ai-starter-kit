# Videos: update
**Source:** https://developers.google.com/youtube/v3/docs/videos/update
**Date:** 2026-03-01
---

## Overview

Updates a video's metadata.

**Note:** The API now supports the ability to mark your channel or videos as "made for kids." Channel and video resources also contain a property that identifies the "made for kids" status.

**Quota impact:** A call to this method has a quota cost of **50 units**.

## HTTP Request

```
PUT https://www.googleapis.com/youtube/v3/videos
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
| `part` | string | Identifies the properties that the write operation will set and what the API response will include. Note that this method will override the existing values for all mutable properties in parts specified. Valid values: `contentDetails`, `fileDetails`, `id`, `liveStreamingDetails`, `localizations`, `paidProductPlacementDetails`, `player`, `processingDetails`, `recordingDetails`, `snippet`, `statistics`, `status`, `suggestions`, `topicDetails` |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. |

## Request body

Provide a `video` resource in the request body.

### Required properties

- `id`
- `snippet.title` (required if updating the `snippet`)
- `snippet.categoryId` (required if updating the `snippet`)

### Settable properties

- `snippet.categoryId`
- `snippet.defaultLanguage`
- `snippet.description`
- `snippet.tags[]`
- `snippet.title`
- `status.embeddable`
- `status.license`
- `status.privacyStatus`
- `status.publicStatsViewable`
- `status.publishAt` (can only be set if privacy status is `private` and video has never been published; must also set `status.privacyStatus` to `private`)
- `status.selfDeclaredMadeForKids`
- `status.containsSyntheticMedia`
- `recordingDetails.recordingDate`
- `localizations.(key)`
- `localizations.(key).title`
- `localizations.(key).description`

**Important:** If you are submitting an update request, and your request does not specify a value for a property that already has a value, the property's existing value will be deleted.

## Response

If successful, this method returns a `video` resource in the response body.

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `badRequest (400)` | `defaultLanguageNotSet` | The API request is trying to add localized video details without specifying the default language of the video details. |
| `badRequest (400)` | `invalidCategoryId` | The `snippet.categoryId` property specifies an invalid category ID. Use the `videoCategories.list` method to retrieve supported categories. |
| `badRequest (400)` | `invalidDefaultBroadcastPrivacySetting` | The request attempts to set an invalid privacy setting for the default broadcast. |
| `badRequest (400)` | `invalidDescription` | The request metadata specifies an invalid video description. |
| `badRequest (400)` | `invalidPublishAt` | The request metadata specifies an invalid scheduled publishing time. |
| `badRequest (400)` | `invalidRecordingDate` | The request metadata specifies an invalid recording date. |
| `badRequest (400)` | `invalidTags` | The request metadata specifies invalid video keywords. |
| `badRequest (400)` | `invalidTitle` | The request metadata specifies an invalid or empty video title. |
| `badRequest (400)` | `invalidVideoMetadata` | The request metadata is invalid. |
| `forbidden (403)` | `forbidden` | The request is not properly authorized to update the video metadata. |
| `forbidden (403)` | `forbiddenEmbedSetting` | The request attempts to set an invalid embed setting for the video. |
| `forbidden (403)` | `forbiddenLicenseSetting` | The request attempts to set an invalid license for the video. |
| `forbidden (403)` | `forbiddenPrivacySetting` | The request attempts to set an invalid privacy setting for the video. |
| `notFound (404)` | `videoNotFound` | The video that you are trying to update cannot be found. Check the value of the request body's `id` property to ensure that it is correct. |
