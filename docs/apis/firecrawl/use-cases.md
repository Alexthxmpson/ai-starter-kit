# Firecrawl — Capabilities & Use Cases

**API:** Firecrawl Web Scraping & Crawling API
**Access:** FIRECRAWL_API_KEY
**Last updated:** 2026-02-28

---

## What You Can Do

Firecrawl converts any website into clean, LLM-ready markdown. It handles JavaScript rendering, bypasses common bot detection, and returns structured content.

### Core Operations
- Scrape a single URL → get clean markdown
- Crawl an entire website → get all pages as markdown
- Map a website → get all URLs without content
- Extract structured data from pages (JSON output)
- Search the web and scrape results (powered by Google)

---

## Use Cases

| Use Case | Endpoint | Difficulty |
|----------|----------|------------|
| Scrape any webpage to clean markdown | /scrape | Easy |
| Extract product data from e-commerce site | /scrape with extract schema | Easy |
| Crawl entire docs site for AI training | /crawl | Medium |
| Build competitor research pipeline | /scrape × multiple URLs | Easy |
| Get all URLs from a website | /map | Easy |
| Extract articles from news sites | /scrape | Easy |
| Feed fresh web content to Claude | /scrape → Claude API | Easy |
| Scrape JavaScript-heavy SPAs | /scrape (auto JS render) | Easy |
| Build knowledge base from website | /crawl + Notion upload | Medium |
| Monitor website content for changes | /scrape on schedule | Medium |
| Convert documentation site to markdown | /crawl | Easy |
| Extract pricing tables from competitor | /scrape with schema | Easy |

---

## Key Notes

- Automatically renders JavaScript (no need for Playwright setup)
- Returns clean markdown — removes nav, headers, footers, ads
- Respects robots.txt (can be overridden)
- Handles pagination and internal link following
- Rate limit: depends on plan (free tier = 500 pages/month)
- Can extract structured JSON using a schema definition
- Works on sites that block basic scrapers (improved bot detection bypass)
- Crawl returns results incrementally via webhook or polling
