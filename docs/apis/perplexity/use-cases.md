# Perplexity API — Practical Use Cases & Automation Ideas

**Date:** 2026-02-27

---

## What You Can Do (Grouped by Capability)

### Real-Time Web Search + LLM Answer
- Answer questions about current events, prices, news — without a knowledge cutoff
- Replace static FAQ bots with live, cited answers
- Research assistant that auto-pulls the latest sources
- Competitive intelligence: monitor competitor announcements, pricing, news
- Track regulatory changes, court rulings, industry updates

### Citation-Grounded Responses
- Generate research summaries with verifiable source links
- Build tools that require traceable answers (legal, medical, compliance use cases)
- Fact-check pipeline: pass claims, get cited verdicts
- Academic-style research synthesis with automatic bibliography

### Reasoning + Search (sonar-reasoning)
- Multi-step math or logic problems that need current data (e.g., live stock calculations)
- Code debugging with search for library docs and Stack Overflow answers
- Strategic analysis combining reasoning chains with recent market data

### Deep Research (sonar-deep-research)
- Generate comprehensive reports on complex topics autonomously
- Investment research: synthesize financials, news, and analyst reports
- Literature reviews pulling from recent publications
- Long-form competitive landscape analysis

### Recency-Filtered Search
- "What happened in the last hour" monitoring dashboards
- Breaking news summarization
- Live event tracking (sports scores, election results, market moves)
- Daily/weekly digest generation

---

## Automation & Project Ideas

| Project | Model | Use | Complexity |
|---------|-------|-----|------------|
| Live news briefing bot (Slack/email daily) | `sonar` | `search_recency_filter: "day"` | Low |
| Competitive pricing monitor | `sonar` | Hourly recency filter, scrape competitor mentions | Low |
| Cited FAQ chatbot for compliance team | `sonar-pro` | Replace static doc search | Medium |
| Research report generator | `sonar-deep-research` | Long-form topic synthesis | Low |
| AI-powered stock/crypto news tracker | `sonar` | `search_recency_filter: "hour"` | Low |
| Legal precedent research assistant | `sonar-pro` | Case law + citations | Medium |
| Product feature comparison tool | `sonar-pro` | Input 2 products, get cited comparison | Low |
| Academic paper literature review | `sonar-deep-research` | Synthesize recent research | Low |
| Customer support agent with live docs | `sonar` | Replace static knowledge base | Medium |
| Breaking news alert system | `sonar` | Poll on schedule, filter by topic | Medium |
| Reasoning + search for math tutoring | `sonar-reasoning` | Show working + cite sources | Medium |
| SEO content with citations | `sonar-pro` | Generate blog posts with real sources | Low |
| Market research report automation | `sonar-deep-research` | Full reports on demand | Low |
| Fact-checking pipeline for content | `sonar` | Input claim → cited verdict | Medium |
| Travel assistant with current conditions | `sonar` | Real-time flight/weather/visa info | Low |

---

## Key Limits & Gotchas

### Context Window

| Model | Context Window | Practical Implication |
|-------|---------------|----------------------|
| `sonar` | 128K tokens | Good for most tasks; ~96,000 words |
| `sonar-pro` | 200K tokens | For very long documents or many-turn conversations |
| `sonar-reasoning` | 128K tokens | Reasoning steps consume extra tokens |
| `sonar-deep-research` | 128K tokens | Output can be very long; set max_tokens carefully |

### Search Limits
- Search queries are billed at **$5 per 1,000 requests** — separate from token costs
- Each API call triggers 1+ searches; `sonar-deep-research` may trigger many searches per call
- There is no option to disable web search — every call performs at least one search
- If you want pure LLM inference without search, use OpenAI or another provider

### Rate Limits
- **50 RPM** for all sonar models by default
- No per-day limits documented publicly
- 50 RPM = 3,000 requests/hour — sufficient for most automation but contact support for high-volume scraping pipelines

### API Design
- Stateless: no persistent threads or memory — you must send conversation history on every request
- No Assistants API equivalent — no file uploads, no code execution tools
- OpenAI-compatible: works with OpenAI Python/JS SDKs by changing `base_url` only

### Temperature Defaults
- Default temperature is **0.2** (conservative) — much lower than OpenAI's default of 1.0
- For creative tasks, set `temperature` to 0.7–1.0 explicitly

### Citation Availability
- Citations are returned as plain URLs, not structured metadata (no author, date, etc.)
- Citation tokens are **free** for `sonar` and `sonar-pro` as of 2026
- `sonar-deep-research` still charges $2/1M citation tokens
- Inline citation markers `[1]` in content map to indices in the `citations` array

### sonar-deep-research Behavior
- Much slower than other models — can take 30–120 seconds per response
- Use streaming to show progress to users
- Not suitable for real-time chat interfaces
- Best for background job / async processing

---

## Pricing Quick Reference

| Model | Per 1M Input | Per 1M Output | Per 1K Searches |
|-------|-------------|--------------|----------------|
| `sonar` | $1 | $1 | $5 |
| `sonar-pro` | $3 | $15 | $5 |
| `sonar-reasoning` | $1 | $5 + $3 reasoning | $5 |
| `sonar-deep-research` | $2 | $8 + $3 reasoning | $5 |

### Cost Estimation per 1,000 Calls (typical usage)

| Model | Avg tokens/call (in+out) | Estimated cost/1K calls |
|-------|------------------------|------------------------|
| `sonar` (short Q&A) | ~800 tokens | ~$5.80 |
| `sonar-pro` (research) | ~3,000 tokens | ~$59 |
| `sonar-deep-research` | ~10,000 tokens | ~$155+ |

---

## When to Use Perplexity vs Other APIs

| Situation | Use Perplexity? | Use Instead |
|-----------|----------------|-------------|
| Need real-time / post-cutoff information | Yes | — |
| Need cited, verifiable answers | Yes | — |
| Pure text generation (no web search needed) | No | OpenAI, Gemini |
| Image generation | No | OpenAI DALL-E |
| Audio transcription | No | OpenAI Whisper |
| Embeddings / semantic search | No | OpenAI, Gemini |
| Agent with tool use and memory | No | OpenAI Assistants |
| Very high volume (>50 RPM) | Caution | Scale requires support contact |
| Cost-sensitive pure inference | No | OpenAI gpt-4.1-mini at $0.40/1M |

---

## Drop-In OpenAI Replacement

If you already use the OpenAI Python SDK, switching to Perplexity is a one-line change:

```python
# Before (OpenAI)
client = OpenAI(api_key="sk-...")

# After (Perplexity — adds web search automatically)
client = OpenAI(
    api_key="pplx-...",
    base_url="https://api.perplexity.ai"
)
# The rest of your code is identical
```

---

*Sources: [Perplexity API Docs](https://docs.perplexity.ai/api-reference/chat-completions-post) | [Pricing](https://docs.perplexity.ai/docs/getting-started/pricing) | [Sonar Pro Blog](https://www.perplexity.ai/hub/blog/introducing-the-sonar-pro-api) | [Sonar Deep Research](https://docs.perplexity.ai/getting-started/models/models/sonar-deep-research)*
