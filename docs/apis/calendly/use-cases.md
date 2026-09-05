# Calendly API v2 — Use Cases & Practical Reference

**Date:** 2026-02-27
**Base URL:** `https://api.calendly.com`
**Auth:** `Authorization: Bearer YOUR_PAT`

---

## What You Can Do

### Read Scheduling Data
- Get all scheduled events for a user or entire organization (with date/status filtering)
- Get individual event details including location, attendees, and meeting link
- List all invitees for any event, including their answers to custom questions
- Retrieve event types (public or private), their duration, slug, and scheduling URL
- Pull routing form submissions and see where invitees were routed
- Check user availability schedules and busy times from calendar integrations

### Organization Management
- List all organization members with their roles (owner/admin/user)
- Invite new members to the organization or revoke pending invitations
- Remove existing members

### Webhooks (Real-Time Events)
- Create webhook subscriptions for `invitee.created`, `invitee.canceled`, `invitee_no_show.created`, and `routing_form_submission.created`
- Scope webhooks to your whole organization or just one specific user
- List and delete existing webhook subscriptions

### Cancellations
- Cancel any scheduled event via API (with an optional reason)
- The cancel/reschedule URLs on invitee objects link to Calendly's hosted pages — invitees can self-service without API access

### What You Cannot Do
- **Reschedule an event via API** — there is no reschedule endpoint. Use the `reschedule_url` from the invitee object to redirect users.
- **Create bookings/schedule events directly via API** — you cannot programmatically schedule a meeting on behalf of an invitee. Invitees must book via Calendly's hosted scheduling page.
- **Modify event types or availability** — the API is read-only for these resources.

---

## Automation & Project Ideas

| Project | Endpoints Used | Description |
|---|---|---|
| Booking CRM sync | Webhook `invitee.created` + `GET /scheduled_events/{uuid}/invitees/{uuid}` | When a meeting is booked, push the invitee's details and custom question answers to HubSpot, Pipedrive, or Airtable |
| Cancellation alerts | Webhook `invitee.canceled` | Post a Slack message when a meeting is cancelled so the team sees it immediately |
| No-show tracker | Webhook `invitee_no_show.created` | Log no-shows to a sheet, update CRM deal stage, or trigger a follow-up email sequence |
| Daily meeting digest | `GET /scheduled_events` with `min_start_time` = today | Morning Slack/email digest of all meetings scheduled for the day across the org |
| Meeting history export | `GET /scheduled_events` + pagination loop | Export all past meetings to a CSV or data warehouse for reporting |
| Invitee data enrichment | Webhook `invitee.created` → `GET /scheduled_events/{uuid}/invitees/{uuid}` | Use the URI from the webhook to pull full invitee object (questions/answers, UTM params) |
| Routing form analytics | `GET /routing_form_submissions` | Aggregate where leads are being routed, answer patterns, and conversion rates |
| Org member dashboard | `GET /organization_memberships` + `GET /event_types` | Internal tool showing each member's active event types and recent booking volume |
| UTM attribution | Webhook payload `tracking` field | Capture `utm_source`, `utm_campaign`, etc. from bookings and associate with marketing campaigns |
| Availability-aware scheduling tool | `GET /user_busy_times` | Build a custom meeting finder that respects busy blocks before suggesting a time |
| Webhook health monitor | `GET /webhook_subscriptions` | Periodic check that your webhooks are still `active` state — recreate if they've been disabled |
| Lead routing analytics | `GET /routing_form_submissions` | Track which routing form paths get the most submissions and measure booking conversion per route |

---

## Key Limits & Gotchas

### Rate Limits
- Exact limits are not publicly documented.
- Community reports suggest staying under **~100 requests/minute** per token.
- Always handle `429 Too Many Requests` with exponential backoff.
- For large bulk pulls, add deliberate delays (200ms+) between paginated requests.
- Use `min_start_time` incremental fetching rather than pulling all history at once.

### Authentication Gotchas
- A PAT is scoped to the **user who generated it**. A member-level PAT cannot access org-wide data.
- To access org-level data (all members' events), you need a PAT from an **admin or owner**.
- PATs do not expire on a schedule but can be revoked from the Calendly dashboard — build token rotation/re-auth into long-running integrations.
- OAuth tokens expire; implement refresh token logic for OAuth integrations.

### URIs vs. UUIDs
- Calendly uses full **URI strings** (not integer IDs) to reference resources in parameters and relationships. Example: `https://api.calendly.com/users/ABCDEF123456`
- Always extract the UUID from the URI when needed: the UUID is the last path segment.
- The `GET /users/me` endpoint is essential first call — use it to get your `uri` and `current_organization` URI for all subsequent requests.

### Webhooks
- Webhook subscriptions require a **paid Calendly plan** (Premium and above). They will not work on the free/Basic plan.
- `organization` scope = events for all org members. `user` scope = events for one specific user.
- Routing form submission webhooks **only support `organization` scope** — you cannot scope them to a single user.
- Subscribing to both `invitee.created` and `invitee.canceled` gives you the full lifecycle of all scheduled/cancelled events across the org.
- When an invitee reschedules, you receive: `invitee.canceled` for the old event AND `invitee.created` for the new one. Check `is_reschedule: true` on the new invitee to distinguish.
- Set a `signing_key` and always verify webhook signatures. Unverified webhooks are a security risk.
- If a webhook endpoint is down for too long, Calendly may set the subscription to an inactive state — monitor `state` field via `GET /webhook_subscriptions`.

### Scheduled Events
- Filtering by `organization` gives all org members' events; filtering by `user` gives one user's events — you must pass one of these.
- `invitees_counter.total` on the event tells you how many people booked, but you need to call `GET /scheduled_events/{uuid}/invitees` to get their details.
- For incremental syncs, use `min_start_time` set to your last sync time — past events don't change, so you only need to fetch events starting after your last check.
- The `cancel_url` and `reschedule_url` on invitee objects are the hosted Calendly pages. Send these to invitees if they need to self-manage.

### Pagination
- Default page size is **20**; max is **100**. Always set `count=100` to minimize API calls.
- Paginate by passing `page_token` from `pagination.next_page_token` in each response.
- Stop when `next_page_token` is `null`.
- Note: there have been community reports of `page_token` inconsistencies on `GET /scheduled_events` with certain filter combinations — test your pagination logic thoroughly.

### Plan / Permissions
- Routing forms are only available on Professional plan and above.
- Some org-level management endpoints require Enterprise plan.
- Always check if a `403` is a permissions issue (role too low) vs. a plan issue (feature not available on your tier).

---

## Quick Reference: Core Endpoint Cheatsheet

```
# Auth / Identity
GET    /users/me                                          Get current user + org URI

# Event Types
GET    /event_types?user={uri}                            List event types for a user
GET    /event_types?organization={uri}                    List event types for an org
GET    /event_types/{uuid}                                Get single event type

# Scheduled Events
GET    /scheduled_events?organization={uri}               List all org events
GET    /scheduled_events?user={uri}                       List one user's events
GET    /scheduled_events/{uuid}                           Get single event
POST   /scheduled_events/{uuid}/cancellation              Cancel an event

# Invitees
GET    /scheduled_events/{uuid}/invitees                  List invitees for an event
GET    /scheduled_events/{uuid}/invitees/{uuid}           Get single invitee

# Organizations
GET    /organization_memberships?organization={uri}       List org members
GET    /organization_memberships/{uuid}                   Get single member
DELETE /organization_memberships/{uuid}                   Remove a member
POST   /organizations/{uuid}/invitations                  Invite a user
DELETE /organizations/{uuid}/invitations/{uuid}           Revoke an invitation

# Webhooks
GET    /webhook_subscriptions?organization={uri}          List webhooks
POST   /webhook_subscriptions                             Create webhook
DELETE /webhook_subscriptions/{uuid}                      Delete webhook

# Routing Forms
GET    /routing_forms?organization={uri}                  List routing forms
GET    /routing_forms/{uuid}                              Get single form
GET    /routing_form_submissions?form={uri}               List form submissions
GET    /routing_form_submissions/{uuid}                   Get single submission

# Availability
GET    /user_availability_schedules?user={uri}            Get user's availability rules
GET    /user_busy_times?user={uri}&start_time=&end_time=  Get user's busy blocks
```

---

## Minimal Working Example (Node.js)

```javascript
const PAT = 'YOUR_PERSONAL_ACCESS_TOKEN';
const BASE = 'https://api.calendly.com';

// Step 1: Get your user URI and org URI
async function getMe() {
  const res = await fetch(`${BASE}/users/me`, {
    headers: { Authorization: `Bearer ${PAT}` }
  });
  const { resource } = await res.json();
  return {
    userUri: resource.uri,
    orgUri: resource.current_organization
  };
}

// Step 2: List today's upcoming events for the org
async function getTodaysEvents(orgUri) {
  const today = new Date().toISOString();
  const tomorrow = new Date(Date.now() + 86400000).toISOString();

  const url = new URL(`${BASE}/scheduled_events`);
  url.searchParams.set('organization', orgUri);
  url.searchParams.set('status', 'active');
  url.searchParams.set('min_start_time', today);
  url.searchParams.set('max_start_time', tomorrow);
  url.searchParams.set('count', '100');

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${PAT}` }
  });
  const data = await res.json();
  return data.collection;
}

// Step 3: Create a webhook subscription
async function createWebhook(orgUri) {
  const res = await fetch(`${BASE}/webhook_subscriptions`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${PAT}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      url: 'https://my-app.com/webhooks/calendly',
      events: ['invitee.created', 'invitee.canceled'],
      organization: orgUri,
      scope: 'organization',
      signing_key: 'my-secret-signing-key'
    })
  });
  return res.json();
}

// Usage
const { userUri, orgUri } = await getMe();
const events = await getTodaysEvents(orgUri);
console.log(`${events.length} meetings today`);
```

---

*Sources: https://developer.calendly.com/api-docs/d7a08c7f8e6f7-calendly-developer | https://developer.calendly.com/api-docs/*
