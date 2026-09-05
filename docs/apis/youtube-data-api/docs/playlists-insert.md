# Playlists: insert
**Source:** https://developers.google.com/youtube/v3/docs/playlists/insert
**Date:** 2026-03-01
---

## Overview

Creates a playlist.

**Quota impact:** A call to this method has a quota cost of **50 units**.

## HTTP Request

```
POST https://www.googleapis.com/youtube/v3/playlists
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
| `part` | string | Identifies the properties that the write operation will set and what the API response will include. Valid values: `contentDetails`, `id`, `localizations`, `player`, `snippet`, `status` |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. |
| `onBehalfOfContentOwnerChannel` | string | For YouTube content partners only. Specifies the YouTube channel ID of the channel to which a video is being added. Required when `onBehalfOfContentOwner` is specified. |

## Request body

Provide a `playlist` resource in the request body.

### Required properties

- `snippet.title`

### Settable properties

- `snippet.title`
- `snippet.description`
- `status.privacyStatus`
- `snippet.defaultLanguage`
- `localizations.(key)`
- `localizations.(key).title`
- `localizations.(key).description`

## Response

If successful, this method returns a `playlist` resource in the response body.

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `badRequest (400)` | `defaultLanguageNotSetError` | The `defaultLanguage` must be set to update `localizations`. |
| `badRequest (400)` | `localizationValidationError` | One of the values in the localizations object failed validation. Use the `playlists.list` method to retrieve valid values. |
| `badRequest (400)` | `maxPlaylistExceeded` | The playlist cannot be created because the channel already has the maximum number of playlists allowed. |
| `forbidden (403)` | `playlistForbidden` | This operation is forbidden or the request is not properly authorized. |
| `invalidValue (400)` | `invalidPlaylistSnippet` | The request provides an invalid playlist snippet. |
| `required (400)` | `playlistTitleRequired` | The request must specify a playlist title. |

*Last updated 2025-08-28 UTC.*
