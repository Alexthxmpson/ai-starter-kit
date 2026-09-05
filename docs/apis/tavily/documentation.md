# Tavily API — Full Technical Documentation

**Source:** https://docs.tavily.com
**Date saved:** 2026-03-05
**Key used:** `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`
**Env var:** `TAVILY_API_KEY`

---

## Authentication

All requests require a Bearer token:

```
Authorization: Bearer tvly-YOUR_API_KEY
```

API key format: `tvly-<key>`

---

## Base URL

```
https://api.tavily.com
```

---

## Endpoints Overview

| Endpoint | Method | Path | Description |
|----------|--------|------|-------------|
| Search | POST | `/search` | Web search with AI-curated results |
| Extract | POST | `/extract` | Extract content from specific URLs |
| Crawl | POST | `/crawl` | Crawl a site recursively |
| Map | POST | `/map` | Map site structure, return URL list |
| Research | POST | `/research` | AI-powered research with custom schemas |

---

## 1. Search Endpoint

**POST** `https://api.tavily.com/search`

### Request Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `query` | string | **Required** | The search query |
| `search_depth` | string | `basic` | `advanced` (2 credits), `basic` (1 credit), `fast` (1 credit), `ultra-fast` (1 credit) |
| `chunks_per_source` | integer | 3 | Max snippets per source (1-3); only with `advanced` depth |
| `max_results` | integer | 5 | Results to return (0-20) |
| `topic` | string | `general` | `general`, `news`, or `finance` |
| `time_range` | string | null | `day`/`d`, `week`/`w`, `month`/`m`, `year`/`y` |
| `start_date` | string | null | Filter results after date (YYYY-MM-DD) |
| `end_date` | string | null | Filter results before date (YYYY-MM-DD) |
| `include_answer` | bool/string | `false` | LLM-generated answer: `false`, `true`/`basic`, `advanced` |
| `include_raw_content` | bool/string | `false` | Full page content: `false`, `true`/`markdown`, `text` |
| `include_images` | boolean | `false` | Include image search results |
| `include_image_descriptions` | boolean | `false` | Add descriptive text for images |
| `include_favicon` | boolean | `false` | Include favicon URL per result |
| `include_domains` | array | `[]` | Whitelist up to 300 domains |
| `exclude_domains` | array | `[]` | Blacklist up to 150 domains |
| `country` | string | null | Boost results from specific country (general topic only) |
| `auto_parameters` | boolean | `false` | Auto-configure parameters (2 credits) |
| `exact_match` | boolean | `false` | Enforce exact phrase matching |
| `include_usage` | boolean | `false` | Include credit usage in response |

### Response Schema

```json
{
  "query": "string",
  "answer": "string (if include_answer=true)",
  "images": [
    {
      "url": "string",
      "description": "string (if include_image_descriptions=true)"
    }
  ],
  "results": [
    {
      "title": "string",
      "url": "string",
      "content": "string",
      "score": "float",
      "raw_content": "string (if include_raw_content=true)",
      "favicon": "string (if include_favicon=true)"
    }
  ],
  "auto_parameters": "object (if auto_parameters=true)",
  "response_time": "float",
  "usage": { "credits": "integer" },
  "request_id": "string (UUID)"
}
```

### Credit Cost
- `basic`, `fast`, `ultra-fast`: 1 credit/request
- `advanced`: 2 credits/request
- `auto_parameters=true`: 2 credits/request

---

## 2. Extract Endpoint

**POST** `https://api.tavily.com/extract`

### Request Parameters

| Parameter | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| `urls` | string or array | — | Yes | Single URL or list (max 20) |
| `query` | string | null | No | Rerank chunks by relevance to this query |
| `chunks_per_source` | integer | 3 | No | Max chunks per URL (1-5); requires `query` |
| `extract_depth` | string | `basic` | No | `basic` or `advanced` (tables + embedded content) |
| `include_images` | boolean | `false` | No | Include image URLs from pages |
| `include_favicon` | boolean | `false` | No | Include favicon URL per result |
| `format` | string | `markdown` | No | `markdown` or `text` |
| `timeout` | float | null | No | Max wait time in seconds (1.0-60.0); defaults: 10s basic, 30s advanced |
| `include_usage` | boolean | `false` | No | Include credit usage in response |

### Response Schema

```json
{
  "results": [
    {
      "url": "string",
      "raw_content": "string",
      "images": ["string"],
      "favicon": "string"
    }
  ],
  "failed_results": [
    {
      "url": "string",
      "error": "string"
    }
  ],
  "response_time": "float",
  "usage": { "credits": "integer" },
  "request_id": "string (UUID)"
}
```

### Credit Cost
- Basic: 1 credit per 5 successful extractions
- Advanced: 2 credits per 5 successful extractions
- Failed extractions are not charged

---

## 3. Crawl Endpoint

**POST** `https://api.tavily.com/crawl`

### Request Parameters

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| `url` | string | **Required** | — | Root URL to begin crawl |
| `instructions` | string | null | — | Natural language directives (doubles cost to 2 credits/10 pages) |
| `chunks_per_source` | integer | 3 | 1-5 | Max chunks per source |
| `max_depth` | integer | 1 | 1-5 | How far from base URL to explore |
| `max_breadth` | integer | 20 | 1-500 | Max links to follow per level |
| `limit` | integer | 50 | 1+ | Total pages to process before stopping |
| `select_paths` | array | null | — | Regex patterns for URL path inclusion |
| `select_domains` | array | null | — | Regex patterns for domain targeting |
| `exclude_paths` | array | null | — | Regex patterns for path exclusion |
| `exclude_domains` | array | null | — | Regex patterns for domain exclusion |
| `allow_external` | boolean | `true` | — | Include external domain links |
| `include_images` | boolean | `false` | — | Include images in results |
| `extract_depth` | string | `basic` | basic, advanced | Content extraction depth |
| `format` | string | `markdown` | markdown, text | Output format |
| `include_favicon` | boolean | `false` | — | Include favicon per result |
| `timeout` | number | 150 | 10-150 | Max seconds to wait |
| `include_usage` | boolean | `false` | — | Include credit usage |

### Response Schema

```json
{
  "base_url": "string",
  "results": [
    {
      "url": "string",
      "raw_content": "string",
      "favicon": "string"
    }
  ],
  "response_time": "float",
  "usage": { "credits": "integer" },
  "request_id": "string (UUID)"
}
```

### Credit Cost
- Without instructions: 1 credit per 10 successful pages
- With instructions: 2 credits per 10 successful pages
- Plus extraction cost: basic 1 credit/5, advanced 2 credits/5

---

## 4. Map Endpoint

**POST** `https://api.tavily.com/map`

### Request Parameters

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| `url` | string | **Required** | — | Root URL to begin mapping |
| `instructions` | string | null | — | Natural language guidance (doubles cost) |
| `max_depth` | integer | 1 | 1-5 | Max crawl depth from base URL |
| `max_breadth` | integer | 20 | 1-500 | Max links per level |
| `limit` | integer | 50 | 1+ | Total pages to process |
| `select_paths` | array | null | — | Regex for path inclusion |
| `select_domains` | array | null | — | Regex for domain scoping |
| `exclude_paths` | array | null | — | Regex for path exclusion |
| `exclude_domains` | array | null | — | Regex for domain exclusion |
| `allow_external` | boolean | `true` | — | Include external links in results |
| `timeout` | float | 150 | 10-150 | Max wait time in seconds |
| `include_usage` | boolean | `false` | — | Include credit usage in response |

### Response Schema

```json
{
  "base_url": "string",
  "results": ["array of discovered URLs"],
  "response_time": "float",
  "usage": { "credits": "integer" },
  "request_id": "string (UUID)"
}
```

### Credit Cost
- Standard: 1 credit per 10 successful pages
- With instructions: 2 credits per 10 successful pages

---

## 5. Research Endpoint

**POST** `https://api.tavily.com/research`

AI-powered research task that combines search + synthesis. Supports custom output schemas and citation formatting.

### Credit Cost
- `model=pro`: 15–250 credits per request
- `model=mini`: 4–110 credits per request

---

## SDKs

### Python
```bash
pip install tavily-python
```

```python
from tavily import TavilyClient

client = TavilyClient(api_key="tvly-YOUR_API_KEY")

# Search
response = client.search("Who is Leo Messi?")

# Extract
response = client.extract("https://en.wikipedia.org/wiki/AI")

# Crawl
response = client.crawl("https://docs.tavily.com",
    instructions="Find all pages on the Python SDK")

# Map
response = client.map("https://docs.tavily.com")
```

### JavaScript
```bash
npm install @tavily/core
```

```javascript
const { tavily } = require("@tavily/core");
const client = tavily({ apiKey: "tvly-YOUR_API_KEY" });

// Search
const results = await client.search("Who is Leo Messi?", {
  searchDepth: "advanced",
  maxResults: 10,
  topic: "general",
  includeAnswer: true
});

// Extract
const extracted = await client.extract(["https://example.com"], {
  extractDepth: "advanced",
  format: "markdown"
});

// Crawl
const crawled = await client.crawl("https://docs.tavily.com", {
  maxDepth: 2,
  limit: 100,
  instructions: "Focus on API reference pages"
});

// Map
const mapped = await client.map("https://docs.tavily.com");
```

---

## Pricing Tiers

| Plan | Credits/Month | Price | Per Credit |
|------|--------------|-------|------------|
| Free | 1,000 | $0 | — |
| Project | 4,000 | $30/mo | $0.0075 |
| Bootstrap | 15,000 | $100/mo | $0.0067 |
| Startup | 38,000 | $220/mo | $0.0058 |
| Growth | 100,000 | $500/mo | $0.0050 |
| Pay-as-you-go | Unlimited | $0.008/credit | $0.008 |
| Enterprise | Custom | Custom | — |

---

## Error Codes

| Code | Meaning |
|------|---------|
| 400 | Bad Request — invalid parameters |
| 401 | Unauthorized — missing/invalid API key |
| 403 | Forbidden — URL not supported |
| 429 | Rate Limit Exceeded |
| 432 | Plan Limit Exceeded |
| 433 | Pay-as-you-go Limit Exceeded |
| 500 | Internal Server Error |

---

## Integrations

- LangChain (official integration)
- LlamaIndex
- Direct REST API
- Python SDK (`tavily-python`)
- JavaScript SDK (`@tavily/core`)

---

## Support

- Docs: https://docs.tavily.com
- Community: community.tavily.com
- Status: status.tavily.com
- Email: support@tavily.com
- Playground: app.tavily.com/playground
