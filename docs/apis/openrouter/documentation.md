# OpenRouter API — Full Technical Documentation

**Source:** https://openrouter.ai/docs/quickstart
**Date Saved:** 2026-03-05
**Base URL:** `https://openrouter.ai/api/v1`

---

## Overview

OpenRouter provides a unified API that gives access to 400+ AI models through a single endpoint, automatically handling fallbacks and selecting the most cost-effective options. It is fully OpenAI-compatible.

---

## Authentication

### Bearer Token (Standard)
```
Authorization: Bearer <OPENROUTER_API_KEY>
```

Key format: `sk-or-v1-...`
Get your key at: https://openrouter.ai/settings/keys

### Optional Headers
```
HTTP-Referer: <YOUR_SITE_URL>      # Makes your app appear in OpenRouter leaderboards
X-OpenRouter-Title: <YOUR_APP_NAME> # App name for rankings
```

### BYOK (Bring Your Own Key)
You can use your own provider API keys (OpenAI, Anthropic, etc.) via BYOK. No additional OpenRouter fee on those requests.

---

## Endpoints

### POST /api/v1/chat/completions
Main chat completions endpoint — fully OpenAI-compatible.

**Request:**
```json
{
  "model": "openai/gpt-4o",
  "messages": [
    {
      "role": "user",
      "content": "What is the meaning of life?"
    }
  ],
  "stream": false,
  "temperature": 0.7,
  "max_tokens": 1024,
  "top_p": 1,
  "stop": null,
  "frequency_penalty": 0,
  "presence_penalty": 0,
  "seed": null,
  "response_format": { "type": "json_object" },
  "tools": [],
  "tool_choice": "auto"
}
```

**Response:**
```json
{
  "id": "gen-...",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "openai/gpt-4o",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "42."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 5,
    "total_tokens": 15
  }
}
```

**Streaming:** Set `"stream": true` to get SSE chunks. Each chunk is a delta following the OpenAI streaming format.

### GET /api/v1/models
Returns all available models with metadata.

**Response schema:**
```json
{
  "data": [
    {
      "id": "google/gemini-2.5-pro-preview",
      "canonical_slug": "google/gemini-2.5-pro-preview",
      "name": "Gemini 2.5 Pro Preview",
      "created": 1234567890,
      "description": "...",
      "context_length": 1000000,
      "architecture": {
        "input_modalities": ["file", "image", "text"],
        "output_modalities": ["text"],
        "tokenizer": "gemini",
        "instruct_type": null
      },
      "pricing": {
        "prompt": "0.00000125",
        "completion": "0.000010",
        "request": "0",
        "image": "0.000263",
        "web_search": "0",
        "internal_reasoning": "0",
        "input_cache_read": "0",
        "input_cache_write": "0"
      },
      "top_provider": {
        "context_length": 1000000,
        "max_completion_tokens": 8192,
        "is_moderated": false
      },
      "per_request_limits": null,
      "supported_parameters": [
        "tools", "tool_choice", "max_tokens", "temperature", "top_p",
        "reasoning", "include_reasoning", "structured_outputs",
        "response_format", "stop", "frequency_penalty", "presence_penalty", "seed"
      ]
    }
  ]
}
```

**Pricing values:** All in USD per token. `"0"` = free feature.

---

## SDKs

### OpenRouter Native SDK (Beta)
```bash
npm install @openrouter/sdk
```

```typescript
import { OpenRouter } from '@openrouter/sdk';

const openRouter = new OpenRouter({
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': '<YOUR_SITE_URL>',       // Optional
    'X-OpenRouter-Title': '<YOUR_APP_NAME>', // Optional
  },
});

const completion = await openRouter.chat.send({
  model: 'openai/gpt-4o',
  messages: [{ role: 'user', content: 'Hello' }],
  stream: false,
});

console.log(completion.choices[0].message.content);
```

### Via OpenAI SDK (TypeScript)
```bash
npm install openai
```

```typescript
import OpenAI from 'openai';

const openai = new OpenAI({
  baseURL: 'https://openrouter.ai/api/v1',
  apiKey: '<OPENROUTER_API_KEY>',
  defaultHeaders: {
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-OpenRouter-Title': '<YOUR_APP_NAME>',
  },
});

const completion = await openai.chat.completions.create({
  model: 'openai/gpt-4o',
  messages: [{ role: 'user', content: 'Hello' }],
});

console.log(completion.choices[0].message);
```

### Via OpenAI SDK (Python)
```python
from openai import OpenAI

client = OpenAI(
  base_url='https://openrouter.ai/api/v1',
  api_key='<OPENROUTER_API_KEY>',
)

completion = client.chat.completions.create(
  model='openai/gpt-4o',
  messages=[{'role': 'user', 'content': 'Hello'}],
  extra_headers={
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-OpenRouter-Title': '<YOUR_APP_NAME>',
  }
)
print(completion.choices[0].message.content)
```

### Direct HTTP (Python)
```python
import requests, json

response = requests.post(
  url='https://openrouter.ai/api/v1/chat/completions',
  headers={
    'Authorization': 'Bearer <OPENROUTER_API_KEY>',
    'HTTP-Referer': '<YOUR_SITE_URL>',
    'X-OpenRouter-Title': '<YOUR_APP_NAME>',
  },
  data=json.dumps({
    'model': 'openai/gpt-4o',
    'messages': [{'role': 'user', 'content': 'What is the meaning of life?'}]
  })
)
```

---

## Model IDs

Model IDs follow the format: `{provider}/{model-name}`

### Popular Models (as of 2026-03-05)

| Provider | Model ID | Context |
|----------|----------|---------|
| Anthropic | `anthropic/claude-sonnet-4-5` | 200K |
| Anthropic | `anthropic/claude-opus-4` | 200K |
| OpenAI | `openai/gpt-4o` | 128K |
| OpenAI | `openai/o3` | 200K |
| Google | `google/gemini-2.5-pro-preview` | 1M |
| Google | `google/gemini-flash-1.5` | 1M |
| Meta | `meta-llama/llama-3.3-70b-instruct` | 128K |
| Mistral | `mistral/mistral-large` | 128K |
| DeepSeek | `deepseek/deepseek-r1` | 64K |
| Microsoft | `microsoft/phi-4` | 16K |

Full model list: https://openrouter.ai/models
Models API: `GET https://openrouter.ai/api/v1/models`
RSS feed for new models: `GET /api/v1/models?use_rss=true`

---

## Model Selection & Routing

### Model Fallbacks
Pass multiple models in `models` array — OpenRouter tries them in order:
```json
{
  "models": ["openai/gpt-4o", "anthropic/claude-3-5-sonnet", "google/gemini-2.5-pro-preview"],
  "messages": [...]
}
```

### Provider Selection
Control which providers serve the request:
```json
{
  "model": "openai/gpt-4o",
  "provider": {
    "order": ["OpenAI", "Azure"],
    "allow_fallbacks": true,
    "require_parameters": true,
    "data_collection": "deny"
  }
}
```

### Auto Router
Use `openrouter/auto` to let OpenRouter select the best model for your prompt automatically.

---

## Features

### Structured Outputs (JSON Schema)
```json
{
  "model": "openai/gpt-4o",
  "response_format": {
    "type": "json_schema",
    "json_schema": {
      "name": "MySchema",
      "schema": {
        "type": "object",
        "properties": { "answer": { "type": "string" } }
      }
    }
  }
}
```

### Tool Calling
OpenAI-compatible function calling:
```json
{
  "model": "openai/gpt-4o",
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get weather for a location",
        "parameters": {
          "type": "object",
          "properties": {
            "location": { "type": "string" }
          },
          "required": ["location"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}
```

### Multimodal (Images, PDFs, Audio, Video)
```json
{
  "model": "google/gemini-2.5-pro-preview",
  "messages": [
    {
      "role": "user",
      "content": [
        { "type": "text", "text": "What's in this image?" },
        { "type": "image_url", "image_url": { "url": "https://..." } }
      ]
    }
  ]
}
```

### Message Transforms
Automatically compress/transform context to fit model limits:
```json
{
  "transforms": ["middle-out"]
}
```

### Zero Completion Insurance
If a provider returns an empty response, OpenRouter automatically retries with another provider at no charge.

### ZDR (Zero Data Retention)
Route only to providers with ZDR policies:
```json
{
  "provider": { "data_collection": "deny" }
}
```

---

## Supported Parameters (per model)

Each model declares which parameters it supports via `supported_parameters`:

| Parameter | Description |
|-----------|-------------|
| `tools` | Function calling |
| `tool_choice` | Tool selection control |
| `max_tokens` | Response length limit |
| `temperature` | Randomness (0–2) |
| `top_p` | Nucleus sampling |
| `reasoning` | Internal reasoning mode |
| `include_reasoning` | Include reasoning in response |
| `structured_outputs` | JSON schema enforcement |
| `response_format` | Output format specification |
| `stop` | Custom stop sequences |
| `frequency_penalty` | Repetition reduction |
| `presence_penalty` | Topic diversity |
| `seed` | Deterministic outputs |

---

## Rate Limits & Pricing

### Free Models
- Some models are marked free (pricing = `"0"`)
- Free tier has rate limits: see https://openrouter.ai/docs/faq#how-are-rate-limits-calculated
- Rate limits depend on your account credits / usage tier

### Pricing
- Pay-as-you-go per token, per request, or per image
- All prices in USD per token
- Tokenization varies by model family
- Use `usage` field in response to get exact token counts

### Credits
- Purchase credits at https://openrouter.ai/credits
- Credits never expire (per FAQ)
- Volume discounts available

### BYOK
- Use your own provider keys — no markup from OpenRouter on those tokens

---

## Error Codes

OpenRouter uses standard HTTP status codes + OpenAI-compatible error shapes:

```json
{
  "error": {
    "message": "...",
    "type": "...",
    "code": 400
  }
}
```

| Code | Meaning |
|------|---------|
| 400 | Bad request / invalid parameters |
| 401 | Invalid or missing API key |
| 402 | Insufficient credits |
| 429 | Rate limit exceeded |
| 500 | Internal server error |
| 502 | Provider returned invalid response |
| 503 | Provider unavailable (fallback triggered) |

---

## API Reference Links

| Resource | URL |
|----------|-----|
| Docs home | https://openrouter.ai/docs/quickstart |
| API Reference | https://openrouter.ai/docs/api-reference/overview |
| Models list | https://openrouter.ai/models |
| Models API | https://openrouter.ai/api/v1/models |
| Request Builder | https://openrouter.ai/request-builder |
| Keys / Dashboard | https://openrouter.ai/settings/keys |
| FAQ | https://openrouter.ai/docs/faq |
| SDK npm | https://www.npmjs.com/package/@openrouter/sdk |
| Discord | https://openrouter.ai/discord |
