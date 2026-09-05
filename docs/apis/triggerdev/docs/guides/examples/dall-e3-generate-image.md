---
source: https://trigger.dev/docs/guides/examples/dall-e3-generate-image
scraped: 2026-02-28
---

# Generate an Image Using DALL·E 3

## Overview

This guide demonstrates integrating Trigger.dev with OpenAI's APIs to reliably generate both text and images. The example showcases built-in resilience features including automatic retry logic (up to 3 attempts), error handling to prevent timeouts, and API call monitoring.

## Key Implementation Details

The task accepts a theme and description, then:
- Generates text content using GPT-4o
- Creates an image via DALL·E 3
- Includes error handling with automatic retries

### Configuration Features

- **Retry Strategy**: "Retry up to 3 times" with configurable maximum attempts
- **Error Handling**: Validates API responses and throws recoverable errors
- **API Integration**: Uses OpenAI's official SDK with environment-based API key management

## Testing Payload

Example input for dashboard testing:

```json
{
  "theme": "A beautiful sunset",
  "description": "A sunset over the ocean with a tiny yacht in the distance."
}
```

This configuration demonstrates how the task generates complementary visual and textual content based on simple descriptive parameters.
