# Exa Search API — Technical Reference

**Source:** https://docs.exa.ai/reference/getting-started | https://docs.exa.ai/reference/search | https://docs.exa.ai/reference/contents-retrieval | https://exa.ai/pricing
**Date:** 2026-02-27

---

## Overview

Exa is an AI-native web search API built for use in AI applications, agents, and pipelines. Unlike traditional search engines that match keywords, Exa uses **semantic (neural) search** — it converts queries and web pages into high-dimensional vector embeddings that capture meaning, enabling concept-level matching rather than literal string matching.

Exa is designed for programmatic consumption: every response is structured JSON, there is no rate-limit-inducing scraping, and content retrieval (full page text, highlights, summaries) is built into the same API call or a companion endpoint.

**Base URL:** `https://api.exa.ai`

---

## Authentication

All requests require an API key passed as a request header:

```
x-api-key: YOUR_EXA_API_KEY
```

Get your key at: https://dashboard.exa.ai

There is no OAuth flow. The key is a static secret that should be stored in environment variables and never committed to source control.

---

## Search Types

Exa supports multiple search engine modes, selected via the `type` parameter:

| Type | Description | Best For |
|------|-------------|----------|
| `auto` | Default. Intelligently selects the best engine based on the query. High quality. | General-purpose queries |
| `neural` | Pure embeddings-based semantic search using Exa's next-link prediction model | Concept-level, meaning-based queries |
| `keyword` | Traditional keyword matching | Exact phrase lookup, named entities, acronyms |
| `fast` | Streamlined neural model — sub-350ms P50 latency (Exa 2.0) | Real-time applications requiring lowest latency |
| `deep` | Light agentic deep search — retrieves high-quality results across multiple hops | Research requiring broad coverage |
| `deep-reasoning` | Base deep search with reasoning | Complex factual or analytical questions |
| `deep-max` | Maximum-effort deep search | Highest-quality results, longer latency |

**Exa 2.0 (released October 2025)** introduced `fast`, `deep`, `deep-reasoning`, and `deep-max` as new search types, and upgraded the quality of `auto` significantly.

---

## Endpoint: POST /search

**URL:** `https://api.exa.ai/search`

Searches the web and returns a ranked list of URLs with metadata. Optionally returns content inline.

### Request Headers

```
Content-Type: application/json
x-api-key: YOUR_EXA_API_KEY
```

### Request Body Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | string | Yes | — | The search query. For neural search, phrase as a sentence or as the first sentence of an ideal result page. |
| `numResults` | integer | No | 10 | Number of results to return. Range varies by search type; up to 10,000 for some types. |
| `type` | string | No | `"auto"` | Search engine type. See Search Types table above. |
| `useAutoprompt` | boolean | No | `false` | When `true`, Exa rewrites the query to optimize it for neural search. Useful when the query is short or ambiguous. |
| `includeDomains` | string[] | No | — | Restrict results to only these domains (e.g., `["arxiv.org", "nature.com"]`). |
| `excludeDomains` | string[] | No | — | Exclude results from these domains. |
| `startPublishedDate` | string | No | — | ISO 8601 date. Only return results published on or after this date. |
| `endPublishedDate` | string | No | — | ISO 8601 date. Only return results published on or before this date. |
| `startCrawlDate` | string | No | — | Only return results that Exa first crawled on or after this date. |
| `endCrawlDate` | string | No | — | Only return results that Exa first crawled on or before this date. |
| `category` | string | No | — | Focus results on a specific content category. See Categories below. |
| `includeText` | string[] | No | — | Only return results whose content includes all of these strings. Requires `livecrawl`. |
| `excludeText` | string[] | No | — | Exclude results whose content includes any of these strings. Requires `livecrawl`. |
| `contents` | object | No | — | If provided, retrieves page content inline with search results. See Contents Object below. |

### Categories

| Category | Notes |
|----------|-------|
| `"research paper"` | Academic papers |
| `"news"` | News articles |
| `"tweet"` | Twitter/X posts |
| `"linkedin profile"` | LinkedIn personal profiles |
| `"company"` | Company pages — improved quality for company lookups |
| `"people"` | LinkedIn-style people pages — improved quality for finding individuals |
| `"pdf"` | PDF documents |
| `"github"` | GitHub repositories |
| `"financial report"` | SEC filings and investor reports |

**Note:** The `company` and `people` categories do NOT support date filters (`startPublishedDate`, `endPublishedDate`, `startCrawlDate`, `endCrawlDate`) or text filters (`includeText`, `excludeText`, `excludeDomains`).

### Contents Object (inline content retrieval)

You can request page content directly within the search response by including a `contents` key:

```json
"contents": {
  "text": true,
  "highlights": {
    "numSentences": 3,
    "highlightsPerUrl": 5,
    "query": "your highlight query"
  },
  "summary": {
    "query": "summarize this page about X"
  },
  "livecrawl": "always"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `text` | boolean or object | Return full page text as markdown. Set to `true` for defaults or pass an object with `maxCharacters`. |
| `highlights` | object | Return the most query-relevant excerpts from each page. `numSentences` controls excerpt length; `highlightsPerUrl` controls how many excerpts per page. |
| `summary` | object | Return an LLM-generated abstractive summary of each page. Pass a `query` to tailor the summary. Structured summaries can be requested via a JSON schema. |
| `livecrawl` | string | `"always"` forces a live crawl of the URL at request time (bypasses cache). Required for `includeText`, `excludeText`, `verbosity`, `includeSections`, `excludeSections`. `"fallback"` uses cache when available. |

### Example Request

```bash
curl -X POST https://api.exa.ai/search \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_KEY" \
  -d '{
    "query": "recent advances in transformer model efficiency",
    "numResults": 10,
    "type": "neural",
    "useAutoprompt": true,
    "category": "research paper",
    "startPublishedDate": "2025-01-01",
    "includeDomains": ["arxiv.org", "semanticscholar.org"],
    "contents": {
      "highlights": {
        "numSentences": 2,
        "highlightsPerUrl": 3
      }
    }
  }'
```

### Example Response

```json
{
  "requestId": "abc123",
  "autopromptString": "The most recent research papers on transformer model efficiency improvements",
  "results": [
    {
      "id": "https://arxiv.org/abs/2501.12345",
      "url": "https://arxiv.org/abs/2501.12345",
      "title": "FlashAttention-3: Efficient Attention for Modern Hardware",
      "score": 0.892,
      "publishedDate": "2025-02-10",
      "author": "Tri Dao et al.",
      "highlights": [
        "We introduce FlashAttention-3, which achieves 1.5–2x speedup over FlashAttention-2 on H100 GPUs.",
        "Our method reduces HBM memory reads/writes by tiling the attention computation."
      ],
      "highlightScores": [0.95, 0.91]
    }
  ]
}
```

---

## Endpoint: POST /contents

**URL:** `https://api.exa.ai/contents`

Retrieves full content (text, highlights, or summaries) for a list of URLs. Use this when you have URLs from a previous search and want to fetch content separately, or when you have known URLs you want to retrieve content for directly.

### Request Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `ids` | string[] | Yes | List of URLs to retrieve content for. |
| `text` | boolean or object | No | Return full page text as markdown. |
| `highlights` | object | No | Return key excerpts. Same structure as in `/search`. |
| `summary` | object | No | Return LLM-generated summary. Same structure as in `/search`. |
| `livecrawl` | string | No | `"always"` to force live crawl; `"fallback"` to use cache when available. |
| `subpages` | integer | No | Number of subpages to crawl from each URL (explores internal links). |

### Example Request

```bash
curl -X POST https://api.exa.ai/contents \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_KEY" \
  -d '{
    "ids": [
      "https://arxiv.org/abs/2501.12345",
      "https://arxiv.org/abs/2501.67890"
    ],
    "text": { "maxCharacters": 5000 },
    "summary": { "query": "key contributions and results" },
    "livecrawl": "fallback"
  }'
```

### Example Response

```json
{
  "results": [
    {
      "id": "https://arxiv.org/abs/2501.12345",
      "url": "https://arxiv.org/abs/2501.12345",
      "title": "FlashAttention-3",
      "text": "Abstract: We present FlashAttention-3...\n\nIntroduction: ...",
      "summary": "The paper introduces FlashAttention-3, achieving 1.5-2x speedup over its predecessor on H100 GPUs through improved memory tiling."
    }
  ]
}
```

---

## Endpoint: POST /findSimilar

**URL:** `https://api.exa.ai/findSimilar`

Finds web pages that are semantically similar to a given URL. Useful for finding related articles, competitor pages, alternative sources, or content for topic clustering.

### Request Body Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | Yes | The reference URL to find similar pages for. |
| `numResults` | integer | No | Number of similar results to return. |
| `includeDomains` | string[] | No | Restrict to these domains. |
| `excludeDomains` | string[] | No | Exclude these domains. |
| `excludeSourceDomain` | boolean | No | If `true`, exclude results from the same domain as the reference URL. |
| `startPublishedDate` | string | No | ISO 8601 date filter. |
| `endPublishedDate` | string | No | ISO 8601 date filter. |
| `contents` | object | No | Inline content retrieval (same structure as `/search`). |

### Example Request

```bash
curl -X POST https://api.exa.ai/findSimilar \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_KEY" \
  -d '{
    "url": "https://openai.com/research/gpt-4",
    "numResults": 5,
    "excludeSourceDomain": true,
    "startPublishedDate": "2024-01-01"
  }'
```

---

## Pricing (as of early 2026)

| Search Type | 1–25 results | 26–100 results | 100+ results |
|-------------|-------------|----------------|--------------|
| Neural (`neural`) | $0.005 | $0.025 | $1.00 |
| Auto (`auto`) | $0.005 | $0.025 | $1.00 |
| Fast (`fast`) | Lower than neural | — | — |
| Deep (`deep`) | $0.015 | $0.075 | — |
| Contents retrieval | $1.00 / 1,000 pages | — | — |
| Find Similar | Same as neural | — | — |

**Free Tier:** $10 in credits with no expiration and no credit card required (approximately 2,000 standard searches).

Pricing page: https://exa.ai/pricing

---

## Python SDK Quick Reference

Install: `pip install exa-py`

```python
from exa_py import Exa

exa = Exa(api_key="YOUR_EXA_API_KEY")

# Basic search
results = exa.search(
    "recent transformer efficiency papers",
    num_results=10,
    type="neural",
    use_autoprompt=True,
    category="research paper",
    start_published_date="2025-01-01",
    include_domains=["arxiv.org"]
)

# Search with inline highlights
results = exa.search_and_get_contents(
    "best practices for RAG systems",
    num_results=5,
    highlights={"num_sentences": 3, "highlights_per_url": 2}
)

# Get contents for known URLs
content = exa.get_contents(
    ["https://arxiv.org/abs/2501.12345"],
    text=True,
    summary={"query": "main contributions"}
)

# Find similar pages
similar = exa.find_similar(
    "https://anthropic.com/claude",
    num_results=10,
    exclude_source_domain=True
)
```

---

## Additional Endpoints (Exa 2.0+)

| Endpoint | Description |
|----------|-------------|
| `POST /answer` | Generates a direct answer to a question by searching and synthesizing results |
| `POST /research` | Multi-agent research coordination for complex questions |
| Websets API | Manage large-scale structured query sets for ongoing monitoring |

---

## Error Codes

| HTTP Status | Meaning |
|------------|---------|
| 400 | Bad Request — invalid parameters |
| 401 | Unauthorized — missing or invalid `x-api-key` |
| 422 | Unprocessable Entity — parameter conflict (e.g., unsupported filter for category) |
| 429 | Rate limit exceeded |
| 500 | Exa server error |

---

## Endpoint: POST /answer

**URL:** `https://api.exa.ai/answer`

Generates a direct Q&A answer with citations from web search results.

### Example Request

```bash
curl -X POST https://api.exa.ai/answer \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_KEY" \
  -d '{
    "query": "What is the latest GPT model?",
    "text": { "max_characters": 20000 }
  }'
```

---

## Content Freshness (maxAgeHours)

Controls how fresh cached content must be before Exa triggers a live crawl:

| Value | Behavior | Best For |
|-------|----------|----------|
| 24 | Use cache if < 24h old, else livecrawl | Daily-fresh content |
| 1 | Use cache if < 1h old, else livecrawl | Near real-time data |
| 0 | Always livecrawl (ignore cache) | Real-time data |
| -1 | Never livecrawl (cache only) | Max speed, static content |
| *(omit)* | Default (livecrawl as fallback if no cache) | Recommended — balanced |

---

## MCP Server (Claude Code Integration)

Installed as HTTP transport MCP server with all tools enabled:

```bash
claude mcp add --transport http exa "https://mcp.exa.ai/mcp?exaApiKey=YOUR_KEY&tools=web_search_exa,web_search_advanced_exa,get_code_context_exa,crawling_exa,company_research_exa,people_search_exa,deep_researcher_start,deep_researcher_check" -s user
```

**MCP Tools:**
| Tool | Description |
|------|-------------|
| `web_search_exa` | Standard web search |
| `web_search_advanced_exa` | Advanced search with all filters |
| `get_code_context_exa` | Search for code context/examples |
| `crawling_exa` | Crawl and extract content from URLs |
| `company_research_exa` | Company research and lookup |
| `people_search_exa` | People search |
| `deep_researcher_start` | Start async deep research |
| `deep_researcher_check` | Check deep research status/results |

---

## References

- API Reference (Search): https://docs.exa.ai/reference/search
- API Reference (Contents): https://docs.exa.ai/reference/contents-retrieval
- API Reference (Answer): https://docs.exa.ai/reference/answer
- Getting Started: https://docs.exa.ai/reference/getting-started
- Pricing: https://exa.ai/pricing
- Exa 2.0 Announcement: https://exa.ai/blog/exa-api-2-0
- Python SDK (exa-py): https://github.com/exa-labs/exa-py
- Exa MCP Server: https://docs.exa.ai/reference/exa-mcp
- Dashboard: https://dashboard.exa.ai
- API Status: https://status.exa.ai
