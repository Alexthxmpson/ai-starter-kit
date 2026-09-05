# Skool API — Technical Reference

**Source:** https://docs.skoolapi.com
**Date documented:** 2026-02-27

---

## Overview

SkoolAPI is a third-party API layer that provides programmatic access to the Skool community platform. Skool itself does not offer a first-party public API; SkoolAPI bridges that gap by letting developers and community managers automate tasks such as member onboarding, post monitoring, webhook-driven notifications, and chat tracking. The API is explicitly described as being in early-stage development with limited endpoint coverage, and the team expands it based on user feedback.

**Base URL:** `https://api.skoolapi.com` (implied; all paths shown as `/v1/...`)
**API Status:** Early development — endpoint coverage is limited
**Format:** JSON request and response bodies

---

## Authentication

### API Key

Every request requires your SkoolAPI secret key passed in the request header.

| Header | Value |
|---|---|
| `X-Api-Secret` | `your_api_secret_here` |

**How to obtain your API key:**

1. Log into the Skool API Dashboard at https://skoolapi.com/
2. Navigate to the "API Keys" section
3. Generate a new API key or copy your existing one
4. Store it securely — this key provides full access to your Skool API account

> The API key authenticates you to the SkoolAPI layer. To actually perform actions against your Skool community, you must also create a **Session** (see Sessions section) using your Skool account credentials.

---

## Core Architecture: Sessions

SkoolAPI uses a two-layer authentication model:

1. **API Key** — authenticates your application to the SkoolAPI service (header on every request)
2. **Session** — represents an authenticated connection to an individual Skool account, scoped to specific communities

Every endpoint that reads or writes community data requires both an API key **and** an active session ID. Sessions serve as the bridge between your application and a specific Skool account/community.

**Session lifecycle:**

```
Create Session (POST /v1/sessions/)
    → Status: pending → active
    → Use session_id on subsequent requests
    → Session may enter: refreshing, authentication_error, internal_error
    → Terminate when done (DELETE /v1/sessions/{session_id})
```

---

## Endpoints

### Sessions

#### POST /v1/sessions/

Create an authenticated session to a Skool account.

**Authentication:** `X-Api-Secret` header (API key only — no session needed to create one)

**Request Body:**

| Field | Type | Required | Description |
|---|---|---|---|
| `email` | string | Yes | Skool account email address |
| `password` | string | Yes | Skool account password |

**Response (201 Created):**

```json
{
  "id": "sess_abc123",
  "status": "pending"
}
```

**Session Status Values:**

| Status | Meaning |
|---|---|
| `pending` | Session is being established |
| `active` | Ready to use for API calls |
| `refreshing` | Session token is being refreshed |
| `authentication_error` | Invalid credentials provided |
| `internal_error` | Server-side error during authentication |

**Error Responses:**

| Status Code | Meaning |
|---|---|
| 422 | Validation error — missing or malformed fields |

**Example:**

```bash
curl -X POST https://api.skoolapi.com/v1/sessions/ \
  -H "X-Api-Secret: your_api_secret_here" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "you@example.com",
    "password": "your_skool_password"
  }'
```

---

#### GET /v1/sessions/{session_id}

Retrieve the current status of an existing session.

**Authentication:** `X-Api-Secret` header

**Path Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | Yes | The session identifier returned from POST /v1/sessions/ |

**Response (200 OK):**

```json
{
  "id": "sess_abc123",
  "status": "active"
}
```

**Error Responses:**

| Status Code | Meaning |
|---|---|
| 422 | Validation error |

**Example:**

```bash
curl -X GET https://api.skoolapi.com/v1/sessions/sess_abc123 \
  -H "X-Api-Secret: your_api_secret_here"
```

---

#### DELETE /v1/sessions/{session_id}

Terminate an authenticated session.

**Authentication:** `X-Api-Secret` header

**Path Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | Yes | The session to terminate |

**Response:** 204 No Content

**Error Responses:**

| Status Code | Meaning |
|---|---|
| 422 | Validation error |

**Example:**

```bash
curl -X DELETE https://api.skoolapi.com/v1/sessions/sess_abc123 \
  -H "X-Api-Secret: your_api_secret_here"
```

---

### Webhooks

Webhooks allow SkoolAPI to push real-time notifications to your application when specific events occur in your Skool communities, eliminating the need to poll for changes.

#### GET /v1/webhooks/

Retrieve all currently registered webhooks for your account.

**Authentication:** `X-Api-Secret` header + `session_id` query parameter

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | Yes | Active session identifier |

**Response (200 OK):**

```json
[
  {
    "id": "wh_xyz789",
    "url": "https://your-app.com/webhooks/skool",
    "group": "your-community-slug",
    "events": ["post", "comment"]
  }
]
```

**Error Responses:**

| Status Code | Meaning |
|---|---|
| 422 | Validation error |

**Example:**

```bash
curl -X GET "https://api.skoolapi.com/v1/webhooks/?session_id=sess_abc123" \
  -H "X-Api-Secret: your_api_secret_here"
```

---

#### POST /v1/webhooks/

Register a new webhook to receive community event notifications.

**Authentication:** `X-Api-Secret` header + `session_id` query parameter

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `session_id` | string | Yes | Active session identifier |

**Request Body:**

| Field | Type | Required | Description |
|---|---|---|---|
| `url` | string | Yes | Your HTTPS endpoint that will receive webhook payloads |
| `group` | string | Yes | Skool community/group identifier (slug) |
| `events` | array | Yes | List of event types to subscribe to |

**Supported Event Types:**

| Event | Triggers When |
|---|---|
| `post` | A new post is created in the community |
| `comment` | A comment is added to a post |
| `group_stats` | Community statistics are updated |
| `chat_update` | A chat message is sent |

**Response (201 Created):**

```json
{
  "id": "wh_xyz789"
}
```

**Error Responses:**

| Status Code | Meaning |
|---|---|
| 404 | Group not found — the community slug is invalid |
| 422 | Validation error — missing or malformed fields |

**Example:**

```bash
curl -X POST "https://api.skoolapi.com/v1/webhooks/?session_id=sess_abc123" \
  -H "X-Api-Secret: your_api_secret_here" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-app.com/webhooks/skool",
    "group": "your-community-slug",
    "events": ["post", "comment", "chat_update"]
  }'
```

---

#### DELETE /v1/webhooks/{webhook_id}

Remove a registered webhook.

**Authentication:** `X-Api-Secret` header

**Path Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `webhook_id` | string | Yes | The webhook identifier to delete |

**Response (200 OK):** Success confirmation

**Error Responses:**

| Status Code | Meaning |
|---|---|
| 422 | Validation error |

**Example:**

```bash
curl -X DELETE https://api.skoolapi.com/v1/webhooks/wh_xyz789 \
  -H "X-Api-Secret: your_api_secret_here"
```

---

## Third-Party Scraper Context

Because SkoolAPI's official endpoint coverage is limited (Sessions + Webhooks are the confirmed documented endpoints as of 2026-02-27), many developers supplement it with third-party Apify actors that can scrape Skool data. These are not part of the official SkoolAPI and operate differently:

| Apify Actor | Data Retrieved |
|---|---|
| Skool Community Scraper | Members, group info, stats |
| Skool Posts + Comments Scraper | Posts, comments, media, course modules |
| Skool Members/Groups Scraper | Member profiles, discovery search |
| Skool Post Scraper | Post content and engagement data |

> **Note:** These are web scraping tools, not official API integrations. They may break when Skool updates its UI.

---

## Error Handling

All endpoints can return a **422 Validation Error** with the following body structure:

```json
{
  "detail": [
    {
      "loc": ["body", "field_name"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

Always validate your request bodies before sending, particularly ensuring `email`, `password`, `url`, `group`, and `events` are provided where required.

---

## Rate Limits

Official rate limit documentation is not published. Given that the API is in early development, treat it conservatively — avoid bulk polling and prefer webhook-driven event consumption over repeated GET requests.

---

## Access Levels and Limitations

| Capability | Available |
|---|---|
| Session management (create/read/delete) | Yes |
| Webhook management (list/create/delete) | Yes |
| Read community posts | Not yet documented as official endpoint |
| Read member list | Not yet documented as official endpoint |
| Read courses/classroom | Not yet documented as official endpoint |
| Read leaderboard | Not yet documented as official endpoint |
| Write/create posts | Not yet documented |
| Write/create comments | Not yet documented |
| Member management (add/remove) | Not yet documented |

> The SkoolAPI team explicitly states the API is in early-stage development. Core community resources (members, posts, courses, events, leaderboard) are referenced in marketing copy but do not yet have formally documented REST endpoints with parameters and response schemas. Watch https://docs.skoolapi.com/ for new endpoint additions.

---

## Quick Start Example (Node.js)

```javascript
const API_KEY = process.env.SKOOL_API_SECRET;

// Step 1: Create a session
const sessionRes = await fetch("https://api.skoolapi.com/v1/sessions/", {
  method: "POST",
  headers: {
    "X-Api-Secret": API_KEY,
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    email: process.env.SKOOL_EMAIL,
    password: process.env.SKOOL_PASSWORD
  })
});
const { id: sessionId, status } = await sessionRes.json();
console.log(`Session created: ${sessionId}, status: ${status}`);

// Step 2: Register a webhook
const webhookRes = await fetch(
  `https://api.skoolapi.com/v1/webhooks/?session_id=${sessionId}`,
  {
    method: "POST",
    headers: {
      "X-Api-Secret": API_KEY,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      url: "https://your-app.com/webhook/skool",
      group: "your-community-slug",
      events: ["post", "comment", "chat_update", "group_stats"]
    })
  }
);
const webhook = await webhookRes.json();
console.log(`Webhook registered: ${webhook.id}`);

// Step 3: Clean up session when done
await fetch(`https://api.skoolapi.com/v1/sessions/${sessionId}`, {
  method: "DELETE",
  headers: { "X-Api-Secret": API_KEY }
});
```

---

## Zapier Integration (Alternative to Direct API)

Skool has an official Zapier integration that provides triggers and actions without requiring the SkoolAPI intermediary layer. This may be useful if you need read access to members or posts today:

- **Trigger:** New member joins community
- **Trigger:** New post created
- Access via: https://zapier.com → search "Skool"

---

## Changelog / Status

The API is actively being developed. The SkoolAPI team adds endpoints based on user demand. Community members on Skool's own platform (skool.com/community) have requested:

- Course engagement analytics via API
- Member count and profile endpoints
- Public API access to community discovery

Monitor https://docs.skoolapi.com/ for new endpoint releases.
