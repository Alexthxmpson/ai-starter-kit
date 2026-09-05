# Resumable Uploads
**Source:** https://developers.google.com/youtube/v3/guides/using_resumable_upload_protocol
**Note:** Original URL in task list (https://developers.google.com/youtube/v3/guides/resumable_uploads) returned 404. Correct URL found via site navigation.
**Date:** 2026-03-01
---

## Overview

You can upload videos more reliably by using the resumable upload protocol for Google APIs. This protocol lets you resume an upload operation after a network interruption or other transmission failure, saving time and bandwidth in the event of network failures.

Using resumable uploads is especially useful in any of the following cases:
- You are transferring large files.
- The likelihood of a network interruption is high.
- Uploads are originating from a device with a low-bandwidth or unstable Internet connection, such as a mobile device.

This guide explains the sequence of HTTP requests that an application makes to upload videos using a resumable uploading process. This guide is primarily intended for developers who cannot use the Google API client libraries, some of which provide native support for resumable uploads.

## Step 1 - Start a resumable session

To start a resumable video upload, send a POST request to the following URL:

```
https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&part=PARTS
```

Set the body of the request to a `video` resource. Also set the following HTTP request headers:

| Header | Description |
|--------|-------------|
| `Authorization` | The authorization token for the request. |
| `Content-Length` | The number of bytes provided in the body of the request. Not needed if using chunked transfer encoding. |
| `Content-Type` | Set the value to `application/json; charset=UTF-8`. |
| `X-Upload-Content-Length` | The number of bytes that will be uploaded in subsequent requests. Set this value to the size of the file you are uploading. |
| `X-Upload-Content-Type` | The MIME type of the file that you are uploading. You can upload files with any video MIME type (`video/*`) or a MIME type of `application/octet-stream`. |

**Example request:**
```
POST /upload/youtube/v3/videos?uploadType=resumable&part=snippet,status,contentDetails HTTP/1.1
Host: www.googleapis.com
Authorization: Bearer AUTH_TOKEN
Content-Length: 278
Content-Type: application/json; charset=UTF-8
X-Upload-Content-Length: 3000000
X-Upload-Content-Type: video/*

{
  "snippet": {
    "title": "My video title",
    "description": "This is a description of my video",
    "tags": ["cool", "video", "more keywords"],
    "categoryId": 22
  },
  "status": {
    "privacyStatus": "public",
    "embeddable": True,
    "license": "youtube"
  }
}
```

## Step 2 - Save the resumable session URI

If your request succeeds, the API server will respond with a `200` (`OK`) HTTP status code, and the response will include a `Location` HTTP header that specifies the URI for the resumable session. This is the URI that you will use to upload your video file.

**Example API response:**
```
HTTP/1.1 200 OK
Location: https://www.googleapis.com/upload/youtube/v3/videos?uploadType=resumable&upload_id=xa298sd_f&part=snippet,status,contentDetails
Content-Length: 0
```

## Step 3 - Upload the video file

After extracting the session URI from the API response, you then need to upload the actual video file content to that location. The body of the request is the binary file content for the video that you are uploading.

```
PUT UPLOAD_URL HTTP/1.1
Authorization: Bearer AUTH_TOKEN
Content-Length: CONTENT_LENGTH
Content-Type: CONTENT_TYPE

BINARY_FILE_DATA
```

**Request headers:**

| Header | Description |
|--------|-------------|
| `Authorization` | The authorization token for the request. |
| `Content-Length` | The size of the file that you are uploading. This value should be the same as the value of the `X-Upload-Content-Length` HTTP request header in step 1. |
| `Content-Type` | The MIME type of the file that you are uploading. Same as `X-Upload-Content-Type` from step 1. |

## Step 4 - Complete the upload process

Your request will lead to one of the following scenarios:

**Your upload is successful:**
The API server responds with an HTTP `201` (`Created`) response code. The body of the response is the `video` resource that you created.

**Your upload did not succeed, but can be resumed:**
You should be able to resume an upload in either of the following cases:
- Your request is interrupted because the connection between your application and the API server is lost.
- The API response specifies any of the following `5xx` response codes (use exponential backoff strategy):
  - `500` – Internal Server Error
  - `502` – Bad Gateway
  - `503` – Service Unavailable
  - `504` – Gateway Timeout

Each resumable session URI has a finite lifetime and eventually expires. Start a resumable upload as soon as you obtain the session URI and resume an interrupted upload shortly after the interruption occurs.

**Your upload failed permanently:**
For a failed upload, the response contains an error response that helps to explain the cause of the failure. For an upload that fails permanently, the API response will have a `4xx` response code or a `5xx` response code other than the ones listed above.

If you send a request with an expired session URI, the server returns a `404` HTTP response code (`Not Found`). In this case, you will need to start a new resumable upload, obtain a new session URI, and start the upload from the beginning using the new URI.

### Step 4.1: Check the status of an upload

To check the status of an interrupted resumable upload, send an empty PUT request to the upload URL that you retrieved in step 2.

```
PUT UPLOAD_URL HTTP/1.1
Authorization: Bearer AUTH_TOKEN
Content-Length: 0
Content-Range: bytes */CONTENT_LENGTH
```

### Step 4.2: Process the API response

If the upload already completed, the API will return the same response that it sent when the upload originally completed.

However, if the upload was interrupted or is still in progress, the API response will have an HTTP `308` (`Resume Incomplete`) response code. In the response, the `Range` header specifies how many bytes of the file have already been successfully uploaded.

- The header value is indexed from zero, so a `Range` header value of `0-999999` indicates that the first 1,000,000 bytes of the file have been received.
- If your request did not have a `Range` header, the entire file must be re-uploaded.

### Step 4.3: Resume the upload

To resume the upload, send a PUT request to the resumable session URI. Set the `Content-Range` header to indicate which portion of the file you are sending:

```
PUT UPLOAD_URL HTTP/1.1
Authorization: Bearer AUTH_TOKEN
Content-Length: REMAINING_BYTES
Content-Range: bytes FIRST_BYTE-LAST_BYTE/TOTAL_LENGTH

BINARY_FILE_DATA
```

Where `FIRST_BYTE` is the next byte number after the last byte received by the server (as indicated in the `Range` header from step 4.2).
