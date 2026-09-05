# Anthropic API (Claude) — Use Cases & Practical Summary

**Source:** https://docs.anthropic.com/en/api/getting-started | https://docs.anthropic.com/en/api/messages | https://docs.anthropic.com/en/docs/about-claude/models
**Date documented:** 2026-02-27

---

## What Claude Can Do

Claude is Anthropic's family of large language models, accessible via API. It handles:

- Long-form text generation and summarization
- Complex reasoning and multi-step problem solving (with extended thinking)
- Code generation, review, and debugging
- Image understanding and description (vision)
- Structured data extraction from unstructured text
- Agentic tool calling (function calling to interact with APIs, databases, etc.)
- Document analysis (PDFs, contracts, books — up to 1M tokens)
- Conversational AI and chatbots
- Translation across dozens of languages
- Batch processing of thousands of tasks at 50% cost reduction

---

## Model Selection Guide

| Situation                                       | Recommended Model     | Why                                          |
|-------------------------------------------------|-----------------------|----------------------------------------------|
| Maximum capability, complex tasks               | Claude Opus 4.6       | Most capable flagship model                  |
| Balanced daily workloads, coding, writing       | Claude Sonnet 4.6     | Best cost/capability ratio                   |
| High-volume, latency-sensitive applications     | Claude Haiku 4.5      | Fastest, cheapest                            |
| Deep multi-step reasoning (math, logic)         | Claude Opus 4.6 + extended thinking | Thorough step-by-step reasoning |
| Processing very large documents (>200K tokens)  | Sonnet 4.6 (1M beta)  | Extended context window                      |
| Bulk processing (>100 requests)                 | Any model via Batch API | 50% discount                               |

---

## Project Ideas

| Project Idea                    | Recommended Setup                                          | Key API Features Used                              |
|---------------------------------|------------------------------------------------------------|----------------------------------------------------|
| Contract review assistant       | Sonnet 4.6 + prompt caching for legal system prompt       | Prompt caching, vision (for PDF pages), tools      |
| Customer support chatbot        | Haiku 4.5 (speed + cost) with escalation to Opus          | Multi-turn messages, tool use, streaming            |
| Automated code reviewer         | Opus 4.6 + extended thinking                              | Extended thinking, tool use for linting APIs        |
| Bulk content generation (blog)  | Sonnet 4.5 via Batch API                                  | Message Batches API, temperature control            |
| Research paper Q&A bot          | Sonnet 4.6 (1M context) + prompt caching on the paper     | Long context, prompt caching, RAG substitute        |
| Invoice data extractor          | Haiku 4.5 + vision + structured output                    | Vision (image input), tool use for JSON extraction  |
| Math/science homework helper    | Opus 4.6 with extended thinking                           | Extended thinking, LaTeX tool                       |
| Multilingual translation pipeline | Haiku 4.5 via Batch API                                 | Batch API, temperature=0 for consistency            |
| AI agent with web access        | Opus 4.6 + tool use loop                                  | Tool use, agentic loop, streaming                   |
| Document summarization pipeline | Sonnet 4.6 + prompt caching for instructions              | Prompt caching, Batch API                           |

---

## Key Limits & Constraints

### Context Window Limits

| Model             | Context Window      | Max Output Tokens |
|-------------------|---------------------|-------------------|
| Claude Opus 4.6   | 200K (1M in beta)   | 128K              |
| Claude Sonnet 4.6 | 200K (1M in beta)   | 64K               |
| Claude Haiku 4.5  | 200K                | 16K               |

Note: 1M context requires Tier 4 API access and the `anthropic-beta: context-1m-2025-08-07` header.

### Rate Limits (Tier 1 defaults for new accounts)

- 50 requests per minute
- 50,000 input tokens per minute
- 10,000 output tokens per minute
- $100/month spend cap

Upgrade tiers by spending more: Tier 2 at $40 cumulative, Tier 3 at $200, Tier 4 at $400.

### Batch API Limits

- Maximum 10,000 requests per batch
- Maximum 24-hour processing time
- Results arrive as a JSONL file, not in order — always use `custom_id` to match responses

### Prompt Caching Limits

- Minimum cacheable size: 1024 tokens (Opus), 2048 tokens (Sonnet/Haiku)
- Maximum cache points per request: 4 (you can mark 4 blocks with `cache_control`)
- Default cache TTL: 5 minutes
- Extended TTL: 1 hour (costs 2x on write, still 0.1x on read)

### Extended Thinking Limits

- Minimum `budget_tokens`: 1024
- `budget_tokens` must be less than `max_tokens`
- Temperature must be 1.0 (default) — cannot change it when thinking is enabled
- Not compatible with streaming in older integrations — check SDK version

### Vision Limits

- Maximum 100 images per API request
- Supported formats: PNG, JPEG, GIF, WebP only
- Very large images may be automatically downscaled

---

## Gotchas & Common Mistakes

### 1. Forgetting `anthropic-version` header
Every request needs `anthropic-version: 2023-06-01`. Without it you get a 400 error. There is no newer version string — this header is frozen and correct as-is.

### 2. Setting both `temperature` and `top_p`
These are mutually exclusive sampling parameters. Setting both together produces unpredictable behavior. Choose one.

### 3. Setting temperature when using extended thinking
Extended thinking requires temperature to be at the default (1.0). Explicitly setting any other value causes an error.

### 4. `budget_tokens` >= `max_tokens`
`budget_tokens` must always be less than `max_tokens`. Set `max_tokens` generously — it covers both the thinking and the final response.

### 5. Treating prompt caching as free on first call
The first request that writes a cache costs 1.25x the normal rate. Caching only pays off if you reuse the cached content at least twice within the TTL window.

### 6. Assuming batch results are ordered
The Batch API JSONL results are not guaranteed to be in request order. Always use the `custom_id` field to match each result to its source request.

### 7. Using stop sequences that appear in the output naturally
If a stop sequence like `"."` or `"1."` appears in normal text, generation stops prematurely. Use unique sequences like `"</DONE>"` or `"###END###"`.

### 8. Not handling 529 overload errors
The API can return 529 during peak usage. Always implement retry logic with exponential backoff for both 429 (rate limit) and 529 (overload).

### 9. Sending messages that don't start with `user` role
The `messages` array must begin with a `user` message. An `assistant` message first causes a 400 error.

### 10. Trying to edit assistant messages mid-stream
Once streaming starts, you cannot modify the request. Pre-validate all parameters before calling with `stream: true`.

### 11. Prompt caching minimum size traps
If your cached content is below 1024 tokens (Opus) or 2048 tokens (Sonnet/Haiku), the cache write is silently ignored — you pay full price every time but think you are caching. Check `cache_creation_input_tokens` in the `usage` response field.

### 12. Vision with unsupported formats
Only PNG, JPEG, GIF, and WebP are supported. Sending a TIFF, BMP, or SVG returns an error. Convert images first.

---

## Cost Optimization Strategies

1. **Use Haiku for triage, Opus for escalation** — Run Haiku first to classify/filter. Only send complex cases to Opus. Haiku is 15x cheaper than Opus per token.

2. **Prompt caching for repeated context** — If your system prompt or document is >2048 tokens and reused across requests, caching reduces cost by 90% on reads. ROI is achieved on the 2nd request.

3. **Batch API for non-real-time workloads** — Any task that doesn't need an immediate response (report generation, bulk translation, classification) should use the Batch API for its 50% discount.

4. **temperature=0 for deterministic tasks** — Classification, extraction, and summarization with temperature=0 gives more consistent outputs, reducing the need for retries due to bad outputs.

5. **Use `max_tokens` wisely** — Set `max_tokens` to the actual expected output size, not 4096 by default. You are only billed for tokens actually generated, but setting this low prevents Claude from completing long responses.

6. **Streaming for perceived performance** — For user-facing applications, streaming with `stream: true` makes responses feel instant even when the full response takes seconds. The user sees output immediately.
