# Calendly API v2 — Technical Documentation

**Source:** https://developer.calendly.com/api-docs/d7a08c7f8e6f7-calendly-developer
**Additional Source:** https://developer.calendly.com/api-docs/
**Date:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [Base URL](#base-url)
3. [Authentication](#authentication)
4. [Rate Limits](#rate-limits)
5. [Request Format](#request-format)
6. [Response Format & Pagination](#response-format--pagination)
7. [Error Codes](#error-codes)
8. [Users](#users)
9. [Event Types](#event-types)
10. [Scheduled Events](#scheduled-events)
11. [Invitees](#invitees)
12. [Organizations](#organizations)
13. [Webhook Subscriptions](#webhook-subscriptions)
14. [Routing Forms](#routing-forms)
15. [Availability Schedules](#availability-schedules)

---

## Overview

Calendly API v2 is a REST API that provides access to Calendly scheduling data. It uses predictable resource-oriented URLs, JSON request/response bodies, standard HTTP methods, and OAuth 2.0 / Personal Access Token authentication. The API is read-oriented — most endpoints retrieve existing data; scheduling (creating invitees/events) is limited by design.

**Important:** There is **no API endpoint to reschedule an event**. Reschedule URLs are embedded in webhook payloads and invitee resources, but rescheduling must be performed by the invitee via Calendly's hosted page.

---

## Base URL

```
https://api.calendly.com
```

All endpoints are appended to this base URL. Example:

```
https://api.calendly.com/users/me
https://api.calendly.com/scheduled_events
https://api.calendly.com/webhook_subscriptions
```

---

## Authentication

Calendly API v2 supports two authentication methods:

### 1. Personal Access Token (PAT)

Best for internal tools, scripts, and single-user integrations.

**Generate a PAT:**
1. Log in to Calendly
2. Go to **Integrations > API & Webhooks**
3. Click **Generate New Token**

**Usage:**

```http
Authorization: Bearer YOUR_PERSONAL_ACCESS_TOKEN
```

A PAT authenticates as the user who created it. Access scope is determined by that user's Calendly role:
- **Member:** Access to their own data only
- **Admin/Owner:** Broader access to organization data

### 2. OAuth 2.0

Best for multi-user applications where you access data on behalf of other Calendly users.

**Flow:** Standard OAuth 2.0 Authorization Code flow.

**OAuth endpoints:**
- Authorization: `https://auth.calendly.com/oauth/authorize`
- Token exchange: `https://auth.calendly.com/oauth/token`
- Token refresh: `https://auth.calendly.com/oauth/token` (with `grant_type: refresh_token`)

**Usage after token exchange:**

```http
Authorization: Bearer <oauth-access-token>
```

### Choosing Between PAT and OAuth

| Use Case | Method |
|---|---|
| Internal team tool or personal automation | PAT |
| App used by multiple Calendly users | OAuth 2.0 |
| Single organization admin integration | PAT (admin-generated) |
| Marketplace or third-party integration | OAuth 2.0 |

---

## Rate Limits

Calendly does not publicly document exact numeric rate limits. Based on developer community reports and official references:

- Rate limits exist per token (user-level).
- The official docs reference a rate limits page but do not disclose specific thresholds.
- Practical guidance: stay under **~100 requests/minute** per token.
- Implement **exponential backoff** on `429 Too Many Requests` responses.
- Use `Retry-After` header if present in the 429 response.
- For bulk data pulls, add delays between requests (at least 200ms between calls).

**Pagination note:** For historical data pulls, prefer `min_start_time` incremental fetches over fetching all data at once.

---

## Request Format

- All request bodies must use `Content-Type: application/json`.
- All dates and times must be in **ISO 8601** format (e.g. `2026-03-01T10:00:00.000000Z`).
- Resource references use **URIs** (full URL strings), not integer IDs. Example: `https://api.calendly.com/users/ABCDEF123456`

**Standard request headers:**

```http
Authorization: Bearer YOUR_PAT_OR_OAUTH_TOKEN
Content-Type: application/json
```

---

## Response Format & Pagination

### Single Resource Response

```json
{
  "resource": {
    "uri": "https://api.calendly.com/users/ABCDEF123456",
    "name": "Alexander Thompson",
    "email": "alex@example.com",
    ...
  }
}
```

### Collection Response

```json
{
  "collection": [
    { ... },
    { ... }
  ],
  "pagination": {
    "count": 20,
    "next_page": "https://api.calendly.com/scheduled_events?count=20&page_token=NEXT_PAGE_TOKEN",
    "previous_page": null,
    "next_page_token": "NEXT_PAGE_TOKEN",
    "previous_page_token": null
  }
}
```

### Pagination Parameters

| Parameter | Type | Description |
|---|---|---|
| `count` | integer | Number of results per page. Max: **100**. Default: **20**. |
| `page_token` | string | Token from previous response's `next_page_token` to retrieve the next page. |

To paginate through all results, call the endpoint repeatedly with `page_token` from each response until `next_page_token` is null.

**Example paginated fetch:**

```javascript
let pageToken = null;
let allEvents = [];
do {
  const url = new URL('https://api.calendly.com/scheduled_events');
  url.searchParams.set('organization', ORG_URI);
  url.searchParams.set('count', '100');
  if (pageToken) url.searchParams.set('page_token', pageToken);

  const res = await fetch(url, { headers: { Authorization: `Bearer ${PAT}` }});
  const data = await res.json();
  allEvents.push(...data.collection);
  pageToken = data.pagination.next_page_token;
} while (pageToken);
```

---

## Error Codes

### HTTP Status Codes

| Status | Meaning |
|---|---|
| `200` | Success |
| `201` | Created |
| `204` | No Content (successful delete) |
| `400` | Bad Request — invalid or missing parameters |
| `401` | Unauthorized — missing or invalid token |
| `403` | Forbidden — valid token but insufficient permissions |
| `404` | Not Found — resource does not exist or has been deleted |
| `409` | Conflict — resource already exists |
| `429` | Too Many Requests — rate limit exceeded |
| `500` | Internal Server Error |

### Error Response Body

```json
{
  "title": "Invalid Argument",
  "message": "The supplied parameters are invalid.",
  "details": [
    {
      "parameter": "organization",
      "message": "Must be a valid organization URI",
      "code": "invalid_argument"
    }
  ]
}
```

| Field | Description |
|---|---|
| `title` | Short error classification |
| `message` | Human-readable description |
| `details` | Array of per-parameter validation errors (present on 400s) |

### Common Error Causes

| Error | Typical Cause |
|---|---|
| `401 Unauthorized` | PAT expired, revoked, or incorrectly formatted |
| `403 Forbidden` | Token scope insufficient (e.g. member token accessing org-level data) |
| `404 Not Found` | UUID in URI doesn't exist or event was deleted |
| `400 Invalid Argument` | Wrong URI format, missing required param, invalid date string |

---

## Users

### Get Current User

```
GET /users/me
```

Returns information about the authenticated user. This is the primary way to get your `user_uri` and `organization_uri` for use in other endpoints.

**Request:**

```http
GET https://api.calendly.com/users/me
Authorization: Bearer YOUR_PAT
```

**Response:**

```json
{
  "resource": {
    "uri": "https://api.calendly.com/users/ABCDEF123456",
    "name": "Alexander Thompson",
    "slug": "alexander-thompson",
    "email": "alex@example.com",
    "scheduling_url": "https://calendly.com/alexander-thompson",
    "timezone": "Europe/Amsterdam",
    "avatar_url": "https://...",
    "created_at": "2024-01-15T10:00:00.000000Z",
    "updated_at": "2026-01-01T08:00:00.000000Z",
    "current_organization": "https://api.calendly.com/organizations/ORG_UUID"
  }
}
```

### Get a Specific User

```
GET /users/{uuid}
```

---

## Event Types

### List Event Types

```
GET /event_types
```

Returns event types for a user or organization.

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `user` | string (URI) | One of user/org | Filter by user URI (e.g. `https://api.calendly.com/users/UUID`) |
| `organization` | string (URI) | One of user/org | Filter by organization URI |
| `active` | boolean | No | Filter by active status |
| `count` | integer | No | Results per page (max 100) |
| `page_token` | string | No | Pagination token |
| `sort` | string | No | Sort field. Example: `name:asc` |

**Example Request:**

```http
GET https://api.calendly.com/event_types?user=https://api.calendly.com/users/ABCDEF123456
Authorization: Bearer YOUR_PAT
```

**Response:**

```json
{
  "collection": [
    {
      "uri": "https://api.calendly.com/event_types/EVENT_TYPE_UUID",
      "name": "30 Minute Meeting",
      "active": true,
      "slug": "30min",
      "scheduling_url": "https://calendly.com/alexander-thompson/30min",
      "duration": 30,
      "kind": "solo",
      "pooling_type": null,
      "type": "StandardEventType",
      "color": "#4d9b8e",
      "created_at": "2024-01-15T10:00:00.000000Z",
      "updated_at": "2026-01-01T08:00:00.000000Z",
      "profile": {
        "type": "User",
        "name": "Alexander Thompson",
        "owner": "https://api.calendly.com/users/ABCDEF123456"
      },
      "secret": false
    }
  ],
  "pagination": {
    "count": 1,
    "next_page": null,
    "next_page_token": null
  }
}
```

### Get a Single Event Type

```
GET /event_types/{uuid}
```

---

## Scheduled Events

### List Scheduled Events

```
GET /scheduled_events
```

Returns scheduled events (meetings) for a user or organization.

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `user` | string (URI) | One of user/org | Filter events for a specific user |
| `organization` | string (URI) | One of user/org | Filter events for an entire organization |
| `count` | integer | No | Results per page. Max: **100**, Default: **20** |
| `page_token` | string | No | Pagination token from previous response |
| `status` | string | No | `active` or `canceled` |
| `min_start_time` | string | No | ISO 8601 — return events starting at or after this time |
| `max_start_time` | string | No | ISO 8601 — return events starting at or before this time |
| `invitee_email` | string | No | Filter by invitee email address |
| `sort` | string | No | Sort order. Example: `start_time:asc` or `start_time:desc` |

**Example Request:**

```http
GET https://api.calendly.com/scheduled_events?organization=https://api.calendly.com/organizations/ORG_UUID&status=active&min_start_time=2026-03-01T00:00:00.000000Z&count=100
Authorization: Bearer YOUR_PAT
```

**Example Response:**

```json
{
  "collection": [
    {
      "uri": "https://api.calendly.com/scheduled_events/EVENT_UUID",
      "name": "30 Minute Meeting",
      "status": "active",
      "start_time": "2026-03-01T10:00:00.000000Z",
      "end_time": "2026-03-01T10:30:00.000000Z",
      "event_type": "https://api.calendly.com/event_types/EVENT_TYPE_UUID",
      "location": {
        "type": "google_conference",
        "join_url": "https://meet.google.com/abc-def-ghi",
        "status": "pushed"
      },
      "invitees_counter": {
        "total": 1,
        "active": 1,
        "limit": 1
      },
      "created_at": "2026-02-20T09:00:00.000000Z",
      "updated_at": "2026-02-20T09:00:00.000000Z",
      "event_memberships": [
        {
          "user": "https://api.calendly.com/users/ABCDEF123456",
          "user_email": "alex@example.com",
          "user_name": "Alexander Thompson"
        }
      ],
      "event_guests": []
    }
  ],
  "pagination": {
    "count": 1,
    "next_page": null,
    "next_page_token": null
  }
}
```

### Get a Single Scheduled Event

```
GET /scheduled_events/{uuid}
```

### Cancel a Scheduled Event

```
POST /scheduled_events/{uuid}/cancellation
```

Cancels a scheduled event. Only the event owner or organization admin can cancel.

**Request Body:**

```json
{
  "reason": "Meeting no longer needed"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `reason` | string | No | Reason for cancellation (shown to invitee) |

**Response:** `200 OK` with the updated event object showing `"status": "canceled"`.

**Important:** There is **no reschedule endpoint**. The `reschedule_url` on the invitee object links to Calendly's hosted reschedule page.

---

## Invitees

### List Event Invitees

```
GET /scheduled_events/{uuid}/invitees
```

Returns all invitees for a specific scheduled event.

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `count` | integer | No | Results per page (max 100) |
| `page_token` | string | No | Pagination token |
| `status` | string | No | `active` or `canceled` |
| `email` | string | No | Filter by invitee email |
| `sort` | string | No | Sort field |

**Example Response:**

```json
{
  "collection": [
    {
      "uri": "https://api.calendly.com/scheduled_events/EVENT_UUID/invitees/INVITEE_UUID",
      "email": "john@example.com",
      "name": "John Doe",
      "status": "active",
      "questions_and_answers": [
        {
          "question": "What would you like to discuss?",
          "answer": "Project kickoff",
          "position": 0
        }
      ],
      "timezone": "America/New_York",
      "created_at": "2026-02-20T09:00:00.000000Z",
      "updated_at": "2026-02-20T09:00:00.000000Z",
      "event": "https://api.calendly.com/scheduled_events/EVENT_UUID",
      "cancel_url": "https://calendly.com/cancellations/INVITEE_UUID",
      "reschedule_url": "https://calendly.com/reschedulings/INVITEE_UUID",
      "payment": null,
      "no_show": null,
      "reconfirmation": null,
      "routing_form_submission": null,
      "utm_parameters": {
        "utm_campaign": null,
        "utm_source": null,
        "utm_medium": null,
        "utm_content": null,
        "utm_term": null,
        "salesforce_uuid": null
      }
    }
  ],
  "pagination": {
    "count": 1,
    "next_page": null,
    "next_page_token": null
  }
}
```

### Get a Single Invitee

```
GET /scheduled_events/{event_uuid}/invitees/{invitee_uuid}
```

---

## Organizations

### List Organization Members

```
GET /organization_memberships
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `organization` | string (URI) | Yes | Organization URI |
| `count` | integer | No | Results per page (max 100) |
| `page_token` | string | No | Pagination token |
| `email` | string | No | Filter by member email |

**Response fields per membership:**
- `uri` — membership URI
- `role` — `owner`, `admin`, or `user`
- `user` — nested user object
- `organization` — organization URI
- `created_at`, `updated_at`

### Get a Single Organization Membership

```
GET /organization_memberships/{uuid}
```

### Remove an Organization Member

```
DELETE /organization_memberships/{uuid}
```

### List Organization Invitations

```
GET /organizations/{uuid}/invitations
```

### Invite a User to Organization

```
POST /organizations/{uuid}/invitations
```

**Request Body:**

```json
{
  "email": "newmember@example.com"
}
```

### Revoke an Invitation

```
DELETE /organizations/{org_uuid}/invitations/{invitation_uuid}
```

---

## Webhook Subscriptions

Webhooks deliver real-time event data to your endpoint when scheduling events occur.

### List Webhook Subscriptions

```
GET /webhook_subscriptions
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `organization` | string (URI) | Yes | Organization URI |
| `user` | string (URI) | No | Filter by specific user (for user-scoped webhooks) |
| `scope` | string | No | `organization` or `user` |
| `count` | integer | No | Results per page |
| `page_token` | string | No | Pagination token |

**Example Response:**

```json
{
  "collection": [
    {
      "uri": "https://api.calendly.com/webhook_subscriptions/WEBHOOK_UUID",
      "callback_url": "https://my-app.com/webhooks/calendly",
      "created_at": "2026-01-01T10:00:00.000000Z",
      "updated_at": "2026-01-01T10:00:00.000000Z",
      "retry_started_at": null,
      "state": "active",
      "events": ["invitee.created", "invitee.canceled"],
      "scope": "organization",
      "organization": "https://api.calendly.com/organizations/ORG_UUID",
      "user": null,
      "creator": "https://api.calendly.com/users/ABCDEF123456"
    }
  ],
  "pagination": {
    "count": 1,
    "next_page": null,
    "next_page_token": null
  }
}
```

### Create a Webhook Subscription

```
POST /webhook_subscriptions
```

**Request Body:**

```json
{
  "url": "https://my-app.com/webhooks/calendly",
  "events": ["invitee.created", "invitee.canceled"],
  "organization": "https://api.calendly.com/organizations/ORG_UUID",
  "user": "https://api.calendly.com/users/ABCDEF123456",
  "scope": "user",
  "signing_key": "my-optional-signing-key"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Yes | HTTPS URL to receive webhook POSTs |
| `events` | array | Yes | Array of event types to subscribe to |
| `organization` | string (URI) | Yes | Organization URI |
| `user` | string (URI) | No | Required when `scope` is `user` |
| `scope` | string | Yes | `organization` or `user` |
| `signing_key` | string | No | Secret for HMAC signature verification |

**Scope rules:**
- `organization` scope: receives events for **all members** of the organization
- `user` scope: receives events for **one specific user** only
- Routing form submissions only support `organization` scope

**Response:** Returns the created webhook subscription object.

### Delete a Webhook Subscription

```
DELETE /webhook_subscriptions/{uuid}
```

Returns `204 No Content` on success.

### Supported Webhook Event Types

| Event | Description |
|---|---|
| `invitee.created` | An invitee scheduled a meeting |
| `invitee.canceled` | An invitee cancelled a meeting |
| `invitee_no_show.created` | An invitee was marked as no-show |
| `invitee_no_show.deleted` | A no-show mark was removed |
| `routing_form_submission.created` | A routing form was submitted |

### Webhook Payload Structure

```json
{
  "event": "invitee.created",
  "time": "2026-03-01T09:05:00.000000Z",
  "payload": {
    "event_type": {
      "uuid": "EVENT_TYPE_UUID",
      "kind": "One-on-One",
      "slug": "30min",
      "name": "30 Minute Meeting",
      "duration": 30,
      "owner": {
        "type": "User",
        "uuid": "USER_UUID"
      }
    },
    "event": {
      "uuid": "EVENT_UUID",
      "assigned_to": ["Alexander Thompson"],
      "extended_assigned_to": [
        {
          "name": "Alexander Thompson",
          "email": "alex@example.com",
          "primary": true
        }
      ],
      "start_time": "2026-03-01T10:00:00.000000Z",
      "start_time_pretty": "10:00am - Saturday, March 1, 2026",
      "invitee_start_time": "2026-03-01T10:00:00.000000Z",
      "invitee_start_time_pretty": "10:00am - Saturday, March 1, 2026",
      "end_time": "2026-03-01T10:30:00.000000Z",
      "end_time_pretty": "10:30am - Saturday, March 1, 2026",
      "invitee_end_time": "2026-03-01T10:30:00.000000Z",
      "invitee_end_time_pretty": "10:30am - Saturday, March 1, 2026",
      "created_at": "2026-02-20T09:00:00.000000Z",
      "location": "https://meet.google.com/abc-def-ghi",
      "cancellation": null,
      "rescheduled": false,
      "old_invitee": null,
      "new_invitee": null,
      "cancel_url": "https://calendly.com/cancellations/INVITEE_UUID",
      "reschedule_url": "https://calendly.com/reschedulings/INVITEE_UUID"
    },
    "invitee": {
      "uuid": "INVITEE_UUID",
      "first_name": "John",
      "last_name": "Doe",
      "name": "John Doe",
      "email": "john@example.com",
      "timezone": "America/New_York",
      "created_at": "2026-02-20T09:00:00.000000Z",
      "is_reschedule": false,
      "payments": [],
      "canceled": false,
      "cancellation": null
    },
    "questions_and_answers": [
      {
        "question": "What would you like to discuss?",
        "answer": "Project kickoff",
        "position": 0
      }
    ],
    "questions_and_responses": {},
    "tracking": {
      "utm_campaign": null,
      "utm_source": null,
      "utm_medium": null,
      "utm_content": null,
      "utm_term": null,
      "salesforce_uuid": null
    },
    "old_event": null,
    "old_invitee": null,
    "new_event": null,
    "new_invitee": null
  }
}
```

### Webhook Signature Verification

If you set a `signing_key`, Calendly signs webhook payloads. Verify using HMAC-SHA256:

```javascript
const crypto = require('crypto');

function verifyWebhook(payload, signature, signingKey) {
  const expected = crypto
    .createHmac('sha256', signingKey)
    .update(payload)
    .digest('base64');
  return crypto.timingSafeEqual(
    Buffer.from(signature, 'base64'),
    Buffer.from(expected, 'base64')
  );
}
// Signature is in the `Calendly-Webhook-Signature` header
```

---

## Routing Forms

Routing forms let you ask questions and direct invitees to specific event types based on their answers.

### List Routing Forms

```
GET /routing_forms
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `organization` | string (URI) | Yes | Organization URI |
| `count` | integer | No | Results per page |
| `page_token` | string | No | Pagination token |
| `sort` | string | No | Sort field |

**Response fields per routing form:**
- `uri`
- `name`
- `status` — `active` or `archived`
- `created_at`, `updated_at`
- `organization`
- `type`

### Get a Single Routing Form

```
GET /routing_forms/{uuid}
```

### List Routing Form Submissions

```
GET /routing_form_submissions
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `form` | string (URI) | Yes | Routing form URI |
| `count` | integer | No | Results per page |
| `page_token` | string | No | Pagination token |
| `sort` | string | No | Sort field |

**Response fields per submission:**
- `uri`
- `routing_form` — form URI
- `questions_and_answers` — array of question/answer pairs
- `tracking` — UTM parameters
- `result` — where the invitee was routed
- `created_at`
- `submitter`, `submitter_type`

### Get a Single Routing Form Submission

```
GET /routing_form_submissions/{uuid}
```

---

## Availability Schedules

### List User Availability Schedules

```
GET /user_availability_schedules
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `user` | string (URI) | Yes | User URI |

**Response:** Returns the user's availability schedules with rules (days, hours, timezone).

### Get a Single Availability Schedule

```
GET /user_availability_schedules/{uuid}
```

### List User Busy Times

```
GET /user_busy_times
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `user` | string (URI) | Yes | User URI |
| `start_time` | string | Yes | ISO 8601 start of range |
| `end_time` | string | Yes | ISO 8601 end of range |

Returns a user's busy time blocks (from calendar integrations and existing bookings).

---

## Subscription Requirements

| Endpoint Category | Plan Required |
|---|---|
| GET endpoints (most) | Any plan (including Basic/Free) |
| Webhook subscriptions | Paid plan (Premium and above) |
| Organization admin endpoints | Admin/Owner role |
| Routing forms | Professional plan and above |
| Enterprise-only endpoints | Enterprise plan |

---

*Sources:*
- https://developer.calendly.com/api-docs/d7a08c7f8e6f7-calendly-developer
- https://developer.calendly.com/api-docs/
- https://developer.calendly.com/getting-started
- https://developer.calendly.com/how-to-authenticate-with-personal-access-tokens
- https://developer.calendly.com/receive-data-from-scheduled-events-in-real-time-with-webhook-subscriptions
- https://developer.calendly.com/api-docs/edca8074633f8-rate-limits
- https://developer.calendly.com/api-docs/ZG9jOjE1MDE3NzI-api-conventions
- https://developer.calendly.com/frequently-asked-questions
