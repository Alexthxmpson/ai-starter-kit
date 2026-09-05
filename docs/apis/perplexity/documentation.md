# Perplexity API — Technical Documentation

**Source:** https://docs.perplexity.ai/api-reference/chat-completions-post | https://docs.perplexity.ai/guides/getting-started
**Date:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Base URL](#base-url)
4. [Chat Completions Endpoint](#chat-completions-endpoint)
5. [Request Parameters](#request-parameters)
6. [Response Format](#response-format)
7. [Citations & Web Search](#citations--web-search)
8. [Available Models](#available-models)
9. [Streaming](#streaming)
10. [Rate Limits](#rate-limits)
11. [Pricing](#pricing)
12. [Error Codes](#error-codes)
13. [Code Examples](#code-examples)

---

## Overview

Perplexity's Sonar API provides an OpenAI-compatible chat completions interface that combines large language model inference with **real-time web search**. Unlike pure LLM APIs, every request automatically retrieves and grounds responses in live web sources, returning citations alongside the answer.

Key differentiators:
- Real-time web search built into every inference call
- Citations returned as structured URLs in the response
- OpenAI-compatible endpoint — drop-in for many existing integrations
- Search recency filtering (hour, day, week, month)
- Search context size control (low, medium, high)

---

## Authentication

All requests require a Bearer token in the `Authorization` header.

```http
Authorization: Bearer pplx-...YOUR_API_KEY...
```

**Environment variable convention:**

```bash
export PERPLEXITY_API_KEY="pplx-..."
```

API keys are obtained from the [Perplexity API Platform](https://sonar.perplexity.ai/).

---

## Base URL

```
https://api.perplexity.ai
```

---

## Chat Completions Endpoint

**Method:** `POST`
**URL:** `https://api.perplexity.ai/chat/completions`

This is the only primary inference endpoint. It is OpenAI-compatible, meaning existing OpenAI client libraries work by changing the `base_url`.

---

## Request Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | string | Model ID (see Models section) |
| `messages` | array | Array of `{role, content}` objects |

### Message Roles

| Role | Description |
|------|-------------|
| `system` | Sets context and behavior |
| `user` | Human turn |
| `assistant` | Model's prior response |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `max_tokens` | integer | — | Max tokens to generate |
| `temperature` | float | 0.2 | 0.0–2.0. Randomness control |
| `top_p` | float | 0.9 | Nucleus sampling probability mass |
| `top_k` | integer | 0 | Top-k sampling (0 = disabled) |
| `stream` | boolean | false | Stream response via SSE |
| `presence_penalty` | float | 0 | -2.0 to 2.0. Penalizes new topics |
| `frequency_penalty` | float | 1 | >0 reduces token repetition |
| `search_recency_filter` | string | — | `"hour"`, `"day"`, `"week"`, `"month"` |
| `search_context_size` | string | `"medium"` | `"low"`, `"medium"`, `"high"` |
| `return_citations` | boolean | true | Include citations in response |
| `return_images` | boolean | false | Include image results |
| `return_related_questions` | boolean | false | Suggest follow-up questions |
| `reasoning_effort` | string | — | For reasoning models: `"low"`, `"medium"`, `"high"` |

---

## Response Format

### Standard Response

```json
{
  "id": "chatcmpl-abc123",
  "model": "sonar-pro",
  "object": "chat.completion",
  "created": 1740000000,
  "choices": [
    {
      "index": 0,
      "finish_reason": "stop",
      "message": {
        "role": "assistant",
        "content": "The Eiffel Tower was built between 1887 and 1889 [1][2]."
      },
      "delta": {"role": "assistant", "content": ""}
    }
  ],
  "usage": {
    "prompt_tokens": 14,
    "completion_tokens": 22,
    "total_tokens": 36,
    "citation_tokens": 8,
    "num_search_queries": 1
  },
  "citations": [
    "https://en.wikipedia.org/wiki/Eiffel_Tower",
    "https://www.toureiffel.paris/en/the-monument/history"
  ],
  "search_results": [
    {
      "title": "Eiffel Tower - Wikipedia",
      "url": "https://en.wikipedia.org/wiki/Eiffel_Tower",
      "date": "2026-01-15",
      "snippet": "The Eiffel Tower is a wrought-iron lattice tower..."
    }
  ],
  "related_questions": [
    "Who designed the Eiffel Tower?",
    "How tall is the Eiffel Tower?"
  ]
}
```

### Citation Inline Format

Citations appear inline in the `content` field as `[1]`, `[2]`, etc., matching indices in the `citations` array.

### Finish Reasons

| Value | Meaning |
|-------|---------|
| `stop` | Natural completion |
| `length` | `max_tokens` reached |

---

## Citations & Web Search

### How Web Search Works

Every request to the Sonar API automatically triggers a web search before generation. The model:
1. Interprets the query
2. Performs one or more web searches (number tracked in `num_search_queries`)
3. Retrieves and reads source documents
4. Synthesizes an answer grounded in those sources
5. Returns citations as structured URLs

### Citation Billing (2026 Update)

Citation tokens are **no longer billed** for standard `sonar` and `sonar-pro` models. Citation tokens are still billed for `sonar-deep-research`.

### Search Context Size

Controls how much web content is retrieved per search. Larger context = higher quality = higher cost.

| Value | Web Content Retrieved | Cost Impact |
|-------|--------------------|-------------|
| `"low"` | Minimal snippets | Lowest |
| `"medium"` | Standard (default) | Moderate |
| `"high"` | Deep page content | Highest |

### Search Recency Filter

| Value | Restricts results to... |
|-------|------------------------|
| `"hour"` | Last 60 minutes |
| `"day"` | Last 24 hours |
| `"week"` | Last 7 days |
| `"month"` | Last 30 days |
| (omitted) | All time (default) |

---

## Available Models

### Current Model Lineup

| Model ID | Context Window | Notes |
|----------|---------------|-------|
| `sonar` | 128K tokens | Standard search-grounded model. Best cost/performance for most queries |
| `sonar-pro` | 200K tokens | Advanced search, 2× citations per search vs sonar, handles complex multi-step queries |
| `sonar-reasoning` | 128K tokens | Based on DeepSeek R1, chain-of-thought reasoning + web search. Uncensored, US datacenters |
| `sonar-reasoning-pro` | 200K tokens | Pro-tier reasoning model |
| `sonar-deep-research` | 128K tokens | Autonomous multi-step research: searches, reads, evaluates sources iteratively |

### Model Selection Guide

| Use Case | Recommended Model |
|----------|------------------|
| Quick factual Q&A, current events | `sonar` |
| Complex research queries, long context | `sonar-pro` |
| Step-by-step reasoning + citations | `sonar-reasoning` |
| Comprehensive research reports | `sonar-deep-research` |
| High-accuracy reasoning on hard problems | `sonar-reasoning-pro` |

---

## Streaming

Set `"stream": true` to receive responses via Server-Sent Events (SSE).

### Streaming Request

```bash
curl https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer pplx-..." \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar",
    "messages": [{"role": "user", "content": "Latest AI news today"}],
    "stream": true,
    "search_recency_filter": "day"
  }'
```

### Streaming Chunk Format

```json
data: {"id":"chatcmpl-abc123","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":"The"},"finish_reason":null}]}

data: {"id":"chatcmpl-abc123","object":"chat.completion.chunk","choices":[{"index":0,"delta":{"content":" latest"},"finish_reason":null}]}

data: [DONE]
```

---

## Rate Limits

| Model Tier | Default Rate Limit |
|------------|-------------------|
| All sonar online models | 50 requests/minute (RPM) |

Rate limits can be increased by contacting Perplexity support for high-volume use cases. Limits apply per API key.

---

## Pricing

### Token Pricing (per 1M tokens)

| Model | Input | Output | Reasoning Tokens | Search Queries | Citation Tokens |
|-------|-------|--------|-----------------|---------------|-----------------|
| `sonar` | $1 | $1 | — | $5/1K requests | Free (as of 2026) |
| `sonar-pro` | $3 | $15 | — | $5/1K requests | Free (as of 2026) |
| `sonar-reasoning` | $1 | $5 | $3/1M | $5/1K requests | Free |
| `sonar-deep-research` | $2 | $8 | $3/1M | $5/1K requests | $2/1M |

### Search API (Raw Results)
- $5 per 1,000 requests — returns raw web results without synthesis

### Cost Calculation Example (sonar-pro)

Query with 500 input tokens, 800 output tokens, 2 search queries:
```
Input:   500 / 1,000,000 × $3    = $0.0015
Output:  800 / 1,000,000 × $15   = $0.012
Search:  2   / 1,000      × $5   = $0.01
Total:                             $0.0235 per request
```

---

## Error Codes

| HTTP Code | Description |
|-----------|-------------|
| 400 | Bad Request — malformed JSON or invalid parameters |
| 401 | Unauthorized — missing or invalid API key |
| 403 | Forbidden — key lacks permission |
| 422 | Unprocessable Entity — parameter validation failure |
| 429 | Too Many Requests — rate limit exceeded |
| 500 | Internal Server Error — Perplexity server error |
| 503 | Service Unavailable — temporary outage |

### Error Response Format

```json
{
  "error": {
    "message": "You exceeded your rate limit.",
    "type": "rate_limit_exceeded",
    "code": 429
  }
}
```

---

## Code Examples

### Python (using OpenAI SDK)

```python
from openai import OpenAI

client = OpenAI(
    api_key="pplx-...",
    base_url="https://api.perplexity.ai"
)

response = client.chat.completions.create(
    model="sonar-pro",
    messages=[
        {"role": "system", "content": "Be precise and concise."},
        {"role": "user", "content": "What are the latest AI model releases in 2026?"}
    ],
    temperature=0.2,
    search_recency_filter="month"
)

print(response.choices[0].message.content)
print("\nCitations:")
for i, url in enumerate(response.citations, 1):
    print(f"[{i}] {url}")
```

### Python (streaming)

```python
from openai import OpenAI

client = OpenAI(api_key="pplx-...", base_url="https://api.perplexity.ai")

stream = client.chat.completions.create(
    model="sonar",
    messages=[{"role": "user", "content": "Summarize today's tech news"}],
    stream=True,
    search_recency_filter="day"
)

for chunk in stream:
    delta = chunk.choices[0].delta
    if delta.content:
        print(delta.content, end="", flush=True)
```

### cURL — Basic Request

```bash
curl -X POST https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer pplx-..." \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar",
    "messages": [
      {"role": "user", "content": "What is the current Bitcoin price?"}
    ],
    "search_recency_filter": "hour",
    "return_citations": true
  }'
```

### cURL — Deep Research

```bash
curl -X POST https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer pplx-..." \
  -H "Content-Type: application/json" \
  -d '{
    "model": "sonar-deep-research",
    "messages": [
      {
        "role": "user",
        "content": "Write a comprehensive analysis of the current state of quantum computing hardware."
      }
    ],
    "reasoning_effort": "high"
  }'
```

### JavaScript / Node.js

```javascript
const response = await fetch("https://api.perplexity.ai/chat/completions", {
  method: "POST",
  headers: {
    "Authorization": `Bearer ${process.env.PERPLEXITY_API_KEY}`,
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    model: "sonar-pro",
    messages: [
      { role: "user", content: "What are the best programming languages to learn in 2026?" }
    ],
    search_recency_filter: "month",
    return_related_questions: true
  })
});

const data = await response.json();
console.log(data.choices[0].message.content);
console.log("Related questions:", data.related_questions);
```

---

## Multi-Turn Conversation

The API is stateless. Maintain conversation history client-side and pass all prior messages on each request.

```python
messages = [
    {"role": "system", "content": "You are a research assistant."}
]

# Turn 1
messages.append({"role": "user", "content": "Who won the 2025 Nobel Prize in Physics?"})
response = client.chat.completions.create(model="sonar", messages=messages)
assistant_reply = response.choices[0].message.content
messages.append({"role": "assistant", "content": assistant_reply})

# Turn 2 — model has context of prior exchange
messages.append({"role": "user", "content": "What was their research about?"})
response = client.chat.completions.create(model="sonar", messages=messages)
```

---

*Sources: [Perplexity Chat Completions API](https://docs.perplexity.ai/api-reference/chat-completions-post) | [Getting Started Guide](https://docs.perplexity.ai/guides/getting-started) | [Pricing](https://docs.perplexity.ai/docs/getting-started/pricing) | [Sonar Deep Research](https://docs.perplexity.ai/getting-started/models/models/sonar-deep-research)*
