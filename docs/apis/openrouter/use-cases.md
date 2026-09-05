# OpenRouter — Use Cases & Practical Guide

**Date:** 2026-03-05

---

## What You Can Do

### Free / No Auth Required
- Browse 400+ models and pricing at https://openrouter.ai/models
- Subscribe to the models RSS feed (`/api/v1/models?use_rss=true`) — no key needed
- Use free-tier models (those with pricing = "0") — rate-limited but no cost

### Paid / Requires Setup
- Send chat completion requests to any of 400+ models with a single API key
- Automatic fallback: if your primary model is down, try the next one
- Provider selection: route only to specific cloud providers (OpenAI, Azure, AWS Bedrock, Google, etc.)
- Structured outputs (JSON schema enforcement) across all supporting models
- Tool/function calling across all supporting models
- Multimodal requests (images, PDFs, audio, video) — model-dependent
- Streaming responses (SSE)
- BYOK: use your own provider API keys (no markup)
- ZDR routing: only use providers with Zero Data Retention
- Message transforms (middle-out compression for long contexts)

### What the API Cannot Do
- Cannot fine-tune models
- Cannot upload or host your own model
- No persistent threads/conversations (stateless like OpenAI)
- Rate limits apply on free-tier; specific limits depend on account tier

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key SDK / Endpoint |
|---|---|---|---|
| Swap OpenAI for OpenRouter in existing app | Easy | Change `baseURL` to `https://openrouter.ai/api/v1`, same key format | OpenAI SDK |
| Build a multi-model fallback pipeline | Easy | Use `models` array with ordered fallbacks | `POST /api/v1/chat/completions` |
| Cost optimizer: auto-select cheapest model | Easy | Use `openrouter/auto` as model ID | `POST /api/v1/chat/completions` |
| Model benchmark dashboard | Medium | Call `/api/v1/models`, compare pricing + context per family | `GET /api/v1/models` |
| Stream chat responses to UI | Easy | Set `stream: true`, parse SSE chunks | `POST /api/v1/chat/completions` |
| JSON-structured AI outputs | Medium | Set `response_format.type = json_schema` with your schema | `POST /api/v1/chat/completions` |
| AI with tool/function calling | Medium | Pass `tools` array + handle `tool_calls` in response | `POST /api/v1/chat/completions` |
| Vision / image analysis | Medium | Include `image_url` content parts — use vision models | `POST /api/v1/chat/completions` |
| PDF/document analysis | Medium | Include file content in messages — use multimodal models | `POST /api/v1/chat/completions` |
| Privacy-first AI routing | Easy | Set `provider.data_collection = "deny"` for ZDR providers | `POST /api/v1/chat/completions` |
| Monitor new model releases | Easy | Subscribe to RSS feed | `GET /api/v1/models?use_rss=true` |
| Claude via OpenRouter (cheaper) | Easy | Use `anthropic/claude-sonnet-4-5` model ID | OpenAI or OpenRouter SDK |
| Trigger.dev task with multi-model fallback | Medium | In TypeScript task: use `@openrouter/sdk` or `openai` with baseURL override | `@openrouter/sdk` |
| Discord bot with dynamic model selection | Medium | Use `/api/v1/models` to list models, let user pick, then chat | `POST /api/v1/chat/completions` |
| Track spend across models | Hard | Use `usage` field in each response, log to Airtable | `POST /api/v1/chat/completions` |

---

## Key Limits and Gotchas

### Rate Limits
- Free tier rate limits are calculated per account — see https://openrouter.ai/docs/faq#how-are-rate-limits-calculated
- Free models have stricter rate limits than paid models
- Adding credits to your account increases rate limits

### Pricing
- All pricing in USD per token (not per 1K tokens — multiply by 1M for $/1M tokens)
- `"0"` means the feature is free for that field (e.g. image input free on some models)
- Tokenization varies per model family — same text = different token count = different cost
- Always check `usage` in the response for actual billed tokens

### Model IDs
- Format: `{provider}/{model-slug}` e.g. `anthropic/claude-sonnet-4-5`
- Model IDs can change (new versions) — use `canonical_slug` for permanent references
- Check `supported_parameters` array before using `tools`, `reasoning`, `structured_outputs`

### BYOK (Bring Your Own Key)
- Pass your own provider key via a special header (documented in provider settings)
- No OpenRouter markup on BYOK tokens
- Still uses OpenRouter's routing/fallback infrastructure

### Compatibility
- Fully OpenAI-compatible — just change `baseURL`
- Not all parameters work on all models — check `supported_parameters`
- `reasoning` and `include_reasoning` only work on reasoning models (o3, DeepSeek R1, etc.)

### SDK
- `@openrouter/sdk` is Beta — prefer using `openai` SDK with `baseURL` override for production
- Both `HTTP-Referer` and `X-OpenRouter-Title` headers are optional but enable leaderboard visibility

### Error Handling
- HTTP 402 = out of credits (not a rate limit — add credits)
- HTTP 503 = provider down — use `models` array fallback to handle automatically
- Responses from different providers may have slightly different `finish_reason` values

---

## Available Scripts / Tools
- `npm install @openrouter/sdk` — official Beta SDK
- `npm install openai` — use with `baseURL: 'https://openrouter.ai/api/v1'`
- Request Builder: https://openrouter.ai/request-builder (generates code in any language)
- Models page: https://openrouter.ai/models (filter by modality, context, price, provider)
