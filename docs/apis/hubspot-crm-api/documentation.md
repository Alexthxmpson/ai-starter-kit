# HubSpot CRM API — Technical Documentation

**Source:** https://developers.hubspot.com/docs/api/overview
**Date Saved:** 2026-03-18
**Research Method:** 6-agent parallel deep research (overnight mode)
**Full Research Package:** See MASTER-SYNTHESIS.md, round-1/, briefings/

---

## Overview

HubSpot CRM API is a REST-based platform providing programmatic access to the full HubSpot data model. Current stable version for CRM objects is **v3** (`/crm/v3/`). Associations have moved to **v4** (`/crm/v4/`).

**Base URLs:**
- `https://api.hubspot.com` (primary)
- `https://api.hubapi.com` (legacy, still works)

**Authentication:** Bearer token in `Authorization` header
**Format:** JSON (`Content-Type: application/json`)

---

## Authentication

### Private Apps (Recommended for AI Agents)
- Created in HubSpot account → Settings → Private Apps
- Token format: `pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (up to 512 chars)
- **No expiry** — stable long-lived token, ideal for automated systems
- Scoped at creation — cannot change scopes without regenerating
- Usage: `Authorization: Bearer {token}`

### OAuth 2.0 (Multi-tenant SaaS)
- Authorization Code flow for user-facing apps
- Tokens expire in **30 minutes** — must refresh using `refresh_token`
- Token endpoint: `POST https://api.hubspot.com/oauth/v1/token`
- Store `refresh_token` securely; exchange for new `access_token` proactively (before expiry)

### Deprecated (Do Not Use)
- API keys (`hapikey` query param) — deprecated, removed for many endpoints

### Key Scopes

| Scope | Grants |
|-------|--------|
| `crm.objects.contacts.read` | Read contacts |
| `crm.objects.contacts.write` | Create/update/delete contacts |
| `crm.objects.companies.read` | Read companies |
| `crm.objects.companies.write` | Create/update/delete companies |
| `crm.objects.deals.read` | Read deals |
| `crm.objects.deals.write` | Create/update/delete deals |
| `crm.objects.tickets.read` | Read tickets |
| `crm.objects.tickets.write` | Create/update/delete tickets |
| `crm.schemas.custom.read` | Read custom object schemas |
| `crm.objects.custom.read` | Read custom object records |
| `crm.objects.custom.write` | Write custom object records |
| `crm.associations.read` | Read associations |
| `crm.associations.write` | Create/delete associations |
| `sales-email-read` | Read email engagements |
| `timeline` | Create timeline events |
| `webhooks` | Manage webhook subscriptions |

---

## Core Objects

### Object Type IDs

| Object | objectTypeId | API Name | Dedup Key |
|--------|-------------|----------|-----------|
| Contacts | `0-1` | `contacts` | `email` |
| Companies | `0-2` | `companies` | `domain` |
| Deals | `0-3` | `deals` | none |
| Tickets | `0-5` | `tickets` | none |
| Notes | `0-46` | `notes` | — |
| Meetings | `0-47` | `meetings` | — |
| Calls | `0-48` | `calls` | — |
| Emails | `0-49` | `emails` | — |
| Tasks | `0-27` | `tasks` | — |

### Standard Endpoints Pattern

```
GET    /crm/v3/objects/{objectType}              # List all
GET    /crm/v3/objects/{objectType}/{recordId}   # Get one
POST   /crm/v3/objects/{objectType}              # Create
PATCH  /crm/v3/objects/{objectType}/{recordId}   # Update
DELETE /crm/v3/objects/{objectType}/{recordId}   # Archive

POST   /crm/v3/objects/{objectType}/batch/create  # Batch create (up to 100)
POST   /crm/v3/objects/{objectType}/batch/read    # Batch read (up to 100)
POST   /crm/v3/objects/{objectType}/batch/update  # Batch update (up to 100)
POST   /crm/v3/objects/{objectType}/batch/upsert  # Batch upsert (up to 100)
POST   /crm/v3/objects/{objectType}/batch/archive # Batch delete (up to 100)
```

### Create Contact
```http
POST /crm/v3/objects/contacts
Authorization: Bearer {token}
Content-Type: application/json

{
  "properties": {
    "email": "john.doe@example.com",
    "firstname": "John",
    "lastname": "Doe",
    "phone": "+1234567890",
    "company": "Acme Corp"
  }
}
```

### Batch Read Contacts by Email
```http
POST /crm/v3/objects/contacts/batch/read
{
  "properties": ["email", "firstname", "lastname", "phone"],
  "idProperty": "email",
  "inputs": [
    {"id": "john@example.com"},
    {"id": "jane@example.com"}
  ]
}
```

### Batch Upsert (Create or Update)
```http
POST /crm/v3/objects/contacts/batch/upsert
{
  "inputs": [
    {
      "idProperty": "email",
      "id": "john@example.com",
      "properties": {
        "firstname": "John",
        "lastname": "Doe Updated"
      }
    }
  ]
}
```

---

## Search API

```http
POST /crm/v3/objects/{objectType}/search
```

### Request Structure
```json
{
  "filterGroups": [
    {
      "filters": [
        {
          "propertyName": "email",
          "operator": "CONTAINS_TOKEN",
          "value": "@company.com"
        }
      ]
    }
  ],
  "sorts": [{"propertyName": "createdate", "direction": "DESCENDING"}],
  "properties": ["email", "firstname", "lastname"],
  "limit": 100,
  "after": "cursor_from_previous_page"
}
```

### Filter Operators

| Operator | Description |
|----------|-------------|
| `EQ` | Equal |
| `NEQ` | Not equal |
| `LT` / `LTE` | Less than / Less than or equal |
| `GT` / `GTE` | Greater than / Greater than or equal |
| `BETWEEN` | Range (values array: [min, max]) |
| `IN` | In list (values array, must be lowercase strings) |
| `NOT_IN` | Not in list |
| `HAS_PROPERTY` | Property exists |
| `NOT_HAS_PROPERTY` | Property does not exist |
| `CONTAINS_TOKEN` | Contains token (use for email domain) |
| `NOT_CONTAINS_TOKEN` | Does not contain token |

**Logic:** Filters within a group = AND. Multiple filterGroups = OR.
**Limits:** 5 filterGroups, 6 filters per group, 18 filters total.
**Pagination:** Use `paging.next.after` cursor (NOT page numbers).
**Hard limit:** 10,000 records max. Workaround: chunk by date range or use `hs_object_id GT {last_id}`.

---

## Pipelines & Stages

```http
GET /crm/v3/pipelines/{objectType}           # List all pipelines
GET /crm/v3/pipelines/{objectType}/{id}      # Get single pipeline
POST /crm/v3/pipelines/{objectType}          # Create pipeline
GET /crm/v3/pipelines/{objectType}/{id}/stages/{stageId}  # Get stage
```

Stage properties:
- `label` — Display name
- `displayOrder` — Sort order
- `metadata.probability` — Deal win probability (0.0-1.0)
- `metadata.ticketState` — OPEN or CLOSED (tickets only)

Move a deal to a new stage: `PATCH /crm/v3/objects/deals/{id}` with `{"properties": {"dealstage": "{stageId}"}}`

---

## Custom Properties

```http
GET    /crm/v3/properties/{objectType}           # List all properties
POST   /crm/v3/properties/{objectType}           # Create property
GET    /crm/v3/properties/{objectType}/{name}    # Get property
PATCH  /crm/v3/properties/{objectType}/{name}    # Update property
DELETE /crm/v3/properties/{objectType}/{name}    # Delete property
```

### Property Types Matrix

| type | fieldType | Description |
|------|-----------|-------------|
| `string` | `text` | Single-line text |
| `string` | `textarea` | Multi-line text |
| `string` | `select` | Single-select dropdown |
| `string` | `radio` | Radio buttons |
| `enumeration` | `checkbox` | Multi-select checkboxes |
| `number` | `number` | Numeric value |
| `date` | `date` | Date only (YYYY-MM-DD) |
| `datetime` | `date` | Date + time (Unix ms) |
| `bool` | `booleancheckbox` | True/false |
| `string` | `file` | File attachment URL |

### Create Custom Property
```json
POST /crm/v3/properties/contacts
{
  "name": "agent_status",
  "label": "Agent Processing Status",
  "type": "string",
  "fieldType": "select",
  "groupName": "contactinformation",
  "options": [
    {"label": "Pending", "value": "pending", "displayOrder": 0},
    {"label": "Processing", "value": "processing", "displayOrder": 1},
    {"label": "Complete", "value": "complete", "displayOrder": 2}
  ]
}
```

---

## Associations (v4)

```http
PUT    /crm/v4/associations/{fromType}/{toType}/batch/create    # Create
POST   /crm/v4/associations/{fromType}/{toType}/batch/read      # Read
DELETE /crm/v4/associations/{fromType}/{toType}/batch/archive   # Delete
```

### Common Association Type IDs

| From | To | Type ID | Label |
|------|----|---------|-------|
| contact | company | 279 | Primary company |
| contact | deal | 4 | Contact to deal |
| contact | ticket | 16 | Contact to ticket |
| company | deal | 5 | Company to deal |
| company | contact | 280 | Company contacts |
| deal | contact | 3 | Deal contacts |
| deal | company | 6 | Deal company |
| deal | ticket | 28 | Deal to ticket |

---

## Webhooks

**Setup:** HubSpot account → Settings → Integrations → Private Apps → Webhooks tab
OR via API: `POST /webhooks/v3/{appId}/subscriptions`

### Event Types
- `contact.creation`, `contact.deletion`, `contact.propertyChange`
- `company.creation`, `company.deletion`, `company.propertyChange`
- `deal.creation`, `deal.deletion`, `deal.propertyChange`, `deal.associationChange`
- `ticket.creation`, `ticket.deletion`, `ticket.propertyChange`
- `contact.merge`, `contact.restore`, `contact.privacyDeletion`

### Payload Structure
```json
[
  {
    "eventId": 1234567890,
    "subscriptionId": 12345,
    "portalId": 123456,
    "appId": 1234,
    "occurredAt": 1710123456789,
    "eventType": "contact.propertyChange",
    "attemptNumber": 0,
    "objectId": 789,
    "propertyName": "email",
    "propertyValue": "new@email.com",
    "changeSource": "CRM_UI",
    "objectTypeId": "0-1"
  }
]
```

### HMAC Signature Validation (Python)
```python
import hmac
import hashlib

def validate_webhook_v3(secret: str, request_uri: str, body: str, timestamp: str, signature: str) -> bool:
    source = f"{secret}{request_uri}{body}{timestamp}"
    expected = hmac.new(secret.encode(), source.encode(), hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature)
```

**Retry schedule:** HubSpot retries failed webhooks up to 10 times over 24 hours with exponential backoff. Delivery is at-least-once — implement idempotency.

---

## Rate Limits

| Plan | Burst (per 10s) | Daily |
|------|-----------------|-------|
| Free | 100 | 250,000 |
| Starter | 100 | 250,000 |
| Professional | 190 | 625,000 |
| Enterprise | 190 | 1,000,000 |

**Search API:** Separate limit of **5 requests/second** across all plans.

### Rate Limit Headers
```
X-HubSpot-RateLimit-Daily: 250000
X-HubSpot-RateLimit-Daily-Remaining: 249800
X-HubSpot-RateLimit-Interval-Milliseconds: 10000
X-HubSpot-RateLimit-Max: 100
X-HubSpot-RateLimit-Remaining: 95
```

**429 Response:**
```json
{"status": "error", "message": "You have reached your secondly limit.", "policyName": "SECONDLY"}
```

### Exponential Backoff (Python)
```python
import time, random

def call_with_retry(fn, max_retries=5):
    for attempt in range(max_retries):
        try:
            return fn()
        except RateLimitError:
            wait = (2 ** attempt) + random.uniform(0, 1)
            time.sleep(wait)
    raise Exception("Max retries exceeded")
```

---

## Custom Objects (Enterprise Only)

```http
GET    /crm-object-schemas/v3/schemas            # List schemas
POST   /crm-object-schemas/v3/schemas            # Create schema
GET    /crm-object-schemas/v3/schemas/{objectType}  # Get schema
PATCH  /crm-object-schemas/v3/schemas/{objectType}  # Update schema
DELETE /crm-object-schemas/v3/schemas/{objectType}  # Delete schema
```

### Create Schema
```json
{
  "name": "ai_agent_session",
  "labels": {"singular": "AI Agent Session", "plural": "AI Agent Sessions"},
  "primaryDisplayProperty": "session_id",
  "requiredProperties": ["session_id"],
  "properties": [
    {
      "name": "session_id",
      "label": "Session ID",
      "type": "string",
      "fieldType": "text",
      "hasUniqueValue": true
    }
  ],
  "associatedObjects": ["CONTACT", "DEAL"]
}
```

**Note:** Schema `name` is PERMANENT once created. Use a descriptive, lowercase, underscore name.

---

## Official SDKs

### Python
```bash
pip install hubspot-api-client
```
```python
from hubspot import HubSpot
client = HubSpot(access_token="pat-na1-...")
contact = client.crm.contacts.basic_api.get_by_id("123", properties=["email"])
```

### Node.js
```bash
npm install @hubspot/api-client
```
```javascript
const hubspot = require('@hubspot/api-client');
const client = new hubspot.Client({ accessToken: 'pat-na1-...' });
const contact = await client.crm.contacts.basicApi.getById('123');
```

---

## Common Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| 400 | Bad request | Fix request format |
| 401 | Unauthorized | Check token |
| 403 | Forbidden | Check scopes |
| 404 | Not found | Record doesn't exist |
| 409 | Conflict | Duplicate property/schema name |
| 422 | Unprocessable | Invalid property value |
| 429 | Rate limited | Backoff and retry |
| 500 | Server error | Retry with backoff |
| 502/503 | Service unavailable | Retry |

---

## Key Gotchas

1. **Private App tokens never expire** — but HubSpot can scan and invalidate tokens found in public repos
2. **Batch 207 responses** — batch calls return 207 Multi-Status on partial failure; always check `results` and `errors` arrays
3. **Search API 10K limit** — cannot page beyond 10,000 records; use date-range chunking or export API
4. **Search API 5 req/sec** — much stricter than regular API; implement separate rate limiter for search
5. **IN operator values must be lowercase** — enumeration filter values must be lowercase strings
6. **Custom object schema names are permanent** — name cannot be changed after creation
7. **Pipeline stage IDs are not portable** — stage IDs differ between portals (same name = different ID)
8. **Properties API GET returns all properties including system ones** — filter by `hidden: false` for user-created
9. **Webhook delivery is at-least-once** — same event can arrive multiple times; use `eventId` for dedup
10. **Associations v3 is deprecated** — use v4 endpoints for all new association operations
11. **Custom objects require Enterprise tier** — not available on Free/Starter/Professional
12. **Custom code workflow actions require Operations Hub Professional or Enterprise**

---

## Full Research Package

For complete documentation see:
- `MASTER-SYNTHESIS.md` — Full 10-part synthesis (8,000+ words)
- `round-1/agent1-auth-core-objects.md` — Auth + Contacts/Companies/Deals/Tickets
- `round-1/agent2-pipelines-properties.md` — Pipelines + Custom Properties
- `round-1/agent3-webhooks-rate-limits.md` — Webhooks + Rate Limits
- `round-1/agent4-associations-engagements.md` — Associations + Engagements
- `round-1/agent5-search-ai-patterns.md` — Search API + AI Agent Patterns
- `round-1/agent6-custom-objects-advanced.md` — Custom Objects + SDKs + Advanced
- `briefings/` — 5 focused briefings per topic area
- `GAP-ANALYSIS.md` — Coverage assessment
- `KNOWLEDGE-MAP.md` — Component tree and quick reference
- `source-registry.yaml` — 33 sources with quality scores
