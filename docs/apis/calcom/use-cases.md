# Cal.com API v2 — Use Cases & Practical Reference

**Date:** 2026-02-27
**API Version:** v2 (date-versioned; use header `cal-api-version: 2024-06-14`)
**Base URL:** `https://api.cal.com/v2`

---

## What You Can Do

### Booking Management
- List all bookings with filters (status, date range, attendee email, event type)
- Create bookings programmatically on behalf of users
- Cancel individual bookings, specific seats in group events, or entire recurring series
- Reschedule bookings with automatic or manual host confirmation

### Scheduling / Availability
- Query available time slots for any event type across any date range
- Check availability per user, per team, or for dynamic multi-host event types
- Retrieve slots in multiple formats (start-only or start+end range)

### Event Type Management
- List, create, update, and delete event types
- Manage locations, booking fields, pricing, recurrence settings
- Support dynamic event types (multi-host, round-robin)

### Webhooks
- Subscribe to booking lifecycle events per event type
- Receive real-time notifications on create, reschedule, cancel, confirm, reject, complete, no-show
- Attach secrets for payload verification

### Platform / Managed Users (OAuth)
- Create and manage Cal.com accounts for your own users (white-label scheduling)
- Issue access tokens per managed user
- Create team event types, manage org members

---

## Automation & Project Ideas

| Project | Endpoints Used | Description |
|---|---|---|
| Booking sync to CRM | `GET /v2/bookings` + webhook | Pull new bookings periodically or receive real-time; push to HubSpot/Pipedrive |
| No-show tracker | Webhook `BOOKING_NO_SHOW` | Log no-shows to a sheet or CRM; trigger follow-up email |
| Availability checker bot | `GET /v2/slots` | Slack/Discord bot that replies with open slots for a given week |
| Meeting scheduler widget | `GET /v2/slots` + `POST /v2/bookings` | Custom booking UI embedded in your app — query slots, confirm booking |
| Auto-cancel past-due unconfirmed | `GET /v2/bookings?status=pending` + `POST /v2/bookings/{uid}/cancel` | Cron job that cancels unconfirmed bookings older than N hours |
| Booking confirmation emails | Webhook `BOOKING_CREATED` | Custom transactional emails with your branding instead of Cal.com defaults |
| Calendar dashboard | `GET /v2/bookings` with date filters | Internal tool showing all upcoming bookings across team members |
| White-label scheduling platform | OAuth + Managed Users API | Let your users schedule via your app while Cal.com runs the backend |
| Recurring meeting management | `GET /v2/bookings?status=recurring` | List all recurring series, surface them in a custom UI with cancel/reschedule |
| Slot-based lead routing | `GET /v2/slots` + `POST /v2/bookings` | Based on form submission, auto-book a discovery call with the right team member |

---

## Key Limits & Gotchas

### Rate Limits

| Auth Type | Limit |
|---|---|
| API Key | 120 req/min |
| OAuth / Managed User Token | 500 req/min |
| No auth | 120 req/min |

- Higher limits (up to ~800 req/min) require contacting support and may cost extra.
- On `429`, back off and retry. Implement exponential backoff.

### Authentication Gotchas
- API keys are personal — they only access resources owned by that specific user.
- OAuth `x-cal-secret-key` is required for managed user operations — the Bearer token alone is not enough to create managed users or OAuth webhooks.
- Access tokens expire in **60 minutes**. Build token refresh logic before going to production.
- Always store `calManagedUserId`, `calAccessToken`, and `calRefreshToken` when creating managed users.

### Versioning
- The `cal-api-version` header is **required** on most endpoints.
- Missing this header causes endpoints to fall back to an older, potentially incompatible version.
- Use `2024-06-14` as your default. Upgrade to `2024-08-13` when specific endpoints require it.

### Bookings
- The `uid` and `id` are different fields. The `uid` (string) is used in URLs; the `id` (integer) is used for references in other objects.
- Cancelling with a recurring booking UID cancels **all future recurrences** — not just one. Use the individual recurrence UID to cancel a single occurrence.
- For seated event types (group bookings), use `seatUid` in the cancel request to cancel a single attendee's seat without cancelling the entire session.
- When rescheduling, if `rescheduledBy` is the host email, the booking is auto-confirmed. If it's anyone else, the host must manually confirm (if confirmation mode is on).
- `phoneNumber` on the attendee object is optional but becomes effectively required when the event type has SMS reminder workflows — the API will silently skip the reminder without it.

### Slots / Availability
- `start` and `end` parameters must be in **UTC ISO 8601**. If you pass a date without time, it defaults to the start of that day UTC.
- The `timeZone` parameter only affects how slots are **displayed** in the response, not which slots are returned.
- For multi-duration event types, you must pass the `duration` parameter explicitly, or the API returns the default duration's slots only.

### Webhooks
- Webhooks are scoped **per event type** in v2 — there is no global user-level webhook.
- Always verify webhook payloads using the `secret` you set on creation.
- The `payloadTemplate` field lets you customize the webhook JSON payload format if you need a specific structure for your receiving endpoint.

### Pagination
- Uses `take` / `skip` (offset pagination), not cursor-based. Safe for small to medium datasets; avoid large `skip` values on very large datasets as performance degrades.

### Self-Hosted Cal.com
- Replace `https://api.cal.com/v2` with your own domain. All other behavior is the same.

---

## Quick Reference: Core Endpoint Cheatsheet

```
GET    /v2/bookings                              List bookings (with filters)
GET    /v2/bookings/{uid}                        Get single booking
POST   /v2/bookings                              Create booking
POST   /v2/bookings/{uid}/cancel                 Cancel booking
POST   /v2/bookings/{uid}/reschedule             Reschedule booking

GET    /v2/event-types                           List event types
GET    /v2/event-types/{id}                      Get single event type
POST   /v2/event-types                           Create event type
PATCH  /v2/event-types/{id}                      Update event type
DELETE /v2/event-types/{id}                      Delete event type

GET    /v2/slots                                 Get available slots

GET    /v2/event-types/{id}/webhooks             List webhooks for event type
POST   /v2/event-types/{id}/webhooks             Create webhook
DELETE /v2/event-types/{id}/webhooks/{wid}       Delete webhook

POST   /v2/oauth/{clientId}/users               Create managed user
POST   /v2/oauth/{clientId}/refresh             Refresh managed user token
```

---

## Minimal Working Example (Node.js)

```javascript
// List upcoming bookings
const response = await fetch('https://api.cal.com/v2/bookings?status=upcoming&take=10', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY',
    'cal-api-version': '2024-06-14'
  }
});
const { status, data } = await response.json();
console.log(data); // array of booking objects

// Create a booking
const booking = await fetch('https://api.cal.com/v2/bookings', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY',
    'cal-api-version': '2024-06-14',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    eventTypeId: 456,
    start: '2026-03-01T10:00:00.000Z',
    attendee: {
      name: 'John Doe',
      email: 'john@example.com',
      timeZone: 'America/New_York'
    }
  })
});
const result = await booking.json();
console.log(result.data.uid); // booking UID for future operations
```

---

*Sources: https://cal.com/docs/api-reference/v2/introduction | https://cal.com/docs/api-reference/v2/bookings/get-all-bookings*
