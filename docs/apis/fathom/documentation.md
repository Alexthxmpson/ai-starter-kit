# Fathom Video API — Technical Documentation

**Source:** https://developers.fathom.ai / https://help.fathom.video/en/articles/8368641
**Date documented:** 2026-02-27
**Product:** Fathom Video (fathom.video) — AI meeting notes, transcripts, and summaries

---

## Important: Two Different "Fathom" Products

There are two unrelated products named Fathom — do not confuse them:

| Product | Website | What it does | API docs |
|---|---|---|---|
| **Fathom Video** (this document) | fathom.video | AI meeting notetaker — records, transcribes, summarizes meetings | https://developers.fathom.ai |
| **Fathom Analytics** | usefathom.com | Privacy-focused website analytics | https://usefathom.com/api |

Alexander's API key is for **Fathom Video** (fathom.video). All endpoints in this document are for Fathom Video only.

---

## 1. Overview

Fathom Video is an AI meeting notetaker that joins your Zoom, Google Meet, or Microsoft Teams calls, records audio/video, and generates:
- Full verbatim transcripts with speaker attribution and timestamps
- AI-generated meeting summaries (multiple template types)
- Action items extracted from the conversation
- CRM match data

The Public API allows developers to programmatically retrieve all of this data to build integrations and automations.

**API availability:** The API is public — anyone can browse the docs and start building. You need a Fathom account and API key, but enterprise pricing is not required for API access (unlike Tella).

---

## 2. Base URL

```
https://api.fathom.ai/external/v1
```

All endpoints are prefixed with this base URL.

---

## 3. Authentication

### Method: API Key via Header

All requests must include your API key in the request header.

```http
X-Api-Key: YOUR_FATHOM_API_KEY
```

**How to get your API key:**
1. Log in to your Fathom account at https://app.fathom.video
2. Go to Settings → Developer / API
3. Create a new API key
4. Copy and store it securely — it is shown only once

**Important scope note:** API keys are created at the **user level**.
- Your key can access meetings **recorded by you**
- Your key can access meetings **shared to your Team** (if you have a team)
- Your key **cannot** access private meetings from other users unless they are shared with you

**Example authenticated request:**
```http
GET https://api.fathom.ai/external/v1/meetings
X-Api-Key: fathom_live_abc123xyz789
```

---

## 4. Rate Limiting

| Limit | Value |
|---|---|
| Requests per minute | 60 |
| Scope | Across all API keys for your account |
| Higher limits available | No — Fathom does not offer higher rate limits |

When rate limited, the API returns HTTP `429 Too Many Requests`. Implement exponential backoff and retry logic.

---

## 5. Endpoints

### 5.1 Meetings

#### List Meetings

```
GET /meetings
```

Returns a paginated list of meetings accessible to the authenticated user.

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `cursor` | string | No | Pagination cursor from previous response |
| `limit` | integer | No | Number of results per page (default likely 25, max likely 100) |
| `created_after` | string (ISO 8601) | No | Filter to meetings created after this timestamp. Example: `2025-01-01T00:00:00Z` |
| `created_before` | string (ISO 8601) | No | Filter to meetings created before this timestamp |
| `recorded_by[]` | string (email) | No | Filter to meetings recorded by specific user(s). Pass once per email. Example: `recorded_by[]=alex@example.com` |
| `teams[]` | string (team name) | No | Filter to meetings belonging to specific team(s). Pass once per team. Example: `teams[]=Sales&teams[]=Engineering` |
| `include_transcript` | boolean | No | Include full transcript in each meeting object |
| `include_summary` | boolean | No | Include AI summary in each meeting object |
| `include_action_items` | boolean | No | Include extracted action items in each meeting object |
| `include_crm_matches` | boolean | No | Include CRM match data in each meeting object |

**Example request — list recent meetings with summaries:**
```http
GET https://api.fathom.ai/external/v1/meetings?include_summary=true&created_after=2026-01-01T00:00:00Z&limit=10
X-Api-Key: YOUR_API_KEY
```

**Example request — filter by recorder and team:**
```http
GET https://api.fathom.ai/external/v1/meetings?recorded_by[]=alex@example.com&teams[]=Sales&include_action_items=true
X-Api-Key: YOUR_API_KEY
```

**Example response:**
```json
{
  "limit": 25,
  "next_cursor": "eyJpZCI6MTIzNDU2fQ==",
  "items": [
    {
      "id": "meeting_abc123",
      "recording_id": 987654321,
      "title": "Q1 Sales Review",
      "meeting_title": "Q1 Sales Review — Alex & Sarah",
      "url": "https://fathom.video/meeting/987654321",
      "share_url": "https://fathom.video/share/abcde12345",
      "created_at": "2026-01-15T14:30:00Z",
      "started_at": "2026-01-15T14:30:00Z",
      "ended_at": "2026-01-15T15:12:00Z",
      "duration_seconds": 2520,
      "meeting_type": "zoom",
      "transcript_language": "en",
      "recorded_by": {
        "name": "Alexander Thompson",
        "email": "alex@example.com",
        "team": "Sales"
      },
      "calendar_invitees": [
        {
          "name": "Sarah Johnson",
          "email": "sarah@client.com",
          "is_external": true
        },
        {
          "name": "Alexander Thompson",
          "email": "alex@example.com",
          "is_external": false
        }
      ],
      "default_summary": {
        "template_name": "Sales Call",
        "markdown_formatted": "## Meeting Overview\n\nDiscussed Q1 pipeline and reviewed deal status...\n\n## Key Points\n- Deal A moving to close\n- Follow-up scheduled for Feb 3\n\n## Next Steps\n- Alex to send proposal by Jan 20\n- Sarah to confirm budget approval"
      }
    }
  ]
}
```

---

#### Get Single Meeting

```
GET /meetings/{recording_id}
```

Returns full details for a single meeting by its recording ID.

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `recording_id` | integer | The recording ID (from the `recording_id` field in list response) |

**Query Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `include_transcript` | boolean | Include full transcript |
| `include_summary` | boolean | Include AI summary |
| `include_action_items` | boolean | Include action items |
| `include_crm_matches` | boolean | Include CRM data |

**Example request:**
```http
GET https://api.fathom.ai/external/v1/meetings/987654321?include_transcript=true&include_action_items=true
X-Api-Key: YOUR_API_KEY
```

**Example response (with transcript and action items):**
```json
{
  "id": "meeting_abc123",
  "recording_id": 987654321,
  "title": "Q1 Sales Review",
  "url": "https://fathom.video/meeting/987654321",
  "share_url": "https://fathom.video/share/abcde12345",
  "created_at": "2026-01-15T14:30:00Z",
  "started_at": "2026-01-15T14:30:00Z",
  "ended_at": "2026-01-15T15:12:00Z",
  "meeting_type": "zoom",
  "transcript_language": "en",
  "recorded_by": {
    "name": "Alexander Thompson",
    "email": "alex@example.com",
    "team": "Sales"
  },
  "calendar_invitees": [
    {
      "name": "Sarah Johnson",
      "email": "sarah@client.com",
      "is_external": true
    }
  ],
  "transcript": [
    {
      "speaker": {
        "display_name": "Alexander Thompson",
        "matched_calendar_invitee_email": "alex@example.com"
      },
      "text": "Great, let's kick things off. Sarah, thanks for joining. Can you walk me through where you are on the budget approval?",
      "timestamp": "00:00:05"
    },
    {
      "speaker": {
        "display_name": "Sarah Johnson",
        "matched_calendar_invitee_email": "sarah@client.com"
      },
      "text": "Of course. So we've got internal approval for Q1, but the full annual budget needs sign-off from the CFO.",
      "timestamp": "00:00:18"
    }
  ],
  "action_items": [
    {
      "text": "Alex to send proposal by January 20",
      "assignee": "Alexander Thompson",
      "due_date": null
    },
    {
      "text": "Sarah to confirm budget approval with CFO",
      "assignee": "Sarah Johnson",
      "due_date": null
    }
  ],
  "default_summary": {
    "template_name": "Sales Call",
    "markdown_formatted": "## Meeting Overview\n\nDiscussed Q1 pipeline..."
  }
}
```

---

### 5.2 Teams

#### List Teams

```
GET /teams
```

Returns all teams the authenticated user belongs to.

**Example request:**
```http
GET https://api.fathom.ai/external/v1/teams
X-Api-Key: YOUR_API_KEY
```

**Example response:**
```json
{
  "items": [
    {
      "id": "team_xyz456",
      "name": "Sales",
      "created_at": "2025-06-01T00:00:00Z"
    },
    {
      "id": "team_abc789",
      "name": "Engineering",
      "created_at": "2025-08-15T00:00:00Z"
    }
  ]
}
```

---

#### List Team Members

```
GET /teams/{team_id}/members
```

Returns all members of a specific team.

**Example request:**
```http
GET https://api.fathom.ai/external/v1/teams/team_xyz456/members
X-Api-Key: YOUR_API_KEY
```

**Example response:**
```json
{
  "items": [
    {
      "name": "Alexander Thompson",
      "email": "alex@example.com",
      "role": "admin"
    },
    {
      "name": "Maria Chen",
      "email": "maria@example.com",
      "role": "member"
    }
  ]
}
```

---

### 5.3 Webhooks

Webhooks allow Fathom to push meeting data to your server the moment a recording is processed. This is more efficient than polling the meetings endpoint.

#### Create a Webhook

```
POST /webhooks
```

**Request body:**

| Field | Type | Required | Description |
|---|---|---|---|
| `destination_url` | string | Yes | Your HTTPS endpoint to receive webhook POSTs (⚠️ verified 2026-07-07: field is `destination_url`, NOT `url` — `url` returns "Url can't be blank") |
| `include_transcript` | boolean | At least one of these must be `true` | Include transcript in payload |
| `include_summary` | boolean | At least one of these must be `true` | Include summary in payload |
| `include_action_items` | boolean | At least one of these must be `true` | Include action items in payload |
| `include_crm_matches` | boolean | At least one of these must be `true` | Include CRM match data in payload |
| `triggered_for` | array of strings | No | Which recording types trigger the webhook (see below) |

**`triggered_for` values:**

| Value | Description |
|---|---|
| `my_recordings` | Only your own private recordings |
| `shared_external_recordings` | Recordings shared with you by external users |
| `my_shared_with_team_recordings` | Your recordings that are shared with the team |
| `shared_team_recordings` | Recordings from other team members shared to the team |

**Example request:**
```http
POST https://api.fathom.ai/external/v1/webhooks
X-Api-Key: YOUR_API_KEY
Content-Type: application/json

{
  "destination_url": "https://your-app.com/fathom-webhook",
  "include_transcript": true,
  "include_summary": true,
  "include_action_items": true,
  "include_crm_matches": false,
  "triggered_for": ["my_recordings", "my_shared_with_team_recordings"]
}
```

**Example response:**
```json
{
  "id": "wh_fathom_123",
  "url": "https://your-app.com/fathom-webhook",
  "include_transcript": true,
  "include_summary": true,
  "include_action_items": true,
  "include_crm_matches": false,
  "triggered_for": ["my_recordings", "my_shared_with_team_recordings"],
  "created_at": "2026-02-27T09:00:00Z",
  "status": "active"
}
```

---

#### Delete a Webhook

```
DELETE /webhooks/{webhook_id}
```

**Example request:**
```http
DELETE https://api.fathom.ai/external/v1/webhooks/wh_fathom_123
X-Api-Key: YOUR_API_KEY
```

Returns `204 No Content` on success.

---

#### Webhook Payload Structure

When a meeting is processed and matches your webhook configuration, Fathom sends a POST request to your URL.

**Webhook payload:**
```json
{
  "recording_id": 987654321,
  "url": "https://fathom.video/meeting/987654321",
  "share_url": "https://fathom.video/share/abcde12345",
  "type": "meeting_content_ready",
  "transcript": [...],
  "summary": {
    "template_name": "Sales Call",
    "markdown_formatted": "## Overview\n\n..."
  },
  "action_items": [
    {
      "text": "Send proposal by Friday",
      "assignee": "Alexander Thompson"
    }
  ]
}
```

**Webhook verification headers:**

Every payload includes three headers for verifying authenticity:

| Header | Description |
|---|---|
| `webhook-id` | Unique message identifier for this delivery |
| `webhook-timestamp` | Unix timestamp (seconds since epoch) when webhook was sent |
| `webhook-signature` | Base64-encoded HMAC signature for payload verification |

**Verifying webhook signatures (Node.js example):**
```javascript
const crypto = require('crypto');

function verifyWebhook(payload, headers, secret) {
  const signedContent = `${headers['webhook-id']}.${headers['webhook-timestamp']}.${payload}`;
  const expectedSig = crypto
    .createHmac('sha256', secret)
    .update(signedContent)
    .digest('base64');

  const receivedSigs = headers['webhook-signature'].split(' ');
  return receivedSigs.some(sig => sig.split(',')[1] === expectedSig);
}
```

---

## 6. Pagination

The Meetings list endpoint uses **cursor-based pagination**.

| Field | Description |
|---|---|
| `next_cursor` | Pass this value as `cursor` in your next request to get the next page |
| `limit` | Number of items returned per page |

When `next_cursor` is `null` or absent, you have reached the last page.

**Example paginated iteration (Python):**
```python
import requests

headers = {"X-Api-Key": "YOUR_API_KEY"}
base_url = "https://api.fathom.ai/external/v1/meetings"
cursor = None
all_meetings = []

while True:
    params = {"limit": 100, "include_summary": "true"}
    if cursor:
        params["cursor"] = cursor

    response = requests.get(base_url, headers=headers, params=params)
    data = response.json()

    all_meetings.extend(data.get("items", []))
    cursor = data.get("next_cursor")

    if not cursor:
        break

print(f"Total meetings fetched: {len(all_meetings)}")
```

---

## 7. Error Codes

| Status Code | Meaning | Typical Cause |
|---|---|---|
| `200 OK` | Success | — |
| `201 Created` | Resource created | Webhook created successfully |
| `204 No Content` | Success, no body | Webhook deleted |
| `400 Bad Request` | Invalid request | Missing required fields, bad date format |
| `401 Unauthorized` | Auth failure | Missing or invalid `X-Api-Key` |
| `403 Forbidden` | Access denied | Trying to access another user's private recordings |
| `404 Not Found` | Resource not found | Invalid recording ID or webhook ID |
| `422 Unprocessable Entity` | Validation error | At least one include flag must be true (webhooks) |
| `429 Too Many Requests` | Rate limited | Exceeded 60 req/min — back off and retry |
| `500 Internal Server Error` | Fathom server error | Check https://help.fathom.video for status |

**Error response body format:**
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing API key"
}
```

---

## 8. Meeting Types

The `meeting_type` field in meeting responses indicates the platform where the meeting was recorded:

| Value | Platform |
|---|---|
| `zoom` | Zoom |
| `google_meet` | Google Meet |
| `microsoft_teams` | Microsoft Teams |
| `webex` | Cisco Webex |

---

## 9. Summary Templates

Fathom generates summaries using templates. The `default_summary.template_name` field indicates which template was applied. Common templates include:

- `Sales Call` — For sales-focused meetings
- `Discovery Call` — For initial client discovery
- `Team Meeting` — For internal team meetings
- `1:1` — For one-on-one meetings
- `Interview` — For hiring interviews
- Custom templates (if configured in Fathom settings)

---

## 10. Quickstart — Complete Working Example

**List your last 5 meetings with summaries and action items:**

```bash
curl -s \
  -H "X-Api-Key: YOUR_API_KEY" \
  "https://api.fathom.ai/external/v1/meetings?limit=5&include_summary=true&include_action_items=true" \
  | jq '.items[] | {title: .title, date: .created_at, summary: .default_summary.markdown_formatted}'
```

**Create a webhook to receive all your meetings:**

```bash
curl -s -X POST \
  -H "X-Api-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-app.com/fathom-webhook",
    "include_transcript": true,
    "include_summary": true,
    "include_action_items": true,
    "triggered_for": ["my_recordings"]
  }' \
  "https://api.fathom.ai/external/v1/webhooks"
```

---

## 11. Testing Webhooks Locally

Use a tunneling tool to expose a local server for webhook testing:

```bash
# Using ngrok
ngrok http 3000

# Your webhook URL becomes something like:
# https://abc123.ngrok.io/fathom-webhook
```

Fathom also provides a webhook testing guide: https://help.fathom.video/en/articles/10625473

---

## 12. Official Resources

| Resource | URL |
|---|---|
| Developer docs | https://developers.fathom.ai |
| Quickstart guide | https://developers.fathom.ai/quickstart |
| Webhooks reference | https://developers.fathom.ai/webhooks |
| Create webhook API ref | https://developers.fathom.ai/api-reference/webhooks/create-a-webhook |
| List meetings API ref | https://developers.fathom.ai/api-reference/meetings/list-meetings |
| Public API help article | https://help.fathom.video/en/articles/8368641 |
| Webhook testing guide | https://help.fathom.video/en/articles/10625473 |
| Support email | help@fathom.video |
