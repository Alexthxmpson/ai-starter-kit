# Tella API — Technical Documentation

**Source:** https://www.tella.tv / https://apitracker.io/a/tella-tv / https://status.tella.tv/public-api
**Date documented:** 2026-02-27
**Product:** Tella (tella.tv) — AI screen recorder and video hosting platform

---

## Important Limitation Notice

Tella does NOT publish a full, freely accessible public REST API reference. The API exists and is confirmed operational (Tella maintains a status page at https://status.tella.tv/public-api), but access to detailed endpoint documentation is gated. Based on available evidence:

- API access is an **enterprise/custom plan feature** — not available on Pro ($16/mo) or Premium ($42/mo) standard plans
- No public OpenAPI/Swagger spec is available without an account with API access enabled
- The API is described as covering video management, sharing, embedding, and webhooks
- Tella uses Mux as its video infrastructure backend

This document covers everything confirmed publicly available. Gaps are explicitly noted.

---

## 1. Overview

Tella is an AI-powered screen recorder and video hosting platform. It allows users to record screens, webcams, or both; apply AI editing (auto-cut silences, studio voice enhancement); and host/share videos with embedded players.

The Tella API enables programmatic access to:
- Video/recording management (list, retrieve, delete)
- Sharing and embed configuration
- Webhooks for recording lifecycle events
- (Potentially) uploading or triggering recordings

---

## 2. Base URL

No officially published base URL is publicly confirmed. Based on available evidence, the API likely operates at:

```
https://api.tella.tv/v1/
```

or through a private subdomain accessible only with an enterprise API key.

---

## 3. Authentication

### Method: API Key

Tella uses API key-based authentication. API keys are generated in account settings under the API section.

Based on industry-standard patterns confirmed via API Tracker and Tella's own "API settings" documentation:

```http
Authorization: Bearer YOUR_API_KEY
```

or potentially:

```http
X-Api-Key: YOUR_API_KEY
```

**How to get an API key:**
1. Log in to your Tella account at https://www.tella.tv
2. Navigate to Settings → API
3. Generate a new API key (enterprise plan required)

**Security notes:**
- API keys are tied to individual user accounts
- Keys should be treated as secrets — do not embed in client-side code
- Rotate keys immediately if compromised via the Settings panel

---

## 4. Confirmed API Capabilities

The following capabilities are confirmed to exist based on Tella's status page, API tracker data, and integration documentation:

### 4.1 Video Management

| Capability | Status |
|---|---|
| List videos/recordings | Confirmed |
| Get video by ID | Confirmed |
| Delete video | Likely available |
| Update video metadata | Likely available |
| Upload video | Unconfirmed |

### 4.2 Sharing & Embedding

| Capability | Status |
|---|---|
| Get embed code / embed URL | Confirmed (via oEmbed) |
| Set password protection on video | Confirmed (UI feature, API unclear) |
| Configure privacy settings | Likely available |
| Custom domain support | Enterprise feature |

### 4.3 Webhooks

Tella is confirmed to have a webhooks management API based on API Tracker data.

| Capability | Status |
|---|---|
| Create webhook | Confirmed |
| Delete webhook | Confirmed |
| List webhooks | Likely available |
| Receive recording lifecycle events | Confirmed |

---

## 5. Endpoints (Best Available)

The following endpoints represent what is known or strongly inferred. Treat unconfirmed paths as approximate.

### 5.1 Videos

#### List Videos
```
GET /v1/videos
```

**Query parameters:**

| Parameter | Type | Description |
|---|---|---|
| `page` | integer | Page number for pagination |
| `per_page` | integer | Results per page (likely max 100) |
| `created_after` | string (ISO 8601) | Filter by creation date |
| `created_before` | string (ISO 8601) | Filter by creation date |

**Example request:**
```http
GET https://api.tella.tv/v1/videos?page=1&per_page=25
Authorization: Bearer YOUR_API_KEY
```

**Example response (inferred structure):**
```json
{
  "data": [
    {
      "id": "abc123def456",
      "title": "Product Demo Q4",
      "created_at": "2026-01-15T10:30:00Z",
      "duration_seconds": 142,
      "status": "ready",
      "url": "https://www.tella.tv/video/abc123def456/view",
      "share_url": "https://www.tella.tv/video/abc123def456/view",
      "thumbnail_url": "https://cdn.tella.tv/thumbnails/abc123def456.jpg",
      "privacy": "public"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 25,
    "total": 87
  }
}
```

#### Get Single Video
```
GET /v1/videos/{video_id}
```

**Example request:**
```http
GET https://api.tella.tv/v1/videos/abc123def456
Authorization: Bearer YOUR_API_KEY
```

#### Delete Video
```
DELETE /v1/videos/{video_id}
```

**Example request:**
```http
DELETE https://api.tella.tv/v1/videos/abc123def456
Authorization: Bearer YOUR_API_KEY
```

---

### 5.2 Webhooks

Tella's webhooks management API is confirmed. Webhooks notify your endpoint when recording/video events occur.

#### Create Webhook
```
POST /v1/webhooks
```

**Request body:**
```json
{
  "url": "https://your-app.com/tella-webhook",
  "events": ["recording.completed", "video.ready"],
  "secret": "your_signing_secret"
}
```

**Example request:**
```http
POST https://api.tella.tv/v1/webhooks
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json

{
  "url": "https://your-app.com/tella-webhook",
  "events": ["recording.completed", "video.ready"]
}
```

**Example response:**
```json
{
  "id": "wh_xyz789",
  "url": "https://your-app.com/tella-webhook",
  "events": ["recording.completed", "video.ready"],
  "created_at": "2026-02-27T09:00:00Z",
  "status": "active"
}
```

#### Delete Webhook
```
DELETE /v1/webhooks/{webhook_id}
```

#### Webhook Event Payload (Inferred Structure)

When an event fires, Tella sends a POST request to your endpoint:

```json
{
  "event": "recording.completed",
  "timestamp": "2026-02-27T09:15:32Z",
  "data": {
    "video_id": "abc123def456",
    "title": "My Recording",
    "duration_seconds": 245,
    "url": "https://www.tella.tv/video/abc123def456/view",
    "status": "ready"
  }
}
```

**Likely webhook events:**

| Event | Trigger |
|---|---|
| `recording.completed` | Recording finishes processing |
| `video.ready` | Video is published and viewable |
| `video.deleted` | Video is deleted |
| `export.completed` | Video export finishes |

---

### 5.3 oEmbed (Public — No Auth Required)

Tella supports the oEmbed standard for generating embed codes. This endpoint is publicly documented via Embedly.

```
GET https://www.tella.tv/oembed
```

**Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `url` | string | Yes | Full Tella video URL |
| `maxwidth` | integer | No | Max width of embed |
| `maxheight` | integer | No | Max height of embed |
| `format` | string | No | `json` (default) or `xml` |

**Example request:**
```http
GET https://www.tella.tv/oembed?url=https://www.tella.tv/video/abc123/view&maxwidth=800
```

**Example response:**
```json
{
  "type": "video",
  "version": "1.0",
  "title": "My Tella Video",
  "author_name": "Alexander Thompson",
  "provider_name": "Tella",
  "provider_url": "https://www.tella.tv",
  "thumbnail_url": "https://cdn.tella.tv/thumbnails/abc123.jpg",
  "thumbnail_width": 1280,
  "thumbnail_height": 720,
  "width": 800,
  "height": 450,
  "html": "<iframe src=\"https://www.tella.tv/video/abc123/embed\" width=\"800\" height=\"450\" frameborder=\"0\"></iframe>"
}
```

---

## 6. Video Embedding (Confirmed)

Tella videos can be embedded anywhere using an iframe. This is a documented public feature.

**Standard embed URL pattern:**
```
https://www.tella.tv/video/{video_id}/embed
```

**Example iframe embed:**
```html
<iframe
  src="https://www.tella.tv/video/abc123def456/embed"
  width="100%"
  height="450"
  frameborder="0"
  allow="autoplay; fullscreen"
  allowfullscreen>
</iframe>
```

**Embed options (via URL parameters):**

| Parameter | Description | Example |
|---|---|---|
| `autoplay` | Auto-play on load | `?autoplay=1` |
| `loop` | Loop video | `?loop=1` |
| `t` | Start at timestamp (seconds) | `?t=30` |

---

## 7. Rate Limits

No official rate limit documentation is publicly available. Based on API Tracker data indicating the API supports standard developer features, typical limits are expected to be:

| Tier | Expected Limit |
|---|---|
| Enterprise API | Unknown — contact Tella |
| Burst | Unknown |

Best practice: Implement exponential backoff on `429 Too Many Requests` responses.

---

## 8. Error Codes

Standard HTTP status codes apply. Tella-specific error body format is not publicly documented.

| Status Code | Meaning | Action |
|---|---|---|
| `200 OK` | Success | — |
| `201 Created` | Resource created | — |
| `204 No Content` | Success, no body (e.g., DELETE) | — |
| `400 Bad Request` | Invalid parameters | Check request body |
| `401 Unauthorized` | Missing or invalid API key | Verify API key |
| `403 Forbidden` | Access denied to resource | Check permissions/plan |
| `404 Not Found` | Video/resource doesn't exist | Verify ID |
| `429 Too Many Requests` | Rate limit exceeded | Back off and retry |
| `500 Internal Server Error` | Tella-side issue | Check status.tella.tv |

**Inferred error response format:**
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Invalid or missing API key"
  }
}
```

---

## 9. Status & Uptime

Tella publishes a status page:
- **Status page:** https://status.tella.tv
- **Public API status:** https://status.tella.tv/public-api
- **Summary JSON:** https://status.tella.tv/summary.json

Monitored components include:
- Public API
- Exports and Rendering Infrastructure
- Upload processing

---

## 10. Plans & API Access

| Plan | Price | API Access |
|---|---|---|
| Free | $0 | No |
| Pro | $16/mo (annual) | No |
| Premium | $42/mo (annual) | No |
| Enterprise | Custom pricing | Yes — API access included |

Enterprise plans also include:
- SSO / SCIM
- Custom branding and domains
- Advanced analytics
- Priority support

To request API access: Contact Tella sales or support via https://www.tella.tv

---

## 11. Infrastructure Notes

- Tella uses **Mux** for video storage, processing, and delivery (confirmed via Mux case study)
- Video CDN delivery is handled by Mux's global infrastructure
- This means upload processing times, video quality levels, and HLS streaming follow Mux's capabilities

---

## 12. SDKs & Integrations

No official SDKs are publicly documented. However:
- **Embedly** — oEmbed embed integration (public)
- **Zapier** — No official Tella Zapier app found
- **Make.com** — No official Tella module found
- **n8n** — No official Tella node found

Tella focuses on manual workflows and UI-based sharing rather than deep automation integrations for non-enterprise users.

---

## 13. Key Gotchas & Limitations

1. **API is enterprise-only.** Standard Pro/Premium plans do not include API access. You must be on a custom enterprise plan.
2. **Documentation is private.** The full API reference is not publicly published. Endpoint details must be obtained from Tella support/sales after getting API access.
3. **No public SDK.** There is no official client library for any language.
4. **No upload API confirmed.** Uploading videos programmatically is not confirmed — Tella's primary flow is recording via the desktop app.
5. **Status page exists** at https://status.tella.tv/public-api — monitor this for outages.
6. **oEmbed is free and public** — no API key needed for generating embed codes.

---

## Sources

- [Tella API Tracker](https://apitracker.io/a/tella-tv)
- [Tella Public API Status](https://status.tella.tv/public-api)
- [Tella oEmbed via Embedly](https://embed.ly/provider/tella)
- [Tella Pricing](https://www.tella.com/pricing)
- [Mux Case Study — Tella](https://www.mux.com/case-studies/tella)
- [Tella llms.txt](https://www.tella.tv/llms.txt)
- [Tella Help — Embed](https://www.tella.com/help/embed)
