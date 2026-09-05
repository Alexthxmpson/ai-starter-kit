---
source: https://trigger.dev/docs/guides/examples/supabase-storage-upload
scraped: 2026-02-28
---

# Uploading Files to Supabase Storage

## Overview

The documentation explains how to upload files to Supabase Storage through Trigger.dev using two distinct approaches: the Supabase client library and the AWS S3 client.

## Method 1: Supabase Client

This approach uses the native Supabase JavaScript SDK. The process involves:

- Fetching video data from a provided URL
- Converting the response to a buffer
- Uploading directly to Supabase Storage with metadata

```ts
const { error } = await supabase.storage.from(bucket).upload(objectKey, videoBuffer, {
  contentType: "video/mp4",
  upsert: true,
});
```

To test, provide a `videoUrl` parameter in the dashboard.

## Method 2: AWS S3 Client

This alternative approach leverages Supabase's S3-compatible API:

- Initializes an S3 client with Supabase credentials and endpoint
- Fetches video content as an ArrayBuffer
- Uploads using the `PutObjectCommand`

### Required Environment Variables

- `SUPABASE_PROJECT_ID`
- `SUPABASE_REGION`
- `SUPABASE_ACCESS_KEY_ID`
- `SUPABASE_SECRET_ACCESS_KEY`

Both methods return the uploaded object key and bucket name upon successful completion.

## Related Resources

The documentation links to supplementary guides covering Supabase edge functions, database webhooks, and authentication patterns for Trigger.dev integration.
