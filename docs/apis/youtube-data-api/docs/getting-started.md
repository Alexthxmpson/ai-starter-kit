# YouTube Data API Overview
**Source:** https://developers.google.com/youtube/v3/getting-started
**Date:** 2026-03-01
---

## Introduction

This document is intended for developers who want to write applications that interact with YouTube. It explains basic concepts of YouTube and of the API itself. It also provides an overview of the different functions that the API supports.

### Before you start

- You need a Google Account to access the Google API Console, request an API key, and register your application.
- Create a project in the Google Developers Console (https://console.developers.google.com) and obtain authorization credentials so your application can submit API requests.
- After creating your project, make sure the YouTube Data API is one of the services that your application is registered to use:
  - Go to the API Console (https://console.cloud.google.com/) and select the project that you just registered.
  - Visit the Enabled APIs page (https://console.cloud.google.com/apis/enabled). In the list of APIs, make sure the status is ON for the YouTube Data API v3.
- If your application will use any API methods that require user authorization, read the authentication guide to learn how to implement OAuth 2.0 authorization.
- Select a client library to simplify your API implementation.
- Familiarize yourself with the core concepts of the JSON (JavaScript Object Notation) data format.

## Resources and resource types

A resource is an individual data entity with a unique identifier. The table below describes the different types of resources that you can interact with using the API.

| Resource | Description |
|----------|-------------|
| `activity` | Contains information about an action that a particular user has taken on the YouTube site. User actions that are reported in activity feeds include rating a video, sharing a video, marking a video as a favorite, and posting a channel bulletin, among others. |
| `channel` | Contains information about a single YouTube channel. |
| `channelBanner` | Identifies the URL to use to set a newly uploaded image as the banner image for a channel. |
| `channelSection` | Contains information about a set of videos that a channel has chosen to feature. For example, a section could feature a channel's latest uploads, most popular uploads, or videos from one or more playlists. |
| `guideCategory` | Identifies a category that YouTube associates with channels based on their content or other indicators, such as popularity. |
| `i18nLanguage` | Identifies an application language that the YouTube website supports. The application language can also be referred to as a UI language. |
| `i18nRegion` | Identifies a geographic area that a YouTube user can select as the preferred content region. |
| `playlist` | Represents a single YouTube playlist. A playlist is a collection of videos that can be viewed sequentially and shared with other users. |
| `playlistItem` | Identifies a resource, such as a video, that is part of a playlist. The playlistItem resource also contains details that explain how the included resource is used in the playlist. |
| `search result` | Contains information about a YouTube video, channel, or playlist that matches the search parameters specified in an API request. |
| `subscription` | Contains information about a YouTube user subscription. |
| `thumbnail` | Identifies thumbnail images associated with a resource. |
| `video` | Represents a single YouTube video. |
| `videoCategory` | Identifies a category that has been or could be associated with uploaded videos. |
| `watermark` | Identifies an image that displays during playbacks of a specified channel's videos. |

Note that, in many cases, a resource contains references to other resources. For example, a `playlistItem` resource's `snippet.resourceId.videoId` property identifies a video resource.

### Supported operations

The following table shows the most common methods that the API supports:

| Operation | Description |
|-----------|-------------|
| `list` | Retrieves (GET) a list of zero or more resources. |
| `insert` | Creates (POST) a new resource. |
| `update` | Modifies (PUT) an existing resource to reflect data in your request. |
| `delete` | Removes (DELETE) a specific resource. |

**Supported operations by resource type:**

| Resource | list | insert | update | delete |
|----------|------|--------|--------|--------|
| `activity` | yes | - | - | - |
| `caption` | yes | yes | yes | yes |
| `channel` | yes | - | - | - |
| `channelBanner` | - | yes | - | - |
| `channelSection` | yes | yes | yes | yes |
| `comment` | yes | yes | yes | yes |
| `commentThread` | yes | yes | yes | - |
| `guideCategory` | - | - | - | - |
| `i18nLanguage` | yes | - | - | - |
| `i18nRegion` | yes | - | - | - |
| `playlist` | yes | yes | yes | yes |
| `playlistItem` | yes | yes | yes | yes |
| `search result` | yes | - | - | - |
| `subscription` | yes | - | - | - |
| `thumbnail` | - | - | - | - |
| `video` | yes | yes | yes | yes |
| `videoCategory` | yes | - | - | - |
| `watermark` | - | - | - | - |

Operations that insert, update, or delete resources always require user authorization. In some cases, `list` methods support both authorized and unauthorized requests, where unauthorized requests only retrieve public data.

## Quota usage

The YouTube Data API uses a quota to ensure that developers use the service as intended and do not create applications that unfairly reduce service quality or limit access for others. All API requests, including invalid requests, incur at least a one-point quota cost.

Projects that enable the YouTube Data API have a default quota allocation of **10,000 units per day**. You can see your quota usage on the Quotas page in the API Console.

Note: If you reach the quota limit, you can request additional quota by completing the Quota extension request form (https://support.google.com/youtube/contact/yt_api_form) for YouTube API Services.

### Calculating quota usage

Google calculates your quota usage by assigning a cost to each request. Different types of operations have different quota costs:

- A read operation that retrieves a list of resources (channels, videos, playlists) usually costs **1 unit**.
- A write operation that creates, updates, or deletes a resource usually costs **50 units**.
- A search request costs **100 units**.
- A video upload costs **100 units**.

## Partial resources

The API allows, and actually requires, the retrieval of partial resources so that applications avoid transferring, parsing, and storing unneeded data.

The API supports two request parameters that enable you to identify the resource properties that should be included in API responses:

- The `part` parameter identifies groups of properties that should be returned for a resource.
- The `fields` parameter filters the API response to only return specific properties within the requested resource parts.

### How to use the `part` parameter

The `part` parameter is a required parameter for any API request that retrieves or returns a resource. The parameter identifies one or more top-level (non-nested) resource properties that should be included in an API response.

For example, a `video` resource has the following parts:
- `snippet`
- `contentDetails`
- `fileDetails`
- `player`
- `processingDetails`
- `recordingDetails`
- `statistics`
- `status`
- `suggestions`
- `topicDetails`

The `part` parameter requires you to select the resource components that your application actually uses. This:
- Reduces latency by preventing the API server from spending time retrieving metadata fields that your application doesn't use.
- Reduces bandwidth usage by reducing (or eliminating) the amount of unnecessary data that your application might retrieve.

### How to use the `fields` parameter

The `fields` parameter filters the API response so that the response only includes a specific set of fields. The `fields` parameter lets you remove nested properties from an API response and thereby further reduce your bandwidth usage.

Supported syntax for the `fields` parameter (loosely based on XPath syntax):
- Use a comma-separated list (`fields=a,b`) to select multiple fields.
- Use an asterisk (`fields=*`) as a wildcard to identify all fields.
- Use parentheses (`fields=a(b,c)`) to specify a group of nested properties.
- Use a forward slash (`fields=a/b`) to identify a nested property.

### Sample partial requests

**Example 1 URL:**
```
https://www.googleapis.com/youtube/v3/videos?id=7lCDEYXw3mM&key=YOUR_API_KEY&part=snippet,contentDetails,statistics,status
```

**Example 1 API response:**
```json
{
  "kind": "youtube#videoListResponse",
  "etag": "\"UCBpFjp2h75_b92t44sqraUcyu0/sDAlsG9NGKfr6v5AlPZKSEZdtqA\"",
  "videos": [
    {
      "id": "7lCDEYXw3mM",
      "kind": "youtube#video",
      "etag": "\"UCBpFjp2h75_b92t44sqraUcyu0/iYynQR8AtacsFUwWmrVaw4Smb_Q\"",
      "snippet": {
        "publishedAt": "2012-06-20T22:45:24.000Z",
        "channelId": "UC_x5XG1OV2P6uZZ5FSM9Ttw",
        "title": "Google I/O 101: Q&A On Using Google APIs",
        "description": "Antonio Fuentes speaks to us and takes questions on working with Google APIs and OAuth 2.0.",
        "thumbnails": {
          "default": { "url": "https://i.ytimg.com/vi/7lCDEYXw3mM/default.jpg" },
          "medium": { "url": "https://i.ytimg.com/vi/7lCDEYXw3mM/mqdefault.jpg" },
          "high": { "url": "https://i.ytimg.com/vi/7lCDEYXw3mM/hqdefault.jpg" }
        },
        "categoryId": "28"
      },
      "contentDetails": {
        "duration": "PT15M51S",
        "aspectRatio": "RATIO_16_9"
      },
      "statistics": {
        "viewCount": "3057",
        "likeCount": "25",
        "dislikeCount": "0",
        "favoriteCount": "17",
        "commentCount": "12"
      },
      "status": {
        "uploadStatus": "STATUS_PROCESSED",
        "privacyStatus": "PRIVACY_PUBLIC"
      }
    }
  ]
}
```

## Optimizing performance

### Using ETags

ETags, a standard part of the HTTP protocol, allow applications to refer to a specific version of a particular API resource.

- **Caching and conditional retrieval** – Your application can cache API resources and their ETags. Then, when your application requests a stored resource again, it specifies the ETag associated with that resource. If the resource has changed, the API returns the modified resource and the ETag associated with that version. If the resource has not changed, the API returns an HTTP 304 response (`Not Modified`).
- **Protecting against inadvertent overwrites of changes** – ETags help to ensure that multiple API clients don't inadvertently overwrite each other's changes. When updating or deleting a resource, your application can specify the resource's ETag. If the ETag doesn't match the most recent version of that resource, then the API request fails.

The Google APIs Client Library for JavaScript supports `If-Match` and `If-None-Match` HTTP request headers, thereby enabling ETags to work within the context of normal browser caching.

### Using gzip

You can reduce the bandwidth needed for each API response by enabling gzip compression.

To receive a gzip-encoded response you must do two things:
1. Set the `Accept-Encoding` HTTP request header to `gzip`.
2. Modify your user agent to contain the string `gzip`.

Sample HTTP headers:
```
Accept-Encoding: gzip
User-Agent: my program (gzip)
```

*Last updated 2026-02-12 UTC.*
