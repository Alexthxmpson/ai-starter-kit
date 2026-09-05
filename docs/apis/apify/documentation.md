# Apify API v2 — Technical Documentation

**Source:** https://docs.apify.com/api/v2 and https://docs.apify.com/platform/actors
**Date:** 2026-02-27

---

## Overview

Apify API v2 is a REST API that provides programmatic access to the Apify platform. All requests go to the base URL:

```
https://api.apify.com/v2
```

The API follows standard REST conventions. All request/response bodies are JSON. An OpenAPI schema is available in YAML or JSON format from the Apify documentation site for full machine-readable endpoint specs.

---

## Authentication

Apify uses Bearer token authentication. Find your API token in the Apify Console under **Settings > Integrations**.

### Recommended: Authorization Header

```http
Authorization: Bearer YOUR_API_TOKEN
```

### Alternative: Query Parameter

```
https://api.apify.com/v2/acts?token=YOUR_API_TOKEN
```

> Prefer the header method. Query parameters expose the token in browser history, server logs, and URLs.

---

## Rate Limits

| Limit Type | Value |
|---|---|
| Global rate limit (per user, authenticated) | 250,000 requests/minute |
| Default per-resource rate limit | 60 requests/second |
| Key-value store record CRUD operations | 200 requests/second per resource |
| Dataset items per single GET request | 250,000 items max |

When a rate limit is exceeded the API returns `429 Too Many Requests`.

---

## Error Handling

All errors return HTTP status codes in the `4xx` or `5xx` range with a JSON body:

```json
{
  "error": {
    "type": "record-not-found",
    "message": "Actor with ID 'abc123' was not found."
  }
}
```

### Common Error Codes

| HTTP Code | Meaning |
|---|---|
| 400 | Bad request — malformed input or missing required parameter |
| 401 | Unauthorized — missing or invalid API token |
| 403 | Forbidden — valid token but insufficient permissions |
| 404 | Not found — resource does not exist |
| 408 | Request timeout — run exceeded `waitForFinish` window |
| 429 | Too many requests — rate limit exceeded |
| 500 | Internal server error |

---

## Actors

Actors are serverless programs that run on the Apify cloud. They have standardized inputs, outputs, storage, scheduling, and monitoring built in. The Apify Store contains 19,000+ pre-built actors.

### List Actors

```http
GET /v2/acts
```

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| my | boolean | If `true`, returns only actors owned by the authenticated user |
| offset | integer | Number of records to skip (pagination) |
| limit | integer | Max records to return |
| desc | boolean | Sort descending by creation date |

**Response:**

```json
{
  "data": {
    "total": 120,
    "offset": 0,
    "limit": 20,
    "count": 20,
    "items": [
      {
        "id": "moJRLRc85AitArpnn",
        "name": "apify~web-scraper",
        "username": "apify",
        "title": "Web Scraper",
        "description": "Crawls arbitrary websites...",
        "createdAt": "2019-01-01T00:00:00.000Z",
        "modifiedAt": "2025-06-01T00:00:00.000Z"
      }
    ]
  }
}
```

### Get Actor

```http
GET /v2/acts/{actorId}
```

Replace `{actorId}` with the actor ID or `username~actor-name` format.

### Run an Actor (Async)

```http
POST /v2/acts/{actorId}/runs
```

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| token | string | Your API token (or use Authorization header) |
| timeout | integer | Timeout in seconds. Defaults to actor's default config |
| memory | integer | Memory in MB. Must be a power of 2, minimum 128 |
| build | string | Build tag or number to run (e.g., `latest`, `beta`) |
| waitForFinish | integer | Seconds to wait (0–300) before returning. Default: returns immediately |

**Request Body:** JSON input passed directly to the actor

```json
{
  "startUrls": [
    { "url": "https://example.com" }
  ],
  "maxPagesPerCrawl": 100
}
```

**Example:**

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~web-scraper/runs?timeout=120&memory=256" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "startUrls": [{"url": "https://example.com"}],
    "maxPagesPerCrawl": 50
  }'
```

**Response:**

```json
{
  "data": {
    "id": "HG7ML7M8z78YcAPEB",
    "actId": "moJRLRc85AitArpnn",
    "userId": "BPWZBd7Z9c746JAnF",
    "status": "RUNNING",
    "startedAt": "2026-02-27T10:00:00.000Z",
    "finishedAt": null,
    "options": {
      "build": "latest",
      "timeoutSecs": 120,
      "memoryMbytes": 256,
      "diskMbytes": 512
    },
    "defaultDatasetId": "WkzbQMuFYuamGv3YB",
    "defaultKeyValueStoreId": "eJNzqsbPiopwJcgGQ",
    "stats": {
      "netRxBytes": 0,
      "netTxBytes": 0
    }
  }
}
```

### Run an Actor Synchronously and Get Dataset Items

This endpoint blocks until the actor finishes and returns the dataset items directly.

```http
POST /v2/acts/{actorId}/run-sync-get-dataset-items
```

**Query Parameters:** Same as async run, plus:

| Parameter | Type | Description |
|---|---|---|
| format | string | Output format: `json`, `jsonl`, `csv`, `html`, `xlsx`, `xml`, `rss` |
| limit | integer | Max items to return |
| offset | integer | Items to skip |

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~google-maps-scraper/run-sync-get-dataset-items?format=json&limit=100" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"searchStringsArray": ["coffee Amsterdam"], "maxCrawledPlacesPerSearch": 20}'
```

### Get Actor Run Details

```http
GET /v2/acts/{actorId}/runs/{runId}
```

Run statuses: `READY`, `RUNNING`, `SUCCEEDED`, `FAILED`, `TIMING-OUT`, `TIMED-OUT`, `ABORTING`, `ABORTED`

### Get Last Run

```http
GET /v2/acts/{actorId}/runs/last
```

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| status | string | Filter by status (e.g., `SUCCEEDED`) |

### List Runs for an Actor

```http
GET /v2/acts/{actorId}/runs
```

### Abort a Run

```http
POST /v2/acts/{actorId}/runs/{runId}/abort
```

---

## Datasets

Datasets store structured output data from actor runs. Each run gets a default dataset automatically.

### List Datasets

```http
GET /v2/datasets
```

### Get Dataset

```http
GET /v2/datasets/{datasetId}
```

**Response:**

```json
{
  "data": {
    "id": "WkzbQMuFYuamGv3YB",
    "name": "my-dataset",
    "userId": "BPWZBd7Z9c746JAnF",
    "createdAt": "2026-02-27T10:00:00.000Z",
    "modifiedAt": "2026-02-27T10:05:00.000Z",
    "itemCount": 1500
  }
}
```

### Get Dataset Items

```http
GET /v2/datasets/{datasetId}/items
```

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| format | string | `json` (default), `jsonl`, `csv`, `html`, `xlsx`, `xml`, `rss` |
| offset | integer | Items to skip for pagination |
| limit | integer | Max items per request. Hard cap: 250,000 |
| fields | string | Comma-separated list of fields to include |
| omit | string | Comma-separated list of fields to exclude |
| desc | boolean | Sort items in descending order |
| clean | boolean | If `true`, skips empty items and hidden fields |

**Example:**

```bash
curl "https://api.apify.com/v2/datasets/WkzbQMuFYuamGv3YB/items?format=json&limit=1000&offset=0&fields=name,url,price" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

**Response:**

```json
{
  "data": {
    "total": 2560,
    "offset": 0,
    "limit": 1000,
    "count": 1000,
    "desc": false,
    "items": [
      { "name": "Product A", "url": "https://example.com/a", "price": 29.99 },
      { "name": "Product B", "url": "https://example.com/b", "price": 49.99 }
    ]
  }
}
```

> To retrieve more than 250,000 items, paginate using `offset` across multiple requests.

### Push Items to Dataset

```http
POST /v2/datasets/{datasetId}/items
```

**Request Body:** JSON array of objects

```json
[
  { "name": "Item 1", "value": 100 },
  { "name": "Item 2", "value": 200 }
]
```

### Delete Dataset

```http
DELETE /v2/datasets/{datasetId}
```

---

## Key-Value Stores

Key-value stores hold arbitrary files and data — inputs, outputs, screenshots, etc. Each actor run gets a default key-value store.

### List Key-Value Stores

```http
GET /v2/key-value-stores
```

### Get Key-Value Store

```http
GET /v2/key-value-stores/{storeId}
```

### Get a Record

```http
GET /v2/key-value-stores/{storeId}/records/{recordKey}
```

Returns the raw value of the record (any content type).

Public URL format (no auth required if store is public):

```
https://api.apify.com/v2/key-value-stores/{storeId}/records/{recordKey}
```

### Set (Create/Update) a Record

```http
PUT /v2/key-value-stores/{storeId}/records/{recordKey}
```

**Request Body:** Any content. Set `Content-Type` header appropriately.

```bash
curl -X PUT "https://api.apify.com/v2/key-value-stores/{storeId}/records/my-output" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"result": "success", "count": 100}'
```

### Delete a Record

```http
DELETE /v2/key-value-stores/{storeId}/records/{recordKey}
```

### List Records in a Store

```http
GET /v2/key-value-stores/{storeId}/records
```

---

## Actor Tasks

Tasks are saved configurations for an actor (pre-filled input). They let you run the same actor with different inputs without duplicating code.

### List Tasks

```http
GET /v2/actor-tasks
```

### Get Task

```http
GET /v2/actor-tasks/{taskId}
```

### Run a Task

```http
POST /v2/actor-tasks/{taskId}/runs
```

**Query Parameters:** Same as running an actor (`timeout`, `memory`, `waitForFinish`)

**Request Body:** Optional input overrides (JSON)

### Run Task Synchronously and Get Dataset Items

```http
GET /v2/actor-tasks/{taskId}/run-sync-get-dataset-items
POST /v2/actor-tasks/{taskId}/run-sync-get-dataset-items
```

### Get Last Task Run

```http
GET /v2/actor-tasks/{taskId}/runs/last
```

---

## Schedules

Schedules trigger actors or tasks on a cron-based timer.

> To create or update a schedule, the token must have Run permission on the actor or Read permission on the task being scheduled.

### List Schedules

```http
GET /v2/schedules
```

### Get Schedule

```http
GET /v2/schedules/{scheduleId}
```

### Create Schedule

```http
POST /v2/schedules
```

**Request Body:**

```json
{
  "name": "Daily scrape",
  "isEnabled": true,
  "isExclusive": true,
  "cronExpression": "0 8 * * *",
  "timezone": "Europe/Amsterdam",
  "actions": [
    {
      "type": "RUN_ACTOR",
      "actorId": "moJRLRc85AitArpnn",
      "runInput": {
        "startUrls": [{"url": "https://example.com"}]
      },
      "runOptions": {
        "build": "latest",
        "timeoutSecs": 3600,
        "memoryMbytes": 512
      }
    }
  ]
}
```

### Update Schedule

```http
PUT /v2/schedules/{scheduleId}
```

### Delete Schedule

```http
DELETE /v2/schedules/{scheduleId}
```

---

## Webhooks

Webhooks send a POST request to your endpoint when an event occurs (e.g., run succeeded or failed).

### List Webhooks

```http
GET /v2/webhooks
```

### Create Webhook

```http
POST /v2/webhooks
```

**Request Body:**

```json
{
  "isAdHoc": false,
  "eventTypes": ["ACTOR.RUN.SUCCEEDED", "ACTOR.RUN.FAILED"],
  "condition": {
    "actorId": "moJRLRc85AitArpnn"
  },
  "requestUrl": "https://your-server.com/webhook-handler",
  "payloadTemplate": "{\"runId\": {{resource.id}}, \"status\": \"{{resource.status}}\", \"datasetId\": \"{{resource.defaultDatasetId}}\"}",
  "headersTemplate": "{\"Authorization\": \"Bearer your-secret-token\"}"
}
```

**Supported Event Types:**

| Event | Description |
|---|---|
| `ACTOR.RUN.CREATED` | A run was created |
| `ACTOR.RUN.SUCCEEDED` | Run finished successfully |
| `ACTOR.RUN.FAILED` | Run failed |
| `ACTOR.RUN.TIMED_OUT` | Run timed out |
| `ACTOR.RUN.ABORTED` | Run was aborted |
| `ACTOR.RUN.RESURRECTED` | Run was resurrected |

### Get Webhook

```http
GET /v2/webhooks/{webhookId}
```

### Update Webhook

```http
PUT /v2/webhooks/{webhookId}
```

### Delete Webhook

```http
DELETE /v2/webhooks/{webhookId}
```

### Test Webhook

```http
POST /v2/webhooks/{webhookId}/test
```

### List Webhook Dispatches

```http
GET /v2/webhooks/{webhookId}/dispatches
```

---

## Proxies

Apify Proxy provides residential, datacenter, and rotating proxy pools. Proxies are configured within actor code or via the actor's proxy configuration settings — they are not a standalone REST API endpoint but are provisioned as part of runs.

### Proxy Types

| Type | Description |
|---|---|
| `DATACENTER` | Shared datacenter IPs, fast and cheap |
| `RESIDENTIAL` | Real residential IPs, harder to detect |
| `GOOGLE_SERP` | Proxies optimized for Google scraping |

### How to Use in Actor Code (JavaScript SDK)

```javascript
const proxyConfiguration = await Actor.createProxyConfiguration({
  groups: ['RESIDENTIAL'],
  countryCode: 'US',
});

const proxyUrl = await proxyConfiguration.newUrl();
```

### Using Proxy Directly (in HTTP requests)

```
http://auto:YOUR_PROXY_PASSWORD@proxy.apify.com:8000
```

Proxy password is available in the Apify Console under Proxy settings.

---

## Popular Pre-Built Actors (Apify Store)

The Apify Store contains 19,000+ actors. Below are the most commonly used for scraping and automation:

| Actor | Actor ID / Slug | What It Scrapes |
|---|---|---|
| Google Maps Scraper | `apify~google-maps-scraper` | Business info, reviews, ratings, hours, contact |
| Google Search Scraper | `apify~google-search-scraper` | SERP results, organic/paid, featured snippets |
| Amazon Product Scraper | `apify~amazon-scraper` | Products, prices, reviews, ASIN, descriptions |
| Instagram Scraper | `apify~instagram-scraper` | Posts, profiles, hashtags, reels, comments |
| TikTok Scraper | `apify~tiktok-scraper` | Videos, comments, profiles, hashtags, trends |
| LinkedIn Scraper | `apify~linkedin-scraper` | Profiles, jobs, companies |
| Twitter/X Scraper | `apify~twitter-scraper` | Tweets, profiles, trends, search |
| Facebook Scraper | `apify~facebook-scraper` | Pages, posts, reviews, groups |
| YouTube Scraper | `apify~youtube-scraper` | Videos, channels, comments, transcripts |
| Reddit Scraper | `apify~reddit-scraper` | Posts, comments, subreddits |
| Zillow Scraper | `apify~zillow-scraper` | Property listings, prices, agent info |
| Web Scraper | `apify~web-scraper` | Any website using CSS selectors + JS |
| Cheerio Scraper | `apify~cheerio-scraper` | Fast HTML scraping (no JS rendering) |
| Playwright Scraper | `apify~playwright-scraper` | Full browser automation |

---

## Full Workflow: Run a Scrape and Get Results

### Step 1 — Run an Actor

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~google-maps-scraper/runs" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "searchStringsArray": ["pizza Amsterdam"],
    "maxCrawledPlacesPerSearch": 50,
    "language": "en"
  }'
```

Save the `id` (run ID) and `defaultDatasetId` from the response.

### Step 2 — Poll Until Complete

```bash
curl "https://api.apify.com/v2/acts/apify~google-maps-scraper/runs/{runId}" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

Check the `status` field. Repeat until `SUCCEEDED` or `FAILED`.

### Step 3 — Retrieve Results

```bash
curl "https://api.apify.com/v2/datasets/{defaultDatasetId}/items?format=json&limit=250000" \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

### Alternative: Synchronous One-Shot (blocks until done, max 5 min)

```bash
curl -X POST "https://api.apify.com/v2/acts/apify~google-maps-scraper/run-sync-get-dataset-items?format=json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"searchStringsArray": ["pizza Amsterdam"], "maxCrawledPlacesPerSearch": 20}'
```

---

## Actor Runs — Storage Endpoints

Each run has its own default dataset and key-value store accessible via shorthand:

```
GET /v2/actor-runs/{runId}/dataset/items
GET /v2/actor-runs/{runId}/key-value-store/records/{key}
```

---

## Apify Pricing (Platform)

| Plan | Monthly Price | Compute Units |
|---|---|---|
| Free | $0 | Limited (shared) |
| Starter | $49/mo | 128 CUs/mo |
| Scale | $499/mo | 2,048 CUs/mo |
| Business | Custom | Custom |

Compute Units (CUs) = (memory in GB) x (duration in hours). Actors from the store may have additional usage fees on top of platform CUs.
