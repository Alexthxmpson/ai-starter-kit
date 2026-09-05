---
source: https://trigger.dev/docs/guides/examples/resend-email-sequence
scraped: 2026-02-28
---

# Send a Sequence of Emails Using Resend

## Overview

This guide demonstrates how to implement a multi-day email sequence using Resend and Trigger.dev. The solution leverages two key features: retry logic for individual email operations and wait functionality to pause execution between messages.

## Key Features

**Retry Mechanism**: Each email send operation uses `retry.onThrow` with a maximum of 3 attempts. If an error occurs during sending, the specific email block retries rather than failing the entire task.

**Resource Efficiency**: The task uses `wait.for` to pause between emails. During these pauses, the task consumes no resources — a significant advantage for multi-day sequences.

## Implementation Details

The code structure includes:

- Initial email dispatch with error handling
- 3-day delay before the second email
- Second email with identical retry logic
- Pattern that can be repeated for additional messages

## Testing

To validate the task in the dashboard, use this test payload:

```json
{
  "userId": "123",
  "email": "<your-test-email>",
  "name": "Alice Testington"
}
```

Replace the email field with an actual test address before running.
