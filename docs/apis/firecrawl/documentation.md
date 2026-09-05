# Firecrawl API — Technical Documentation

**Source:** https://docs.firecrawl.dev/
**Date documented:** 2026-02-28
**Product:** Firecrawl — web scraping and crawling API with LLM-ready output

---

## 1. Overview

Firecrawl turns any website into clean, LLM-ready markdown or structured JSON. It handles JavaScript rendering, dynamic content, pagination, and anti-bot measures. Use it to scrape single pages, crawl entire sites, extract structured data via AI, or search the web.

**Env variable name:** `FIRECRAWL_API_KEY`

---

## 2. Base URL & Versioning

```
https://api.firecrawl.dev
```

| Version | Status | Base Path |
|---------|--------|-----------|
| v2 | Current (recommended) | `/v2/` |
| v1 | Supported | `/v1/` |
| v0 | Deprecated | Removed April 2025 |

Use v1 unless a specific endpoint is only available in v2.

---

## 3. Authentication

**Method:** Bearer token

```http
Authorization: Bearer YOUR_API_KEY
```

Include this header on every request. Get your key from the Firecrawl dashboard.

---

## 4. Core Endpoints

### 4.1 Scrape (Single Page)

```
POST /v1/scrape
```

Extracts content from a single URL.

**Request body:**
```json
{
  "url": "https://example.com/page",
  "formats": ["markdown", "html", "links", "screenshot"],
  "onlyMainContent": true,
  "includeTags": ["article", "main"],
  "excludeTags": ["nav", "footer", "ads"]
}
```

**Format options:**

| Format | Output |
|--------|--------|
| `markdown` | Clean markdown text (default) |
| `html` | Cleaned HTML |
| `rawHtml` | Raw unprocessed HTML |
| `screenshot` | Base64 PNG of the page |
| `links` | Array of all links found |
| `json` | Structured data extraction |

**Response:**
```json
{
  "success": true,
  "data": {
    "markdown": "# Page Title\n\nContent...",
    "html": "<h1>Page Title</h1>...",
    "screenshot": "data:image/png;base64,..."
  }
}
```

---

### 4.2 Crawl (Entire Site)

```
POST /v1/crawl
```

Recursively crawls a website starting from a URL. Returns a job ID — crawls are asynchronous.

**Request body:**
```json
{
  "url": "https://example.com",
  "limit": 50,
  "scrapeOptions": {
    "formats": ["markdown"],
    "onlyMainContent": true
  },
  "max_discovery_depth": 3,
  "allow_external_links": false,
  "webhook": "https://your-app.com/webhook"
}
```

**Start crawl response:**
```json
{
  "success": true,
  "id": "crawl-job-123-abc",
  "status": "processing"
}
```

**Check crawl status:**
```
GET /v1/crawl/{jobId}
```

---

### 4.3 Map (URL Discovery)

```
POST /v1/map
```

Discovers all accessible URLs on a site without scraping content. Fast site structure analysis.

**Request body:**
```json
{
  "url": "https://example.com"
}
```

**Response:**
```json
{
  "success": true,
  "links": [
    "https://example.com/page-1",
    "https://example.com/page-2"
  ]
}
```

---

### 4.4 Extract (AI-Powered Structured Data)

```
POST /v1/extract
```

Extracts specific data points from one or more pages using AI. Define output structure via JSON schema or natural language prompt.

**Request body:**
```json
{
  "urls": ["https://example.com/product"],
  "prompt": "Extract product name, price, and description",
  "schema": {
    "type": "object",
    "properties": {
      "product_name": { "type": "string" },
      "price": { "type": "number" },
      "description": { "type": "string" }
    }
  },
  "enableWebSearch": false
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "product_name": "Example Product",
    "price": 29.99,
    "description": "A great product."
  }
}
```

---

### 4.5 Search

```
POST /v1/search
```

Searches the web and optionally scrapes the result pages in a single call.

**Request body:**
```json
{
  "query": "firecrawl API documentation",
  "scrapeOptions": {
    "formats": ["markdown"]
  }
}
```

---

### 4.6 Batch Scrape

```
POST /v1/batch/scrape
```

Scrapes multiple URLs concurrently. Returns a job ID for async polling.

**Check batch status:**
```
GET /v1/batch/scrape/{jobId}
```

Results expire after **24 hours**.

---

### 4.7 Agent (AI-Driven, v2+)

```
POST /v1/agent
```

Evolution of the extract endpoint — faster and more reliable. Accepts a natural language prompt without needing to provide URLs upfront. Not available in self-hosted deployments.

---

## 5. Webhooks

Configure a `webhook` URL on crawl jobs to receive real-time page notifications.

**Webhook payload:**
```json
{
  "success": true,
  "type": "crawl.page",
  "id": "crawl-job-id",
  "data": { },
  "metadata": { },
  "error": null
}
```

**Security — verify signature:**

Every webhook includes `X-Firecrawl-Signature` with an HMAC-SHA256 hash:
```
X-Firecrawl-Signature: sha256=abc123def456...
```

Always verify this before processing.

**Webhook events:**

| Event | Trigger |
|-------|---------|
| `started` | Crawl job started |
| `page` | Individual page scraped |
| `completed` | Full crawl finished |

For responses exceeding 10MB, a `next` URL parameter is included for pagination.

---

## 6. Rate Limits & Pricing

### Concurrency by Plan

| Plan | Concurrent Browsers | Credits/Month | Cost |
|------|-------------------|---------------|------|
| Free | 1–5 | 500 | $0 |
| Hobby | 20 | 100K | $49/mo |
| Startup | 50 | 1M | $149/mo |
| Business | 100 | 3M | $299/mo |
| Scale | Higher | Custom | Custom |

**Credit consumption:**
- Standard page scrape: 1 credit per page
- PDF: 1 credit per PDF page
- Advanced features: Additional credits vary

The real bottleneck is **concurrent browser slots**, not request rate. Jobs queue when the concurrent limit is hit.

---

## 7. Error Codes

| Status | Meaning | Action |
|--------|---------|--------|
| `401` | Invalid API key | Verify key |
| `402` | Insufficient credits | Upgrade or recharge |
| `403` | Forbidden / access denied | Check IP or permissions |
| `429` | Rate limited | Exponential backoff |
| `500` | Server error | Retry with backoff |
| `503` | Service unavailable | Retry later |

**Error response format:**
```json
{
  "success": false,
  "error": "error_description"
}
```

---

## 8. SDKs

| Language | Package |
|----------|---------|
| Python | `firecrawl` (PyPI) |
| JavaScript/Node | `@mendable/firecrawl-js` (npm) |
| Go | Official SDK |
| Ruby | Official SDK |
| Rust | Official SDK |

SDK features: automatic polling for async jobs, webhook verification helpers, typed request/response objects.

---

## 9. Key Limitations

1. **Crawl page limit** — default max 50 pages per job (higher plans increase this).
2. **Batch results expire** — 24 hours after completion.
3. **Agent endpoint** — not available in self-hosted deployments.
4. **Browser actions** — click/write/press not available in self-hosted.
5. **Free tier** — 500 credits/month, expires monthly, lower concurrency.
6. **Self-hosting** requires Docker, PostgreSQL, Redis, and manual scaling.

---

## 10. Self-Hosting

License: AGPL-3.0. Deploy via Docker, Railway, or Kubernetes. Requirements: Docker, PostgreSQL, Redis.

Self-hosted instances lack `/agent`, browser interactive actions, and Fire-engine (IP rotation, bot detection).

---

## 11. Sources

- [Firecrawl Documentation](https://docs.firecrawl.dev/api-reference/introduction)
- [Crawl Endpoint](https://docs.firecrawl.dev/api-reference/endpoint/crawl-post)
- [Extract Feature](https://docs.firecrawl.dev/features/extract)
- [Rate Limits](https://docs.firecrawl.dev/rate-limits)
- [Pricing](https://www.firecrawl.dev/pricing)
- [GitHub Repository](https://github.com/firecrawl/firecrawl)
- [Webhooks](https://www.firecrawl.dev/blog/launch-week-i-day-7-webhooks)
- [Self-Hosting Guide](https://docs.firecrawl.dev/contributing/self-host)
