# Anthropic (Claude) API — Technical Documentation

**Source:** https://docs.anthropic.com/en/api/getting-started
**Date documented:** 2026-02-27

---

## Table of Contents

1. [Authentication](#authentication)
2. [Base URL](#base-url)
3. [Available Models](#available-models)
4. [Core Endpoint: POST /messages](#core-endpoint-post-messages)
5. [Request Parameters](#request-parameters)
6. [Response Format](#response-format)
7. [Tool Use (Function Calling)](#tool-use-function-calling)
8. [Vision (Image Input)](#vision-image-input)
9. [Streaming Responses](#streaming-responses)
10. [Batch API](#batch-api)
11. [Rate Limits by Tier](#rate-limits-by-tier)
12. [Context Windows and Pricing](#context-windows-and-pricing)
13. [Python SDK](#python-sdk)
14. [Node.js SDK](#nodejs-sdk)
15. [Claude Code CLI](#claude-code-cli)
16. [Error Handling](#error-handling)

---

## Authentication

All API requests require an API key passed via the `x-api-key` header. The `anthropic-version` header is also required on every request.

```http
x-api-key: YOUR_ANTHROPIC_API_KEY
anthropic-version: 2023-06-01
content-type: application/json
```

Store your key in the `ANTHROPIC_API_KEY` environment variable. Never hardcode it in source code.

```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```

Obtain your API key from the Anthropic Console at https://console.anthropic.com.

---

## Base URL

```
https://api.anthropic.com/v1
```

---

## Available Models

| Model ID                        | Context Window | Best For                                    |
|---------------------------------|----------------|---------------------------------------------|
| `claude-opus-4-6`               | 200,000 tokens | Complex reasoning, agentic tasks            |
| `claude-sonnet-4-6`             | 200,000 tokens | Balanced performance and speed              |
| `claude-haiku-4-5-20251001`     | 200,000 tokens | Fast, lightweight, high-volume tasks        |
| `claude-3-5-sonnet-20241022`    | 200,000 tokens | Previous-gen Sonnet, still widely used      |
| `claude-3-opus-20240229`        | 200,000 tokens | Previous-gen Opus                           |
| `claude-3-haiku-20240307`       | 200,000 tokens | Previous-gen Haiku                          |

Always use the full versioned model ID string in API requests. Using `claude-opus-4-6` without a date suffix points to the latest Opus 4.6 release.

---

## Core Endpoint: POST /messages

```
POST https://api.anthropic.com/v1/messages
```

This is the primary endpoint for all text generation tasks. It accepts a conversation history and returns the model's next response.

### Minimal Working Request (curl)

```bash
curl https://api.anthropic.com/v1/messages \
  --header "x-api-key: $ANTHROPIC_API_KEY" \
  --header "anthropic-version: 2023-06-01" \
  --header "content-type: application/json" \
  --data '{
    "model": "claude-sonnet-4-6",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Hello, Claude."}
    ]
  }'
```

---

## Request Parameters

### Required Parameters

| Parameter    | Type    | Description                                                                  |
|--------------|---------|------------------------------------------------------------------------------|
| `model`      | string  | Model ID to use (see Available Models table above)                           |
| `max_tokens` | integer | Maximum number of output tokens to generate                                  |
| `messages`   | array   | Conversation history as an array of role/content message objects             |

### Messages Array Structure

Each message object requires a `role` and `content`:

```json
"messages": [
  {"role": "user",      "content": "What is the capital of France?"},
  {"role": "assistant", "content": "The capital of France is Paris."},
  {"role": "user",      "content": "What is its population?"}
]
```

- Roles must be `"user"` or `"assistant"` and must alternate
- The first message must always be from `"user"`
- `content` can be a plain string or an array of content blocks (for images, tool results, etc.)

### Optional Parameters

| Parameter       | Type             | Description                                                                 |
|-----------------|------------------|-----------------------------------------------------------------------------|
| `system`        | string or array  | System prompt — sets Claude's persona and behavioral instructions            |
| `temperature`   | float (0.0–1.0)  | Randomness of output; lower = more deterministic (default: 1.0)             |
| `top_p`         | float (0.0–1.0)  | Nucleus sampling threshold; mutually exclusive with `temperature`            |
| `top_k`         | integer          | Limits each token selection to the top-k most likely candidates              |
| `stop_sequences`| array of strings | Custom sequences that will cause the model to stop generating                |
| `stream`        | boolean          | If `true`, streams response as Server-Sent Events                            |
| `tools`         | array            | Tool definitions for function calling                                        |
| `tool_choice`   | object           | Controls tool usage: `auto`, `any`, `tool` (specific), or `none`            |
| `metadata`      | object           | Optional metadata, e.g. `{"user_id": "user_123"}` for tracking              |

### Full Request Example

```json
{
  "model": "claude-sonnet-4-6",
  "max_tokens": 2048,
  "system": "You are a helpful assistant specializing in data analysis.",
  "messages": [
    {"role": "user", "content": "Summarize the key trends in this dataset: [data here]"}
  ],
  "temperature": 0.3,
  "stop_sequences": ["</answer>"]
}
```

---

## Response Format

A successful response (HTTP 200) returns:

```json
{
  "id": "msg_01XFDUDYJgAACzvnptvVoYEL",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "The capital of France is Paris."
    }
  ],
  "model": "claude-sonnet-4-6",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 25,
    "output_tokens": 10
  }
}
```

| Field          | Description                                                                             |
|----------------|-----------------------------------------------------------------------------------------|
| `id`           | Unique message identifier                                                               |
| `content`      | Array of content blocks; each block has a `type` (`text`, `tool_use`, etc.) and data   |
| `stop_reason`  | Why generation stopped: `end_turn`, `max_tokens`, `stop_sequence`, or `tool_use`        |
| `usage`        | Token counts for billing — `input_tokens` and `output_tokens`                           |

---

## Tool Use (Function Calling)

Tool use lets Claude call external functions you define. Claude signals when it wants to use a tool via a `tool_use` content block. Your application executes the tool and returns the result via a `tool_result` message.

### 1. Define Tools in the Request

```json
{
  "model": "claude-sonnet-4-6",
  "max_tokens": 1024,
  "tools": [
    {
      "name": "get_weather",
      "description": "Get the current weather for a city. Returns temperature and conditions.",
      "input_schema": {
        "type": "object",
        "properties": {
          "city": {"type": "string", "description": "City name, e.g. 'Amsterdam'"}
        },
        "required": ["city"]
      }
    }
  ],
  "messages": [
    {"role": "user", "content": "What's the weather in Amsterdam?"}
  ]
}
```

### 2. Claude Responds with a Tool Call

When Claude decides to use a tool, `stop_reason` is `"tool_use"` and the content array includes a `tool_use` block:

```json
{
  "stop_reason": "tool_use",
  "content": [
    {"type": "text", "text": "Let me check that for you."},
    {
      "type": "tool_use",
      "id": "toolu_01A09q90qw90lq917835lq9",
      "name": "get_weather",
      "input": {"city": "Amsterdam"}
    }
  ]
}
```

### 3. Return the Tool Result

Execute the tool locally, then send the result back as a `tool_result` content block in a new `user` message:

```json
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01A09q90qw90lq917835lq9",
      "content": "Temperature: 12°C, Conditions: Partly cloudy"
    }
  ]
}
```

### Agentic Loop Pattern

```
1. Send user message + tools array
2. Claude responds with tool_use block  (stop_reason: "tool_use")
3. Execute the tool in your application
4. Append assistant response and tool_result to messages
5. Send updated messages array back to Claude
6. Claude responds with final answer    (stop_reason: "end_turn")
   → Repeat steps 2–6 if Claude calls more tools
```

---

## Vision (Image Input)

Pass images directly in the `content` array as image blocks alongside text blocks.

### Base64 Image

```json
{
  "role": "user",
  "content": [
    {
      "type": "image",
      "source": {
        "type": "base64",
        "media_type": "image/jpeg",
        "data": "/9j/4AAQSkZJRgAB..."
      }
    },
    {"type": "text", "text": "What is in this image?"}
  ]
}
```

### URL Image

```json
{
  "type": "image",
  "source": {
    "type": "url",
    "url": "https://example.com/chart.png"
  }
}
```

Supported formats: `image/jpeg`, `image/png`, `image/gif`, `image/webp`. Up to 100 images per request. Maximum image size via base64: 5 MB.

---

## Streaming Responses

Set `"stream": true` to receive the response as Server-Sent Events (SSE) rather than waiting for the full response.

```bash
curl https://api.anthropic.com/v1/messages \
  --header "x-api-key: $ANTHROPIC_API_KEY" \
  --header "anthropic-version: 2023-06-01" \
  --header "content-type: application/json" \
  --data '{"model":"claude-sonnet-4-6","max_tokens":512,"stream":true,"messages":[{"role":"user","content":"Tell me a story."}]}'
```

### SSE Event Sequence

| Event Type            | Description                                         |
|-----------------------|-----------------------------------------------------|
| `message_start`       | Message metadata (model, id, usage starts)          |
| `content_block_start` | A new content block begins                          |
| `content_block_delta` | Incremental text chunk via `text_delta` type        |
| `content_block_stop`  | A content block ends                                |
| `message_delta`       | Final stop_reason and output token count            |
| `message_stop`        | Stream is complete                                  |

Each `content_block_delta` event delivers a `text_delta` with a `text` field containing the next chunk of generated text.

---

## Batch API

Process up to 10,000 requests asynchronously in a single batch at a 50% cost discount. Most batches complete within 1 hour; maximum processing time is 24 hours.

### Create a Batch

```
POST https://api.anthropic.com/v1/messages/batches
```

```json
{
  "requests": [
    {
      "custom_id": "req-001",
      "params": {
        "model": "claude-haiku-4-5-20251001",
        "max_tokens": 256,
        "messages": [{"role": "user", "content": "Summarize: ..."}]
      }
    },
    {
      "custom_id": "req-002",
      "params": {
        "model": "claude-haiku-4-5-20251001",
        "max_tokens": 256,
        "messages": [{"role": "user", "content": "Translate to French: ..."}]
      }
    }
  ]
}
```

### Poll for Completion

```
GET https://api.anthropic.com/v1/messages/batches/{batch_id}
```

Poll until `processing_status` is `"ended"`.

### Retrieve Results

```
GET https://api.anthropic.com/v1/messages/batches/{batch_id}/results
```

Returns JSONL — one JSON object per line. Each line has a `custom_id` matching your request and a `result` containing the full message response. Results are NOT guaranteed to be in submission order; use `custom_id` to match them.

---

## Rate Limits by Tier

Anthropic uses a 4-tier system based on cumulative spend. Limits apply per model family and reset continuously.

| Tier | Requirement           | RPM   | ITPM (Sonnet) | Monthly Cap |
|------|-----------------------|-------|---------------|-------------|
| 1    | $5 deposit            | 50    | 50,000        | $100        |
| 2    | $40 cumulative spend  | 1,000 | 400,000       | $500        |
| 3    | $200 cumulative spend | 2,000 | 800,000       | $1,000      |
| 4    | $400 cumulative spend | 4,000 | 2,000,000     | Unlimited   |

RPM = Requests Per Minute, ITPM = Input Tokens Per Minute.

Rate limit headers are returned with every response:

```
anthropic-ratelimit-requests-limit: 50
anthropic-ratelimit-requests-remaining: 49
anthropic-ratelimit-tokens-limit: 50000
anthropic-ratelimit-tokens-remaining: 48500
anthropic-ratelimit-tokens-reset: 2026-02-27T10:00:01Z
```

---

## Context Windows and Pricing

All current Claude models have a 200,000-token context window. A 1M-token context window is available in beta for Opus 4.6, Sonnet 4.6, and Sonnet 4.5 (requires Tier 4 or enterprise agreement).

### Cost Estimates (Per Million Tokens)

| Model                       | Input   | Output  |
|-----------------------------|---------|---------|
| `claude-opus-4-6`           | $15.00  | $75.00  |
| `claude-sonnet-4-6`         | $3.00   | $15.00  |
| `claude-haiku-4-5-20251001` | $1.00   | $5.00   |

Batch API requests are 50% cheaper than standard pricing. Prompt caching reduces repeated input costs by up to 90%. Check https://console.anthropic.com for current pricing.

---

## Python SDK

```bash
pip install anthropic
```

```python
import anthropic

# Reads ANTHROPIC_API_KEY from environment automatically
client = anthropic.Anthropic()

# Basic message
message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system="You are a helpful assistant.",
    messages=[
        {"role": "user", "content": "Write a Python function to reverse a string."}
    ]
)

print(message.content[0].text)
print(f"Tokens used: {message.usage.input_tokens} in, {message.usage.output_tokens} out")
```

### Streaming (Python)

```python
with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=512,
    messages=[{"role": "user", "content": "Tell me a story."}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

### Batch API (Python)

```python
import time

batch = client.messages.batches.create(
    requests=[
        {
            "custom_id": f"item-{i}",
            "params": {
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 256,
                "messages": [{"role": "user", "content": f"Summarize: {text}"}]
            }
        }
        for i, text in enumerate(my_texts)
    ]
)

# Poll until complete
while batch.processing_status != "ended":
    time.sleep(60)
    batch = client.messages.batches.retrieve(batch.id)

# Retrieve results
for result in client.messages.batches.results(batch.id):
    print(f"{result.custom_id}: {result.result.message.content[0].text}")
```

---

## Node.js SDK

```bash
npm install @anthropic-ai/sdk
```

```javascript
import Anthropic from "@anthropic-ai/sdk";

// Reads ANTHROPIC_API_KEY from environment automatically
const client = new Anthropic();

// Basic message
const message = await client.messages.create({
  model: "claude-sonnet-4-6",
  max_tokens: 1024,
  messages: [{ role: "user", content: "Explain async/await in JavaScript." }],
});

console.log(message.content[0].text);
console.log(`Input tokens: ${message.usage.input_tokens}`);
```

### Streaming (Node.js)

```javascript
const stream = await client.messages.stream({
  model: "claude-sonnet-4-6",
  max_tokens: 512,
  messages: [{ role: "user", content: "Tell me a joke." }],
});

for await (const chunk of stream) {
  if (chunk.type === "content_block_delta" && chunk.delta.type === "text_delta") {
    process.stdout.write(chunk.delta.text);
  }
}
```

---

## Claude Code CLI

Claude Code is Anthropic's official CLI for interacting with Claude directly from the terminal.

```bash
# Interactive conversational session
claude

# Non-interactive one-shot prompt (returns output and exits)
claude -p "Refactor this function to use async/await"

# Pipe file content as input
cat myfile.py | claude -p "Review this code for bugs and suggest improvements"

# Continue the most recent conversation
claude --continue

# Resume a specific session by ID
claude --resume <session-id>
```

The CLI automatically reads `ANTHROPIC_API_KEY` from the environment. Useful for scripting, CI pipelines, and quick lookups without switching context.

---

## Error Handling

### HTTP Error Codes

| HTTP Status | Error Type              | Common Cause                                          |
|-------------|-------------------------|-------------------------------------------------------|
| 400         | `invalid_request_error` | Malformed JSON, missing required fields, invalid params|
| 401         | `authentication_error`  | Invalid or missing API key                            |
| 403         | `permission_error`      | Key lacks access to the requested model or feature    |
| 404         | `not_found_error`       | Unknown model ID or invalid batch ID                  |
| 429         | `rate_limit_error`      | Too many requests or too many tokens per minute       |
| 500         | `api_error`             | Unexpected server error on Anthropic's side           |
| 529         | `overloaded_error`      | API temporarily overloaded due to high traffic        |

### Error Response Body

```json
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "max_tokens: field required"
  }
}
```

### Exponential Backoff for Rate Limits

```python
import anthropic
import time

client = anthropic.Anthropic()

def call_with_retry(messages, model="claude-sonnet-4-6", max_retries=5):
    for attempt in range(max_retries):
        try:
            return client.messages.create(
                model=model,
                max_tokens=1024,
                messages=messages
            )
        except anthropic.RateLimitError:
            if attempt == max_retries - 1:
                raise
            wait = 2 ** attempt  # 1s, 2s, 4s, 8s, 16s
            print(f"Rate limited. Retrying in {wait}s...")
            time.sleep(wait)
```

Apply the same exponential backoff pattern for 529 overload errors.
