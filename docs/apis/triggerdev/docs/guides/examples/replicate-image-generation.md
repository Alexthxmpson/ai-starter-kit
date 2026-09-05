---
source: https://trigger.dev/docs/guides/examples/replicate-image-generation
scraped: 2026-02-28
---

# Image-to-Image Generation Using Replicate and Nano-Banana

## Overview

This guide demonstrates implementing image generation from source URLs by leveraging Replicate's nano-banana model with Trigger.dev's capabilities.

## Implementation Details

The example code establishes connections to both Replicate and AWS R2 (Cloudflare's S3-compatible storage). The workflow:

1. Accepts a prompt and image URL as input parameters
2. Creates a webhook token with a 10-minute timeout for asynchronous processing
3. Submits the request to the Replicate API with structured parameters
4. Waits for completion via webhook callback
5. Downloads the generated image and converts it to a buffer
6. Uploads the result to R2 storage with appropriate metadata
7. Returns the public URL along with original input details

## Required Configuration

Seven environment variables must be configured:

- `TRIGGER_SECRET_KEY` - Authentication credential for Trigger.dev
- `REPLICATE_API_TOKEN` - API access for Replicate services
- `R2_ENDPOINT` - Cloudflare R2 storage endpoint
- `R2_ACCESS_KEY_ID` - R2 authentication credential
- `R2_SECRET_ACCESS_KEY` - R2 authentication credential
- `R2_BUCKET` - Target storage bucket name
- `R2_PUBLIC_URL` - Base URL for publicly accessible files
