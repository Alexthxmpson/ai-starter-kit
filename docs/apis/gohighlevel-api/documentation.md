# GoHighLevel (HighLevel) API Documentation
Source: https://marketplace.gohighlevel.com/docs/ | Saved: 2026-03-10

---

## Overview

- **Base URL**: `https://services.leadconnectorhq.com`
- **API Version Header**: `Version: 2021-07-28`
- **Auth**: `Authorization: Bearer <token>`
- **Official MCP endpoint**: `https://services.leadconnectorhq.com/mcp/`

---

## Authentication

### Private Integration Token (PIT)
- Format: `pit-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- Obtained via: GHL Settings → Integrations → Private Integrations
- Scope-based — only requested scopes are accessible
- Rotate every 90 days (7-day overlap window)
- Passed as: `Authorization: Bearer pit-...`
- **locationId** must also be passed as a query param or header for sub-account endpoints

### Old Location JWT (legacy)
- Format: `eyJhbGciOiJIUzI1NiJ9...`
- Contains `location_id` and `company_id` in payload
- Less secure — no scope restriction

---

## MCP Server (Official)

**Endpoint**: `https://services.leadconnectorhq.com/mcp/`
**Transport**: HTTP Streamable (SSE)
**Auth headers**:
```
Authorization: Bearer pit-...
locationId: jkkz9cczD1uyCBjFOXok
Version: 2021-07-28
```

**36+ Tools available** (roadmap: 250+):
- Contact management (create, update, search, tag, delete)
- Conversations & messaging (SMS, email, chat)
- Opportunities & pipelines
- Calendars & appointments
- Social media posting & analytics
- Blog management
- Email templates
- Payment transactions
- Workflows
- Custom fields
- Media library
- Surveys
- Products & store
- Invoices

---

## Key Endpoints (REST)

### Contacts
```
GET    /contacts/?locationId={id}
POST   /contacts/
GET    /contacts/{contactId}
PUT    /contacts/{contactId}
DELETE /contacts/{contactId}
POST   /contacts/{contactId}/tags
DELETE /contacts/{contactId}/tags
POST   /contacts/{contactId}/notes
GET    /contacts/{contactId}/notes
GET    /contacts/{contactId}/tasks
POST   /contacts/{contactId}/tasks
```

### Conversations
```
GET    /conversations/?locationId={id}
POST   /conversations/
GET    /conversations/{conversationId}
PUT    /conversations/{conversationId}
DELETE /conversations/{conversationId}
POST   /conversations/messages
GET    /conversations/{conversationId}/messages
```

### Opportunities
```
GET    /opportunities/search?location_id={id}
POST   /opportunities/
GET    /opportunities/{opportunityId}
PUT    /opportunities/{opportunityId}
DELETE /opportunities/{opportunityId}
PUT    /opportunities/{opportunityId}/status
```

### Calendars
```
GET    /calendars/?locationId={id}
GET    /calendars/events?locationId={id}
POST   /calendars/events/appointments
GET    /calendars/events/appointments/{eventId}
PUT    /calendars/events/appointments/{eventId}
DELETE /calendars/events/appointments/{eventId}
GET    /calendars/{calendarId}/free-slots
```

### Locations (Sub-accounts)
```
GET    /locations/{locationId}
PUT    /locations/{locationId}
GET    /locations/search?companyId={id}
POST   /locations/
DELETE /locations/{locationId}
GET    /locations/{locationId}/customFields
POST   /locations/{locationId}/customFields
GET    /locations/{locationId}/customValues
POST   /locations/{locationId}/customValues
GET    /locations/{locationId}/tags
POST   /locations/{locationId}/tags
GET    /locations/{locationId}/pipelines
GET    /locations/{locationId}/tasks
```

### Blogs
```
GET    /blogs/posts?locationId={id}
POST   /blogs/posts
PUT    /blogs/posts/{postId}
GET    /blogs/?locationId={id}
GET    /blogs/authors?locationId={id}
GET    /blogs/categories?locationId={id}
GET    /blogs/check-slug?slug={slug}&locationId={id}
```

### Payments & Invoices
```
GET    /payments/transactions?locationId={id}
GET    /payments/orders?locationId={id}
GET    /invoices/?locationId={id}
POST   /invoices/
GET    /invoices/{invoiceId}
PUT    /invoices/{invoiceId}
DELETE /invoices/{invoiceId}
POST   /invoices/{invoiceId}/send
POST   /invoices/{invoiceId}/record-payment
```

### Social Media
```
POST   /social-media-posting/{locationId}/posts
GET    /social-media-posting/{locationId}/posts
PUT    /social-media-posting/{locationId}/posts/{postId}
DELETE /social-media-posting/{locationId}/posts/{postId}
GET    /social-media-posting/{locationId}/accounts
```

### Workflows
```
GET    /workflows/?locationId={id}
```

### Surveys
```
GET    /surveys/?locationId={id}
GET    /surveys/submissions?locationId={id}
```

---

## Common Headers

```
Authorization: Bearer <token>
Version: 2021-07-28
Content-Type: application/json
Accept: application/json
```

---

## Environment Variables (Alexander's Setup)

```
GHL_PRIVATE_TOKEN=pit-YOUR-TOKEN-HERE
GHL_LOCATION_ID=jkkz9cczD1uyCBjFOXok
GHL_COMPANY_ID=GLVSQhpgFnZC9wgnTPvt
GHL_BASE_URL=https://services.leadconnectorhq.com
```

---

## Required Scopes (for PIT)

Enable in GHL → Settings → Integrations → Private Integrations:
- `contacts.readonly` + `contacts.write`
- `conversations.readonly` + `conversations.write`
- `conversations/message.readonly` + `conversations/message.write`
- `opportunities.readonly` + `opportunities.write`
- `calendars.readonly` + `calendars.write`
- `calendars/events.readonly` + `calendars/events.write`
- `locations.readonly`
- `blogs.readonly` + `blogs.write`
- `payments.readonly`
- `invoices.readonly` + `invoices.write`
- `social-media-posting.readonly` + `social-media-posting.write`
- `workflows.readonly`
- `surveys.readonly`
- `medias.readonly` + `medias.write`
- `products.readonly` + `products.write`

---

## Error Codes

| Code | Meaning |
|------|---------|
| 401 | Token invalid or scope not enabled |
| 403 | Forbidden — wrong location or missing permission |
| 404 | Resource not found |
| 422 | Validation error — check request body |
| 429 | Rate limited |
