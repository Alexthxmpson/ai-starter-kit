# OpenAI API — Technical Documentation

**Source:** https://platform.openai.com/docs/api-reference/introduction | https://platform.openai.com/docs/models
**Date:** 2026-02-27

---

## Table of Contents

1. [Authentication](#authentication)
2. [Base URL & Headers](#base-url--headers)
3. [Chat Completions](#chat-completions)
4. [Assistants API](#assistants-api)
5. [Files API](#files-api)
6. [Embeddings](#embeddings)
7. [Images (DALL-E)](#images-dall-e)
8. [Audio (Whisper / TTS)](#audio-whisper--tts)
9. [Fine-Tuning](#fine-tuning)
10. [Moderation](#moderation)
11. [Models Reference](#models-reference)
12. [Rate Limits & Usage Tiers](#rate-limits--usage-tiers)
13. [Error Codes](#error-codes)
14. [Response Headers](#response-headers)

---

## Authentication

All requests require a Bearer token in the `Authorization` header.

```http
Authorization: Bearer sk-...YOUR_API_KEY...
```

Optionally, send an organization ID:

```http
OpenAI-Organization: org-...
OpenAI-Project: proj-...
```

**Environment variable convention:**

```bash
export OPENAI_API_KEY="sk-..."
```

---

## Base URL & Headers

```
Base URL: https://api.openai.com/v1
Content-Type: application/json
```

---

## Chat Completions

**Endpoint:** `POST /v1/chat/completions`

The primary endpoint for generating text. Supports streaming, function/tool calling, structured outputs, vision, and audio.

### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `model` | string | Yes | Model ID, e.g. `gpt-4o`, `o3`, `gpt-4.1` |
| `messages` | array | Yes | Array of message objects with `role` and `content` |
| `max_tokens` | integer | No | Max tokens to generate |
| `temperature` | float | No | 0.0–2.0. Controls randomness. Default: 1.0 |
| `top_p` | float | No | Nucleus sampling probability mass |
| `stream` | boolean | No | Stream responses via SSE. Default: false |
| `tools` | array | No | List of tool/function definitions |
| `tool_choice` | string/object | No | Controls tool selection: `"none"`, `"auto"`, `"required"` |
| `response_format` | object | No | `{"type": "json_object"}` or `{"type": "json_schema", ...}` |
| `n` | integer | No | Number of completions to generate. Default: 1 |
| `stop` | string/array | No | Stop sequences |
| `presence_penalty` | float | No | -2.0 to 2.0. Penalizes new topics |
| `frequency_penalty` | float | No | -2.0 to 2.0. Penalizes repetition |
| `logit_bias` | map | No | Adjust token probabilities |
| `user` | string | No | End-user identifier for abuse monitoring |
| `seed` | integer | No | For deterministic outputs (best effort) |

### Message Roles

| Role | Description |
|------|-------------|
| `system` | Sets assistant behavior and context |
| `user` | Human turn input |
| `assistant` | Model's prior response (for multi-turn) |
| `tool` | Tool/function call result |

### Request Example (Basic)

```json
POST https://api.openai.com/v1/chat/completions
Authorization: Bearer sk-...
Content-Type: application/json

{
  "model": "gpt-4o",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "What is the capital of France?"}
  ],
  "temperature": 0.7,
  "max_tokens": 256
}
```

### Response Example

```json
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion",
  "created": 1740000000,
  "model": "gpt-4o-2024-11-20",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "The capital of France is Paris."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 28,
    "completion_tokens": 9,
    "total_tokens": 37
  }
}
```

### Finish Reasons

| Value | Meaning |
|-------|---------|
| `stop` | Natural end or stop sequence hit |
| `length` | `max_tokens` reached |
| `tool_calls` | Model wants to call a tool |
| `content_filter` | Content blocked by moderation |
| `null` | Streaming, not yet complete |

### Tool Calling Example

```json
{
  "model": "gpt-4o",
  "messages": [{"role": "user", "content": "What's the weather in London?"}],
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get current weather for a city",
        "parameters": {
          "type": "object",
          "properties": {
            "city": {"type": "string"}
          },
          "required": ["city"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}
```

### Streaming Example (Python)

```python
from openai import OpenAI
client = OpenAI()

stream = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Tell me a story."}],
    stream=True,
)
for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="")
```

### Vision (Image Input)

```json
{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "user",
      "content": [
        {"type": "text", "text": "What's in this image?"},
        {
          "type": "image_url",
          "image_url": {
            "url": "https://example.com/image.png",
            "detail": "high"
          }
        }
      ]
    }
  ]
}
```

Image detail levels: `"low"` (85 tokens), `"high"` (tiles-based cost), `"auto"`.

---

## Assistants API

**Endpoint base:** `/v1/assistants`, `/v1/threads`, `/v1/runs`

A stateful API for building AI agents with persistent threads, tool use, and file access.

### Key Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v1/assistants` | Create assistant |
| GET | `/v1/assistants/{id}` | Retrieve assistant |
| POST | `/v1/threads` | Create thread |
| POST | `/v1/threads/{thread_id}/messages` | Add message to thread |
| POST | `/v1/threads/{thread_id}/runs` | Run assistant on thread |
| GET | `/v1/threads/{thread_id}/runs/{run_id}` | Get run status |
| GET | `/v1/threads/{thread_id}/messages` | List messages |
| DELETE | `/v1/threads/{thread_id}/messages/{msg_id}` | Delete a message |

### Built-in Tools

| Tool | Description |
|------|-------------|
| `code_interpreter` | Runs Python, generates files/charts |
| `file_search` | Searches up to 10,000 files per assistant with vector store |

### Create Assistant Example

```json
POST /v1/assistants
{
  "model": "gpt-4o",
  "name": "Data Analyst",
  "instructions": "Analyze CSV data and produce summaries.",
  "tools": [{"type": "code_interpreter"}, {"type": "file_search"}],
  "tool_resources": {
    "file_search": {
      "vector_store_ids": ["vs_abc123"]
    }
  }
}
```

### Run Lifecycle States

`queued` → `in_progress` → `requires_action` (tool call) → `completed` | `failed` | `expired` | `cancelled`

---

## Files API

**Endpoint:** `POST /v1/files`, `GET /v1/files`, `DELETE /v1/files/{id}`

Upload files for use with Assistants, Fine-tuning, or Batch API.

### Supported Purposes

| Purpose | Description |
|---------|-------------|
| `assistants` | For use with the Assistants API |
| `assistants_output` | Output files from Assistants |
| `batch` | Input for Batch API (.jsonl, max 200 MB) |
| `batch_output` | Batch results |
| `fine-tune` | Training data (.jsonl only) |
| `fine-tune-results` | Results from fine-tuning |
| `vision` | Images for vision tasks |
| `user_data` | General user uploads |

### Upload Example

```bash
curl https://api.openai.com/v1/files \
  -H "Authorization: Bearer sk-..." \
  -F purpose="fine-tune" \
  -F file="@training_data.jsonl"
```

### Response

```json
{
  "id": "file-abc123",
  "object": "file",
  "bytes": 140289,
  "created_at": 1740000000,
  "filename": "training_data.jsonl",
  "purpose": "fine-tune"
}
```

---

## Embeddings

**Endpoint:** `POST /v1/embeddings`

Converts text into a numerical vector for semantic search, clustering, and similarity.

### Available Models

| Model | Dimensions | Max Input Tokens | Cost |
|-------|-----------|-----------------|------|
| `text-embedding-3-large` | 3072 (default) | 8192 | $0.13/1M tokens |
| `text-embedding-3-small` | 1536 (default) | 8192 | $0.02/1M tokens |
| `text-embedding-ada-002` | 1536 | 8192 | $0.10/1M tokens (legacy) |

Note: `text-embedding-3-*` models support dimension reduction via the `dimensions` parameter.

### Request Example

```json
POST /v1/embeddings
{
  "model": "text-embedding-3-small",
  "input": "The quick brown fox jumps over the lazy dog",
  "encoding_format": "float"
}
```

### Response Example

```json
{
  "object": "list",
  "data": [
    {
      "object": "embedding",
      "embedding": [0.0023064255, -0.009327292, ...],
      "index": 0
    }
  ],
  "model": "text-embedding-3-small",
  "usage": {"prompt_tokens": 9, "total_tokens": 9}
}
```

---

## Images (DALL-E)

**Endpoint:** `POST /v1/images/generations`, `POST /v1/images/edits`, `POST /v1/images/variations`

### Models

| Model | Max Resolution | Notes |
|-------|---------------|-------|
| `dall-e-3` | 1024×1024, 1792×1024, 1024×1792 | Highest quality |
| `dall-e-2` | 256×256 to 1024×1024 | Lower cost, supports edits/variations |

### Generate Request

```json
POST /v1/images/generations
{
  "model": "dall-e-3",
  "prompt": "A photorealistic image of a red fox in a snowy forest",
  "n": 1,
  "size": "1024x1024",
  "quality": "hd",
  "style": "vivid",
  "response_format": "url"
}
```

### Parameters

| Parameter | Values | Notes |
|-----------|--------|-------|
| `n` | 1 (dall-e-3), 1–10 (dall-e-2) | Number of images |
| `size` | See model above | Image dimensions |
| `quality` | `standard`, `hd` | DALL-E 3 only |
| `style` | `vivid`, `natural` | DALL-E 3 only |
| `response_format` | `url`, `b64_json` | URL expires after 1 hour |

---

## Audio (Whisper / TTS)

### Transcription (Whisper)

**Endpoint:** `POST /v1/audio/transcriptions`

| Model | Notes |
|-------|-------|
| `whisper-1` | Classic Whisper, multilingual |
| `gpt-4o-transcribe` | GPT-4o-based, high accuracy |
| `gpt-4o-mini-transcribe` | Faster, cheaper transcription |

```bash
curl https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer sk-..." \
  -F model="gpt-4o-transcribe" \
  -F file="@audio.mp3" \
  -F response_format="json"
```

Supported formats: `mp3`, `mp4`, `mpeg`, `mpga`, `m4a`, `wav`, `webm`. Max file size: 25 MB.

### Translation (Whisper)

**Endpoint:** `POST /v1/audio/translations`
Translates audio to English only. Uses `whisper-1`.

### Text-to-Speech

**Endpoint:** `POST /v1/audio/speech`

| Model | Notes |
|-------|-------|
| `tts-1` | Optimized for speed |
| `tts-1-hd` | Higher quality |
| `gpt-4o-mini-tts` | Latest, natural voice |

```json
POST /v1/audio/speech
{
  "model": "tts-1-hd",
  "input": "Hello, world! This is a test.",
  "voice": "alloy",
  "response_format": "mp3",
  "speed": 1.0
}
```

Available voices: `alloy`, `echo`, `fable`, `onyx`, `nova`, `shimmer`.
Output formats: `mp3`, `opus`, `aac`, `flac`, `wav`, `pcm`.

---

## Fine-Tuning

**Endpoint:** `POST /v1/fine_tuning/jobs`, `GET /v1/fine_tuning/jobs/{id}`

Fine-tune base models on custom datasets to improve performance for specific tasks.

### Supported Base Models (Fine-tuning)

- `gpt-4.1-2025-04-14`
- `gpt-4.1-mini-2025-04-14`
- `gpt-4.1-nano-2025-04-14`
- `gpt-4o-2024-11-20`
- `gpt-4o-mini-2024-07-18`

### Training File Format (.jsonl)

```jsonl
{"messages": [{"role": "system", "content": "You are a legal assistant."}, {"role": "user", "content": "What is habeas corpus?"}, {"role": "assistant", "content": "Habeas corpus is a legal right..."}]}
{"messages": [{"role": "user", "content": "Define mens rea."}, {"role": "assistant", "content": "Mens rea refers to criminal intent..."}]}
```

### Create Fine-Tune Job

```json
POST /v1/fine_tuning/jobs
{
  "training_file": "file-abc123",
  "model": "gpt-4o-mini-2024-07-18",
  "hyperparameters": {
    "n_epochs": 3
  }
}
```

### Fine-Tuning Methods

| Method | Description |
|--------|-------------|
| Supervised Fine-Tuning (SFT) | Standard prompt/completion pairs |
| Direct Preference Optimization (DPO) | Preferred vs rejected response pairs |
| Reinforcement Fine-Tuning (RFT) | Reward-signal based optimization |

---

## Moderation

**Endpoint:** `POST /v1/moderations`

Classifies text and images for harmful content. Free to use.

### Models

| Model | Notes |
|-------|-------|
| `omni-moderation-latest` | Text + image, most accurate |
| `text-moderation-latest` | Text only |

### Request Example

```json
POST /v1/moderations
{
  "model": "omni-moderation-latest",
  "input": "I want to hurt someone."
}
```

### Response Example

```json
{
  "id": "modr-abc123",
  "model": "omni-moderation-latest",
  "results": [
    {
      "flagged": true,
      "categories": {
        "hate": false,
        "harassment": true,
        "self-harm": false,
        "sexual": false,
        "violence": true,
        "violence/graphic": false
      },
      "category_scores": {
        "harassment": 0.9823,
        "violence": 0.7712
      }
    }
  ]
}
```

---

## Models Reference

### GPT-4 Series

| Model ID | Context Window | Output Tokens | Notes |
|----------|---------------|---------------|-------|
| `gpt-4o` | 128K | 16K | Fast, multimodal, flagship |
| `gpt-4o-mini` | 128K | 16K | Cost-efficient, smaller tasks |
| `gpt-4.1` | 1M | 32K | Smartest non-reasoning model |
| `gpt-4.1-mini` | 1M | 32K | Efficient version of 4.1 |
| `gpt-4.1-nano` | 1M | 32K | Cheapest 4.1 variant |

### O-Series (Reasoning Models)

| Model ID | Context Window | Output Tokens | Notes |
|----------|---------------|---------------|-------|
| `o1` | 200K | 100K | Previous reasoning flagship |
| `o1-pro` | 200K | 100K | o1 with more compute |
| `o3` | 200K | 100K | Latest reasoning model for complex tasks |
| `o3-pro` | 200K | 100K | o3 with extended reasoning |
| `o3-mini` | 200K | 100K | Smaller reasoning model |
| `o4-mini` | 200K | 100K | Fast, cost-efficient reasoning |

### Pricing (as of 2026-02-27)

| Model | Input ($/1M tokens) | Output ($/1M tokens) |
|-------|--------------------|--------------------|
| `gpt-4o` | $2.50 | $10.00 |
| `gpt-4o-mini` | $0.15 | $0.60 |
| `gpt-4.1` | $2.00 | $8.00 |
| `gpt-4.1-mini` | $0.40 | $1.60 |
| `gpt-4.1-nano` | $0.10 | $0.40 |
| `o1` | $15.00 | $60.00 |
| `o3` | $10.00 | $40.00 |
| `o3-mini` | $1.10 | $4.40 |
| `o4-mini` | $1.10 | $4.40 |
| `text-embedding-3-small` | $0.02 | — |
| `text-embedding-3-large` | $0.13 | — |

Batch API: 50% discount on all eligible models for asynchronous workloads.

---

## Rate Limits & Usage Tiers

Rate limits apply per project. Tiers upgrade automatically based on cumulative spend.

### Tier Structure

| Tier | Requirement | GPT-4o RPM | GPT-4o TPM |
|------|-------------|-----------|-----------|
| Free | $0 spend | 3 | 40K |
| Tier 1 | $5 payment | 500 | 30K |
| Tier 2 | $50 spend | 5,000 | 450K |
| Tier 3 | $100 spend | 5,000 | 800K |
| Tier 4 | $250 spend | 10,000 | 2M |
| Tier 5 | $1,000 spend | 10,000 | 30M |

Rate limits are measured across five dimensions:

| Metric | Description |
|--------|-------------|
| RPM | Requests per minute |
| RPD | Requests per day |
| TPM | Tokens per minute |
| TPD | Tokens per day |
| IPM | Images per minute |

**Batch API:** Asynchronous requests processed within 24 hours at 50% cost. Separate limits apply.

---

## Error Codes

| HTTP Code | Error Type | Description |
|-----------|-----------|-------------|
| 400 | `invalid_request_error` | Malformed request, bad parameters |
| 401 | `authentication_error` | Invalid or missing API key |
| 403 | `permission_error` | Key lacks permission for resource |
| 404 | `not_found_error` | Resource or model not found |
| 409 | `conflict_error` | Resource state conflict |
| 422 | `unprocessable_entity` | Semantic validation failure |
| 429 | `rate_limit_error` | RPM, TPM, or daily limit exceeded |
| 500 | `api_error` | OpenAI server error |
| 503 | `service_unavailable` | Temporary overload or maintenance |

### Error Response Format

```json
{
  "error": {
    "message": "You exceeded your current quota.",
    "type": "insufficient_quota",
    "param": null,
    "code": "insufficient_quota"
  }
}
```

---

## Response Headers

| Header | Description |
|--------|-------------|
| `x-ratelimit-limit-requests` | Max requests allowed in window |
| `x-ratelimit-remaining-requests` | Requests remaining |
| `x-ratelimit-reset-requests` | Time until request limit resets |
| `x-ratelimit-limit-tokens` | Max tokens in window |
| `x-ratelimit-remaining-tokens` | Tokens remaining |
| `x-ratelimit-reset-tokens` | Time until token limit resets |
| `openai-processing-ms` | Server-side processing time |
| `openai-version` | API version used |

---

## Quick Reference: All Endpoints

| Category | Method | Endpoint |
|----------|--------|----------|
| Chat | POST | `/v1/chat/completions` |
| Embeddings | POST | `/v1/embeddings` |
| Images Generate | POST | `/v1/images/generations` |
| Images Edit | POST | `/v1/images/edits` |
| Images Variations | POST | `/v1/images/variations` |
| Audio Transcribe | POST | `/v1/audio/transcriptions` |
| Audio Translate | POST | `/v1/audio/translations` |
| Audio Speech | POST | `/v1/audio/speech` |
| Moderation | POST | `/v1/moderations` |
| Files Upload | POST | `/v1/files` |
| Files List | GET | `/v1/files` |
| Files Delete | DELETE | `/v1/files/{file_id}` |
| Fine-tune Create | POST | `/v1/fine_tuning/jobs` |
| Fine-tune List | GET | `/v1/fine_tuning/jobs` |
| Fine-tune Status | GET | `/v1/fine_tuning/jobs/{id}` |
| Assistants Create | POST | `/v1/assistants` |
| Threads Create | POST | `/v1/threads` |
| Thread Messages | POST | `/v1/threads/{id}/messages` |
| Runs Create | POST | `/v1/threads/{id}/runs` |
| Runs Status | GET | `/v1/threads/{id}/runs/{run_id}` |
| Models List | GET | `/v1/models` |
| Model Get | GET | `/v1/models/{model}` |

---

*Sources: [OpenAI API Reference](https://platform.openai.com/docs/api-reference/introduction) | [OpenAI Models](https://platform.openai.com/docs/models) | [OpenAI Pricing](https://openai.com/api/pricing/) | [Rate Limits Guide](https://platform.openai.com/docs/guides/rate-limits)*
