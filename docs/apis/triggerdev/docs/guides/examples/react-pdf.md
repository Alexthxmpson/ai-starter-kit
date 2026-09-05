---
source: https://trigger.dev/docs/guides/examples/react-pdf
scraped: 2026-02-28
---

# Generate a PDF using react-pdf and save it to R2

## Overview

This documentation demonstrates integrating Trigger.dev with react-pdf to create PDFs and store them in Cloudflare R2 object storage.

## Key Implementation Details

The example requires a `.tsx` file to leverage React components. The implementation uses:

- **react-pdf/renderer** - For PDF generation via React components
- **AWS SDK S3Client** - To interact with R2's S3-compatible API
- **Environment variables** - For R2 authentication credentials and endpoint configuration

## Core Workflow

The task accepts a text payload, renders it into an A4-sized PDF document, generates a timestamped filename, and uploads the resulting buffer to R2 storage. The filename follows a pattern of the input text (space-normalized) appended with the current timestamp.

## R2 Authentication Setup

The S3Client configuration requires:
- `region: "auto"`
- R2 endpoint URL
- Access key credentials
- Bucket name

All sensitive values should be stored as environment variables.

## Testing

The dashboard accepts test payloads in JSON format:

```json
{
  "text": "Hello, world!"
}
```

The task returns the bucket name and R2 key path for the uploaded file, enabling retrieval and sharing of the generated PDF.
