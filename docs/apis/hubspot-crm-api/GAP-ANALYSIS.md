# HubSpot CRM API — Gap Analysis
**Synthesized from:** 6 research agents (round-1)
**Date:** 2026-03-18
**Scope:** Full CRM API surface — authentication, objects, pipelines, properties, webhooks, rate limits, associations, engagements, search, AI patterns, custom objects, SDKs

---

## Overall Coverage Summary

| Subtopic | Agent(s) | Coverage Score | Notes |
|---|---|---|---|
| Authentication (Private Apps) | Agent 1 | 9/10 | Step-by-step, scopes table, token storage |
| Authentication (OAuth 2.0) | Agent 1 | 8/10 | Full flow, missing PKCE detail |
| Core CRM Objects (Contact/Company/Deal/Ticket) | Agent 1 | 9/10 | All CRUD, batch, search |
| Pipelines & Stages | Agent 2 | 9/10 | Deal + ticket pipelines, audit logs, probability |
| Custom Properties | Agent 2 | 9/10 | All types, fieldType matrix, groups, calculation props |
| CRM Object Schemas | Agent 2 | 8/10 | Standard + custom schemas; archiving not fully differentiated |
| Webhooks Setup & Events | Agent 3 | 9/10 | All event types, payload structure, HMAC validation |
| Webhooks v4 Journal API | Agent 3 | 7/10 | Beta docs partial; replay/filtering covered lightly |
| Rate Limits by Plan | Agent 3 | 9/10 | Comprehensive tier table, headers, retry strategy |
| Associations v4 | Agent 4 | 9/10 | Categories, type IDs, labels, bulk operations |
| Engagements (Notes/Tasks/Calls) | Agent 4 | 9/10 | Full CRUD, payload examples |
| Engagements (Meetings/Emails) | Agent 4 | 8/10 | Covered but fewer code examples |
| Timeline Events | Agent 4 | 8/10 | CRM Extensions timeline covered; portal-level gaps |
| Search API | Agent 5 | 10/10 | All operators, AND/OR logic, pagination, 10K workarounds |
| AI Agent Patterns | Agent 5 | 9/10 | Idempotency, dedup, CRM-as-state-store, flowcharts |
| Custom Objects CRUD | Agent 6 | 9/10 | Full schema lifecycle, limitations by plan |
| Python SDK | Agent 6 | 9/10 | v12 complete reference |
| Node.js SDK | Agent 6 | 9/10 | v13.4 complete reference |
| Import API | Agent 6 | 8/10 | Bulk import covered; export API not covered |
| Lists API (Segments) | Agent 6 | 7/10 | ILS v3 covered; legacy Lists API migration not documented |
| CRM UI Extensions | Agent 6 | 7/10 | Classic cards + new UI Extensions introduced; deep dev guide missing |
| Workflow Extensions | Agent 6 | 7/10 | Custom action setup covered; testing/versioning thin |
| Marketing Hub Integration | None | 2/10 | Emails, forms, campaigns — not covered |
| Sales Hub (Sequences, Quotes) | None | 1/10 | Not covered at all |
| Service Hub (Knowledge Base) | None | 1/10 | Not covered at all |
| Reporting/Analytics API | None | 2/10 | Mentioned briefly in pipeline forecasting only |
| Owners API | None | 3/10 | Referenced in object payloads but not documented standalone |
| Files/Media API | None | 1/10 | Not covered |
| Meetings Scheduler API | None | 2/10 | Mentioned in engagements; booking links not documented |
| CRM Cards (Native) | Agent 6 | 5/10 | Classic cards covered; new React-based cards thin |
| Developer Projects / Local Dev | None | 1/10 | HubSpot CLI, local dev environment not covered |
| Plan-Based Feature Availability | Agent 6 | 8/10 | Table of features by tier present |
| Error Codes (Full Catalog) | Agents 1,3,5 | 7/10 | Common errors documented; full error catalog not compiled |

---

## Topics Thoroughly Covered (Score 8-10)

These areas have production-ready depth — all required for building an AI agent integration:

1. **Authentication** — Private Apps (full setup) and OAuth 2.0 (full flow). Scopes table is comprehensive. Token refresh for automated systems documented with Python code.

2. **Core CRM CRUD** — Contacts, Companies, Deals, Tickets all have create/read/update/archive examples, batch endpoints, and property-select patterns.

3. **Pipelines & Stages** — Deal and Ticket pipelines fully documented including stage transition mechanics, probability fields, forecasting categories, and audit logs.

4. **Custom Properties** — All 11 type/fieldType combinations documented. Calculation properties, enumeration options, property groups — all covered with create/read/update patterns.

5. **Webhooks** — Setup, all 37+ event types, payload structure, HMAC validation with Python, retry/batching behavior, filtering by property.

6. **Rate Limits** — Plan-tier table complete. All response headers documented. Retry-after + exponential backoff with jitter fully implemented in code.

7. **Associations v4** — Category taxonomy (HUBSPOT_DEFINED/USER_DEFINED/INTEGRATOR_DEFINED), all standard type IDs, custom labels, batch operations with 100-record limits.

8. **Engagements** — Notes, Tasks, Calls, Meetings, Emails all documented with payload structure and association patterns.

9. **Search API** — Complete operator reference, AND/OR filter group logic, cursor pagination, 10K limit workarounds (date-window chunking, property-range splitting).

10. **AI Agent Patterns** — Idempotency via `hs_unique_creation_key`, deduplication strategies, CRM-as-state-store, webhook-driven vs polling architectures.

11. **Custom Objects** — Full schema lifecycle. Plan-based limits table. Python and Node.js SDK coverage.

---

## Topics with Partial Coverage (Score 5-7)

These are usable but have identifiable gaps:

- **Webhooks v4 Journal API** — Beta endpoint documented but replay window, pagination through journal, and exact filtering params are thin.
- **Lists API (ILS v3)** — Dynamic/static/manual list types covered; migration path from legacy Lists API not documented.
- **CRM UI Extensions** — Classic cards explained but the newer React-based `ui-extensions-sdk` with custom sections, panels, and iframe embedding is not fully documented.
- **Workflow Extensions** — Custom action setup covered; serverless function testing, versioning strategy, and rollback procedures missing.
- **Import API** — Bulk CSV import documented; the Export API (GET `/crm/v3/exports`) not covered at all.
- **Error Codes** — Common errors (400, 401, 403, 429) documented in context. No consolidated error catalog with all specific `errorType` values.
- **Owners API** — Owner IDs appear in almost every payload but `GET /crm/v3/owners` is never formally documented as a standalone endpoint.

---

## Topics Missing or Thin (Score 1-4)

These represent the primary research gaps — recommended for round-2 agents:

- **Marketing Hub API** — Email sending, form submissions, campaigns, marketing contacts distinction — zero coverage. Critical for any marketing automation agent.
- **Sales Hub API** — Sequences, Quote Builder, CPQ (Configure Price Quote), Calling integrations — not covered.
- **Service Hub API** — Knowledge Base, Customer Feedback (surveys), Help Desk — not covered.
- **Reporting & Analytics API** — Custom reports, dashboards, revenue attribution — mentioned only incidentally.
- **Files API** — File upload, CDN URL generation, file associations to records — missing.
- **Meetings Scheduler API** — Booking page API, meeting links, embed options — not covered.
- **HubSpot CLI & Developer Projects** — Local development workflow, `hs` CLI commands, serverless functions, testing framework — not covered.
- **Sensitive Data Properties** — PII/sensitive property flags (compliance mode), data masking behavior — not covered.
- **GDPR Compliance API** — Data deletion requests, consent tracking, legal basis — not covered.
- **Multi-Portal / Account Architecture** — Business Units, parent-child portals, sandbox environments — not covered.

---

## Specific Gaps Identified

1. **PKCE flow for OAuth** — Agent 1 documents standard OAuth; the PKCE extension (required for public clients) is not mentioned.
2. **Refresh token rotation** — Mentioned in Token Storage but the specific token rotation policy (do refresh tokens expire? rolling vs absolute?) not documented.
3. **Webhook deduplication IDs** — `eventId` noted but the dedup window (HubSpot's internal 24h window) not documented.
4. **Association cardinality limits** — Agent 4 notes 50K association limit per object; the cross-object cardinality limits (e.g., max contacts on a company) not all listed.
5. **Property history read** — Properties have history but the endpoint for reading property value history (`GET /crm/v3/objects/{type}/{id}?propertiesWithHistory=...`) is mentioned but not fully documented.
6. **Conditional property logic** — Dependent fields (if fieldA=X, show fieldB) exist in the UI; API support for this not documented.
7. **Deal splits / revenue sharing** — Enterprise-level deal attribution splits not documented.
8. **Forecasting API** — `forecast_probability` and `deal_currency_amount` documented in pipeline stages but the standalone Forecasting API is not covered.

---

## Recommended Round-2 Research

| Priority | Topic | Why Needed |
|---|---|---|
| HIGH | Marketing Hub API (email, forms, campaigns) | Core to marketing automation agents |
| HIGH | GDPR / Compliance API | Required for EU deployments |
| HIGH | Owners API standalone reference | Every record assignment needs this |
| MEDIUM | Sales Hub (Sequences, Quotes) | Sales automation coverage |
| MEDIUM | Export API | Data pipeline completeness |
| MEDIUM | Files API | Media handling in agents |
| MEDIUM | Error codes full catalog | Production error handling |
| LOW | HubSpot CLI / Developer Projects | Tooling for developers |
| LOW | Reporting API | Analytics automation |
| LOW | Service Hub API | Support ticket agents |
