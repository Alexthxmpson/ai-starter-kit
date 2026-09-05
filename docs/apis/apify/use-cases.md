# Apify API — Use Cases & Practical Summary

**Source:** https://docs.apify.com/api/v2 | https://docs.apify.com/platform/actors
**Date:** 2026-02-27

---

## What You Can Do

### Run and Manage Web Scrapers
- Trigger any of 19,000+ pre-built actors via API (Google Maps, Amazon, Instagram, TikTok, LinkedIn, YouTube, Reddit, Zillow, and more)
- Pass custom input (URLs, search terms, filters) per run
- Run synchronously (wait for result) or asynchronously (poll later)
- Abort, monitor, and list runs programmatically

### Retrieve Scraped Data
- Pull results from datasets in JSON, CSV, JSONL, XLSX, XML, or RSS
- Paginate through large result sets (up to 250,000 items per request)
- Filter fields to return only what you need
- Access the default dataset immediately from any run ID

### Store and Retrieve Arbitrary Files
- Use key-value stores to read/write any file type (JSON, HTML, screenshots, PDFs)
- Share public store records via direct URL with no auth required
- Use as a config store: write input to a store, read output from another

### Automate and Schedule
- Create cron-based schedules to run actors on a timer without any infrastructure
- Enable/disable schedules via API
- Set exclusive mode so only one instance runs at a time

### React to Events with Webhooks
- Fire HTTP POST to your server when a run succeeds, fails, or times out
- Attach webhooks to specific actors or tasks
- Use payload templates to pass run ID, dataset ID, and status into the webhook body
- Chain workflows: webhook fires -> your server calls another API or actor

### Manage Actor Tasks
- Save pre-configured actor inputs as reusable tasks
- Run tasks via API without re-specifying input every time
- Great for recurring scrapes with the same settings

### Proxy Management
- Route scraper requests through rotating residential, datacenter, or Google SERP proxies
- Select country for proxy origin
- Avoid IP bans on rate-limited sites

---

## Automation and Project Ideas

| Project | Actors / Endpoints Used | How It Works |
|---|---|---|
| Lead generation pipeline | Google Maps Scraper + Dataset GET | Run scraper for business type + city, pull results to CRM |
| Price monitoring dashboard | Amazon Scraper + Schedule + Webhook | Daily schedule triggers scrape, webhook fires to update database |
| Competitor social monitoring | Instagram/TikTok Scraper + Dataset GET | Weekly run pulls competitor posts, analyze engagement trends |
| Job board aggregator | LinkedIn Scraper + Task + Dataset GET | Pre-configured task for each search query, combine datasets |
| SEO SERP tracker | Google Search Scraper + Schedule | Daily runs for target keywords, store rank positions over time |
| Real estate alerts | Zillow Scraper + Webhook | Run on schedule, webhook posts new listings to Slack |
| Content research | YouTube/Reddit Scraper + Dataset GET | Pull trending topics for a keyword, feed to content calendar |
| Automated QA screenshots | Playwright Scraper + KV Store | Crawl site, store screenshots in key-value store, compare diffs |
| News aggregation | Web Scraper + Dataset GET | Crawl news sites daily, output structured articles |
| E-commerce sync | Amazon Scraper + Webhook + your API | Scrape product data, webhook triggers your inventory update endpoint |
| Review monitoring | Google Maps / Trustpilot Scraper | Monitor new reviews for any business location |
| RAG / AI data pipeline | Any scraper + Dataset GET | Collect web data at scale, push to vector database for AI retrieval |

---

## Key Limits and Gotchas

### Rate Limits
- Global: 250,000 requests per minute (per authenticated user). You won't hit this casually.
- Per-resource: 60 requests per second on most endpoints.
- Key-value store CRUD: 200 requests per second per store.
- If you exceed limits you get `429`. Add retry logic with exponential backoff.

### Dataset Retrieval Cap
- Single GET on dataset items is capped at 250,000 items per request.
- For larger datasets, paginate: increment `offset` by your `limit` in a loop.
- Always check `total` in the response to know how many pages you need.

### Synchronous Run Timeout
- `run-sync-get-dataset-items` blocks your HTTP connection for up to 5 minutes (`waitForFinish` max = 300 seconds).
- If the actor takes longer, it returns a timeout — you must then poll asynchronously.
- Use async + polling for any scrape expected to run more than 2-3 minutes.

### Memory Must Be a Power of 2
- Valid memory values: 128, 256, 512, 1024, 2048, 4096, 8192 MB.
- Passing an arbitrary number will return a 400 error.

### Actor Input Must Match the Actor's Schema
- Each actor expects specific input fields. Always check the actor's documentation in the Apify Store before calling it.
- Wrong or missing input fields will cause the run to fail silently or immediately.

### Webhooks Require a Public Endpoint
- Your server must be publicly reachable (not localhost) to receive webhook POST requests.
- Use ngrok or a deployed endpoint during development.
- Validate webhook payloads with a secret header to prevent spoofing.

### Schedules Need Extra Permissions
- The token used to create a schedule must have Run permission on the actor or Read permission on the task being scheduled, not just general API access.

### Default Dataset vs Named Dataset
- Each run gets a disposable default dataset. If you want persistent data across runs, create a named dataset and push to it explicitly.
- Default datasets are deleted after your plan's data retention period.

### Apify Store Actors Have Extra Costs
- Running pre-built store actors costs Compute Units (CU = GB-hours) plus potentially a per-use fee charged by the actor author.
- Check the actor's pricing tab in the store before automating high-volume runs.

### Build Tag Matters
- Specifying `build: "latest"` always uses the most recent version of the actor.
- Pin to a specific build number in production to avoid breaking changes when the actor author pushes updates.

### Token Security
- Never put your API token in a URL in production code. Always use the `Authorization: Bearer` header.
- Rotate your token from the Apify Console if exposed.
