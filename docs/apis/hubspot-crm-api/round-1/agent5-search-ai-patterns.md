# HubSpot CRM Search API & AI Agent Integration Patterns

**Source:** developers.hubspot.com, HubSpot Community, agentsapis.com, insightsalesglobal.com, aiagentlearn.site
**Date Compiled:** 2026-03-18
**Scope:** Search API full spec, filter operators, pagination, AI agent integration, idempotency, batch ops, error handling, code patterns

---

## Table of Contents

1. [Search API Overview](#1-search-api-overview)
2. [Filter Groups and AND/OR Logic](#2-filter-groups-and-andor-logic)
3. [All Filter Operators](#3-all-filter-operators)
4. [Sorting Results](#4-sorting-results)
5. [Selecting Properties to Return](#5-selecting-properties-to-return)
6. [Pagination with After Cursor](#6-pagination-with-after-cursor)
7. [The 10,000 Record Limit](#7-the-10000-record-limit)
8. [Date Range Filtering](#8-date-range-filtering)
9. [Searching Custom Properties](#9-searching-custom-properties)
10. [Rate Limits](#10-rate-limits)
11. [AI Agent Integration Patterns](#11-ai-agent-integration-patterns)
12. [Idempotency and Deduplication](#12-idempotency-and-deduplication)
13. [Batch Operations](#13-batch-operations)
14. [Error Handling and Retry Strategies](#14-error-handling-and-retry-strategies)
15. [Webhook Architecture for Agents](#15-webhook-architecture-for-agents)
16. [CRM as Agent State Store](#16-crm-as-agent-state-store)
17. [Python Code Patterns](#17-python-code-patterns)
18. [JavaScript/Node.js Code Patterns](#18-javascriptnodejs-code-patterns)
19. [Production Architecture Reference](#19-production-architecture-reference)

---

## 1. Search API Overview

### Endpoint Format

The HubSpot CRM Search API uses a single consistent endpoint pattern across all object types:

```
POST https://api.hubapi.com/crm/v3/objects/{objectType}/search
```

Supported `{objectType}` values include:

- `contacts`
- `companies`
- `deals`
- `tickets`
- `products`
- `quotes`
- `line_items`
- `appointments` (object type ID `0-421`)
- Any custom object (referenced by its `objectTypeId` such as `2-XXX`)

### Authentication

All search requests require a Bearer token in the Authorization header:

```http
Authorization: Bearer YOUR_PRIVATE_APP_TOKEN
Content-Type: application/json
```

For private app integrations (single-account), generate an access token from Settings → Integrations → Private Apps. For multi-account public apps, use OAuth 2.0.

Never put HubSpot tokens in browser JavaScript. Store them server-side in a secrets manager or environment variable.

### Request Body Structure

A complete search request body supports the following top-level fields:

```json
{
  "filterGroups": [...],
  "sorts": [...],
  "properties": [...],
  "limit": 100,
  "after": "cursor_value",
  "query": "free text search string"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `filterGroups` | array | Contains one or more filter group objects (OR logic between groups) |
| `sorts` | array | Up to one sort rule with `propertyName` and `direction` |
| `properties` | array | Specific property names to include in response |
| `limit` | integer | Results per page; max 200, default 10 |
| `after` | string | Cursor for next page, taken from `paging.next.after` |
| `query` | string | Full-text search across default searchable properties |

### Default Properties Returned by Object Type

When no `properties` array is specified, HubSpot returns these defaults:

| Object | Default Properties |
|--------|-------------------|
| contacts | `createdate`, `email`, `firstname`, `hs_object_id`, `lastmodifieddate`, `lastname` |
| companies | `name`, `domain` |
| deals | `dealname`, `amount`, `closedate`, `pipeline`, `dealstage` |
| products | `name`, `description`, `price` |
| tickets | `content`, `hs_pipeline`, `hs_pipeline_stage`, `hs_ticket_category`, `hs_ticket_priority`, `subject` |

### Response Structure

```json
{
  "total": 2,
  "results": [
    {
      "id": "10045",
      "properties": {
        "email": "alice@hubspot.com",
        "firstname": "Alice",
        "lastname": "Smith",
        "createdate": "2024-01-15T10:23:00.000Z",
        "lastmodifieddate": "2024-03-01T08:00:00.000Z",
        "hs_object_id": "10045"
      },
      "createdAt": "2024-01-15T10:23:00.000Z",
      "updatedAt": "2024-03-01T08:00:00.000Z",
      "archived": false
    }
  ],
  "paging": {
    "next": {
      "after": "10",
      "link": "https://api.hubapi.com/crm/v3/objects/contacts/search?after=10"
    }
  }
}
```

Key fields in the response:
- `total` — the total number of records matching the filter (capped at 10,000)
- `results` — array of matching records for this page
- `paging.next.after` — cursor value to pass as `after` in the next request; absent on the last page

---

## 2. Filter Groups and AND/OR Logic

### Core Logic Rules

HubSpot implements a two-level boolean logic system:

- **AND logic**: Place multiple filters within the same `filterGroups[n].filters` array. All conditions in a single group must be true.
- **OR logic**: Place conditions in separate filter group objects within the `filterGroups` array. If any group matches, the record is included.

### Structure

```json
{
  "filterGroups": [
    {
      "filters": [
        { "propertyName": "lifecyclestage", "operator": "EQ", "value": "lead" },
        { "propertyName": "country", "operator": "EQ", "value": "Netherlands" }
      ]
    },
    {
      "filters": [
        { "propertyName": "lifecyclestage", "operator": "EQ", "value": "marketingqualifiedlead" },
        { "propertyName": "country", "operator": "EQ", "value": "Netherlands" }
      ]
    }
  ]
}
```

This query returns contacts who are (`lead` AND `Netherlands`) OR (`marketingqualifiedlead` AND `Netherlands`).

### Complex Logic Example: (A OR B) AND C

To implement `(A OR B) AND C`, duplicate C into both filter groups:

```json
{
  "filterGroups": [
    {
      "filters": [
        { "propertyName": "industry", "operator": "EQ", "value": "TECHNOLOGY" },
        { "propertyName": "annualrevenue", "operator": "GT", "value": "1000000" }
      ]
    },
    {
      "filters": [
        { "propertyName": "industry", "operator": "EQ", "value": "FINANCE" },
        { "propertyName": "annualrevenue", "operator": "GT", "value": "1000000" }
      ]
    }
  ]
}
```

### Filter Limits

HubSpot enforces the following hard limits on search requests:

- Maximum **5 filterGroups** per request
- Maximum **6 filters** per filterGroup
- Maximum **18 filters total** across all filterGroups combined
- Request body size limit: **3,000 characters**

These limits exist at the API level. Note that HubSpot's own Sales dashboard does not enforce these same limits, which is a known developer frustration. There is no official way to increase them for a standard integration.

---

## 3. All Filter Operators

Each filter object has three fields: `propertyName`, `operator`, and (for most operators) `value`. The `BETWEEN` operator uses both `value` (lower bound) and `highValue` (upper bound).

### Comparison Operators

| Operator | Description | Value Required | Example |
|----------|-------------|----------------|---------|
| `EQ` | Equals | Yes | `"operator": "EQ", "value": "lead"` |
| `NEQ` | Not equals | Yes | `"operator": "NEQ", "value": "customer"` |
| `LT` | Less than | Yes | `"operator": "LT", "value": "50000"` |
| `LTE` | Less than or equal | Yes | `"operator": "LTE", "value": "50000"` |
| `GT` | Greater than | Yes | `"operator": "GT", "value": "1000"` |
| `GTE` | Greater than or equal | Yes | `"operator": "GTE", "value": "1000"` |

### Range Operator

| Operator | Description | Fields Required |
|----------|-------------|-----------------|
| `BETWEEN` | Inclusive range | `value` (low), `highValue` (high) |

```json
{
  "propertyName": "amount",
  "operator": "BETWEEN",
  "value": "1000",
  "highValue": "50000"
}
```

### List Operators

| Operator | Description | Notes |
|----------|-------------|-------|
| `IN` | Property value is in the provided list | String values must be lowercase |
| `NOT_IN` | Property value is not in the provided list | String values must be lowercase |

```json
{
  "propertyName": "lifecyclestage",
  "operator": "IN",
  "values": ["lead", "marketingqualifiedlead", "salesqualifiedlead"]
}
```

Note: `IN` and `NOT_IN` use a `values` array field (not `value`). String values must be lowercase — passing `"Lead"` will not match the enum value `"lead"`.

### Existence Operators

| Operator | Description | Value Required |
|----------|-------------|----------------|
| `HAS_PROPERTY` | Property has any value set (not null/empty) | No |
| `NOT_HAS_PROPERTY` | Property is not set (null or empty) | No |

```json
{
  "propertyName": "phone",
  "operator": "HAS_PROPERTY"
}
```

```json
{
  "propertyName": "hs_email_optout",
  "operator": "NOT_HAS_PROPERTY"
}
```

### Text Search Operators

| Operator | Description | Wildcard Support |
|----------|-------------|-----------------|
| `CONTAINS_TOKEN` | Value contains a token (word/phrase) | Yes, using `*` |
| `NOT_CONTAINS_TOKEN` | Value does not contain the token | Yes, using `*` |

```json
{
  "propertyName": "email",
  "operator": "CONTAINS_TOKEN",
  "value": "*@hubspot.com"
}
```

The `*` wildcard in `CONTAINS_TOKEN` matches any sequence of characters. This is useful for domain-level filtering (all emails from a domain, all names starting with a prefix, etc.). Note that CONTAINS_TOKEN performs tokenized search, not arbitrary substring matching — it works on word boundaries and email domains, not arbitrary midstring positions.

### Full-Text Search vs Property Filtering

HubSpot provides two distinct search mechanisms:

1. **`query` field** — Full-text search across each object's default searchable properties. For contacts, this searches across `firstname`, `lastname`, `email`, `phone`, and a few others. Fast but limited to default properties only.

2. **`filterGroups`** — Structured property filtering. Works on any property including custom ones. More precise control over logic, operators, and data types.

You can use `query` and `filterGroups` simultaneously in the same request body. The query acts as an additional filter on top of the filterGroups conditions.

---

## 4. Sorting Results

The `sorts` array accepts a single sort rule. Multi-property sorting is not supported in the standard search API.

```json
{
  "filterGroups": [...],
  "sorts": [
    {
      "propertyName": "createdate",
      "direction": "DESCENDING"
    }
  ]
}
```

Valid directions: `ASCENDING`, `DESCENDING`.

Common sort properties:
- `createdate` — sort by creation date
- `lastmodifieddate` — sort by last update
- `hs_object_id` — sort by record ID (useful for re-indexing past the 10k limit)
- Any numeric or date custom property

For pagination past the 10,000 record limit (covered in section 7), sorting by `hs_object_id ASCENDING` and using the last returned ID as a filter cursor is the canonical workaround.

---

## 5. Selecting Properties to Return

By default, search returns only the object's default properties. To retrieve specific or custom properties, include a `properties` array:

```json
{
  "filterGroups": [...],
  "properties": [
    "firstname",
    "lastname",
    "email",
    "phone",
    "company",
    "jobtitle",
    "lifecyclestage",
    "hs_lead_status",
    "custom_agent_state",
    "custom_last_processed_at"
  ]
}
```

Important notes:
- Property names are case-sensitive and must match the internal API name (not the display label)
- Requesting non-existent properties does not throw an error — the property is simply absent from the response
- There is a practical limit on how many properties you can request; very large `properties` arrays can cause request body size limit errors (3,000 character limit)
- For contacts with many properties (400+), consider making multiple targeted search calls or using the batch read endpoint after getting IDs from search

---

## 6. Pagination with After Cursor

### How Cursor Pagination Works

HubSpot search uses opaque cursor-based pagination, not page numbers. This prevents skipping or double-counting records when the underlying data changes between requests.

**Initial request:**
```json
{
  "filterGroups": [...],
  "limit": 200,
  "sorts": [{"propertyName": "createdate", "direction": "ASCENDING"}]
}
```

**Check for next page:**
```python
if response.get("paging", {}).get("next", {}).get("after"):
    next_cursor = response["paging"]["next"]["after"]
else:
    # No more pages
    break
```

**Subsequent request:**
```json
{
  "filterGroups": [...],
  "limit": 200,
  "after": "10",
  "sorts": [{"propertyName": "createdate", "direction": "ASCENDING"}]
}
```

### Pagination Parameters

| Parameter | Value | Notes |
|-----------|-------|-------|
| `limit` | 1–200 | Max 200 per page; default is 10 |
| `after` | string (cursor) | Taken from `paging.next.after` in previous response |

### Pagination Stability

HubSpot does not guarantee stable pagination. If records are created, updated, or deleted between page requests, you may see:
- Records that appear on two pages
- Records that are skipped entirely
- The `total` count changing between requests

For production data pipelines, always implement deduplication by `hs_object_id` when collecting paginated results.

---

## 7. The 10,000 Record Limit

### Understanding the Limit

The CRM Search API has a hard limit of 10,000 results per query. Regardless of how many records match your filters, pagination will stop returning results after 10,000 records. The `total` field will show the true count (e.g., 50,000), but you can only page through up to 10,000 of those results.

This limit is architectural and applies to all HubSpot accounts. There is no official way to increase it for the search endpoint.

### Workaround 1: Re-Indexing with ID Cursor (Recommended)

The standard community-accepted pattern for fetching more than 10,000 records is to sort by `hs_object_id ASCENDING` and use the last returned ID as a filter for the next batch:

**Step 1:** Fetch first 10,000 records sorted by ID:
```json
{
  "filterGroups": [
    {
      "filters": [
        {"propertyName": "hs_lead_status", "operator": "EQ", "value": "NEW"}
      ]
    }
  ],
  "sorts": [{"propertyName": "hs_object_id", "direction": "ASCENDING"}],
  "limit": 200
}
```

**Step 2:** When you reach 10,000, note the last `hs_object_id` (e.g., `"99842"`). Add a new filter for the next batch:
```json
{
  "filterGroups": [
    {
      "filters": [
        {"propertyName": "hs_lead_status", "operator": "EQ", "value": "NEW"},
        {"propertyName": "hs_object_id", "operator": "GT", "value": "99842"}
      ]
    }
  ],
  "sorts": [{"propertyName": "hs_object_id", "direction": "ASCENDING"}],
  "limit": 200
}
```

Repeat, each time using the last ID from the previous batch as the new `GT` filter value. This effectively re-indexes the search window and allows retrieving unlimited records.

### Workaround 2: Time-Range Segmentation

Split large result sets into time windows:

```python
def fetch_all_with_date_segmentation(start_date, end_date, segment_days=30):
    current = start_date
    all_records = []
    while current < end_date:
        window_end = min(current + timedelta(days=segment_days), end_date)
        records = fetch_window(current, window_end)
        all_records.extend(records)
        current = window_end
    return all_records
```

Each time window fetches fewer than 10,000 records, so pagination completes. The tradeoff is more API calls.

### Workaround 3: List API for Full Downloads

For complete dataset exports without filters, use the list endpoint instead:

```
GET /crm/v3/objects/contacts
```

This endpoint does not have a 10,000 record limit and supports full pagination via `after` cursor. However, it does not support filtering — only listing all records in the object.

For filtered large datasets, combine: use search to get matching IDs → use batch read to fetch full property data.

---

## 8. Date Range Filtering

### Unix Timestamp Format

HubSpot date/datetime properties use Unix timestamps in **milliseconds** when filtering via the API:

```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "lastmodifieddate",
          "operator": "GT",
          "value": "1700000000000"
        }
      ]
    }
  ]
}
```

To convert from Python datetime to millisecond timestamp:
```python
import datetime

dt = datetime.datetime(2024, 1, 1, 0, 0, 0)
ms_timestamp = str(int(dt.timestamp() * 1000))
```

### BETWEEN for Date Ranges

```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "createdate",
          "operator": "BETWEEN",
          "value": "1704067200000",
          "highValue": "1735689600000"
        }
      ]
    }
  ]
}
```

This example fetches records created between January 1, 2024 and January 1, 2025.

### Incremental Sync Pattern

For agent workflows that need to process only recently changed records, filter by `lastmodifieddate GT {last_sync_timestamp}`:

```python
import datetime
import time

def get_recently_modified_contacts(hours_back=24):
    cutoff = datetime.datetime.utcnow() - datetime.timedelta(hours=hours_back)
    cutoff_ms = str(int(cutoff.timestamp() * 1000))

    payload = {
        "filterGroups": [{
            "filters": [{
                "propertyName": "lastmodifieddate",
                "operator": "GT",
                "value": cutoff_ms
            }]
        }],
        "sorts": [{"propertyName": "lastmodifieddate", "direction": "ASCENDING"}],
        "properties": ["email", "firstname", "lastname", "lastmodifieddate"],
        "limit": 200
    }
    return paginate_search("contacts", payload)
```

---

## 9. Searching Custom Properties

Custom properties are fully searchable via the same filter syntax. Use the internal API name of the property (not the display label) as `propertyName`.

### Creating a Searchable Custom Property

First, create the custom property via the Properties API:

```python
import requests

def create_custom_property(object_type, name, label, prop_type="string"):
    url = f"https://api.hubapi.com/crm/v3/properties/{object_type}"
    payload = {
        "groupName": "contactinformation",
        "name": name,          # e.g., "agent_processing_status"
        "label": label,        # e.g., "Agent Processing Status"
        "type": prop_type,     # string, number, bool, enumeration, date, datetime
        "fieldType": "text"    # text, textarea, number, select, radio, checkbox, date
    }
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }
    response = requests.post(url, json=payload, headers=headers)
    return response.json()
```

### Property Type to FieldType Mapping

| Type | fieldType Options |
|------|-------------------|
| `string` | `text`, `textarea`, `file`, `phonenumber`, `html` |
| `number` | `number` |
| `bool` | `booleancheckbox` |
| `enumeration` | `select`, `radio`, `checkbox` |
| `date` | `date` |
| `datetime` | `date` |

### Unique Identifier Properties

Custom properties can be designated as unique identifiers by setting `"hasUniqueValue": true`. This allows:
- Using the property as the `idProperty` parameter in batch read operations
- Using the property as the dedup key in upsert operations
- Maximum 10 unique identifier properties per object type

```python
def create_unique_property(object_type, name, label):
    payload = {
        "groupName": "contactinformation",
        "name": name,
        "label": label,
        "type": "string",
        "fieldType": "text",
        "hasUniqueValue": True   # enforces uniqueness, enables use as idProperty
    }
    # ... POST to /crm/v3/properties/{objectType}
```

### Filtering on Custom Enumeration Properties

Enumeration values must be stored in lowercase when filtering with `EQ` or `IN`:

```json
{
  "filterGroups": [{
    "filters": [{
      "propertyName": "agent_processing_status",
      "operator": "IN",
      "values": ["pending", "in_progress", "failed"]
    }]
  }]
}
```

---

## 10. Rate Limits

### Search-Specific Rate Limit

The CRM Search API has a dedicated rate limit separate from the general API rate limit:

- **5 requests per second** per HubSpot account (across all apps using the same account)

This is lower than the general API limit and must be respected in any high-throughput agent.

### General API Rate Limits

| Plan | Limit |
|------|-------|
| Free/Starter | 100 requests per 10 seconds |
| Professional/Enterprise | 150 requests per 10 seconds |

### Daily Limits

HubSpot also enforces daily API call limits which vary by subscription tier. Hitting the daily limit returns a 429 with a reset time.

### Rate Limit Response

When rate limited, HubSpot returns:

```json
{
  "status": "error",
  "message": "You have reached your secondly limit.",
  "errorType": "RATE_LIMIT",
  "policyName": "SECONDLY",
  "correlationId": "uuid-here"
}
```

The `Retry-After` header (in milliseconds) is included in 429 responses for search and other endpoints.

### Strategies to Stay Within Limits

1. **Batch endpoints** — Replace 100 individual PATCH requests with one batch PATCH. Batch operations are capped at 100 records but count as one API call.
2. **Search efficiently** — Retrieve only necessary properties. Avoid polling search when webhooks can be used.
3. **Queue requests** — Implement a request queue with configurable concurrency (e.g., max 4 concurrent search calls).
4. **Exponential backoff with jitter** — On 429, wait `(2^attempt + random_ms)` before retry.
5. **Avoid polling** — Use webhooks for real-time events. Only poll when webhooks are unavailable.

---

## 11. AI Agent Integration Patterns

### Pattern 1: Search-Then-Act

The most common agent pattern: search CRM for records matching agent criteria, process them, update records, repeat.

```
Agent Loop:
  1. POST /crm/v3/objects/contacts/search — find records matching current task
  2. For each result, perform enrichment or analysis
  3. PATCH /crm/v3/objects/contacts/{id} — write results back
  4. Update agent state property to mark completion
  5. Repeat for next batch
```

This is safe, idempotent (because you can filter on the state property), and respects rate limits.

### Pattern 2: Webhook-Driven Agent

HubSpot triggers your agent endpoint when a CRM event occurs:

```
HubSpot Workflow → "Send a webhook" action
→ POST your-agent-endpoint.com/webhook
→ Agent processes payload
→ Agent calls HubSpot API to update record
→ 2xx response within 5 seconds (or HubSpot retries)
```

The agent must respond with 2xx within 5 seconds. For work that takes longer, immediately enqueue the payload and return 200, then process asynchronously:

```python
@app.post("/webhook")
async def hubspot_webhook(request: Request):
    payload = await request.json()
    # Immediately enqueue — do not block
    await task_queue.enqueue(payload)
    return {"status": "accepted"}   # 200 within milliseconds

async def process_webhook(payload):
    # Heavy work happens here asynchronously
    contact_id = payload["objectId"]
    await enrich_contact(contact_id)
    await update_hubspot_contact(contact_id, {...})
```

### Pattern 3: Polling with Incremental Sync

For agents that need to process all recent changes without webhooks:

```python
LAST_SYNC_KEY = "last_hubspot_sync"

def incremental_sync():
    last_sync_ms = state_store.get(LAST_SYNC_KEY, default=0)

    contacts = search_contacts_modified_since(last_sync_ms)

    for contact in contacts:
        process_contact(contact)

    # Only advance cursor after successful processing
    new_sync_ms = int(datetime.utcnow().timestamp() * 1000)
    state_store.set(LAST_SYNC_KEY, new_sync_ms)
```

Do not advance the cursor until the batch is fully processed. If the agent crashes mid-batch, re-processing from the previous cursor is safe if operations are idempotent.

### Pattern 4: CRM-Native Agent via Custom Code Workflow Actions

HubSpot Operations Hub allows running arbitrary JavaScript within a workflow step. This is useful for lightweight in-CRM logic:

- Triggered by property changes or deal stage transitions
- Can call external APIs
- Retries for up to 3 days on 429/5xx errors
- Starts 1 minute post-failure, intervals increase up to 8 hours between attempts

### Pattern 5: LangChain / LLM Agent with HubSpot Tools

Modern AI agents using LangChain, CrewAI, or similar frameworks expose HubSpot operations as tools:

```python
from langchain.tools import tool

@tool
def search_contact_by_email(email: str) -> dict:
    """Search for a HubSpot contact by email address."""
    payload = {
        "filterGroups": [{
            "filters": [{
                "propertyName": "email",
                "operator": "EQ",
                "value": email
            }]
        }],
        "properties": ["firstname", "lastname", "company", "jobtitle", "lifecyclestage"]
    }
    response = hubspot_post("/crm/v3/objects/contacts/search", payload)
    results = response.get("results", [])
    return results[0] if results else {"error": "Contact not found"}

@tool
def update_contact_lead_score(contact_id: str, score: int, reason: str) -> dict:
    """Update the lead score for a contact."""
    payload = {
        "properties": {
            "lead_score": str(score),
            "lead_score_reason": reason,
            "lead_score_updated_at": str(int(datetime.utcnow().timestamp() * 1000))
        }
    }
    return hubspot_patch(f"/crm/v3/objects/contacts/{contact_id}", payload)
```

The LLM decides which tools to call and in what sequence. Use `temperature=0` for deterministic tool selection in production agents.

---

## 12. Idempotency and Deduplication

### Why Idempotency Matters for Agents

Agents retry on network failures, timeouts, and transient errors. Without idempotency, a retry that follows a successfully-processed-but-unacknowledged operation creates duplicates — double-created contacts, duplicate deals, duplicate emails sent.

### Contact Deduplication: Email as Primary Key

Email is HubSpot's primary unique identifier for contacts. No two contacts can have the same email address (including additional emails). When creating contacts from agent operations, always include email:

```python
def create_contact_safe(email, firstname, lastname, company):
    # First check if contact exists
    existing = search_contact_by_email(email)
    if existing:
        return existing  # Contact already exists, return it

    # Only create if not found
    payload = {
        "properties": {
            "email": email,
            "firstname": firstname,
            "lastname": lastname,
            "company": company
        }
    }
    return hubspot_post("/crm/v3/objects/contacts", payload)
```

### Company Deduplication: Domain as Primary Key

Domain is HubSpot's primary unique identifier for companies. Always include `domain` when creating companies:

```python
def create_company_safe(name, domain):
    # Check for existing company by domain
    existing = search_company_by_domain(domain)
    if existing:
        return existing

    payload = {
        "properties": {
            "name": name,
            "domain": domain
        }
    }
    return hubspot_post("/crm/v3/objects/companies", payload)

def search_company_by_domain(domain):
    payload = {
        "filterGroups": [{
            "filters": [{
                "propertyName": "domain",
                "operator": "EQ",
                "value": domain
            }]
        }]
    }
    results = hubspot_post("/crm/v3/objects/companies/search", payload).get("results", [])
    return results[0] if results else None
```

### Upsert Pattern: createOrUpdate

For contacts, use the batch upsert endpoint to create-or-update atomically:

```
POST /crm/v3/objects/contacts/batch/upsert
```

```json
{
  "inputs": [
    {
      "idProperty": "email",
      "id": "alice@example.com",
      "properties": {
        "firstname": "Alice",
        "lastname": "Smith",
        "company": "Acme Corp",
        "last_synced_at": "1700000000000"
      }
    }
  ]
}
```

Key behavior:
- If a contact with `email = alice@example.com` exists: it is updated with the provided properties
- If no contact exists with that email: a new contact is created
- The `idProperty` specifies which property to match on; must be `email` or a custom unique identifier property
- Limitation: partial upserts with `email` as `idProperty` are not fully supported; for complex scenarios use a custom unique identifier property

### Custom Unique Identifier for Agent Operations

Create a custom property like `external_system_id` with `hasUniqueValue: true` to use as a stable dedup key from your system:

```python
# Create the unique property once
create_unique_property("contacts", "external_system_id", "External System ID")

# Use it in upserts
def upsert_contact_by_external_id(external_id, properties):
    payload = {
        "inputs": [{
            "idProperty": "external_system_id",
            "id": external_id,
            "properties": {**properties, "external_system_id": external_id}
        }]
    }
    return hubspot_post("/crm/v3/objects/contacts/batch/upsert", payload)
```

### Idempotency for Webhook Events

For inbound webhooks from HubSpot, use `eventId` as the idempotency key:

```python
import redis
import hashlib

redis_client = redis.Redis()
IDEMPOTENCY_TTL = 7 * 24 * 3600  # 7 days

def process_webhook_idempotently(event):
    event_id = str(event["eventId"])
    key = f"hubspot:event:{event_id}"

    # Atomic set-if-not-exists
    is_new = redis_client.set(key, "1", ex=IDEMPOTENCY_TTL, nx=True)

    if not is_new:
        # Already processed — skip
        return {"status": "duplicate_skipped"}

    # Process the event
    return handle_event(event)
```

HubSpot explicitly does not guarantee exactly-once delivery for webhooks. Using `eventId` + Redis SETNX is the recommended pattern to achieve exactly-once processing.

---

## 13. Batch Operations

### Overview

Batch endpoints allow processing up to 100 records per API call, dramatically reducing total call counts for large operations.

| Operation | Endpoint |
|-----------|----------|
| Batch create | `POST /crm/v3/objects/{objectType}/batch/create` |
| Batch read | `POST /crm/v3/objects/{objectType}/batch/read` |
| Batch update | `POST /crm/v3/objects/{objectType}/batch/update` |
| Batch upsert | `POST /crm/v3/objects/{objectType}/batch/upsert` |
| Batch archive | `POST /crm/v3/objects/{objectType}/batch/archive` |

All batch operations are limited to **100 records per request**.

### Batch Create

```json
{
  "inputs": [
    {
      "properties": {
        "email": "user1@example.com",
        "firstname": "User",
        "lastname": "One",
        "company": "Acme"
      }
    },
    {
      "properties": {
        "email": "user2@example.com",
        "firstname": "User",
        "lastname": "Two",
        "company": "Acme"
      }
    }
  ]
}
```

### Batch Read by Email (Non-ID Lookup)

To fetch contacts by email (not record ID), use the `idProperty` parameter:

```json
{
  "idProperty": "email",
  "inputs": [
    {"id": "alice@example.com"},
    {"id": "bob@example.com"}
  ],
  "properties": ["firstname", "lastname", "lifecyclestage", "agent_state"]
}
```

Important: batch read cannot retrieve associations. For association data, use the Associations API separately after getting record IDs.

### Batch Update (ID Required)

Batch update requires HubSpot record IDs, not email or custom identifiers:

```json
{
  "inputs": [
    {
      "id": "10045",
      "properties": {
        "lifecyclestage": "customer",
        "agent_last_action": "deal_closed"
      }
    },
    {
      "id": "10067",
      "properties": {
        "lifecyclestage": "salesqualifiedlead",
        "agent_last_action": "qualified"
      }
    }
  ]
}
```

### Multi-Status Error Handling in Batch Operations

Batch create supports multi-status error handling, which returns partial success/failure information rather than failing the entire batch on one error:

Response when some records fail:

```json
{
  "status": "COMPLETE",
  "numErrors": 1,
  "results": [
    {
      "id": "10045",
      "properties": {...},
      "createdAt": "...",
      "status": "success"
    }
  ],
  "errors": [
    {
      "status": "error",
      "category": "VALIDATION_ERROR",
      "message": "Property 'email' is required",
      "context": {"propertyName": ["email"]},
      "status": "error"
    }
  ],
  "requestedAt": "...",
  "startedAt": "...",
  "completedAt": "..."
}
```

To enable multi-status, include an `objectWriteTraceId` on each input item:

```json
{
  "inputs": [
    {
      "objectWriteTraceId": "trace-001",
      "properties": {"email": "good@example.com", "firstname": "Valid"}
    },
    {
      "objectWriteTraceId": "trace-002",
      "properties": {"firstname": "No Email - Will Fail"}
    }
  ]
}
```

### Handling Partial Failures in Agent Workflows

```python
def batch_create_contacts_with_retry(contacts):
    successful = []
    failed = []

    # Chunk into batches of 100
    for i in range(0, len(contacts), 100):
        batch = contacts[i:i+100]

        # Add trace IDs for multi-status support
        inputs = [
            {"objectWriteTraceId": c.get("external_id", str(idx)),
             "properties": c["properties"]}
            for idx, c in enumerate(batch)
        ]

        response = hubspot_post(
            "/crm/v3/objects/contacts/batch/create",
            {"inputs": inputs}
        )

        successful.extend(response.get("results", []))

        # Retry failed items individually
        for error in response.get("errors", []):
            trace_id = error.get("context", {}).get("objectWriteTraceId", [None])[0]
            failed.append({"traceId": trace_id, "error": error})

    return {"successful": successful, "failed": failed}
```

### Large-Scale Batch Processing (>100,000 Records)

For very large datasets, the Imports API is recommended over the batch API. The Imports API accepts CSV files and processes them asynchronously, handling deduplication and error reporting at scale. The batch API is limited to 100 records per request and is better suited for operational updates (agent writes) rather than bulk data migrations.

---

## 14. Error Handling and Retry Strategies

### HTTP Status Code Reference

| Code | Meaning | Action |
|------|---------|--------|
| `200` | Success | Process response |
| `207` | Multi-Status (batch partial success) | Process success/error arrays |
| `400` | Validation error | Log payload, fix input, do not retry |
| `401` | Unauthorized | Refresh/rotate token, then retry |
| `403` | Forbidden (missing scope) | Add required scope to app, do not retry |
| `404` | Record not found | Check ID mapping, do not retry infinitely |
| `409` | Conflict (duplicate) | Apply dedup logic, search for existing record |
| `414` | URI too long or merge limit exceeded | Reduce payload size |
| `423` | Locked (high-volume sync in progress) | Wait 2+ seconds, then retry |
| `429` | Rate limit exceeded | Respect `Retry-After` header, exponential backoff |
| `477` | Migration in progress | Check `Retry-After` (up to 24 hours) |
| `502`, `504` | Processing limit / gateway | Pause and retry |
| `503` | Service temporarily unavailable | Pause and retry |
| `521` | Web server down | Pause and retry |
| `522` | Connection timed out | Contact HubSpot support |
| `523` | Origin unreachable | Pause and retry |
| `524` | 100-second response timeout | Pause and retry |

### Standard Error Response Format

```json
{
  "status": "error",
  "message": "Property 'email' already exists.",
  "errors": [
    {
      "message": "Duplicate property value",
      "code": "DUPLICATE_VALUE",
      "context": {
        "propertyName": ["email"]
      }
    }
  ],
  "category": "VALIDATION_ERROR",
  "correlationId": "a3b2c1d0-1234-5678-abcd-ef0123456789"
}
```

All error fields are optional in the response. Always log `correlationId` for debugging — provide it when contacting HubSpot support.

### Exponential Backoff with Jitter (Python)

```python
import time
import random
import requests

def hubspot_request_with_retry(method, url, payload=None, max_retries=5):
    headers = {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }

    for attempt in range(max_retries):
        try:
            if method == "POST":
                response = requests.post(url, json=payload, headers=headers, timeout=30)
            elif method == "PATCH":
                response = requests.patch(url, json=payload, headers=headers, timeout=30)
            elif method == "GET":
                response = requests.get(url, headers=headers, timeout=30)

            # Success
            if response.status_code in (200, 201, 207):
                return response.json()

            # Rate limited — respect Retry-After header
            if response.status_code == 429:
                retry_after_ms = int(response.headers.get("Retry-After", "1000"))
                retry_after_s = retry_after_ms / 1000
                wait = retry_after_s + random.uniform(0, 1)
                print(f"Rate limited. Waiting {wait:.1f}s (attempt {attempt+1})")
                time.sleep(wait)
                continue

            # Transient server errors — exponential backoff with jitter
            if response.status_code in (423, 502, 503, 504, 521, 523, 524):
                wait = (2 ** attempt) + random.uniform(0, 1)
                print(f"Transient error {response.status_code}. Waiting {wait:.1f}s")
                time.sleep(wait)
                continue

            # Non-retryable client errors
            if response.status_code in (400, 401, 403, 404):
                error_data = response.json()
                raise ValueError(
                    f"Non-retryable error {response.status_code}: "
                    f"{error_data.get('message')} "
                    f"[correlationId: {error_data.get('correlationId')}]"
                )

            # 477 migration — could be up to 24 hours
            if response.status_code == 477:
                retry_after = int(response.headers.get("Retry-After", "60"))
                print(f"Account migration in progress. Retry after {retry_after}s")
                time.sleep(min(retry_after, 300))  # cap at 5 min per cycle
                continue

            # Unexpected status
            response.raise_for_status()

        except requests.Timeout:
            wait = (2 ** attempt) + random.uniform(0, 1)
            print(f"Request timeout. Waiting {wait:.1f}s")
            time.sleep(wait)
            continue
        except requests.ConnectionError:
            wait = (2 ** attempt) + random.uniform(0, 1)
            print(f"Connection error. Waiting {wait:.1f}s")
            time.sleep(wait)
            continue

    raise RuntimeError(f"Max retries exceeded for {url}")
```

### Retry Behavior Reference by Mechanism

| Mechanism | Max Retries | Max Duration | 4xx Behavior | 429 Behavior |
|-----------|-------------|--------------|--------------|--------------|
| Webhooks API | 10 | ~24 hours | Retries | Retries with Retry-After |
| Workflow "Send webhook" | Unlimited | 3 days | No retry (except 429) | Retries |
| Custom Code Workflow | Unlimited | 3 days | No retry (except 429) | Retries |
| Your integration (you control) | Configurable | Configurable | Your logic | Respect Retry-After |

---

## 15. Webhook Architecture for Agents

### Outbound Webhooks: HubSpot → Agent

**Via Webhooks API (app subscriptions):**
Subscribe to CRM object events in your app's configuration:

```
Events supported: contact.creation, contact.deletion, contact.merge,
contact.propertyChange, deal.creation, deal.propertyChange,
deal.stageChange, company.propertyChange, etc.
```

Payload batch (up to 100 events per request):

```json
[
  {
    "eventId": 1234567890,
    "subscriptionId": 54321,
    "portalId": 1111111,
    "appId": 99999,
    "occurredAt": 1700000000000,
    "eventType": "contact.propertyChange",
    "objectId": 10045,
    "propertyName": "lifecyclestage",
    "propertyValue": "customer",
    "changeSource": "CRM",
    "attemptNumber": 0
  }
]
```

Key fields:
- `eventId` — unique event identifier; use as idempotency key
- `attemptNumber` — increments on retries (0 = first delivery)
- `occurredAt` — millisecond timestamp; use for ordering (not guaranteed delivery order)
- `objectId` — the HubSpot record ID that was modified

**Via Workflow "Send a webhook" action:**
Configure a workflow to POST to your endpoint when a deal stage changes, a contact is created, etc. More flexible targeting than subscriptions; same retry behavior (3 days).

### Inbound Webhooks: External System → HubSpot

HubSpot can be the webhook receiver via the "When a webhook is received" workflow trigger (Operations Hub). This enables external systems to trigger HubSpot automations:

- Requires a unique matching property on the enrollment object
- Accepts `application/json` content type
- Triggers workflow enrollment immediately on receipt

### Signature Verification (v3)

Always verify webhook authenticity using the `X-HubSpot-Signature-v3` header:

```python
import hmac
import hashlib
import base64
import time

def verify_hubspot_signature_v3(
    secret, request_method, request_uri, request_body, timestamp_ms
):
    # Reject old requests (>5 minutes)
    age_seconds = (int(time.time() * 1000) - int(timestamp_ms)) / 1000
    if age_seconds > 300:
        return False

    # Build the string to sign
    source = request_method + request_uri + request_body + timestamp_ms

    # Compute HMAC-SHA256 and base64-encode
    digest = hmac.new(
        secret.encode("utf-8"),
        source.encode("utf-8"),
        hashlib.sha256
    ).digest()
    expected_signature = base64.b64encode(digest).decode("utf-8")

    # Constant-time comparison
    return hmac.compare_digest(expected_signature, received_signature)
```

### Recommended Webhook Processing Architecture

```
Inbound Request
     │
     ▼
Validate Signature ──── FAIL ──▶ 403
     │
     ▼
Check Idempotency Key (Redis SETNX)
     │
     ├─ DUPLICATE ──▶ 200 OK (no-op)
     │
     ▼
Enqueue to Message Queue (SQS/RabbitMQ/Redis Queue)
     │
     ▼
200 OK (fast acknowledgment)
     │
     ▼ (async)
Worker processes event
     │
     ├─ SUCCESS ──▶ Done
     │
     └─ FAILURE ──▶ Retry queue ──▶ Dead Letter Queue (DLQ)
```

**DLQ purpose:** Events that fail repeatedly go to a dead letter queue for manual investigation. Prevents silent data loss.

---

## 16. CRM as Agent State Store

### Why Use HubSpot CRM for Agent State

When an agent processes CRM records, storing agent state directly in CRM properties has several advantages:
- State is co-located with the data being processed
- No separate state database required
- HubSpot workflows can react to state changes
- State is queryable via the search API
- Audit trail is automatic (HubSpot logs property changes with timestamps)

### Custom Properties for Agent State

Create a dedicated property group for agent state:

```python
# Create property group
def create_agent_property_group(object_type="contacts"):
    url = f"https://api.hubapi.com/crm/v3/properties/{object_type}/groups"
    payload = {
        "name": "agent_state",
        "label": "Agent State",
        "displayOrder": 99
    }
    return hubspot_post_raw(url, payload)

# Create individual state properties
agent_properties = [
    {
        "name": "agent_processing_status",
        "label": "Agent Processing Status",
        "type": "enumeration",
        "fieldType": "select",
        "options": [
            {"label": "Pending", "value": "pending", "displayOrder": 0},
            {"label": "In Progress", "value": "in_progress", "displayOrder": 1},
            {"label": "Completed", "value": "completed", "displayOrder": 2},
            {"label": "Failed", "value": "failed", "displayOrder": 3},
            {"label": "Skipped", "value": "skipped", "displayOrder": 4}
        ]
    },
    {
        "name": "agent_last_run_at",
        "label": "Agent Last Run At",
        "type": "datetime",
        "fieldType": "date"
    },
    {
        "name": "agent_task_id",
        "label": "Agent Task ID",
        "type": "string",
        "fieldType": "text"
    },
    {
        "name": "agent_result_summary",
        "label": "Agent Result Summary",
        "type": "string",
        "fieldType": "textarea"
    }
]
```

### State-Driven Agent Loop Pattern

```python
def run_agent_processing_loop():
    # Find all records that need processing
    pending = search_contacts_by_agent_status("pending")

    for contact in pending:
        contact_id = contact["id"]

        # Claim the record (prevent concurrent processing)
        update_agent_status(contact_id, "in_progress", task_id=generate_task_id())

        try:
            result = process_contact(contact)
            update_agent_status(contact_id, "completed", result=result)
        except Exception as e:
            update_agent_status(contact_id, "failed", error=str(e))

def search_contacts_by_agent_status(status):
    payload = {
        "filterGroups": [{
            "filters": [{
                "propertyName": "agent_processing_status",
                "operator": "EQ",
                "value": status
            }]
        }],
        "properties": ["email", "firstname", "lastname", "agent_processing_status"],
        "limit": 100
    }
    return paginate_search("contacts", payload)

def update_agent_status(contact_id, status, task_id=None, result=None, error=None):
    properties = {
        "agent_processing_status": status,
        "agent_last_run_at": str(int(datetime.utcnow().timestamp() * 1000))
    }
    if task_id:
        properties["agent_task_id"] = task_id
    if result:
        properties["agent_result_summary"] = str(result)[:65536]  # property char limit
    if error:
        properties["agent_result_summary"] = f"ERROR: {error}"[:65536]

    hubspot_patch(f"/crm/v3/objects/contacts/{contact_id}", {"properties": properties})
```

### Workflow Automation Triggered by Agent State

Create a HubSpot Workflow that fires when `agent_processing_status` changes to `completed`:

1. In HubSpot: Automation → Workflows → Create Workflow
2. Trigger: Contact property `agent_processing_status` becomes `completed`
3. Action: Send internal notification, enroll in sequence, create task, etc.

This allows agents to trigger HubSpot-native automations without directly calling the workflow API, creating a clean separation between agent processing and CRM automation.

### Custom Objects for Complex Agent State

For agents that manage multi-step processes or need to store structured state that does not fit contact/company properties, use Custom Objects:

```python
# Create a custom object for agent job tracking
def create_agent_job_object():
    url = "https://api.hubapi.com/crm/v3/schemas"
    payload = {
        "name": "agent_job",
        "labels": {"singular": "Agent Job", "plural": "Agent Jobs"},
        "primaryDisplayProperty": "job_id",
        "requiredProperties": ["job_id"],
        "searchableProperties": ["job_id", "status", "contact_id"],
        "properties": [
            {"name": "job_id", "label": "Job ID", "type": "string", "fieldType": "text", "hasUniqueValue": True},
            {"name": "status", "label": "Status", "type": "enumeration", "fieldType": "select",
             "options": [
                 {"label": "Queued", "value": "queued"},
                 {"label": "Running", "value": "running"},
                 {"label": "Done", "value": "done"},
                 {"label": "Error", "value": "error"}
             ]},
            {"name": "contact_id", "label": "Contact ID", "type": "string", "fieldType": "text"},
            {"name": "started_at", "label": "Started At", "type": "datetime", "fieldType": "date"},
            {"name": "completed_at", "label": "Completed At", "type": "datetime", "fieldType": "date"},
            {"name": "result_payload", "label": "Result Payload", "type": "string", "fieldType": "textarea"}
        ],
        "associatedObjects": ["CONTACT"]
    }
    return hubspot_post_raw(url, payload)
```

---

## 17. Python Code Patterns

### Complete Python Client Setup

```python
import os
import time
import random
import requests
from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any

ACCESS_TOKEN = os.getenv("HUBSPOT_ACCESS_TOKEN")
BASE_URL = "https://api.hubapi.com"

def get_headers():
    return {
        "Authorization": f"Bearer {ACCESS_TOKEN}",
        "Content-Type": "application/json"
    }

def hubspot_post(path: str, payload: dict) -> dict:
    return hubspot_request_with_retry("POST", f"{BASE_URL}{path}", payload)

def hubspot_patch(path: str, payload: dict) -> dict:
    return hubspot_request_with_retry("PATCH", f"{BASE_URL}{path}", payload)

def hubspot_get(path: str, params: dict = None) -> dict:
    return hubspot_request_with_retry("GET", f"{BASE_URL}{path}", params=params)
```

### Full Paginated Search Function

```python
def paginate_search(
    object_type: str,
    payload: dict,
    max_records: int = None
) -> List[dict]:
    """
    Paginate through all search results for a given object type and filter payload.
    Automatically handles cursor-based pagination and respects rate limits.
    """
    all_results = []
    page_count = 0

    while True:
        response = hubspot_post(
            f"/crm/v3/objects/{object_type}/search",
            payload
        )

        results = response.get("results", [])
        all_results.extend(results)
        page_count += 1

        print(f"Fetched page {page_count}: {len(results)} records "
              f"(total so far: {len(all_results)})")

        # Check max_records limit
        if max_records and len(all_results) >= max_records:
            all_results = all_results[:max_records]
            break

        # Check for next page
        next_cursor = response.get("paging", {}).get("next", {}).get("after")
        if not next_cursor:
            break

        # Update payload with cursor
        payload["after"] = next_cursor

        # Respect search rate limit: 5 req/sec
        time.sleep(0.2)

    return all_results
```

### Paginating Past the 10,000 Limit

```python
def fetch_all_contacts_past_10k_limit(base_filters: list) -> List[dict]:
    """
    Fetch all matching contacts regardless of the 10,000 search API limit,
    using the re-indexing pattern (filter by hs_object_id GT last_seen_id).
    """
    all_contacts = []
    last_id = "0"

    while True:
        # Build filters: user's filters + ID cursor
        filters = base_filters + [{
            "propertyName": "hs_object_id",
            "operator": "GT",
            "value": last_id
        }]

        payload = {
            "filterGroups": [{"filters": filters}],
            "sorts": [{"propertyName": "hs_object_id", "direction": "ASCENDING"}],
            "properties": ["email", "firstname", "lastname", "hs_object_id"],
            "limit": 200
        }

        batch = paginate_search("contacts", payload)

        if not batch:
            break

        all_contacts.extend(batch)
        last_id = batch[-1]["id"]  # hs_object_id of last record

        print(f"Fetched {len(all_contacts)} total contacts (last id: {last_id})")

    return all_contacts
```

### Using the Official Python SDK

```python
from hubspot import HubSpot
from hubspot.crm.contacts import (
    BatchInputSimplePublicObjectInput,
    BatchInputSimplePublicObjectBatchInputUpsert,
    PublicObjectSearchRequest,
    ApiException
)

api_client = HubSpot(access_token=ACCESS_TOKEN)

# Batch create
def batch_create_contacts(contact_list):
    inputs = [
        {"properties": c}
        for c in contact_list
    ]
    batch_input = BatchInputSimplePublicObjectInput(inputs=inputs)

    try:
        response = api_client.crm.contacts.batch_api.create(
            batch_input_simple_public_object_input=batch_input
        )
        return response
    except ApiException as e:
        print(f"HubSpot API error: {e}")
        raise

# Search with SDK
def search_contacts_sdk(email_domain):
    search_request = PublicObjectSearchRequest(
        filter_groups=[{
            "filters": [{
                "propertyName": "email",
                "operator": "CONTAINS_TOKEN",
                "value": f"*@{email_domain}"
            }]
        }],
        properties=["email", "firstname", "lastname", "lifecyclestage"],
        limit=100
    )

    try:
        response = api_client.crm.contacts.search_api.do_search(
            public_object_search_request=search_request
        )
        return response.results
    except ApiException as e:
        print(f"Search error: {e}")
        raise
```

### LangChain AI Agent with HubSpot Tools

```python
from langchain_openai import ChatOpenAI
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
from langchain.tools import tool

@tool
def search_contact_by_email(email: str) -> str:
    """
    Search for a contact in HubSpot by email address.
    Returns contact details including name, company, lifecycle stage.
    """
    payload = {
        "filterGroups": [{"filters": [{"propertyName": "email", "operator": "EQ", "value": email}]}],
        "properties": ["firstname", "lastname", "company", "jobtitle", "lifecyclestage", "hs_lead_status"]
    }
    results = hubspot_post("/crm/v3/objects/contacts/search", payload).get("results", [])
    if not results:
        return f"No contact found with email {email}"
    c = results[0]
    p = c["properties"]
    return (f"Contact ID: {c['id']}\n"
            f"Name: {p.get('firstname','')} {p.get('lastname','')}\n"
            f"Company: {p.get('company','')}\n"
            f"Stage: {p.get('lifecyclestage','')}")

@tool
def update_contact_lifecycle_stage(contact_id: str, new_stage: str) -> str:
    """
    Update the lifecycle stage for a HubSpot contact.
    Valid stages: subscriber, lead, marketingqualifiedlead, salesqualifiedlead, opportunity, customer, evangelist, other
    """
    valid_stages = ["subscriber","lead","marketingqualifiedlead","salesqualifiedlead",
                    "opportunity","customer","evangelist","other"]
    if new_stage not in valid_stages:
        return f"Invalid stage: {new_stage}. Valid: {valid_stages}"

    hubspot_patch(f"/crm/v3/objects/contacts/{contact_id}",
                  {"properties": {"lifecyclestage": new_stage}})
    return f"Contact {contact_id} lifecycle stage updated to {new_stage}"

@tool
def create_deal_for_contact(contact_id: str, deal_name: str, amount: str, stage: str) -> str:
    """Create a new deal in HubSpot and associate it with a contact."""
    deal = hubspot_post("/crm/v3/objects/deals", {
        "properties": {
            "dealname": deal_name,
            "amount": amount,
            "dealstage": stage,
            "pipeline": "default"
        },
        "associations": [{
            "to": {"id": contact_id},
            "types": [{"associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 3}]
        }]
    })
    return f"Deal created: ID {deal['id']} - {deal_name} (${amount})"

# Initialize agent
llm = ChatOpenAI(model="gpt-4o", temperature=0)
tools = [search_contact_by_email, update_contact_lifecycle_stage, create_deal_for_contact]

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a CRM assistant with access to HubSpot. "
               "Help manage contacts, deals, and lifecycle stages accurately."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# Run
result = agent_executor.invoke({
    "input": "Find alice@example.com and update her lifecycle stage to customer"
})
```

---

## 18. JavaScript/Node.js Code Patterns

### Authentication Setup

```javascript
const axios = require('axios');

const HUBSPOT_BASE_URL = 'https://api.hubapi.com';
const ACCESS_TOKEN = process.env.HUBSPOT_ACCESS_TOKEN;

const hubspotClient = axios.create({
  baseURL: HUBSPOT_BASE_URL,
  headers: {
    'Authorization': `Bearer ${ACCESS_TOKEN}`,
    'Content-Type': 'application/json'
  },
  timeout: 30000
});

// OAuth flow for multi-account apps
const { Client } = require('@hubspot/api-client');
const CLIENT_ID = process.env.HUBSPOT_CLIENT_ID;
const CLIENT_SECRET = process.env.HUBSPOT_CLIENT_SECRET;

async function exchangeCodeForTokens(code) {
  const client = new Client({ clientId: CLIENT_ID, clientSecret: CLIENT_SECRET });
  const tokensResponse = await client.oauth.tokensApi.create(
    'authorization_code',
    code,
    process.env.HUBSPOT_REDIRECT_URI,
    CLIENT_ID,
    CLIENT_SECRET
  );
  return tokensResponse;
}
```

### Search with Retry and Rate Limiting

```javascript
async function searchHubSpot(objectType, filterGroups, options = {}) {
  const {
    properties = [],
    sorts = [],
    limit = 200,
    maxRetries = 5
  } = options;

  const payload = { filterGroups, properties, sorts, limit };

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await hubspotClient.post(
        `/crm/v3/objects/${objectType}/search`,
        payload
      );
      return response.data;
    } catch (error) {
      const status = error.response?.status;

      if (status === 429) {
        const retryAfterMs = parseInt(error.response.headers['retry-after'] || '1000');
        const jitter = Math.random() * 1000;
        const wait = retryAfterMs + jitter;
        console.log(`Rate limited. Waiting ${wait}ms (attempt ${attempt + 1})`);
        await new Promise(resolve => setTimeout(resolve, wait));
        continue;
      }

      if ([423, 502, 503, 504, 521, 523, 524].includes(status)) {
        const wait = (2 ** attempt) * 1000 + Math.random() * 1000;
        console.log(`Transient error ${status}. Waiting ${wait}ms`);
        await new Promise(resolve => setTimeout(resolve, wait));
        continue;
      }

      // Non-retryable
      throw error;
    }
  }
  throw new Error(`Max retries exceeded for search on ${objectType}`);
}
```

### Full Paginated Search (Node.js)

```javascript
async function paginateSearch(objectType, filterGroups, properties = []) {
  const allResults = [];
  let afterCursor = null;

  do {
    const payload = {
      filterGroups,
      properties,
      limit: 200,
      sorts: [{ propertyName: 'createdate', direction: 'ASCENDING' }],
      ...(afterCursor ? { after: afterCursor } : {})
    };

    const data = await searchHubSpot(objectType, filterGroups, { properties });
    allResults.push(...data.results);

    afterCursor = data.paging?.next?.after ?? null;

    // Rate limit: search API is 5 req/sec
    await new Promise(resolve => setTimeout(resolve, 200));

  } while (afterCursor);

  return allResults;
}
```

### Batch Upsert in Node.js

```javascript
const { Client } = require('@hubspot/api-client');
const hubspot = new Client({ accessToken: ACCESS_TOKEN });

async function batchUpsertContacts(contacts) {
  const inputs = contacts.map(c => ({
    idProperty: 'email',
    id: c.email,
    properties: {
      email: c.email,
      firstname: c.firstname,
      lastname: c.lastname,
      company: c.company,
      agent_last_synced: Date.now().toString()
    }
  }));

  const chunks = [];
  for (let i = 0; i < inputs.length; i += 100) {
    chunks.push(inputs.slice(i, i + 100));
  }

  const results = [];
  for (const chunk of chunks) {
    try {
      const response = await hubspot.crm.contacts.batchApi.upsert({ inputs: chunk });
      results.push(...response.results);
    } catch (e) {
      console.error('Batch upsert error:', e.message);
      // Handle partial failure: try individual upserts for this chunk
    }
    await new Promise(resolve => setTimeout(resolve, 200));
  }

  return results;
}
```

### Webhook Handler with Idempotency (Express)

```javascript
const express = require('express');
const redis = require('redis');
const crypto = require('crypto');

const app = express();
const redisClient = redis.createClient();

// Preserve raw body for signature verification
app.use(express.json({
  verify: (req, res, buf) => { req.rawBody = buf; }
}));

function verifyHubSpotSignature(req) {
  const secret = process.env.HUBSPOT_APP_SECRET;
  const timestamp = req.headers['x-hubspot-request-timestamp'];
  const receivedSig = req.headers['x-hubspot-signature-v3'];

  if (!timestamp || !receivedSig) return false;

  // Reject stale requests
  const ageMs = Date.now() - parseInt(timestamp);
  if (ageMs > 300000) return false;

  const source = req.method + req.url + req.rawBody.toString() + timestamp;
  const expected = crypto
    .createHmac('sha256', secret)
    .update(source)
    .digest('base64');

  return crypto.timingSafeEqual(
    Buffer.from(expected),
    Buffer.from(receivedSig)
  );
}

app.post('/hubspot/webhook', async (req, res) => {
  if (!verifyHubSpotSignature(req)) {
    return res.status(403).json({ error: 'Invalid signature' });
  }

  // Immediately acknowledge
  res.status(200).json({ status: 'accepted' });

  // Process asynchronously
  const events = req.body;
  for (const event of events) {
    const key = `hs:event:${event.eventId}`;
    const isNew = await redisClient.set(key, '1', { NX: true, EX: 604800 }); // 7-day TTL

    if (isNew) {
      // Enqueue for processing (use your queue system here)
      await processQueue.add(event);
    }
  }
});
```

---

## 19. Production Architecture Reference

### Reference Architecture for AI Agent + HubSpot CRM

```
External Triggers
(form, webhook, schedule)
         │
         ▼
    Agent Orchestrator
    (LangChain / CrewAI / custom)
         │
         ├──▶ Search API ──▶ Filter matching records
         │         │
         │         ▼
         │    Rate Limiter
         │    (5 req/sec search, 150 req/10s general)
         │
         ├──▶ Batch Read ──▶ Fetch full property data
         │
         ├──▶ Enrich ──▶ External APIs, LLM scoring
         │
         ├──▶ Batch Upsert ──▶ Write results back to CRM
         │
         └──▶ State Update ──▶ Set agent_processing_status
                   │
                   ▼
            HubSpot Workflow
            (triggered by status change)
                   │
                   ▼
            Notify / Enroll / Route
```

### Key Design Principles for Production

1. **Authenticate with minimum scopes.** Request only the scopes your agent actually uses. Reduces blast radius if a token is compromised.

2. **Never hardcode tokens.** Store in environment variables or a secrets manager (AWS Secrets Manager, HashiCorp Vault). Rotate regularly.

3. **Always paginate defensively.** Never assume a single page returns all results. Always check `paging.next.after`.

4. **Implement exactly-once semantics.** Use eventId for webhooks, custom unique properties for contact operations. Redis SETNX is the standard pattern.

5. **Use upsert instead of create.** `POST /batch/upsert` is safer than checking-then-creating. Eliminates the race condition window.

6. **Sort by hs_object_id for large exports.** The re-indexing pattern (GT last ID) is the only reliable way to exceed 10,000 records with the search API.

7. **Respect the search rate limit separately.** The 5 req/sec search limit is distinct from the general API limit. Space search calls by at least 200ms.

8. **Acknowledge webhooks fast.** Respond 200 within 5 seconds or HubSpot will retry. Enqueue immediately and process asynchronously.

9. **Log correlationId on every error.** HubSpot support requires this for investigation. Store it alongside your request metadata.

10. **Add jitter to all backoff.** Pure exponential backoff without randomization causes synchronized retry storms when multiple agent instances hit limits simultaneously.

### Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Search polling every second | Exceeds 5 req/sec limit | Webhooks for real-time, polling at 30min+ intervals |
| Creating contacts in a loop | Duplicates + slow | Batch upsert with email as idProperty |
| Ignoring `total` in search response | Missing records silently | Check total, use re-indexing if > 10,000 |
| Storing tokens in browser JS | Credential exposure | Server-side only, secrets manager |
| No idempotency on retries | Duplicate records/actions | Redis SETNX on eventId or request ID |
| Full dataset download via search | 10k cap hit | List endpoint for full download, search for filtered ops |
| Advancing sync cursor before commit | Lost updates on crash | Advance cursor only after confirmed write |
| Filtering IN with uppercase values | No matches returned | Lowercase all string values in IN/NOT_IN operators |
| Using page numbers (not cursors) | Skipped/duplicated records | Always use `after` cursor from `paging.next.after` |

---

*Document compiled from: HubSpot Developer Documentation (developers.hubspot.com), HubSpot Community forums, agentsapis.com HubSpot Integration Guide, insightsalesglobal.com webhook retry patterns, aiagentlearn.site AI agent integration guide. Date: 2026-03-18.*
