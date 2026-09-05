# Tavily API — Use Cases & Practical Guide

**Date:** 2026-03-05

---

## What You Can Do

### Free / No Auth Required
- Nothing — all endpoints require an API key
- Free tier: 1,000 credits/month (no credit card needed to sign up)

### Paid / Requires Setup
- Real-time web search with AI-curated results (Search)
- Extract structured content from any URL (Extract)
- Crawl entire websites recursively (Crawl)
- Generate site maps for any domain (Map)
- Run deep AI research tasks with custom output schemas (Research)
- Filter by domain, date range, country, or topic (news/finance/general)
- Get LLM-generated answers from search results

### What the API Cannot Do
- Search is not real-time to the second (standard web crawl latency applies)
- Cannot access paywalled or login-protected pages
- Rate limits apply per plan — no burst exemptions documented
- Research endpoint costs are highly variable (15-250 credits per call)
- Crawl timeout max is 150 seconds (large sites may time out)
- Max 20 URLs per Extract call, max 20 results per Search call

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key Endpoint |
|---|---|---|---|
| AI assistant with web search | Easy | Connect Search to Claude/GPT tool call | `POST /search` |
| News monitoring digest | Easy | Search with `topic=news` + `time_range=day`, post to Discord | `POST /search` |
| Competitor price monitoring | Easy | Extract pricing page URL daily | `POST /extract` |
| Research any person/company | Easy | Search + `include_answer=advanced` | `POST /search` |
| Scrape full docs site | Medium | Crawl with `select_paths` + regex to target docs | `POST /crawl` |
| Build a domain sitemap | Easy | Map any website, dump URL list | `POST /map` |
| AI-powered lead enrichment | Medium | Extract LinkedIn/company pages in bulk (20 at a time) | `POST /extract` |
| Finance news tracker | Medium | Search with `topic=finance` + `time_range=day` on a schedule | `POST /search` |
| Academic research assistant | Medium | Research endpoint with `model=pro` + custom schema | `POST /research` |
| SEO content gap analysis | Medium | Crawl competitor site + map structure + extract content | `/crawl` + `/map` |
| Legal/compliance monitoring | Hard | Daily search + date filtering + RAG pipeline storage | `POST /search` |
| Knowledge base builder | Hard | Crawl + extract → chunk → embed → vector store | `/crawl` → `/extract` |
| Job listing aggregator | Medium | Search for job posts with domain filters + time range | `POST /search` |
| Real estate market monitor | Medium | News search with `topic=news` + domain filter | `POST /search` |
| AI agent grounding tool | Easy | Use Search as tool in LangChain/LlamaIndex agent | SDK integration |

---

## Key Limits and Gotchas

### Rate Limits
- Exact per-minute rate limits not documented publicly
- 429 = rate limited; 432 = plan limit hit; 433 = PayGo limit hit
- Free plan: 1,000 credits/month — burns quickly with `advanced` search (2 credits) or Research (15-250 credits)

### Credit Costs to Watch
- Research is expensive: 15-250 credits per call (pro model) — can blow free plan in 4-66 calls
- Crawl with `instructions`: 2x the credit cost — avoid unless needed
- `auto_parameters=true` on search always costs 2 credits
- Extract is efficient: 1 credit per 5 URLs (basic), 2 credits per 5 (advanced)

### Payload / Size Limits
- Max 20 URLs per Extract call
- Max 20 results per Search call
- `include_domains` whitelist: max 300 domains
- `exclude_domains` blacklist: max 150 domains
- `chunks_per_source`: max 3 for Search, max 5 for Extract/Crawl
- Crawl `max_depth` max: 5 levels; `max_breadth` max: 500 links/level

### Auth
- Key format must be `tvly-<key>` — not just a bare token
- Header: `Authorization: Bearer tvly-YOUR_API_KEY`

### Other Gotchas
- `chunks_per_source` on Extract only works when `query` is also set (relevance reranking)
- Crawl/Map `allow_external=true` by default — set to `false` to stay on domain
- Crawl includes both mapping AND extraction costs (combined billing)
- `include_usage` may return 0 credits on Map if under 10 successful pages
- Failed extractions are NOT charged — only successful ones count

---

## Available Scripts / Tools

- Python SDK: `pip install tavily-python` → `from tavily import TavilyClient`
- JS SDK: `npm install @tavily/core` → `const { tavily } = require("@tavily/core")`
- LangChain: built-in `TavilySearchAPIRetriever` integration
- LlamaIndex: built-in Tavily tool
- Playground for manual testing: app.tavily.com/playground
