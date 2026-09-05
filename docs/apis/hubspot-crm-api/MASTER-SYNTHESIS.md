---
title: HubSpot CRM API — Complete Reference for AI Agent Integration
date: 2026-03-18
source: Deep research synthesis from 6 parallel research agents
version: 1.0
---

# HubSpot CRM API — Master Synthesis

---

## Part 1: Executive Summary

The HubSpot CRM API is a mature, REST-based platform that gives programmatic access to the full HubSpot data model — contacts, companies, deals, tickets, custom objects, pipelines, properties, associations, engagements, and workflow automation. For AI agent integration, it is one of the more agent-friendly CRM platforms: it supports idempotent batch operations, upsert patterns, a structured search API, webhook push notifications, and custom properties that can be used to store agent state directly on CRM records.

The API is versioned. The current stable version for CRM objects is v3 (`/crm/v3/`), associations have moved to v4 (`/crm/v4/`), and a 2025-09 dated versioning scheme is being introduced for newer endpoints. All authentication uses Bearer tokens in the `Authorization` header — either Private App tokens (stable, long-lived, recommended for internal agents) or OAuth 2.0 access tokens (for multi-tenant SaaS products).

Rate limits are the most important operational constraint. They are tier-dependent and enforced at two levels — burst (per 10-second window) and daily. Free/Starter accounts are limited to 100 requests per 10 seconds and 250,000 per day; Professional gets 190 burst and 625,000 daily; Enterprise gets 190 burst and 1,000,000 daily. The Search API has a separate, stricter limit of 5 requests per second. Building an AI agent without proper rate limit handling will cause production 429 errors. Batch endpoints (100 records per call) are the primary mitigation.

**Recommended approach for a new AI agent on HubSpot CRM:** Use a Private App token stored in an environment variable. Request only the scopes your agent needs. Use batch CRUD operations whenever possible. Store agent state (processing status, timestamps, external IDs) as custom properties on the CRM records themselves. Use webhooks for real-time triggering and incremental polling (`lastmodifieddate GT {cursor}`) for background sync. Deduplicate by email (contacts) and domain (companies). Implement exponential backoff for 429s and transient 5xx errors.

---

## Part 2: Background & Architecture

### Base URL and Versioning

```
Base URL: https://api.hubspot.com
Alternative base: https://api.hubapi.com  (both work, api.hubapi.com is older but still valid)
```

| API Family | Path Pattern | Version |
|---|---|---|
| CRM Objects (CRUD) | `/crm/v3/objects/{objectType}` | v3 (stable) |
| CRM Search | `/crm/v3/objects/{objectType}/search` | v3 (stable) |
| CRM Properties | `/crm/v3/properties/{objectType}` | v3 (stable) |
| CRM Pipelines | `/crm/v3/pipelines/{objectType}` | v3 (stable) |
| CRM Associations | `/crm/v4/associations/{from}/{to}` | v4 (current) |
| Custom Object Schemas | `/crm-object-schemas/v3/schemas` | v3 |
| Import API | `/crm/v3/imports` | v3 |
| Lists API | `/crm/v3/lists` | v3 |
| OAuth | `/oauth/v1/token` | v1 |
| Webhooks | `/webhooks/v3/{appId}/` | v3 |
| Webhooks (new) | `/webhooks/v4/` | v4 (beta) |

### CRM Object Model

HubSpot CRM is organized into **objects**, **records**, and **properties**.

- **Objects** — entity types (Contacts, Companies, Deals, Tickets, custom objects)
- **Records** — individual instances of an object
- **Properties** — data fields attached to records
- **Associations** — typed relationships between records
- **Engagements** — activities (Notes, Calls, Emails, Meetings, Tasks) linked to records
- **Pipelines** — ordered stage workflows for Deals and Tickets

### Object Type IDs

| Object | objectTypeId | API Name | Notes |
|---|---|---|---|
| Contacts | `0-1` | `contacts` | Primary dedup: `email` |
| Companies | `0-2` | `companies` | Primary dedup: `domain` |
| Deals | `0-3` | `deals` | No natural unique key |
| Tickets | `0-5` | `tickets` | No natural unique key |
| Products | `0-7` | `products` | |
| Line Items | `0-8` | `line_items` | |
| Notes | `0-46` | `notes` | Engagement subtype |
| Meetings | `0-47` | `meetings` | Engagement subtype |
| Calls | `0-48` | `calls` | Engagement subtype |
| Emails | `0-49` | `emails` | Engagement subtype |
| Tasks | `0-27` | `tasks` | Engagement subtype |
| Quotes | `0-14` | `quotes` | |
| Leads | `0-136` | `leads` | |
| Custom Objects | `2-XXX` | (user-defined name) | Enterprise tier required |

Every record has a system-generated `hs_object_id` (the Record ID). Custom unique identifier properties can be created and used as alternative keys for lookups and upsert operations.

---

## Part 3: Authentication & Authorization

### Method Comparison

**VALIDATED** (all 6 agents agree):

| Method | Status | Best For | Token Lifetime |
|---|---|---|---|
| Private Apps (access tokens) | Recommended | Internal agents, single-account automation | Stable (no expiry) |
| OAuth 2.0 | Recommended | Multi-tenant SaaS, public apps | 30 min (refresh token refreshes it) |
| API Keys (`hapikey`) | Deprecated | Do not use | N/A |

### Private App Authentication (Recommended for AI Agents)

Private App tokens replace the deprecated `hapikey` system. They are long-lived (no time-based expiry), scoped to a single portal, and require no OAuth handshake at runtime.

**Token format:**
```
pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```
Tokens begin with `pat-`. HubSpot states token sizes may fluctuate — accommodate up to **512 characters** in storage.

**Usage in requests:**
```http
Authorization: Bearer pat-na1-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Content-Type: application/json
```

**Creating a Private App:**
1. Settings > Integrations > Private Apps (super admin only)
2. Set name and select required scopes on the Scopes tab
3. Click Create app → Auth tab → Show token

**Token rotation best practice:** Rotate every 6 months. Use 7-day scheduled rotation to avoid downtime. Update your environment variable, then confirm deployment before the old token expires.

**Python usage:**
```python
import os, requests

headers = {
    "Authorization": f"Bearer {os.environ['HUBSPOT_ACCESS_TOKEN']}",
    "Content-Type": "application/json"
}
response = requests.get("https://api.hubspot.com/crm/v3/objects/contacts", headers=headers)
```

### OAuth 2.0 Flow

Required for multi-account integrations. OAuth access tokens expire every **30 minutes**. The refresh token is long-lived and used to obtain new access tokens.

**Step 1 — Authorization URL:**
```
https://app.hubspot.com/oauth/authorize
  ?client_id={client_id}
  &redirect_uri={redirect_uri}
  &scope=crm.objects.contacts.read%20crm.objects.contacts.write
```

**Step 2 — Token Exchange:**
```http
POST https://api.hubspot.com/oauth/v1/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code={authorization_code}
&redirect_uri={redirect_uri}
&client_id={client_id}
&client_secret={client_secret}
```

Response: `access_token`, `refresh_token`, `expires_in` (1800 seconds).

**Step 3 — Token Refresh:**
```python
class HubSpotTokenManager:
    def __init__(self, client_id, client_secret, refresh_token):
        self.client_id = client_id
        self.client_secret = client_secret
        self.refresh_token = refresh_token
        self.access_token = None
        self.expires_at = 0

    def get_token(self):
        if time.time() >= self.expires_at - 60:  # refresh 60s before expiry
            self._refresh()
        return self.access_token

    def _refresh(self):
        response = requests.post(
            "https://api.hubspot.com/oauth/v1/token",
            data={
                "grant_type": "refresh_token",
                "refresh_token": self.refresh_token,
                "client_id": self.client_id,
                "client_secret": self.client_secret
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        data = response.json()
        self.access_token = data["access_token"]
        self.expires_at = time.time() + data["expires_in"]
```

**Token introspection:**
```
GET https://api.hubspot.com/oauth/v1/access-tokens/{token}
```
Returns: `user`, `hub_id`, `scopes`, `expires_in`.

### Scopes Reference

#### Core CRM Object Scopes

| Scope | Access Granted |
|---|---|
| `crm.objects.contacts.read` | Read contact records |
| `crm.objects.contacts.write` | Create, update, delete contacts |
| `crm.objects.companies.read` | Read company records |
| `crm.objects.companies.write` | Create, update, delete companies |
| `crm.objects.deals.read` | Read deal records |
| `crm.objects.deals.write` | Create, update, delete deals |
| `tickets` | Read and write ticket records (single scope) |
| `crm.objects.owners.read` | Read HubSpot user/owner records |
| `crm.objects.custom.read` | Read custom object records |
| `crm.objects.custom.write` | Create, update, delete custom object records |
| `crm.objects.line_items.read/write` | Line item records |

#### Schema Scopes

| Scope | Access Granted |
|---|---|
| `crm.schemas.contacts.read/write` | Contact property definitions |
| `crm.schemas.companies.read/write` | Company property definitions |
| `crm.schemas.deals.read/write` | Deal property definitions |
| `crm.schemas.custom.read/write` | Custom object schemas (Enterprise) |

#### Minimum Scopes for a Standard AI Agent

```
crm.objects.contacts.read
crm.objects.contacts.write
crm.objects.companies.read
crm.objects.companies.write
crm.objects.deals.read
crm.objects.deals.write
tickets
crm.objects.owners.read
crm.schemas.deals.read
crm.schemas.contacts.read
```

---

## Part 4: Core Objects & CRUD Operations

### Endpoint Pattern

All CRM objects share a consistent URL pattern:

```
GET    /crm/v3/objects/{objectType}              — list all records
GET    /crm/v3/objects/{objectType}/{recordId}   — get single record
POST   /crm/v3/objects/{objectType}              — create record
PATCH  /crm/v3/objects/{objectType}/{recordId}   — update record
DELETE /crm/v3/objects/{objectType}/{recordId}   — archive (soft delete)

POST   /crm/v3/objects/{objectType}/batch/create  — batch create (max 100)
POST   /crm/v3/objects/{objectType}/batch/read    — batch read (max 100)
POST   /crm/v3/objects/{objectType}/batch/update  — batch update (max 100)
POST   /crm/v3/objects/{objectType}/batch/upsert  — batch upsert (max 100)
POST   /crm/v3/objects/{objectType}/batch/archive — batch delete (max 100)
POST   /crm/v3/objects/{objectType}/search        — filtered search
```

### 4.1 Contacts

**Deduplication key:** `email`

**Create:**
```json
POST /crm/v3/objects/contacts
{
  "properties": {
    "email": "jane@example.com",
    "firstname": "Jane",
    "lastname": "Doe",
    "phone": "+18884827768",
    "jobtitle": "Marketing Manager",
    "lifecyclestage": "marketingqualifiedlead"
  }
}
```

**Read by email (alternative ID):**
```
GET /crm/v3/objects/contacts/{email}?idProperty=email&properties=email,firstname,lastname
```

**Update — clear a property:**
```json
PATCH /crm/v3/objects/contacts/{id}
{ "properties": { "phone": "" } }
```

**Lifecycle stage constraint:** Stages can only move forward (subscriber → lead → ... → customer). To move backward, first clear the property: `"lifecyclestage": ""`, then set the desired stage.

**Batch upsert (create-or-update atomically):**
```json
POST /crm/v3/objects/contacts/batch/upsert
{
  "inputs": [
    {
      "idProperty": "email",
      "id": "alice@example.com",
      "properties": { "firstname": "Alice", "lifecyclestage": "customer" }
    }
  ]
}
```

**Key contact properties:**

| Property | Type | Notes |
|---|---|---|
| `email` | string | Primary dedup key |
| `hs_additional_emails` | string | Semicolon-separated additional emails |
| `firstname`, `lastname` | string | |
| `phone`, `mobilephone` | string | |
| `jobtitle`, `company` | string | `company` is text, not a linked record |
| `lifecyclestage` | enumeration | subscriber → lead → mql → sql → opportunity → customer → evangelist |
| `hubspot_owner_id` | string | Assigned owner user ID |
| `hs_object_id` | number | Auto-generated record ID |

### 4.2 Companies

**Deduplication key:** `domain`

**Create:**
```json
POST /crm/v3/objects/companies
{
  "properties": {
    "name": "Acme Corporation",
    "domain": "acmecorp.com",
    "industry": "Technology",
    "numberofemployees": 250,
    "annualrevenue": 5000000
  }
}
```

Multiple domains: `"hs_additional_domains": "acme.co;acme.io"` (semicolon-separated).

**Batch read cannot retrieve associations.** Use the Associations API separately after getting IDs.

### 4.3 Deals

**CRITICAL:** Deal `pipeline` and `dealstage` values are internal IDs, not display names. Always call `GET /crm/v3/pipelines/deals` first to retrieve the correct IDs for the target account.

**Create with associations:**
```json
POST /crm/v3/objects/deals
{
  "properties": {
    "dealname": "Enterprise License — Acme",
    "pipeline": "default",
    "dealstage": "appointmentscheduled",
    "amount": "25000.00",
    "closedate": "2026-06-30T00:00:00.000Z",
    "hubspot_owner_id": "910901"
  },
  "associations": [
    {
      "to": { "id": 33451 },
      "types": [{ "associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 3 }]
    }
  ]
}
```

`associationTypeId: 3` = Deal to Contact. `associationTypeId: 341` = Deal to Company.

**Stage transition:**
```json
PATCH /crm/v3/objects/deals/{dealId}
{ "properties": { "dealstage": "closedwon" } }
```

### 4.4 Tickets

Tickets require a pipeline and stage just like deals, but use `hs_pipeline` and `hs_pipeline_stage` as property names (not `pipeline`/`dealstage`).

**Create:**
```json
POST /crm/v3/objects/tickets
{
  "properties": {
    "subject": "Billing issue",
    "content": "Customer was double-charged.",
    "hs_pipeline": "0",
    "hs_pipeline_stage": "1",
    "hs_ticket_priority": "MEDIUM"
  }
}
```

**Ticket stage metadata** uses `ticketState: OPEN` or `CLOSED` (not `probability` like deals).

### 4.5 Batch Operations Summary

**VALIDATED**: All batch endpoints accept `inputs` arrays and return HTTP `207` when partially successful.

```json
POST /crm/v3/objects/contacts/batch/create
{
  "inputs": [
    { "objectWriteTraceId": "trace-001", "properties": { "email": "a@x.com" } },
    { "objectWriteTraceId": "trace-002", "properties": { "email": "b@x.com" } }
  ]
}
```

Use `objectWriteTraceId` to correlate which records failed in a partial-success 207 response.

**Batch read by email:**
```json
POST /crm/v3/objects/contacts/batch/read
{
  "idProperty": "email",
  "inputs": [{ "id": "alice@example.com" }, { "id": "bob@example.com" }],
  "properties": ["firstname", "lastname", "lifecyclestage"]
}
```

Limitation: batch read does not return associations. Fetch associations separately via the Associations API.

---

## Part 5: Advanced Features

### 5.1 Pipelines & Stages

**VALIDATED**: Pipeline and stage IDs are account-specific internal strings. Always discover them before creating records.

```
GET /crm/v3/pipelines/deals      — list all deal pipelines with stages
GET /crm/v3/pipelines/tickets    — list all ticket pipelines with stages
```

**Pipeline response includes stage metadata:**
```json
{
  "stages": [
    {
      "id": "appointmentscheduled",
      "label": "Appointment Scheduled",
      "metadata": { "isClosed": "false", "probability": "0.2" }
    },
    {
      "id": "closedwon",
      "label": "Closed Won",
      "metadata": { "isClosed": "true", "probability": "1.0" }
    }
  ]
}
```

**Create pipeline:**
```json
POST /crm/v3/pipelines/deals
{
  "label": "Enterprise Sales Pipeline",
  "displayOrder": 1,
  "stages": [
    { "label": "Outreach", "metadata": { "probability": "0.1" }, "displayOrder": 0 },
    { "label": "Discovery", "metadata": { "probability": "0.3" }, "displayOrder": 1 },
    { "label": "Closed Won", "metadata": { "probability": "1.0" }, "displayOrder": 2 }
  ]
}
```

Use `DELETE /crm/v3/pipelines/deals/{id}?validateReferencesBeforeDelete=true` to safely delete pipelines that may have active records.

**Pipeline audit log:**
```
GET /crm/v3/pipelines/{objectType}/{pipelineId}/audit
```
Returns a history of every create/update/delete on the pipeline and its stages.

### 5.2 Custom Properties

Properties define the data fields on a CRM object. Custom properties extend the built-in schema.

**Property type/fieldType matrix:**

| `type` | Valid `fieldType` values |
|---|---|
| `string` | `text`, `textarea`, `html`, `file`, `phonenumber` |
| `number` | `number` |
| `bool` | `booleancheckbox` |
| `enumeration` | `select`, `radio`, `checkbox`, `booleancheckbox` |
| `date` | `date` |
| `datetime` | `date` |

**Create a custom text property:**
```json
POST /crm/v3/properties/contacts
{
  "groupName": "contactinformation",
  "name": "agent_processing_status",
  "label": "Agent Processing Status",
  "type": "string",
  "fieldType": "text"
}
```

**Create a unique identifier property** (for deduplication and upsert by external ID):
```json
{
  "name": "external_system_id",
  "label": "External System ID",
  "type": "string",
  "fieldType": "text",
  "hasUniqueValue": true
}
```
Maximum 10 unique identifier properties per object type.

**Create an enumeration property:**
```json
{
  "name": "lead_source_category",
  "label": "Lead Source Category",
  "type": "enumeration",
  "fieldType": "select",
  "options": [
    { "label": "Organic", "value": "organic", "displayOrder": 1, "hidden": false },
    { "label": "Paid", "value": "paid", "displayOrder": 2, "hidden": false }
  ]
}
```

### 5.3 Associations v4

The Associations v4 API replaced the deprecated v3 API. Key change: every association operation must declare both `associationCategory` and `associationTypeId`.

**Two categories:**
- `HUBSPOT_DEFINED` — built-in types, same IDs across all portals
- `USER_DEFINED` — custom labels, IDs are portal-specific

**Key association type IDs (HUBSPOT_DEFINED — consistent across all accounts):**

| From | To | Type ID |
|---|---|---|
| Contact | Company (primary) | `1` |
| Company | Contact (primary) | `2` |
| Contact | Company (unlabeled) | `279` |
| Company | Contact (unlabeled) | `280` |
| Contact | Deal | `4` |
| Deal | Contact | `3` |
| Contact | Ticket | `15` |
| Ticket | Contact | `16` |
| Company | Deal | `342` |
| Deal | Company | `341` |
| Company | Ticket | `25` |
| Ticket | Company | `26` |
| Deal | Ticket | `27` |
| Ticket | Deal | `28` |
| Deal | Line Item | `19` |

**Always verify type IDs programmatically:**
```
GET /crm/v4/associations/{fromObjectType}/{toObjectType}/labels
```

**Create unlabeled association (simplest):**
```
PUT /crm/v4/objects/contact/12345/associations/default/company/67891
```
No request body. Returns 204 No Content.

**Batch create associations:**
```json
POST /crm/v4/associations/{fromObjectType}/{toObjectType}/batch/create
{
  "inputs": [
    {
      "from": { "id": "1001" },
      "to": { "id": "2001" },
      "types": [{ "associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 1 }]
    }
  ]
}
```
Batch limit: 2,000 inputs per request.

**Custom association label** (creates two type IDs — one per direction):
```json
POST /crm/v4/associations/deals/contacts/labels
{ "label": "Decision Maker", "name": "decision_maker" }
```

### 5.4 Engagements (Notes, Tasks, Calls, Meetings, Emails)

Engagements are activities logged against CRM records. Create them via the standard objects endpoints, then associate to records.

**Create a Note:**
```json
POST /crm/v3/objects/notes
{
  "properties": {
    "hs_timestamp": "1710763200000",
    "hs_note_body": "Discussed Q2 renewal. Customer interested.",
    "hubspot_owner_id": "910901"
  },
  "associations": [
    {
      "to": { "id": "33451" },
      "types": [{ "associationCategory": "HUBSPOT_DEFINED", "associationTypeId": 202 }]
    }
  ]
}
```

**Create a Task:**
```json
POST /crm/v3/objects/tasks
{
  "properties": {
    "hs_task_subject": "Follow up on proposal",
    "hs_task_body": "Send pricing breakdown",
    "hs_timestamp": "1710763200000",
    "hs_task_status": "NOT_STARTED",
    "hs_task_priority": "HIGH",
    "hubspot_owner_id": "910901"
  }
}
```

**Create a Call:**
```json
POST /crm/v3/objects/calls
{
  "properties": {
    "hs_call_title": "Discovery Call",
    "hs_call_direction": "OUTBOUND",
    "hs_call_duration": "1800000",
    "hs_call_disposition": "Connected",
    "hs_call_body": "Discussed needs...",
    "hs_timestamp": "1710763200000",
    "hubspot_owner_id": "910901"
  }
}
```

Call disposition values: `Connected`, `Left voicemail`, `No answer`, `Wrong number`, `Left live message`.

### 5.5 Search API

Full reference in Part 5.6 below and dedicated coverage in Part 8.

### 5.6 Custom Objects

Custom objects allow defining entirely new record types. Requires **Enterprise tier**.

**Required scopes:** `crm.schemas.custom.read`, `crm.schemas.custom.write`, `crm.objects.custom.read`, `crm.objects.custom.write`

**Create schema:**
```json
POST https://api.hubapi.com/crm-object-schemas/v3/schemas
{
  "name": "cars",
  "labels": { "singular": "Car", "plural": "Cars" },
  "primaryDisplayProperty": "car_name",
  "searchableProperties": ["car_name", "vin"],
  "requiredProperties": ["car_name"],
  "properties": [
    { "name": "car_name", "label": "Car Name", "type": "string", "fieldType": "text" },
    { "name": "vin", "label": "VIN", "type": "string", "fieldType": "text", "hasUniqueValue": true },
    { "name": "year", "label": "Year", "type": "number", "fieldType": "number" }
  ],
  "associatedObjects": ["CONTACT", "DEAL"]
}
```

The schema response returns `objectTypeId` (e.g., `2-3456789`) — use this as the `{objectType}` in all subsequent calls.

**Naming rules:** Name cannot be changed after creation. Must start with a letter. Only letters, numbers, underscores allowed. Max 20 searchable properties. Max 10 unique value properties.

**Once created, CRUD uses the standard objects pattern:**
```
POST /crm/v3/objects/cars               — create record
GET  /crm/v3/objects/cars/{id}          — read record
PATCH /crm/v3/objects/cars/{id}         — update record
POST /crm/v3/objects/cars/search        — search records
```

### 5.7 SDKs

**Python SDK — `hubspot-api-client` (v12+):**
```bash
pip install hubspot-api-client
```
```python
from hubspot import HubSpot
from hubspot.crm.contacts import SimplePublicObjectInputForCreate

api_client = HubSpot(access_token=os.environ["HUBSPOT_ACCESS_TOKEN"])

# Create contact
contact = api_client.crm.contacts.basic_api.create(
    simple_public_object_input_for_create=SimplePublicObjectInputForCreate(
        properties={"email": "alice@example.com", "firstname": "Alice"}
    )
)
```

**Node.js SDK — `@hubspot/api-client` (v13.4+):**
```bash
npm install @hubspot/api-client
```
```javascript
const { Client } = require('@hubspot/api-client');
const hubspotClient = new Client({
    accessToken: process.env.HUBSPOT_ACCESS_TOKEN,
    limiterOptions: { minTime: 1000/9, maxConcurrent: 6 },
    numberOfApiCallRetries: 3
});
```

The Node.js SDK includes built-in Bottleneck-based rate limiting. The search limiter defaults to ~1.8 req/sec and max 3 concurrent to comply with the strict search rate limit.

### 5.8 Import API (Bulk Data Loading)

For initial migrations or large batch loads, the Import API is preferred over the batch CRUD endpoints.

```
POST /crm/v3/imports                   — start import (multipart/form-data)
GET  /crm/v3/imports/{importId}        — check status
POST /crm/v3/imports/{importId}/cancel — cancel
```

Limits: max 1,048,576 rows or 512 MB per file. Formats: CSV or XLSX.

Import operations: `CREATE`, `UPDATE`, `UPSERT`. Matching by: `EMAIL`, `HUBSPOT_OBJECT_ID`, `UNIQUE_PROPERTY`.

Import runs asynchronously. Poll for states: `STARTED` → `PROCESSING` → `DONE` | `FAILED` | `CANCELED`.

---

## Part 6: Webhooks & Event-Driven Architecture

### Overview

**VALIDATED**: HubSpot webhooks send POST requests with a JSON array of events to a single HTTPS endpoint. Webhook delivery does not count against API rate limits. Up to 100 events may be batched per request. Maximum 1,000 subscriptions per application. Maximum 10 simultaneous in-flight requests per installed account.

### Webhook Setup

**For Private Apps:** Settings > Integrations > Private Apps > app name > Webhooks tab. Settings can only be configured through the UI (not API) for private apps.

**For Public Apps (via API):**
```
PUT /webhooks/v3/{appId}/settings
{ "targetUrl": "https://your-endpoint.com/webhooks", "maxConcurrentRequests": 10 }

POST /webhooks/v3/{appId}/subscriptions
{ "eventType": "contact.creation", "active": true }

POST /webhooks/v3/{appId}/subscriptions
{ "eventType": "contact.propertyChange", "propertyName": "lifecyclestage", "active": true }
```

New subscriptions are created in a **paused state** — must be explicitly activated.

Changes to webhook settings take up to **5 minutes to propagate**.

### Event Types

**Legacy format** (still supported): `contact.creation`, `deal.propertyChange`, etc.

**Generic format** (preferred for new integrations): `object.creation`, `object.propertyChange` — uses `objectTypeId` in payload to identify the object type.

| Event Type | Trigger |
|---|---|
| `object.creation` | Record created |
| `object.deletion` | Record moved to recycle bin |
| `object.propertyChange` | Specific property value changed |
| `object.associationChange` | Association created or removed |
| `object.restore` | Record restored from recycle bin |
| `object.merge` | Two records merged |
| `contact.privacyDeletion` | GDPR deletion (contacts only) |

**Properties that cannot be subscribed to:** `num_unique_conversion_events`, `hs_lastmodifieddate`. These are excluded because they change too frequently.

### Webhook Payload Structure

Payloads are **intentionally minimal** — they contain event metadata only, not the full CRM record.

```json
[
  {
    "objectId": 1246965,
    "propertyName": "lifecyclestage",
    "propertyValue": "customer",
    "changeSource": "API",
    "eventId": 3816279340,
    "subscriptionId": 25,
    "portalId": 33,
    "appId": 1160452,
    "occurredAt": 1462216307945,
    "subscriptionType": "contact.propertyChange",
    "eventType": "contact.propertyChange",
    "attemptNumber": 0,
    "objectTypeId": "0-1"
  }
]
```

**Key fields:**
- `objectId` — CRM record ID
- `propertyName` / `propertyValue` — for propertyChange events
- `changeSource` — `CRM`, `API`, `IMPORT`, `WORKFLOW`, `INTEGRATION`, etc.
- `occurredAt` — Unix milliseconds; use for event ordering
- `attemptNumber` — 0 = first delivery; > 0 = retry
- `objectTypeId` — present in generic format events

**Follow-up fetch required:** The payload does not include the full record. If your agent needs additional properties:
```
GET /crm/v3/objects/contacts/{objectId}?properties=email,firstname,lifecyclestage
```

### Webhook Security: HMAC Validation

Three signature versions exist. Use the version indicated by `X-HubSpot-Signature-Version` header.

**v1 (CRM object events):**
```python
import hashlib

def validate_v1(client_secret: str, body: str, signature: str) -> bool:
    computed = hashlib.sha256((client_secret + body).encode()).hexdigest()
    return computed == signature
```

**v3 (Recommended — OAuth apps, includes replay protection):**
```python
import hashlib, hmac, base64, time

def validate_v3(client_secret, method, uri, body, signature_v3, timestamp_ms, max_age=300):
    if abs(int(time.time() * 1000) - int(timestamp_ms)) > max_age * 1000:
        return False  # reject if > 5 minutes old
    source = method + uri + body + timestamp_ms
    raw_hmac = hmac.new(client_secret.encode(), source.encode(), hashlib.sha256).digest()
    computed = base64.b64encode(raw_hmac).decode()
    return hmac.compare_digest(computed, signature_v3)
```

**Security rules:**
- Always validate against the **raw, unmodified** request body bytes before any parsing
- Use `hmac.compare_digest` (constant-time) to prevent timing attacks
- Reject requests if timestamp is > 5 minutes old (v3 only)
- Return 200 for invalid signatures — returning 4xx triggers HubSpot retries

### Retry Logic and Delivery Guarantees

**VALIDATED**: HubSpot provides **at-least-once** delivery, not exactly-once. Same event may arrive multiple times.

**Retry schedule:**
| Attempt | Approximate Delay |
|---|---|
| 0 (initial) | Immediate |
| 1 | ~1–2 minutes |
| 2 | ~5–10 minutes |
| 3 | ~15–30 minutes |
| 4–9 | Progressively longer, across 24h window |

After 10 retries, events are silently dropped. No dead-letter queue in v3.

**Response timeout:** 5 seconds. Exceeding this triggers a retry. For agents that need more than 5 seconds to process:

```python
@app.post("/webhook")
async def receive_webhook(request: Request):
    payload = await request.json()
    await task_queue.enqueue(payload)  # immediate enqueue
    return {"status": "accepted"}     # return 200 within milliseconds

async def process_async(event):
    # Heavy processing here, not in the HTTP handler
    contact_id = event["objectId"]
    await enrich_and_update(contact_id)
```

### Idempotency Key for Webhooks

```python
def process_webhook_idempotently(event):
    key = f"hubspot:event:{event['portalId']}-{event['eventId']}-{event['attemptNumber']}"
    is_new = redis_client.set(key, "1", ex=90000, nx=True)  # 25-hour TTL
    if not is_new:
        return {"status": "duplicate_skipped"}
    return handle_event(event)
```

Note: `eventId` alone is not sufficient — use the three-field composite key including `portalId` and `attemptNumber`.

### Feedback Loop Prevention

```python
EXCLUDED_SOURCES = {"MY_INTEGRATION_NAME", "WORKFLOW"}

def should_process(event: dict) -> bool:
    return event.get("changeSource") not in EXCLUDED_SOURCES
```

### Webhooks v4 (Beta)

A redesigned webhook system is in public beta as of 2024–2025. Key improvements: lightweight notifications (fetch full payload from Journal API on demand), historical event retrieval, CRM snapshots, per-portal/per-object/per-property granularity, custom object support.

Base path: `https://api.hubapi.com/webhooks/v4/`. Verify beta stability before committing to production.

---

## Part 7: Rate Limits & Performance Optimization

### Rate Limit Tiers

**VALIDATED** (consistent across agents 1, 3, 5):

#### Private Apps and Restricted OAuth Apps

| Plan | Burst (per 10 sec, per app) | Daily (per account, all apps) |
|---|---|---|
| Free | 100 requests | 250,000 |
| Starter | 100 requests | 250,000 |
| Professional | 190 requests | 625,000 |
| Enterprise | 190 requests | 1,000,000 |

#### API Limit Increase Capacity Pack (add-on)

| Pack | Additional Daily | Burst |
|---|---|---|
| 1x Pack | +1,000,000/day | 250 req/10 sec |
| 2x Pack | +2,000,000/day | 250 req/10 sec (does not stack) |

Burst limit does not stack above 250 with multiple packs.

#### Public OAuth Apps

Fixed at **110 requests per 10 seconds per connected account**, regardless of plan tier. Capacity pack does not apply to public apps.

#### CRM Search API (separate, stricter)

**5 requests per second** per account. Separate from the general burst limit. Enforce dedicated throttling for search calls.

**CONTEXT-SPECIFIC**: Agent 5 reports 150 req/10 sec for Professional/Enterprise general limit, while Agents 1 and 3 report 190 req/10 sec. Agent 3's figure (190) is more detailed and explicitly sourced from HubSpot's current documentation — use 190 for Professional/Enterprise.

### Rate Limit Response Headers

```
X-HubSpot-RateLimit-Daily           — total daily limit
X-HubSpot-RateLimit-Daily-Remaining — remaining calls today
X-HubSpot-RateLimit-Secondly        — burst limit
X-HubSpot-RateLimit-Secondly-Remaining — remaining this second
Retry-After                         — seconds to wait (on 429)
```

Note: Rate limit headers are **not included** for OAuth-authorized requests (only available for private app requests).

### 429 Error Response

```json
{
  "status": "error",
  "message": "You have reached your secondly limit.",
  "errorType": "RATE_LIMIT",
  "policyName": "SECONDLY",
  "correlationId": "uuid-here"
}
```

### Retry with Exponential Backoff

```python
def hubspot_request_with_retry(method, url, headers, json=None, max_retries=5):
    for attempt in range(max_retries):
        response = requests.request(method, url, headers=headers, json=json)
        if response.status_code == 429:
            retry_after = int(response.headers.get("Retry-After", 10))
            time.sleep(retry_after + (random.random() * 2))  # add jitter
            continue
        elif response.status_code in (502, 503, 504):
            time.sleep(2 ** attempt)
            continue
        return response
    raise Exception(f"Max retries exceeded for {url}")
```

### Batch Optimization

Every batch call of 100 records counts as 1 API call instead of 100. This is the single most impactful optimization for high-volume agents.

| Operation | Without Batch | With Batch (100 records) |
|---|---|---|
| Create 500 contacts | 500 API calls | 5 API calls |
| Update 1,000 deal stages | 1,000 API calls | 10 API calls |
| Read 300 contacts by email | 300 API calls | 3 API calls |

### Check Daily Usage

```
GET /account-info/v3/api-usage/daily/private-apps
```

### Caching Strategies

- Cache pipeline/stage IDs at startup (they rarely change) — saves repeated `GET /crm/v3/pipelines/deals` calls
- Cache property definitions at startup — saves repeated property schema lookups
- Cache contact/company lookups in a short-lived in-memory store (60–300 seconds) for deduplication checks
- Do not cache mutable record data (contact properties, deal stages) beyond a few seconds

---

## Part 8: AI Agent Integration Patterns

### Pattern 1: Search-Then-Act (Most Common)

```
Agent loop:
1. POST /crm/v3/objects/contacts/search — find unprocessed records
2. Process each record (enrichment, analysis, scoring)
3. PATCH /crm/v3/objects/contacts/{id} — write results back
4. Update agent_processing_status property to "complete"
5. Repeat
```

Filter for unprocessed records:
```json
{
  "filterGroups": [{
    "filters": [{
      "propertyName": "agent_processing_status",
      "operator": "NOT_HAS_PROPERTY"
    }]
  }],
  "sorts": [{ "propertyName": "createdate", "direction": "ASCENDING" }],
  "limit": 100
}
```

### Pattern 2: Webhook-Driven (Real-Time Reaction)

```
HubSpot event → POST /your-endpoint → enqueue → 200 OK
Worker: dequeue → fetch full record → process → PATCH HubSpot
```

Required: respond within 5 seconds. All heavy processing must be asynchronous.

### Pattern 3: Incremental Polling (Background Sync)

```python
def incremental_sync():
    last_sync_ms = state_store.get("last_hubspot_sync", default=0)
    contacts = search_contacts_modified_since(last_sync_ms)
    for contact in contacts:
        process_contact(contact)
    # Only advance cursor after full batch is processed
    state_store.set("last_hubspot_sync", int(datetime.utcnow().timestamp() * 1000))
```

Filter: `lastmodifieddate GT {last_sync_ms}`, sort by `lastmodifieddate ASCENDING`.

### Pattern 4: LangChain / LLM Agent with HubSpot Tools

```python
from langchain.tools import tool

@tool
def search_contact_by_email(email: str) -> dict:
    """Search for a HubSpot contact by email address."""
    payload = {
        "filterGroups": [{"filters": [{"propertyName": "email", "operator": "EQ", "value": email}]}],
        "properties": ["firstname", "lastname", "company", "lifecyclestage"]
    }
    results = hubspot_post("/crm/v3/objects/contacts/search", payload).get("results", [])
    return results[0] if results else {"error": "Contact not found"}

@tool
def update_contact_property(contact_id: str, property_name: str, value: str) -> dict:
    """Update a property on a HubSpot contact."""
    return hubspot_patch(
        f"/crm/v3/objects/contacts/{contact_id}",
        {"properties": {property_name: value}}
    )
```

Use `temperature=0` for deterministic tool selection in production agents.

### Idempotency and Deduplication

**Contact deduplication (email as primary key):**
```python
def upsert_contact(email, firstname, lastname):
    return hubspot_post("/crm/v3/objects/contacts/batch/upsert", {
        "inputs": [{
            "idProperty": "email",
            "id": email,
            "properties": {"email": email, "firstname": firstname, "lastname": lastname}
        }]
    })
```

**Company deduplication (domain as primary key):**
```python
def search_company_by_domain(domain):
    results = hubspot_post("/crm/v3/objects/companies/search", {
        "filterGroups": [{"filters": [{"propertyName": "domain", "operator": "EQ", "value": domain}]}]
    }).get("results", [])
    return results[0] if results else None
```

**External system ID as stable dedup key:**
```python
# Create once:
create_unique_property("contacts", "external_system_id", "External System ID")

# Use in every upsert:
def upsert_by_external_id(external_id, properties):
    return hubspot_post("/crm/v3/objects/contacts/batch/upsert", {
        "inputs": [{
            "idProperty": "external_system_id",
            "id": external_id,
            "properties": {**properties, "external_system_id": external_id}
        }]
    })
```

### CRM as Agent State Store

Store agent state directly on CRM records using custom properties:

```python
# Recommended state properties to create on contacts:
state_properties = [
    { "name": "agent_processing_status", "label": "Agent Processing Status",
      "type": "enumeration", "fieldType": "select",
      "options": [
        {"label": "Pending", "value": "pending"},
        {"label": "In Progress", "value": "in_progress"},
        {"label": "Complete", "value": "complete"},
        {"label": "Failed", "value": "failed"}
      ]},
    { "name": "agent_last_processed_at", "label": "Agent Last Processed At",
      "type": "datetime", "fieldType": "date" },
    { "name": "agent_result_score", "label": "Agent Result Score",
      "type": "number", "fieldType": "number" },
    { "name": "agent_notes", "label": "Agent Notes",
      "type": "string", "fieldType": "textarea" }
]
```

Benefits: no external state store needed, filter for unprocessed records via Search API, full audit trail in CRM, state survives agent restarts.

### Search API: Full Reference

**Endpoint:**
```
POST /crm/v3/objects/{objectType}/search
```

**Request body:**
```json
{
  "filterGroups": [...],
  "sorts": [{ "propertyName": "createdate", "direction": "DESCENDING" }],
  "properties": ["email", "firstname", "lifecyclestage"],
  "limit": 200,
  "after": "cursor_from_previous_response",
  "query": "optional free text"
}
```

**Filter operators:**

| Operator | Description | Notes |
|---|---|---|
| `EQ` | Equals | |
| `NEQ` | Not equals | |
| `LT`, `LTE`, `GT`, `GTE` | Numeric/date comparison | |
| `BETWEEN` | Inclusive range | Uses `value` (low) + `highValue` (high) |
| `IN` | Value in list | Use `values` array (not `value`); strings must be lowercase |
| `NOT_IN` | Not in list | |
| `HAS_PROPERTY` | Field has any value | No `value` needed |
| `NOT_HAS_PROPERTY` | Field is empty/null | No `value` needed |
| `CONTAINS_TOKEN` | Text contains token | Supports `*` wildcard |
| `NOT_CONTAINS_TOKEN` | Does not contain token | |

**AND/OR logic:**
- AND: multiple filters in the same `filterGroups[n].filters` array
- OR: multiple objects in the `filterGroups` array

**Filter limits:** Max 5 filterGroups, max 6 filters per group, max 18 total filters. Request body size limit: 3,000 characters.

**The 10,000 Record Limit:** Search returns at most 10,000 records. Workaround — sort by `hs_object_id ASCENDING` and use the last returned ID as a `GT` filter for the next batch:

```python
def fetch_all_records(object_type, filter_groups):
    all_records = []
    last_id = None
    while True:
        filters = list(filter_groups)
        if last_id:
            filters.append({"propertyName": "hs_object_id", "operator": "GT", "value": str(last_id)})
        payload = {
            "filterGroups": [{"filters": filters}],
            "sorts": [{"propertyName": "hs_object_id", "direction": "ASCENDING"}],
            "limit": 200
        }
        results = paginate_search(object_type, payload)
        if not results:
            break
        all_records.extend(results)
        last_id = results[-1]["id"]
    return all_records
```

**Date filtering uses Unix milliseconds:**
```python
cutoff_ms = str(int(datetime.utcnow().timestamp() * 1000))
# Filter: { "propertyName": "lastmodifieddate", "operator": "GT", "value": cutoff_ms }
```

**Pagination:**
```python
def paginate_search(object_type, payload):
    all_results = []
    while True:
        response = hubspot_post(f"/crm/v3/objects/{object_type}/search", payload)
        all_results.extend(response.get("results", []))
        next_cursor = response.get("paging", {}).get("next", {}).get("after")
        if not next_cursor:
            break
        payload["after"] = next_cursor
    return all_results
```

---

## Part 9: Strategic Recommendations

1. **Use Private Apps for internal agents.** No OAuth handshake, stable token, higher rate limits, capacity pack eligible. Store the token in an environment variable. Plan for rotation every 6 months using HubSpot's 7-day scheduled rotation option.

2. **Request minimum scopes.** Only request the scopes your agent actually uses. Minimizing scope reduces blast radius if the token is exposed.

3. **Always use batch endpoints.** A batch create/update/read of 100 records counts as 1 API call. For any loop that touches > 1 record, batch it. This alone can reduce API consumption by 99%.

4. **Cache static data at startup.** Pipeline IDs, stage IDs, and property definitions rarely change. Fetch them once at agent startup and reuse in-memory. This eliminates hundreds of repeated schema calls.

5. **Always fetch pipeline IDs before creating records.** Never hardcode pipeline or stage IDs — they are account-specific strings. Retrieve them from the target account before first use and re-verify them if stage transitions return 422 errors.

6. **Store agent state on CRM records.** Create custom properties like `agent_processing_status`, `agent_last_processed_at`, `external_system_id`. This eliminates the need for an external state store, makes the state observable in the CRM UI, and enables filtering for unprocessed records via the Search API.

7. **Use webhooks for real-time triggers; use incremental polling for background sync.** Webhooks reduce API call volume to zero for event detection. Incremental polling with `lastmodifieddate GT {cursor}` is the correct fallback when webhooks are unavailable or for backfill operations.

8. **Implement proper webhook handling: enqueue immediately, process asynchronously.** The 5-second response window is strict. Any agent that enriches contacts, calls external APIs, or writes to databases cannot do that inline. Accept, enqueue, return 200 — then process the queue at whatever pace your system requires.

9. **Use upsert patterns to achieve idempotency.** The batch upsert endpoint for contacts (using `email` as `idProperty`) is inherently idempotent — calling it twice with the same email creates one record, not two. For Deals and Tickets (no natural unique key), create a custom unique property (`external_deal_id`) and use it as the upsert key.

10. **Design for at-least-once delivery.** HubSpot webhooks may deliver the same event more than once. Build your event handler to be idempotent using `eventId` + `portalId` + `attemptNumber` as the composite deduplication key in a Redis SETNX with 25-hour TTL.

---

## Part 10: Known Gotchas & Pitfalls

**Authentication:**
- Private App tokens look like `pat-na1-...` but HubSpot says sizes will fluctuate — store up to 512 characters
- OAuth access tokens expire in 30 minutes; if you forget to implement refresh, your agent silently fails at 30 minutes
- Scopes cannot be retroactively added to an existing OAuth token — you must re-authorize the user
- The deprecated `hapikey` query parameter may stop working without notice — do not use it for new builds
- Returning 4xx from your webhook endpoint triggers retries from HubSpot (not stops them) — return 200 and filter invalid events in application logic

**Core Objects:**
- Deal `pipeline` and `dealstage` use internal IDs, not display names — a stage labeled "Discovery" in the HubSpot UI has an opaque internal ID like `"2468136"`. Always retrieve IDs from the Pipelines API first
- Contact lifecycle stages can only advance forward in the default order; to move backward, clear the property first (`"lifecyclestage": ""`), then set the target stage
- Company deduplication is by `domain`, not `name` — two companies with the same name but different domains are distinct records
- `company` property on a Contact is a plain text field, not a linked Company record — use Associations to link them

**Search API:**
- Hard limit of 10,000 records per search query — use the `hs_object_id GT {last_id}` re-indexing workaround for larger datasets
- `IN` and `NOT_IN` operator values must be **lowercase** for enumeration properties — `"Lead"` will not match `"lead"`
- `CONTAINS_TOKEN` does tokenized search, not arbitrary substring matching — it works on word boundaries and email domains
- Max 5 filterGroups, 6 filters per group, 18 total filters per request. Request body size limit: 3,000 characters
- Search API rate limit is 5 requests/second — separate from and stricter than the general burst limit
- `total` in search response is capped at 10,000 even if more records match
- Sort supports only one property — multi-property sort is not available

**Associations:**
- Always use v4 Associations API for new builds (v3 is deprecated)
- Custom label type IDs (`USER_DEFINED`) are portal-specific — hardcoding them will break if the integration runs on a different HubSpot account
- Creating a custom label produces TWO type IDs (one per direction) — both are returned in the API response
- Association cardinality rules (one-to-many, one-to-one) cannot be set programmatically via schema API — must be configured in the HubSpot UI
- Batch read on standard objects cannot retrieve associations — fetch them separately from the Associations API

**Custom Objects:**
- Require at least one Enterprise-tier hub
- Object `name` and `labels` cannot be changed after creation — choose carefully
- System properties (`hs_object_id`, `createdate`, `lastmodifieddate`) are added automatically — do not define them in your schema
- Custom object schema endpoint base is different from standard objects: `/crm-object-schemas/v3/schemas` vs `/crm/v3/objects`

**Webhooks:**
- Payloads contain event metadata only — not the full CRM record. Follow-up GET calls count against rate limits
- `num_unique_conversion_events` and `hs_lastmodifieddate` cannot be used as propertyChange subscription targets
- Returning any 4xx or 5xx from your webhook endpoint triggers HubSpot retries — there is no "reject this event" mechanism. Return 200 and filter in application logic
- Events within a batch and across batches may arrive out of chronological order — use `occurredAt` for ordering
- After 10 retries over 24 hours, events are silently dropped. No dead-letter queue in v3
- Webhook configuration changes (URL, concurrency) take up to 5 minutes to propagate
- Private app webhook settings can only be configured through the HubSpot UI, not the API

**Rate Limits:**
- Rate limit headers are not included for OAuth-authorized requests — you must track usage yourself
- Hitting the daily limit results in 429 for all subsequent calls until midnight (account timezone reset), not just for the next few seconds
- The search rate limit (5 req/sec) is independent of the general burst limit — an agent can exhaust one without touching the other
- Error rate > 5% of daily requests blocks HubSpot Marketplace certification

**Pipelines:**
- `closedwon` and `closedlost` are **not always** the stage IDs even though they appear that way on new accounts — custom pipelines have random numeric IDs. Do not assume
- Deleting a pipeline with active records will fail or silently orphan records unless you use `validateReferencesBeforeDelete=true`
- The default pipeline ID is often `"default"` on new accounts, but migrated or older accounts may have different IDs

**Classic CRM Cards:** Officially deprecated October 31, 2026 (sunset started June 16, 2025). Migrate to UI Extensions.

---

## References

| Topic | URL |
|---|---|
| CRM API overview | https://developers.hubspot.com/docs/api/crm/crm-api-overview |
| Authentication (Private Apps) | https://developers.hubspot.com/docs/api/private-apps |
| OAuth 2.0 | https://developers.hubspot.com/docs/api/oauth-quickstart-guide |
| Scopes reference | https://developers.hubspot.com/docs/api/oauth/scopes |
| Contacts API | https://developers.hubspot.com/docs/api/crm/contacts |
| Companies API | https://developers.hubspot.com/docs/api/crm/companies |
| Deals API | https://developers.hubspot.com/docs/api/crm/deals |
| Tickets API | https://developers.hubspot.com/docs/api/crm/tickets |
| Batch operations | https://developers.hubspot.com/docs/api/crm/batch-overview |
| Search API | https://developers.hubspot.com/docs/api/crm/search |
| Properties API | https://developers.hubspot.com/docs/api/crm/properties |
| Pipelines API | https://developers.hubspot.com/docs/api/crm/pipelines |
| Associations v4 | https://developers.hubspot.com/docs/api/crm/associations |
| Engagements (Notes) | https://developers.hubspot.com/docs/api/crm/notes |
| Engagements (Tasks) | https://developers.hubspot.com/docs/api/crm/tasks |
| Engagements (Calls) | https://developers.hubspot.com/docs/api/crm/calls |
| Custom Objects | https://developers.hubspot.com/docs/api/crm/crm-custom-objects |
| Webhooks API | https://developers.hubspot.com/docs/api/webhooks |
| Webhooks v4 (beta) | https://developers.hubspot.com/changelog |
| Rate limits | https://developers.hubspot.com/docs/api/usage-details |
| Import API | https://developers.hubspot.com/docs/api/crm/imports |
| Lists API | https://developers.hubspot.com/docs/api/crm/lists |
| Python SDK | https://pypi.org/project/hubspot-api-client/ |
| Node.js SDK | https://www.npmjs.com/package/@hubspot/api-client |
| Developer changelog | https://developers.hubspot.com/changelog |
| Error codes reference | https://developers.hubspot.com/docs/api/error-handling-and-best-practices |
