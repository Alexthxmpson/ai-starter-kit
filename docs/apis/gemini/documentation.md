# Google Gemini API — Technical Documentation

**Source:** https://ai.google.dev/api/generate-content | https://ai.google.dev/gemini-api/docs/quickstart
**Date:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Base URL](#base-url)
4. [generateContent Endpoint](#generatecontent-endpoint)
5. [streamGenerateContent Endpoint](#streamgeneratecontent-endpoint)
6. [Chat (Multi-Turn)](#chat-multi-turn)
7. [Vision (Multimodal)](#vision-multimodal)
8. [Embeddings](#embeddings)
9. [Request / Response Object Reference](#request--response-object-reference)
10. [Available Models](#available-models)
11. [Rate Limits](#rate-limits)
12. [Pricing](#pricing)
13. [Error Codes](#error-codes)
14. [Code Examples](#code-examples)

---

## Overview

The Gemini API is Google's generative AI REST API, hosted at `generativelanguage.googleapis.com`. It provides:

- Text generation (single-turn and multi-turn chat)
- Multimodal inputs: text, images, video, audio, PDF
- Embedding generation
- Function/tool calling
- Code execution (built-in tool)
- Search grounding (Gemini with Google Search)
- Structured output (JSON Schema)
- Context caching (long repeated contexts at reduced cost)

The API is available through two platforms:
- **Google AI Studio / Gemini Developer API** — API key auth, easier onboarding, free tier
- **Vertex AI** — Google Cloud service account auth, enterprise SLAs, additional models

This documentation covers the **Gemini Developer API** (AI Studio).

---

## Authentication

All requests require an API key passed as a query parameter or header.

### Query Parameter (simplest)

```
https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=YOUR_API_KEY
```

### Header

```http
x-goog-api-key: YOUR_API_KEY
```

API keys are created in [Google AI Studio](https://aistudio.google.com/apikey). No billing account needed for free tier.

**Environment variable convention:**

```bash
export GEMINI_API_KEY="AIzaSy..."
```

---

## Base URL

```
https://generativelanguage.googleapis.com/v1beta
```

All endpoints are relative to this base URL.

---

## generateContent Endpoint

**Method:** `POST`
**URL:** `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`

Generates a complete response in one request. The model processes the full input and returns the complete output.

### URL Path Parameters

| Parameter | Description |
|-----------|-------------|
| `{model}` | Model ID, e.g. `gemini-2.0-flash`, `gemini-2.5-pro` |

### Request Body

```json
{
  "contents": [...],
  "systemInstruction": {...},
  "tools": [...],
  "toolConfig": {...},
  "generationConfig": {...},
  "safetySettings": [...]
}
```

### Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `contents` | array of Content | Yes | Conversation turns |
| `systemInstruction` | Content | No | System prompt (single Content object) |
| `tools` | array | No | Function declarations or built-in tools |
| `toolConfig` | object | No | Controls tool invocation behavior |
| `generationConfig` | object | No | Generation parameters |
| `safetySettings` | array | No | Override default safety thresholds |

### Content Object Structure

```json
{
  "role": "user",
  "parts": [
    {"text": "Hello, what can you do?"}
  ]
}
```

| Field | Values | Description |
|-------|--------|-------------|
| `role` | `"user"`, `"model"` | Turn author |
| `parts` | array of Part | Content pieces |

### Part Types

| Part Type | Structure | Description |
|-----------|-----------|-------------|
| Text | `{"text": "string"}` | Plain text |
| Inline data | `{"inlineData": {"mimeType": "image/png", "data": "base64..."}}` | Base64 encoded file |
| File URI | `{"fileData": {"mimeType": "video/mp4", "fileUri": "gs://..."}}` | Cloud Storage URI |
| Function call | `{"functionCall": {"name": "...", "args": {...}}}` | Model tool invocation |
| Function response | `{"functionResponse": {"name": "...", "response": {...}}}` | Tool result |

### generationConfig Fields

| Field | Type | Description |
|-------|------|-------------|
| `temperature` | float | 0.0–2.0. Randomness. Default: model-dependent |
| `topP` | float | Nucleus sampling probability |
| `topK` | integer | Top-k token sampling |
| `maxOutputTokens` | integer | Max tokens to generate |
| `stopSequences` | array of strings | Stop generation at these strings |
| `responseMimeType` | string | `"text/plain"` or `"application/json"` |
| `responseSchema` | object | JSON Schema for structured output |
| `candidateCount` | integer | Number of response candidates (usually 1) |
| `seed` | integer | Seed for deterministic output |
| `presencePenalty` | float | Penalizes tokens already in the output |
| `frequencyPenalty` | float | Penalizes frequent tokens |
| `thinkingConfig` | object | Controls thinking/reasoning for applicable models |

### Request Example (Text)

```json
POST /v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSy...
Content-Type: application/json

{
  "contents": [
    {
      "role": "user",
      "parts": [{"text": "Explain quantum entanglement in one paragraph."}]
    }
  ],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 512
  }
}
```

### Response Body

```json
{
  "candidates": [
    {
      "content": {
        "role": "model",
        "parts": [
          {"text": "Quantum entanglement is a phenomenon where..."}
        ]
      },
      "finishReason": "STOP",
      "safetyRatings": [...],
      "index": 0,
      "tokenCount": 148
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 14,
    "candidatesTokenCount": 148,
    "totalTokenCount": 162,
    "cachedContentTokenCount": 0
  },
  "modelVersion": "gemini-2.0-flash-001"
}
```

### Finish Reasons

| Value | Description |
|-------|-------------|
| `STOP` | Natural end of generation |
| `MAX_TOKENS` | `maxOutputTokens` reached |
| `SAFETY` | Content blocked by safety filters |
| `RECITATION` | Potential copyright recitation blocked |
| `LANGUAGE` | Language not supported |
| `OTHER` | Unknown reason |

---

## streamGenerateContent Endpoint

**Method:** `POST`
**URL:** `https://generativelanguage.googleapis.com/v1beta/models/{model}:streamGenerateContent`

Identical request format to `generateContent` but streams response chunks as they are generated.

Each chunk is a complete `GenerateContentResponse` object. Accumulate `text` across chunks for the full response.

### Streaming Example (Python)

```python
import google.generativeai as genai

genai.configure(api_key="AIzaSy...")
model = genai.GenerativeModel("gemini-2.0-flash")

for chunk in model.generate_content("Write a poem about AI", stream=True):
    print(chunk.text, end="")
```

---

## Chat (Multi-Turn)

The API is stateless. Build multi-turn conversations by passing the full history in `contents`, alternating `user` and `model` roles.

### Multi-Turn Request

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [{"text": "My name is Alex."}]
    },
    {
      "role": "model",
      "parts": [{"text": "Nice to meet you, Alex!"}]
    },
    {
      "role": "user",
      "parts": [{"text": "What's my name?"}]
    }
  ]
}
```

### System Instructions

```json
{
  "systemInstruction": {
    "parts": [{"text": "You are a helpful Python coding assistant. Always include working code examples."}]
  },
  "contents": [
    {"role": "user", "parts": [{"text": "How do I read a CSV file?"}]}
  ]
}
```

---

## Vision (Multimodal)

Gemini models natively accept images, video, audio, and PDFs in the same request as text.

### Supported Mime Types

| Type | Formats |
|------|---------|
| Image | `image/jpeg`, `image/png`, `image/gif`, `image/webp` |
| Video | `video/mp4`, `video/mpeg`, `video/webm`, `video/quicktime` |
| Audio | `audio/wav`, `audio/mp3`, `audio/aiff`, `audio/ogg`, `audio/flac` |
| Document | `application/pdf` |

### Image Input (Inline Base64)

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {"text": "Describe what you see in this image."},
        {
          "inlineData": {
            "mimeType": "image/jpeg",
            "data": "/9j/4AAQSkZJRg..."
          }
        }
      ]
    }
  ]
}
```

### File Upload (for Large Files)

For files >20 MB, use the Files API first, then reference by URI.

```python
import google.generativeai as genai

# Upload file
file = genai.upload_file("video.mp4", mime_type="video/mp4")

# Use in generation
model = genai.GenerativeModel("gemini-2.0-flash")
response = model.generate_content([
    "Summarize this video.",
    file
])
```

### Context Window Usage by Media Type

| Media | Token Equivalent |
|-------|-----------------|
| Image | 258 tokens per image (fixed) |
| Video | ~300 tokens/second |
| Audio | ~32 tokens/second |
| PDF | Image-like cost per page |

---

## Embeddings

**Method:** `POST`
**URL:** `/v1beta/models/{embedding-model}:embedContent`

Converts text into a numerical vector for semantic search, clustering, and RAG pipelines.

### Available Embedding Models

| Model | Dimensions | Max Input | Notes |
|-------|-----------|-----------|-------|
| `text-embedding-004` | 768 | 2048 tokens | Latest, most stable |
| `embedding-001` | 768 | 2048 tokens | Legacy |

### embedContent Request

```json
POST /v1beta/models/text-embedding-004:embedContent?key=AIzaSy...

{
  "model": "models/text-embedding-004",
  "content": {
    "parts": [{"text": "The quick brown fox jumps over the lazy dog"}]
  },
  "taskType": "RETRIEVAL_DOCUMENT",
  "outputDimensionality": 256
}
```

### Task Types

| Task Type | Use Case |
|-----------|----------|
| `RETRIEVAL_QUERY` | Embedding a search query |
| `RETRIEVAL_DOCUMENT` | Embedding a document to be retrieved |
| `SEMANTIC_SIMILARITY` | Comparing text similarity |
| `CLASSIFICATION` | For classification tasks |
| `CLUSTERING` | For clustering |
| `QUESTION_ANSWERING` | Q&A retrieval |
| `FACT_VERIFICATION` | Fact-checking |

### embedContent Response

```json
{
  "embedding": {
    "values": [0.013168523, -0.008504095, ...]
  }
}
```

### Batch Embeddings

Use `batchEmbedContents` to embed multiple texts in one request:

```
POST /v1beta/models/text-embedding-004:batchEmbedContents
```

---

## Request / Response Object Reference

### Safety Settings

```json
"safetySettings": [
  {
    "category": "HARM_CATEGORY_HARASSMENT",
    "threshold": "BLOCK_ONLY_HIGH"
  },
  {
    "category": "HARM_CATEGORY_HATE_SPEECH",
    "threshold": "BLOCK_MEDIUM_AND_ABOVE"
  }
]
```

### Safety Categories

| Category | Description |
|----------|-------------|
| `HARM_CATEGORY_HARASSMENT` | Harassment and bullying |
| `HARM_CATEGORY_HATE_SPEECH` | Hate speech |
| `HARM_CATEGORY_SEXUALLY_EXPLICIT` | Sexual content |
| `HARM_CATEGORY_DANGEROUS_CONTENT` | Dangerous, harmful content |

### Threshold Values

| Value | Description |
|-------|-------------|
| `BLOCK_NONE` | No blocking |
| `BLOCK_ONLY_HIGH` | Block only high-confidence harmful content |
| `BLOCK_MEDIUM_AND_ABOVE` | Block medium and above (default) |
| `BLOCK_LOW_AND_ABOVE` | Block most potentially harmful content |

### Tool Use (Function Calling)

```json
{
  "tools": [
    {
      "functionDeclarations": [
        {
          "name": "get_weather",
          "description": "Get current weather for a location",
          "parameters": {
            "type": "object",
            "properties": {
              "location": {
                "type": "string",
                "description": "City name"
              }
            },
            "required": ["location"]
          }
        }
      ]
    }
  ],
  "toolConfig": {
    "functionCallingConfig": {
      "mode": "AUTO"
    }
  }
}
```

Tool calling modes: `AUTO` (model decides), `ANY` (must call a tool), `NONE` (no tools).

### Structured Output (JSON Schema)

```json
"generationConfig": {
  "responseMimeType": "application/json",
  "responseSchema": {
    "type": "object",
    "properties": {
      "name": {"type": "string"},
      "age": {"type": "integer"},
      "hobbies": {
        "type": "array",
        "items": {"type": "string"}
      }
    },
    "required": ["name", "age"]
  }
}
```

---

## Available Models

### Gemini 2.x Series (Current — 2026)

| Model ID | Context Window | Key Capabilities | Notes |
|----------|---------------|-----------------|-------|
| `gemini-2.5-pro` | 1M tokens (output: 65K) | Most intelligent, reasoning | Highest quality, slower |
| `gemini-2.5-flash` | 1M tokens (output: 65K) | Balanced speed/quality, thinking | Best value overall |
| `gemini-2.5-flash-lite` | 1M tokens (output: 65K) | Fastest, cheapest 2.5 | Most cost-efficient |
| `gemini-2.0-flash` | 1M tokens (output: 8K) | Multimodal, tool use, GA | General availability |
| `gemini-2.0-flash-lite` | 1M tokens (output: 8K) | Ultra low cost | Public preview |

### Gemini 1.5 Series (Available, older)

| Model ID | Context Window | Notes |
|----------|---------------|-------|
| `gemini-1.5-pro` | 2M tokens | Longest context window |
| `gemini-1.5-flash` | 1M tokens | Fast and efficient |
| `gemini-1.5-flash-8b` | 1M tokens | Lightest 1.5 model |

### Embedding Models

| Model ID | Dimensions | Notes |
|----------|-----------|-------|
| `text-embedding-004` | 768 | Current recommended |
| `embedding-001` | 768 | Legacy |

### Model Capabilities Matrix

| Model | Text | Vision | Video | Audio | PDF | Function Calling | Code Exec |
|-------|------|--------|-------|-------|-----|-----------------|-----------|
| gemini-2.5-pro | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| gemini-2.5-flash | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| gemini-2.0-flash | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| gemini-2.0-flash-lite | Yes | Yes | No | No | Yes | Yes | No |

---

## Rate Limits

### Free Tier (Google AI Studio)

| Model | RPM | TPM | RPD |
|-------|-----|-----|-----|
| gemini-2.5-pro | 5 | 250K | 100 |
| gemini-2.5-flash | 10 | 250K | 250 |
| gemini-2.5-flash-lite | 15 | 250K | 1,000 |
| gemini-2.0-flash | 15 | 1M | 1,500 |
| gemini-2.0-flash-lite | 30 | 1M | 1,500 |
| text-embedding-004 | 1,500 | 1M | — |

Note: December 2025 update significantly reduced free tier quotas (50–92% reductions on some models).

### Paid Tier 1 (Billing enabled)

| Model | RPM | TPM | RPD |
|-------|-----|-----|-----|
| gemini-2.5-pro | 150 | 1M | 1,000 |
| gemini-2.5-flash | 300 | 1M | 10,000 |
| gemini-2.0-flash | 2,000 | 4M | — |

### Paid Tier 2 (After $250 cumulative spend + 30 days)

500–1,500 RPM, 2M TPM, 10,000 RPD depending on model.

### Paid Tier 3 / Enterprise

1,000–4,000+ RPM with custom limits. Contact Google Cloud sales.

---

## Pricing

### Gemini 2.5 Series (per 1M tokens)

| Model | Input ≤200K | Input >200K | Output |
|-------|------------|------------|--------|
| gemini-2.5-pro | $1.25 | $2.50 | $10.00 |
| gemini-2.5-flash | $0.075 | $0.15 | $0.30 |
| gemini-2.5-flash-lite | $0.018 | — | $0.072 |

### Gemini 2.0 Series (per 1M tokens)

| Model | Input | Output |
|-------|-------|--------|
| gemini-2.0-flash | $0.10 | $0.40 |
| gemini-2.0-flash-lite | $0.025 | $0.10 |

### Image / Video Input Pricing

| Media | Cost |
|-------|------|
| Image (any model) | ~$0.000658 per image (at 258 tokens/image) |
| Video | Billed as tokens (~300 tokens/second) |
| Audio | Billed as tokens (~32 tokens/second) |

### Context Caching

Available for 2.5 and 2.0 models. Caches repeated long prefixes (system prompts, documents) at 25% of standard input price. Cache storage: $1.00/1M tokens/hour.

### Batch API

50% discount on all paid models. Processed asynchronously within 24 hours.

### Free Tier Pricing

**$0** — Free tier is completely free, rate-limited, no credit card required for access via Google AI Studio.

---

## Error Codes

| HTTP Code | gRPC Code | Description |
|-----------|----------|-------------|
| 400 | INVALID_ARGUMENT | Malformed request, bad parameters |
| 400 | FAILED_PRECONDITION | Free tier not supported in your region |
| 403 | PERMISSION_DENIED | API key invalid or model access denied |
| 404 | NOT_FOUND | Model not found or does not exist |
| 413 | RESOURCE_EXHAUSTED | Request too large (input tokens) |
| 429 | RESOURCE_EXHAUSTED | Rate limit exceeded (RPM/TPM/RPD) |
| 500 | INTERNAL | Google server error |
| 503 | UNAVAILABLE | Service temporarily unavailable |

### Error Response Format

```json
{
  "error": {
    "code": 429,
    "message": "Resource has been exhausted (e.g. check quota).",
    "status": "RESOURCE_EXHAUSTED"
  }
}
```

### Safety Block Response

When content is blocked by safety filters, `finishReason` is `SAFETY` and `candidates` may be empty:

```json
{
  "candidates": [],
  "promptFeedback": {
    "blockReason": "SAFETY",
    "safetyRatings": [
      {
        "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
        "probability": "HIGH"
      }
    ]
  }
}
```

---

## Code Examples

### Python — Basic Generation (Google SDK)

```python
import google.generativeai as genai

genai.configure(api_key="AIzaSy...")

model = genai.GenerativeModel(
    model_name="gemini-2.0-flash",
    system_instruction="You are a concise technical writer."
)

response = model.generate_content(
    "Explain REST APIs in 3 bullet points.",
    generation_config=genai.types.GenerationConfig(
        temperature=0.5,
        max_output_tokens=256
    )
)

print(response.text)
print(f"Tokens used: {response.usage_metadata.total_token_count}")
```

### Python — Multi-Turn Chat

```python
import google.generativeai as genai

genai.configure(api_key="AIzaSy...")
model = genai.GenerativeModel("gemini-2.0-flash")

chat = model.start_chat()

response = chat.send_message("What is machine learning?")
print(response.text)

response = chat.send_message("Give me a simple Python example.")
print(response.text)
```

### Python — Vision (Image Analysis)

```python
import google.generativeai as genai
from PIL import Image

genai.configure(api_key="AIzaSy...")
model = genai.GenerativeModel("gemini-2.0-flash")

image = Image.open("chart.png")
response = model.generate_content(["Analyze this chart and summarize the key trends.", image])
print(response.text)
```

### Python — Streaming

```python
import google.generativeai as genai

genai.configure(api_key="AIzaSy...")
model = genai.GenerativeModel("gemini-2.5-flash")

for chunk in model.generate_content("Write a detailed essay on climate change.", stream=True):
    print(chunk.text, end="", flush=True)
```

### Python — Structured JSON Output

```python
import google.generativeai as genai
import json

genai.configure(api_key="AIzaSy...")

model = genai.GenerativeModel(
    "gemini-2.0-flash",
    generation_config={"response_mime_type": "application/json"}
)

response = model.generate_content(
    "List 3 planets with their diameter in km. Return as JSON array."
)
data = json.loads(response.text)
print(data)
```

### Python — Embeddings

```python
import google.generativeai as genai

genai.configure(api_key="AIzaSy...")

result = genai.embed_content(
    model="models/text-embedding-004",
    content="The Gemini API provides state-of-the-art language models.",
    task_type="RETRIEVAL_DOCUMENT"
)

print(f"Embedding dimensions: {len(result['embedding'])}")
print(f"First 5 values: {result['embedding'][:5]}")
```

### cURL — Basic Request

```bash
curl -X POST \
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "contents": [
      {
        "role": "user",
        "parts": [{"text": "What is 2+2?"}]
      }
    ]
  }'
```

### JavaScript — Node.js

```javascript
import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

const result = await model.generateContent("Summarize the water cycle.");
console.log(result.response.text());
```

---

## List Models Endpoint

```
GET https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_API_KEY
```

Returns all available models with their supported generation methods, input token limits, and output token limits.

---

*Sources: [Gemini API Reference](https://ai.google.dev/api/generate-content) | [Quickstart](https://ai.google.dev/gemini-api/docs/quickstart) | [Models](https://ai.google.dev/gemini-api/docs/models) | [Pricing](https://ai.google.dev/gemini-api/docs/pricing) | [Rate Limits](https://ai.google.dev/gemini-api/docs/rate-limits)*
