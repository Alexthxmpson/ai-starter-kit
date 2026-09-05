# Airtable API — Use Cases & Practical Guide

**Date:** 2026-02-27

---

## What You Can Do

### Free Plan (Personal Access Token — All Plans)

- Read all records from any table (filtered, sorted, by view)
- Create up to 10 records per API call
- Update or replace records (batch up to 10 per call)
- Delete records (batch up to 10 per call)
- Upsert records (find-and-update or create in one call)
- Read base schema: table names, field types, view names
- List all bases your token has access to
- Create and refresh webhooks to receive real-time change notifications
- Create new bases, tables, and fields via the Metadata API
- Filter records using Airtable formula syntax (`filterByFormula`)

### Requires Specific Scopes (On Any Plan)

| Action | Required Scope |
|---|---|
| Read records | `data.records:read` |
| Write records | `data.records:write` |
| Read schema | `schema.bases:read` |
| Modify schema | `schema.bases:write` |
| Webhooks | `webhook:manage` |
| Read comments | `data.recordComments:read` |

### What the API Cannot Do

- Delete tables or fields (create-only via API, modify via UI)
- Write to formula, rollup, lookup, count, auto number, created time, created by, last modified time, last modified by, or button fields
- Upload files directly — attachments must be provided as public URLs
- Access Airtable automations or interfaces programmatically
- Increase rate limits (5 req/s for OAuth, 50 req/s for PAT — no paid tiers change this)
- Read or write `button` field values
- Query multiple tables in one API call

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key Endpoint |
|---|---|---|---|
| Pull all records to a script | Easy | List records with pagination, collect all pages | `GET /v0/{baseId}/{tableId}` |
| Add a new row to a table | Easy | POST a single record with field values | `POST /v0/{baseId}/{tableId}` |
| Mark tasks done in bulk | Easy | PATCH up to 10 records per call with Status = Done | `PATCH /v0/{baseId}/{tableId}` |
| Delete completed records | Easy | Filter for Done records, delete in batches of 10 | GET + DELETE |
| Read base/table structure | Easy | Fetch schema to discover field names and types | `GET /v0/meta/bases/{id}/tables` |
| Sync form submissions to a table | Easy | POST each submission as a record from a webhook or form handler | `POST /v0/{baseId}/{tableId}` |
| Upsert contacts from CRM | Medium | Use `performUpsert` on Email field to update or create | `PATCH` with `performUpsert` |
| Filter records by formula | Medium | Use `filterByFormula` with Airtable formula syntax | `GET` with query params |
| Real-time notifications on record change | Medium | Create a webhook, listen at your endpoint, process payload | `POST /v0/bases/{id}/webhooks` |
| Export table to CSV/JSON | Medium | Paginate through all records, write to file | GET with pagination loop |
| Bi-directional sync with another tool | Medium | Poll both APIs, detect diffs, push updates to each | GET + PATCH |
| Copy records from one base to another | Medium | Read from source, create in destination with mapped fields | GET + POST |
| Automated reporting | Medium | Query filtered records, compute aggregates, send via email/Slack | GET + external service |
| Create a table dynamically from schema | Hard | POST to metadata API to create table + all fields | `POST /v0/meta/bases/{id}/tables` |
| Full base clone/backup | Hard | Read schema + all records from all tables, recreate in new base | Schema GET + Record GET + POST |
| Build an API on top of Airtable | Hard | Use Airtable as a database, expose filtered views via your own REST API | All record endpoints |
| Webhook-driven pipeline | Hard | Receive webhook, parse changed fields, trigger downstream actions conditionally | Webhook + PATCH |

---

## Key Limits and Gotchas

### Rate Limits

- **PAT:** 50 requests/second (use PATs for any serious automation)
- **OAuth token:** 5 requests/second per base
- **Batch up to 10 records** per create/update/delete call — this is the single most important optimization
- A `429` response means you need to wait and retry — no header tells you how long; use exponential backoff
- Rate limit is **per base**, not per account — querying multiple bases in parallel is safe

### Pagination

- Records come back in pages of up to 100
- Always check for `offset` in the response — if present, there are more pages
- The `offset` string is **opaque and time-limited** — do not store and reuse it hours later (`LIST_RECORDS_OFFSET_INVALID` error will result)
- Complete pagination in one session without large delays between calls

### FilterByFormula Syntax

- Uses Airtable formula language — not SQL, not JSON
- Reference field **names** in curly braces: `{Field Name}`
- Examples:

```
# Single condition
filterByFormula={Status}='In Progress'

# Multiple conditions
filterByFormula=AND({Status}='In Progress',{Priority}='High')

# Date comparison
filterByFormula=IS_AFTER({Due Date},TODAY())

# Contains text
filterByFormula=FIND('keyword',{Notes})>0

# Not empty
filterByFormula={Email}!=''
```

- Special characters in field names must be enclosed in `{curly braces}`
- Formula is URL-encoded when passed as a query parameter

### Attachments

- You cannot upload a file directly to Airtable via the API
- Attachments must be provided as **publicly accessible URLs**
- Airtable fetches the file from the URL and stores it
- To **add** an attachment without replacing existing ones, include existing attachment objects AND new ones in the same array
- Writing only new URL objects **replaces** all existing attachments

```json
// Append to existing attachments (preserve + add)
{
  "Attachments": [
    { "id": "attEXISTING", "url": "..." },  // existing — must include
    { "url": "https://new-file.com/doc.pdf" }  // new
  ]
}
```

### Field References: Names vs IDs

- By default, the API uses **field names** in `fields` objects
- Names can change — breaking your integration
- Use `returnFieldsByFieldId=true` on GET requests and pass field IDs in write requests for stability
- Field IDs start with `fld` and are stable even after renaming

### Computed Fields Are Read-Only

These field types cannot be written via the API:

| Field Type | Reason |
|---|---|
| `formula` | Computed from other fields |
| `rollup` | Aggregated from linked table |
| `lookup` | Looked up from linked table |
| `count` | Count of linked records |
| `autoNumber` | Auto-incrementing |
| `createdTime` | Set on creation |
| `lastModifiedTime` | Set on modification |
| `createdBy` | Set on creation |
| `lastModifiedBy` | Set on modification |
| `button` | UI action only |
| `aiText` | AI-generated |

### Webhooks Expire

- Webhooks expire after **7 days** of inactivity
- Airtable sends a warning before expiry — but only if it can reach your endpoint
- Refresh webhooks with `POST /v0/bases/{baseId}/webhooks/{webhookId}/refresh`
- Implement a scheduled job to refresh all active webhooks weekly
- Always validate incoming payloads using HMAC-SHA256 with the `macSecretBase64` secret

### Table and Field Deletion

- Tables: **cannot be deleted via API** — only via the UI
- Fields: **cannot be deleted via API** — only via the UI
- This means schema cleanup must be done manually in Airtable

### Select Field Choices

- Writing a value to a `singleSelect` or `multipleSelects` field that does not exist as a choice **creates it automatically**
- This can result in unbounded option lists — validate before writing if you want to constrain choices
- Choice IDs (`selXXX`) are stable, names are not — if you rename an option the ID stays the same

### OAuth Token Expiry

- Access tokens expire in **1 hour** — must refresh proactively
- Refresh tokens expire in **60 days** — if a user doesn't use your app for 60 days, they need to re-authorize
- Store both tokens securely and implement token refresh before access token expiry

### Table Name vs Table ID in URLs

- The records API accepts both the table **name** and table **ID** (`tblXXX`) in the URL path
- Prefer table IDs for stability — table names can be renamed
- Table IDs are returned by the schema endpoint (`GET /v0/meta/bases/{baseId}/tables`)

### PAT Scope Is Set at Token Creation

- If you need additional scopes later, you must create a **new token** — you cannot modify an existing PAT
- Keep PATs with minimal scope: only grant what each integration actually needs
- Resource access (which bases the token can see) is also set at creation time
