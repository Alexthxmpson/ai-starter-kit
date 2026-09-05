# Cal.com API v2 — Technical Documentation

**Source:** https://cal.com/docs/api-reference/v2/introduction
**Additional Source:** https://cal.com/docs/api-reference/v2/bookings/get-all-bookings
**Date:** 2026-02-27

---

## Table of Contents

1. [Overview](#overview)
2. [Base URL & Versioning](#base-url--versioning)
3. [Authentication](#authentication)
4. [Rate Limits](#rate-limits)
5. [Request Format](#request-format)
6. [Response Format](#response-format)
7. [Error Codes](#error-codes)
8. [Bookings](#bookings)
9. [Event Types](#event-types)
10. [Slots / Availability](#slots--availability)
11. [Webhooks](#webhooks)
12. [OAuth Clients & Managed Users](#oauth-clients--managed-users)
13. [Organizations & Teams](#organizations--teams)

---

## Overview

Cal.com API v2 is a REST API that exposes scheduling resources — bookings, event types, availability, and more — via simple HTTP endpoints. It supports creating, modifying, fetching, and removing all core scheduling objects. V2 is the current production version; V1 is deprecated.

---

## Base URL & Versioning

```
https://api.cal.com/v2
```

For self-hosted deployments, replace the base URL with your own domain.

**API Version Header** (required on most endpoints):

```
cal-api-version: 2024-06-14
```

Cal.com uses date-based versioning in the format `YYYY-MM-DD`. The two most common version strings are:

| Version String | Notes |
|---|---|
| `2024-06-14` | Stable version for most endpoints |
| `2024-08-13` | Newer version; required for some updated endpoints |

Always include the `cal-api-version` header. Without it, endpoints may default to an older or unexpected version.

---

## Authentication

Cal.com API v2 supports three authentication methods:

### 1. API Key (Personal Use)

Generate an API key from your Cal.com dashboard at **Settings > Developer > API Keys**.

Pass the key in the `Authorization` header:

```http
Authorization: Bearer <your-api-key>
```

API keys are tied to your individual user account and give access to all resources owned by that user.

### 2. OAuth 2.0 (Multi-User / Platform Apps)

Used when building applications that act on behalf of other Calendly users (managed users). Requires:

- Creating an OAuth client to get `x-cal-client-id` and `x-cal-secret-key`
- Exchanging credentials for access/refresh tokens per managed user

**OAuth headers:**

```http
x-cal-client-id: <your-oauth-client-id>
x-cal-secret-key: <your-oauth-client-secret>
```

**Access token usage** (for managed user requests):

```http
Authorization: Bearer <managed-user-access-token>
```

Token lifetimes:
- Access token: **60 minutes**
- Refresh token: **1 year**

Refresh tokens via `POST /v2/oauth/{clientId}/refresh`.

### 3. Platform (Deprecated)

The legacy Platform authentication method is deprecated. Use OAuth instead.

### When Each Method Is Required

| Action | Auth Method |
|---|---|
| Personal bookings, event types, availability | API Key |
| Managing managed users | OAuth (`x-cal-secret-key`) |
| Creating OAuth client webhooks | OAuth |
| Refreshing managed user tokens | OAuth |
| Team / org endpoints | OAuth or Managed User Token |
| Acting as a managed user | Managed User Access Token (Bearer) |

---

## Rate Limits

| Auth Method | Default Rate Limit |
|---|---|
| API Key | 120 requests/minute |
| OAuth Client Credentials | 500 requests/minute |
| Managed User Access Token | 500 requests/minute |
| Unauthenticated | 120 requests/minute |

- Rate limits can be increased upon request (up to ~800 req/min may incur extra charges).
- Contact Cal.com support to request higher limits.
- Implement exponential backoff when you receive `429 Too Many Requests`.

---

## Request Format

- All request bodies must be `Content-Type: application/json`.
- Query parameters are used for GET requests.
- All timestamps must be in **ISO 8601** format in **UTC** unless otherwise specified.

**Standard request headers:**

```http
Authorization: Bearer <token>
cal-api-version: 2024-06-14
Content-Type: application/json
```

---

## Response Format

All responses return JSON with a consistent wrapper:

```json
{
  "status": "success",
  "data": { ... }
}
```

Error responses:

```json
{
  "status": "error",
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description"
  }
}
```

---

## Error Codes

| HTTP Status | Meaning |
|---|---|
| `200` | Success |
| `201` | Created |
| `400` | Bad Request — invalid parameters or missing required fields |
| `401` | Unauthorized — missing or invalid token/API key |
| `403` | Forbidden — valid auth but insufficient permissions |
| `404` | Not Found — resource does not exist |
| `409` | Conflict — e.g. booking time slot no longer available |
| `422` | Unprocessable Entity — validation errors |
| `429` | Too Many Requests — rate limit exceeded |
| `500` | Internal Server Error |

Common error codes returned in the body:

| Code | Description |
|---|---|
| `BAD_REQUEST` | Missing or malformed parameters |
| `UNAUTHORIZED` | Auth token missing or invalid |
| `FORBIDDEN` | Insufficient permissions |
| `NOT_FOUND` | Resource not found |
| `CONFLICT` | Booking slot taken or conflict |

---

## Bookings

### Get All Bookings

```
GET /v2/bookings
```

Returns bookings for the authenticated user.

**Headers:**

```http
Authorization: Bearer <token>
cal-api-version: 2024-06-14
```

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `status` | string | Filter by booking status. Values: `upcoming`, `recurring`, `past`, `cancelled`, `unconfirmed`. Comma-separate for multiple. |
| `attendeeEmail` | string | Filter by attendee email address |
| `attendeeName` | string | Filter by attendee name |
| `uid` | string | Filter by booking UID |
| `eventTypeIds` | string | Comma-separated event type IDs |
| `teamIds` | string | Comma-separated team IDs |
| `afterStart` | string | ISO 8601 datetime — bookings starting after this time |
| `beforeEnd` | string | ISO 8601 datetime — bookings ending before this time |
| `afterCreatedAt` | string | ISO 8601 datetime — bookings created after this time |
| `beforeCreatedAt` | string | ISO 8601 datetime — bookings created before this time |
| `afterUpdatedAt` | string | ISO 8601 datetime — bookings updated after this time |
| `beforeUpdatedAt` | string | ISO 8601 datetime — bookings updated before this time |
| `sortBy` | string | Field to sort by: `start`, `end`, `createdAt`, `updatedAt` |
| `sortOrder` | string | `asc` or `desc` |
| `take` | integer | Number of results to return (pagination) |
| `skip` | integer | Number of results to skip (pagination) |

**Example Request:**

```http
GET /v2/bookings?status=upcoming&take=10&skip=0
Authorization: Bearer cal_live_abc123
cal-api-version: 2024-06-14
```

**Example Response:**

```json
{
  "status": "success",
  "data": [
    {
      "id": 123,
      "uid": "booking-uid-abc123",
      "title": "30 Minute Meeting",
      "description": "Let's connect",
      "hosts": [
        {
          "id": 1,
          "name": "Alexander Thompson",
          "email": "alex@example.com",
          "timeZone": "Europe/Amsterdam",
          "username": "alexander"
        }
      ],
      "status": "accepted",
      "start": "2026-03-01T10:00:00.000Z",
      "end": "2026-03-01T10:30:00.000Z",
      "duration": 30,
      "eventTypeId": 456,
      "eventType": {
        "id": 456,
        "slug": "30min",
        "title": "30 Minute Meeting"
      },
      "location": {
        "type": "integrations:google:meet",
        "link": "https://meet.google.com/abc-def-ghi"
      },
      "attendees": [
        {
          "name": "John Doe",
          "email": "john@example.com",
          "timeZone": "America/New_York",
          "language": { "locale": "en" }
        }
      ],
      "bookingFieldsResponses": {
        "name": "John Doe",
        "email": "john@example.com",
        "notes": "Looking forward to it"
      },
      "cancellationReason": null,
      "createdAt": "2026-02-20T09:00:00.000Z",
      "updatedAt": "2026-02-20T09:00:00.000Z"
    }
  ]
}
```

---

### Get a Single Booking

```
GET /v2/bookings/{bookingUid}
```

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `bookingUid` | string | The unique identifier (UID) of the booking |

---

### Create a Booking

```
POST /v2/bookings
```

Creates regular, recurring, or instant bookings. The type of booking created depends on the `eventTypeId` provided.

**Request Body:**

```json
{
  "eventTypeId": 456,
  "start": "2026-03-01T10:00:00.000Z",
  "attendee": {
    "name": "John Doe",
    "email": "john@example.com",
    "timeZone": "America/New_York",
    "language": "en",
    "phoneNumber": "+31612345678"
  },
  "guests": ["guest@example.com"],
  "meetingUrl": "https://meet.google.com/custom",
  "location": {
    "optionValue": "",
    "value": "integrations:google:meet"
  },
  "bookingFieldsResponses": {
    "notes": "Please bring slides"
  },
  "metadata": {
    "source": "my-app"
  },
  "hasHashedBookingLink": false,
  "hashBookingLink": ""
}
```

**Key Notes:**
- If `eventTypeId` belongs to a regular event type, a regular booking is created.
- If `eventTypeId` belongs to a recurring event type, a recurring booking is created.
- `attendee.phoneNumber` is optional but required when SMS reminders are enabled on the event type.
- `guests` is an array of additional attendee emails.

**Response:** Returns the created booking object (same schema as Get All Bookings response).

---

### Cancel a Booking

```
POST /v2/bookings/{bookingUid}/cancel
```

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `bookingUid` | string | UID of the booking to cancel. Can be a regular booking, individual recurrence, or recurring series UID to cancel all. |

**Request Body:**

```json
{
  "cancellationReason": "Schedule conflict",
  "seatUid": "seat-uid-xyz"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `cancellationReason` | string | No | Reason for cancellation |
| `seatUid` | string | No | For seated bookings only — cancels a specific seat rather than the whole booking |

**Notes:**
- Passing the recurring booking UID cancels **all recurrences**.
- Passing an individual recurrence UID cancels only that occurrence.
- For seated bookings, pass `seatUid` to cancel a specific attendee's seat.

---

### Reschedule a Booking

```
POST /v2/bookings/{bookingUid}/reschedule
```

**Request Body:**

```json
{
  "start": "2026-03-05T14:00:00.000Z",
  "rescheduledBy": "alex@example.com",
  "reschedulingReason": "Meeting room conflict"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `start` | string | Yes | New start time in ISO 8601 UTC |
| `rescheduledBy` | string | No | Email of the person rescheduling |
| `reschedulingReason` | string | No | Reason for rescheduling |

**Important behavior:**
- If `rescheduledBy` is the **event type owner's email**, the rescheduled booking is **automatically confirmed**.
- If `rescheduledBy` is the attendee's email or omitted, the event type owner must manually confirm the rescheduled booking (if confirmation is required).

---

### Booking Status Values

| Status | Description |
|---|---|
| `accepted` | Confirmed booking |
| `pending` | Awaiting host confirmation |
| `cancelled` | Cancelled booking |
| `rejected` | Rejected by host |

---

## Event Types

### Get All Event Types

```
GET /v2/event-types
```

**Headers:**

```http
Authorization: Bearer <token>
cal-api-version: 2024-06-14
```

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `username` | string | Get event types for a specific user |
| `eventSlug` | string | Get a specific event type by slug (requires `username`) |
| `usernames` | string | Comma-separated usernames for dynamic event types (e.g. `alice,bob`) |

**Example Response:**

```json
{
  "status": "success",
  "data": [
    {
      "id": 456,
      "slug": "30min",
      "title": "30 Minute Meeting",
      "description": "A standard 30 minute call",
      "lengthInMinutes": 30,
      "locations": [
        {
          "type": "integrations:google:meet"
        }
      ],
      "bookingFields": [
        {
          "name": "notes",
          "type": "textarea",
          "label": "Additional notes",
          "required": false
        }
      ],
      "disableGuests": false,
      "price": 0,
      "currency": "usd",
      "metadata": {},
      "recurrence": null
    }
  ]
}
```

### Create an Event Type

```
POST /v2/event-types
```

### Get a Single Event Type

```
GET /v2/event-types/{eventTypeId}
```

### Update an Event Type

```
PATCH /v2/event-types/{eventTypeId}
```

### Delete an Event Type

```
DELETE /v2/event-types/{eventTypeId}
```

---

## Slots / Availability

### Get Available Time Slots

```
GET /v2/slots
```

Returns available booking slots for a given event type within a time range.

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `eventTypeId` | integer | Yes | ID of the event type |
| `start` | string | Yes | ISO 8601 UTC datetime — start of the search range. Can be a date (defaults to start of day) or a specific time. |
| `end` | string | Yes | ISO 8601 UTC datetime — end of the search range |
| `timeZone` | string | No | Timezone for returned slots. Defaults to `UTC`. |
| `duration` | integer | No | Duration in minutes. Required for multi-duration event types; defaults to event type's default duration. |
| `format` | string | No | Slot format: `time` (start time only) or `range` (start + end times). Default returns object keyed by date. |
| `username` | string | No | Username for user-specific slots |
| `usernameList` | string | No | Comma-separated for dynamic event types |

**Example Request:**

```http
GET /v2/slots?eventTypeId=456&start=2026-03-01&end=2026-03-07&timeZone=Europe/Amsterdam
```

**Example Response (default format):**

```json
{
  "status": "success",
  "data": {
    "slots": {
      "2026-03-01": [
        { "time": "2026-03-01T09:00:00.000Z" },
        { "time": "2026-03-01T09:30:00.000Z" },
        { "time": "2026-03-01T10:00:00.000Z" }
      ],
      "2026-03-02": [
        { "time": "2026-03-02T08:00:00.000Z" }
      ]
    }
  }
}
```

**Example Response (`range` format):**

```json
{
  "status": "success",
  "data": {
    "slots": {
      "2026-03-01": [
        {
          "start": "2026-03-01T09:00:00.000Z",
          "end": "2026-03-01T09:30:00.000Z"
        }
      ]
    }
  }
}
```

---

## Webhooks

Webhooks are scoped to event types. They fire on booking lifecycle events.

### Get All Webhooks (for an Event Type)

```
GET /v2/event-types/{eventTypeId}/webhooks
```

**Example Response:**

```json
{
  "status": "success",
  "data": [
    {
      "id": "webhook-id-123",
      "eventTypeId": 456,
      "subscriberUrl": "https://my-app.com/webhooks/calcom",
      "active": true,
      "triggers": ["BOOKING_CREATED", "BOOKING_CANCELLED"],
      "payloadTemplate": null,
      "secret": "my-webhook-secret"
    }
  ]
}
```

### Create a Webhook

```
POST /v2/event-types/{eventTypeId}/webhooks
```

**Request Body:**

```json
{
  "subscriberUrl": "https://my-app.com/webhooks/calcom",
  "triggers": ["BOOKING_CREATED", "BOOKING_CANCELLED", "BOOKING_RESCHEDULED"],
  "active": true,
  "payloadTemplate": null,
  "secret": "my-webhook-secret"
}
```

### Delete a Webhook

```
DELETE /v2/event-types/{eventTypeId}/webhooks/{webhookId}
```

### Supported Webhook Triggers

| Trigger | Description |
|---|---|
| `BOOKING_CREATED` | A new booking was created |
| `BOOKING_RESCHEDULED` | A booking was rescheduled |
| `BOOKING_CANCELLED` | A booking was cancelled |
| `BOOKING_CONFIRMED` | A pending booking was confirmed |
| `BOOKING_REJECTED` | A pending booking was rejected |
| `BOOKING_COMPLETED` | A booking was marked completed |
| `BOOKING_NO_SHOW` | Attendee marked as no-show |
| `BOOKING_REOPENED` | A completed booking was reopened |

### Webhook Payload (example)

```json
{
  "triggerEvent": "BOOKING_CREATED",
  "createdAt": "2026-03-01T10:00:00.000Z",
  "payload": {
    "uid": "booking-uid-abc123",
    "title": "30 Minute Meeting",
    "status": "accepted",
    "start": "2026-03-01T10:00:00.000Z",
    "end": "2026-03-01T10:30:00.000Z",
    "organizer": {
      "id": 1,
      "name": "Alexander Thompson",
      "email": "alex@example.com",
      "timeZone": "Europe/Amsterdam"
    },
    "attendees": [
      {
        "email": "john@example.com",
        "name": "John Doe",
        "timeZone": "America/New_York"
      }
    ]
  }
}
```

---

## OAuth Clients & Managed Users

This section is for platform builders managing scheduling on behalf of users.

### Create an OAuth Client

```
POST /v2/oauth-clients
```

Returns `clientId` and `clientSecret` used to create managed users and generate tokens.

### Create a Managed User

```
POST /v2/oauth/{clientId}/users
```

**Request Body:**

```json
{
  "email": "newuser@example.com",
  "name": "New User",
  "timeZone": "Europe/Amsterdam",
  "weekStart": "Monday",
  "timeFormat": 24,
  "locale": "en"
}
```

**Response includes:**
- `id` — managed user's Cal.com ID
- `accessToken` — valid for 60 minutes
- `refreshToken` — valid for 1 year

Store `calManagedUserId`, `calAccessToken`, and `calRefreshToken` in your users table.

### Refresh a Managed User's Token

```
POST /v2/oauth/{clientId}/refresh
```

**Request Body:**

```json
{
  "refreshToken": "<refresh-token>"
}
```

---

## Organizations & Teams

### List Organization Members

```
GET /v2/organizations/{orgId}/members
```

### Get All Bookings for an Organization User

```
GET /v2/organizations/{orgId}/users/{userId}/bookings
```

**Query Parameters:** Same as `GET /v2/bookings` (status, filters, sort, pagination).

### Team Event Types

```
GET /v2/organizations/{orgId}/teams/{teamId}/event-types
POST /v2/organizations/{orgId}/teams/{teamId}/event-types
```

---

## Pagination

Most list endpoints support cursor-based pagination using `take` and `skip`:

| Parameter | Description |
|---|---|
| `take` | Number of records to return |
| `skip` | Number of records to skip |

**Example:**

```http
GET /v2/bookings?take=20&skip=40
```

---

## SDK & Tools

Cal.com does not have an official Node.js SDK as of early 2026, but the API is fully usable via standard HTTP clients. OpenAPI/Swagger specs are available in the cal.com GitHub repository under `docs/api-reference/v2/openapi.json`.

---

*Sources:*
- https://cal.com/docs/api-reference/v2/introduction
- https://cal.com/docs/api-reference/v2/bookings/get-all-bookings
- https://cal.com/docs/api-reference/v2/bookings/create-a-booking
- https://cal.com/docs/api-reference/v2/bookings/cancel-a-booking
- https://cal.com/docs/api-reference/v2/bookings/reschedule-a-booking
- https://cal.com/docs/api-reference/v2/event-types/get-all-event-types
- https://cal.com/docs/api-reference/v2/slots/get-available-time-slots-for-an-event-type
- https://cal.com/docs/api-reference/v2/event-types-webhooks/create-a-webhook
- https://github.com/calcom/cal.com/blob/main/docs/api-reference/v2/introduction.mdx
