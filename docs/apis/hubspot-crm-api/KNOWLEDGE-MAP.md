# HubSpot CRM API — Knowledge Map
**Date:** 2026-03-18
**Coverage:** Round-1 research (6 agents)

---

## Component Tree

```
HubSpot CRM API
├── AUTHENTICATION                                [Agent 1]
│   ├── Private Apps (access tokens)              ✅ Full
│   ├── OAuth 2.0 (authorization_code flow)       ✅ Full
│   ├── Deprecated API Keys (hapikey)             ✅ Noted
│   ├── Scopes Reference                          ✅ Full table
│   └── Token Storage / Refresh                  ✅ Full
│
├── CORE CRM OBJECTS                              [Agent 1]
│   ├── Contacts                                  ✅ Full CRUD + batch
│   ├── Companies                                 ✅ Full CRUD + batch
│   ├── Deals                                     ✅ Full CRUD + batch
│   ├── Tickets                                   ✅ Full CRUD + batch
│   └── Line Items                                ⚠️  Mentioned only
│
├── PROPERTIES                                    [Agents 1, 2]
│   ├── Standard Properties                       ✅ Full
│   ├── Custom Properties (CREATE)                ✅ All types
│   ├── Property Types × fieldType Matrix         ✅ 11 combinations
│   ├── Enumeration Options                       ✅ Full
│   ├── Calculation Properties                    ✅ Full
│   ├── Property Groups                           ✅ Full
│   ├── Property Value History                    ⚠️  Partial
│   └── Sensitive/PII Property Flags              ❌ Missing
│
├── PIPELINES                                     [Agent 2]
│   ├── Deal Pipelines (list/create/update)       ✅ Full
│   ├── Ticket Pipelines                          ✅ Full
│   ├── Pipeline Stages                           ✅ Full
│   ├── Stage Transitions                         ✅ Full
│   ├── Pipeline Audit Logs                       ✅ Covered
│   ├── Deal Probability / Forecasting Category   ✅ Covered
│   └── Forecasting API (standalone)              ❌ Missing
│
├── ASSOCIATIONS                                  [Agents 1, 4]
│   ├── v4 API (primary)                          ✅ Full
│   │   ├── HUBSPOT_DEFINED types                 ✅ Full type ID table
│   │   ├── USER_DEFINED labels                   ✅ Full
│   │   ├── INTEGRATOR_DEFINED                    ✅ Covered
│   │   ├── Batch create/read/delete              ✅ Full
│   │   └── Cardinality limits                    ⚠️  Partial
│   └── v3 API (legacy)                           ✅ Noted as deprecated
│
├── ENGAGEMENTS                                   [Agent 4]
│   ├── Notes                                     ✅ Full CRUD
│   ├── Tasks                                     ✅ Full CRUD
│   ├── Calls (with recording URL)                ✅ Full CRUD
│   ├── Meetings                                  ✅ Full CRUD
│   ├── Emails (logged)                           ✅ Full CRUD
│   └── Meetings Scheduler / Booking Links        ❌ Missing
│
├── TIMELINE EVENTS                               [Agents 4, 6]
│   ├── Event Type Creation                       ✅ Full
│   ├── Event Ingestion                           ✅ Full
│   ├── CRM Timeline Display                      ✅ Covered
│   └── Portal-level event filtering              ⚠️  Partial
│
├── SEARCH API                                    [Agents 1, 5]
│   ├── Endpoint pattern                          ✅ Full
│   ├── Filter Groups (AND / OR logic)            ✅ Full
│   ├── All Operators (EQ/NEQ/GT/LT/CONTAINS...)  ✅ Complete table
│   ├── Sorting                                   ✅ Full
│   ├── Property selection                        ✅ Full
│   ├── Cursor pagination (after)                 ✅ Full
│   ├── 10,000 record limit workarounds           ✅ Full (3 strategies)
│   └── Custom property search                    ✅ Full
│
├── WEBHOOKS                                      [Agents 3, 6]
│   ├── Subscription setup (App-level)            ✅ Full
│   ├── Event types catalog (37+)                 ✅ Full table
│   ├── Payload structure                         ✅ Full examples
│   ├── HMAC-SHA256 validation                    ✅ Python code
│   ├── Retry logic & delivery guarantees         ✅ Full
│   ├── Batching behavior (up to 100 events)      ✅ Full
│   ├── Property-level filtering                  ✅ Covered
│   ├── v4 Journal API (beta)                     ⚠️  Partial
│   └── Testing (ngrok / Hookdeck)                ✅ Covered
│
├── RATE LIMITS                                   [Agents 1, 3, 5, 6]
│   ├── Plan tier table (Free→Enterprise)         ✅ Complete
│   ├── Search API limit (5 req/s)                ✅ Noted
│   ├── Burst limits                              ✅ Documented
│   ├── Response headers (X-HubSpot-RateLimit-*)  ✅ Full
│   ├── 429 error structure                       ✅ Full
│   └── Exponential backoff with jitter           ✅ Python code
│
├── CUSTOM OBJECTS                                [Agents 2, 6]
│   ├── Schema creation (fullyQualifiedName)      ✅ Full
│   ├── Property definitions                      ✅ Full
│   ├── Primary display property                  ✅ Covered
│   ├── Association definitions                   ✅ Full
│   ├── CRUD on custom object records             ✅ Full
│   ├── Plan limits (Enterprise: 10 objects)      ✅ Table
│   └── Schema deletion (hard delete)             ✅ Covered
│
├── SDKs                                          [Agent 6]
│   ├── Python SDK (hubspot-api-client v12)       ✅ Full reference
│   ├── Node.js SDK (@hubspot/api-client v13.4)   ✅ Full reference
│   ├── PHP SDK                                   ⚠️  Mentioned only
│   └── Ruby / Java SDKs                          ❌ Not covered
│
├── IMPORT / EXPORT API                           [Agent 6]
│   ├── Import API (CSV bulk load)                ✅ Full
│   └── Export API                                ❌ Missing
│
├── LISTS API (ILS v3)                            [Agent 6]
│   ├── Dynamic / Static / Manual lists           ✅ Full
│   ├── List membership management                ✅ Covered
│   └── Legacy Lists API migration                ❌ Missing
│
├── CRM EXTENSIONS                                [Agent 6]
│   ├── Timeline Events (CRM Extensions)          ✅ Full
│   ├── Classic CRM Cards                         ✅ Covered
│   ├── UI Extensions (React-based)               ⚠️  Partial
│   └── Workflow Extensions (Custom Actions)      ⚠️  Partial
│
├── AI AGENT PATTERNS                             [Agents 1, 5]
│   ├── Webhook-driven vs polling architecture    ✅ Full
│   ├── Idempotency (hs_unique_creation_key)      ✅ Full
│   ├── Deduplication strategies                  ✅ Full
│   ├── CRM as state store                        ✅ Full
│   ├── Error handling flowcharts                 ✅ Full
│   ├── Python production examples                ✅ Full
│   └── Node.js production examples               ✅ Full
│
└── GAPS (not covered in round-1)
    ├── Marketing Hub API                          ❌
    ├── Sales Hub (Sequences, Quotes)              ❌
    ├── Service Hub (Knowledge Base, Feedback)     ❌
    ├── Reporting / Analytics API                  ❌
    ├── Files / Media API                          ❌
    ├── GDPR Compliance API                        ❌
    ├── Owners API (standalone)                    ❌
    ├── Meetings Scheduler API                     ❌
    ├── HubSpot CLI / Developer Projects           ❌
    └── Multi-portal / Sandbox environments        ❌
```

---

## Relationship Map

```
                        ┌─────────────────────┐
                        │   AUTHENTICATION     │
                        │ Private App / OAuth  │
                        └──────────┬──────────┘
                                   │ Bearer token on all requests
                   ┌───────────────┼───────────────┐
                   ▼               ▼               ▼
           ┌──────────┐   ┌──────────────┐  ┌──────────────┐
           │  OBJECTS │   │  PROPERTIES  │  │   PIPELINES  │
           │ Contact  │◄──│ Standard     │  │ Deal stages  │
           │ Company  │   │ Custom       │  │ Ticket stages│
           │ Deal     │   │ Calculation  │  └──────┬───────┘
           │ Ticket   │   └──────────────┘         │
           │ Custom   │                      stage_id on Deal/Ticket
           └────┬─────┘
                │
        ┌───────┴────────┐
        ▼                ▼
┌──────────────┐  ┌────────────────┐
│ ASSOCIATIONS │  │  ENGAGEMENTS   │
│ Contact↔Co.  │  │ Notes, Tasks   │
│ Deal↔Contact │  │ Calls, Meetings│
│ Custom links │  │ Emails, Events │
└──────────────┘  └────────────────┘
        │
        ▼
┌──────────────────────────────────────────────┐
│                SEARCH API                    │
│  POST /crm/v3/objects/{type}/search          │
│  Queries any object with filter groups       │
│  Returns associations + properties together  │
└──────────────────────────────────────────────┘
        │
        ▼
┌──────────────────────────────────────────────┐
│                 WEBHOOKS                     │
│  React to CRUD events on any object/property │
│  Deliver batched payloads → your endpoint    │
│  Trigger AI agent workflows                  │
└──────────────────────────────────────────────┘
```

---

## Quick Reference Index — Key Endpoints

| Operation | Method | Endpoint |
|---|---|---|
| Get contacts | GET | `/crm/v3/objects/contacts` |
| Create contact | POST | `/crm/v3/objects/contacts` |
| Batch create contacts | POST | `/crm/v3/objects/contacts/batch/create` |
| Search contacts | POST | `/crm/v3/objects/contacts/search` |
| Get deal pipelines | GET | `/crm/v3/pipelines/deals` |
| Create pipeline | POST | `/crm/v3/pipelines/{objectType}` |
| Get properties for object | GET | `/crm/v3/properties/{objectType}` |
| Create custom property | POST | `/crm/v3/properties/{objectType}` |
| Create association (v4) | PUT | `/crm/v4/objects/{fromType}/{fromId}/associations/{toType}/{toId}` |
| Batch associations (v4) | POST | `/crm/v4/associations/{fromObjectType}/{toObjectType}/batch/create` |
| Get association schema | GET | `/crm/v4/associations/{fromObjectType}/{toObjectType}/labels` |
| Create note | POST | `/crm/v3/objects/notes` |
| Create task | POST | `/crm/v3/objects/tasks` |
| Create call | POST | `/crm/v3/objects/calls` |
| Create meeting | POST | `/crm/v3/objects/meetings` |
| Get webhook subscriptions | GET | `/webhooks/v3/{appId}/subscriptions` |
| Create webhook subscription | POST | `/webhooks/v3/{appId}/subscriptions` |
| Get custom object schemas | GET | `/crm/v3/schemas` |
| Create custom object schema | POST | `/crm/v3/schemas` |
| Get lists | GET | `/crm/v3/lists/` |
| Import records | POST | `/crm/v3/imports/` |
| Get owners | GET | `/crm/v3/owners/` |
| OAuth token exchange | POST | `/oauth/v1/token` |
| OAuth token info | GET | `/oauth/v1/access-tokens/{token}` |

---

## Where to Find What

| What you need | Go to |
|---|---|
| Auth setup code | `agent1-auth-core-objects.md` → Section 2 (Private Apps) or Section 3 (OAuth) |
| Full scopes table | `agent1-auth-core-objects.md` → Section 5 |
| Contact/Company/Deal CRUD examples | `agent1-auth-core-objects.md` → Sections 10-13 |
| Pipeline stage IDs | `agent2-pipelines-properties.md` → Section 2-4 |
| All property types matrix | `agent2-pipelines-properties.md` → Section 8 |
| Calculation property syntax | `agent2-pipelines-properties.md` → Section 11 |
| Webhook event types list | `agent3-webhooks-rate-limits.md` → Section 3 |
| HMAC validation code | `agent3-webhooks-rate-limits.md` → Section 5 |
| Rate limit headers | `agent3-webhooks-rate-limits.md` → Section 14 |
| Retry/backoff implementation | `agent3-webhooks-rate-limits.md` → Section 16 |
| Association type IDs table | `agent4-associations-engagements.md` → Section 2 |
| Engagement payload examples | `agent4-associations-engagements.md` → Sections 10-14 |
| Search operators complete table | `agent5-search-ai-patterns.md` → Section 3 |
| 10K record limit workarounds | `agent5-search-ai-patterns.md` → Section 7 |
| Idempotency key usage | `agent5-search-ai-patterns.md` → Section 12 |
| CRM-as-state-store pattern | `agent5-search-ai-patterns.md` → Section 16 |
| Python production code | `agent5-search-ai-patterns.md` → Section 17 |
| Custom object schema creation | `agent6-custom-objects-advanced.md` → Sections 2-3 |
| Python SDK reference | `agent6-custom-objects-advanced.md` → Section 8 |
| Node.js SDK reference | `agent6-custom-objects-advanced.md` → Section 9 |
| Import API CSV format | `agent6-custom-objects-advanced.md` → Section 10 |
| Plan-based feature availability | `agent6-custom-objects-advanced.md` → Section 18 |
