# Groq API — Full Technical Documentation

**Sources:**
- https://console.groq.com/docs/openai
- https://console.groq.com/docs/speech-text (alias: https://console.groq.com/docs/speech-to-text)
- https://console.groq.com/docs/rate-limits
- https://groq.com/pricing
- https://console.groq.com/docs/errors
- https://console.groq.com/docs/models
- https://console.groq.com/docs/tool-use
- https://console.groq.com/docs/structured-outputs

**Date saved:** 2026-02-28

---

## 1. Overview

Groq is a fast, low-cost AI inference platform powered by its custom LPU (Language Processing Unit) hardware. The API is fully OpenAI-compatible, meaning any library or tool that works with OpenAI's API works with Groq by changing the base URL and API key.

**Base URL:**
```
https://api.groq.com/openai/v1
```

---

## 2. Authentication

All requests require a Bearer token in the `Authorization` header.

```http
Authorization: Bearer $GROQ_API_KEY
```

Get your API key at: https://console.groq.com/keys

**Python (using OpenAI SDK):**
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.groq.com/openai/v1",
    api_key="your_groq_api_key"
)
```

**Python (using Groq SDK):**
```python
from groq import Groq

client = Groq(api_key="your_groq_api_key")
```

Install: `pip install groq`

---

## 3. Endpoints

### 3.1 Chat Completions

```
POST https://api.groq.com/openai/v1/chat/completions
```

**Request body parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `model` | string | Yes | Model ID (e.g., `llama-3.3-70b-versatile`) |
| `messages` | array | Yes | Array of message objects with `role` and `content` |
| `temperature` | float | No | 0–2. Default 1. Higher = more random |
| `max_tokens` | integer | No | Max tokens to generate |
| `top_p` | float | No | Nucleus sampling. Default 1 |
| `stream` | boolean | No | Stream partial results via SSE. Default false |
| `stop` | string/array | No | Stop sequences |
| `n` | integer | No | Number of completions to generate |
| `response_format` | object | No | `{"type": "json_object"}` or `{"type": "json_schema", "json_schema": {...}}` |
| `tools` | array | No | List of tools for function calling |
| `tool_choice` | string/object | No | Controls tool usage: `"none"`, `"auto"`, or `{"type": "function", "function": {"name": "..."}}`  |
| `seed` | integer | No | For deterministic sampling |
| `user` | string | No | Identifier for end-user |

**cURL example:**
```bash
curl -X POST https://api.groq.com/openai/v1/chat/completions \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "llama-3.3-70b-versatile",
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": "Explain LPU inference in one sentence."}
    ]
  }'
```

**Response:**
```json
{
  "id": "chatcmpl-abc123",
  "object": "chat.completion",
  "created": 1709123456,
  "model": "llama-3.3-70b-versatile",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "An LPU processes tokens sequentially at very high speed..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 25,
    "completion_tokens": 18,
    "total_tokens": 43
  }
}
```

---

### 3.2 Audio Transcription (Speech-to-Text)

```
POST https://api.groq.com/openai/v1/audio/transcriptions
```

**Request — multipart/form-data parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file` | file | Yes* | Audio file to transcribe. Max 25MB (free) / 100MB (dev tier) |
| `url` | string | Yes* | URL of audio file (Base64URL supported). Alternative to `file` |
| `model` | string | Yes | Model ID: `whisper-large-v3-turbo`, `whisper-large-v3`, or `distil-whisper-large-v3-en` |
| `language` | string | No | ISO-639-1 language code (e.g., `"en"`, `"nl"`, `"fr"`). Auto-detected if omitted |
| `prompt` | string | No | Guidance text to steer style or continue previous segment. Should match audio language |
| `response_format` | string | No | `json` (default), `text`, or `verbose_json` |
| `temperature` | float | No | 0–1. 0 = deterministic. Default 0 |
| `timestamp_granularities` | array | No | `["word"]`, `["segment"]`, or `["word","segment"]`. Requires `response_format: verbose_json` |

*Either `file` or `url` must be provided.

**Supported audio formats:** mp3, mp4, mpeg, mpga, m4a, wav, webm

**Note:** Audio is downsampled to 16KHz mono before transcription (optimal for speech recognition).

**Python example:**
```python
from groq import Groq

client = Groq()

with open("audio.mp3", "rb") as f:
    transcription = client.audio.transcriptions.create(
        file=("audio.mp3", f.read()),
        model="whisper-large-v3-turbo",
        response_format="verbose_json",
        timestamp_granularities=["word", "segment"],
        language="en",
        temperature=0.0
    )

print(transcription.text)
```

**cURL example:**
```bash
curl -X POST https://api.groq.com/openai/v1/audio/transcriptions \
  -H "Authorization: Bearer $GROQ_API_KEY" \
  -F "file=@audio.mp3" \
  -F "model=whisper-large-v3-turbo" \
  -F "response_format=verbose_json" \
  -F "timestamp_granularities[]=word" \
  -F "language=en"
```

**Response (verbose_json):**
```json
{
  "task": "transcribe",
  "language": "english",
  "duration": 45.2,
  "text": "Full transcription text here...",
  "words": [
    {"word": "Hello", "start": 0.0, "end": 0.4},
    {"word": "world", "start": 0.5, "end": 0.9}
  ],
  "segments": [
    {
      "id": 0,
      "seek": 0,
      "start": 0.0,
      "end": 4.5,
      "text": "Hello world...",
      "tokens": [50364, 15947, ...],
      "temperature": 0.0,
      "avg_logprob": -0.23,
      "compression_ratio": 1.4,
      "no_speech_prob": 0.01
    }
  ]
}
```

---

### 3.3 Audio Translation

```
POST https://api.groq.com/openai/v1/audio/translations
```

Translates any supported language audio **to English text only**.

Parameters are identical to `/audio/transcriptions` with one difference:
- `language` accepts `"en"` only (output is always English)

---

### 3.4 Text-to-Speech

```
POST https://api.groq.com/openai/v1/audio/speech
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `model` | string | Yes | `playai-tts` (PlayAI Dialog v1.0) or `playai-tts-arabic` |
| `input` | string | Yes | Text to convert to speech |
| `voice` | string | Yes | Voice ID |
| `response_format` | string | No | Output format (e.g., `mp3`, `wav`) |

**Pricing:** $50.00 per million characters

---

### 3.5 Models List

```
GET https://api.groq.com/openai/v1/models
```

Returns a JSON list of all currently active models.

**cURL:**
```bash
curl https://api.groq.com/openai/v1/models \
  -H "Authorization: Bearer $GROQ_API_KEY"
```

---

### 3.6 Batch API

```
POST https://api.groq.com/openai/v1/batches
```

Send thousands of requests at once. Results returned within 24 hours. Discount: **50% off** real-time rates. Not suitable for time-sensitive tasks.

---

## 4. Supported Models

### 4.1 Chat / Text Models

| Model ID | Context Window | Notes |
|----------|---------------|-------|
| `llama-3.3-70b-versatile` | 128K tokens | Recommended general-purpose model |
| `llama-3.3-70b-specdec` | 128K tokens | Speculative decoding variant (faster) |
| `llama-3.1-8b-instant` | 131,072 tokens | Fastest, cheapest LLM |
| `llama-3.1-70b-versatile` | 131,072 tokens | High capability |
| `llama-3.1-405b-reasoning` | 131,072 tokens | Largest reasoning model |
| `llama3-8b-8192` | 8,192 tokens | Legacy |
| `llama3-70b-8192` | 8,192 tokens | Legacy |
| `llama-4-scout-17b-16e-instruct` | 128K tokens | Llama 4 MoE (17Bx16E) |
| `llama-4-maverick-17b-128e-instruct` | 128K tokens | Llama 4 MoE (17Bx128E) |
| `gemma2-9b-it` | 8,192 tokens | Google Gemma 2 |
| `qwen-qwq-32b` | 128K tokens | Qwen reasoning model |
| `qwen3-32b` | 128K tokens | Qwen 3 |
| `deepseek-r1-distill-llama-70b` | 128K tokens | DeepSeek R1 distilled |
| `compound-beta` | — | Compound model with built-in web search + code execution |
| `compound-beta-mini` | — | Lighter compound model |
| `kimi-k2-instruct` | — | Moonshot Kimi K2 |
| `moonshotai/kimi-k2-instruct` | — | Alternate Kimi K2 path |

### 4.2 Audio / Speech Models

| Model ID | Type | Notes |
|----------|------|-------|
| `whisper-large-v3-turbo` | Transcription | Fastest, cheapest. Recommended for most use cases |
| `whisper-large-v3` | Transcription | Highest accuracy, slowest |
| `distil-whisper-large-v3-en` | Transcription | English-only, very fast |
| `playai-tts` | Text-to-Speech | PlayAI Dialog v1.0 |
| `playai-tts-arabic` | Text-to-Speech | Arabic TTS |

---

## 5. Pricing

### 5.1 Audio Transcription

| Model | Price |
|-------|-------|
| `whisper-large-v3` | $0.111 per audio hour |
| `whisper-large-v3-turbo` | $0.04 per audio hour |
| `distil-whisper-large-v3-en` | ~$0.02 per audio hour |

### 5.2 Text Models (per million tokens — input / output)

| Model | Input | Output |
|-------|-------|--------|
| `llama-3.1-8b-instant` | $0.05 | $0.08 |
| `llama-3.3-70b-versatile` | $0.59 | $0.79 |
| `llama-3.3-70b-specdec` | $0.59 | $0.99 |
| `gemma2-9b-it` | ~$0.20 | ~$0.20 |
| Large models (120B+) | up to $1.00 | up to $1.00 |

### 5.3 Text-to-Speech

| Model | Price |
|-------|-------|
| PlayAI Dialog v1.0 (`playai-tts`) | $50.00 per million characters |

### 5.4 Batch API Discount

All models: **50% off** real-time rates when using the Batch API.

### 5.5 Prompt Caching

Repeated identical inputs: **50% discount** on cached input tokens.

---

## 6. Rate Limits

Rate limits are enforced at the **organization level** and measured across:
- **RPM** — Requests per Minute
- **RPD** — Requests per Day
- **TPM** — Tokens per Minute
- **TPD** — Tokens per Day
- **APD** — Audio seconds per Day (for Whisper models)

### 6.1 Tiers

| Tier | Requires | Notes |
|------|----------|-------|
| **Free** | Sign-up only, no credit card | Capped limits, hard cutoff at 429 (no charges) |
| **Developer** | Credit card on file | ~10x higher token consumption than Free |
| **Enterprise** | Custom contract | Custom capacity |

### 6.2 Free Tier Limits (approximate — check console.groq.com/settings/limits for current values)

| Model | RPM | RPD | TPM | Notes |
|-------|-----|-----|-----|-------|
| `llama-3.3-70b-versatile` | — | 14,400 | 70,000 | — |
| `llama-3.1-8b-instant` | — | 14,400 | — | — |
| `whisper-large-v3-turbo` | — | 7,200 | — | Audio model |
| `whisper-large-v3` | — | 7,200 | — | Audio model |

**File size limits:**
- Free tier: 25MB per audio file
- Developer tier: 100MB per audio file

**Note:** Always check https://console.groq.com/settings/limits for current per-model limits as they change frequently.

### 6.3 Rate Limit Response Headers

Every API response includes these headers:

| Header | Description |
|--------|-------------|
| `x-ratelimit-limit-requests` | Max requests allowed in window |
| `x-ratelimit-limit-tokens` | Max tokens allowed in window |
| `x-ratelimit-remaining-requests` | Requests remaining in window |
| `x-ratelimit-remaining-tokens` | Tokens remaining in window |
| `x-ratelimit-reset-requests` | Time until request limit resets |
| `x-ratelimit-reset-tokens` | Time until token limit resets |
| `retry-after` | Only set on 429 responses |

---

## 7. Error Codes

| HTTP Status | Type | Description |
|-------------|------|-------------|
| `400` | `invalid_request_error` | Malformed request or missing required parameters |
| `401` | `authentication_error` | Invalid or missing API key |
| `403` | `permission_error` | Insufficient permissions for the requested resource |
| `404` | `not_found_error` | Model or resource not found |
| `422` | `unprocessable_entity` | Well-formed request but semantic errors or model issues |
| `429` | `rate_limit_error` | Too many requests — implement backoff and retry |
| `498` | `flex_tier_capacity_exceeded` | Custom code: Flex tier at capacity |
| `500` | `internal_server_error` | Groq server error |
| `503` | `service_unavailable` | Model temporarily unavailable |

**Error response body format:**
```json
{
  "error": {
    "message": "Rate limit reached for model `llama-3.3-70b-versatile`",
    "type": "rate_limit_error",
    "code": "rate_limit_exceeded"
  }
}
```

**Handling 429 in Python:**
```python
import time
import groq

client = groq.Groq()

def call_with_retry(messages, model, max_retries=5):
    for attempt in range(max_retries):
        try:
            return client.chat.completions.create(
                model=model,
                messages=messages
            )
        except groq.RateLimitError as e:
            if attempt == max_retries - 1:
                raise
            wait = 2 ** attempt
            print(f"Rate limited. Waiting {wait}s...")
            time.sleep(wait)
```

---

## 8. Advanced Features

### 8.1 Structured Outputs

Force the model to output valid JSON matching a schema:

```python
response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": "List 3 cities in France as JSON."}],
    response_format={
        "type": "json_schema",
        "json_schema": {
            "name": "cities",
            "schema": {
                "type": "object",
                "properties": {
                    "cities": {"type": "array", "items": {"type": "string"}}
                },
                "required": ["cities"]
            }
        }
    }
)
```

**Limitation:** Streaming and Structured Outputs cannot be used together.

### 8.2 Tool Use / Function Calling

```python
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "Get current weather for a location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {"type": "string", "description": "City name"}
                },
                "required": ["location"]
            }
        }
    }
]

response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": "What's the weather in Amsterdam?"}],
    tools=tools,
    tool_choice="auto"
)
```

### 8.3 Streaming

```python
stream = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": "Write a poem."}],
    stream=True
)

for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="")
```

### 8.4 Compound Models (Built-in Tools)

`compound-beta` and `compound-beta-mini` have built-in web search and code execution — no manual tool definitions needed.

---

## 9. SDKs and Compatibility

| Language | Package | Install |
|----------|---------|---------|
| Python (native) | `groq` | `pip install groq` |
| Python (OpenAI compat) | `openai` | `pip install openai` |
| Node.js (native) | `groq-sdk` | `npm install groq-sdk` |
| Node.js (OpenAI compat) | `openai` | `npm install openai` |

All OpenAI-compatible SDKs work by setting `base_url="https://api.groq.com/openai/v1"`.

---

## 10. Cloudflare AI Gateway Integration

Groq is supported via Cloudflare AI Gateway:
```
https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/groq/openai/v1
```
This adds caching, logging, and rate limit observability on top of the Groq API.
