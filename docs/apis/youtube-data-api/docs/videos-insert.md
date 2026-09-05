# Videos: insert
**Source:** https://developers.google.com/youtube/v3/docs/videos/insert
**Date:** 2026-03-01
---

## Overview

Uploads a video to YouTube and optionally sets the video's metadata.

**Important:** All videos uploaded via the `videos.insert` endpoint from unverified API projects created after 28 July 2020 will be restricted to private viewing mode. To lift this restriction, each API project must undergo an audit to verify compliance with the Terms of Service.

This method supports media upload. Uploaded files must conform to these constraints:
- **Maximum file size:** 256GB
- **Accepted Media MIME types:** `video/*`, `application/octet-stream`

**Quota impact:** A call to this method has a quota cost of **100 units**.

## HTTP Request

```
POST https://www.googleapis.com/upload/youtube/v3/videos
```

## Authorization

This request requires authorization with at least one of the following scopes:

- `https://www.googleapis.com/auth/youtube.upload`
- `https://www.googleapis.com/auth/youtube`
- `https://www.googleapis.com/auth/youtubepartner`
- `https://www.googleapis.com/auth/youtube.force-ssl`

## Parameters

### Required parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `part` | string | Identifies the properties that the write operation will set as well as the properties that the API response will include. Valid part names: `contentDetails`, `fileDetails`, `id`, `liveStreamingDetails`, `localizations`, `paidProductPlacementDetails`, `player`, `processingDetails`, `recordingDetails`, `snippet`, `statistics`, `status`, `suggestions`, `topicDetails` |

### Optional parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `notifySubscribers` | boolean | Indicates whether YouTube should send a notification about the new video to users who subscribe to the video's channel. Default value is `True`. |
| `onBehalfOfContentOwner` | string | For YouTube content partners only. The parameter indicates that the request's authorization credentials identify a YouTube CMS user who is acting on behalf of the content owner specified in the parameter value. |
| `onBehalfOfContentOwnerChannel` | string | For YouTube content partners only. Specifies the YouTube channel ID of the channel to which a video is being added. Required when `onBehalfOfContentOwner` is specified. |

## Request body

Provide a `video` resource in the request body. You can set values for these properties:

- `snippet.title`
- `snippet.description`
- `snippet.tags[]`
- `snippet.categoryId`
- `snippet.defaultLanguage`
- `localizations.(key)`
- `localizations.(key).title`
- `localizations.(key).description`
- `status.embeddable`
- `status.license`
- `status.privacyStatus`
- `status.publicStatsViewable`
- `status.publishAt`
- `status.selfDeclaredMadeForKids`
- `status.containsSyntheticMedia`
- `recordingDetails.recordingDate`

## Response

If successful, this method returns a `video` resource in the response body.

## Common use case

Insert a video with its privacy status set to `private`. The `id`, `snippet.title`, and `snippet.categoryId` properties are all required, and all other properties are optional.

## Code samples

### Go

```go
package main

import (
  "flag"
  "fmt"
  "log"
  "os"
  "strings"
  "google.golang.org/api/youtube/v3"
)

var (
  filename    = flag.String("filename", "", "Name of video file to upload")
  title       = flag.String("title", "Test Title", "Video title")
  description = flag.String("description", "Test Description", "Video description")
  category    = flag.String("category", "22", "Video category")
  keywords    = flag.String("keywords", "", "Comma separated list of video keywords")
  privacy     = flag.String("privacy", "unlisted", "Video privacy status")
)

func main() {
  flag.Parse()
  // ... OAuth2 setup and API call omitted for brevity
  upload := &youtube.Video{
    Snippet: &youtube.VideoSnippet{
      Title:       *title,
      Description: *description,
      CategoryId:  *category,
    },
    Status: &youtube.VideoStatus{PrivacyStatus: *privacy},
  }
  if strings.Trim(*keywords, "") != "" {
    upload.Snippet.Tags = strings.Split(*keywords, ",")
  }
  call := service.Videos.Insert([]string{"snippet", "status"}, upload)
  file, err := os.Open(*filename)
  if err != nil {
    log.Fatalf("Error opening %v: %v", *filename, err)
  }
  defer file.Close()
  response, err := call.Media(file).Do()
  if err != nil {
    log.Fatalf("Error making YouTube API call: %v", err)
  }
  fmt.Printf("Upload successful! Video ID: %v\n", response.Id)
}
```
