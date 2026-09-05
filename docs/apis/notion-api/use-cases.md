# Notion API — Use Cases & Practical Guide

**Date:** 2026-03-01

---

## What You Can Do

### Free / No Auth Required
- Nothing — all Notion API calls require an integration token

### Paid / Requires Setup
- Create a Notion integration (free Notion account required) at https://www.notion.so/profile/integrations
- Get an integration token (Bearer token) and add the integration to specific pages/databases
- Read pages, databases, and blocks
- Create new pages inside a database or as children of an existing page
- Update page properties and content
- Query and filter databases with sort/filter options
- Append, retrieve, and delete blocks
- List workspace users and retrieve the bot user
- Search across all accessible pages and databases
- Create and list comments on pages/blocks
- Upload files (File Uploads endpoint)
- Implement OAuth 2.0 for public integrations (token exchange)
- Subscribe to webhooks for real-time change notifications

### What the API Cannot Do
- Access pages the integration has not been explicitly shared with
- Bypass workspace admin permissions (integration caps at user's access level)
- Delete pages (only archive them — use `archived: true`)
- Move pages between workspaces
- Access Notion AI features via API
- Create workspaces or databases at the workspace root (must be child of a shared page)
- Return more than 100 items per paginated request

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key SDK / Endpoint |
|---|---|---|---|
| Log form submissions to Notion DB | Easy | POST new page with properties | `POST /v1/pages` |
| Read all rows from a Notion database | Easy | Query database, handle pagination | `POST /v1/databases/{id}/query` |
| Create daily log/journal entries | Easy | Create page inside a database each morning | `POST /v1/pages` |
| Update task status from external system | Easy | Patch page property (status/select field) | `PATCH /v1/pages/{id}` |
| Sync contact list to Notion database | Medium | Query existing rows, create or update pages | `POST /v1/pages`, `PATCH /v1/pages/{id}` |
| Build Notion CRM from webhook events | Medium | Receive webhook → create/update page in DB | `POST /v1/pages`, `PATCH /v1/pages/{id}` |
| Export entire Notion database to CSV/JSON | Medium | Query all rows with pagination loop | `POST /v1/databases/{id}/query` |
| Mirror GitHub issues into Notion | Medium | GitHub webhook → create Notion page per issue | `POST /v1/pages`, `PATCH /v1/pages/{id}` |
| Build a documentation site reader | Medium | Traverse block children to render content | `GET /v1/blocks/{id}/children` |
| Auto-tag or categorize Notion pages | Medium | Read content, update select/multi-select property | `PATCH /v1/pages/{id}` + `GET /v1/blocks` |
| Search Notion across workspaces | Medium | POST search with query + filter by object type | `POST /v1/search` |
| Post AI summaries as Notion comments | Medium | Call AI API → post result as a comment | `POST /v1/comments` |
| Append structured blocks to a page | Medium | Build block array (headings, bullets, code) | `PATCH /v1/blocks/{id}/children` |
| Notion → Slack daily standup digest | Hard | Query tasks due today → format → send Slack message | `POST /v1/databases/{id}/query` |
| Build Notion OAuth integration | Hard | OAuth 2.0 flow → token exchange → store per-user token | `POST /v1/oauth/token` |
| Two-way sync Notion ↔ external DB | Hard | Poll changes on both sides, reconcile, update | All CRUD endpoints |

---

## Key Limits and Gotchas

### Rate Limits
- **3 requests per second** average per integration (HTTP 429 on breach)
- Bursts allowed but throttled — use exponential backoff
- Respect `Retry-After` header (value in seconds)
- Rate limits may change — Notion has stated plans to introduce pricing-tier-based limits

### Payload / Size Limits
- Max payload size: **500 KB** overall
- Max **1000 block elements** per request
- Rich text content: **2000 characters** per text node
- Rich text link URLs: **2000 characters**
- Equation expressions: **1000 characters**
- Any URL property: **2000 characters**
- Email properties: **200 characters**
- Phone properties: **200 characters**
- Multi-select: max **100 options**
- Relation property: max **100 related pages**
- People property: max **100 users**
- Any array of blocks (including rich text): max **100 elements**

### Auth & Access
- Integration token scope is set at creation — Content (Read/Insert/Update), Comments, User info
- Pages must be **explicitly shared** with the integration — the API cannot access arbitrary pages
- Integration can never exceed the sharing user's permission level
- For public integrations: users must re-authenticate if capabilities change
- Request minimum capabilities needed — fewer capabilities = easier installation approval

### API Versioning
- Latest version: `2022-06-28` — must be sent as `Notion-Version: 2022-06-28` header
- **Breaking change introduced 2025-09-03**: New versioning scheme — migrating old integrations requires updates
- Old database query endpoints (`/v1/databases/{id}/query`) still work but are deprecated — prefer Data Sources endpoints

### Pagination
- Default page size: **100 items** (also the maximum)
- `GET` requests: pagination params go in **query string**
- `POST` requests: pagination params go in **request body**
- Detect more results with `has_more: true` and use `next_cursor` as `start_cursor`

### IDs and Objects
- All IDs are UUIDv4 — dashes can be omitted in requests
- All property names are `snake_case`
- Empty strings are not supported — use explicit `null` to unset string fields
- Dates: ISO 8601 (`2020-08-12T02:12:33.231Z`) — time-only dates include time value

### Webhooks
- Require a separate webhook configuration (not a standard REST endpoint)
- Events are sent asynchronously — design for eventual consistency
