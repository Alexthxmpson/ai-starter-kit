# Exa Search API — Use Cases & Practical Summary

**Source:** https://docs.exa.ai/reference/getting-started | https://exa.ai/pricing | https://docs.exa.ai/reference/search
**Date:** 2026-02-27

---

## What Exa Actually Does

Exa is a **semantic web search API** built for AI applications. Instead of matching keywords in a query against keywords on a page (the Google/Bing model), Exa uses vector embeddings to match the *meaning* of a query against the *meaning* of web pages — a technology called next-link prediction.

In practice, this means:
- A query like `"companies doing interesting work in AI for drug discovery"` returns relevant biotech AI companies even if their pages never contain those exact words
- Research queries return conceptually relevant papers, not just pages that mention the search terms
- You can find pages similar to a reference URL without specifying any query at all

Exa returns structured JSON — URLs, titles, scores, dates, and optionally full text, highlights, or LLM-generated summaries. It is designed to plug directly into AI pipelines, not to be used by humans via a browser.

---

## Core Capabilities

| Capability | Description |
|-----------|-------------|
| Semantic search (`neural`) | Meaning-based search using vector embeddings |
| Keyword search | Exact phrase and entity matching |
| Auto search (default) | Intelligent blend of neural and other methods |
| Fast search | Sub-350ms latency for real-time applications |
| Deep search | Agentic multi-hop retrieval for high-quality results |
| Domain filtering | Restrict or exclude specific domains |
| Date filtering | Filter by publish date or crawl date |
| Category filtering | Focus on papers, news, tweets, LinkedIn, GitHub, etc. |
| Contents retrieval | Full page text, highlights, or LLM summaries for any URL |
| Find Similar | Given a URL, find semantically related pages |
| Autoprompt | Exa rewrites your query to optimize it for neural search |
| Live crawl | Force real-time crawl of pages (bypasses cache) |
| Subpage exploration | Crawl internal links from a retrieved page |

---

## Project Ideas — What You Can Build With Exa

| Project | How Exa Is Used | Search Type |
|---------|----------------|-------------|
| AI research assistant | Search arXiv, Semantic Scholar, and academic journals for relevant papers on a topic | `neural` + `category: "research paper"` |
| Competitive intelligence tracker | Find new blog posts, case studies, and product announcements from competitor domains | `auto` + `includeDomains` + `startPublishedDate` |
| News digest pipeline | Retrieve today's news articles on a specific topic with summaries | `auto` + `category: "news"` + date filter + `summary` |
| RAG knowledge base builder | Gather high-quality source documents for a retrieval-augmented generation system | `neural` + `text: true` |
| Lead generation tool | Find LinkedIn profiles or company pages matching a description | `neural` + `category: "people"` or `"company"` |
| Similar content recommender | Given a blog post or article URL, surface related reading | `findSimilar` |
| Startup ecosystem explorer | Find companies in a niche without knowing their names | `neural` + `category: "company"` |
| Real-time AI agent web tool | Give an AI agent live web access at sub-350ms for interactive sessions | `type: "fast"` |
| GitHub project discovery | Find open-source repositories related to a concept | `neural` + `category: "github"` |
| Financial research assistant | Surface SEC filings, earnings reports, and investor documents | `category: "financial report"` |
| Job market analyzer | Find recent job postings or company hiring signals from specific domains | `keyword` + date filter |
| Podcast/content monitoring | Track when specific topics appear on content sites | `auto` + `includeDomains` + date filter |
| Deep research pipeline | Multi-hop research for complex factual questions | `type: "deep"` or `"deep-max"` |
| Content scraper replacement | Retrieve clean markdown text from known URLs without scraping | `/contents` endpoint with `livecrawl: "always"` |

---

## When to Use Exa vs Google vs Perplexity

| Scenario | Best Tool | Reason |
|----------|-----------|--------|
| Semantic / concept-based search in a pipeline | Exa | Returns structured JSON; meaning-based, not keyword-based |
| Finding pages similar to a URL | Exa | `findSimilar` is unique to Exa; no equivalent in Google/Perplexity |
| Retrieving full page text for LLM context | Exa | `/contents` returns clean markdown directly |
| Real-time low-latency search in an AI agent | Exa Fast | Sub-350ms is fastest available |
| Filtering to specific domains or date ranges | Exa | Deep domain and date filtering built into the API |
| Academic or research paper discovery | Exa | `category: "research paper"` with neural search outperforms keyword search for concepts |
| Finding exact named entities, brands, acronyms | Google / keyword | Keyword matching; Exa's keyword type or Google is better for exact strings |
| Human-readable summarized answers | Perplexity | Perplexity synthesizes and cites; Exa returns raw results (though `/answer` endpoint bridges this gap) |
| Large-scale structured queries (monitoring) | Exa Websets | Designed for bulk, scheduled, structured search workflows |
| Broad web coverage for a known keyword | Google | Google's index is larger; Exa optimizes for quality over exhaustiveness |

**Rule of thumb:** Use Exa when your search is part of an AI pipeline, you want structured output, or your query is conceptual rather than a specific string. Use Google when you need maximum index coverage or exact phrase matching. Use Perplexity when you want a synthesized human-readable answer rather than source URLs.

---

## Gotchas and Things to Watch Out For

### 1. Phrase Queries vs Concept Queries — Neural vs Keyword
Neural search is optimized for concept-level queries phrased as natural language or as the opening sentence of an ideal result document. Feeding it a keyword-style query (`"laravel eloquent ORM tutorial 2025"`) will produce worse results than a neural-framed query (`"An in-depth tutorial explaining Laravel Eloquent ORM with practical examples"`). Use `useAutoprompt: true` to let Exa reframe short queries automatically.

### 2. Category Restrictions on Filter Support
The `company` and `people` categories do NOT support date filters or text inclusion/exclusion filters. Attempting to use `startPublishedDate` or `includeText` with these categories will either be silently ignored or return an error. Always check category-specific limitations before building a pipeline.

### 3. `livecrawl` Is Required for Text Filters
The `includeText` and `excludeText` parameters require `livecrawl: "always"` to function. They rely on Exa reading the actual page content at query time, not cached index data. Enabling live crawl increases latency and costs.

### 4. Results Are Not Guaranteed To Be Current
Without `livecrawl`, Exa returns results from its index, which may be days to weeks old for rapidly-changing content. Use `startCrawlDate` to filter for freshly indexed content, or `livecrawl: "always"` to guarantee current page content.

### 5. Score Is Relative, Not Absolute
The `score` field in results is a relevance score relative to the query, not a global quality score. A score of `0.85` for one query does not mean the same thing as `0.85` for another query. Use scores for ranking within a query, not for comparing results across queries.

### 6. `numResults` Limits Vary by Search Type
Each search type has different maximum `numResults` values. `deep-max` has lower result limits than `neural`. Check the docs for the specific type you are using before expecting to retrieve 10,000 results.

### 7. `findSimilar` Works Best With Content-Rich Pages
`findSimilar` uses the target URL's content as the query embedding. If the URL redirects, is behind a login, or has minimal content, results will be poor. Use `excludeSourceDomain: true` to avoid returning pages from the same site as the reference URL.

### 8. The Free Tier Is $10 of Credits, Not Unlimited
The free tier gives $10 in credits (approximately 2,000 standard neural searches at 1–25 results). Production applications need a paid plan. Monitor your credit usage via the dashboard at https://dashboard.exa.ai.

### 9. Autoprompt Is for Neural Search Only
`useAutoprompt: true` only helps when using neural or auto search types. For keyword search, autoprompt may reformulate the query in a way that breaks exact matching. Disable it for keyword queries.

### 10. Summaries Are LLM-Generated and Abstractive
The `summary` field is generated by an LLM (Gemini Flash as of early 2026) and is abstractive — it may introduce phrasing not present in the source. Do not use summaries as verbatim quotations; always cite the source URL.

---

## Quick Reference — Common Patterns

```python
from exa_py import Exa
exa = Exa(api_key="YOUR_KEY")

# Pattern 1: Concept search for recent papers
results = exa.search(
    "methods for reducing hallucination in large language models",
    type="neural",
    num_results=10,
    category="research paper",
    start_published_date="2025-01-01",
    use_autoprompt=True
)

# Pattern 2: Domain-scoped news with summaries
results = exa.search_and_get_contents(
    "product launch announcement",
    type="auto",
    num_results=5,
    include_domains=["techcrunch.com", "theverge.com"],
    start_published_date="2026-02-01",
    summary={"query": "what product was announced and what does it do"}
)

# Pattern 3: Find similar pages excluding source domain
similar = exa.find_similar(
    "https://stripe.com/docs/payments",
    num_results=8,
    exclude_source_domain=True
)

# Pattern 4: Retrieve clean text from known URLs
content = exa.get_contents(
    ["https://arxiv.org/abs/2501.12345"],
    text={"max_characters": 10000},
    livecrawl="always"
)
```

---

## References

- https://docs.exa.ai/reference/getting-started
- https://docs.exa.ai/reference/search
- https://docs.exa.ai/reference/contents-retrieval
- https://exa.ai/pricing
- https://exa.ai/blog/exa-api-2-0
- https://github.com/exa-labs/exa-py
- https://github.com/exa-labs/exa-mcp-server
