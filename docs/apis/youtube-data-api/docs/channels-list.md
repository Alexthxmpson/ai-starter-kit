# Channels: list
**Source:** https://developers.google.com/youtube/v3/docs/channels/list
**Date:** 2026-03-01
---

## Overview

Returns a collection of zero or more channel resources that match the request criteria.

**Quota impact:** A call to this method has a quota cost of **1 unit**.

## Common use cases

| Use case | Description |
|----------|-------------|
| list (by channel ID) | Retrieves channel data for a specific channel using the `id` parameter (e.g., GoogleDevelopers YouTube channel). |
| list (by YouTube handle) | Retrieves channel data using the `forHandle` parameter (e.g., `@GoogleDevelopers`). |
| list (by YouTube username) | Retrieves channel data using the `forUsername` parameter. |
| list (my channel) | Retrieves channel data for the authorized user's YouTube channel using the `mine` parameter. |

## HTTP Request

```
GET https://www.googleapis.com/youtube/v3/channels
```

## Authorization

A request that retrieves the `auditDetails` part for a `channel` resource must provide an authorization token that contains the `https://www.googleapis.com/auth/youtubepartner-channel-audit` scope. In addition, any token that uses that scope must be revoked when the MCN decides to accept or reject the channel or within two weeks of the date that the token was issued.

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | string | Specifies a comma-separated list of one or more `channel` resource properties that the API response will include. Valid values: `auditDetails`, `brandingSettings`, `contentDetails`, `contentOwnerDetails`, `id`, `localizations`, `snippet`, `statistics`, `status`, `topicDetails` |

### Filters (specify exactly one of the following parameters)

| Parameter | Type | Description |
|-----------|------|-------------|
| `categoryId` | string | **Deprecated.** Specified a YouTube guide category and could be used to request YouTube channels associated with that category. |
| `forHandle` | string | Specifies a YouTube handle, thereby requesting the channel associated with that handle. The parameter value can be prepended with an `@` symbol (e.g., `GoogleDevelopers` or `@GoogleDevelopers`). |
| `forUsername` | string | Specifies a YouTube username, thereby requesting the channel associated with that username. |
| `id` | string | Specifies a comma-separated list of the YouTube channel ID(s) for the resource(s) that are being retrieved. |
| `managedByMe` | boolean | Requires authorization. For YouTube content partners only. Set to `true` to instruct the API to only return channels managed by the content owner specified by `onBehalfOfContentOwner`. The user must be authenticated as a CMS account linked to the specified content owner, and `onBehalfOfContentOwner` must be provided. |
| `mine` | boolean | Requires authorization. Set to `true` to instruct the API to only return channels owned by the authenticated user. |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `hl` | string | Instructs the API to retrieve localized resource metadata for a specific application language that the YouTube website supports. If localized details are available, the `snippet.localized` object will contain localized values; otherwise it will contain resource details in the resource's default language. |
| `maxResults` | unsigned integer | Specifies the maximum number of items that should be returned in the result set. Acceptable values are 0 to 50, inclusive. The default value is 5. |
| `onBehalfOfContentOwner` | string | For YouTube content partners only. Indicates that the request's authorization credentials identify a YouTube CMS user acting on behalf of the specified content owner. Allows content owners to authenticate once and get access to all their video and channel data. |
| `pageToken` | string | Identifies a specific page in the result set that should be returned. In an API response, `nextPageToken` and `prevPageToken` identify other pages that could be retrieved. |

## Request body

Do not provide a request body when calling this method.

## Response

If successful, this method returns a response body with the following structure:

```json
{
  "kind": "youtube#channelListResponse",
  "etag": etag,
  "nextPageToken": string,
  "prevPageToken": string,
  "pageInfo": {
    "totalResults": integer,
    "resultsPerPage": integer
  },
  "items": [
    channel Resource
  ]
}
```

### Response properties

| Property | Type | Description |
|----------|------|-------------|
| `kind` | string | Identifies the API resource's type. The value will be `youtube#channelListResponse`. |
| `etag` | etag | The Etag of this resource. |
| `nextPageToken` | string | The token that can be used as the value of the `pageToken` parameter to retrieve the next page in the result set. |
| `prevPageToken` | string | The token that can be used as the value of the `pageToken` parameter to retrieve the previous page in the result set. Note: not included in the API response if the request set `managedByMe` to `true`. |
| `pageInfo.totalResults` | integer | The total number of results in the result set. |
| `pageInfo.resultsPerPage` | integer | The number of results included in the API response. |
| `items[]` | list | A list of channels that match the request criteria. |

## Errors

| Error type | Error detail | Description |
|------------|--------------|-------------|
| `badRequest (400)` | `invalidCriteria` | A maximum of one of the following filters may be specified: `id`, `categoryId`, `mine`, `managedByMe`, `forHandle`, `forUsername`. In case of content owner authentication via `onBehalfOfContentOwner`, only `id` or `managedByMe` may be specified. |
| `forbidden (403)` | `channelForbidden` | The channel specified by the `id` parameter does not support the request or the request is not properly authorized. |
| `notFound (404)` | `categoryNotFound` | The category identified by the `categoryId` parameter cannot be found. Use the `guideCategories.list` method to retrieve a list of valid values. |
