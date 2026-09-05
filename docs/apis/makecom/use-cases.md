# Make.com — Use Cases & Practical Guide

**Date:** 2026-03-01

---

## What You Can Do

### Free / No Auth Required
- Ping the API (`GET /ping`) to check service health

### Free with API Token (Any Plan)
- List, create, activate, deactivate, and delete scenarios
- Run scenarios on demand with input data
- Clone scenarios across teams or organizations
- Manage webhooks (create, enable/disable, ping, learn structure)
- Manage connections (list, verify, rename, check scopes)
- Manage data stores (create, update, delete)
- Manage keys/keychain (create, update, delete)
- Create and validate custom JavaScript functions
- Manage team and organization variables (with change history)
- Manage users (list, update profile, reset passwords, invite to org)
- Read and manage notifications
- View incomplete executions (DLQ) and trigger retries
- View 30-day usage metrics at scenario, team, and organization level

### Paid / Requires Setup
- OAuth 2.0 client (requires application with Make for client credentials)
- Analytics endpoint (`GET /analytics/{organizationId}`) — Enterprise plan + Owner role only; 1-year data retention
- Audit logs — requires Admin or Owner (org) or Team Admin (team) role
- Custom variables feature — requires specific plan feature flag enabled
- Subscription management endpoints (`/subscription`) — billing-related, plan-dependent
- Team LLM configuration — AI features are tier-based

### What the API Cannot Do
- No public OpenAPI/Swagger spec available for download
- Cannot access data store records directly via this API (data store CRUD for records uses a separate internal path)
- Analytics is Enterprise-only — no analytics API on lower plans
- Cannot manage app store/public templates beyond listing
- Cannot create or publish custom apps (SDK Apps require separate developer workflow)

---

## Automation Ideas

| Use Case | Complexity | What You Do | Key SDK / Endpoint |
|---|---|---|---|
| Trigger a Make scenario from any external tool | Easy | POST with input data | `POST /scenarios/{id}/run` |
| Monitor failed executions and auto-retry | Easy | Poll DLQ, retry all | `GET /dlqs`, `POST /dlqs/retry` |
| Activate/deactivate scenarios on a schedule | Easy | Cron job hits start/stop | `POST /scenarios/{id}/start` / `stop` |
| Sync scenario blueprints to Git (backup) | Medium | Fetch blueprint, commit | `GET /scenarios/{id}`, read blueprint field |
| Clone a scenario template to new clients | Medium | Clone with resource mapping | `POST /scenarios/{id}/clone` |
| Build a Make admin dashboard | Medium | Aggregate team/org usage | `GET /teams/{id}/usage`, `/organizations/{id}/usage` |
| Rotate/update connection credentials automatically | Medium | Fetch editable params, post new data | `GET /connections/{id}/editable-data-schema`, `POST /connections/{id}/set-data` |
| Alert on connection failures | Medium | Verify all connections periodically | `POST /connections/{id}/test` |
| Audit user access across org (compliance) | Medium | List users, roles, audit logs | `GET /users`, `GET /audit-logs/organization/{id}` |
| Auto-invite new team members via CI/CD | Easy | Invite by email with role | `POST /organizations/{id}/invite` |
| Track operations/credits consumption per team | Easy | Poll team usage daily | `GET /teams/{teamId}/usage` |
| Deploy custom JS functions from a code repo | Medium | Create/update functions via API | `POST /functions`, `PATCH /functions/{id}` |
| Validate function code before deploying | Easy | Run eval endpoint first | `POST /functions/eval` |
| Build scenario lifecycle management tool | Hard | Full CRUD + activate/deactivate + clone + variable management | Multiple endpoints |
| Enterprise scenario performance analytics | Hard | Pull analytics, build dashboards | `GET /analytics/{organizationId}` (Enterprise only) |

---

## Key Limits and Gotchas

### Authentication
- API tokens are user-scoped — they inherit the user's permissions
- Each token requires specific **scopes** to be enabled; missing scope → 403 Forbidden
- OAuth 2.0 clients must be requested from Make (not self-served)

### Rate Limits
- Not published in the official docs — use exponential backoff on 429 responses
- Large DLQ retry batches are queued with potential delays

### Case Sensitivity
- Endpoint paths are **case-sensitive** — always use exact casing as documented

### Destructive Operations
- Most DELETE and destructive actions require `confirmed=true` as a query param when the resource is in use by active scenarios
- Deleting a team also deletes all its scenarios, webhooks, data stores, and variables

### Pagination
- Two pagination styles: offset (`pg[offset]` + `pg[limit]`) and cursor (`pg[last]`)
- Use cursor pagination for large datasets to avoid performance issues
- `pg[returnTotalCount]=true` adds overhead — only use when needed

### Analytics
- Enterprise plan + Owner role required
- Maximum 1 year of historical data
- Data is per-scenario within org, filterable by team/folder/status

### Variable Types
- `typeId` is an integer: `1` = number, `2` = string, `3` = boolean, `4` = date
- Custom variables require the "custom variables" feature to be enabled for the org/team

### Scenario Execution
- `POST /scenarios/{id}/run` with `responsive: false` (default) returns immediately with only `executionId`
- With `responsive: true`, it waits and returns status: `1` (success), `2` (warning), `3` (error)
- Use `callbackUrl` for async webhook-based completion notification

### Multi-Zone Setup
- Make operates across zones (EU1, EU2, US1, US2, Celonis EU/US)
- You must hit the correct zone's base URL for your organization
- Some endpoints accept `imtZoneId` to specify zone

### Connection Management
- Connection credentials cannot be read back (write-only for security)
- Use `editable-data-schema` to discover which fields can be updated before calling `set-data`

### Hooks
- Newly created hooks are enabled by default
- Use `learn-start` / `learn-stop` to let Make auto-detect the incoming data structure
- `typeName` must match supported types (`gateway-webhook`, `gateway-mailhook`, etc.)

### Billing / Subscription Endpoints
- Subscription management endpoints interact with Make's payment system — use with care
- `subscription-free` downgrades to free tier — irreversible without going through checkout

### Audit Logs
- Organization audit logs require Admin or Owner role
- Team audit logs require Team Admin role
- Filterable by date range, event type, team, and author
